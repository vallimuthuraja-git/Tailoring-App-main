const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('../config/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function deleteAllUsersAndData() {
  console.log('🗑️  Deleting all existing users and data...\n');

  try {
    // Delete all collections
    const collections = [
      'users', 'customers', 'employees', 'orders', 'products',
      'services', 'measurements', 'reviews', 'notifications',
      'chatHistory', 'analytics', 'inventory', 'paymentHistory'
    ];

    for (const collection of collections) {
      const snapshot = await admin.firestore().collection(collection).get();
      if (!snapshot.empty) {
        console.log(`   Deleting ${snapshot.size} documents from '${collection}'...`);
        const batch = admin.firestore().batch();
        snapshot.docs.forEach(doc => {
          batch.delete(doc.ref);
        });
        await batch.commit();
        console.log(`   ✅ Deleted ${snapshot.size} documents from '${collection}'`);
      } else {
        console.log(`   ⏭️  Collection '${collection}' is already empty`);
      }
    }

    // Delete all auth users
    console.log('   Deleting all Firebase Auth users...');
    let usersDeleted = 0;
    let hasMoreUsers = true;
    let nextPageToken;

    while (hasMoreUsers) {
      const listUsersResult = await admin.auth().listUsers(100, nextPageToken);
      if (listUsersResult.users.length > 0) {
        const deletePromises = listUsersResult.users.map(user =>
          admin.auth().deleteUser(user.uid)
        );
        await Promise.all(deletePromises);
        usersDeleted += listUsersResult.users.length;
        console.log(`   ✅ Deleted ${usersDeleted} auth users so far...`);
      }

      nextPageToken = listUsersResult.pageToken;
      hasMoreUsers = listUsersResult.users.length === 100 && nextPageToken;
    }

    console.log(`✅ Successfully deleted all users and data (${usersDeleted} auth users)`);
  } catch (error) {
    console.error('❌ Error deleting users and data:', error.message);
  }
  console.log('');
}

async function createSpecificUsers() {
  console.log('🎯 Creating fresh user accounts for Tailoring App with Madurai, Tamil Nadu details...\n');

  // Define users to create with Tamil Nadu Madurai details
  const usersToCreate = [
    {
      email: 'owner@tailoring.com',
      password: 'Owner123!',
      displayName: 'Arun Kumar Rajendran',
      phone: '+914524567890',
      role: 'shopOwner', // Role index 2 (UserRole.shopOwner)
      location: 'Madurai, Tamil Nadu',
      address: '123 Temple Street, Meenakshi Nagar, Madurai - 625002',
      dateOfBirth: '1985-03-15',
      gender: 'male',
      specialty: 'Master Tailor',
      experience: '15 years'
    },
    {
      email: 'customer@tailoring.com',
      password: 'Customer123!',
      displayName: 'Priya Senthilkumar',
      phone: '+914524567891',
      role: 'customer', // Role index 0 (UserRole.customer)
      location: 'Madurai, Tamil Nadu',
      address: '456 Gandhi Nagar, Anna Colony, Madurai - 625020',
      dateOfBirth: '1992-07-22',
      gender: 'female',
      occupation: 'Software Engineer',
      preferences: ['Premium fabrics', 'Custom designs', 'Fast delivery']
    },
    {
      email: 'tailor1@tailoring.com',
      password: 'Tailor123!',
      displayName: 'Suresh Rajalingam',
      phone: '+914524567892',
      role: 'employee', // Role index 1 (UserRole.employee)
      specialty: 'Stitching Master',
      location: 'Madurai, Tamil Nadu',
      address: '789 Railway Colony, Goripalayam, Madurai - 625002',
      dateOfBirth: '1988-11-08',
      gender: 'male',
      experience: '12 years',
      skills: ['Suits', 'Shirts', 'Trouser alterations']
    },
    {
      email: 'tailor2@tailoring.com',
      password: 'Tailor456!',
      displayName: 'Lakshmi Balasubramanian',
      phone: '+914524567893',
      role: 'employee', // Role index 1 (UserRole.employee)
      specialty: 'Designer Tailor',
      location: 'Madurai, Tamil Nadu',
      address: '321 KK Nagar, Vilangudi, Madurai - 625018',
      dateOfBirth: '1990-05-30',
      gender: 'female',
      experience: '10 years',
      skills: ['Saree blouses', 'Churidars', 'Wedding wear', 'Embroidery']
    }
  ];

  try {
    console.log('📝 Creating authentication users...\n');

    for (const userData of usersToCreate) {
      try {
        // Check if user already exists
        try {
          const existingUser = await admin.auth().getUserByEmail(userData.email);
          console.log(`⚠️  User ${userData.email} already exists (UID: ${existingUser.uid}) - skipping`);
          continue;
        } catch (e) {
          // User doesn't exist, continue with creation
        }

        // Create Firebase Auth user
        const userRecord = await admin.auth().createUser({
          email: userData.email,
          password: userData.password,
          displayName: userData.displayName,
          emailVerified: true, // Mark as verified for easy testing
        });

        console.log(`✅ Created auth user: ${userData.displayName} (${userData.email})`);

        // Create user profile in Firestore
        const userProfile = {
          id: userRecord.uid,
          email: userData.email,
          displayName: userData.displayName,
          phoneNumber: userData.phone,
          role: userData.role === 'shopOwner' ? 2 : userData.role === 'employee' ? 3 : 0, // Map to role index
          isEmailVerified: true,
          isProfileComplete: false, // Can be updated manually
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        };

        await admin.firestore().collection('users').doc(userRecord.uid).set(userProfile);

        // Create role-specific profile
        if (userData.role === 'customer') {
          // Create customer profile
          const customerProfile = {
            id: userRecord.uid,
            userId: userRecord.uid,
            name: userData.displayName,
            email: userData.email,
            phone: userData.phone,
            isActive: true,
            joinDate: new Date().toISOString(),
            loyaltyTier: 'Bronze', // Will be updated manually
            totalSpent: 0.0,
            measurements: {},
            preferences: ['Custom tailoring', 'Premium fabrics'],
          };

          await admin.firestore().collection('customers').doc(userRecord.uid).set(customerProfile);

        } else if (userData.role === 'employee') {
          // Create employee profile
          const employeeType = userData.email.includes('tailor') ? 'tailor' : 'cutter';
          const employeeProfile = {
            id: `emp_${userRecord.uid}`,
            userId: userRecord.uid,
            displayName: userData.displayName,
            email: userData.email,
            role: 3, // Employee role index
            specialty: userData.email.includes('tailor') ? 'tailor' : 'cutter',
            skills: employeeType === 'tailor' ? [0, 1, 2] : [0, 3, 4], // Mock skills mapping
            isActive: true,
            joinedDate: new Date().toISOString(),
            phoneNumber: userData.phone,
          };

          await admin.firestore().collection('employees').doc(userRecord.uid).set(employeeProfile);

        } else if (userData.role === 'shopOwner') {
          // Create both owner and employee profiles
          const ownerEmployeeProfile = {
            id: `owner_${userRecord.uid}`,
            userId: userRecord.uid,
            displayName: userData.displayName,
            email: userData.email,
            role: 2, // Shop owner role index
            specialty: 'owner',
            isActive: true,
            joinedDate: new Date().toISOString(),
            phoneNumber: userData.phone,
          };

          await admin.firestore().collection('employees').doc(userRecord.uid).set(ownerEmployeeProfile);
        }

        console.log(`📄 Created profile for: ${userData.displayName} (${userData.role})`);
        console.log('');

      } catch (userError) {
        console.log(`❌ Failed to create ${userData.email}: ${userError.message}`);
      }
    }

    console.log('🎉 Account creation complete!\n');

    // Verify created accounts
    console.log('🔍 Verifying created accounts...\n');
    const allUsers = await admin.auth().listUsers(10);
    const ourUsers = allUsers.users.filter(user =>
      ['owner@tailoring.com', 'customer@tailoring.com', 'tailor1@tailoring.com', 'tailor2@tailoring.com'].includes(user.email)
    );

    console.log('📊 Successfully created accounts:');
    ourUsers.forEach(user => {
      const userInfo = usersToCreate.find(u => u.email === user.email);
      console.log(`   ✅ ${userInfo?.displayName} (${user.email}) - ${userInfo?.role}`);
      console.log(`      Password: ${userInfo?.password}`);
      console.log(`      UID: ${user.uid}`);
      console.log('');
    });

  } catch (error) {
    console.error('❌ Error during account creation:', error.message);
  } finally {
    admin.app().delete();
  }
}

async function main() {
  await deleteAllUsersAndData();
  await createSpecificUsers();

  console.log('\n🎉 SETUP COMPLETE!');
  console.log('===============================');
  console.log('📧 ACCESS DETAILS:');
  console.log('===============================');
  console.log('');
  console.log('👑 SHOP OWNER:');
  console.log('   Email: owner@tailoring.com');
  console.log('   Password: Owner123!');
  console.log('   Role: Shop Owner (Full Admin Access)');
  console.log('   Features: Product management, employee oversight, business analytics');
  console.log('');

  console.log('🛒 CUSTOMER:');
  console.log('   Email: customer@tailoring.com');
  console.log('   Password: Customer123!');
  console.log('   Role: Customer');
  console.log('   Features: Order placement, basic shopping');
  console.log('');

  console.log('👨‍💼 EMPLOYEE 1 (TAILOR):');
  console.log('   Email: tailor1@tailoring.com');
  console.log('   Password: Tailor123!');
  console.log('   Role: Employee (Stitching Master)');
  console.log('   Features: Order processing, tailoring work');
  console.log('');

  console.log('👩‍💼 EMPLOYEE 2 (DESIGNER):');
  console.log('   Email: tailor2@tailoring.com');
  console.log('   Password: Tailor456!');
  console.log('   Role: Employee (Designer)');
  console.log('   Features: Order processing, design work');
  console.log('');

  console.log('📍 ALL DETAILS BASED ON:');
  console.log('   Location: Madurai, Tamil Nadu');
  console.log('   Local phone numbers: +91 452-XXXXXXX');
  console.log('   Local addresses in Madurai areas');
}

main();
