const admin = require('firebase-admin');

// TODO: Replace with your service account credentials
const serviceAccount = require('./firebase-service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://tailoringapp-c768d-default-rtdb.firebaseio.com',
  projectId: 'tailoringapp-c768d'
});

const db = admin.firestore();

async function checkEmployees() {
  try {
    console.log('🔍 Checking employees collection...');

    // Get all employees
    const employeesRef = db.collection('employees');
    const snapshot = await employeesRef.get();

    if (snapshot.empty) {
      console.log('❌ No employees found in database');
    } else {
      console.log(`✅ Found ${snapshot.size} employees:`);

      snapshot.forEach((doc) => {
        const data = doc.data();
        console.log(`- ${data.displayName} (${data.email}) - Role: ${data.role}, Active: ${data.isActive}`);
      });
    }

    // Also check users collection
    console.log('\n🔍 Checking users collection...');
    const usersRef = db.collection('users');
    const userSnapshot = await usersRef.get();

    if (userSnapshot.empty) {
      console.log('❌ No users found in database');
    } else {
      console.log(`✅ Found ${userSnapshot.size} users:`);

      userSnapshot.forEach((doc) => {
        const data = doc.data();
        if (data.role) {
          console.log(`- ${data.displayName} (${data.email}) - Role: ${data.role}`);
        }
      });
    }

  } catch (error) {
    console.error('❌ Error querying database:', error);
  }

  // Close the connection
  process.exit(0);
}

checkEmployees();