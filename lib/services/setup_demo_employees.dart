import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import '../models/employee.dart' as emp;
import '../utils/demo_constants.dart';

class SetupDemoEmployees {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setupAllDemoEmployees() async {
    // debugPrint('ðŸš€ Setting up demo employees...');

    // Setup demo users in Auth
    await _setupAuthUsers();

    // Setup employee profiles in Firestore
    await _setupEmployeeProfiles();

    // debugPrint('âœ… Demo employees setup complete!');
  }

  Future<void> _setupAuthUsers() async {
    // debugPrint('ðŸ“§ Creating demo auth users...');

    final demoUsers = [
      {
        'email': DemoConstants.tailorEmail,
        'password': DemoConstants.demoPassword,
        'displayName': 'Demo Tailor',
        'role': UserRole.employee,
      },
      {
        'email': DemoConstants.cutterEmail,
        'password': DemoConstants.demoPassword,
        'displayName': 'Demo Cutter',
        'role': UserRole.employee,
      },
      {
        'email': DemoConstants.finisherEmail,
        'password': DemoConstants.demoPassword,
        'displayName': 'Demo Finisher',
        'role': UserRole.employee,
      },
      {
        'email': DemoConstants.helperEmail,
        'password': DemoConstants.demoPassword,
        'displayName': 'Helper',
        'role': UserRole.employee,
      },
    ];

    for (final userData in demoUsers) {
      try {
        // Check if user already exists
        final existingUsers = await _firestore
            .collection('users')
            .where('email', isEqualTo: userData['email'])
            .get();

        if (existingUsers.docs.isNotEmpty) {
          // debugPrint('âœ… User ${userData['email']} already exists');
          continue;
        }

        // Create user in Auth
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: userData['email'] as String,
          password: userData['password'] as String,
        );

        // Update display name
        await userCredential.user!
            .updateDisplayName(userData['displayName'] as String);

        // Create user profile in Firestore
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: userData['email'] as String,
          displayName: userData['displayName'] as String,
          role: userData['role'] as UserRole,
          isEmailVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());

        // debugPrint('âœ… Created user: ${userData['email']}');

        // Sign out to avoid conflicts
        await _auth.signOut();
      } catch (e) {
        // debugPrint('âŒ Error creating user ${userData['email']}: $e');
      }
    }
  }

  Future<void> _setupEmployeeProfiles() async {
    // debugPrint('ðŸ‘· Setting up employee profiles...');

    final employeeProfiles = [
      {
        'email': DemoConstants.tailorEmail,
        'skills': [
          emp.EmployeeSkill.stitching,
          emp.EmployeeSkill.alterations,
          emp.EmployeeSkill.embroidery
        ],
        'displayName': 'Demo Tailor',
        'experienceYears': 8,
        'hourlyRate': 25.0,
        'availability': emp.EmployeeAvailability.fullTime,
      },
      {
        'email': DemoConstants.cutterEmail,
        'skills': [emp.EmployeeSkill.cutting, emp.EmployeeSkill.patternMaking],
        'displayName': 'Demo Cutter',
        'experienceYears': 5,
        'hourlyRate': 18.0,
        'availability': emp.EmployeeAvailability.fullTime,
      },
      {
        'email': DemoConstants.finisherEmail,
        'skills': [emp.EmployeeSkill.finishing, emp.EmployeeSkill.qualityCheck],
        'displayName': 'Demo Finisher',
        'experienceYears': 4,
        'hourlyRate': 16.0,
        'availability': emp.EmployeeAvailability.partTime,
      },
      {
        'email': DemoConstants.helperEmail,
        'skills': [emp.EmployeeSkill.stitching, emp.EmployeeSkill.finishing],
        'displayName': 'Helper',
        'experienceYears': 2,
        'hourlyRate': 12.0,
        'availability': emp.EmployeeAvailability.fullTime,
      },
    ];

    for (final profile in employeeProfiles) {
      try {
        // Get user from Firestore
        final userDoc = await _firestore
            .collection('users')
            .where('email', isEqualTo: profile['email'])
            .get();

        if (userDoc.docs.isEmpty) {
          // debugPrint('âŒ User not found: ${profile['email']}');
          continue;
        }

        final userId = userDoc.docs.first.id;

        // Check if employee profile already exists
        final existingEmployee = await _firestore
            .collection('employees')
            .where('userId', isEqualTo: userId)
            .get();

        if (existingEmployee.docs.isNotEmpty) {
          // debugPrint('âœ… Employee profile already exists: ${profile['email']}');
          continue;
        }

        // Create employee profile
        final employee = emp.Employee(
          id: '',
          userId: userId,
          displayName: profile['displayName'] as String,
          email: profile['email'] as String,
          phoneNumber: '+1-555-0123',
          photoUrl: null,
          skills: profile['skills'] as List<emp.EmployeeSkill>,
          specializations: ['General tailoring', 'Alterations'],
          experienceYears: profile['experienceYears'] as int,
          certifications: ['Basic tailoring certification'],
          availability: profile['availability'] as emp.EmployeeAvailability,
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
          totalOrdersCompleted: (profile['experienceYears'] as int) *
              50, // Estimate based on experience
          ordersInProgress: 0,
          averageRating: 4.5,
          completionRate: 0.95,
          strengths: ['Reliable', 'Good communication', 'Quality focused'],
          areasForImprovement: ['Could improve speed'],
          baseRatePerHour: profile['hourlyRate'] as double,
          performanceBonusRate: (profile['hourlyRate'] as double) * 0.1,
          paymentTerms: 'Bi-weekly',
          totalEarnings: (profile['experienceYears'] as int) *
              50 *
              (profile['hourlyRate'] as double) *
              8, // Estimate
          recentAssignments: [],
          consecutiveDaysWorked: 5,
          isActive: true,
          joinedDate: DateTime.now().subtract(
              Duration(days: (profile['experienceYears'] as int) * 365)),
          additionalInfo: {
            'demo_account': true,
            'special_notes': 'Demo account for testing employee features',
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final employeeData = employee.toJson();
        employeeData.remove('id');

        await _firestore.collection('employees').add(employeeData);

        // debugPrint('âœ… Created employee profile: ${profile['email']}');
      } catch (e) {
        // debugPrint('âŒ Error creating employee profile ${profile['email']}: $e');
      }
    }
  }

  // Method to clean up demo employees (for testing)
  Future<void> cleanupDemoEmployees() async {
    // debugPrint('ðŸ§¹ Cleaning up demo employees...');

    try {
      // Delete from employees collection
      final employeeDocs = await _firestore.collection('employees').get();
      for (final doc in employeeDocs.docs) {
        final data = doc.data();
        if (data['additionalInfo']?['demo_account'] == true) {
          await doc.reference.delete();
          // debugPrint('âœ… Deleted employee: ${data['email']}');
        }
      }

      // Delete from users collection
      final userDocs = await _firestore.collection('users').get();
      for (final doc in userDocs.docs) {
        final data = doc.data();
        if (AuthService.demoAccounts
                .containsKey(data['role']?.toString().split('.').last) &&
            data['email']?.contains('@demo.com') == true) {
          await doc.reference.delete();
          // debugPrint('âœ… Deleted user: ${data['email']}');
        }
      }

      // debugPrint('âœ… Demo employees cleanup complete!');
    } catch (e) {
      // debugPrint('âŒ Error during cleanup: $e');
    }
  }
}

// Helper function to setup demo employees (can be called from main)
Future<void> setupDemoEmployees() async {
  try {
    debugPrint('ðŸš€ Starting demo employee setup...');
    final setup = SetupDemoEmployees();
    await setup.setupAllDemoEmployees();
    debugPrint('âœ… Demo employee setup completed successfully');
  } catch (e) {
    debugPrint('âŒ Demo employee setup failed: $e');
    // Don't throw error to prevent app from crashing
    // The employee screen will handle missing data gracefully
  }
}


