# Authentication Service

## Overview
The `auth_service.dart` file provides comprehensive Firebase authentication functionality for the AI-Enabled Tailoring Shop Management System. It handles user registration, login, phone verification, profile management, and demo authentication with full integration with Firestore for user profiles.

## Key Components

### UserRole Enum
Defines all available user roles in the system:
```dart
enum UserRole {
  customer,      // Regular customers
  shopOwner,     // Business owners
  admin,         // System administrators
  employee,      // General staff
  tailor,        // Master tailors
  cutter,        // Fabric cutting specialists
  finisher,      // Quality control finishers
  supervisor,    // Team supervisors
  apprentice     // Training staff
}
```

### UserModel Class
Comprehensive user data structure with Firebase integration:

#### Core Properties
- **`id`**: Firebase Auth UID (String)
- **`email`**: User email address (String)
- **`displayName`**: User's display name (String)
- **`phoneNumber`**: Optional phone number (String?)
- **`photoUrl`**: Profile photo URL (String?)
- **`role`**: User role in the system (UserRole)
- **`isEmailVerified`**: Email verification status (bool)

#### Metadata
- **`createdAt`**: Account creation timestamp (DateTime)
- **`updatedAt`**: Last update timestamp (DateTime)

### AuthService Class
Main authentication service with Firebase integration.

## Firebase Integration

### Core Firebase Services
```dart
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
```

### Authentication Streams
```dart
Stream<User?> get authStateChanges => _auth.authStateChanges();
User? get currentUser => _auth.currentUser;
```

## Authentication Methods

### Email/Password Authentication

#### User Registration
```dart
Future<UserCredential> signUpWithEmailAndPassword({
  required String email,
  required String password,
  String? displayName,
  String? phoneNumber,
  UserRole role = UserRole.customer,
})
```

**Process Flow:**
1. Create Firebase Auth account
2. Update display name if provided
3. Create Firestore user profile
4. Return user credentials

#### User Login
```dart
Future<UserCredential> signInWithEmailAndPassword({
  required String email,
  required String password,
})
```

**Features:**
- Comprehensive error handling
- Detailed logging for debugging
- Automatic user profile loading

### Phone Number Authentication

#### Phone Verification
```dart
Future<void> verifyPhoneNumber({
  required String phoneNumber,
  required Function(String verificationId) onCodeSent,
  required Function(String error) onError,
  required Function(UserCredential userCredential) onVerified,
})
```

**Verification Flow:**
1. Send SMS with verification code
2. Handle auto-retrieval on Android
3. Provide verification ID for manual code entry
4. Support for international phone numbers

#### OTP Verification
```dart
Future<UserCredential> verifyOTP({
  required String verificationId,
  required String smsCode,
})
```

**Security Features:**
- Time-based verification (60-second timeout)
- Secure credential verification
- Automatic error handling

#### OTP Resend
```dart
Future<void> resendOTP({
  required String phoneNumber,
  required Function(String verificationId) onCodeSent,
  required Function(String error) onError,
})
```

## Profile Management

### User Profile Operations

#### Get User Profile
```dart
Future<UserModel?> getUserProfile(String userId)
```

**Features:**
- Fetch user data from Firestore
- Automatic JSON deserialization
- Comprehensive error handling

#### Update User Profile
```dart
Future<void> updateUserProfile({
  String? displayName,
  String? phoneNumber,
  String? photoUrl,
})
```

**Update Process:**
1. Update Firebase Auth profile
2. Sync changes to Firestore
3. Maintain data consistency

#### Stream User Profile
```dart
Stream<UserModel?> getUserProfileStream(String userId)
```

**Real-time Features:**
- Live updates from Firestore
- Automatic UI updates
- Connection status handling

## Account Management

### Security Operations

#### Password Reset
```dart
Future<void> sendPasswordResetEmail(String email)
```

**Security Features:**
- Firebase secure token generation
- Email template customization
- Rate limiting protection

#### Email Verification
```dart
Future<void> sendEmailVerification()
Future<bool> isEmailVerified()
```

**Verification Process:**
- Send verification email
- Check verification status
- Automatic status updates

#### Password Change
```dart
Future<void> changePassword(String currentPassword, String newPassword)
```

**Security Process:**
1. Re-authenticate with current password
2. Validate new password strength
3. Update password securely

### Account Operations

#### Account Deletion
```dart
Future<void> deleteAccount()
```

**Deletion Process:**
1. Remove Firestore user profile
2. Delete Firebase Auth account
3. Clean up related data

#### Sign Out
```dart
Future<void> signOut()
```

**Cleanup Process:**
- Clear authentication state
- Close active streams
- Clear cached data

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
      case 'invalid-email':
        return Exception('Invalid email address.');
      case 'weak-password':
        return Exception('Password is too weak.');
      case 'user-disabled':
        return Exception('This user account has been disabled.');
      case 'operation-not-allowed':
        return Exception('Email/password accounts are not enabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection.');
      default:
        return Exception('Authentication error: ${error.message}');
    }
  }
  return Exception('An unexpected error occurred.');
}
```

## Demo Authentication System

### Pre-configured Demo Accounts
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
  // ... additional demo accounts
};
```

### Demo Account Features
- **Multiple Roles**: Test all user types
- **Pre-populated Data**: Realistic test scenarios
- **Isolated Environment**: No impact on production data
- **Easy Access**: Quick authentication for development

## Data Serialization

### JSON Conversion Methods

#### UserModel Serialization
```dart
factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'],
    email: json['email'],
    displayName: json['displayName'],
    phoneNumber: json['phoneNumber'],
    photoUrl: json['photoUrl'],
    role: UserRole.values[json['role'] ?? 0],
    isEmailVerified: json['isEmailVerified'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'email': email,
    'displayName': displayName,
    'phoneNumber': phoneNumber,
    'photoUrl': photoUrl,
    'role': role.index,
    'isEmailVerified': isEmailVerified,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
```

## Integration Points

### With Authentication Provider
- **State Management**: Provides auth operations to AuthProvider
  - Related: [`lib/providers/auth_provider.dart`](../providers/auth_provider.md)
- **Error Handling**: Centralized error management
- **Demo Support**: Demo account functionality

### With UI Components
- **Login Screen**: User authentication interface
  - Related: [`lib/screens/auth/login_screen.dart`](../screens/auth/login_screen.md)
- **Signup Screen**: User registration interface
  - Related: [`lib/screens/auth/signup_screen.dart`](../screens/auth/signup_screen.md)
- **Profile Management**: User data updates
  - Related: [`lib/screens/profile/profile_screen.dart`](../screens/profile/profile_screen.md)

### With Data Services
- **Firebase Service**: Core Firebase operations
  - Related: [`lib/services/firebase_service.dart`](../services/firebase_service.md)
- **Firestore Integration**: User profile persistence
- **Real-time Updates**: Live data synchronization

### With Security System
- **Role-Based Access**: User role management
  - Related: [`lib/models/user_role.dart`](../models/user_role.dart.md)
- **Permission System**: Integration with RBAC
- **Data Security**: Secure user data handling

## Security Features

### Authentication Security
- **Firebase Auth**: Enterprise-grade authentication
- **Token Management**: Secure JWT handling
- **Session Management**: Automatic session cleanup

### Data Protection
- **Encrypted Communication**: HTTPS-only connections
- **Secure Storage**: Firebase security rules
- **Access Control**: Role-based data access

### Account Security
- **Email Verification**: Account security validation
- **Password Policies**: Strong password requirements
- **Account Recovery**: Secure password reset process

## Performance Optimizations

### Efficient Operations
- **Lazy Loading**: Load profiles on demand
- **Stream Management**: Efficient real-time updates
- **Caching Strategy**: Minimize network requests

### Error Recovery
- **Retry Logic**: Automatic retry on network failures
- **Offline Support**: Basic functionality without network
- **Graceful Degradation**: Maintain functionality during errors

## Usage Examples

### User Registration
```dart
final authService = AuthService();

final userCredential = await authService.signUpWithEmailAndPassword(
  email: 'user@example.com',
  password: 'securePassword123',
  displayName: 'John Doe',
  phoneNumber: '+1234567890',
  role: UserRole.customer,
);

// User profile automatically created in Firestore
```

### Phone Verification
```dart
await authService.verifyPhoneNumber(
  phoneNumber: '+1234567890',
  onCodeSent: (verificationId) {
    // Show OTP input UI
    print('OTP sent, verification ID: $verificationId');
  },
  onError: (error) {
    // Handle verification error
    print('Verification error: $error');
  },
  onVerified: (userCredential) {
    // Auto-verification successful
    print('Phone verified automatically');
  },
);

// Later, verify OTP
final userCredential = await authService.verifyOTP(
  verificationId: verificationId,
  smsCode: '123456',
);
```

### Profile Management
```dart
// Get user profile
final userProfile = await authService.getUserProfile(userId);

// Update profile
await authService.updateUserProfile(
  displayName: 'New Name',
  phoneNumber: '+1987654321',
  photoUrl: 'https://example.com/photo.jpg',
);

// Stream profile changes
final profileStream = authService.getUserProfileStream(userId);
profileStream.listen((profile) {
  if (profile != null) {
    // Handle profile updates
    print('Profile updated: ${profile.displayName}');
  }
});
```

## Testing Support

### Demo Account Integration
- **Multiple Test Accounts**: All user roles available
- **Consistent Data**: Reliable test scenarios
- **Isolated Environment**: No production data impact
- **Easy Development**: Quick authentication for testing

### Error Simulation
- **Network Errors**: Test offline scenarios
- **Authentication Failures**: Test error handling
- **Edge Cases**: Test boundary conditions

## Future Enhancements

### Advanced Authentication
- **Biometric Authentication**: Fingerprint and face unlock
- **Multi-Factor Authentication**: SMS and authenticator app support
- **Social Login**: Google, Facebook, Apple sign-in
- **Passwordless Authentication**: Magic link authentication

### Enhanced Security
- **Account Lockout**: Prevent brute force attacks
- **Suspicious Activity Detection**: Monitor for unusual patterns
- **Audit Logging**: Comprehensive authentication logging
- **Compliance Features**: GDPR and security compliance

### Advanced Features
- **Account Recovery**: Enhanced recovery options
- **Device Management**: Manage authenticated devices
- **Session Management**: Advanced session controls
- **Account Linking**: Multiple authentication methods

---

*This comprehensive AuthService provides enterprise-grade authentication functionality for the AI-Enabled Tailoring Shop Management System, supporting multiple authentication methods, comprehensive user management, and seamless integration with Firebase Auth and Firestore for a complete authentication solution.*