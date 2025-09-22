// Role-Based Access Control Widgets for Tailoring Services

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart' as auth;
import '../providers/auth_provider.dart';

/// Widget that guards routes based on user roles
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;
        final userRole = authProvider.userRole;

        // If no user is logged in, show login screen
        if (currentUser == null) {
          return _buildFallback(
              context, 'Please log in to access this feature');
        }

        // Check if user has required role or higher
        if (hasRequiredRole(userRole, requiredRole)) {
          return child ?? const SizedBox.shrink();
        }

        // Show fallback widget or access denied message
        return fallbackWidget ?? _buildAccessDenied(context);
      },
    );
  }

  bool hasRequiredRole(auth.UserRole userRole, auth.UserRole requiredRole) {
    // Role hierarchy logic - higher number = more permissions
    final roleHierarchy = {
      auth.UserRole.admin: 10, // Full access (equivalent to business owner)
      auth.UserRole.shopOwner: 9, // High-level business operations
      auth.UserRole.supervisor: 8, // Team supervision
      auth.UserRole.employee: 5, // General employee
      auth.UserRole.tailor: 4, // Specialized tailor
      auth.UserRole.cutter: 4, // Specialized cutter
      auth.UserRole.finisher: 4, // Specialized finisher
      auth.UserRole.apprentice: 2, // Training level
      auth.UserRole.customer: 1, // External customer
    };

    final userLevel = roleHierarchy[userRole] ?? 0;
    final requiredLevel = roleHierarchy[requiredRole] ?? 0;

    return userLevel >= requiredLevel;
  }

  Widget _buildFallback(BuildContext context, String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to login or appropriate fallback
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.block,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Access Denied',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have permission to access this feature.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Required Role: ${requiredRole.name}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that shows content only if user has required role or higher
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.userRole;

        final roleHierarchy = {
          auth.UserRole.admin: 10,
          auth.UserRole.shopOwner: 9,
          auth.UserRole.supervisor: 8,
          auth.UserRole.employee: 5,
          auth.UserRole.tailor: 4,
          auth.UserRole.cutter: 4,
          auth.UserRole.finisher: 4,
          auth.UserRole.apprentice: 2,
          auth.UserRole.customer: 1,
        };

        final userLevel = roleHierarchy[userRole] ?? 0;
        final requiredLevel = roleHierarchy[requiredRole] ?? 0;

        if (userLevel >= requiredLevel) {
          return child ?? const SizedBox.shrink();
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Widget that shows different content based on user role
class RoleSpecificWidget extends StatelessWidget {
  final Map<auth.UserRole, Widget> roleWidgets;
  final Widget? fallback;

  const RoleSpecificWidget({
    required this.roleWidgets,
    this.fallback,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.userRole;

        if (roleWidgets.containsKey(userRole)) {
          return roleWidgets[userRole]!;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Widget for role-based navigation items
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.userRole;

        final roleHierarchy = {
          auth.UserRole.admin: 10,
          auth.UserRole.shopOwner: 9,
          auth.UserRole.supervisor: 8,
          auth.UserRole.employee: 5,
          auth.UserRole.tailor: 4,
          auth.UserRole.cutter: 4,
          auth.UserRole.finisher: 4,
          auth.UserRole.apprentice: 2,
          auth.UserRole.customer: 1,
        };

        final userLevel = roleHierarchy[userRole] ?? 0;
        final requiredLevel = roleHierarchy[requiredRole] ?? 0;

        if (userLevel >= requiredLevel) {
          if (onTap != null) {
            return InkWell(
              onTap: onTap,
              child: child,
            );
          }
          return child ?? const SizedBox.shrink();
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Extension methods for role checking
extension RoleCheck on auth.UserRole {
  String get displayName {
    switch (this) {
      case auth.UserRole.customer:
        return 'Customer';
      case auth.UserRole.shopOwner:
        return 'Shop Owner';
      case auth.UserRole.admin:
        return 'Administrator';
      case auth.UserRole.employee:
        return 'Employee';
      case auth.UserRole.tailor:
        return 'Master Tailor';
      case auth.UserRole.cutter:
        return 'Fabric Cutter';
      case auth.UserRole.finisher:
        return 'Finisher';
      case auth.UserRole.supervisor:
        return 'Supervisor';
      case auth.UserRole.apprentice:
        return 'Apprentice';
    }
  }

  String get description {
    switch (this) {
      case auth.UserRole.customer:
        return 'External customer with order management access';
      case auth.UserRole.shopOwner:
        return 'Business owner with full operational access';
      case auth.UserRole.admin:
        return 'System administrator with complete access';
      case auth.UserRole.employee:
        return 'General employee with standard access';
      case auth.UserRole.tailor:
        return 'Specialized in garment construction';
      case auth.UserRole.cutter:
        return 'Specialized in fabric cutting';
      case auth.UserRole.finisher:
        return 'Specialized in final touches and quality';
      case auth.UserRole.supervisor:
        return 'Team supervisor with management access';
      case auth.UserRole.apprentice:
        return 'Training level with limited access';
    }
  }

  int get hierarchyLevel {
    switch (this) {
      case auth.UserRole.admin:
        return 10;
      case auth.UserRole.shopOwner:
        return 9;
      case auth.UserRole.supervisor:
        return 8;
      case auth.UserRole.employee:
        return 5;
      case auth.UserRole.tailor:
      case auth.UserRole.cutter:
      case auth.UserRole.finisher:
        return 4;
      case auth.UserRole.apprentice:
        return 2;
      case auth.UserRole.customer:
        return 1;
    }
  }

  bool canAccessRole(auth.UserRole targetRole) {
    return hierarchyLevel >= targetRole.hierarchyLevel;
  }

  bool hasPermission(String permission) {
    // Define permission mappings for each role
    final rolePermissions = {
      auth.UserRole.admin: [
        'create_user',
        'read_user',
        'update_user',
        'delete_user',
        'create_order',
        'read_order',
        'update_order',
        'delete_order',
        'create_product',
        'read_product',
        'update_product',
        'delete_product',
        'create_inventory',
        'read_inventory',
        'update_inventory',
        'delete_inventory',
        'view_analytics',
        'view_reports',
        'export_data',
        'system_settings',
        'business_config',
        'security_settings',
      ],
      auth.UserRole.shopOwner: [
        'read_user',
        'update_user',
        'create_order',
        'read_order',
        'update_order',
        'delete_order',
        'create_product',
        'read_product',
        'update_product',
        'delete_product',
        'read_inventory',
        'update_inventory',
        'view_analytics',
        'view_reports',
        'export_data',
        'business_config',
      ],
      auth.UserRole.supervisor: [
        'read_user',
        'read_order',
        'update_order',
        'read_product',
        'update_product',
        'read_inventory',
        'view_reports',
      ],
      auth.UserRole.employee: [
        'read_order',
        'update_order',
        'read_product',
        'read_inventory',
      ],
      auth.UserRole.tailor: [
        'read_order',
        'update_order',
        'read_product',
      ],
      auth.UserRole.cutter: [
        'read_order',
        'update_order',
        'read_product',
        'read_inventory',
      ],
      auth.UserRole.finisher: [
        'read_order',
        'update_order',
        'read_product',
      ],
      auth.UserRole.apprentice: [
        'read_order',
        'read_product',
      ],
      auth.UserRole.customer: [
        'create_order',
        'read_order',
        'update_order',
        'read_product',
      ],
    };

    final permissions = rolePermissions[this] ?? [];
    return permissions.contains(permission);
  }

  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((permission) => hasPermission(permission));
  }
}

/// Extension method for easy role checking in widgets
extension RoleCheckExtensions on BuildContext {
  bool hasRole(auth.UserRole requiredRole) {
    final authProvider = Provider.of<AuthProvider>(this, listen: false);
    final userRole = authProvider.userRole;
    return userRole.canAccessRole(requiredRole);
  }

  bool hasPermission(String permission) {
    final authProvider = Provider.of<AuthProvider>(this, listen: false);
    final userRole = authProvider.userRole;
    return userRole.hasPermission(permission);
  }

  auth.UserRole? get currentUserRole {
    final authProvider = Provider.of<AuthProvider>(this, listen: false);
    return authProvider.userRole;
  }

  bool isAdmin() => hasRole(auth.UserRole.admin);
  bool isShopOwner() => hasRole(auth.UserRole.shopOwner);
  bool isSupervisor() => hasRole(auth.UserRole.supervisor);
  bool isEmployee() => hasRole(auth.UserRole.employee);
  bool isCustomer() => hasRole(auth.UserRole.customer);
}
