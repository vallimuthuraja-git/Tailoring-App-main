import 'package:flutter/material.dart';

import '../../utils/demo_accounts_util.dart';

class DevSetupService {
  /// Get comprehensive Firebase demo credentials (from updated firebase_data_setup.js & demo_accounts_util.dart)
  static List<Map<String, String>> getFirebaseDemoCredentials() {
    return demoUsers.map((user) {
      final roleInt = user['role'] as int;
      final roleName = roleInt == 3
          ? 'shop owner'
          : roleInt == 1
              ? 'employee'
              : roleInt == 0
                  ? 'customer'
                  : 'unknown';

      return <String, String>{
        'email': user['email']!,
        'password': user['password']!,
        'displayName': user['displayName']!,
        'role': roleName,
        'description': _getRoleDescription(roleInt),
      };
    }).toList();
  }

  /// Get demo credentials (legacy - kept for compatibility)
  static List<Map<String, String>> getDemoCredentials() {
    return getFirebaseDemoCredentials()
        .map((user) => {
              ...user,
              'role': user['role']! == 'shop owner'
                  ? 'Owner'
                  : user['role']! == 'customer'
                      ? 'Customer'
                      : user['role']! == 'employee'
                          ? 'Employee'
                          : user['role']!,
            })
        .toList();
  }

  /// Get development credentials that match Firebase accounts (10 accounts total)
  static List<Map<String, String>> getDevCredentials() {
    return getFirebaseDemoCredentials();
  }

  /// Get all available demo credentials with proper naming
  static List<Map<String, String>> getAllDemoCredentials() {
    return getFirebaseDemoCredentials();
  }

  /// Get quick login credentials organized by role type
  static Map<String, List<Map<String, String>>> getQuickLoginCredentials() {
    final credentials = getFirebaseDemoCredentials();
    final organized = <String, List<Map<String, String>>>{};

    for (final cred in credentials) {
      final role = cred['role']!;
      if (!organized.containsKey(role)) {
        organized[role] = [];
      }
      organized[role]!.add(cred);
    }

    return organized;
  }

  /// Get quick login buttons for UI (grouped by role type)
  static List<Map<String, dynamic>> getQuickLoginButtons() {
    final credentials = getQuickLoginCredentials();
    final buttons = <Map<String, dynamic>>[];

    // Add SUPER ADMIN first with special styling
    if (credentials.containsKey('shop owner')) {
      final shopOwners = credentials['shop owner']!;
      final superAdmin = shopOwners.firstWhere(
        (user) => user['email'] == 'admin@tailoring-app.com',
        orElse: () => <String, String>{},
      );

      if (superAdmin.isNotEmpty) {
        buttons.add({
          'title': '🔥 Super Admin',
          'subtitle': 'FULL CONTROL',
          'email': superAdmin['email']!,
          'password': superAdmin['password']!,
          'color': const Color(0xFFFF6B35), // Orange/Red - distinctive
          'icon': Icons.admin_panel_settings,
          'isSuperAdmin': true,
        });
      }

      // Add other shop owners (exclude super admin)
      final otherShopOwners = shopOwners
          .where((user) => user['email'] != 'admin@tailoring-app.com');

      buttons.addAll(otherShopOwners.map((user) => {
            'title': '🏪 ${_getShortName(user['displayName']!)}',
            'subtitle': 'Shop Owner',
            'email': user['email']!,
            'password': user['password']!,
            'color': const Color(0xFF9C27B0), // Purple
            'icon': Icons.business,
          }));
    }

    // Add employees
    if (credentials.containsKey('employee')) {
      buttons.addAll(credentials['employee']!.map((user) => {
            'title': '👷 ${_getShortName(user['displayName']!)}',
            'subtitle': 'Employee',
            'email': user['email']!,
            'password': user['password']!,
            'color': const Color(0xFF2196F3), // Blue
            'icon': Icons.work,
          }));
    }

    // Add customers
    if (credentials.containsKey('customer')) {
      buttons.addAll(credentials['customer']!.map((user) => {
            'title': '👤 ${_getShortName(user['displayName']!)}',
            'subtitle': 'Customer',
            'email': user['email']!,
            'password': user['password']!,
            'color': const Color(0xFF4CAF50), // Green
            'icon': Icons.person,
          }));
    }

    return buttons;
  }

  static String _getRoleDescription(int role) {
    switch (role) {
      case 3:
        return 'Business owner with full administrative access';
      case 1:
        return 'Tailoring specialist with measurement and stitching expertise';
      case 0:
        return 'Customer with order history and measurement profile';
      default:
        return 'Demo user account';
    }
  }

  static String _getShortName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1][0].toUpperCase()}.';
    }
    return fullName;
  }
}
