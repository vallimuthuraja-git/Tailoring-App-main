import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

// Demo user data for testing
const List<Map<String, dynamic>> demoUsers = [
  {
    'email': 'shop@demo.com',
    'password': 'Pass123',
    'displayName': 'Shop Owner',
    'role': 3, // UserRole.shopOwner
    'phone': '+91-9876543210',
  },
  {
    'email': 'customer@demo.com',
    'password': 'Pass123',
    'displayName': 'Demo Customer',
    'role': 0, // UserRole.customer
    'phone': '+91-9876543211',
  },
  {
    'email': 'employee0@demo.com',
    'password': 'Pass123',
    'displayName': 'Employee 0',
    'role': 1, // UserRole.employee
    'phone': '+91-9876543212',
  },
  {
    'email': 'employee1@demo.com',
    'password': 'Pass123',
    'displayName': 'Employee 1',
    'role': 1, // UserRole.employee
    'phone': '+91-9876543213',
  },
];

class DemoAccountCreator {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createDemoAccounts() async {
    try {
      if (kDebugMode) print('🚀 Starting demo account creation...');

      for (final userData in demoUsers) {
        try {
          await _createSingleAccount(userData);
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error creating user ${userData['displayName']}: $e');
          }
        }
      }

      if (kDebugMode) {
        print('\n🎉 Demo account creation completed!');
        _printDemoAccounts();
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error in demo account creation: $e');
      rethrow;
    }
  }

  Future<void> _createSingleAccount(Map<String, dynamic> userData) async {
    final email = userData['email'] as String;
    final password = userData['password'] as String;
    final displayName = userData['displayName'] as String;
    final role = userData['role'] as int;
    final phone = userData['phone'] as String;

    if (kDebugMode) print('Creating user: $displayName ($email)');

    // Check if user already exists
    final existingQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (existingQuery.docs.isNotEmpty) {
      if (kDebugMode) print('⚠️  User $email already exists, skipping...');
      return;
    }

    // Create Firebase Auth user
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;
    await userCredential.user!.updateDisplayName(displayName);

    // Create user profile in Firestore
    await _firestore.collection('users').doc(uid).set({
      'id': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'isEmailVerified': true,
      'phoneNumber': phone,
      'lastLoginAt': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Create role-specific data
    if (role == 1) {
      // Employee
      await _createEmployeeProfile(uid, userData);
    } else if (role == 0) {
      // Customer
      await _createCustomerProfile(uid, userData);
    }

    if (kDebugMode) print('✅ Created user: $displayName');
  }

  Future<void> _createEmployeeProfile(
      String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('employees').doc('emp_$uid').set({
      'id': 'emp_$uid',
      'userId': uid,
      'displayName': userData['displayName'],
      'email': userData['email'],
      'phoneNumber': userData['phone'] ?? '',
      'role': 1, // Employee
      'skills': ['General Tailoring'],
      'specializations': [],
      'experienceYears': 2,
      'certifications': [],
      'availability': 0, // fullTime
      'preferredWorkDays': [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday'
      ],
      'preferredStartTime': {'hour': 9, 'minute': 0},
      'preferredEndTime': {'hour': 17, 'minute': 0},
      'canWorkRemotely': false,
      'location': 'Workshop',
      'totalOrdersCompleted': 0,
      'ordersInProgress': 0,
      'averageRating': 0.0,
      'completionRate': 0.0,
      'strengths': ['Reliable'],
      'areasForImprovement': [],
      'baseRatePerHour': 120.0,
      'performanceBonusRate': 20.0,
      'paymentTerms': 'Monthly',
      'totalEarnings': 0.0,
      'recentAssignments': [],
      'consecutiveDaysWorked': 0,
      'isActive': true,
      'joinedDate': FieldValue.serverTimestamp(),
      'additionalInfo': {},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _createCustomerProfile(
      String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('customers').doc(uid).set({
      'id': uid,
      'userId': uid,
      'name': userData['displayName'],
      'email': userData['email'],
      'phone': userData['phone'] ?? '',
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
        'style': 'Modern',
        'fabric': 'Cotton',
        'colors': ['Black', 'Blue', 'White'],
      },
      'loyaltyTier': 'Bronze',
      'totalSpent': 0.0,
      'orderCount': 0,
      'joinDate': FieldValue.serverTimestamp(),
      'lastOrderDate': null,
      'isActive': true,
      'notes': 'Demo customer for testing',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _printDemoAccounts() {
    if (kDebugMode) {
      print('\n📧 Demo Accounts Created:');
      for (final user in demoUsers) {
        print(
            '- ${user['displayName']}: ${user['email']} / ${user['password']}');
      }
    }
  }
}

// Function to call from anywhere in the app
Future<void> createDemoAccounts() async {
  final creator = DemoAccountCreator();
  await creator.createDemoAccounts();
}

// Legacy main function for running as standalone script
Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await createDemoAccounts();
}
