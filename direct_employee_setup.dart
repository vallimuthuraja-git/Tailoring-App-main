import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DirectEmployeeSetup {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setupBasicEmployees() async {
    try {
      if (kDebugMode) print('🚀 Setting up basic demo employees...');

      // Basic employee data
      final employees = [
        {
          'id': 'emp_demo_1',
          'userId': 'demo_user_1',
          'displayName': 'Rajesh Kumar',
          'email': 'rajesh@tailor.com',
          'phoneNumber': '+91-9876543211',
          'skills': [0, 1, 2, 3], // Stitching, alterations, cutting, finishing
          'specializations': ['Formal Wear', 'Alterations and Fittings'],
          'experienceYears': 8,
          'certifications': ['Master Tailor Certification'],
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
          'location': 'Main Workshop',
          'totalOrdersCompleted': 245,
          'ordersInProgress': 2,
          'averageRating': 4.7,
          'completionRate': 0.96,
          'strengths': ['Exceptional craftsmanship', 'Attention to detail'],
          'areasForImprovement': ['Could improve time management'],
          'baseRatePerHour': 100.0,
          'performanceBonusRate': 15.0,
          'paymentTerms': 'Monthly',
          'totalEarnings': 78400.0,
          'recentAssignments': [],
          'consecutiveDaysWorked': 15,
          'isActive': true,
          'joinedDate': Timestamp.fromDate(DateTime(2023, 3, 15)),
          'additionalInfo': {'demo_account': true},
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'id': 'emp_demo_2',
          'userId': 'demo_user_2',
          'displayName': 'Priya Sharma',
          'email': 'priya@designer.com',
          'phoneNumber': '+91-9876543212',
          'skills': [1, 2, 4], // alterations, cutting, patternMaking
          'specializations': ['Wedding Wear', 'Traditional Indian Wear'],
          'experienceYears': 12,
          'certifications': ['Fashion Design Diploma'],
          'availability': 1, // partTime
          'preferredWorkDays': ['Wednesday', 'Friday', 'Saturday'],
          'preferredStartTime': {'hour': 9, 'minute': 0},
          'preferredEndTime': {'hour': 16, 'minute': 0},
          'canWorkRemotely': true,
          'location': 'Design Studio',
          'totalOrdersCompleted': 189,
          'ordersInProgress': 1,
          'averageRating': 4.8,
          'completionRate': 0.98,
          'strengths': ['Creative design thinking', 'Client communication'],
          'areasForImprovement': ['Should delegate more'],
          'baseRatePerHour': 120.0,
          'performanceBonusRate': 20.0,
          'paymentTerms': 'Monthly',
          'totalEarnings': 91200.0,
          'recentAssignments': [],
          'consecutiveDaysWorked': 8,
          'isActive': true,
          'joinedDate': Timestamp.fromDate(DateTime(2022, 11, 20)),
          'additionalInfo': {'demo_account': true},
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'id': 'emp_demo_3',
          'userId': 'demo_user_3',
          'displayName': 'Amit Patel',
          'email': 'amit@cutter.com',
          'phoneNumber': '+91-9876543213',
          'skills': [2, 3, 4], // cutting, finishing, patternMaking
          'specializations': ['Fabric Cutting', 'Material Optimization'],
          'experienceYears': 6,
          'certifications': ['Precision Cutting Specialist'],
          'availability': 0, // fullTime
          'preferredWorkDays': ['Tuesday', 'Wednesday', 'Thursday', 'Saturday'],
          'preferredStartTime': {'hour': 10, 'minute': 0},
          'preferredEndTime': {'hour': 18, 'minute': 0},
          'canWorkRemotely': false,
          'location': 'Cutting Department',
          'totalOrdersCompleted': 156,
          'ordersInProgress': 3,
          'averageRating': 4.6,
          'completionRate': 0.94,
          'strengths': ['Precision work', 'Fast execution'],
          'areasForImprovement': ['Needs to reduce waste'],
          'baseRatePerHour': 85.0,
          'performanceBonusRate': 12.0,
          'paymentTerms': 'Monthly',
          'totalEarnings': 52800.0,
          'recentAssignments': [],
          'consecutiveDaysWorked': 22,
          'isActive': true,
          'joinedDate': Timestamp.fromDate(DateTime(2024, 1, 10)),
          'additionalInfo': {'demo_account': true},
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        }
      ];

      // Check if employees already exist
      final existingEmployees = await _firestore.collection('employees').get();
      if (existingEmployees.docs.isNotEmpty) {
        if (kDebugMode) {
          print(
              '✅ Demo employees already exist (${existingEmployees.docs.length} found)');
        }
        return;
      }

      // Add each employee
      for (final employee in employees) {
        await _firestore.collection('employees').add(employee);
        if (kDebugMode) print('✅ Added employee: ${employee['displayName']}');
      }

      if (kDebugMode) print('✅ Successfully added 3 demo employees!');
    } catch (e) {
      if (kDebugMode) print('❌ Error setting up employees: $e');
      rethrow;
    }
  }
}

// Function to call from anywhere in the app
Future<void> setupEmployeesDirectly() async {
  final setup = DirectEmployeeSetup();
  await setup.setupBasicEmployees();
  if (kDebugMode) print('✅ Direct employee setup completed successfully');
}
