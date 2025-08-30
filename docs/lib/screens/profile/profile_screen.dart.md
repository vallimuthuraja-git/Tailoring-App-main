# Profile Screen

## Overview
The `profile_screen.dart` file implements a comprehensive user profile management interface for the AI-Enabled Tailoring Shop Management System. It provides users with a centralized location to view and manage their account information, preferences, and application settings, featuring role-based content and seamless theme integration.

## Key Features

### User Profile Management
- **Personal Information Display**: Avatar, name, email, and role visualization
- **Role-Based Profile**: Different experiences for customers vs shop owners
- **Account Status**: Clear indication of user permissions and access level
- **Profile Customization**: Avatar display with fallback to default icons

### Account Settings
- **Personal Information**: Access to profile editing capabilities
- **Security Management**: Password change functionality
- **Customer-Specific Features**: Measurements and address book management
- **Account Preferences**: Personalized settings and configurations

### Theme & App Preferences
- **Dynamic Theme Selection**: Light and dark mode switching
- **Visual Feedback**: Selected theme indication and previews
- **Persistent Settings**: Theme preferences maintained across sessions
- **Adaptive UI**: Theme-aware component styling

### Support & Information
- **Help & Support**: Access to customer support resources
- **About Dialog**: Application information and version details
- **Legal Information**: App licensing and copyright details
- **Contact Integration**: Support channel access

## Architecture Components

### Main Widget Structure

#### ProfileScreen Widget
```dart
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        final user = authProvider.userProfile;
        return Scaffold(
          appBar: AppBar(...),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(user, authProvider, themeProvider),
                _buildAccountSettings(themeProvider),
                _buildAppPreferences(context),
                _buildSupportSection(context, themeProvider),
                _buildLogoutSection(context),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### Profile Header Component
```dart
Center(
  child: Column(
    children: [
      CircleAvatar(
        radius: 50,
        backgroundImage: user?.photoUrl != null
            ? NetworkImage(user!.photoUrl!)
            : null,
        child: user?.photoUrl == null
            ? Icon(
                Icons.person,
                size: 50,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha:0.5)
                    : AppColors.onSurface.withValues(alpha:0.5),
              )
            : null,
      ),
      Text(
        user?.displayName ?? 'User',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
        ),
      ),
      _buildRoleBadge(authProvider, themeProvider),
    ],
  ),
)
```

### Role Badge Implementation
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: authProvider.isShopOwnerOrAdmin
        ? (themeProvider.isDarkMode
            ? Colors.orange.shade900.withValues(alpha:0.3)
            : Colors.orange.shade100)
        : (themeProvider.isDarkMode
            ? AppColors.primary.withValues(alpha:0.2)
            : AppColors.primary.withValues(alpha:0.1)),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Text(
    authProvider.userRole == UserRole.customer
        ? 'Customer'
        : authProvider.userRole == UserRole.shopOwner
            ? 'Shop Owner'
            : 'Admin',
    style: TextStyle(
      color: authProvider.isShopOwnerOrAdmin
          ? (themeProvider.isDarkMode
              ? Colors.orange.shade300
              : Colors.orange.shade700)
          : (themeProvider.isDarkMode
              ? AppColors.primary
              : AppColors.primary),
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

## UI Components

### Profile Option Widget
```dart
class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? AppColors.primary.withValues(alpha:0.1)
                : AppColors.primary.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: themeProvider.isDarkMode ? AppColors.primary : AppColors.primary,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha:0.2)
                : AppColors.onSurface.withValues(alpha:0.2),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
```

### Theme Selection Component
```dart
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha:0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: color.withValues(alpha:0.3)) : null,
          ),
          child: Icon(
            icon,
            color: isSelected ? color : Colors.grey.shade600,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: color)
            : Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }
}
```

## Account Settings Section

### Customer-Specific Options
```dart
_ProfileOption(
  icon: Icons.straighten,
  title: 'Measurements',
  subtitle: 'Manage your body measurements',
  onTap: () {
    // Navigate to measurements management
  },
),

_ProfileOption(
  icon: Icons.location_on,
  title: 'Address Book',
  subtitle: 'Manage delivery addresses',
  onTap: () {
    // Navigate to address management
  },
),
```

### Universal Account Options
```dart
_ProfileOption(
  icon: Icons.person,
  title: 'Personal Information',
  subtitle: 'Update your profile details',
  onTap: () {
    // Navigate to profile editing
  },
),

_ProfileOption(
  icon: Icons.lock,
  title: 'Change Password',
  subtitle: 'Update your password',
  onTap: () {
    // Navigate to password change
  },
),
```

## Theme Management System

### Theme Selection Interface
```dart
Widget _buildThemeSelection(BuildContext context) {
  return Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return Column(
        children: [
          _ThemeOption(
            icon: Icons.light_mode,
            title: 'Light Mode',
            subtitle: 'Clean and bright interface',
            color: AppColors.primary,
            isSelected: themeProvider.isLightMode,
            onTap: () => themeProvider.switchToLightMode(),
          ),
          _ThemeOption(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Easy on the eyes in low light',
            color: DarkAppColors.primary,
            isSelected: themeProvider.isDarkMode,
            onTap: () => themeProvider.switchToDarkMode(),
          ),
        ],
      );
    },
  );
}
```

### Theme Switching Logic
```dart
// Light Mode Selection
onTap: () => themeProvider.switchToLightMode(),

// Dark Mode Selection
onTap: () => themeProvider.switchToDarkMode(),
```

## Support & Information

### About Dialog Implementation
```dart
void _showAboutDialog(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: 'Tailoring Shop Management',
    applicationVersion: '1.0.0',
    applicationLegalese: '© 2024 Tailoring App',
    children: [
      const SizedBox(height: 16),
      const Text(
        'AI-Enabled Web-Based Tailoring Shop Management System with Customer Support Chatbot.',
        textAlign: TextAlign.center,
      ),
    ],
  );
}
```

### Support Options
```dart
_ProfileOption(
  icon: Icons.help,
  title: 'Help & Support',
  subtitle: 'Get help and contact support',
  onTap: () {
    // Navigate to help center
  },
),

_ProfileOption(
  icon: Icons.info,
  title: 'About',
  subtitle: 'App version and information',
  onTap: () {
    _showAboutDialog(context);
  },
),
```

## Authentication Integration

### Logout Functionality
```dart
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}
```

### Secure Sign Out Process
```dart
// 1. Show confirmation dialog
_showLogoutDialog(context);

// 2. Perform sign out
await authProvider.signOut();

// 3. Navigate to login screen
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) => const LoginScreen()),
  (route) => false,
);
```

## Role-Based Features

### Shop Owner Features
- **Advanced Permissions**: Administrative access indicators
- **Management Tools**: Access to business management features
- **Analytics Integration**: Links to performance dashboards
- **Staff Oversight**: Employee management capabilities

### Customer Features
- **Personal Measurements**: Body measurement management
- **Address Management**: Delivery address book
- **Order History**: Access to personal order tracking
- **Personalized Support**: Customer-specific help resources

## Integration Points

### With Authentication Provider
- **User Context**: Access to current user profile and permissions
  - Related: [`lib/providers/auth_provider.dart`](../../providers/auth_provider.md)
- **Role Validation**: Real-time role-based UI rendering
- **Session Management**: Secure logout and session handling
- **Profile Data**: User information display and management

### With Theme Provider
- **Dynamic Theming**: Consistent theme application across all components
  - Related: [`lib/providers/theme_provider.dart`](../../providers/theme_provider.md)
- **Visual Consistency**: Theme-aware colors and styling
- **User Preferences**: Persistent theme selection
- **Accessibility**: High contrast and readability support

### With Navigation System
- **Screen Transitions**: Smooth navigation to related screens
- **State Management**: Proper navigation state handling
- **Deep Linking**: Direct access to specific profile sections
- **Back Navigation**: Proper stack management

## User Experience Design

### Profile Header Layout
```
[Avatar (50px)]
[Display Name]
[Email Address]
[Role Badge]
```

### Settings Organization
```
Account Settings
├── Personal Information
├── Change Password
├── Measurements (Customer only)
└── Address Book (Customer only)

App Preferences
├── Light Mode
└── Dark Mode

Support
├── Help & Support
└── About
```

### Visual Hierarchy
- **Primary Actions**: Large, prominent buttons for critical actions
- **Secondary Options**: List tiles with icons and descriptions
- **Status Indicators**: Clear visual feedback for selections
- **Consistent Spacing**: Proper padding and margins throughout

## Performance Optimizations

### Efficient Rendering
- **Consumer Pattern**: Targeted rebuilds for specific data changes
- **Lazy Loading**: On-demand content loading
- **Memory Management**: Proper disposal of resources
- **Minimal Rebuilds**: Optimized widget structure

### State Management
- **Provider Integration**: Centralized state access
- **Real-time Updates**: Live profile data synchronization
- **Persistent Preferences**: Settings maintained across sessions
- **Offline Support**: Cached data for offline functionality

## Accessibility Features

### Screen Reader Support
- **Semantic Labels**: Proper labeling for assistive technologies
- **Navigation Hints**: Clear descriptions for screen readers
- **Focus Management**: Logical tab order and focus flow
- **High Contrast**: Sufficient color contrast ratios

### Visual Accessibility
- **Large Touch Targets**: Minimum 44px touch areas
- **Clear Typography**: Readable font sizes and weights
- **Icon Clarity**: High-visibility icons for quick recognition
- **Consistent Patterns**: Familiar UI patterns for easy navigation

## Future Enhancements

### Advanced Profile Features
- **Profile Photo Upload**: Custom avatar management
- **Social Integration**: Social media account linking
- **Notification Preferences**: Granular notification controls
- **Privacy Settings**: Data sharing and privacy controls

### Enhanced Customization
- **Custom Themes**: User-defined color schemes
- **Language Selection**: Multi-language support
- **Regional Settings**: Location-based preferences
- **Accessibility Options**: Advanced accessibility settings

### Integration Features
- **Third-Party Services**: Integration with external services
- **Data Export**: Profile and data export capabilities
- **Backup & Restore**: Profile backup and restoration
- **Account Recovery**: Advanced account recovery options

---

*This Profile Screen serves as the comprehensive user control center for the tailoring shop management system, providing role-based access to account management, preferences, and support features while maintaining consistent theming and seamless integration with the application's authentication and navigation systems.*