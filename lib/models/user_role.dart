// User Role and Permission System for Scalable Tailoring Services

/// User roles in the tailoring business
enum UserRole {
  customer,
  shopOwner,
  employee,
}

/// Employee specialties within the employee role
enum EmployeeSpecialty {
  tailor, // Pattern making, alterations, sewing
  cutter, // Fabric cutting, marking, templates
  finisher, // Quality control, pressing, finishing
  supervisor, // Team management, scheduling, oversight
  apprentice, // Training, basic assistance
  inventory, // Stock management, supplies tracking
  customerSvc, // Customer communication, order handling
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
  }

  /// Check if one role can access resources of another role
  static bool canAccessRole(UserRole accessorRole, UserRole targetRole) {
    return getRoleHierarchy(accessorRole) >= getRoleHierarchy(targetRole);
  }
}

/// Specialty-based feature access for employees
class SpecialtyFeatures {
  /// Features accessible to each specialty
  static const Map<EmployeeSpecialty, Set<String>> featureAccess = {
    EmployeeSpecialty.tailor: {
      'pattern_design',
      'alterations',
      'sewing_tools',
      'fabric_measurement',
      'customer_fitting',
    },
    EmployeeSpecialty.cutter: {
      'fabric_inventory',
      'cutting_templates',
      'fabric_marking',
      'waste_management',
      'supplier_orders',
    },
    EmployeeSpecialty.finisher: {
      'quality_control',
      'pressing_station',
      'finishing_reports',
      'final_inspection',
      'packaging_preparation',
    },
    EmployeeSpecialty.supervisor: {
      'employee_management',
      'schedule_view',
      'performance_reports',
      'quality_oversight',
      'work_assignment',
    },
    EmployeeSpecialty.inventory: {
      'stock_management',
      'warehouse_access',
      'supply_tracking',
      'inventory_reports',
      'reorder_alerts',
    },
    EmployeeSpecialty.customerSvc: {
      'customer_communication',
      'order_history',
      'complaint_handling',
      'appointment_scheduling',
      'feedback_collection',
    },
    EmployeeSpecialty.apprentice: {
      'basic_training',
      'assistance_tasks',
      'observation_access',
      'learning_materials',
    },
  };

  /// Get all features accessible to an employee with multiple specialties
  static Set<String> getEmployeeFeatures(List<EmployeeSpecialty> specialties) {
    final features = <String>{};
    for (final specialty in specialties) {
      features.addAll(featureAccess[specialty] ?? {});
    }
    return features;
  }

  /// Check if employee can access a specific feature
  static bool canAccessFeature(
      List<EmployeeSpecialty> specialties, String feature) {
    return getEmployeeFeatures(specialties).contains(feature);
  }

  /// Get primary specialty display name
  static String getPrimarySpecialtyName(List<EmployeeSpecialty> specialties) {
    if (specialties.isEmpty) return 'General';
    return specialties.first.displayName;
  }
}

/// Employee specialty extension methods
extension EmployeeSpecialtyExtension on EmployeeSpecialty {
  String get displayName {
    switch (this) {
      case EmployeeSpecialty.tailor:
        return 'Tailor';
      case EmployeeSpecialty.cutter:
        return 'Cutter';
      case EmployeeSpecialty.finisher:
        return 'Finisher';
      case EmployeeSpecialty.supervisor:
        return 'Supervisor';
      case EmployeeSpecialty.apprentice:
        return 'Apprentice';
      case EmployeeSpecialty.inventory:
        return 'Inventory';
      case EmployeeSpecialty.customerSvc:
        return 'Customer Service';
    }
  }

  String get description {
    switch (this) {
      case EmployeeSpecialty.tailor:
        return 'Pattern making, alterations, and sewing';
      case EmployeeSpecialty.cutter:
        return 'Fabric cutting, marking, and waste management';
      case EmployeeSpecialty.finisher:
        return 'Quality control, pressing, and final touches';
      case EmployeeSpecialty.supervisor:
        return 'Team management, scheduling, and oversight';
      case EmployeeSpecialty.apprentice:
        return 'Training and basic assistance tasks';
      case EmployeeSpecialty.inventory:
        return 'Stock management and supply tracking';
      case EmployeeSpecialty.customerSvc:
        return 'Customer communication and order handling';
    }
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
      case UserRole.employee:
        return 'Employee';
    }
  }

  String get description {
    switch (this) {
      case UserRole.customer:
        return 'External customer with order management access';
      case UserRole.shopOwner:
        return 'Business owner with full operational access';
      case UserRole.employee:
        return 'General employee with standard operational access';
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
      case UserRole.shopOwner:
        return 10;
      case UserRole.employee:
        return 5;
      case UserRole.customer:
        return 1;
    }
  }

  bool canAccessRole(UserRole targetRole) {
    return hierarchyLevel >= targetRole.hierarchyLevel;
  }
}
