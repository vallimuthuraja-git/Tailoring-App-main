# Authentication Service Documentation

## Overview
The `auth_service.dart` file contains the comprehensive authentication and user management system for the AI-Enabled Tailoring Shop Management System. It provides secure authentication using Firebase Auth, user profile management with Firestore, and supports multiple authentication methods including email/password and phone number verification.

## Architecture

### Core Components
- **`UserModel`**: User data structure with role-based access control
- **`AuthService`**: Main authentication service class
- **`UserRole`**: Comprehensive role enumeration for the tailoring business

### Authentication Methods
- **Email/Password Authentication**: Traditional email and password login
- **Phone Number Authentication**: SMS OTP verification
- **Password Reset**: Secure password recovery via email
- **Email Verification**: Account verification system
- **Profile Management**: User profile updates and management

## UserModel Class

### Properties
- **`id`**: Unique user identifier (Firebase Auth UID)
- **`email`**: User's email address
- **`displayName`**: User's display name
- **`phoneNumber`**: Optional phone number
- **`photoUrl`**: Optional profile photo URL
- **`role`**: User's role in the system (see UserRole enum)
- **`isEmailVerified`**: Email verification status
- **`createdAt`**: Account creation timestamp
- **`updatedAt`**: Last profile update timestamp

### User Roles
```dart
enum UserRole {
  customer,    // Regular customers
  shopOwner,   // Business owner with full access
  admin,       // System administrator
  employee,    // General employee
  tailor,      // Master tailor/couturier
  cutter,      // Fabric cutting specialist
  finisher,    // Final touches and quality control
  supervisor,  // Team supervisor/manager
  apprentice   // Training/new employee
}
```

### Serialization
- **`fromJson()`**: Creates UserModel from Firestore document
- **`toJson()`**: Converts UserModel to Firestore-compatible format
- **Timestamp Handling**: Proper date conversion between Dart and Firestore

## AuthService Class

### Core Properties
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user access
  User? get currentUser => _auth.currentUser;
}
```

### Authentication Methods

#### Email/Password Authentication
```dart
Future<UserCredential> signUpWithEmailAndPassword({
  required String email,
  required String password,
  String? displayName,
  String? phoneNumber,
  UserRole role = UserRole.customer,
})
```
- **Account Creation**: Creates new Firebase Auth account
- **Profile Setup**: Automatically creates Firestore user profile
- **Role Assignment**: Assigns appropriate user role
- **Display Name**: Updates Firebase Auth display name
- **Error Handling**: Comprehensive error management

```dart
Future<UserCredential> signInWithEmailAndPassword({
  required String email,
  required String password,
})
```
- **Secure Login**: Authenticates user credentials
- **Logging**: Debug logging for authentication attempts
- **Error Handling**: User-friendly error messages

#### Phone Number Authentication
```dart
Future<void> verifyPhoneNumber({
  required String phoneNumber,
  required Function(String verificationId) onCodeSent,
  required Function(String error) onError,
  required Function(UserCredential userCredential) onVerified,
})
```
- **SMS Verification**: Sends OTP to phone number
- **Auto-Verification**: Automatic verification on supported devices
- **Callback System**: Flexible callback handling for different states
- **Timeout Handling**: 60-second verification timeout

```dart
Future<UserCredential> verifyOTP({
  required String verificationId,
  required String smsCode,
})
```
- **OTP Validation**: Verifies SMS code against verification ID
- **Credential Creation**: Creates PhoneAuthCredential
- **User Authentication**: Signs in user with phone credential

```dart
Future<void> resendOTP({...})
```
- **OTP Resend**: Resends verification code
- **Rate Limiting**: Built-in rate limiting through Firebase
- **Error Handling**: Proper error callback handling

### Account Management

#### Password Operations
```dart
Future<void> sendPasswordResetEmail(String email)
```
- **Password Recovery**: Sends reset email to user
- **Security**: Firebase handles secure token generation
- **Email Templates**: Uses Firebase default email templates

```dart
Future<void> changePassword(String currentPassword, String newPassword)
```
- **Password Update**: Changes user password securely
- **Re-authentication**: Requires current password for security
- **Credential Validation**: Validates current credentials before update

#### Email Verification
```dart
Future<void> sendEmailVerification()
```
- **Verification Email**: Sends verification link to user email
- **Conditional Sending**: Only sends if email not already verified

```dart
Future<bool> isEmailVerified()
```
- **Verification Check**: Checks current email verification status
- **User Reload**: Refreshes user data from Firebase Auth

### Profile Management

#### Profile Operations
```dart
Future<void> updateUserProfile({
  String? displayName,
  String? phoneNumber,
  String? photoUrl,
})
```
- **Profile Updates**: Updates user profile information
- **Firebase Auth Sync**: Updates both Firebase Auth and Firestore
- **Selective Updates**: Only updates provided fields

```dart
Future<UserModel?> getUserProfile(String userId)
```
- **Profile Retrieval**: Gets user profile from Firestore
- **Data Mapping**: Converts Firestore data to UserModel
- **Error Handling**: Comprehensive error management

```dart
Stream<UserModel?> getUserProfileStream(String userId)
```
- **Real-time Updates**: Streams profile changes from Firestore
- **Automatic Mapping**: Converts document snapshots to UserModel
- **Null Safety**: Handles non-existent documents

#### Account Operations
```dart
Future<void> deleteAccount()
```
- **Account Deletion**: Removes user account and profile
- **Data Cleanup**: Deletes Firestore profile before Auth account
- **Security**: Requires authentication to delete account

```dart
Future<void> signOut()
```
- **Session Termination**: Signs out current user
- **State Management**: Updates authentication state

## Firebase Integration

### Data Structure
```json
{
  "id": "firebase_user_id",
  "email": "user@example.com",
  "displayName": "John Doe",
  "phoneNumber": "+1234567890",
  "photoUrl": "https://example.com/photo.jpg",
  "role": 0,
  "isEmailVerified": true,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### Collections
- **`users`**: User profiles and role information
- **Integration**: Works with Firebase Auth users collection

### Real-time Features
- **Authentication State**: Real-time auth state changes
- **Profile Updates**: Live profile data synchronization
- **Stream Management**: Efficient stream handling and cleanup

## Demo Accounts

### Pre-configured Test Accounts
```dart
static const Map<String, Map<String, String>> demoAccounts = {
  'customer': {
    'email': 'customer@demo.com',
    'password': 'password123',
    'displayName': 'Demo Customer',
  },
  'shopOwner': {
    'email': 'shop@demo.com',
    'password': 'password123',
    'displayName': 'Demo Shop Owner',
  },
  'employee': {
    'email': 'employee@demo.com',
    'password': 'password123',
    'displayName': 'Demo Employee',
  },
  // ... more demo accounts
};
```

### Demo Account Roles
- **Customer**: Regular customer access
- **Shop Owner**: Business owner with full access
- **Employee**: General employee permissions
- **Specialized Roles**: Tailor, cutter, finisher for testing

## Error Handling

### Comprehensive Error Management
```dart
Exception _handleAuthError(dynamic error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email.');
      // ... more error cases
    }
  }
  return Exception('An unexpected error occurred.');
}
```

### Error Categories
- **Authentication Errors**: Login, signup, password issues
- **Network Errors**: Connectivity and timeout issues
- **Validation Errors**: Invalid email, weak password
- **Account Errors**: Disabled accounts, too many attempts
- **Phone Errors**: SMS verification failures

## Usage Examples

### Email/Password Registration
```dart
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();

  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _authService.signUpWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
        phoneNumber: _phoneController.text,
        role: UserRole.customer,
      );

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
```

### Phone Number Authentication
```dart
class PhoneLoginScreen extends StatefulWidget {
  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final AuthService _authService = AuthService();
  String? _verificationId;

  Future<void> _verifyPhone() async {
    await _authService.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      onCodeSent: (verificationId) {
        setState(() => _verificationId = verificationId);
        // Show OTP input field
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
      onVerified: (userCredential) {
        // Auto-verified, navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      },
    );
  }

  Future<void> _verifyOTP() async {
    try {
      UserCredential userCredential = await _authService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      // Navigate to home screen
    } catch (e) {
      // Handle OTP verification error
    }
  }
}
```

### Profile Management
```dart
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    _userProfile = await _authService.getCurrentUserProfile();
    setState(() {});
  }

  Future<void> _updateProfile() async {
    await _authService.updateUserProfile(
      displayName: _nameController.text,
      phoneNumber: _phoneController.text,
    );
    await _loadUserProfile(); // Refresh profile
  }
}
```

### Authentication State Management
```dart
class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }

        if (snapshot.hasData) {
          return HomeScreen(); // User is signed in
        }

        return LoginScreen(); // User is not signed in
      },
    );
  }
}
```

## Integration Points

### Related Components
- **Auth Provider**: State management wrapper around AuthService
- **Login Screen**: User interface for email/password authentication
- **Signup Screen**: Registration interface
- **Profile Screen**: User profile management interface
- **Role-Based Guards**: Access control based on user roles

### Dependencies
- **Firebase Auth**: Core authentication functionality
- **Cloud Firestore**: User profile data persistence
- **Flutter Framework**: UI integration and state management

## Security Considerations

### Authentication Security
- **Secure Authentication**: Firebase Auth security best practices
- **Password Policies**: Enforced by Firebase Auth
- **Account Verification**: Email verification requirement
- **Session Management**: Secure session handling

### Data Privacy
- **User Data Protection**: Secure handling of personal information
- **Profile Data**: Encrypted storage in Firestore
- **Access Control**: Role-based data access
- **Audit Trail**: Authentication attempt logging

### Phone Number Security
- **SMS Verification**: Secure OTP delivery
- **Rate Limiting**: Protection against abuse
- **Auto-Verification**: Secure auto-verification on supported devices
- **Timeout Handling**: Prevents OTP replay attacks

## Performance Optimization

### Data Loading Strategies
- **Lazy Loading**: Load user profiles on demand
- **Caching**: Cache current user information
- **Stream Optimization**: Efficient real-time subscriptions
- **Batch Operations**: Minimize Firebase calls

### Network Efficiency
- **Minimal Data Transfer**: Only fetch required user data
- **Stream Management**: Proper stream cleanup and management
- **Error Handling**: Efficient error handling without unnecessary retries
- **Connection Management**: Handle network connectivity issues

## Business Logic

### Role-Based Access Control
- **Hierarchical Roles**: Clear role hierarchy for the tailoring business
- **Permission Levels**: Different access levels for different roles
- **Business Logic**: Role-specific business rules and workflows
- **Security Enforcement**: Consistent role validation across the app

### User Lifecycle Management
- **Account Creation**: Streamlined registration process
- **Profile Management**: Flexible profile updates
- **Account Deletion**: Secure account removal with data cleanup
- **Password Management**: Secure password change process

### Multi-Channel Authentication
- **Email/Password**: Traditional authentication method
- **Phone Number**: Alternative authentication for mobile users
- **Demo Accounts**: Testing and demonstration support
- **Flexible Integration**: Easy integration with existing systems

This comprehensive authentication service provides a solid foundation for user management in the tailoring shop system, supporting multiple authentication methods, comprehensive user profiles, and role-based access control while maintaining security and performance best practices.