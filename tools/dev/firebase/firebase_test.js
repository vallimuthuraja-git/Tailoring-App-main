const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('../config/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${serviceAccount.project_id}-default-rtdb.firebaseio.com`
});

const firestore = admin.firestore();

async function testFirebaseConnectivity() {
  try {
    console.log('🔍 Testing Firebase connectivity...');

    // Check products collection
    const productsSnapshot = await firestore.collection('products').get();
    console.log(`📦 Products collection: ${productsSnapshot.size} documents`);

    if (productsSnapshot.size > 0) {
      console.log('📋 Sample product documents:');
      productsSnapshot.docs.slice(0, 3).forEach((doc, index) => {
        const data = doc.data();
        console.log(`  ${index + 1}. ID: ${doc.id}`);
        console.log(`     Name: ${data.name || 'No name'}`);
        console.log(`     Price: ${data.basePrice ? '₹' + data.basePrice : 'No price'}`);
        console.log(`     Category: ${data.category || 'No category'}`);
        console.log('');
      });
    }

    // Check users collection
    const usersSnapshot = await firestore.collection('users').get();
    console.log(`👥 Users collection: ${usersSnapshot.size} documents`);

    // Check customers collection
    const customersSnapshot = await firestore.collection('customers').get();
    console.log(`🛒 Customers collection: ${customersSnapshot.size} documents`);

    console.log('✅ Firebase connectivity test completed successfully!');

  } catch (error) {
    console.error('❌ Firebase connectivity test failed:', error.message);

    if (error.message.includes('permission-denied')) {
      console.log('🔒 Possible Firestore Security Rules issue');
    } else if (error.message.includes('not-found')) {
      console.log('📂 Collection does not exist');
    }
  } finally {
    admin.app().delete();
  }
}

testFirebaseConnectivity();
