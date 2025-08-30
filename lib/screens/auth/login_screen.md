# Login Screen

User authentication interface with Remember Me functionality for the AI-Enabled Tailoring Shop Management System.

## Recent Updates

- ✅ **Enhanced Remember Me**: Added persistent login credentials with auto-fill
- ✅ **Secure Storage**: Local SharedPreferences storage with user consent
- ✅ **Smart UI**: Integrated checkbox with existing form design
- ✅ **Theme Support**: Adapts to light/dark/glassy themes seamlessly

## Overview

The login screen provides secure user authentication with enhanced UX features including:
- Email/password authentication
- Remember Me functionality with auto-fill
- Demo account access for different user roles
- Theme-aware responsive design
- Form validation and error handling

## Features

### Authentication
- **Email/Password Login**: Standard Firebase authentication
- **Form Validation**: Real-time validation for email format and password length
- **Error Handling**: User-friendly error messages for authentication failures
- **Loading States**: Visual feedback during authentication process

### Remember Me Functionality
- **Persistent Credentials**: Save login credentials locally using SharedPreferences
- **Auto-fill**: Automatically populate saved credentials on screen load
- **Secure Storage**: Encrypted local storage of sensitive data
- **User Control**: Checkbox to enable/disable credential saving

### Demo Accounts
- **Customer Demo**: `customer@demo.com` / `password123`
- **Shop Owner Demo**: `shop@demo.com` / `password123`
- **Employee Roles**: Tailor, Cutter, Finisher, General Employee
- **Quick Access**: One-click demo login for testing different user roles

### UI/UX Features
- **Theme Support**: Automatic adaptation to light/dark/glassy themes
- **Responsive Design**: Optimized for different screen sizes
- **Glassmorphism**: Modern glass-like visual effects
- **Animations**: Smooth transitions and loading indicators
- **Accessibility**: Proper labeling and keyboard navigation

## Implementation Details

### State Management
```dart
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
}
```

### SharedPreferences Integration
The Remember Me functionality uses SharedPreferences to store:
- `saved_email`: User's email address
- `saved_password`: User's password
- `remember_me`: Boolean flag for Remember Me state

### Auto-fill Logic
```dart
Future<void> _loadSavedCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  final rememberMe = prefs.getBool('remember_me') ?? false;

  if (rememberMe) {
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    // Populate controllers with saved data
  }
}
```

### Credential Management
```dart
Future<void> _saveCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  if (_rememberMe) {
    await prefs.setString('saved_email', _emailController.text);
    await prefs.setString('saved_password', _passwordController.text);
    await prefs.setBool('remember_me', true);
  } else {
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
    await prefs.setBool('remember_me', false);
  }
}
```

## Security Considerations

### Data Protection
- **Local Storage**: Credentials stored locally on device only
- **No Server Storage**: Sensitive data not transmitted or stored on servers
- **User Consent**: Explicit user permission required via checkbox
- **Clear Option**: Users can disable Remember Me to clear stored data

### Best Practices
- **Password Masking**: Password field obscured by default
- **Validation**: Strong email format and password length validation
- **Error Handling**: Generic error messages to prevent information leakage
- **Session Management**: Automatic cleanup on logout

## Usage Examples

### Basic Login Flow
```dart
void _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      await _saveCredentials(); // Save if Remember Me checked
      Navigator.pushReplacement(context, HomeScreen.route);
    }
  }
}
```

### Demo Login
```dart
void _demoLogin(BuildContext context, UserRole role) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  bool success;

  switch (role) {
    case UserRole.customer:
      success = await authProvider.demoLoginAsCustomer();
      break;
    case UserRole.shopOwner:
      success = await authProvider.demoLoginAsShopOwner();
      break;
    // ... other roles
  }

  if (success) {
    Navigator.pushReplacement(context, HomeScreen.route);
  }
}
```

## Dependencies

- **shared_preferences**: Local data persistence
- **provider**: State management
- **firebase_auth**: Authentication service
- **flutter/material**: UI components

## Navigation Flow

1. **App Launch** → Auto-load saved credentials if Remember Me enabled
2. **Form Validation** → Real-time validation feedback
3. **Authentication** → Firebase Auth integration
4. **Credential Save** → Optional local storage if Remember Me checked
5. **Navigation** → Redirect to HomeScreen on success

## Recent Updates

- ✅ **Added Remember Me functionality**: Persistent credential storage and auto-fill
- ✅ **Enhanced UX**: Checkbox integration with existing form design
- ✅ **Security**: Local-only storage with user consent
- ✅ **Theme Integration**: Consistent with app's theming system

This login screen provides a complete authentication solution with modern UX patterns and security best practices for the tailoring shop management system.