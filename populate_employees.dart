import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firestore = FirebaseFirestore.instance;

    // Create demo employee data
    final demoEmployees = [
      {
        'id': 'demo_owner',
        'userId': 'demo_user_owner',
        'displayName': 'Esther',
        'email': 'shop@demo.com',
        'phoneNumber': '+91-9876543210',
        'role': 'shopOwner',
        'skills': ['cutting', 'stitching', 'alterations'],
        'specializations': ['Shop Management', 'Quality Assurance', 'Customer Service', 'Business Operations'],
        'experienceYears': 8,
        'certifications': ['Certified Master Tailor'],
        'availability': 'fullTime',
        'preferredWorkDays': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        'preferredStartTime': {'hour': 9, 'minute': 0},
        'preferredEndTime': {'hour': 18, 'minute': 0},
        'canWorkRemotely': false,
        'location': 'Main Shop',
        'totalOrdersCompleted': 450,
        'ordersInProgress': 0,
        'averageRating': 4.8,
        'completionRate': 0.98,
        'strengths': ['Leadership', 'Quality Control', 'Customer Relations', 'Business Planning'],
        'areasForImprovement': ['Could delegate more', 'Should reduce work hours'],
        'baseRatePerHour': 150.0,
        'performanceBonusRate': 25.0,
        'paymentTerms': 'Monthly',
        'totalEarnings': 96000.0,
        'recentAssignments': [],
        'consecutiveDaysWorked': 0,
        'isActive': true,
        'joinedDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2190))), // 6 years ago
        'additionalInfo': {
          'ownershipPercentage': 100,
          'businessPhone': '+91-9876543210',
          'emergencyContact': 'Sister: +91-8765432109'
        },
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'id': 'demo_emp_1',
        'userId': 'demo_user_1',
        'displayName': 'Rajesh Kumar',
        'email': 'rajesh@tailor.com',
        'phoneNumber': '+91-9876543211',
        'role': 'employee',
        'skills': ['stitching', 'alterations', 'measurements', 'qualityCheck'],
        'specializations': ['Formal Wear', 'Suit Customization', 'Alterations and Fittings'],
        'experienceYears': 12,
        'certifications': ['Master Tailor Certification', 'Advanced Sewing Techniques'],
        'availability': 'fullTime',
        'preferredWorkDays': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        'preferredStartTime': {'hour': 8, 'minute': 30},
        'preferredEndTime': {'hour': 17, 'minute': 30},
        'canWorkRemotely': false,
        'location': 'Main Workshop',
        'totalOrdersCompleted': 650,
        'ordersInProgress': 3,
        'averageRating': 4.9,
        'completionRate': 0.97,
        'strengths': ['Exceptional craftsmanship', 'Attention to detail', 'Reliability', 'Fast learning curve'],
        'areasForImprovement': ['Should improve time management', 'Could enhance pattern making skills'],
        'baseRatePerHour': 100.0,
        'performanceBonusRate': 15.0,
        'paymentTerms': 'Monthly',
        'totalEarnings': 78000.0,
        'recentAssignments': [],
        'consecutiveDaysWorked': 15,
        'isActive': true,
        'joinedDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1500))), // 4+ years ago
        'additionalInfo': {
          'homeAddress': 'Andheri West, Mumbai',
          'preferredMaterials': ['Cotton', 'Wool', 'Linen'],
          'languages': ['Hindi', 'English', 'Marathi']
        },
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'id': 'demo_emp_2',
        'userId': 'demo_user_2',
        'displayName': 'Priya Sharma',
        'email': 'priya@designer.com',
        'phoneNumber': '+91-9876543212',
        'role': 'employee',
        'skills': ['designing', 'patternMaking', 'consultation'],
        'specializations': ['Wedding Wear', 'Traditional Indian Wear', 'Saree Customization', 'Fashion Design'],
        'experienceYears': 15,
        'certifications': ['Fashion Design Diploma', 'Master Designer Certificate'],
        'availability': 'partTime',
        'preferredWorkDays': ['Monday', 'Wednesday', 'Friday', 'Saturday'],
        'preferredStartTime': {'hour': 9, 'minute': 0},
        'preferredEndTime': {'hour': 16, 'minute': 0},
        'canWorkRemotely': true,
        'location': 'Design Studio',
        'totalOrdersCompleted': 320,
        'ordersInProgress': 2,
        'averageRating': 4.7,
        'completionRate': 0.95,
        'strengths': ['Creative design thinking', 'Excellent client communication', 'Material knowledge'],
        'areasForImprovement': ['Should work on deadline management', 'Could improve technical precision'],
        'baseRatePerHour': 120.0,
        'performanceBonusRate': 20.0,
        'paymentTerms': 'Monthly',
        'totalEarnings': 72000.0,
        'recentAssignments': [],
        'consecutiveDaysWorked': 10,
        'isActive': true,
        'joinedDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1800))), // 5 years ago
        'additionalInfo': {
          'designhouse': 'Priya Designs',
          'designStyle': 'Bespoke Indian Fashion',
          'featuredWork': 'Featured in local fashion magazines'
        },
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      }
    ];

    print('🚀 Populating demo employees...');

    for (final employee in demoEmployees) {
      try {
        final docRef = await firestore.collection('employees').add(employee);
        print('✅ Added employee: ${employee['displayName']} (ID: ${docRef.id})');
      } catch (e) {
        print('❌ Failed to add employee ${employee['displayName']}: $e');
      }
    }

    print('✅ Demo employee population completed!');

    // Also create some demo user documents
    final demoUsers = [
      {
        'id': 'demo_user_owner',
        'email': 'shop@demo.com',
        'displayName': 'Esther',
        'role': 'shopOwner',
        'isEmailVerified': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'id': 'demo_user_1',
        'email': 'rajesh@tailor.com',
        'displayName': 'Rajesh Kumar',
        'role': 'employee',
        'isEmailVerified': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      }
    ];

    print('📧 Creating demo users...');

    for (final user in demoUsers) {
      try {
        final docRef = await firestore.collection('users').add(user);
        print('✅ Added user: ${user['displayName']} (ID: ${docRef.id})');
      } catch (e) {
        print('❌ Failed to add user ${user['displayName']}: $e');
      }
    }

    print('✅ All demo data populated successfully!');

  } catch (e) {
    print('❌ Error: $e');
  }
}
