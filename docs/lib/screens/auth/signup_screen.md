# Signup Screen

## Overview
The `SignupScreen` provides multi-step user registration with modern UI design, comprehensive validation, and enhanced theme support. It features a full-page card layout with glassmorphism effects and role-based registration.

## Key Features

### Multi-Step Registration Process
1. **Account Setup**: Basic information and credentials
2. **Personal Information**: Profile details and role selection
3. **Verification**: Email/phone verification process

### Visual Design (Updated)
- **Gradient Background**: Dynamic gradient matching login screen
- **Glassmorphism Card**: Consistent with app design system
- **Theme Consistency**: Adapts to light/dark/glassy modes
- **Responsive Layout**: Optimized for different screen sizes

### Advanced Form Features
- **Password Strength Indicator**: Real-time strength assessment
- **Role Selection**: Multiple user roles with visual chips
- **Phone Verification**: OTP-based phone number verification
- **Email Verification**: Link-based email verification
- **Terms & Conditions**: Required acceptance for registration

## UI Components

### Progress Indicator
```dart
Row(
  children: List.generate(3, (index) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: index <= _currentStep
              ? (isDarkMode ? DarkAppColors.primary : AppColors.primary)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }),
)
```

### Step-Based Content
- **Dynamic Headers**: Changes based on current step
- **Conditional Forms**: Different fields for each step
- **Smooth Transitions**: Fade animations between steps

## Form Steps

### Step 1: Account Setup
- **Email Field**: With validation and uniqueness checks
- **Phone Field**: 10-digit validation with country code
- **Password Fields**: Strength indicator and confirmation
- **Terms Acceptance**: Required checkbox with links

### Step 2: Personal Information
- **Role Selection**: Interactive chips for user roles
- **Name Fields**: First and last name with validation
- **Address**: Multi-line address input
- **Location**: City and pincode fields

### Step 3: Verification
- **Method Selection**: Email or phone verification
- **OTP Input**: 6-digit code for phone verification
- **Status Tracking**: Verification completion indicators

## Available User Roles

### Customer-Facing Roles
- **Customer**: Regular users of the tailoring service
- **Shop Owner**: Business owners managing the tailoring shop

### Employee Roles
- **Employee**: General staff member
- **Master Tailor**: Lead tailoring specialist
- **Fabric Cutter**: Specialized cutting technician
- **Finisher**: Quality control and finishing specialist
- **Supervisor**: Team lead and quality manager
- **Apprentice**: Training and junior position

## Key Methods

### `_handleStepNavigation()`
```dart
Future<void> _handleStepNavigation() async {
  switch (_currentStep) {
    case 0:
      if (_validateAccountSetupStep()) {
        _goToNextStep();
      }
      break;
    case 1:
      if (_validatePersonalInfoStep()) {
        _goToNextStep();
      }
      break;
    case 2:
      await _handleFinalSignup();
      break;
  }
}
```

### `_createAccount()`
- Creates user account with Firebase Auth
- Sets up user profile with role and personal information
- Handles verification requirements
- Navigates to home screen on success

### `_sendEmailVerification()` & `_sendPhoneVerification()`
- Integrates with Firebase Authentication
- Handles verification flow and error states
- Updates UI based on verification status

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

### Password Strength Algorithm
```dart
int score = 0;
if (password.length >= 8) score++;
if (password.length >= 12) score++;
if (RegExp(r'[a-z]').hasMatch(password)) score++;
if (RegExp(r'[A-Z]').hasMatch(password)) score++;
if (RegExp(r'[0-9]').hasMatch(password)) score++;
if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
```

## Theme Integration

### Dynamic Form Styling
- **Input Fields**: Theme-aware borders and backgrounds
- **Buttons**: Consistent with login screen design
- **Role Chips**: Interactive selection with theme colors
- **Progress Indicator**: Animated progress tracking

### Glassmorphism Effects
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    boxShadow: themeProvider.isGlassyMode ? [
      BoxShadow(
        color: (isDarkMode ? Colors.white : Colors.black)
            .withValues(alpha: 0.1),
        blurRadius: 20,
        spreadRadius: 5,
      ),
    ] : null,
  ),
)
```

## Verification Flow

### Email Verification
1. User enters email and completes registration
2. Verification email sent automatically
3. User clicks link in email to verify
4. Account activated upon verification

### Phone Verification
1. User enters phone number
2. OTP sent via SMS
3. User enters 6-digit code
4. Account activated upon successful verification

## Error Handling

### Form Validation Errors
- **Real-time Feedback**: Immediate validation on field changes
- **Clear Messages**: Specific, actionable error messages
- **Visual Indicators**: Color-coded error states

### Network Errors
- **Firebase Errors**: Proper error code handling
- **User Feedback**: Clear error messages with retry options
- **Graceful Degradation**: App remains functional during issues

## Performance Optimizations

### State Management
- **Efficient Rebuilds**: Targeted updates for changed fields
- **Controller Lifecycle**: Proper disposal of text controllers
- **Animation Optimization**: Smooth transitions with controlled rebuilds

### Memory Management
- **Resource Cleanup**: Dispose of controllers and animations
- **Lazy Initialization**: Initialize services only when needed
- **Efficient Validation**: Validate only necessary fields

## Accessibility Features

### Screen Reader Support
- **Form Labels**: Proper labeling for all input fields
- **Error Announcements**: Screen reader error feedback
- **Progress Updates**: Step-by-step progress announcements

### Visual Accessibility
- **High Contrast**: Sufficient color contrast in all themes
- **Touch Targets**: Minimum 44px touch targets
- **Focus Indicators**: Clear focus states for keyboard navigation

## Integration Points

### With Authentication Provider
- **Account Creation**: Firebase Auth integration
- **Error Handling**: Centralized error management
- **Loading States**: Consistent loading indicators

### With Theme Provider
- **Dynamic Theming**: Automatic theme adaptation
- **Glassy Mode Support**: Advanced visual effects
- **Color Consistency**: Theme-aware color usage

### With Device Detection
- **Auto Theme Detection**: Respects device capabilities
- **Platform Optimization**: Adapts to device characteristics
- **Performance Scaling**: Optimizes based on device specs

## Benefits

1. **Comprehensive Registration**: Multi-step process with validation
2. **Modern UI**: Glassmorphism design with smooth animations
3. **Role-Based Access**: Flexible user role system
4. **Strong Security**: Password strength and verification requirements
5. **Theme Consistency**: Seamless integration with theme system
6. **Error Resilience**: Comprehensive error handling and recovery
7. **Performance**: Optimized rendering and state management
8. **Accessibility**: Inclusive design for all users
9. **Developer Experience**: Clear validation and error feedback