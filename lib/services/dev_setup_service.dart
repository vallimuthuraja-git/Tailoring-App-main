import 'package:flutter/material.dart';

class DevSetupService {
  /// Current active demo accounts - these are the 4 real users created in Firebase with Madurai, Tamil Nadu details
  static const List<Map<String, dynamic>> currentDemoUsers = [
    // Shop Owner - Madurai Master Tailor
    {
      'email': 'owner@tailoring.com',
      'password': 'Owner123!',
      'displayName': 'Arun Kumar Rajendran',
      'role': 2, // shopOwner
      'roleName': 'shop owner',
      'phone': '+914524567890',
      'location': 'Madurai, Tamil Nadu',
    },
    // Customer - Madurai Software Engineer
    {
      'email': 'customer@tailoring.com',
      'password': 'Customer123!',
      'displayName': 'Priya Senthilkumar',
      'role': 0, // customer
      'roleName': 'customer',
      'phone': '+914524567891',
      'location': 'Madurai, Tamil Nadu',
    },
    // Employee 1 - Stitching Master
    {
      'email': 'tailor1@tailoring.com',
      'password': 'Tailor123!',
      'displayName': 'Suresh Rajalingam',
      'role': 1, // employee
      'roleName': 'employee',
      'phone': '+914524567892',
      'specialty': 'Stitching Master',
      'location': 'Madurai, Tamil Nadu',
    },
    // Employee 2 - Designer Tailor
    {
      'email': 'tailor2@tailoring.com',
      'password': 'Tailor456!',
      'displayName': 'Lakshmi Balasubramanian',
      'role': 1, // employee
      'roleName': 'employee',
      'phone': '+914524567893',
      'specialty': 'Designer Tailor',
      'location': 'Madurai, Tamil Nadu',
    },
  ];

  /// Get current active Firebase demo credentials (only the 4 real users)
  static List<Map<String, String>> getFirebaseDemoCredentials() {
    return currentDemoUsers.map((user) {
      return <String, String>{
        'email': user['email']!,
        'password': user['password']!,
        'displayName': user['displayName']!,
        'role': user['roleName']!,
        'description': _getRoleDescription(user['role'] as int),
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

  /// Get quick login buttons for UI - updated for Madurai, Tamil Nadu accounts
  static List<Map<String, dynamic>> getQuickLoginButtons() {
    return [
      // Shop Owner - Arun Kumar Rajendran - Master Tailor
      {
        'title': 'Shop Owner',
        'subtitle': 'Arun Kumar Rajendran',
        'email': 'owner@tailoring.com',
        'password': 'Owner123!',
        'color': const Color(0xFF9C27B0), // Purple
        'icon': Icons.business,
        'location': 'Madurai, TN',
      },
      // Customer - Priya Senthilkumar - Software Engineer
      {
        'title': 'Customer',
        'subtitle': 'Priya Senthilkumar',
        'email': 'customer@tailoring.com',
        'password': 'Customer123!',
        'color': const Color(0xFF4CAF50), // Green
        'icon': Icons.shopping_cart,
        'location': 'Madurai, TN',
      },
      // Tailor 1 - Suresh Rajalingam - Stitching Master
      {
        'title': 'Stitching Master',
        'subtitle': 'Suresh Rajalingam',
        'email': 'tailor1@tailoring.com',
        'password': 'Tailor123!',
        'color': const Color(0xFF2196F3), // Blue
        'icon': Icons.content_cut,
        'location': 'Madurai, TN',
      },
      // Tailor 2 - Lakshmi Balasubramanian - Designer
      {
        'title': 'Designer',
        'subtitle': 'Lakshmi Balasubramanian',
        'email': 'tailor2@tailoring.com',
        'password': 'Tailor456!',
        'color': const Color(0xFFE91E63), // Pink
        'icon': Icons.design_services,
        'location': 'Madurai, TN',
      },
    ];
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
