const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function deleteAllAuthUsers() {
  console.log('🗑️ Deleting all Firebase Authentication users...\n');

  // SAFETY CHECK - Require explicit confirmation
  const confirmation = process.argv[2];
  if (confirmation !== '--confirm-delete') {
    console.log('❌ SAFETY CHECK: This operation will delete ALL Firebase Authentication users!');
    console.log('🔒 To proceed, run this script with: node delete_all_auth_users.js --confirm-delete');
    console.log('⚠️  This action cannot be undone!');
    return;
  }

  try {
    let totalUsers = 0;
    let totalDeleted = 0;
    let deletePromises = [];

    // First, collect all users
    let pageToken;
    do {
      const result = await admin.auth().listUsers(1000, pageToken);

      result.users.forEach((user) => {
        totalUsers++;
        console.log(`📋 Found user ${totalUsers}: ${user.email} (${user.uid})`);

        // Add to deletion queue
        deletePromises.push({
          uid: user.uid,
          email: user.email || 'No email',
          displayName: user.displayName || 'No name'
        });
      });

      pageToken = result.pageToken;
    } while (pageToken);

    if (totalUsers === 0) {
      console.log('✅ No users found to delete.');
      return;
    }

    console.log(`\n📊 Found ${totalUsers} users to delete.`);
    console.log('🗑️ Starting deletion process...\n');

    // Delete users in batches
    const batchSize = 10; // Firebase allows up to 10 concurrent operations
    for (let i = 0; i < deletePromises.length; i += batchSize) {
      const batch = deletePromises.slice(i, i + batchSize);

      try {
        await Promise.all(batch.map(async (user) => {
          await admin.auth().deleteUser(user.uid);
          totalDeleted++;
          console.log(`🗑️ Deleted user ${totalDeleted}/${totalUsers}: ${user.email} (${user.uid})`);
          return user.uid;
        }));
      } catch (batchError) {
        console.error(`❌ Error deleting batch of users:`, batchError.message);
      }
    }

    console.log(`\n✅ Deletion Complete!`);
    console.log(`📊 Total users deleted: ${totalDeleted}/${totalUsers}`);

    // Also delete any Firestore user documents
    console.log('\n🧹 Also deleting corresponding user documents from Firestore...');
    try {
      await Promise.all(deletePromises.map(async (user) => {
        try {
          await admin.firestore().collection('users').doc(user.uid).delete();
          console.log(`🗑️ Deleted user document: ${user.uid}`);
        } catch (firestoreError) {
          // Ignore if document doesn't exist
          console.log(`ℹ️  User document not found or already deleted: ${user.uid}`);
        }
      }));
      console.log('✅ Firestore cleanup complete!');
    } catch (e) {
      console.error('❌ Error cleaning up Firestore:', e.message);
    }

  } catch (error) {
    console.error('❌ Error during deletion process:', error.message);
  } finally {
    admin.app().delete();
  }
}

deleteAllAuthUsers();
