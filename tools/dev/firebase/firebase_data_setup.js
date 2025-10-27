const admin = require('firebase-admin');

// Initialize Firebase Admin
// You need to download the service account key from Firebase Console > Project Settings > Service Accounts
// Save it as serviceAccountKey.json in the config directory
const serviceAccount = require('../config/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${serviceAccount.project_id}-default-rtdb.firebaseio.com` // Adjust if using RTDB
});

const auth = admin.auth();
const firestore = admin.firestore();

// Note: Use the correct category index from your ProductCategory enum
// Based on the enum I saw: mensWear=0, womensWear=1, kidsWear=2, etc.
const ProductCategory = {
  mensWear: 0,
  womensWear: 1,
  kidsWear: 2,
  formalWear: 3,
  casualWear: 4,
  traditionalWear: 5,
  alterations: 6,
  customDesign: 7
};

// Comprehensive demo user data for Indian tailoring shop
const demoUsers = [
  // Shop Owners
  {
    email: 'owner@royal-tailors.com',
    password: 'Tailor123!',
    displayName: 'Rajesh Sharma',
    role: 3, // UserRole.shopOwner
    phone: '+91-9876543210',
    details: {
      businessName: 'Royal Tailors',
      experience: 25,
      specialties: ['Wedding Wear', 'Formal Suits', 'Traditional Wear']
    }
  },
  {
    email: 'manager@sarika-designs.com',
    password: 'Designer123!',
    displayName: 'Sarika Patel',
    role: 3, // UserRole.shopOwner
    phone: '+91-9876543211',
    details: {
      businessName: 'Sarika Designer Boutique',
      experience: 18,
      specialties: ['Bridal Lehenga', 'Designer Sarees', 'Modern Fashion']
    }
  },
  // Employees
  {
    email: 'vikram.kumar@royal-tailors.com',
    password: 'Tailor123!',
    displayName: 'Vikram Kumar',
    role: 1, // UserRole.employee
    phone: '+91-9876543212',
    details: {
      skills: ['Stitching', 'Alterations', 'Pattern Making'],
      specialization: 'Formal Wear & Suits',
      experienceYears: 12,
      hourlyRate: 150,
      certifications: ['Master Tailor Certification', 'CAD Pattern Design']
    }
  },
  {
    email: 'priya.singh@sarika-designs.com',
    password: 'Designer123!',
    displayName: 'Priya Singh',
    role: 1, // UserRole.employee
    phone: '+91-9876543213',
    details: {
      skills: ['Embroidery', 'Design Creation', 'Fabric Selection'],
      specialization: 'Bridal & Traditional Wear',
      experienceYears: 8,
      hourlyRate: 200,
      certifications: ['Fashion Design Diploma', 'Embroidery Specialist']
    }
  },
  {
    email: 'amit.verma@royal-tailors.com',
    password: 'Tailor123!',
    displayName: 'Amit Verma',
    role: 1, // UserRole.employee
    phone: '+91-9876543214',
    details: {
      skills: ['Fabric Cutting', 'Measurements', 'Quality Control'],
      specialization: 'Fabric Cutting & Optimization',
      experienceYears: 10,
      hourlyRate: 120,
      certifications: ['Precision Cutting Specialist', 'Quality Assurance']
    }
  },
  {
    email: 'deepa.krishnan@sarika-designs.com',
    password: 'Designer123!',
    displayName: 'Deepa Krishnan',
    role: 1, // UserRole.employee
    phone: '+91-9876543215',
    details: {
      skills: ['Saree Draping', 'Blouse Stitching', 'Alterations'],
      specialization: 'Sarees & South Indian Wear',
      experienceYears: 15,
      hourlyRate: 140,
      certifications: ['Traditional Wear Specialist', 'Color Theory Expert']
    }
  },
  // Customers
  {
    email: 'rahul.agrawal@gmail.com',
    password: 'Customer123!',
    displayName: 'Rahul Agrawal',
    role: 0, // UserRole.customer
    phone: '+91-9876543216',
    details: {
      measurements: { chest: 42, waist: 36, shoulder: 18, inseam: 34 },
      preferences: { style: 'Modern', fabric: 'Cotton', colors: ['Navy', 'Charcoal'] },
      loyaltyTier: 'Gold',
      totalSpent: 125000,
      orderCount: 8
    }
  },
  {
    email: 'meera.sharma@outlook.com',
    password: 'Customer123!',
    displayName: 'Meera Sharma',
    role: 0, // UserRole.customer
    phone: '+91-9876543217',
    details: {
      measurements: { chest: 38, waist: 30, shoulder: 15, inseam: 30 },
      preferences: { style: 'Traditional', fabric: 'Silk', colors: ['Maroon', 'Gold', 'Cream'] },
      loyaltyTier: 'Platinum',
      totalSpent: 250000,
      orderCount: 15
    }
  },
  {
    email: 'karan.jain@yahoo.com',
    password: 'Customer123!',
    displayName: 'Karan Jain',
    role: 0, // UserRole.customer
    phone: '+91-9876543218',
    details: {
      measurements: { chest: 44, waist: 38, shoulder: 19, inseam: 35 },
      preferences: { style: 'Corporate', fabric: 'Wool Blend', colors: ['Grey', 'Navy', 'Black'] },
      loyaltyTier: 'Silver',
      totalSpent: 87500,
      orderCount: 6
    }
  },
  {
    email: 'isha.patel@icloud.com',
    password: 'Customer123!',
    displayName: 'Isha Patel',
    role: 0, // UserRole.customer
    phone: '+91-9876543219',
    details: {
      measurements: { chest: 36, waist: 28, shoulder: 14, inseam: 29 },
      preferences: { style: 'Designer', fabric: 'Chiffon', colors: ['Pink', 'Blue', 'White'] },
      loyaltyTier: 'Bronze',
      totalSpent: 25000,
      orderCount: 3
    }
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
  const details = userData.details || {};

  await firestore.collection('employees').doc(`emp_${uid}`).set({
    id: `emp_${uid}`,
    userId: uid,
    displayName: userData.displayName,
    email: userData.email,
    phoneNumber: userData.phone,
    role: 1, // Employee
    skills: details.skills || ['General Tailoring'],
    specializations: [details.specialization || 'General Tailoring'],
    experienceYears: details.experienceYears || 5,
    certifications: details.certifications || [],
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
    location: determineWorkLocation(details.specialization || ''),
    totalOrdersCompleted: Math.floor(Math.random() * 100) + 10,
    ordersInProgress: Math.floor(Math.random() * 3),
    averageRating: (Math.random() * 0.5 + 4.3).toFixed(1), // 4.3-4.8 range
    completionRate: 0.85 + Math.random() * 0.13, // 85-98% range
    strengths: generateStrengths(details.specialization || ''),
    areasForImprovement: generateAreasForImprovement(details.specialization || ''),
    baseRatePerHour: details.hourlyRate || 120.0,
    performanceBonusRate: 15.0 + Math.random() * 10.0,
    paymentTerms: 'Monthly',
    totalEarnings: Math.floor(Math.random() * 50000) + 25000,
    recentAssignments: [],
    consecutiveDaysWorked: Math.floor(Math.random() * 30),
    isActive: true,
    joinedDate: admin.firestore.FieldValue.serverTimestamp(),
    additionalInfo: {
      businessEmail: userData.email,
      emergencyContact: generateEmergencyContact(),
      employeeId: `EMP${String(Math.floor(Math.random() * 1000)).padStart(3, '0')}`
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function createCustomerProfile(uid, userData) {
  const details = userData.details || {};

  await firestore.collection('customers').doc(uid).set({
    id: uid,
    userId: uid,
    name: userData.displayName,
    email: userData.email,
    phone: userData.phone,
    address: {
      street: generateRandomStreet(),
      city: getRandomIndianCity(),
      state: getRandomIndianState(),
      country: 'India',
      pincode: generateRandomPincode(),
    },
    measurements: {
      chest: details.measurements?.chest || (35 + Math.floor(Math.random() * 12)), // Random 35-47
      waist: details.measurements?.waist || (28 + Math.floor(Math.random() * 14)), // Random 28-42
      shoulder: details.measurements?.shoulder || (14 + Math.floor(Math.random() * 6)), // Random 14-20
      sleeveLength: details.measurements?.sleeveLength || (22 + Math.floor(Math.random() * 6)), // Random 22-28
      inseam: details.measurements?.inseam || (28 + Math.floor(Math.random() * 9)), // Random 28-37
      neck: details.measurements?.neck || (14 + Math.floor(Math.random() * 4)), // Random 14-18
    },
    preferences: {
      style: details.preferences?.style || getRandomStyle(),
      fabric: details.preferences?.fabric || getRandomFabric(),
      colors: details.preferences?.colors || getRandomColors(),
    },
    loyaltyTier: details.loyaltyTier || getRandomLoyaltyTier(details.totalSpent || 0),
    totalSpent: details.totalSpent || Math.floor(Math.random() * 200000),
    orderCount: details.orderCount || Math.floor(Math.random() * 20),
    joinDate: admin.firestore.FieldValue.serverTimestamp(),
    lastOrderDate: null,
    isActive: true,
    notes: `Created as demo customer. Preferences: ${details.preferences?.style || 'General'}`,
    emergencyContact: {
      name: generateEmergencyContactName(),
      phone: generateEmergencyContactPhone()
    },
    additionalInfo: {
      preferredCommunication: ['Email', 'WhatsApp'],
      birthday: generateRandomBirthday(),
      anniversary: Math.random() > 0.5 ? generateRandomAnniversary() : null
    },
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

async function createSampleProducts() {
  console.log('🚀 Setting up demo products for tailoring app...');

  // Sample tailoring products for Indian market
  const products = [
    {
      id: 'prod_001',
      name: 'Premium Wool Suit - 3 Piece',
      description: 'Hand-crafted premium wool suit with Italian fabric, perfect for weddings and corporate events. Includes jacket, trousers, and waistcoat with custom tailoring services.',
      basePrice: 25999.0,
      originalPrice: 35000.0,
      discountPercentage: 25.7,
      category: ProductCategory.mensWear,
      brand: 'Royal Tailors',
      imageUrls: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=600&fit=crop',
        'https://images.unsplash.com/photo-1445205170230-053b83016050?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Super 150s Wool from Italy',
        'Color': 'Navy Blue',
        'Style': 'Classic Fit',
        'Workmanship': 'Hand Stitched',
        'Delivery Time': '21-28 days'
      },
      availableSizes: ['38', '40', '42', '44', '46', '48'],
      availableFabrics: ['Wool', 'Cotton Blend', 'Linen'],
      customizationOptions: ['Size Customization', 'Color Choice', 'Monogram Embroidery'],
      stockCount: 15,
      soldCount: 23,
      rating: {
        averageRating: 4.8,
        reviewCount: 15,
        recentReviews: []
      },
      isActive: true,
      isPopular: true,
      isNewArrival: false,
      isOnSale: false,
      badges: {},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      id: 'prod_002',
      name: 'Designer Lehenga Choli - Golden Embroidery',
      description: 'Exquisite bridal lehenga with heavy gold embroidery work, featuring traditional motifs and modern design elements. Perfect for weddings and festive occasions.',
      basePrice: 89999.0,
      originalPrice: 120000.0,
      discountPercentage: 25.0,
      category: ProductCategory.womensWear,
      brand: 'Golden Threads',
      imageUrls: [
        'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&h=600&fit=crop',
        'https://images.unsplash.com/photo-1594736142265-db07cd5c6fc3?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Work': 'Heavy Gold Embroidery',
        'Fabric': 'Pure Silk',
        'Color': 'Maroon with Gold',
        'Design': 'Traditional Bridal',
        'Delivery Time': '30-45 days'
      },
      availableSizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      availableFabrics: ['Pure Silk', 'Chiffon', 'Georgette'],
      customizationOptions: ['Size Alterations', 'Color Matching', 'Additional Embroidery'],
      stockCount: 5,
      soldCount: 8,
      rating: {
        averageRating: 4.9,
        reviewCount: 12,
        recentReviews: []
      },
      isActive: true,
      isPopular: true,
      isNewArrival: true,
      isOnSale: true,
      badges: {},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      id: 'prod_003',
      name: 'Traditional Sherwani - Embroidered',
      description: 'Elegant sherwani with intricate embroidery work, ideal for wedding ceremonies and cultural events. Made with premium fabric and attention to traditional details.',
      basePrice: 45999.0,
      originalPrice: 55000.0,
      discountPercentage: 16.4,
      category: ProductCategory.mensWear,
      brand: 'Heritage Crafts',
      imageUrls: [
        'https://images.unsplash.com/photo-1506629905607-d6c8c76c234e?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Work': 'Zardosi Embroidery',
        'Fabric': 'Raw Silk',
        'Color': 'Cream with Gold',
        'Style': 'Traditional Sherwani',
        'Delivery Time': '25-35 days'
      },
      availableSizes: ['36', '38', '40', '42', '44', '46', '48'],
      availableFabrics: ['Raw Silk', 'Brocade', 'Velvet'],
      customizationOptions: ['Custom Measurements', 'Design Modifications', 'Fabric Choice'],
      stockCount: 8,
      soldCount: 5,
      rating: {
        averageRating: 4.7,
        reviewCount: 8,
        recentReviews: []
      },
      isActive: true,
      isPopular: false,
      isNewArrival: false,
      isOnSale: false,
      badges: {},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      id: 'prod_004',
      name: 'Modest Maxi Dress - Cotton',
      description: 'Comfortable everyday maxi dress made from premium cotton fabric. Perfect for office wear and casual outings with elegant design and quality stitching.',
      basePrice: 8999.0,
      originalPrice: 11000.0,
      discountPercentage: 18.2,
      category: ProductCategory.womensWear,
      brand: 'Comfort Wear',
      imageUrls: [
        'https://images.unsplash.com/photo-1596783074911-700b9db3c5f4?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Premium Cotton',
        'Color': 'Navy Blue',
        'Style': 'Maxi Dress',
        'Occasion': 'Formal/Casual',
        'Delivery Time': '7-10 days'
      },
      availableSizes: ['XS', 'S', 'M', 'L', 'XL'],
      availableFabrics: ['Cotton', 'Linen Cotton Mix'],
      customizationOptions: ['Size Adjustments', 'Length Modification'],
      stockCount: 25,
      soldCount: 12,
      rating: {
        averageRating: 4.4,
        reviewCount: 10,
        recentReviews: []
      },
      isActive: true,
      isPopular: true,
      isNewArrival: false,
      isOnSale: false,
      badges: {},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      id: 'prod_005',
      name: 'Kids Party Wear - Kurta Set',
      description: 'Beautiful kurta set for kids with traditional embroidery. Perfect for festivals and family celebrations with vibrant colors and comfortable fit.',
      basePrice: 3499.0,
      originalPrice: 4500.0,
      discountPercentage: 22.2,
      category: ProductCategory.kidsWear,
      brand: 'Little Champs',
      imageUrls: [
        'https://images.unsplash.com/photo-1559030752-b8d3f5b8b8e3?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Age Group': '5-12 years',
        'Fabric': 'Cotton',
        'Style': 'Kurta with Pajama',
        'Occasion': 'Festive Wear',
        'Delivery Time': '7-12 days'
      },
      availableSizes: ['22', '24', '26', '28', '30', '32'],
      availableFabrics: ['Cotton', 'Cotton Blend'],
      customizationOptions: ['Size Options', 'Color Selection'],
      stockCount: 30,
      soldCount: 18,
      rating: {
        averageRating: 4.6,
        reviewCount: 14,
        recentReviews: []
      },
      isActive: true,
      isPopular: false,
      isNewArrival: true,
      isOnSale: false,
      badges: {},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    {
      id: 'prod_006',
      name: 'Corporate Blazer - Modern Fit',
      description: 'Professional blazer suitable for corporate environments. Made with wool blend fabric ensuring comfort and style throughout the workday.',
      basePrice: 18999.0,
      originalPrice: null,
      discountPercentage: 0.0,
      category: ProductCategory.mensWear,
      brand: 'Executive Wear',
      imageUrls: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=600&fit=crop',
        'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Wool Blend',
        'Fit': 'Modern Slim',
        'Color': 'Charcoal Grey',
        'Style': '2-Button Blazer',
        'Delivery Time': '14-18 days'
      },
      availableSizes: ['38R', '40R', '42R', '44R', '46R'],
      availableFabrics: ['Wool Blend', 'Polyester Mix'],
      customizationOptions: ['Size Customization', 'Monogram Service'],
      stockCount: 20,
      soldCount: 9,
      rating: {
        averageRating: 4.3,
        reviewCount: 7,
        recentReviews: []
      },
      isActive: true,
      isPopular: false,
      isNewArrival: false,
      isOnSale: false,
      badges: {},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }
  ];

  // Check if products already exist
  const existingProducts = await firestore.collection('products').get();
  if (!existingProducts.empty) {
    console.log(`✅ Demo products already exist (${existingProducts.size} found)`);
    return;
  }

  // Add each product
  for (const product of products) {
    await firestore.collection('products').doc(product.id).set(product);
    console.log(`✅ Added product: ${product.name} (${product.brand})`);
  }

  console.log('✅ Successfully added 6 demo tailoring products!');
}

function printDemoAccounts() {
  console.log('\n📧 Demo Accounts Created:');
  for (const user of demoUsers) {
    console.log(`- ${user.displayName}: ${user.email} / ${user.password}`);
  }
}

// Helper functions for generating realistic demo data
function determineWorkLocation(specialization) {
  const locations = {
    'Formal Wear & Suits': 'Main Workshop - Suit Department',
    'Bridal & Traditional Wear': 'Design Studio',
    'Fabric Cutting & Optimization': 'Cutting Department',
    'Sarees & South Indian Wear': 'Traditional Wear Section',
  };
  return locations[specialization] || 'Main Workshop';
}

function generateStrengths(specialization) {
  const strengthPools = {
    'Formal Wear & Suits': [
      'Exceptional attention to detail',
      'Expert in formal wear patterns',
      'Perfect measurements every time',
      'High client satisfaction'
    ],
    'Bridal & Traditional Wear': [
      'Creative design thinking',
      'Extensive embroidery knowledge',
      'Excellent color coordination',
      'Client-focused approach'
    ],
    'Fabric Cutting & Optimization': [
      'Precise cutting techniques',
      'Material optimization expertise',
      'Wastage minimization',
      'Quality control focus'
    ],
    'Sarees & South Indian Wear': [
      'Traditional draping mastery',
      'Extensive fabric knowledge',
      'Cultural authenticity',
      'Perfect fitting for traditional wear'
    ],
  };

  const pool = strengthPools[specialization] || ['Reliable performance', 'Quality focus', 'Client satisfaction'];
  // Return 2-3 random strengths
  const shuffled = pool.sort(() => 0.5 - Math.random());
  return shuffled.slice(0, 2 + Math.floor(Math.random() * 2));
}

function generateAreasForImprovement(specialization) {
  const improvementPools = {
    'Formal Wear & Suits': [
      'Could improve time management',
      'Should learn advanced CAD design',
      'Might reduce material wastage slightly'
    ],
    'Bridal & Traditional Wear': [
      'Should delegate minor tasks sometimes',
      'Could maintain better documentation',
      'Might need to reduce consultation time'
    ],
    'Fabric Cutting & Optimization': [
      'Should reduce material wastage further',
      'Could improve speed without losing precision',
      'Might consider bulk cutting methods'
    ],
    'Sarees & South Indian Wear': [
      'Could update technique knowledge frequently',
      'Might need to reduce measuring time',
      'Should document traditional methods better'
    ],
  };

  const pool = improvementPools[specialization] || ['None identified', 'Performance excellent'];
  return pool.sort(() => 0.5 - Math.random()).slice(0, 1 + Math.floor(Math.random()));
}

function generateEmergencyContact() {
  const names = ['Sunita Kumar', 'Rajesh Verma', 'Priya Singh', 'Amit Singh', 'Meera Patel'];
  const phones = ['+91-98765-4' + Math.floor(Math.random() * 10000 + 10000)];
  return {
    name: names[Math.floor(Math.random() * names.length)],
    relationship: 'Relative',
    phone: phones[0]
  };
}

function generateRandomStreet() {
  const streets = [
    'Park Street', 'MG Road', 'Brigade Road', 'Commercial Street', 'Mount Road', 'Linking Road',
    'Hill Road', 'Station Road', 'Market Road', 'Mall Road', 'Residency Road', 'Bazaar Road'
  ];
  return `${Math.floor(Math.random() * 200) + 1} ${streets[Math.floor(Math.random() * streets.length)]}`;
}

function getRandomIndianCity() {
  const cities = [
    'Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata', 'Pune', 'Ahmedabad', 'Jaipur',
    'Surat', 'Hyderabad', 'Lucknow', 'Kanpur', 'Nagpur', 'Indore', 'Thane', 'Bhopal'
  ];
  return cities[Math.floor(Math.random() * cities.length)];
}

function getRandomIndianState() {
  const states = {
    'Mumbai': 'Maharashtra',
    'Delhi': 'Delhi',
    'Bangalore': 'Karnataka',
    'Chennai': 'Tamil Nadu',
    'Kolkata': 'West Bengal',
    'Pune': 'Maharashtra',
    'Ahmedabad': 'Gujarat',
    'Jaipur': 'Rajasthan',
    'Surat': 'Gujarat',
    'Hyderabad': 'Telangana',
    'Lucknow': 'Uttar Pradesh',
    'Kanpur': 'Uttar Pradesh',
    'Nagpur': 'Maharashtra',
    'Indore': 'Madhya Pradesh',
    'Thane': 'Maharashtra',
    'Bhopal': 'Madhya Pradesh'
  };
  const cities = Object.keys(states);
  const city = cities[Math.floor(Math.random() * cities.length)];
  return states[city];
}

function generateRandomPincode() {
  return Math.floor(Math.random() * 900000 + 100000).toString();
}

function getRandomStyle() {
  const styles = ['Modern', 'Traditional', 'Designer', 'Classic', 'Contemporary', 'Fusion'];
  return styles[Math.floor(Math.random() * styles.length)];
}

function getRandomFabric() {
  const fabrics = ['Cotton', 'Silk', 'Wool Blend', 'Linen', 'Chiffon', 'Georgette', 'Polyester', 'Rayon'];
  return fabrics[Math.floor(Math.random() * fabrics.length)];
}

function getRandomColors() {
  const colorPalette = ['Black', 'Navy', 'Grey', 'White', 'Beige', 'Blue', 'Maroon', 'Gold', 'Cream', 'Pink', 'Green'];
  const numColors = 2 + Math.floor(Math.random() * 3); // 2-4 colors
  const shuffled = colorPalette.sort(() => 0.5 - Math.random());
  return shuffled.slice(0, numColors);
}

function getRandomLoyaltyTier(spent) {
  if (spent >= 200000) return 'Platinum';
  if (spent >= 100000) return 'Gold';
  if (spent >= 50000) return 'Silver';
  return 'Bronze';
}

function generateEmergencyContactName() {
  const firstNames = ['Sunita', 'Rajesh', 'Priya', 'Amit', 'Meera', 'Vikram', 'Deepa', 'Suresh', 'Kavita', 'Ravi'];
  const lastNames = ['Kumar', 'Singh', 'Verma', 'Patel', 'Sharma', 'Gupta', 'Agarwal', 'Jain', 'Malhotra', 'Chopra'];
  return `${firstNames[Math.floor(Math.random() * firstNames.length)]} ${lastNames[Math.floor(Math.random() * lastNames.length)]}`;
}

function generateEmergencyContactPhone() {
  return `+91-9${Math.floor(Math.random() * 8 + 7)}${Math.floor(Math.random() * 100000000 + 10000000).toString().padStart(3, '0')}`;
}

function generateRandomBirthday() {
  // Generate birthday between 18-65 years ago
  const today = new Date();
  const birthYear = today.getFullYear() - 18 - Math.floor(Math.random() * 47);
  const birthMonth = Math.floor(Math.random() * 12) + 1;
  const birthDay = Math.floor(Math.random() * 28) + 1; // Ensure valid date
  return `${birthYear}-${birthMonth.toString().padStart(2, '0')}-${birthDay.toString().padStart(2, '0')}`;
}

function generateRandomAnniversary() {
  // Generate anniversary within last 5-15 years
  const today = new Date();
  const yearsAgo = 5 + Math.floor(Math.random() * 10);
  const anniversaryDate = new Date(today.getFullYear() - yearsAgo, today.getMonth(), today.getDate());
  return `${anniversaryDate.getFullYear()}-${(anniversaryDate.getMonth() + 1).toString().padStart(2, '0')}-${anniversaryDate.getDate().toString().padStart(2, '0')}`;
}

// Main execution
async function main() {
  try {
    console.log('🚀 Starting comprehensive Firebase data setup...');

    // Create demo accounts with detailed profiles
    await createDemoAccounts();

    // Setup additional employee data (the manual ones)
    await setupBasicEmployees();

    // Setup sample tailoring products
    await createSampleProducts();

    console.log('\n🎉 Firebase data setup completed successfully!');
    console.log('\n📊 Summary:');
    console.log('- 2 Shop Owners (tailoring businesses)');
    console.log('- 4 Specialized Employees');
    console.log('- 4 Customers with detailed profiles');
    console.log('- 6 Indian tailoring products');
    console.log('- 3 Additional demo employees');

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
