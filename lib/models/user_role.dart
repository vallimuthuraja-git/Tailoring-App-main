// User Role and Permission System for Scalable Tailoring Services

/// User roles in the tailoring business
enum UserRole {
  customer,
  shopOwner,
  admin,
  employee,
  tailor, // Master tailor/couturier
  cutter, // Fabric cutting specialist
  finisher, // Final touches and quality control
  supervisor, // Team supervisor/manager
  apprentice, // Training/new employee
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
      case UserRole.admin:
      case UserRole.shopOwner:
        return 10;
      case UserRole.supervisor:
        return 8;
      case UserRole.employee:
      case UserRole.tailor:
      case UserRole.cutter:
      case UserRole.finisher:
        return 5;
      case UserRole.apprentice:
        return 2;
      case UserRole.customer:
        return 1;
    }
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
      case UserRole.customer:
        return 'Customer';
      case UserRole.shopOwner:
        return 'Shop Owner';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.employee:
        return 'Employee';
      case UserRole.tailor:
        return 'Master Tailor';
      case UserRole.cutter:
        return 'Fabric Cutter';
      case UserRole.finisher:
        return 'Finisher';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.apprentice:
        return 'Apprentice';
    }
  }

  String get description {
    switch (this) {
      case UserRole.customer:
        return 'External customer with order management access';
      case UserRole.shopOwner:
        return 'Business owner with full operational access';
      case UserRole.admin:
        return 'System administrator with complete access';
      case UserRole.employee:
        return 'General employee with standard access';
      case UserRole.tailor:
        return 'Specialized in garment construction';
      case UserRole.cutter:
        return 'Specialized in fabric cutting';
      case UserRole.finisher:
        return 'Specialized in final touches and quality';
      case UserRole.supervisor:
        return 'Team supervisor with management access';
      case UserRole.apprentice:
        return 'Training level with limited access';
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
    switch (this) {
      case UserRole.admin:
        return 10;
      case UserRole.shopOwner:
        return 9;
      case UserRole.supervisor:
        return 8;
      case UserRole.employee:
        return 5;
      case UserRole.tailor:
      case UserRole.cutter:
      case UserRole.finisher:
        return 4;
      case UserRole.apprentice:
        return 2;
      case UserRole.customer:
        return 1;
    }
  }

  bool canAccessRole(UserRole targetRole) {
    return this.hierarchyLevel >= targetRole.hierarchyLevel;
  }
}
