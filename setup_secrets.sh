#!/bin/bash

echo "🔐 Setting up Firebase Cloud Functions Secrets"
echo "=============================================="
echo ""

# SMTP Configuration for sending emails
echo "📧 SMTP Configuration (for sending welcome emails)"
echo "---------------------------------------------------"
read -p "SMTP Host (e.g., smtp.gmail.com): " smtp_host
read -p "SMTP Port (e.g., 587): " smtp_port
read -p "SMTP Secure (true/false): " smtp_secure
read -p "SMTP User (email address): " smtp_user
read -sp "SMTP Password (app password): " smtp_pass
echo ""
read -p "SMTP From (sender email): " smtp_from
echo ""

# MeSomb Configuration for mobile money payments
echo ""
echo "💰 MeSomb Configuration (for mobile money payments)"
echo "---------------------------------------------------"
read -p "MeSomb Application Key: " mesomb_app_key
read -p "MeSomb Access Key: " mesomb_access_key
read -sp "MeSomb Secret Key: " mesomb_secret_key
echo ""
echo ""

# Set secrets using Firebase CLI
echo "🚀 Setting secrets in Firebase..."
echo ""

firebase functions:secrets:set SMTP_HOST --data-file <(echo -n "$smtp_host")
firebase functions:secrets:set SMTP_PORT --data-file <(echo -n "$smtp_port")
firebase functions:secrets:set SMTP_SECURE --data-file <(echo -n "$smtp_secure")
firebase functions:secrets:set SMTP_USER --data-file <(echo -n "$smtp_user")
firebase functions:secrets:set SMTP_PASS --data-file <(echo -n "$smtp_pass")
firebase functions:secrets:set SMTP_FROM --data-file <(echo -n "$smtp_from")

firebase functions:secrets:set MESOMB_APP_KEY --data-file <(echo -n "$mesomb_app_key")
firebase functions:secrets:set MESOMB_ACCESS_KEY --data-file <(echo -n "$mesomb_access_key")
firebase functions:secrets:set MESOMB_SECRET_KEY --data-file <(echo -n "$mesomb_secret_key")

echo ""
echo "✅ Secrets configured successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Deploy functions: firebase deploy --only functions"
echo "2. Test by creating a user from admin dashboard"
echo ""
