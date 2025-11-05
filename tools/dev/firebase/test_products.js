const admin = require('firebase-admin');
const serviceAccount = require('../../config/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function testProducts() {
  try {
    console.log('🔍 Checking products in database...');

    const snapshot = await db.collection('products').get();

    console.log(`📦 Found ${snapshot.size} products in database`);

    if (snapshot.size > 0) {
      console.log('\n📋 Product details:');
      snapshot.forEach((doc) => {
        const data = doc.data();
        console.log(`- ID: ${doc.id}`);
        console.log(`  Name: ${data.name}`);
        console.log(`  Category: ${data.category}`);
        console.log(`  Price: ₹${data.basePrice}`);
        console.log(`  Active: ${data.isActive}`);
        console.log('');
      });
    } else {
      console.log('❌ No products found in database');
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error checking products:', error);
    process.exit(1);
  }
}

testProducts();
