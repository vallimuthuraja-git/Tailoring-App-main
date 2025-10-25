class DevSetupService {
  /// Demo user credentials that match Firebase setup script (from firebase_data_setup.js)
  static const List<Map<String, String>> firebaseDemoUsers = [
    {
      'email': 'shop@demo.com',
      'password': 'Pass123',
      'displayName': 'Shop Owner',
      'role': 'shop owner',
    },
    {
      'email': 'customer@demo.com',
      'password': 'Pass123',
      'displayName': 'Demo Customer',
      'role': 'customer',
    },
    {
      'email': 'employee0@demo.com',
      'password': 'Pass123',
      'displayName': 'Employee 0',
      'role': 'employee',
    },
    {
      'email': 'employee1@demo.com',
      'password': 'Pass123',
      'displayName': 'Employee 1',
      'role': 'employee',
    },
  ];

  /// Get all Firebase demo credentials (accounts that exist in Firebase)
  static List<Map<String, String>> getFirebaseDemoCredentials() {
    return firebaseDemoUsers;
  }

  /// Get demo credentials (legacy - kept for compatibility)
  static List<Map<String, String>> getDemoCredentials() {
    return firebaseDemoUsers
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

  /// Get development credentials that match Firebase accounts (4 accounts total)
  static List<Map<String, String>> getDevCredentials() {
    return firebaseDemoUsers;
  }

  /// Get all available demo credentials with proper naming
  static List<Map<String, String>> getAllDemoCredentials() {
    return [
      ...getFirebaseDemoCredentials(),

      // Additional demo accounts that can be created in Firebase if needed
      // NOTE: These don't exist in Firebase yet - run firebase_data_setup.js first
      {
        'email': 'manager@demo.com',
        'password': 'Pass123',
        'displayName': 'Manager',
        'role': 'employee',
      },
      {
        'email': 'vip@demo.com',
        'password': 'Pass123',
        'displayName': 'VIP Customer',
        'role': 'customer',
      },
    ];
  }
}
