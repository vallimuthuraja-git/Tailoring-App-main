// NOTE: This Dart script is deprecated.
// Use firebase_data_setup.js instead, which uses Firebase Admin SDK for proper server-side Firebase operations.
//
// To run the setup script:
// 1. Download Firebase service account key as serviceAccountKey.json from Firebase Console
// 2. Run: npm run setup
//
// This script cannot run as 'dart run firebase_data_setup.dart' because Flutter Firebase packages require Flutter runtime.
// The new script uses Node.js and Firebase Admin SDK for creating users and data.

import 'firebase_options.dart';
import 'lib/utils/demo_accounts_util.dart';
import 'lib/utils/employee_setup_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  try {
    if (kDebugMode) debugPrint('🚀 Starting Firebase data setup...');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      debugPrint('✅ Firebase initialized');
    }

    // Create demo accounts
    await createDemoAccounts();

    // Setup employee data
    await setupEmployeesDirectly();

    if (kDebugMode) {
      debugPrint('\n🎉 Firebase data setup completed successfully!');
    }

    // List the created accounts
    debugPrint('\n📋 Created Demo Accounts:');
    for (final user in demoUsers) {
      debugPrint(
          '- ${user['displayName']}: ${user['email']} (Password: ${user['password']})');
    }
  } catch (e) {
    if (kDebugMode) debugPrint('❌ Error in Firebase data setup: $e');
    rethrow;
  }
}
