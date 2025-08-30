# Demo Employees Setup Service Documentation

## Overview
The `setup_demo_employees.dart` file contains the comprehensive demo data generation service for the AI-Enabled Tailoring Shop Management System. It provides automated creation of realistic employee accounts, profiles, and associated data for development, testing, and demonstration purposes.

## Architecture

### Core Components
- **`SetupDemoEmployees`**: Main demo setup service class
- **Authentication Integration**: Firebase Auth account creation
- **Employee Profile Generation**: Firestore employee data creation
- **Skill-Based Data**: Realistic employee skills and specializations
- **Cleanup Functionality**: Demo data removal utilities

### Key Features
- **Multi-Role Employee Creation**: 4 different employee types with appropriate skills
- **Realistic Data Generation**: Experience-based performance metrics
- **Skill Distribution**: Proper skill assignment for different roles
- **Data Relationships**: Proper linking between Auth users and Firestore profiles
- **Cleanup Tools**: Safe removal of demo data
- **Error Handling**: Robust error handling and conflict resolution

## SetupDemoEmployees Class

### Core Properties
```dart
class SetupDemoEmployees {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
}
```

### Main Setup Method
```dart
Future<void> setupAllDemoEmployees() async {
  // Step 1: Setup demo users in Firebase Auth
  await _setupAuthUsers();

  // Step 2: Setup employee profiles in Firestore
  await _setupEmployeeProfiles();
}
```

## Authentication Setup

### Demo User Creation
```dart
Future<void> _setupAuthUsers() async {
  final demoUsers = [
    {
      'email': 'employee@demo.com',
      'password': 'password123',
      'displayName': 'Demo Employee',
      'role': UserRole.employee,
    },
    {
      'email': 'tailor@demo.com',
      'password': 'password123',
      'displayName': 'Demo Tailor',
      'role': UserRole.tailor,
    },
    {
      'email': 'cutter@demo.com',
      'password': 'password123',
      'displayName': 'Demo Cutter',
      'role': UserRole.cutter,
    },
    {
      'email': 'finisher@demo.com',
      'password': 'password123',
      'displayName': 'Demo Finisher',
      'role': UserRole.finisher,
    },
  ];
}
```

### User Creation Process
```dart
for (final userData in demoUsers) {
  // 1. Check if user already exists
  final existingUsers = await _firestore
      .collection('users')
      .where('email', isEqualTo: userData['email'])
      .get();

  if (existingUsers.docs.isNotEmpty) {
    continue; // Skip if already exists
  }

  // 2. Create Firebase Auth account
  final userCredential = await _auth.createUserWithEmailAndPassword(
    email: userData['email'] as String,
    password: userData['password'] as String,
  );

  // 3. Update display name
  await userCredential.user!.updateDisplayName(userData['displayName'] as String);

  // 4. Create Firestore user profile
  final userModel = UserModel(
    id: userCredential.user!.uid,
    email: userData['email'] as String,
    displayName: userData['displayName'] as String,
    role: userData['role'] as UserRole,
    isEmailVerified: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  await _firestore.collection('users').doc(userCredential.user!.uid).set(userModel.toJson());
}
```

## Employee Profile Setup

### Demo Employee Profiles
```dart
final employeeProfiles = [
  {
    'email': 'employee@demo.com',
    'skills': [EmployeeSkill.stitching, EmployeeSkill.finishing],
    'displayName': 'Demo Employee',
    'experienceYears': 3,
    'hourlyRate': 15.0,
    'availability': EmployeeAvailability.fullTime,
  },
  {
    'email': 'tailor@demo.com',
    'skills': [EmployeeSkill.stitching, EmployeeSkill.alterations, EmployeeSkill.embroidery],
    'displayName': 'Demo Tailor',
    'experienceYears': 8,
    'hourlyRate': 25.0,
    'availability': EmployeeAvailability.fullTime,
  },
  {
    'email': 'cutter@demo.com',
    'skills': [EmployeeSkill.cutting, EmployeeSkill.patternMaking],
    'displayName': 'Demo Cutter',
    'experienceYears': 5,
    'hourlyRate': 18.0,
    'availability': EmployeeAvailability.fullTime,
  },
  {
    'email': 'finisher@demo.com',
    'skills': [EmployeeSkill.finishing, EmployeeSkill.qualityCheck],
    'displayName': 'Demo Finisher',
    'experienceYears': 4,
    'hourlyRate': 16.0,
    'availability': EmployeeAvailability.partTime,
  },
];
```

### Profile Creation Process
```dart
for (final profile in employeeProfiles) {
  // 1. Get user from Firestore
  final userDoc = await _firestore
      .collection('users')
      .where('email', isEqualTo: profile['email'])
      .get();

  final userId = userDoc.docs.first.id;

  // 2. Check if employee profile already exists
  final existingEmployee = await _firestore
      .collection('employees')
      .where('userId', isEqualTo: userId)
      .get();

  if (existingEmployee.docs.isNotEmpty) {
    continue; // Skip if already exists
  }

  // 3. Create comprehensive employee profile
  final employee = Employee(
    id: '',
    userId: userId,
    displayName: profile['displayName'] as String,
    email: profile['email'] as String,
    phoneNumber: '+1-555-0123',
    skills: profile['skills'] as List<EmployeeSkill>,
    specializations: ['General tailoring', 'Alterations'],
    experienceYears: profile['experienceYears'] as int,
    certifications: ['Basic tailoring certification'],
    availability: profile['availability'] as EmployeeAvailability,
    preferredWorkDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    preferredStartTime: const TimeOfDay(hour: 9, minute: 0),
    preferredEndTime: const TimeOfDay(hour: 17, minute: 0),
    canWorkRemotely: false,
    location: 'Main Workshop',
    // Calculated fields based on experience
    totalOrdersCompleted: (profile['experienceYears'] as int) * 50,
    averageRating: 4.5,
    completionRate: 0.95,
    baseRatePerHour: profile['hourlyRate'] as double,
    performanceBonusRate: (profile['hourlyRate'] as double) * 0.1,
    totalEarnings: (profile['experienceYears'] as int) * 50 * (profile['hourlyRate'] as double) * 8,
    consecutiveDaysWorked: 5,
    isActive: true,
    joinedDate: DateTime.now().subtract(Duration(days: (profile['experienceYears'] as int) * 365)),
    additionalInfo: {
      'demo_account': true,
      'special_notes': 'Demo account for testing employee features',
    },
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // 4. Save to Firestore
  final employeeData = employee.toJson();
  employeeData.remove('id'); // Let Firestore generate ID

  await _firestore.collection('employees').add(employeeData);
}
```

## Demo Employee Types

### 1. General Employee
```dart
{
  'email': 'employee@demo.com',
  'skills': [EmployeeSkill.stitching, EmployeeSkill.finishing],
  'displayName': 'Demo Employee',
  'experienceYears': 3,
  'hourlyRate': 15.0,
  'availability': EmployeeAvailability.fullTime,
}
```
- **Skills**: Basic stitching and finishing
- **Experience**: 3 years (mid-level)
- **Rate**: $15/hour (standard employee rate)
- **Orders**: ~150 completed (50 * 3 years)
- **Earnings**: ~$36,000 total (estimated)

### 2. Master Tailor
```dart
{
  'email': 'tailor@demo.com',
  'skills': [EmployeeSkill.stitching, EmployeeSkill.alterations, EmployeeSkill.embroidery],
  'displayName': 'Demo Tailor',
  'experienceYears': 8,
  'hourlyRate': 25.0,
  'availability': EmployeeAvailability.fullTime,
}
```
- **Skills**: Advanced stitching, alterations, embroidery
- **Experience**: 8 years (senior level)
- **Rate**: $25/hour (premium rate)
- **Orders**: ~400 completed (50 * 8 years)
- **Earnings**: ~$160,000 total (estimated)

### 3. Fabric Cutter
```dart
{
  'email': 'cutter@demo.com',
  'skills': [EmployeeSkill.cutting, EmployeeSkill.patternMaking],
  'displayName': 'Demo Cutter',
  'experienceYears': 5,
  'hourlyRate': 18.0,
  'availability': EmployeeAvailability.fullTime,
}
```
- **Skills**: Precision cutting, pattern making
- **Experience**: 5 years (experienced)
- **Rate**: $18/hour (skilled trade rate)
- **Orders**: ~250 completed (50 * 5 years)
- **Earnings**: ~$72,000 total (estimated)

### 4. Quality Finisher
```dart
{
  'email': 'finisher@demo.com',
  'skills': [EmployeeSkill.finishing, EmployeeSkill.qualityCheck],
  'displayName': 'Demo Finisher',
  'experienceYears': 4,
  'hourlyRate': 16.0,
  'availability': EmployeeAvailability.partTime,
}
```
- **Skills**: Quality finishing, inspection
- **Experience**: 4 years (experienced)
- **Rate**: $16/hour (standard rate)
- **Availability**: Part-time (4 hours/day)
- **Orders**: ~200 completed (50 * 4 years)
- **Earnings**: ~$25,600 total (estimated)

## Cleanup Functionality

### Demo Data Removal
```dart
Future<void> cleanupDemoEmployees() async {
  // 1. Delete from employees collection
  final employeeDocs = await _firestore.collection('employees').get();
  for (final doc in employeeDocs.docs) {
    final data = doc.data();
    if (data['additionalInfo']?['demo_account'] == true) {
      await doc.reference.delete();
    }
  }

  // 2. Delete from users collection
  final userDocs = await _firestore.collection('users').get();
  for (final doc in userDocs.docs) {
    final data = doc.data();
    if (AuthService.demoAccounts.containsKey(data['role']?.toString().split('.').last) &&
        data['email']?.contains('@demo.com') == true) {
      await doc.reference.delete();
    }
  }
}
```

## Integration Points

### Related Components
- **Auth Service**: User account creation and management
- **Employee Provider**: Employee data management and state
- **Firebase Service**: Database operations and connectivity
- **User Role Model**: Role-based access control
- **Employee Model**: Employee data structure

### Dependencies
- **Firebase Auth**: User authentication and account management
- **Cloud Firestore**: Employee profile and user data storage
- **Flutter Foundation**: Development utilities and debugging
- **Employee Model**: Employee data structure and skills

## Usage Examples

### Development Setup
```dart
class DevelopmentSetup {
  final SetupDemoEmployees _demoSetup = SetupDemoEmployees();

  Future<void> initializeDemoData() async {
    try {
      debugPrint('🚀 Setting up demo environment...');

      // Setup demo employees
      await _demoSetup.setupAllDemoEmployees();

      // Setup demo orders (if available)
      // await _demoOrders.setupDemoOrders();

      debugPrint('✅ Demo environment ready!');
    } catch (e) {
      debugPrint('❌ Demo setup failed: $e');
    }
  }

  Future<void> resetDemoData() async {
    try {
      debugPrint('🧹 Resetting demo data...');

      // Cleanup existing demo data
      await _demoSetup.cleanupDemoEmployees();

      // Re-setup fresh demo data
      await initializeDemoData();

      debugPrint('✅ Demo data reset complete!');
    } catch (e) {
      debugPrint('❌ Demo reset failed: $e');
    }
  }
}
```

### Testing Integration
```dart
class EmployeeProviderTests {
  final SetupDemoEmployees _demoSetup = SetupDemoEmployees();

  Future<void> runEmployeeTests() async {
    try {
      // Setup test data
      await _demoSetup.setupAllDemoEmployees();

      // Test employee loading
      final employeeProvider = EmployeeProvider();
      await employeeProvider.loadEmployees();

      // Verify demo employees exist
      final employees = employeeProvider.employees;
      assert(employees.length >= 4, 'Demo employees not created');

      // Test specific employee types
      final tailors = employees.where((e) => e.skills.contains(EmployeeSkill.stitching));
      assert(tailors.isNotEmpty, 'No tailors found');

      // Cleanup test data
      await _demoSetup.cleanupDemoEmployees();

      debugPrint('✅ Employee tests passed!');
    } catch (e) {
      debugPrint('❌ Employee tests failed: $e');
    }
  }
}
```

### Quick Demo Setup
```dart
class DemoButton extends StatelessWidget {
  final SetupDemoEmployees _demoSetup = SetupDemoEmployees();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await _demoSetup.setupAllDemoEmployees();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Demo employees created!')),
            );
          },
          child: Text('Create Demo Employees'),
        ),
        ElevatedButton(
          onPressed: () async {
            await _demoSetup.cleanupDemoEmployees();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Demo employees cleaned up!')),
            );
          },
          child: Text('Cleanup Demo Data'),
        ),
      ],
    );
  }
}
```

## Security Considerations

### Demo Account Security
- **Weak Passwords**: Demo accounts use simple passwords for easy access
- **Limited Permissions**: Demo accounts have appropriate role-based restrictions
- **Development Only**: Demo accounts should only exist in development environments
- **Clear Identification**: Demo accounts are clearly marked for easy identification

### Data Privacy
- **Test Data**: All demo data is clearly marked as test/demo data
- **Easy Cleanup**: Demo data can be completely removed when needed
- **No Real Data**: Demo data doesn't contain real customer or personal information
- **Development Isolation**: Demo setup should be isolated from production environments

## Performance Optimization

### Efficient Setup
- **Batch Operations**: Multiple accounts created efficiently
- **Duplicate Prevention**: Checks for existing accounts before creation
- **Minimal Data**: Only essential demo data is created
- **Cleanup Tools**: Efficient removal of demo data

### Memory Management
- **Scoped Operations**: Operations are contained within methods
- **Resource Cleanup**: Proper cleanup of Firebase resources
- **Error Recovery**: Robust error handling prevents memory leaks
- **Async Operations**: Non-blocking operations for smooth UX

## Business Logic

### Realistic Employee Data
- **Experience-Based Metrics**: Performance data based on years of experience
- **Skill-Appropriate Roles**: Skills match job roles and responsibilities
- **Market Rate Pricing**: Competitive hourly rates based on experience and skills
- **Workload Distribution**: Realistic order completion numbers
- **Performance Ratings**: Credible rating and completion rate data

### Role-Specific Profiles
- **Tailor**: High experience, advanced skills, premium pricing
- **Cutter**: Specialized cutting skills, pattern making expertise
- **Finisher**: Quality focus, finishing skills, part-time availability
- **General Employee**: Broad skills, moderate experience, standard pricing

### Demo Data Relationships
- **Auth Integration**: Proper Firebase Auth account creation
- **Profile Linking**: Correct linking between auth users and employee profiles
- **Role Consistency**: User roles match employee skills and responsibilities
- **Data Integrity**: Consistent data across all related collections

This comprehensive demo employee setup service provides developers and testers with realistic, role-specific employee data that accurately represents a tailoring shop's workforce, enabling comprehensive testing of all employee-related features and workflows.