# Authentication Provider

## Overview
The `auth_provider.dart` file implements a comprehensive authentication and user management system for the AI-Enabled Tailoring Shop Management System. It provides complete Firebase Auth integration, role-based access control, user profile management, and demo authentication capabilities with real-time state synchronization.

## Key Features

### Complete Authentication Lifecycle
- **User Registration**: Sign up with email, password, and role assignment
- **Secure Login**: Email/password authentication with profile loading
- **Session Management**: Automatic session restoration and state persistence
- **Secure Logout**: Complete session cleanup and state reset

### Role-Based Access Control
- **Multi-Role System**: Customer, Employee, Tailor, Cutter, Finisher, Shop Owner, Admin
- **Permission Checking**: Role-based UI rendering and feature access
- **Dynamic UI Adaptation**: Interface changes based on user permissions
- **Security Enforcement**: Route protection and data access control

### Real-time State Management
- **Firebase Auth Integration**: Live authentication state monitoring
- **Profile Synchronization**: Real-time user profile updates
- **Error Handling**: Comprehensive error management with user feedback
- **Loading States**: UI feedback for all authentication operations

## Architecture Components

### Provider Structure

#### AuthProvider Class
```dart
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
}
```

#### State Management Properties
```dart
// Authentication State
User? get user => _user;                    // Firebase Auth user
UserModel? get userProfile => _userProfile; // Extended user profile
bool get isLoading => _isLoading;          // Loading state
String? get errorMessage => _errorMessage;  // Error messages

// Computed Properties
bool get isAuthenticated => _user != null;              // Auth status
bool get isEmailVerified => _user?.emailVerified ?? false; // Email verification
UserRole get userRole => _userProfile?.role ?? UserRole.customer; // Current role
bool get isShopOwnerOrAdmin => // Shop owner or admin check
```

### Mock User Implementation

#### Demo Authentication Support
```dart
class MockUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool emailVerified;
  final bool isDemo;

  const MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = true,
    this.isDemo = false,
  });
}
```

## Core Functionality

### Authentication Operations

#### User Registration
```dart
Future<bool> signUp({
  required String email,
  required String password,
  String? displayName,
  String? phoneNumber,
  UserRole role = UserRole.customer,
}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    UserCredential userCredential = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
      phoneNumber: phoneNumber,
      role: role,
    );

    _user = userCredential.user;
    await _loadUserProfile();

    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _isLoading = false;
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}
```

#### User Login
```dart
Future<bool> signIn({
  required String email,
  required String password,
}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    UserCredential userCredential = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    _user = userCredential.user;
    await _loadUserProfile();

    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _isLoading = false;
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}
```

#### Session Logout
```dart
Future<void> signOut() async {
  _isLoading = true;
  notifyListeners();

  try {
    await _authService.signOut();
    _user = null;
    _userProfile = null;
    _errorMessage = null;
  } catch (e) {
    _errorMessage = e.toString();
  }

  _isLoading = false;
  notifyListeners();
}
```

### Profile Management

#### Load User Profile
```dart
Future<void> _loadUserProfile() async {
  if (_user != null) {
    try {
      _userProfile = await _authService.getUserProfile(_user!.uid);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user profile';
      notifyListeners();
    }
  }
}
```

#### Update User Profile
```dart
Future<bool> updateUserProfile({
  String? displayName,
  String? phoneNumber,
  String? photoUrl,
}) async {
  _isLoading = true;
  notifyListeners();

  try {
    await _authService.updateUserProfile(
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
    );

    // Reload user profile
    await _loadUserProfile();

    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _isLoading = false;
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}
```

### Security Features

#### Email Verification
```dart
Future<bool> sendEmailVerification() async {
  try {
    await _authService.sendEmailVerification();
    return true;
  } catch (e) {
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}

Future<bool> checkEmailVerification() async {
  try {
    bool isVerified = await _authService.isEmailVerified();
    if (_userProfile != null) {
      _userProfile = UserModel(
        id: _userProfile!.id,
        email: _userProfile!.email,
        displayName: _userProfile!.displayName,
        phoneNumber: _userProfile!.phoneNumber,
        photoUrl: _userProfile!.photoUrl,
        role: _userProfile!.role,
        isEmailVerified: isVerified,
        createdAt: _userProfile!.createdAt,
        updatedAt: DateTime.now(),
      );
    }
    notifyListeners();
    return isVerified;
  } catch (e) {
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}
```

#### Password Management
```dart
Future<bool> sendPasswordResetEmail(String email) async {
  try {
    await _authService.sendPasswordResetEmail(email);
    return true;
  } catch (e) {
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}

Future<bool> changePassword(String currentPassword, String newPassword) async {
  _isLoading = true;
  notifyListeners();

  try {
    await _authService.changePassword(currentPassword, newPassword);

    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _isLoading = false;
    _errorMessage = e.toString();
    notifyListeners();
    return false;
  }
}
```

### Role-Based Access Control

#### Role Validation Methods
```dart
bool hasRole(UserRole requiredRole) {
  return _userProfile?.role == requiredRole;
}

bool get isShopOwnerOrAdmin {
  return _userProfile?.role == UserRole.shopOwner || _userProfile?.role == UserRole.admin;
}
```

#### User Roles
```dart
enum UserRole {
  customer,    // Regular customers
  employee,    // General employees
  tailor,      // Specialized tailors
  cutter,      // Cutting specialists
  finisher,    // Finishing specialists
  shopOwner,   // Business owners
  admin        // System administrators
}
```

### Demo Authentication System

#### Demo Login Methods
```dart
Future<bool> demoLoginAsCustomer() async {
  return await _demoLogin('customer', UserRole.customer);
}

Future<bool> demoLoginAsShopOwner() async {
  return await _demoLogin('shopOwner', UserRole.shopOwner);
}

Future<bool> demoLoginAsEmployee() async {
  return await _demoLogin('employee', UserRole.employee);
}

Future<bool> demoLoginAsTailor() async {
  return await _demoLogin('tailor', UserRole.tailor);
}

Future<bool> demoLoginAsCutter() async {
  return await _demoLogin('cutter', UserRole.cutter);
}

Future<bool> demoLoginAsFinisher() async {
  return await _demoLogin('finisher', UserRole.finisher);
}
```

#### Demo Login Implementation
```dart
Future<bool> _demoLogin(String accountKey, UserRole role) async {
  final account = AuthService.demoAccounts[accountKey]!;
  final email = account['email']!;
  final displayName = account['displayName']!;

  try {
    // Create mock user session
    final mockUserId = 'demo_${accountKey}_${DateTime.now().millisecondsSinceEpoch}';

    _user = MockUser(
      uid: mockUserId,
      email: email,
      displayName: displayName,
      emailVerified: true,
      isDemo: true,
    );

    // Create user profile
    _userProfile = UserModel(
      id: mockUserId,
      email: email,
      displayName: displayName,
      role: role,
      isEmailVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _isLoading = false;
    _errorMessage = 'Demo login successful!';
    notifyListeners();

    return true;

  } catch (e) {
    _isLoading = false;
    _errorMessage = 'Demo login failed. Please try again.';
    notifyListeners();
    return false;
  }
}
```

## Integration Points

### With Authentication Service
- **Firebase Auth Operations**: User registration, login, logout
  - Related: [`lib/services/auth_service.dart`](../../services/auth_service.dart)
- **User Profile Management**: Profile creation and updates
- **Email Verification**: Verification email sending and checking
- **Password Management**: Password reset and change functionality

### With Firebase Service
- **Data Persistence**: User profile storage and retrieval
  - Related: [`lib/services/firebase_service.dart`](../../services/firebase_service.dart.md)
- **Real-time Updates**: Live authentication state monitoring
- **Security Rules**: Firebase security integration

### With UI Screens
- **Authentication Screens**: Login, signup, password reset integration
  - Related: [`lib/screens/auth/login_screen.dart`](../../screens/auth/login_screen.md)
  - Related: [`lib/screens/auth/signup_screen.dart`](../../screens/auth/signup_screen.md)
  - Related: [`lib/screens/auth/forgot_password_screen.dart`](../../screens/auth/forgot_password_screen.md)
- **Role-Based UI**: Dynamic interface adaptation
  - Related: [`lib/screens/home/home_screen.dart`](../../screens/home/home_screen.md)
  - Related: [`lib/screens/profile/profile_screen.dart`](../../screens/profile/profile_screen.md)

### With Business Logic Providers
- **Customer Provider**: Customer profile creation integration
  - Related: [`lib/providers/customer_provider.dart`](../../providers/customer_provider.md)
- **Order Provider**: User context for order operations
  - Related: [`lib/providers/order_provider.dart`](../../providers/order_provider.md)
- **Product Provider**: User permissions for product management
  - Related: [`lib/providers/product_provider.dart`](../../providers/product_provider.md)

### With Analytics Dashboard
- **User Context**: Analytics data filtering by user
  - Related: [`lib/screens/dashboard/analytics_dashboard_screen.dart`](../../screens/dashboard/analytics_dashboard_screen.md)
- **Role-Based Analytics**: Different analytics views by user role
- **Security Filtering**: Data access control for analytics

## User Experience Features

### Authentication Flow
```
User Authentication
├── Sign Up Process
│   ├── Email/Password Registration
│   ├── Role Selection
│   ├── Profile Information
│   └── Email Verification
├── Sign In Process
│   ├── Email/Password Login
│   ├── Profile Loading
│   └── Role-Based Redirect
├── Demo Authentication
│   ├── Pre-configured Accounts
│   ├── Role-Specific Logins
│   └── Instant Access
└── Session Management
    ├── Auto-restore Sessions
    ├── Real-time State Updates
    └── Secure Logout
```

### Role-Based Experience
```
Shop Owner Experience
├── Complete System Access
├── Business Analytics Dashboard
├── Employee Management Tools
├── Product & Service Management
└── Customer Relationship Management

Customer Experience
├── Personal Profile Management
├── Order History & Tracking
├── Measurement Management
├── Service Browsing & Booking
└── Support & Communication

Employee Experience
├── Task-Specific Interfaces
├── Work Assignment Tracking
├── Customer Communication
├── Performance Analytics
└── Role-Based Permissions
```

### Error Handling & Feedback
```dart
// Error states and user feedback
void clearError() {
  _errorMessage = null;
  notifyListeners();
}

// Comprehensive error handling in all operations
try {
  // Authentication operation
} catch (e) {
  _errorMessage = e.toString();
  notifyListeners();
}
```

## Performance Optimizations

### State Management Efficiency
- **Lazy Profile Loading**: On-demand user profile retrieval
- **Stream Optimization**: Efficient Firebase auth state listening
- **Memory Management**: Proper cleanup of listeners and resources
- **Error Recovery**: Graceful failure handling and recovery

### Security Optimizations
- **Session Persistence**: Secure session restoration
- **Token Management**: Automatic token refresh and validation
- **Role Caching**: Efficient role-based permission checking
- **Audit Trail**: Authentication event logging

## Future Enhancements

### Advanced Authentication
- **Multi-Factor Authentication**: Enhanced security with 2FA
- **Social Authentication**: Google, Facebook, Apple sign-in
- **Biometric Authentication**: Fingerprint and face recognition
- **Single Sign-On**: Enterprise SSO integration

### Enhanced User Management
- **User Invitations**: Email-based user invitations
- **Bulk User Operations**: Mass user management for admins
- **User Activity Tracking**: Comprehensive user behavior analytics
- **Session Management**: Advanced session controls and monitoring

### Security Enhancements
- **Advanced Password Policies**: Customizable password requirements
- **Account Recovery**: Enhanced account recovery options
- **Device Management**: Trusted device management
- **Security Alerts**: Real-time security notifications

### Integration Features
- **Third-Party Auth**: OAuth integration with external services
- **LDAP Integration**: Enterprise directory integration
- **API Authentication**: REST API authentication support
- **Mobile App Sync**: Cross-platform authentication sync

---

*This Authentication Provider serves as the comprehensive security and user management foundation for the tailoring shop system, providing secure authentication, role-based access control, user profile management, and seamless integration with all system components while supporting both production and demo authentication workflows.*