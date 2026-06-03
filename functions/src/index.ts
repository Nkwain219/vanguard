// functions/src/index.ts
// Vanguard Firebase Cloud Functions — MeSomb payments, user management, notifications
// Cloud Functions v2 | Project: portfolio-5ee70

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";
import { getFirestore } from "firebase-admin/firestore";
import axios from "axios";
import * as nodemailer from "nodemailer";
// Official MeSomb SDK for proper balance retrieval
import { PaymentOperation } from "@hachther/mesomb";

// Initialize Firebase Admin
admin.initializeApp();

const db = getFirestore("vanguard-db");

// Define secrets using the modern params API
// MeSomb requires: applicationKey, accessKey, and secretKey
const mesombAppKey = defineSecret("MESOMB_APP_KEY");
const mesombAccessKey = defineSecret("MESOMB_ACCESS_KEY");
const mesombSecretKey = defineSecret("MESOMB_SECRET_KEY");
const smtpHost = defineSecret("SMTP_HOST");
const smtpPort = defineSecret("SMTP_PORT");
const smtpSecure = defineSecret("SMTP_SECURE");
const smtpUser = defineSecret("SMTP_USER");
const smtpPass = defineSecret("SMTP_PASS");
const smtpFrom = defineSecret("SMTP_FROM");

// MeSomb API base URL (kept for direct API calls if needed)
const MESOMB_BASE_URL = "https://mesomb.hachther.com/api/v1.1";

/**
 * Collect payment from a customer's mobile money account.
 * This function:
 * 1. Validates the user is authenticated
 * 2. Calls MeSomb API to collect payment from user's MTN/Orange Money
 * 3. Records the transaction in Firestore on success
 */
export const collectPayment = onCall(
    { secrets: [mesombAppKey, mesombAccessKey] },
    async (request) => {
        // Ensure user is authenticated
        if (!request.auth) {
            throw new HttpsError(
                "unauthenticated",
                "You must be logged in to make a payment."
            );
        }

        const data = request.data as {
            amount: number;
            phoneNumber: string;
            service: string;
            description?: string;
        };

        const { amount, phoneNumber, service, description } = data;
        const userId = request.auth.uid;

        // Validate input
        if (!amount || amount <= 0) {
            throw new HttpsError(
                "invalid-argument",
                "Amount must be greater than 0."
            );
        }

        if (!phoneNumber || phoneNumber.length < 9) {
            throw new HttpsError(
                "invalid-argument",
                "Invalid phone number."
            );
        }

        const validServices = ["MTN", "ORANGE"];
        const normalizedService = service.toUpperCase();
        if (!validServices.includes(normalizedService)) {
            throw new HttpsError(
                "invalid-argument",
                "Service must be MTN or ORANGE."
            );
        }

        const appKey = mesombAppKey.value();
        const accessKey = mesombAccessKey.value();

        if (!appKey || !accessKey) {
            throw new HttpsError(
                "failed-precondition",
                "Payment service is not configured. Please contact support."
            );
        }

        const reference = `txn_${Date.now()}_${userId.substring(0, 8)}`;

        try {
            // Call MeSomb API to collect payment
            const response = await axios.post(
                `${MESOMB_BASE_URL}/payment/collect/`,
                {
                    amount: Math.round(amount),
                    payer: phoneNumber,
                    service: normalizedService,
                    message: description || "Deposit to company wallet",
                    reference: reference,
                },
                {
                    headers: {
                        "Content-Type": "application/json",
                        "X-MeSomb-Application": appKey,
                        "Authorization": `Token ${accessKey}`,
                    },
                }
            );

            const mesombData = response.data;

            // Record successful transaction to Firestore
            const transaction = {
                id: reference,
                type: "deposit",
                category: "mobileMoney",
                amount: amount,
                description: description || "Mobile Money Deposit",
                submittedBy: userId,
                submittedByName: request.auth.token.name || "User",
                date: admin.firestore.FieldValue.serverTimestamp(),
                status: "completed",
                paymentMethod: normalizedService,
                phoneNumber: phoneNumber.substring(0, 6) + "****", // Mask for privacy
                mesombTransactionId: mesombData.pk || null,
            };

            await db.collection("vanguard_wallet_transactions").doc(reference).set(transaction);

            // Update company wallet balance
            const walletRef = db.collection("vanguard_company_wallet").doc("main");
            await walletRef.set(
                {
                    balance: admin.firestore.FieldValue.increment(amount),
                    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                },
                { merge: true }
            );

            // Update wallet summary for dashboard totals
            const summaryRef = db.collection("vanguard_wallet_summary").doc("current");
            await summaryRef.set(
                {
                    totalBalance: admin.firestore.FieldValue.increment(amount),
                    totalRevenue: admin.firestore.FieldValue.increment(amount),
                    // Monthly tracking
                    monthlyRevenue: admin.firestore.FieldValue.increment(amount),
                    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                },
                { merge: true }
            );

            return {
                success: true,
                transactionId: reference,
                message: `Successfully deposited ${amount} XAF`,
            };

        } catch (error: unknown) {
            console.error("MeSomb API Error:", error);

            if (axios.isAxiosError(error)) {
                const errorMessage = error.response?.data?.message ||
                    error.response?.data?.detail ||
                    "Payment failed. Please try again.";
                throw new HttpsError("aborted", errorMessage);
            }

            throw new HttpsError(
                "internal",
                "An unexpected error occurred. Please try again later."
            );
        }
    }
);

/**
 * Check MeSomb account balance and statistics (admin only)
 * 
 * Uses the official MeSomb SDK's PaymentOperation.getStatus() method.
 * Also calls the raw API to get total credit/debit statistics.
 * 
 * Documentation: https://pub.dev/packages/mesomb
 * SDK: @hachther/mesomb
 */
export const checkBalance = onCall(
    { secrets: [mesombAppKey, mesombAccessKey, mesombSecretKey] },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "Must be logged in.");
        }

        // Get user's role from Firestore to verify admin
        const userDoc = await db.collection("vanguard_users").doc(request.auth.uid).get();
        const userData = userDoc.data();

        if (userData?.role !== "admin") {
            throw new HttpsError("permission-denied", "Admin access required.");
        }

        const appKey = mesombAppKey.value();
        const accessKey = mesombAccessKey.value();
        const secretKey = mesombSecretKey.value();

        if (!appKey || !accessKey || !secretKey) {
            console.error("Missing MeSomb credentials");
            throw new HttpsError(
                "failed-precondition",
                "MeSomb credentials not configured. Please add MESOMB_SECRET_KEY."
            );
        }

        try {
            // Use official MeSomb SDK for balance
            const payment = new PaymentOperation({
                applicationKey: appKey,
                accessKey: accessKey,
                secretKey: secretKey,
            });

            // getStatus() returns Application object with balances
            const application = await payment.getStatus();

            // Log the full application object for debugging
            console.log("MeSomb Application (SDK):", JSON.stringify(application));

            // getBalance() sums all balances (can filter by country/service)
            const totalBalance = application.getBalance('CM');

            // Also call the raw API to get statistics (credit/debit totals)
            // The SDK might not expose all fields, so we call directly
            let totalCredit = 0;
            let totalDebit = 0;

            try {
                const statsResponse = await axios.get(
                    `${MESOMB_BASE_URL}/application/status/`,
                    {
                        headers: {
                            "Content-Type": "application/json",
                            "X-MeSomb-Application": appKey,
                            "Authorization": `Token ${accessKey}`,
                        },
                    }
                );

                console.log("MeSomb Raw API Response:", JSON.stringify(statsResponse.data));

                // Extract credit and debit from raw response
                // Field names might be: credit, debit, all_time_credit, all_time_debit, 
                // total_credit, total_debit, etc.
                const rawData = statsResponse.data;
                totalCredit = rawData.credit ??
                    rawData.all_time_credit ??
                    rawData.total_credit ??
                    rawData.deposits ?? 0;
                totalDebit = rawData.debit ??
                    rawData.all_time_debit ??
                    rawData.total_debit ??
                    rawData.withdrawals ?? 0;
            } catch (statsError) {
                console.error("Failed to get stats from raw API:", statsError);
                // Continue with zeros if stats fail
            }

            return {
                success: true,
                balance: totalBalance,
                totalCredit: totalCredit,
                totalDebit: totalDebit,
                currency: "XAF",
                applicationName: application.name,
                countries: application.countries,
            };
        } catch (error: unknown) {
            console.error("Balance check error:", error);
            const errorMessage = error instanceof Error ? error.message : "Unknown error";
            throw new HttpsError("internal", `Could not retrieve balance: ${errorMessage}`);
        }
    }
);

/**
 * Create a new user (admin only).
 * This function:
 * 1. Validates the caller is an admin
 * 2. Creates a Firebase Auth user with auto-generated password
 * 3. Creates the user document in Firestore
 * 4. Sends a welcome email with login credentials
 */
export const createUser = onCall(
    { secrets: [smtpHost, smtpPort, smtpSecure, smtpUser, smtpPass, smtpFrom] },
    async (request) => {
        // DEBUG: Log authentication context
        console.log("createUser called");
        console.log("request.auth:", request.auth ? "present" : "null");
        console.log("request.auth?.uid:", request.auth?.uid);
        console.log("request.auth?.token:", request.auth?.token ? "present" : "null");

        // Verify caller is authenticated
        if (!request.auth) {
            console.error("Authentication failed: request.auth is null");
            throw new HttpsError(
                "unauthenticated",
                "You must be logged in to create users."
            );
        }

        // Verify caller is admin
        const callerDoc = await db.collection("vanguard_users").doc(request.auth.uid).get();
        const callerData = callerDoc.data();

        if (callerData?.role !== "admin") {
            throw new HttpsError(
                "permission-denied",
                "Only admins can create new users."
            );
        }

        const data = request.data as {
            email: string;
            firstName: string;
            lastName: string;
            phone: string;
            role: string;
            department: string;
            position: string;
            salary?: number;
            bankAccount?: string;
            idCard?: string;
        };

        const { email, firstName, lastName, phone, role, department, position, salary, bankAccount, idCard } = data;

        // Validate required fields
        if (!email || !firstName || !lastName || !role) {
            throw new HttpsError(
                "invalid-argument",
                "Email, first name, last name, and role are required."
            );
        }

        // Generate a secure random password
        const generatedPassword = generateSecurePassword();

        try {
            // Create Firebase Auth user
            const userRecord = await admin.auth().createUser({
                email: email,
                password: generatedPassword,
                displayName: `${firstName} ${lastName}`,
                disabled: false,
            });

            // Create user document in Firestore
            const userData = {
                id: userRecord.uid,
                firstName,
                lastName,
                email,
                phone: phone || "",
                role,
                department: department || "",
                position: position || "",
                salary: salary || 0,
                bankAccount: bankAccount || "",
                idCard: idCard || "",
                joinDate: admin.firestore.FieldValue.serverTimestamp(),
                isActive: true,
                createdBy: request.auth.uid,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            await db.collection("vanguard_users").doc(userRecord.uid).set(userData);

            // Also add to employees collection if role is employee/secretary
            if (role === "employee" || role === "secretary") {
                await db.collection("vanguard_employees").doc(userRecord.uid).set({
                    ...userData,
                    salary: salary || 0,
                });
            }

            // Also add to volunteers collection if role is volunteer
            if (role === "volunteer") {
                await db.collection("vanguard_volunteers").doc(userRecord.uid).set({
                    ...userData,
                    stipend: salary || 0, // Use salary field for volunteer stipend
                });
            }

            // Send welcome email with credentials (don't fail if email fails)
            let emailSent = false;
            try {
                await sendWelcomeEmail(email, firstName, generatedPassword);
                emailSent = true;
            } catch (emailError) {
                console.error("Failed to send welcome email:", emailError);
                // Email failed but user was created - don't fail the whole operation
            }

            return {
                success: true,
                userId: userRecord.uid,
                message: emailSent
                    ? `User ${firstName} ${lastName} created successfully. Login credentials sent to ${email}.`
                    : `User ${firstName} ${lastName} created successfully. Email could not be sent - password: ${generatedPassword}`,
            };

        } catch (error: unknown) {
            console.error("Create user error:", error);

            if (error instanceof Error) {
                if (error.message.includes("email-already-exists")) {
                    throw new HttpsError(
                        "already-exists",
                        "A user with this email already exists."
                    );
                }
            }

            throw new HttpsError(
                "internal",
                "Failed to create user. Please try again."
            );
        }
    }
);

/**
 * Generate a secure random password.
 */
function generateSecurePassword(): string {
    const length = 12;
    const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%";
    let password = "";

    // Ensure at least one of each type
    password += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[Math.floor(Math.random() * 26)];
    password += "abcdefghijklmnopqrstuvwxyz"[Math.floor(Math.random() * 26)];
    password += "0123456789"[Math.floor(Math.random() * 10)];
    password += "!@#$%"[Math.floor(Math.random() * 5)];

    // Fill the rest
    for (let i = password.length; i < length; i++) {
        password += charset[Math.floor(Math.random() * charset.length)];
    }

    // Shuffle the password
    return password.split("").sort(() => Math.random() - 0.5).join("");
}

/**
 * Send welcome email with login credentials using Nodemailer.
 */
async function sendWelcomeEmail(email: string, firstName: string, password: string): Promise<void> {
    const host = smtpHost.value();
    const port = smtpPort.value();
    const secure = smtpSecure.value();
    const user = smtpUser.value();
    const pass = smtpPass.value();
    const from = smtpFrom.value() || user;

    if (!user || !pass) {
        console.warn("SMTP not configured. Storing email for later processing.");
        await db.collection("vanguard_pending_emails").add({
            to: email,
            subject: "Welcome to Vanguard — Your Login Credentials",
            firstName: firstName,
            password: password,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            status: "pending",
            error: "SMTP not configured",
        });
        return;
    }

    const transporter = nodemailer.createTransport({
        host: host || "smtp.gmail.com",
        port: parseInt(port || "587"),
        secure: secure === "true",
        auth: { user, pass },
    });

    const emailHtml = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Welcome to Vanguard</title>
</head>
<body style="margin:0;padding:0;background-color:#F8F9FF;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" role="presentation">
    <tr>
      <td align="center" style="padding:40px 20px;">
        <table width="600" cellpadding="0" cellspacing="0" role="presentation"
               style="max-width:600px;width:100%;background:#ffffff;border-radius:20px;overflow:hidden;box-shadow:0 4px 24px rgba(8,12,24,0.10);">

          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#080C18 0%,#0E2355 55%,#1A1F5E 100%);padding:40px 48px 36px;">
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <table cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="background:linear-gradient(135deg,#4F46E5,#7C3AED);border-radius:14px;padding:12px 14px;display:inline-block;">
                          <span style="font-size:22px;">🛡️</span>
                        </td>
                        <td style="padding-left:14px;">
                          <div style="font-size:22px;font-weight:800;color:#ffffff;letter-spacing:4px;">VANGUARD</div>
                          <div style="font-size:10px;color:rgba(255,255,255,0.50);letter-spacing:3px;margin-top:2px;">WORKFORCE MANAGEMENT</div>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
                <tr>
                  <td style="padding-top:28px;">
                    <div style="width:40px;height:2px;background:linear-gradient(90deg,#EAB308,#D97706);border-radius:1px;"></div>
                    <div style="font-size:26px;font-weight:700;color:#ffffff;margin-top:16px;letter-spacing:-0.5px;">
                      Welcome aboard, ${firstName}!
                    </div>
                    <div style="font-size:15px;color:rgba(255,255,255,0.65);margin-top:8px;">
                      Your workspace is ready. Here are your login credentials.
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:40px 48px;">
              <p style="font-size:15px;color:#374151;margin:0 0 24px;">
                Your administrator has created an account for you on <strong>Vanguard</strong>.
                Use the credentials below to sign in and get started.
              </p>

              <!-- Credentials card -->
              <table width="100%" cellpadding="0" cellspacing="0" style="background:#F1F3FF;border:1px solid #E0E3FF;border-radius:14px;margin-bottom:28px;">
                <tr>
                  <td style="padding:24px 28px;">
                    <div style="font-size:11px;font-weight:600;color:#4F46E5;letter-spacing:2px;margin-bottom:16px;text-transform:uppercase;">
                      Your Credentials
                    </div>
                    <table width="100%" cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="padding:10px 0;border-bottom:1px solid #E0E3FF;">
                          <span style="font-size:12px;color:#6B7280;font-weight:500;">EMAIL ADDRESS</span><br>
                          <span style="font-size:15px;color:#0A0E1A;font-weight:600;font-family:monospace;">${email}</span>
                        </td>
                      </tr>
                      <tr>
                        <td style="padding:10px 0;">
                          <span style="font-size:12px;color:#6B7280;font-weight:500;">TEMPORARY PASSWORD</span><br>
                          <span style="font-size:15px;color:#0A0E1A;font-weight:600;font-family:monospace;">${password}</span>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>

              <!-- Security notice -->
              <table width="100%" cellpadding="0" cellspacing="0" style="background:#FFFBEB;border:1px solid #FDE68A;border-radius:12px;margin-bottom:32px;">
                <tr>
                  <td style="padding:16px 20px;">
                    <span style="font-size:14px;color:#92400E;">
                      ⚠️ <strong>Security:</strong> Change your password immediately after your first login.
                    </span>
                  </td>
                </tr>
              </table>

              <!-- CTA button -->
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center">
                    <a href="https://vanguard.gentleways.com/login"
                       style="display:inline-block;padding:16px 48px;background:linear-gradient(135deg,#4F46E5,#7C3AED);color:#ffffff;text-decoration:none;font-size:15px;font-weight:700;border-radius:12px;letter-spacing:0.3px;box-shadow:0 6px 16px rgba(79,70,229,0.35);">
                      Sign In to Vanguard →
                    </a>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background:#F8F9FF;padding:24px 48px;border-top:1px solid #E8EAFF;">
              <p style="font-size:12px;color:#9CA3AF;margin:0;text-align:center;line-height:1.8;">
                This email was sent by <strong style="color:#4F46E5;">Vanguard Workforce Management</strong> — a product by Gentleways.<br>
                If you did not expect this email, please contact your administrator.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;

    try {
        await transporter.sendMail({
            from: `"Vanguard by Gentleways" <${from}>`,
            to: email,
            subject: "Welcome to Vanguard — Your Login Credentials",
            html: emailHtml,
        });

        console.log(`Welcome email sent to ${email}`);

        await db.collection("vanguard_sent_emails").add({
            to: email,
            subject: "Welcome to Vanguard — Your Login Credentials",
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            status: "sent",
        });

    } catch (error) {
        console.error("Failed to send email:", error);

        await db.collection("vanguard_pending_emails").add({
            to: email,
            subject: "Welcome to Vanguard — Your Login Credentials",
            firstName: firstName,
            password: password,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            status: "failed",
            error: error instanceof Error ? error.message : "Unknown error",
        });

        throw error;
    }
}

/**
 * Disburse salary to an employee's mobile money account.
 * This function:
 * 1. Validates the caller is an admin
 * 2. Fetches salary request and employee details
 * 3. Checks company wallet has sufficient balance
 * 4. Calls MeSomb deposit API to send money
 * 5. Updates salary request status to approved
 * 6. Deducts from company wallet
 * 7. Records the transaction
 */
export const disburseSalary = onCall(
    { secrets: [mesombAppKey, mesombAccessKey] },
    async (request) => {
        // Ensure user is authenticated
        if (!request.auth) {
            throw new HttpsError(
                "unauthenticated",
                "You must be logged in to disburse salaries."
            );
        }

        // Verify caller is admin
        const callerDoc = await db.collection("vanguard_users").doc(request.auth.uid).get();
        const callerData = callerDoc.data();

        if (callerData?.role !== "admin") {
            throw new HttpsError(
                "permission-denied",
                "Only admins can disburse salaries."
            );
        }

        const data = request.data as {
            requestId: string;
            service?: string; // MTN or ORANGE, defaults to detecting from phone
            notes?: string;
        };

        const { requestId, service, notes } = data;

        if (!requestId) {
            throw new HttpsError(
                "invalid-argument",
                "Request ID is required."
            );
        }

        // Fetch salary request
        const requestDoc = await db.collection("vanguard_salary_requests").doc(requestId).get();
        if (!requestDoc.exists) {
            throw new HttpsError(
                "not-found",
                "Salary request not found."
            );
        }

        const requestData = requestDoc.data()!;

        // Check if already processed
        if (requestData.status !== "pending") {
            throw new HttpsError(
                "failed-precondition",
                `This request has already been ${requestData.status}.`
            );
        }

        const amount = requestData.amount as number;
        const employeeId = requestData.employeeId as string;

        // Fetch employee details to get phone number
        const employeeDoc = await db.collection("vanguard_users").doc(employeeId).get();
        if (!employeeDoc.exists) {
            throw new HttpsError(
                "not-found",
                "Employee not found."
            );
        }

        const employeeData = employeeDoc.data()!;
        const phoneNumber = employeeData.phone as string;

        if (!phoneNumber || phoneNumber.length < 9) {
            throw new HttpsError(
                "failed-precondition",
                "Employee does not have a valid phone number."
            );
        }

        // Check company wallet balance
        const walletDoc = await db.collection("vanguard_company_wallet").doc("main").get();
        const walletBalance = walletDoc.exists ? (walletDoc.data()?.balance || 0) : 0;

        if (walletBalance < amount) {
            throw new HttpsError(
                "failed-precondition",
                `Insufficient wallet balance. Available: ${walletBalance} XAF, Required: ${amount} XAF`
            );
        }

        // Detect mobile money service from phone number if not provided
        let mobileService = service?.toUpperCase();
        if (!mobileService) {
            // Cameroon phone prefixes
            const phoneDigits = phoneNumber.replace(/\D/g, "");
            const prefix = phoneDigits.substring(0, 2);
            const prefix3 = phoneDigits.substring(0, 3);

            const mtnPrefixes = ["650", "651", "652", "653", "654", "680", "681", "682", "683", "684", "685", "686", "687", "688", "689"];
            const orangePrefixes = ["655", "656", "657", "658", "659", "690", "691", "692", "693", "694", "695", "696", "697", "698", "699"];

            if (prefix === "67" || mtnPrefixes.includes(prefix3)) {
                mobileService = "MTN";
            } else if (prefix === "69" || orangePrefixes.includes(prefix3)) {
                mobileService = "ORANGE";
            } else {
                throw new HttpsError(
                    "invalid-argument",
                    "Could not detect mobile money service. Please specify MTN or ORANGE."
                );
            }
        }

        const appKey = mesombAppKey.value();
        const accessKey = mesombAccessKey.value();

        if (!appKey || !accessKey) {
            throw new HttpsError(
                "failed-precondition",
                "Payment service is not configured. Please contact support."
            );
        }

        const reference = `salary_${Date.now()}_${requestId.substring(0, 8)}`;

        try {
            // Call MeSomb API to deposit (send money to employee)
            const response = await axios.post(
                `${MESOMB_BASE_URL}/payment/deposit/`,
                {
                    amount: Math.round(amount),
                    receiver: phoneNumber,
                    service: mobileService,
                    message: `Salary payment: ${requestData.type || "salary"}`.trim(),
                    reference: reference,
                },
                {
                    headers: {
                        "Content-Type": "application/json",
                        "X-MeSomb-Application": appKey,
                        "Authorization": `Token ${accessKey}`,
                    },
                }
            );

            const mesombData = response.data;

            // Update salary request to approved
            await db.collection("vanguard_salary_requests").doc(requestId).update({
                status: "approved",
                approvedBy: request.auth.uid,
                approvalDate: new Date().toISOString(),
                notes: notes || null,
                paymentReference: reference,
                paymentMethod: mobileService,
                paidAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            // Deduct from company wallet
            await db.collection("vanguard_company_wallet").doc("main").update({
                balance: admin.firestore.FieldValue.increment(-amount),
                lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            });

            // Record transaction
            const transaction = {
                id: reference,
                type: "withdrawal",
                category: "salary",
                amount: amount,
                description: `Salary to ${employeeData.firstName} ${employeeData.lastName}`,
                submittedBy: request.auth.uid,
                submittedByName: `${callerData?.firstName || ""} ${callerData?.lastName || "Admin"}`,
                recipientId: employeeId,
                recipientName: `${employeeData.firstName} ${employeeData.lastName}`,
                date: admin.firestore.FieldValue.serverTimestamp(),
                status: "completed",
                paymentMethod: mobileService,
                phoneNumber: phoneNumber.substring(0, 6) + "****",
                salaryRequestId: requestId,
                mesombTransactionId: mesombData.pk || null,
            };

            await db.collection("vanguard_wallet_transactions").doc(reference).set(transaction);

            // Update wallet summary for dashboard totals (expense/withdrawal)
            const summaryRef = db.collection("vanguard_wallet_summary").doc("current");
            await summaryRef.set(
                {
                    totalBalance: admin.firestore.FieldValue.increment(-amount),
                    totalExpenses: admin.firestore.FieldValue.increment(amount),
                    // Monthly tracking
                    monthlyExpenses: admin.firestore.FieldValue.increment(amount),
                    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                },
                { merge: true }
            );

            return {
                success: true,
                transactionId: reference,
                message: `Successfully sent ${amount} XAF to ${employeeData.firstName} ${employeeData.lastName}`,
            };

        } catch (error: unknown) {
            console.error("MeSomb Deposit Error:", error);

            // Mark request as having payment error
            await db.collection("vanguard_salary_requests").doc(requestId).update({
                paymentError: error instanceof Error ? error.message : "Payment failed",
                lastPaymentAttempt: admin.firestore.FieldValue.serverTimestamp(),
            });

            if (axios.isAxiosError(error)) {
                const errorMessage = error.response?.data?.message ||
                    error.response?.data?.detail ||
                    "Payment failed. Please try again.";
                throw new HttpsError("aborted", errorMessage);
            }

            throw new HttpsError(
                "internal",
                "An unexpected error occurred during payment. Please try again later."
            );
        }
    }
);

/**
 * Recalculate wallet summary from all transactions (admin only)
 * This function scans all wallet_transactions and recalculates the summary totals.
 * Useful for fixing data when transactions were created without updating the summary.
 */
export const recalculateWalletSummary = onCall(
    async (request) => {
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "Must be logged in.");
        }

        // Get user's role from Firestore to verify admin
        const userDoc = await db.collection("vanguard_users").doc(request.auth.uid).get();
        const userData = userDoc.data();

        if (userData?.role !== "admin") {
            throw new HttpsError("permission-denied", "Admin access required.");
        }

        try {
            // Get all transactions
            const transactionsSnapshot = await db.collection("vanguard_wallet_transactions").get();

            let totalRevenue = 0;
            let totalExpenses = 0;
            let monthlyRevenue = 0;
            let monthlyExpenses = 0;
            const now = new Date();
            const currentMonth = now.getMonth();
            const currentYear = now.getFullYear();

            transactionsSnapshot.forEach((doc) => {
                const txn = doc.data();
                const amount = txn.amount as number || 0;
                const type = txn.type as string;

                // Parse transaction date
                let txnDate: Date;
                if (txn.date && txn.date.toDate) {
                    txnDate = txn.date.toDate();
                } else if (txn.date) {
                    txnDate = new Date(txn.date);
                } else {
                    txnDate = new Date();
                }

                const isThisMonth = txnDate.getMonth() === currentMonth &&
                    txnDate.getFullYear() === currentYear;

                if (type === "deposit") {
                    totalRevenue += amount;
                    if (isThisMonth) monthlyRevenue += amount;
                } else if (type === "withdrawal" || type === "expense") {
                    totalExpenses += amount;
                    if (isThisMonth) monthlyExpenses += amount;
                }
            });

            const totalBalance = totalRevenue - totalExpenses;

            // Update the summary document
            const summaryRef = db.collection("vanguard_wallet_summary").doc("current");
            await summaryRef.set({
                totalBalance: totalBalance,
                totalRevenue: totalRevenue,
                totalExpenses: totalExpenses,
                monthlyRevenue: monthlyRevenue,
                monthlyExpenses: monthlyExpenses,
                lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                recalculatedAt: admin.firestore.FieldValue.serverTimestamp(),
                transactionCount: transactionsSnapshot.size,
            });

            console.log(`Recalculated wallet summary: Revenue=${totalRevenue}, Expenses=${totalExpenses}, Balance=${totalBalance}`);

            return {
                success: true,
                totalRevenue: totalRevenue,
                totalExpenses: totalExpenses,
                totalBalance: totalBalance,
                monthlyRevenue: monthlyRevenue,
                monthlyExpenses: monthlyExpenses,
                transactionCount: transactionsSnapshot.size,
                message: `Successfully recalculated from ${transactionsSnapshot.size} transactions`,
            };
        } catch (error: unknown) {
            console.error("Recalculate error:", error);
            const errorMessage = error instanceof Error ? error.message : "Unknown error";
            throw new HttpsError("internal", `Failed to recalculate: ${errorMessage}`);
        }
    }
);

/**
 * Send push notification when a new notification document is created.
 * This function:
 * 1. Reads the notification document
 * 2. Determines the target audience
 * 3. Sends FCM push to topics or specific device tokens
 */
export const sendPushNotification = onDocumentCreated(
    { document: "vanguard_notifications/{notificationId}" },
    async (event) => {
        const snapshot = event.data;
        if (!snapshot) {
            console.log("No data associated with the event");
            return;
        }

        const notification = snapshot.data();
        const title = notification.title as string;
        const message = notification.message as string;
        const priority = notification.priority as string || "normal";
        const targetAudience = notification.targetAudience as string || "all";
        const recipientIds = notification.recipientIds as string[] || [];

        // Build the FCM message payload
        const fcmData: { [key: string]: string } = {
            notificationId: event.params.notificationId,
            type: notification.type || "info",
            priority: priority,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
        };

        // Set FCM priority based on notification priority
        const isHighPriority = priority === "high" || priority === "urgent";

        try {
            if (targetAudience === "custom" && recipientIds.length > 0) {
                // Send to specific users by their FCM tokens
                const tokens: string[] = [];

                // Fetch FCM tokens for each recipient
                for (const userId of recipientIds) {
                    const userDoc = await db.collection("vanguard_users").doc(userId).get();
                    const userData = userDoc.data();
                    if (userData?.fcmToken) {
                        tokens.push(userData.fcmToken as string);
                    }
                }

                if (tokens.length > 0) {
                    const multicastMessage: admin.messaging.MulticastMessage = {
                        notification: {
                            title: title,
                            body: message,
                        },
                        data: fcmData,
                        tokens: tokens,
                        android: {
                            priority: isHighPriority ? "high" : "normal",
                            notification: {
                                priority: isHighPriority ? "max" : "default",
                                channelId: isHighPriority ? "high_importance_channel" : "default_channel",
                            },
                        },
                        apns: {
                            payload: {
                                aps: {
                                    sound: "default",
                                    badge: 1,
                                    ...(isHighPriority && { "interruption-level": "time-sensitive" }),
                                },
                            },
                        },
                    };

                    const response = await admin.messaging().sendEachForMulticast(multicastMessage);
                    console.log(`Sent to ${response.successCount}/${tokens.length} devices`);
                } else {
                    console.log("No FCM tokens found for recipients");
                }
            } else {
                // Send to topic based on target audience
                let topic: string;
                switch (targetAudience) {
                    case "employees":
                        topic = "employees";
                        break;
                    case "volunteers":
                        topic = "volunteers";
                        break;
                    case "admins":
                        topic = "admins";
                        break;
                    case "secretaries":
                        topic = "secretarys";
                        break;
                    default:
                        topic = "all_users";
                        break;
                }

                const topicMessage: admin.messaging.Message = {
                    notification: {
                        title: title,
                        body: message,
                    },
                    data: fcmData,
                    topic: topic,
                    android: {
                        priority: isHighPriority ? "high" : "normal",
                        notification: {
                            priority: isHighPriority ? "max" : "default",
                            channelId: isHighPriority ? "high_importance_channel" : "default_channel",
                        },
                    },
                    apns: {
                        payload: {
                            aps: {
                                sound: "default",
                                badge: 1,
                            },
                        },
                    },
                };

                await admin.messaging().send(topicMessage);
                console.log(`Push notification sent to topic: ${topic}`);
            }

            // Update the notification document with push sent status
            await snapshot.ref.update({
                pushSent: true,
                pushSentAt: admin.firestore.FieldValue.serverTimestamp(),
            });

        } catch (error: unknown) {
            console.error("Push notification error:", error);
            await snapshot.ref.update({
                pushSent: false,
                pushError: error instanceof Error ? error.message : "Unknown error",
            });
        }
    }
);
