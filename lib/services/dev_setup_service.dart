import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/employee.dart' as emp;
import '../models/user_role.dart';

class DevSetupService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Development users data
  static const String _devPassword = 'dev123456'; // Must be 6+ characters

  static final Map<String, Map<String, dynamic>> devUsers = {
    'esther_shop_owner': {
      'email': 'owner@tailoring.com',
      'password': _devPassword,
      'displayName': 'Esther (Owner)',
      'role': UserRole.shopOwner,
      'type': 'shop_owner',
    },
    'john_customer': {
      'email': 'customer@example.com',
      'password': _devPassword,
      'displayName': 'John Doe (Customer)',
      'role': UserRole.customer,
      'type': 'customer',
    },
    'rajesh_employee': {
      'email': 'rajesh@tailoring.com',
      'password': _devPassword,
      'displayName': 'Rajesh Kumar (Employee)',
      'role': UserRole.employee,
      'type': 'employee',
      'skills': [
        emp.EmployeeSkill.cutting,
        emp.EmployeeSkill.stitching,
        emp.EmployeeSkill.qualityCheck
      ],
    },
    'priya_employee': {
      'email': 'priya@tailoring.com',
      'password': _devPassword,
      'displayName': 'Priya Sharma (Employee)',
      'role': UserRole.employee,
      'type': 'employee',
      'skills': [
        emp.EmployeeSkill.patternMaking,
        emp.EmployeeSkill.embroidery,
        emp.EmployeeSkill.alterations,
        emp.EmployeeSkill.finishing
      ],
    },
  };

  // Create all development users
  static Future<void> createDevUsers() async {
    print('🚀 Starting development user creation...');

    for (final entry in devUsers.entries) {
      final userData = entry.value;
      await _createUser(userData);
    }

    print('✅ All development users created successfully!');
    print('');
    print('🔑 Development Login Credentials:');
    print('Password for all accounts: $_devPassword');
    print('');
    devUsers.forEach((key, user) {
      print('${user['displayName']}: ${user['email']}');
    });
  }

  // Create individual user
  static Future<void> _createUser(Map<String, dynamic> userData) async {
    try {
      final email = userData['email'] as String;
      final password = userData['password'] as String;
      final displayName = userData['displayName'] as String;
      final role = userData['role'] as UserRole;
      final userType = userData['type'] as String;

      print('Creating user: $displayName ($email)');

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.sendEmailVerification();

      // Create user profile in Firestore
      final userProfile = {
        'id': uid,
        'email': email,
        'displayName': displayName,
        'role': role.index,
        'photoUrl': null,
        'phoneNumber': _getPhoneNumber(userType),
        'isEmailVerified': false,
        'lastLoginAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).set(userProfile);

      // Create additional data based on role
      if (role == UserRole.employee) {
        await _createEmployeeData(uid, userData);
      } else if (role == UserRole.customer) {
        await _createCustomerData(uid, userData);
      } else if (role == UserRole.shopOwner) {
        await _createShopOwnerData(uid, userData);
      }

      print('✅ Created user: $displayName');
    } catch (e) {
      print('❌ Error creating user ${userData['displayName']}: $e');
      // Try to clean up if user creation failed
      try {
        if (userData['email'] != null) {
          await _auth.signOut();
        }
      } catch (_) {}
    }
  }

  // Create employee data
  static Future<void> _createEmployeeData(
      String userId, Map<String, dynamic> userData) async {
    final employee = emp.Employee(
      id: 'emp_$userId',
      userId: userId,
      displayName: userData['displayName'] as String,
      email: userData['email'] as String,
      phoneNumber: _getPhoneNumber('employee'),
      role: UserRole.employee,
      skills: userData['skills'] as List<emp.EmployeeSkill>? ?? [],
      specializations: ['General Tailoring'],
      experienceYears: 5,
      certifications: ['Certified Tailor'],
      availability: emp.EmployeeAvailability.fullTime,
      preferredWorkDays: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday'
      ],
      preferredStartTime: const emp.TimeOfDay(hour: 9, minute: 0),
      preferredEndTime: const emp.TimeOfDay(hour: 17, minute: 0),
      canWorkRemotely: false,
      location: 'Main Workshop',
      totalOrdersCompleted: 0,
      ordersInProgress: 0,
      averageRating: 0.0,
      completionRate: 0.0,
      strengths: ['Attention to detail', 'Reliability'],
      areasForImprovement: ['Could improve time management'],
      baseRatePerHour: 150.0,
      performanceBonusRate: 25.0,
      paymentTerms: 'Monthly',
      totalEarnings: 0.0,
      recentAssignments: [],
      consecutiveDaysWorked: 0,
      isActive: true,
      joinedDate: DateTime.now(),
      additionalInfo: {
        'department': 'Tailoring',
        'shift': 'Day',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('employees')
        .doc(employee.id)
        .set(employee.toJson());
  }

  // Create customer data
  static Future<void> _createCustomerData(
      String userId, Map<String, dynamic> userData) async {
    final customerData = {
      'id': userId,
      'userId': userId,
      'name': userData['displayName'] as String,
      'email': userData['email'] as String,
      'phone': _getPhoneNumber('customer'),
      'address': {
        'street': '123 Main Street',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'country': 'India',
        'pincode': '400001',
      },
      'measurements': {
        'chest': 40.0,
        'waist': 32.0,
        'shoulder': 17.0,
        'sleeveLength': 25.0,
        'inseam': 32.0,
        'neck': 15.5,
      },
      'preferences': {
        'style': 'Traditional',
        'fabric': 'Cotton',
        'colors': ['Blue', 'White', 'Black'],
      },
      'loyaltyTier': 'Bronze',
      'totalSpent': 0.0,
      'orderCount': 0,
      'joinDate': FieldValue.serverTimestamp(),
      'lastOrderDate': null,
      'isActive': true,
      'notes': 'Development test customer',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('customers').doc(userId).set(customerData);
  }

  // Create shop owner data
  static Future<void> _createShopOwnerData(
      String userId, Map<String, dynamic> userData) async {
    // Shop owner gets both employee and customer data plus additional owner data
    await _createEmployeeData(userId, {
      ...userData,
      'skills': [emp.EmployeeSkill.qualityCheck, emp.EmployeeSkill.alterations],
    });

    await _createCustomerData(userId, userData);

    // Additional shop owner data
    final shopOwnerData = {
      'userId': userId,
      'businessName': 'Esther\'s Tailoring Shop',
      'businessType': 'Tailoring & Alterations',
      'experience': 12,
      'specialties': ['Bridal Wear', 'Formal Suits', 'Traditional Wear'],
      'businessAddress': {
        'street': '456 Fashion Street',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'country': 'India',
        'pincode': '400002',
      },
      'businessPhone': '+91-9876543210',
      'operatingHours': {
        'monday': {'open': '09:00', 'close': '18:00'},
        'tuesday': {'open': '09:00', 'close': '18:00'},
        'wednesday': {'open': '09:00', 'close': '18:00'},
        'thursday': {'open': '09:00', 'close': '18:00'},
        'friday': {'open': '09:00', 'close': '18:00'},
        'saturday': {'open': '09:00', 'close': '16:00'},
        'sunday': 'Closed',
      },
      'pricing': {
        'shirt': 800.0,
        'trouser': 600.0,
        'suit': 2500.0,
        'alteration': 200.0,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('shops').doc(userId).set(shopOwnerData);
  }

  // Get phone number based on user type
  static String _getPhoneNumber(String userType) {
    switch (userType) {
      case 'shop_owner':
        return '+91-9876543210';
      case 'customer':
        return '+91-9876543211';
      case 'employee':
        return '+91-9876543212';
      default:
        return '+91-9876543200';
    }
  }

  // Get all development login credentials for UI display
  static List<Map<String, String>> getDevCredentials() {
    return devUsers.values
        .map((user) => {
              'displayName': user['displayName'] as String,
              'email': user['email'] as String,
              'password': user['password'] as String,
              'role': (user['role'] as UserRole).displayName,
              'type': user['type'] as String,
            })
        .toList();
  }

  // Sign in as development user (for quick login buttons)
  static Future<UserCredential?> signInAsDevUser(
      String email, String password) async {
    try {
      print('Signing in as development user: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Signed in successfully as: ${userCredential.user?.displayName}');
      return userCredential;
    } catch (e) {
      print('❌ Failed to sign in as $email: $e');
      return null;
    }
  }
}
