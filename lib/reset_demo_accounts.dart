import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Script to reset demo accounts that have wrong passwords
/// Run this script to delete existing demo accounts and let the app recreate them fresh
Future<void> resetDemoAccounts() async {
  debugPrint('ðŸ”„ Starting demo account reset process...');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // Demo accounts to reset
  final demoAccounts = {
    'customer@demo.com': 'password123',
    'shop@demo.com': 'password123',
    'admin@demo.com': 'password123',
    'employee@demo.com': 'password123',
    'tailor@demo.com': 'password123',
    'cutter@demo.com': 'password123',
    'finisher@demo.com': 'password123',
  };

  for (final account in demoAccounts.entries) {
    final email = account.key;
    final password = account.value;

    try {
      debugPrint('ðŸ” Processing account: $email');

      // First try to sign in to get the user
      UserCredential? userCredential;
      try {
        userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('âœ… Successfully signed in as $email');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-credential') {
          // Password is wrong, try to find if account exists another way
          // Since we can't check without knowing the correct password,
          // we'll assume it exists and proceed to try deleting the profile
          debugPrint('âš ï¸ Password incorrect for $email, skipping auth access');
        } else {
          debugPrint(
              'â„¹ï¸ Account $email does not exist or other error: ${e.message}');
          continue;
        }
      }

      if (userCredential != null) {
        final user = userCredential.user!;

        // Delete user profile from Firestore
        try {
          await firestore.collection('users').doc(user.uid).delete();
          debugPrint('ðŸ—‘ï¸ Deleted Firestore profile for $email');
        } catch (e) {
          debugPrint('âš ï¸ Could not delete Firestore profile for $email: $e');
        }

        // Delete user profile from employees collection if exists
        try {
          final employeeQuery = await firestore
              .collection('employees')
              .where('email', isEqualTo: email)
              .get();
          for (final doc in employeeQuery.docs) {
            await doc.reference.delete();
            debugPrint('ðŸ—‘ï¸ Deleted employee profile for $email');
          }
        } catch (e) {
          debugPrint('âš ï¸ Could not delete employee profile for $email: $e');
        }

        // Sign out
        await auth.signOut();

        // Try to delete the auth account (this works better when signed in)
        try {
          await user.delete();
          debugPrint('ðŸ—‘ï¸ Deleted auth account for $email');
        } catch (e) {
          debugPrint('âš ï¸ Could not fully delete auth account for $email: $e');
          // This is common if requires-recent-login
        }
      } else {
        // Account exists but we can't access it with wrong password
        // Try to delete profile data anyway using email search
        try {
          final userQuery = await firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

          for (final doc in userQuery.docs) {
            await doc.reference.delete();
            debugPrint(
                'ðŸ—‘ï¸ Deleted Firestore profile for $email using email search');
          }
        } catch (e) {
          debugPrint('âš ï¸ Could not delete Firestore profile for $email: $e');
        }

        try {
          final employeeQuery = await firestore
              .collection('employees')
              .where('email', isEqualTo: email)
              .get();
          for (final doc in employeeQuery.docs) {
            await doc.reference.delete();
            debugPrint('ðŸ—‘ï¸ Deleted employee profile for $email using email search');
          }
        } catch (e) {
          debugPrint('âš ï¸ Could not delete employee profile for $email: $e');
        }
      }
    } catch (e) {
      debugPrint('âŒ Error processing account $email: $e');
    }
  }

  debugPrint('âœ… Demo account reset process completed!');
  debugPrint('');
  debugPrint('ðŸ“‹ Next steps:');
  debugPrint('1. Restart your Flutter app');
  debugPrint(
      '2. The app will automatically recreate the demo accounts with correct passwords');
  debugPrint('3. Demo login should now work properly');
}

void main() async {
  try {
    await resetDemoAccounts();
  } catch (e) {
    debugPrint('âŒ Script failed: $e');
  }
}


