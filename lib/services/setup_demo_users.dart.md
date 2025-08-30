# Setup Demo Users Service Documentation

## Overview
The `setup_demo_users.dart` file contains the comprehensive demo user management system for the AI-Enabled Tailoring Shop Management System. It provides automated creation and management of demonstration user accounts, ensuring consistent testing environments and seamless user onboarding experiences without requiring manual account creation.

## Architecture

### Core Components
- **`SetupDemoUsers`**: Main service handling demo user creation and management
- **Firebase Auth Integration**: User account creation and authentication
- **Firestore Integration**: User profile storage and management
- **Duplicate Handling**: Intelligent management of existing accounts
- **Role-Based Setup**: Specialized user creation for different system roles
- **Initialization Control**: Conditional setup based on existing data

### Key Features
- **Automated Setup**: One-click demo environment creation
- **Conflict Resolution**: Handles existing accounts gracefully
- **Role Assignment**: Creates users with appropriate system roles
- **Profile Management**: Ensures complete user profiles in Firestore
- **Verification Logic**: Checks for existing users before creation
- **Error Resilience**: Robust error handling for network and authentication issues

## Demo User Configuration

### Demo User Accounts
The service creates two primary demo accounts:

#### Customer Account
```dart
await _createDemoUser(
  email: 'customer@demo.com',
  password: 'password123',
  displayName: 'Demo Customer',
  role: UserRole.customer,
);
```

#### Shop Owner Account
```dart
await _createDemoUser(
  email: 'shop@demo.com',
  password: 'password123',
  displayName: 'Demo Shop Owner',
  role: UserRole.shopOwner,
);
```

### User Credentials
- **Username**: Consistent demo email addresses
- **Password**: Standardized `password123` for easy access
- **Display Names**: Descriptive names for user identification
- **Roles**: Pre-assigned roles based on user type

## Firebase Integration

### Authentication Setup
```dart
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
```

### User Creation Process
```dart
Future<void> _createDemoUser({
  required String email,
  required String password,
  required String displayName,
  required UserRole role,
}) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name
    await userCredential.user!.updateDisplayName(displayName);

    // Create Firestore profile
    final userModel = UserModel(
      id: userCredential.user!.uid,
      email: email,
      displayName: displayName,
      role: role,
      isEmailVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .set(userModel.toJson());

  } catch (e) {
    if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
      await _ensureUserProfileExists(email, displayName, role);
    } else {
      rethrow;
    }
  }
}
```

## Conflict Resolution

### Existing User Handling
```dart
catch (e) {
  if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
    // User exists in Auth, ensure profile exists in Firestore
    await _ensureUserProfileExists(email, displayName, role);
    return;
  }
}
```

### Profile Synchronization
```dart
Future<void> _ensureUserProfileExists(String email, String displayName, UserRole role) async {
  try {
    // Sign in to existing account
    final user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: 'password123'
    );

    // Check Firestore profile
    final existingProfile = await _firestore
        .collection('users')
        .doc(user.user!.uid)
        .get();

    if (!existingProfile.exists) {
      // Create missing profile
      final userModel = UserModel(
        id: user.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        isEmailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.user!.uid)
          .set(userModel.toJson());
    }

    await _auth.signOut();
  } catch (e) {
    print('Error ensuring user profile exists: $e');
  }
}
```

## User Existence Verification

### Authentication Check
```dart
Future<bool> _userExistsInAuth(String email) async {
  try {
    // Attempt to create user with temporary password
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: 'temp_password_123',
    );

    // User didn't exist, clean up temporary account
    await _auth.currentUser?.delete();
    return false;

  } catch (e) {
    if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
      return true; // User exists
    }
    return false;
  }
}
```

### Comprehensive Existence Check
```dart
Future<bool> demoUsersExist() async {
  try {
    bool customerExists = await _userExistsInAuth('customer@demo.com');
    bool shopExists = await _userExistsInAuth('shop@demo.com');

    return customerExists && shopExists;
  } catch (e) {
    print('Error checking demo users: $e');
    return false;
  }
}
```

## User Profile Management

### Profile Retrieval
```dart
Future<Map<String, dynamic>?> getDemoUserInfo(String email) async {
  try {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
    }
    return null;
  } catch (e) {
    print('Error getting demo user info: $e');
    return null;
  }
}
```

### User Model Structure
```dart
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.toString(),
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

## Initialization Control

### Conditional Setup
```dart
Future<void> initializeDemoDataIfNeeded() async {
  try {
    final usersExist = await demoUsersExist();
    if (!usersExist) {
      print('Demo users not found, creating them...');
      await createDemoUsers();
    } else {
      print('Demo users already exist');
    }
  } catch (e) {
    print('Error initializing demo data: $e');
  }
}
```

### Global Setup Function
```dart
Future<void> setupDemoUsers() async {
  final setup = SetupDemoUsers();
  await setup.initializeDemoDataIfNeeded();
}
```

## Usage Examples

### Application Startup Integration
```dart
class AppInitializer {
  Future<void> initializeApp() async {
    // Initialize Firebase first
    await Firebase.initializeApp();

    // Setup demo users
    await setupDemoUsers();

    // Continue with app initialization
    runApp(MyApp());
  }
}
```

### Manual Demo Setup
```dart
class DemoSetupManager {
  final SetupDemoUsers _setupService = SetupDemoUsers();

  Future<void> forceRecreateDemoUsers() async {
    try {
      // Delete existing demo users if needed
      await _cleanupExistingDemoUsers();

      // Create fresh demo users
      await _setupService.createDemoUsers();

      print('Demo users recreated successfully');
    } catch (e) {
      print('Error recreating demo users: $e');
    }
  }

  Future<void> _cleanupExistingDemoUsers() async {
    // Implementation to clean up existing demo users
    // This might involve deleting from Firestore and Auth
  }
}
```

### User Authentication Testing
```dart
class AuthTestingUtils {
  final SetupDemoUsers _setupService = SetupDemoUsers();

  Future<void> testDemoUserLogin() async {
    try {
      // Ensure demo users exist
      await _setupService.initializeDemoDataIfNeeded();

      // Test customer login
      final customerInfo = await _setupService.getDemoUserInfo('customer@demo.com');
      if (customerInfo != null) {
        print('Customer account ready: ${customerInfo['displayName']}');
      }

      // Test shop owner login
      final shopInfo = await _setupService.getDemoUserInfo('shop@demo.com');
      if (shopInfo != null) {
        print('Shop owner account ready: ${shopInfo['displayName']}');
      }

    } catch (e) {
      print('Error testing demo user login: $e');
    }
  }
}
```

### Role-Based Access Testing
```dart
class RoleTestingManager {
  final SetupDemoUsers _setupService = SetupDemoUsers();

  Future<void> validateRoleAssignments() async {
    try {
      // Check customer role
      final customerInfo = await _setupService.getDemoUserInfo('customer@demo.com');
      if (customerInfo != null) {
        final customerRole = UserRole.values.firstWhere(
          (role) => role.toString() == customerInfo['role']
        );
        assert(customerRole == UserRole.customer, 'Customer role incorrect');
      }

      // Check shop owner role
      final shopInfo = await _setupService.getDemoUserInfo('shop@demo.com');
      if (shopInfo != null) {
        final shopRole = UserRole.values.firstWhere(
          (role) => role.toString() == shopInfo['role']
        );
        assert(shopRole == UserRole.shopOwner, 'Shop owner role incorrect');
      }

      print('All demo user roles validated successfully');

    } catch (e) {
      print('Error validating role assignments: $e');
    }
  }
}
```

### Development Environment Setup
```dart
class DevelopmentEnvironment {
  final SetupDemoUsers _setupService = SetupDemoUsers();

  Future<void> prepareDevelopmentEnvironment() async {
    try {
      print('🚀 Preparing development environment...');

      // Ensure demo users exist
      await _setupService.initializeDemoDataIfNeeded();

      // Create additional development users if needed
      await _createDevelopmentUsers();

      // Validate all users
      await _validateAllUsers();

      print('✅ Development environment ready!');

    } catch (e) {
      print('❌ Error preparing development environment: $e');
    }
  }

  Future<void> _createDevelopmentUsers() async {
    // Create additional users for development testing
    // e.g., managers, employees, etc.
  }

  Future<void> _validateAllUsers() async {
    final customerExists = await _setupService._userExistsInAuth('customer@demo.com');
    final shopExists = await _setupService._userExistsInAuth('shop@demo.com');

    if (!customerExists || !shopExists) {
      throw Exception('Required demo users missing');
    }
  }
}
```

### Integration with Authentication Flow
```dart
class AuthService {
  final SetupDemoUsers _demoSetup = SetupDemoUsers();

  Future<void> initialize() async {
    // Ensure demo users are available for testing
    await _demoSetup.initializeDemoDataIfNeeded();
  }

  Future<UserCredential?> signInWithDemoCredentials(UserRole role) async {
    try {
      final email = role == UserRole.customer ? 'customer@demo.com' : 'shop@demo.com';
      final password = 'password123';

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } catch (e) {
      print('Error signing in with demo credentials: $e');
      return null;
    }
  }
}
```

### User Onboarding Integration
```dart
class OnboardingManager {
  final SetupDemoUsers _demoSetup = SetupDemoUsers();

  Future<Map<String, String>> getDemoCredentials() async {
    await _demoSetup.initializeDemoDataIfNeeded();

    return {
      'customer_email': 'customer@demo.com',
      'customer_password': 'password123',
      'shop_email': 'shop@demo.com',
      'shop_password': 'password123',
    };
  }

  Future<void> demonstrateLoginFlow() async {
    final credentials = await getDemoCredentials();

    // Use these credentials to demonstrate login flow
    // This could be used in tutorials or onboarding screens
  }
}
```

## Security Considerations

### Password Management
- **Demo Passwords**: Use consistent, well-known passwords for demo accounts
- **No Production Use**: Demo accounts should not be used in production environments
- **Password Reset**: Provide easy password reset mechanisms for demo accounts

### Access Control
- **Role Verification**: Always verify user roles before granting access
- **Profile Validation**: Ensure user profiles are complete and valid
- **Session Management**: Properly handle authentication sessions

### Data Protection
- **Test Data**: Clearly mark demo data to distinguish from real user data
- **Cleanup Procedures**: Provide mechanisms to clean up demo data when needed
- **Privacy Compliance**: Ensure demo data doesn't contain real personal information

## Best Practices

### Development Workflow
- **Automatic Setup**: Integrate demo user creation into development startup
- **Consistent Testing**: Use the same demo accounts across all testing scenarios
- **Documentation**: Keep demo credentials documented for team members
- **Version Control**: Track demo user configurations in version control

### Production Deployment
- **Conditional Execution**: Only create demo users in development/testing environments
- **Environment Detection**: Use environment variables to control demo user creation
- **Cleanup Scripts**: Provide scripts to remove demo users from production

### Maintenance
- **Regular Updates**: Keep demo user profiles current with application changes
- **Password Rotation**: Regularly update demo passwords for security
- **Usage Monitoring**: Monitor demo account usage for testing purposes

This comprehensive demo user setup service ensures consistent, reliable access to demonstration accounts throughout the development and testing lifecycle of the tailoring shop management system, providing a seamless experience for developers, testers, and users exploring the application's capabilities.