const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function listAllAuthUsers() {
  console.log('🔍 Listing all Firebase Authentication users...\n');

  try {
    let totalUsers = 0;
    let pageToken;

    do {
      const result = await admin.auth().listUsers(1000, pageToken);

      result.users.forEach((user) => {
        totalUsers++;
        console.log(`👤 User ${totalUsers}:`);
        console.log(`   🆔 UID: ${user.uid}`);
        console.log(`   📧 Email: ${user.email || 'No email'}`);
        console.log(`   📱 Phone: ${user.phoneNumber || 'No phone'}`);
        console.log(`   📝 Display Name: ${user.displayName || 'No display name'}`);
        console.log(`   ✅ Email Verified: ${user.emailVerified ? 'Yes' : 'No'}`);
        console.log(`   ⏰ Created: ${user.metadata.creationTime}`);
        console.log(`   🔄 Last Signin: ${user.metadata.lastSignInTime || 'Never'}`);
        console.log(`   🔒 Disabled: ${user.disabled ? 'Yes' : 'No'}`);
        console.log('');
      });

      pageToken = result.pageToken;
    } while (pageToken);

    console.log(`📊 Total Authentication Users: ${totalUsers}`);

  } catch (error) {
    console.error('❌ Error listing auth users:', error.message);

    if (error.message.includes('permission-denied')) {
      console.log('🔒 Check that the service account has proper permissions in Firebase Console');
    }
  } finally {
    admin.app().delete();
  }
}

listAllAuthUsers();
