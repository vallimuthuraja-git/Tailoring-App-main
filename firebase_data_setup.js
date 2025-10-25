const admin = require('firebase-admin');

// Initialize Firebase Admin
// You need to download the service account key from Firebase Console > Project Settings > Service Accounts
// Save it as serviceAccountKey.json in the project root
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${serviceAccount.project_id}-default-rtdb.firebaseio.com` // Adjust if using RTDB
});

const auth = admin.auth();
const firestore = admin.firestore();

// Demo user data for testing
const demoUsers = [
  {
    email: 'shop@demo.com',
    password: 'Pass123',
    displayName: 'Shop Owner',
    role: 3, // UserRole.shopOwner
    phone: '+91-9876543210',
  },
  {
    email: 'customer@demo.com',
    password: 'Pass123',
    displayName: 'Demo Customer',
    role: 0, // UserRole.customer
    phone: '+91-9876543211',
  },
  {
    email: 'employee0@demo.com',
    password: 'Pass123',
    displayName: 'Employee 0',
    role: 1, // UserRole.employee
    phone: '+91-9876543212',
  },
  {
    email: 'employee1@demo.com',
    password: 'Pass123',
    displayName: 'Employee 1',
    role: 1, // UserRole.employee
    phone: '+91-9876543213',
  },
];

async function createDemoAccounts() {
  console.log('🚀 Starting demo account creation...');

  for (const userData of demoUsers) {
    try {
      await createSingleAccount(userData);
    } catch (e) {
      console.log(`❌ Error creating user ${userData.displayName}: ${e}`);
    }
  }

  console.log('\n🎉 Demo account creation completed!');
  printDemoAccounts();
}

async function createSingleAccount(userData) {
  const email = userData.email;
  const password = userData.password;
  const displayName = userData.displayName;
  const role = userData.role;
  const phone = userData.phone;

  console.log(`Creating user: ${displayName} (${email})`);

  // Check if user already exists
  try {
    await auth.getUserByEmail(email);
    console.log(`⚠️  User ${email} already exists, skipping...`);
    return;
  } catch (e) {
    if (e.code !== 'auth/user-not-found') {
      throw e;
    }
  }

  // Create Firebase Auth user
  const userRecord = await auth.createUser({
    email: email,
    password: password,
    displayName: displayName,
    phoneNumber: phone,
    emailVerified: true,
  });

  const uid = userRecord.uid;

  // Create user profile in Firestore
  await firestore.collection('users').doc(uid).set({
    id: uid,
    email: email,
    displayName: displayName,
    role: role,
    isEmailVerified: true,
    phoneNumber: phone,
    lastLoginAt: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Create role-specific data
  if (role === 1) {
    // Employee
    await createEmployeeProfile(uid, userData);
  } else if (role === 0) {
    // Customer
    await createCustomerProfile(uid, userData);
  }

  console.log(`✅ Created user: ${displayName}`);
}

async function createEmployeeProfile(uid, userData) {
  await firestore.collection('employees').doc(`emp_${uid}`).set({
    id: `emp_${uid}`,
    userId: uid,
    displayName: userData.displayName,
    email: userData.email,
    phoneNumber: userData.phone,
    role: 1, // Employee
    skills: ['General Tailoring'],
    specializations: [],
    experienceYears: 2,
    certifications: [],
    availability: 0, // fullTime
    preferredWorkDays: [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday'
    ],
    preferredStartTime: {'hour': 9, 'minute': 0},
    preferredEndTime: {'hour': 17, 'minute': 0},
    canWorkRemotely: false,
    location: 'Workshop',
    totalOrdersCompleted: 0,
    ordersInProgress: 0,
    averageRating: 0.0,
    completionRate: 0.0,
    strengths: ['Reliable'],
    areasForImprovement: [],
    baseRatePerHour: 120.0,
    performanceBonusRate: 20.0,
    paymentTerms: 'Monthly',
    totalEarnings: 0.0,
    recentAssignments: [],
    consecutiveDaysWorked: 0,
    isActive: true,
    joinedDate: admin.firestore.FieldValue.serverTimestamp(),
    additionalInfo: {},
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function createCustomerProfile(uid, userData) {
  await firestore.collection('customers').doc(uid).set({
    id: uid,
    userId: uid,
    name: userData.displayName,
    email: userData.email,
    phone: userData.phone,
    address: {
      street: '123 Main Street',
      city: 'Mumbai',
      state: 'Maharashtra',
      country: 'India',
      pincode: '400001',
    },
    measurements: {
      chest: 40.0,
      waist: 32.0,
      shoulder: 17.0,
      sleeveLength: 25.0,
      inseam: 32.0,
      neck: 15.5,
    },
    preferences: {
      style: 'Modern',
      fabric: 'Cotton',
      colors: ['Black', 'Blue', 'White'],
    },
    loyaltyTier: 'Bronze',
    totalSpent: 0.0,
    orderCount: 0,
    joinDate: admin.firestore.FieldValue.serverTimestamp(),
    lastOrderDate: null,
    isActive: true,
    notes: 'Demo customer for testing',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function setupBasicEmployees() {
  console.log('🚀 Setting up basic demo employees...');

  // Basic employee data
  const employees = [
    {
      id: 'emp_demo_1',
      userId: 'demo_user_1',
      displayName: 'Rajesh Kumar',
      email: 'rajesh@tailor.com',
      phoneNumber: '+91-9876543211',
      skills: [0, 1, 2, 3], // Stitching, alterations, cutting, finishing
      specializations: ['Formal Wear', 'Alterations and Fittings'],
      experienceYears: 8,
      certifications: ['Master Tailor Certification'],
      availability: 0, // fullTime
      preferredWorkDays: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday'
      ],
      preferredStartTime: {'hour': 9, 'minute': 0},
      preferredEndTime: {'hour': 17, 'minute': 0},
      canWorkRemotely: false,
      location: 'Main Workshop',
      totalOrdersCompleted: 245,
      ordersInProgress: 2,
      averageRating: 4.7,
      completionRate: 0.96,
      strengths: ['Exceptional craftsmanship', 'Attention to detail'],
      areasForImprovement: ['Could improve time management'],
      baseRatePerHour: 100.0,
      performanceBonusRate: 15.0,
      paymentTerms: 'Monthly',
      totalEarnings: 78400.0,
      recentAssignments: [],
      consecutiveDaysWorked: 15,
      isActive: true,
      joinedDate: admin.firestore.Timestamp.fromDate(new Date('2023-03-15')),
      additionalInfo: {'demo_account': true},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      id: 'emp_demo_2',
      userId: 'demo_user_2',
      displayName: 'Priya Sharma',
      email: 'priya@designer.com',
      phoneNumber: '+91-9876543212',
      skills: [1, 2, 4], // alterations, cutting, patternMaking
      specializations: ['Wedding Wear', 'Traditional Indian Wear'],
      experienceYears: 12,
      certifications: ['Fashion Design Diploma'],
      availability: 1, // partTime
      preferredWorkDays: ['Wednesday', 'Friday', 'Saturday'],
      preferredStartTime: {'hour': 9, 'minute': 0},
      preferredEndTime: {'hour': 16, 'minute': 0},
      canWorkRemotely: true,
      location: 'Design Studio',
      totalOrdersCompleted: 189,
      ordersInProgress: 1,
      averageRating: 4.8,
      completionRate: 0.98,
      strengths: ['Creative design thinking', 'Client communication'],
      areasForImprovement: ['Should delegate more'],
      baseRatePerHour: 120.0,
      performanceBonusRate: 20.0,
      paymentTerms: 'Monthly',
      totalEarnings: 91200.0,
      recentAssignments: [],
      consecutiveDaysWorked: 8,
      isActive: true,
      joinedDate: admin.firestore.Timestamp.fromDate(new Date('2022-11-20')),
      additionalInfo: {'demo_account': true},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      id: 'emp_demo_3',
      userId: 'demo_user_3',
      displayName: 'Amit Patel',
      email: 'amit@cutter.com',
      phoneNumber: '+91-9876543213',
      skills: [2, 3, 4], // cutting, finishing, patternMaking
      specializations: ['Fabric Cutting', 'Material Optimization'],
      experienceYears: 6,
      certifications: ['Precision Cutting Specialist'],
      availability: 0, // fullTime
      preferredWorkDays: ['Tuesday', 'Wednesday', 'Thursday', 'Saturday'],
      preferredStartTime: {'hour': 10, 'minute': 0},
      preferredEndTime: {'hour': 18, 'minute': 0},
      canWorkRemotely: false,
      location: 'Cutting Department',
      totalOrdersCompleted: 156,
      ordersInProgress: 3,
      averageRating: 4.6,
      completionRate: 0.94,
      strengths: ['Precision work', 'Fast execution'],
      areasForImprovement: ['Needs to reduce waste'],
      baseRatePerHour: 85.0,
      performanceBonusRate: 12.0,
      paymentTerms: 'Monthly',
      totalEarnings: 52800.0,
      recentAssignments: [],
      consecutiveDaysWorked: 22,
      isActive: true,
      joinedDate: admin.firestore.Timestamp.fromDate(new Date('2024-01-10')),
      additionalInfo: {'demo_account': true},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }
  ];

  // Check if employees already exist
  const existingEmployees = await firestore.collection('employees').get();
  if (!existingEmployees.empty) {
    console.log(`✅ Demo employees already exist (${existingEmployees.size} found)`);
    return;
  }

  // Add each employee
  for (const employee of employees) {
    await firestore.collection('employees').add(employee);
    console.log(`✅ Added employee: ${employee.displayName}`);
  }

  console.log('✅ Successfully added 3 demo employees!');
}

function printDemoAccounts() {
  console.log('\n📧 Demo Accounts Created:');
  for (const user of demoUsers) {
    console.log(`- ${user.displayName}: ${user.email} / ${user.password}`);
  }
}

// Main execution
async function main() {
  try {
    console.log('🚀 Starting Firebase data setup...');

    // Initialize Firebase (done above)

    // Create demo accounts
    await createDemoAccounts();

    // Setup employee data
    await setupBasicEmployees();

    console.log('\n🎉 Firebase data setup completed successfully!');

    // Print accounts
    printDemoAccounts();
  } catch (e) {
    console.log(`❌ Error in Firebase data setup: ${e}`);
    throw e;
  } finally {
    admin.app().delete();
  }
}

main();
