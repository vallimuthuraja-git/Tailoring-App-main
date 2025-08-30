# Login Screen

## Overview
The `LoginScreen` provides user authentication with modern UI design and enhanced theme support. It features a full-page card layout with glassmorphism effects and comprehensive demo functionality.

## Key Features

### Visual Design
- **Gradient Background**: Dynamic gradient based on theme
- **Glassmorphism Card**: Translucent card with blur effects
- **Theme Consistency**: Adapts to light/dark/glassy modes
- **Responsive Layout**: Optimized for different screen sizes

### Authentication Methods
- **Email/Password Login**: Standard authentication
- **Demo Accounts**: Multiple pre-configured demo users
- **Role-Based Access**: Different demo accounts for various roles
- **Form Validation**: Real-time email and password validation

### Demo Functionality
- **Customer Demo**: Regular customer access
- **Shop Owner Demo**: Administrative access
- **Employee Demo**: Role selection dialog for various positions
- **Quick Access**: One-tap demo login for testing

## UI Components

### Header Section
```dart
Icon(
  Icons.design_services,
  size: 64,
  color: themeProvider.isDarkMode
      ? DarkAppColors.primary
      : AppColors.primary,
),
Text(
  'Welcome Back',
  style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: themeProvider.isDarkMode
        ? DarkAppColors.onBackground
        : AppColors.onBackground,
  ),
)
```

### Login Form
- **Email Field**: With validation and icon
- **Password Field**: Obscured text with visibility toggle
- **Forgot Password**: Navigation to reset screen
- **Error Display**: Real-time error messaging

### Demo Section
- **Demo Customer**: Quick customer login
- **Demo Shop**: Shop owner access
- **Demo Partner**: Employee role selection

## Key Methods

### `_handleLogin()`
```dart
Future<void> _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }
}
```

### `_demoLogin(BuildContext context, UserRole role)`
- Handles demo authentication
- Supports multiple user roles
- Automatic navigation on success

### `_showForgotPasswordDialog()`
- **Now Updated**: Navigates to full-page forgot password screen
- Replaced dialog with dedicated screen for better UX

## Navigation Flow

### Successful Login
```
LoginScreen → HomeScreen (pushReplacement)
```

### Demo Login
```
LoginScreen → Role Selection (if needed) → HomeScreen
```

### Password Reset
```
LoginScreen → ForgotPasswordScreen → LoginScreen (pop)
```

### Sign Up
```
LoginScreen → SignupScreen (push)
```

## Theme Integration

### Dynamic Styling
- **Colors**: Adapts to theme mode automatically
- **Glassmorphism**: Conditional blur and transparency effects
- **Shadows**: Theme-appropriate shadow effects
- **Borders**: Subtle borders with theme colors

### Theme-Aware Components
- **Text Fields**: Dynamic border and background colors
- **Buttons**: Theme-appropriate colors and effects
- **Icons**: Context-aware icon colors
- **Progress Indicators**: Loading states with theme colors

## Form Validation

### Email Validation
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}
```

### Password Validation
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}
```

## Demo User Roles

### Available Demo Accounts
- **Customer**: `customer@demo.com`
- **Shop Owner**: `shop@demo.com`
- **Employee Roles**:
  - General Employee
  - Master Tailor
  - Fabric Cutter
  - Finisher
  - Supervisor
  - Apprentice

### Role Selection Dialog
- **Dynamic UI**: Adapts to current theme
- **Role Icons**: Visual representation of each role
- **One-Tap Access**: Direct navigation to home screen

## Error Handling

### Authentication Errors
- **Display**: Real-time error messages in form
- **Styling**: Theme-appropriate error colors
- **User Feedback**: Clear, actionable error messages

### Network Issues
- **Timeout Handling**: Graceful degradation
- **Retry Options**: User can attempt again
- **Offline Support**: Cached authentication state

## Performance Optimizations

### State Management
- **Efficient Rebuilds**: Targeted state updates
- **Controller Disposal**: Proper cleanup on dispose
- **Memory Management**: Optimized widget lifecycle

### UI Performance
- **Conditional Rendering**: Only show relevant UI elements
- **Lazy Loading**: Demo buttons load on demand
- **Smooth Animations**: 300ms fade transitions

## Accessibility Features

### Screen Reader Support
- **Semantic Labels**: Proper labeling for assistive technologies
- **Focus Management**: Logical tab order
- **Error Announcements**: Screen reader error feedback

### Visual Accessibility
- **High Contrast**: Sufficient color contrast ratios
- **Large Touch Targets**: Minimum 44px touch targets
- **Clear Typography**: Readable font sizes and weights

## Integration Points

### With Authentication Provider
- **State Management**: Real-time auth state updates
- **Error Propagation**: Centralized error handling
- **Loading States**: Consistent loading indicators

### With Theme Provider
- **Dynamic Theming**: Automatic theme adaptation
- **Glassy Effects**: Conditional visual enhancements
- **Color Consistency**: Theme-aware color usage

### With Navigation
- **Push/Pop Navigation**: Standard Flutter navigation
- **State Preservation**: Maintains form state during navigation
- **Deep Linking**: Supports deep links to login

## Benefits

1. **Modern UI**: Glassmorphism and gradient design
2. **Easy Testing**: Multiple demo accounts for development
3. **Theme Consistency**: Seamless integration with theme system
4. **Form Validation**: Real-time feedback and error handling
5. **Performance**: Optimized rendering and state management
6. **Accessibility**: Inclusive design for all users
7. **Developer Experience**: Comprehensive demo functionality