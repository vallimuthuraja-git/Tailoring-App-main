# User Role Model

## Overview
The `user_role.dart` file defines the comprehensive Role-Based Access Control (RBAC) system for the AI-Enabled Tailoring Shop Management System. It implements a hierarchical permission system with granular access controls for different user types.

## Key Components

### UserRole Enum
Defines all possible user roles in the tailoring business hierarchy:

#### Management Roles
- **`businessOwner`**: Complete system access and strategic control
- **`generalManager`**: High-level business operations management
- **`operationsManager`**: Day-to-day operations oversight

#### Sales & Customer Service Roles
- **`salesManager`**: Sales team leadership and customer relations
- **`salesRepresentative`**: Individual sales and customer service
- **`customerServiceRepresentative`**: Customer support and service

#### Production & Quality Roles
- **`productionSupervisor`**: Production floor management
- **`qualityInspector`**: Quality control and inspection
- **`tailor`**: Production staff (seamstresses, tailors)

#### Administrative & Support Roles
- **`officeManager`**: Administrative operations
- **`accountant`**: Financial management and reporting
- **`inventoryManager`**: Inventory and supply chain management

#### External Roles
- **`customer`**: External customers with limited access

### Permission Enum
Granular permissions covering all system operations:

#### User Management Permissions
- `createUser`, `readUser`, `updateUser`, `deleteUser`

#### Business Entity Permissions
- **Employee**: `createEmployee`, `readEmployee`, `updateEmployee`, `deleteEmployee`
- **Customer**: `createCustomer`, `readCustomer`, `updateCustomer`, `deleteCustomer`
- **Order**: `createOrder`, `readOrder`, `updateOrder`, `deleteOrder`, `assignOrder`, `reassignOrder`
- **Product**: `createProduct`, `readProduct`, `updateProduct`, `deleteProduct`

#### Operational Permissions
- **Inventory**: `createInventory`, `readInventory`, `updateInventory`, `deleteInventory`
- **Financial**: `createTransaction`, `readTransaction`, `updateTransaction`, `deleteTransaction`
- **Work Assignment**: `createWorkAssignment`, `readWorkAssignment`, `updateWorkAssignment`, `deleteWorkAssignment`

#### Administrative Permissions
- **Analytics**: `viewAnalytics`, `viewReports`, `exportData`
- **Financial**: `viewFinancialReports`, `managePricing`
- **System**: `systemSettings`, `businessConfig`, `securitySettings`, `manageRoles`

## RolePermissions Class

### Permission Mapping
Comprehensive mapping of roles to their allowed permissions:

```dart
static final Map<UserRole, Set<Permission>> permissions = {
  UserRole.businessOwner: {
    // All permissions for complete business control
    Permission.createUser,
    Permission.readUser,
    // ... all permissions
    Permission.manageRoles,
  },
  // ... other role mappings
};
```

### Permission Checking Methods
- **`hasPermission(UserRole, Permission)`**: Check specific permission
- **`hasAnyPermission(UserRole, List<Permission>)`**: Check multiple permissions
- **`getPermissionsForRole(UserRole)`**: Get all permissions for a role

### Role Hierarchy Methods
- **`getRoleHierarchy(UserRole)`**: Get numerical hierarchy level
- **`canAccessRole(UserRole, UserRole)`**: Check role access rights

## UserRoleExtension

### Display Properties
- **`displayName`**: Human-readable role names
- **`description`**: Detailed role descriptions and responsibilities

### Permission Methods
- **`hasPermission(Permission)`**: Instance method for permission checking
- **`hasAnyPermission(List<Permission>)`**: Check multiple permissions
- **`allPermissions`**: Get all permissions for this role instance

### Hierarchy Methods
- **`hierarchyLevel`**: Get numerical hierarchy level for this role
- **`canAccessRole(UserRole)`**: Check if this role can access another role

## Role Hierarchy Levels

```
10 - Business Owner (Complete Access)
 9 - General Manager (Most Permissions)
 8 - Operations Manager (Operations Focus)
 7 - Sales Manager (Sales & Customer Focus)
 6 - Production Supervisor (Production Management)
 5 - Administrative Roles (Office Manager, Accountant, Inventory Manager)
 4 - Sales Representatives & Customer Service
 3 - Quality Inspector (Quality Control)
 2 - Tailor (Production Staff)
 1 - Customer (External Access)
```

## Integration Points

### Authentication System
- **User Registration**: Role assignment during signup
  - Related: [`lib/screens/auth/signup_screen.dart`](../screens/auth/signup_screen.md)
- **Login Process**: Role-based dashboard routing
  - Related: [`lib/screens/auth/login_screen.dart`](../screens/auth/login_screen.md)

### Provider Integration
- **Auth Provider**: Role-based state management
  - Related: [`lib/providers/auth_provider.dart`](../lib/providers/auth_provider.md)
- **Theme Provider**: Role-based feature access
  - Related: [`lib/providers/theme_provider.dart`](../lib/providers/theme_provider.md)

### Service Integration
- **Firebase Service**: Role-based data access
  - Related: [`lib/services/firebase_service.dart`](../lib/services/firebase_service.md)
- **Demo Setup**: Pre-configured role accounts
  - Related: [`lib/services/setup_demo_users.dart`](../lib/services/setup_demo_users.md)

### UI Integration
- **Role-Based Guards**: Conditional UI rendering
  - Related: [`lib/widgets/role_based_guard.dart`](../lib/widgets/role_based_guard.md)
- **Dashboard Routing**: Role-specific home screens
  - Related: [`lib/screens/home/home_screen.dart`](../lib/screens/home/home_screen.md)

## Usage Examples

### Permission Checking
```dart
// Check specific permission
if (UserRole.businessOwner.hasPermission(Permission.createUser)) {
  // Allow user creation
}

// Check multiple permissions
if (currentUser.hasAnyPermission([
  Permission.createOrder,
  Permission.updateOrder
])) {
  // Show order management options
}
```

### Role Hierarchy
```dart
// Check if manager can access employee data
if (UserRole.generalManager.canAccessRole(UserRole.tailor)) {
  // Allow access to tailor information
}
```

### UI Conditional Rendering
```dart
if (currentUser.hasPermission(Permission.viewAnalytics)) {
  return AnalyticsDashboard();
} else {
  return StandardDashboard();
}
```

## Security Considerations

### Access Control
- **Granular Permissions**: Specific permissions for each operation
- **Role Hierarchy**: Higher roles can access lower role resources
- **Separation of Concerns**: Different roles for different responsibilities

### Data Security
- **Field-Level Access**: Control access to specific data fields
- **Operation-Level Security**: Control create, read, update, delete operations
- **Audit Trail**: Track permission usage and changes

### Authentication Integration
- **JWT Tokens**: Firebase Auth integration with custom claims
- **Session Management**: Secure session handling
- **Logout Security**: Proper session cleanup

## Performance Optimizations

### Permission Caching
- **Static Mapping**: Pre-computed permission sets
- **Fast Lookups**: O(1) permission checking
- **Memory Efficient**: Minimal memory footprint

### Lazy Evaluation
- **On-Demand Checking**: Permissions checked when needed
- **Efficient Queries**: Optimized database queries based on roles
- **Batch Operations**: Handle multiple permission checks efficiently

## Testing Integration

### Unit Tests
- **Permission Testing**: Test individual permission checks
- **Role Testing**: Test role hierarchy and access control
- **Edge Cases**: Test boundary conditions and error cases

### Integration Tests
- **Authentication Flow**: Test login with different roles
- **UI Testing**: Test conditional rendering based on roles
- **Data Access**: Test role-based data access patterns

## Related Files

### Authentication & User Management
- [`lib/providers/auth_provider.dart`](../lib/providers/auth_provider.md) - Authentication state management
- [`lib/services/auth_service.dart`](../lib/services/auth_service.md) - Firebase authentication
- [`lib/models/customer.dart`](../lib/models/customer.md) - Customer data model
- [`lib/models/employee.dart`](../lib/models/employee.md) - Employee data model

### UI Components
- [`lib/screens/auth/login_screen.dart`](../lib/screens/auth/login_screen.md) - Role-based login
- [`lib/screens/auth/signup_screen.dart`](../lib/screens/auth/signup_screen.md) - Role selection during signup
- [`lib/widgets/role_based_guard.dart`](../lib/widgets/role_based_guard.md) - Conditional rendering

### Documentation
- [`ROLE_BASED_ACCESS_CONTROL.md`](../ROLE_BASED_ACCESS_CONTROL.md.md) - RBAC system documentation
- [`lib/project_overview.md`](../lib/project_overview.md) - Project architecture

## Benefits

1. **Comprehensive Access Control**: Granular permissions for all operations
2. **Scalable Architecture**: Easy to add new roles and permissions
3. **Security First**: Robust access control prevents unauthorized access
4. **Developer Friendly**: Simple API for permission checking
5. **Performance Optimized**: Efficient permission checking and caching
6. **Maintainable**: Clear separation of roles and responsibilities
7. **Flexible**: Easy to modify permissions and add new roles
8. **Auditable**: Clear permission structure for security audits

## Future Enhancements

### Advanced Features
- **Dynamic Permissions**: Runtime permission modification
- **Time-Based Access**: Temporary permission grants
- **Approval Workflows**: Multi-step approval processes
- **Audit Logging**: Comprehensive access logging

### Integration Features
- **Third-Party SSO**: Integration with external identity providers
- **MFA Support**: Multi-factor authentication
- **Device-Based Access**: Location and device restrictions
- **Compliance Features**: GDPR and security compliance

---

*This comprehensive RBAC system provides the foundation for secure, role-based access control throughout the AI-Enabled Tailoring Shop Management System, ensuring that each user has appropriate access to system features and data based on their organizational role and responsibilities.*