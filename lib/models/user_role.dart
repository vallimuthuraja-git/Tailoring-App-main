// User Role and Permission System for Scalable Tailoring Services

/// Simplified user roles in the tailoring business
enum UserRole {
  /// Shop Owner/Admin - Full access to everything including user management
  shopOwner,

  /// Customers - External users with order access
  customer,

  /// Employees - All employee types consolidated (tailors, cutters, finishers, etc.)
  employee,
}

/// Granular permissions for role-based access control
enum Permission {
  // User management
  createUser,
  readUser,
  updateUser,
  deleteUser,

  // Employee management
  createEmployee,
  readEmployee,
  updateEmployee,
  deleteEmployee,

  // Customer management
  createCustomer,
  readCustomer,
  updateCustomer,
  deleteCustomer,

  // Order management
  createOrder,
  readOrder,
  updateOrder,
  deleteOrder,
  assignOrder,
  reassignOrder,

  // Product management
  createProduct,
  readProduct,
  updateProduct,
  deleteProduct,

  // Inventory management
  createInventory,
  readInventory,
  updateInventory,
  deleteInventory,

  // Financial management
  createTransaction,
  readTransaction,
  updateTransaction,
  deleteTransaction,
  viewFinancialReports,
  managePricing,

  // Work assignment
  createWorkAssignment,
  readWorkAssignment,
  updateWorkAssignment,
  deleteWorkAssignment,

  // Analytics and reports
  viewAnalytics,
  viewReports,
  exportData,

  // System administration
  systemSettings,
  businessConfig,
  securitySettings,
  manageRoles,
}

/// Role-based permission mapping
class RolePermissions {
  static final Map<UserRole, Set<Permission>> permissions = {
    UserRole.shopOwner: {
      // All permissions for shop owner
      Permission.createUser,
      Permission.readUser,
      Permission.updateUser,
      Permission.deleteUser,
      Permission.createEmployee,
      Permission.readEmployee,
      Permission.updateEmployee,
      Permission.deleteEmployee,
      Permission.createCustomer,
      Permission.readCustomer,
      Permission.updateCustomer,
      Permission.deleteCustomer,
      Permission.createOrder,
      Permission.readOrder,
      Permission.updateOrder,
      Permission.deleteOrder,
      Permission.assignOrder,
      Permission.reassignOrder,
      Permission.viewAnalytics,
      Permission.viewReports,
      Permission.exportData,
      Permission.systemSettings,
      Permission.businessConfig,
    },
    UserRole.employee: {
      // Employee permissions focused on their work
      Permission.readOrder,
      Permission.updateOrder,
      Permission.readWorkAssignment,
      Permission.updateWorkAssignment,
      Permission.viewReports,
    },
    UserRole.customer: {
      // Customer permissions focused on placing and managing their orders
      Permission.createOrder,
      Permission.readOrder,
      Permission.updateOrder,
    },
  };

  /// Check if a role has a specific permission
  static bool hasPermission(UserRole role, Permission permission) {
    final rolePermissions = permissions[role];
    return rolePermissions?.contains(permission) ?? false;
  }

  /// Check if a role has any of the specified permissions
  static bool hasAnyPermission(UserRole role, List<Permission> permissions) {
    final rolePermissions = RolePermissions.permissions[role];
    return rolePermissions?.any((p) => permissions.contains(p)) ?? false;
  }

  /// Get all permissions for a role
  static Set<Permission> getPermissionsForRole(UserRole role) {
    return permissions[role] ?? {};
  }

  /// Check role hierarchy (higher number = more permissions)
  static int getRoleHierarchy(UserRole role) {
    switch (role) {
      case UserRole.shopOwner:
        return 10;
      case UserRole.employee:
        return 5;
      case UserRole.customer:
        return 1;
    }
    // This should never be reached since we've covered all enum values
    return 0;
  }

  /// Check if one role can access resources of another role
  static bool canAccessRole(UserRole accessorRole, UserRole targetRole) {
    return getRoleHierarchy(accessorRole) >= getRoleHierarchy(targetRole);
  }
}

/// User role extension methods
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.shopOwner:
        return 'Shop Owner';
      case UserRole.employee:
        return 'Employee';
      case UserRole.customer:
        return 'Customer';
    }
  }

  String get description {
    switch (this) {
      case UserRole.shopOwner:
        return 'Full shop management with user and employee administration';
      case UserRole.employee:
        return 'Tailoring professional with order and assignment management';
      case UserRole.customer:
        return 'Customer with order placement and management access';
    }
  }

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
}
