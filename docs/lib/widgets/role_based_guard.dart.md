# Role-Based Guard Widgets

## Overview
The `role_based_guard.dart` file implements a comprehensive role-based access control (RBAC) system for the AI-Enabled Tailoring Shop Management System. It provides multiple security widgets and utilities for controlling user access to features, screens, and UI elements based on user roles and permissions.

## Key Features

### Multi-Level Security Widgets
- **Route Protection**: Complete screen-level access control
- **Conditional Rendering**: Dynamic UI based on user permissions
- **Role-Specific Content**: Different content for different user roles
- **Navigation Security**: Protected navigation items and menus

### Advanced Permission System
- **9 User Roles**: Hierarchical role system with clear access levels
- **Granular Permissions**: Specific permissions for different operations
- **Role Hierarchy**: Automatic permission inheritance
- **Flexible Access Control**: Multiple ways to check and enforce permissions

### Developer Experience
- **Easy Integration**: Simple widget wrapping for security
- **Context Extensions**: Convenient role checking methods
- **Visual Feedback**: Clear access denied messages and UI
- **Fallback Support**: Custom fallback widgets for unauthorized access

## Architecture Components

### Core Security Widgets

#### RoleBasedRouteGuard
```dart
class RoleBasedRouteGuard extends StatelessWidget {
  final auth.UserRole requiredRole;
  final Widget child;
  final Widget? fallbackWidget;

  const RoleBasedRouteGuard({
    required this.requiredRole,
    required this.child,
    this.fallbackWidget,
    super.key,
  });
}
```

#### RoleBasedWidget
```dart
class RoleBasedWidget extends StatelessWidget {
  final auth.UserRole requiredRole;
  final Widget child;
  final Widget? fallback;

  const RoleBasedWidget({
    required this.requiredRole,
    required this.child,
    this.fallback,
    super.key,
  });
}
```

#### RoleSpecificWidget
```dart
class RoleSpecificWidget extends StatelessWidget {
  final Map<auth.UserRole, Widget> roleWidgets;
  final Widget? fallback;

  const RoleSpecificWidget({
    required this.roleWidgets,
    this.fallback,
    super.key,
  });
}
```

#### RoleBasedNavigationItem
```dart
class RoleBasedNavigationItem extends StatelessWidget {
  final auth.UserRole requiredRole;
  final Widget child;
  final VoidCallback? onTap;

  const RoleBasedNavigationItem({
    required this.requiredRole,
    required this.child,
    this.onTap,
    super.key,
  });
}
```

### Role Hierarchy System

#### User Roles (9 Levels)
```dart
enum UserRole {
  admin,        // Level 10 - Full system access
  shopOwner,    // Level 9  - Business operations
  supervisor,   // Level 8  - Team management
  employee,     // Level 5  - General employee
  tailor,       // Level 4  - Specialized sewing
  cutter,       // Level 4  - Specialized cutting
  finisher,     // Level 4  - Specialized finishing
  apprentice,   // Level 2  - Training level
  customer,     // Level 1  - External customers
}
```

#### Role Hierarchy Logic
```dart
final roleHierarchy = {
  auth.UserRole.admin: 10,           // Full access
  auth.UserRole.shopOwner: 9,        // High-level business operations
  auth.UserRole.supervisor: 8,       // Team supervision
  auth.UserRole.employee: 5,         // General employee
  auth.UserRole.tailor: 4,           // Specialized tailor
  auth.UserRole.cutter: 4,           // Specialized cutter
  auth.UserRole.finisher: 4,         // Specialized finisher
  auth.UserRole.apprentice: 2,       // Training level
  auth.UserRole.customer: 1,         // External customer
};
```

### Permission System

#### Granular Permissions by Role
```dart
// Admin permissions (complete access)
final adminPermissions = [
  'create_user', 'read_user', 'update_user', 'delete_user',
  'create_order', 'read_order', 'update_order', 'delete_order',
  'create_product', 'read_product', 'update_product', 'delete_product',
  'create_inventory', 'read_inventory', 'update_inventory', 'delete_inventory',
  'view_analytics', 'view_reports', 'export_data',
  'system_settings', 'business_config', 'security_settings',
];

// Shop Owner permissions (business operations)
final shopOwnerPermissions = [
  'read_user', 'update_user',
  'create_order', 'read_order', 'update_order', 'delete_order',
  'create_product', 'read_product', 'update_product', 'delete_product',
  'read_inventory', 'update_inventory',
  'view_analytics', 'view_reports', 'export_data',
  'business_config',
];

// Customer permissions (limited access)
final customerPermissions = [
  'create_order', 'read_order', 'update_order',
  'read_product',
];
```

## Implementation Examples

### Route Protection
```dart
// Protect entire screens
RoleBasedRouteGuard(
  requiredRole: auth.UserRole.shopOwner,
  child: Scaffold(
    appBar: AppBar(title: const Text('Employee Management')),
    body: EmployeeManagementScreen(),
  ),
  fallbackWidget: Scaffold(
    body: Center(
      child: Text('Access denied - Shop Owner required'),
    ),
  ),
)
```

### Conditional Widget Rendering
```dart
// Show different content based on role
RoleBasedWidget(
  requiredRole: auth.UserRole.employee,
  child: ElevatedButton(
    onPressed: () => navigateToWorkAssignment(),
    child: const Text('View Work Assignments'),
  ),
  fallback: const SizedBox.shrink(), // Hide if no permission
)
```

### Role-Specific Content
```dart
// Different UI for different roles
RoleSpecificWidget(
  roleWidgets: {
    auth.UserRole.customer: CustomerDashboard(),
    auth.UserRole.shopOwner: ShopOwnerDashboard(),
    auth.UserRole.employee: EmployeeDashboard(),
  },
  fallback: const Text('Please log in to continue'),
)
```

### Navigation Item Protection
```dart
// Protected navigation items
RoleBasedNavigationItem(
  requiredRole: auth.UserRole.shopOwner,
  child: ListTile(
    leading: const Icon(Icons.analytics),
    title: const Text('Business Analytics'),
    onTap: () => navigateToAnalytics(),
  ),
)
// Automatically hidden if user doesn't have required role
```

### Context Extensions Usage
```dart
// Easy role checking in build methods
@override
Widget build(BuildContext context) {
  final isAdmin = context.isAdmin();
  final isShopOwner = context.isShopOwner();
  final currentRole = context.currentUserRole;

  return Column(
    children: [
      if (context.hasRole(auth.UserRole.employee))
        const Text('Employee Dashboard'),
      if (context.hasPermission('view_analytics'))
        const AnalyticsWidget(),
      Text('Current Role: ${currentRole?.displayName}'),
    ],
  );
}
```

## Role Descriptions

### Administrative Roles
- **Admin**: Complete system access, user management, system configuration
- **Shop Owner**: Business operations, inventory, analytics, customer management
- **Supervisor**: Team oversight, quality control, performance monitoring

### Operational Roles
- **Employee**: General operations, order processing, customer service
- **Tailor**: Specialized sewing, garment construction, pattern work
- **Cutter**: Fabric cutting, measurement accuracy, material optimization
- **Finisher**: Quality control, final touches, finishing operations

### Training & External Roles
- **Apprentice**: Training and learning, limited operational access
- **Customer**: External users, order management, service browsing

## Security Implementation

### Access Control Flow
```
User Action → Role Check → Permission Validation → Content Access
     ↓             ↓              ↓                    ↓
  Login      Role Hierarchy  Permission Matrix    Authorized Content
                    ↓              ↓                    ↓
             Inheritance     Granular Control    Fallback UI
                    ↓              ↓                    ↓
             Higher roles    Specific Actions    Access Denied
             get lower       for each feature    with clear message
             permissions
```

### Authentication Integration
```dart
// Integration with AuthProvider
class RoleBasedRouteGuard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;
        final userRole = authProvider.userRole;

        // Authentication checks
        if (currentUser == null) {
          return _buildFallback(context, 'Please log in to access this feature');
        }

        // Role hierarchy checks
        if (hasRequiredRole(userRole, requiredRole)) {
          return child ?? const SizedBox.shrink();
        }

        // Access denied
        return fallbackWidget ?? _buildAccessDenied(context);
      },
    );
  }
}
```

### Permission Validation
```dart
bool hasPermission(String permission) {
  final rolePermissions = {
    auth.UserRole.admin: ['create_user', 'view_analytics', 'system_settings'],
    auth.UserRole.shopOwner: ['create_order', 'view_analytics'],
    auth.UserRole.customer: ['create_order', 'read_product'],
    // ... other roles
  };

  final permissions = rolePermissions[this] ?? [];
  return permissions.contains(permission);
}
```

## User Experience Features

### Visual Feedback
```dart
// Access denied screen
Widget _buildAccessDenied(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Access Denied')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.block, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Access Denied', style: Theme.of(context).textTheme.headlineMedium),
          Text('You don\'t have permission to access this feature.'),
          Text('Required Role: ${requiredRole.name}'),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    ),
  );
}
```

### Login Redirect
```dart
// Automatic login redirect
Widget _buildFallback(BuildContext context, String message) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
          Text(message, textAlign: TextAlign.center),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    ),
  );
}
```

## Business Logic

### Role Hierarchy Validation
```dart
bool hasRequiredRole(auth.UserRole userRole, auth.UserRole requiredRole) {
  final roleHierarchy = {
    auth.UserRole.admin: 10,
    auth.UserRole.shopOwner: 9,
    auth.UserRole.supervisor: 8,
    // ... other roles with levels
  };

  final userLevel = roleHierarchy[userRole] ?? 0;
  final requiredLevel = roleHierarchy[requiredRole] ?? 0;

  return userLevel >= requiredLevel;
}
```

### Permission Checking
```dart
bool hasPermission(String permission) {
  // Define permission mappings for each role
  final rolePermissions = {
    auth.UserRole.admin: ['create_user', 'view_analytics', 'system_settings'],
    auth.UserRole.shopOwner: ['create_order', 'view_analytics'],
    // ... other roles with their permissions
  };

  final permissions = rolePermissions[this] ?? [];
  return permissions.contains(permission);
}
```

## Integration Points

### With Authentication Provider
- **User Context**: Current user information and role
  - Related: [`lib/providers/auth_provider.dart`](../../providers/auth_provider.md)
- **Real-time Updates**: Live role and permission changes
- **Session Management**: User authentication state
- **Role Validation**: Permission checking integration

### With Navigation System
- **Route Protection**: Screen-level access control
- **Menu Items**: Dynamic navigation based on permissions
- **Deep Linking**: Permission-aware navigation
- **Breadcrumb Security**: Navigation state protection

### With Business Logic
- **Data Access**: Firebase security rules integration
- **UI Adaptation**: Dynamic interface based on user role
- **Feature Flags**: Role-based feature availability
- **Workflow Security**: Process-level permission checks

## Performance Optimizations

### Efficient Role Checking
- **Cached Permissions**: Role hierarchy caching
- **Minimal Rebuilds**: Optimized widget rebuilds
- **Lazy Evaluation**: On-demand permission checking
- **Memory Management**: Efficient state management

### Security Performance
- **Fast Validation**: Quick permission checks
- **Batch Operations**: Multiple permission validation
- **Stream Optimization**: Efficient real-time updates
- **Resource Cleanup**: Proper listener disposal

## Future Enhancements

### Advanced Security
- **Dynamic Permissions**: Runtime permission modifications
- **Time-Based Access**: Time-restricted permissions
- **Location-Based Access**: Geographic permission restrictions
- **Device-Based Access**: Trusted device validation

### Enhanced User Experience
- **Graceful Degradation**: Feature hiding vs access denial
- **Permission Requests**: Dynamic permission elevation
- **Audit Trails**: Permission usage tracking
- **Help Integration**: Context-sensitive help for access issues

### Business Intelligence
- **Permission Analytics**: Usage pattern analysis
- **Access Monitoring**: Security event logging
- **Compliance Reporting**: Permission audit reports
- **Risk Assessment**: Permission-based security analysis

---

*This Role-Based Guard system provides comprehensive security and access control for the tailoring shop management system, ensuring that users only see and access features appropriate to their roles while maintaining a smooth, secure user experience throughout the application.*