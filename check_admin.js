// Quick script to check if admin user exists
const admin = require('firebase-admin');

// Initialize with your service account
admin.initializeApp({
  projectId: 'portfolio-5ee70',
  databaseURL: 'https://portfolio-5ee70.firebaseio.com'
});

const db = admin.firestore();
db.settings({ databaseId: 'vanguard-db' });

async function checkAdmin() {
  try {
    // List all users in Firebase Auth
    console.log('\n=== Firebase Auth Users ===');
    const listUsersResult = await admin.auth().listUsers(10);
    listUsersResult.users.forEach((userRecord) => {
      console.log(`Email: ${userRecord.email}, UID: ${userRecord.uid}`);
    });

    // Check vanguard_users collection
    console.log('\n=== Firestore vanguard_users Collection ===');
    const usersSnapshot = await db.collection('vanguard_users').get();
    if (usersSnapshot.empty) {
      console.log('❌ No documents found in vanguard_users collection!');
    } else {
      usersSnapshot.forEach(doc => {
        const data = doc.data();
        console.log(`Doc ID: ${doc.id}`);
        console.log(`Email: ${data.email}, Role: ${data.role}, Active: ${data.isActive}`);
      });
    }
  } catch (error) {
    console.error('Error:', error.message);
  }
  process.exit(0);
}

checkAdmin();
