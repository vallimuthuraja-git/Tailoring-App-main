# User Role and Permission System Documentation

## Overview
The `user_role.dart` file contains the comprehensive role-based access control (RBAC) system for the AI-Enabled Tailoring Shop Management System. It provides granular permission management, role hierarchy, and secure access control for all system operations across 13 different user roles and 28+ permissions.

## Architecture

### Core Components
- **`UserRole`**: 13 predefined roles for the tailoring business
- **`Permission`**: 28 granular permissions for different operations
- **`RolePermissions`**: Role-based permission mapping system
- **`UserRoleExtension`**: Extension methods for role functionality

### Key Features
- **Hierarchical Access Control**: Role-based permission inheritance
- **Granular Permissions**: Fine-grained access control for all operations
- **Business Logic Integration**: Tailored for tailoring shop operations
- **Extension Methods**: Convenient role-based operations
- **Security-First Design**: Principle of least privilege implementation

## UserRole Enum

### Business Roles Hierarchy

#### Management Roles (High-Level Access)
```dart
enum UserRole {
  businessOwner,        // Full access to everything - CEO/Owner level
  generalManager,       // High-level business operations - COO level
  operationsManager,    // Day-to-day operations management - Operations Director
}
```

#### Sales & Customer Service Roles
```dart
salesManager,                    // Sales operations and customer relations
salesRepresentative,             // Individual sales and customer service
customerServiceRepresentative,   // Customer support and service
```

#### Production & Quality Roles
```dart
productionSupervisor,   // Production floor management
qualityInspector,       // Quality control and inspection
tailor,                // Production staff (seamstresses, tailors)
```

#### Administrative & Support Roles
```dart
officeManager,     // Administrative operations
accountant,        // Financial management
inventoryManager,  // Inventory and supply management
```

#### External Users
```dart
customer,   // External customers with limited access
```

## Permission Enum

### User Management Permissions
```dart
enum Permission {
  createUser,   // Create new user accounts
  readUser,     // View user information
  updateUser,   // Modify user profiles
  deleteUser,   // Remove user accounts
}
```

### Employee Management Permissions
```dart
createEmployee,   // Hire new employees
readEmployee,     // View employee information
updateEmployee,   // Modify employee records
deleteEmployee,   // Terminate employees
```

### Customer Management Permissions
```dart
createCustomer,   // Register new customers
readCustomer,     // View customer information
updateCustomer,   // Modify customer profiles
deleteCustomer,   // Remove customer accounts
```

### Order Management Permissions
```dart
createOrder,     // Create new orders
readOrder,       // View order information
updateOrder,     // Modify order details
deleteOrder,     // Cancel orders
assignOrder,     // Assign orders to employees
reassignOrder,   // Reassign orders between employees
```

### Product Management Permissions
```dart
createProduct,   // Add new products
readProduct,     // View product catalog
updateProduct,   // Modify product information
deleteProduct,   // Remove products
```

### Inventory Management Permissions
```dart
createInventory,   // Add inventory items
readInventory,     // View inventory levels
updateInventory,   // Modify inventory quantities
deleteInventory,   // Remove inventory items
```

### Financial Management Permissions
```dart
createTransaction,     // Record financial transactions
readTransaction,       // View financial records
updateTransaction,     // Modify transaction details
deleteTransaction,     // Remove transactions
viewFinancialReports,  // Access financial reporting
managePricing,         // Set and modify pricing
```

### Work Assignment Permissions
```dart
createWorkAssignment,   // Create work assignments
readWorkAssignment,     // View assignment details
updateWorkAssignment,   // Modify assignment status
deleteWorkAssignment,   // Remove assignments
```

### Analytics and Reporting Permissions
```dart
viewAnalytics,   // Access business analytics
viewReports,     // View various reports
exportData,      // Export data to external formats
```

### System Administration Permissions
```dart
systemSettings,    // Modify system configuration
businessConfig,    // Business rule configuration
securitySettings,  // Security policy management
manageRoles,       // Role and permission management
```

## RolePermissions Class

### Permission Mapping System
```dart
class RolePermissions {
  static final Map<UserRole, Set<Permission>> permissions = {
    UserRole.businessOwner: {
      // Complete access to all permissions
      Permission.createUser,
      Permission.readUser,
      Permission.updateUser,
      Permission.deleteUser,
      // ... all other permissions
    },
    // ... other role mappings
  };
}
```

### Permission Checking Methods

#### Individual Permission Check
```dart
static bool hasPermission(UserRole role, Permission permission) {
  final rolePermissions = permissions[role];
  return rolePermissions?.contains(permission) ?? false;
}
```

#### Multiple Permissions Check
```dart
static bool hasAnyPermission(UserRole role, List<Permission> permissions) {
  final rolePermissions = RolePermissions.permissions[role];
  return rolePermissions?.any((p) => permissions.contains(p)) ?? false;
}
```

#### Get All Role Permissions
```dart
static Set<Permission> getPermissionsForRole(UserRole role) {
  return permissions[role] ?? {};
}
```

### Role Hierarchy System

#### Hierarchy Levels
```dart
static int getRoleHierarchy(UserRole role) {
  switch (role) {
    case UserRole.businessOwner:
      return 10;  // Highest level
    case UserRole.generalManager:
      return 9;
    case UserRole.operationsManager:
      return 8;
    // ... decreasing hierarchy
    case UserRole.customer:
      return 1;   // Lowest level
    default:
      return 0;
  }
}
```

#### Access Control Validation
```dart
static bool canAccessRole(UserRole accessorRole, UserRole targetRole) {
  return getRoleHierarchy(accessorRole) >= getRoleHierarchy(targetRole);
}
```

## UserRoleExtension

### Display and Description Methods
```dart
extension UserRoleExtension on UserRole {
  String get displayName {
    // Returns human-readable role names
    switch (this) {
      case UserRole.businessOwner:
        return 'Business Owner';
      case UserRole.tailor:
        return 'Tailor/Seamstress';
      // ... other display names
    }
  }

  String get description {
    // Returns detailed role descriptions
    switch (this) {
      case UserRole.businessOwner:
        return 'Complete business oversight and strategic decision-making';
      case UserRole.tailor:
        return 'Garment construction and production work';
      // ... other descriptions
    }
  }
}
```

### Permission Convenience Methods
```dart
bool hasPermission(Permission permission) {
  return RolePermissions.hasPermission(this, permission);
}

bool hasAnyPermission(List<Permission> permissions) {
  return RolePermissions.hasAnyPermission(this, permissions);
}

Set<Permission> get allPermissions {
  return RolePermissions.getPermissionsForRole(this);
}

int get hierarchyLevel {
  return RolePermissions.getRoleHierarchy(this);
}

bool canAccessRole(UserRole targetRole) {
  return RolePermissions.canAccessRole(this, targetRole);
}
```

## Detailed Role Permissions

### Business Owner (Level 10)
**All Permissions**: Complete system access including:
- User and employee management
- Customer relationship management
- Order lifecycle management
- Product catalog management
- Financial operations
- System administration
- Analytics and reporting

### General Manager (Level 9)
**High-Level Operations**: Most permissions except system-level configuration:
- Employee management (hire/fire)
- Customer and order management
- Financial reporting
- Analytics and exports
- Business configuration (limited)

### Operations Manager (Level 8)
**Daily Operations**: Operations-focused permissions:
- Order assignment and management
- Employee supervision
- Inventory control
- Production workflow management
- Operational analytics

### Sales Manager (Level 7)
**Sales Leadership**: Sales and customer management:
- Customer relationship management
- Order processing and assignment
- Pricing management
- Sales analytics and reporting
- Team supervision

### Production Supervisor (Level 6)
**Production Management**: Production-focused permissions:
- Order assignment and reassignment
- Work assignment management
- Production analytics
- Quality control oversight
- Team coordination

### Specialized Roles (Level 5)
**Accountant, Inventory Manager, Office Manager**:
- Domain-specific permissions
- Reporting and analytics access
- Specialized operational control

### Customer Service Roles (Level 4)
**Sales Representatives, Customer Service Representatives**:
- Customer interaction permissions
- Order management (limited)
- Service-oriented access
- Customer data management

### Quality Inspector (Level 3)
**Quality Control**: Quality-focused permissions:
- Order quality assessment
- Work assignment updates
- Quality reporting
- Inspection workflow management

### Tailor (Level 2)
**Production Staff**: Minimal permissions for production work:
- Assigned order access
- Work assignment updates
- Product information access
- Limited operational access

### Customer (Level 1)
**External Users**: Very limited permissions:
- Personal order management
- Product catalog browsing
- Order creation and updates
- Limited self-service access

## Usage Examples

### Permission Checking
```dart
class OrderManagementScreen extends StatelessWidget {
  final UserRole currentUserRole;

  bool canCreateOrder() {
    return currentUserRole.hasPermission(Permission.createOrder);
  }

  bool canAssignOrder() {
    return currentUserRole.hasPermission(Permission.assignOrder);
  }

  bool canDeleteOrder() {
    return currentUserRole.hasPermission(Permission.deleteOrder);
  }

  bool isManagerOrHigher() {
    return currentUserRole.hasAnyPermission([
      Permission.assignOrder,
      Permission.reassignOrder,
      Permission.managePricing,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (canCreateOrder())
          ElevatedButton(
            onPressed: () => _createOrder(),
            child: Text('Create Order'),
          ),
        if (canAssignOrder())
          ElevatedButton(
            onPressed: () => _assignOrder(),
            child: Text('Assign Order'),
          ),
        if (canDeleteOrder())
          ElevatedButton(
            onPressed: () => _deleteOrder(),
            child: Text('Delete Order'),
          ),
      ],
    );
  }
}
```

### Role-Based UI Components
```dart
class RoleBasedWidget extends StatelessWidget {
  final UserRole userRole;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!userRole.hasPermission(Permission.viewAnalytics)) {
      return Container(); // Hide widget if no permission
    }

    return child;
  }
}

class RoleBasedNavigation extends StatelessWidget {
  final UserRole userRole;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Dashboard'),
          onTap: () => Navigator.pushNamed(context, '/dashboard'),
        ),
        if (userRole.hasPermission(Permission.createOrder))
          ListTile(
            title: Text('Create Order'),
            onTap: () => Navigator.pushNamed(context, '/create-order'),
          ),
        if (userRole.hasPermission(Permission.readEmployee))
          ListTile(
            title: Text('Employee Management'),
            onTap: () => Navigator.pushNamed(context, '/employees'),
          ),
        if (userRole.hasPermission(Permission.viewFinancialReports))
          ListTile(
            title: Text('Financial Reports'),
            onTap: () => Navigator.pushNamed(context, '/reports'),
          ),
        if (userRole.hasPermission(Permission.systemSettings))
          ListTile(
            title: Text('System Settings'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
      ],
    );
  }
}
```

### Permission Validation Service
```dart
class PermissionService {
  static bool checkPermission(UserRole role, Permission permission) {
    return RolePermissions.hasPermission(role, permission);
  }

  static bool checkAnyPermission(UserRole role, List<Permission> permissions) {
    return RolePermissions.hasAnyPermission(role, permissions);
  }

  static Set<Permission> getRolePermissions(UserRole role) {
    return RolePermissions.getPermissionsForRole(role);
  }

  static bool canAccessResource(UserRole accessorRole, UserRole resourceOwnerRole) {
    return RolePermissions.canAccessRole(accessorRole, resourceOwnerRole);
  }

  static List<UserRole> getAccessibleRoles(UserRole accessorRole) {
    return UserRole.values.where((role) {
      return RolePermissions.canAccessRole(accessorRole, role);
    }).toList();
  }
}
```

### Role Management Interface
```dart
class RoleManagementScreen extends StatefulWidget {
  @override
  _RoleManagementScreenState createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  UserRole selectedRole = UserRole.customer;

  @override
  Widget build(BuildContext context) {
    final rolePermissions = selectedRole.allPermissions;
    final hierarchyLevel = selectedRole.hierarchyLevel;

    return Scaffold(
      appBar: AppBar(
        title: Text('Role Management'),
      ),
      body: Column(
        children: [
          DropdownButton<UserRole>(
            value: selectedRole,
            items: UserRole.values.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text('${role.displayName} (Level ${role.hierarchyLevel})'),
              );
            }).toList(),
            onChanged: (role) => setState(() => selectedRole = role!),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              selectedRole.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: rolePermissions.length,
              itemBuilder: (context, index) {
                final permission = rolePermissions.elementAt(index);
                return ListTile(
                  title: Text(_formatPermissionName(permission)),
                  leading: Icon(Icons.check_circle, color: Colors.green),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatPermissionName(Permission permission) {
    return permission.toString().split('.').last.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim();
  }
}
```

## Integration Points

### Related Components
- **Auth Provider**: User authentication and role assignment
- **Role-Based Guards**: UI component access control
- **Permission Service**: Centralized permission checking
- **User Management Screens**: Role assignment interfaces
- **Audit Logging**: Permission usage tracking

### Dependencies
- **Firebase Auth**: User authentication integration
- **Cloud Firestore**: Role data persistence
- **Provider Package**: State management integration
- **Flutter Framework**: UI component access control

## Security Considerations

### Access Control Principles
- **Principle of Least Privilege**: Users get minimum required permissions
- **Role Separation**: Clear separation between different business functions
- **Hierarchical Access**: Higher roles can access lower role resources
- **Permission Granularity**: Fine-grained control over all operations

### Security Best Practices
- **Regular Audits**: Periodic review of role assignments
- **Permission Changes**: Logged changes to role permissions
- **Access Monitoring**: Track permission usage for security
- **Role Lifecycle**: Proper role assignment and revocation

## Performance Optimization

### Permission Checking Efficiency
- **Static Permission Maps**: Pre-computed permission mappings
- **Fast Lookup**: O(1) permission checking complexity
- **Cached Results**: Avoid repeated permission calculations
- **Minimal Memory Usage**: Efficient data structures

### Scalability Considerations
- **Role Extension**: Easy addition of new roles
- **Permission Extension**: Simple addition of new permissions
- **Hierarchy Flexibility**: Adaptable role hierarchy system
- **Multi-tenancy Ready**: Supports multiple business units

## Business Logic

### Tailoring Business Roles
- **Business Owner**: Strategic oversight and final decisions
- **General Manager**: High-level operations and team leadership
- **Operations Manager**: Daily production and workflow management
- **Sales Team**: Customer acquisition and relationship management
- **Production Staff**: Garment construction and quality control
- **Administrative Roles**: Support functions and coordination
- **External Customers**: Self-service access with limited permissions

### Permission Categories
- **Management Permissions**: User and system administration
- **Operational Permissions**: Day-to-day business operations
- **Financial Permissions**: Accounting and financial management
- **Customer Permissions**: Customer relationship management
- **Production Permissions**: Manufacturing and quality control
- **Reporting Permissions**: Analytics and business intelligence

This comprehensive role-based access control system provides enterprise-grade security while remaining tailored to the specific needs of a tailoring shop business, supporting everything from strategic business decisions to individual production tasks with appropriate permission levels.