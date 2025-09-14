import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../utils/demo_constants.dart';

/// Default measurements for adult male (in inches)
const Map<String, double> defaultMaleMeasurements = {
  'chest': 40.0,
  'waist': 32.0,
  'shoulder': 18.0,
  'neck': 15.5,
  'sleeveLength': 25.0,
  'inseam': 32.0,
};

/// Default measurements for adult female (in inches)
const Map<String, double> defaultFemaleMeasurements = {
  'chest': 34.0,
  'waist': 28.0,
  'hip': 36.0,
  'shoulder': 14.5,
  'neck': 13.0,
  'sleeveLength': 22.0,
};

void main() async {
  print('🚀 Starting update_existing_users script...');

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Authenticate as admin to get permissions
    final auth = FirebaseAuth.instance;
    print('🔐 Authenticating as admin...');
    await auth.signInWithEmailAndPassword(
      email: DemoConstants.adminEmail,
      password: DemoConstants.demoPassword,
    );
    print('✅ Authenticated as admin successfully');

    final firestore = FirebaseFirestore.instance;
    final usersCollection = firestore.collection('users');

    // Fetch all users
    print('🔍 Fetching all users from Firestore...');
    final usersSnapshot = await usersCollection.get();

    if (usersSnapshot.docs.isEmpty) {
      print('ℹ️ No users found in the database');
      return;
    }

    print('📊 Found ${usersSnapshot.docs.length} users');
    int updatedUsers = 0;
    int skippedUsers = 0;

    // Process each user
    for (final userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      final userData = userDoc.data();

      print(
          '\n👤 Processing user: $userId (${userData['email'] ?? 'no email'})');

      bool needsUpdate = false;
      final Map<String, dynamic> updates = {};

      // Check if gender is missing
      if (userData['gender'] == null || userData['gender'].toString().isEmpty) {
        updates['gender'] = 'male'; // Default gender
        needsUpdate = true;
        print('  📝 Missing gender - will set to "male"');
      } else {
        print('  ✅ Gender already exists: ${userData['gender']}');
      }

      // Check if dateOfBirth is missing
      if (userData['dateOfBirth'] == null) {
        final twentyFiveYearsAgo =
            DateTime.now().subtract(Duration(days: 365 * 25));
        updates['dateOfBirth'] = twentyFiveYearsAgo.toIso8601String();
        needsUpdate = true;
        print('  📅 Missing dateOfBirth - will set to 25 years ago');
      } else {
        print('  ✅ DateOfBirth already exists');
      }

      // Update user document if needed
      if (needsUpdate) {
        try {
          await usersCollection.doc(userId).update(updates);
          print('  ✅ User document updated successfully');
          updatedUsers++;
        } catch (e) {
          print('  ❌ Failed to update user document: $e');
          continue; // Skip to next user
        }
      } else {
        print('  ⏭️ No updates needed for user document');
      }

      // Check if measurements already exist
      final measurementsCollection =
          usersCollection.doc(userId).collection('measurements');
      final existingMeasurements = await measurementsCollection.get();

      if (existingMeasurements.docs.isNotEmpty) {
        print(
            '  ✅ Measurements already exist (${existingMeasurements.docs.length} measurements)');
        skippedUsers++;
        continue;
      }

      // Add default measurements
      final gender = updates['gender'] ?? userData['gender'] ?? 'male';
      final defaultMeasurements = gender == 'female'
          ? defaultFemaleMeasurements
          : defaultMaleMeasurements;

      print('  📏 Adding default measurements for $gender...');

      int addedMeasurements = 0;
      for (final entry in defaultMeasurements.entries) {
        try {
          await measurementsCollection.doc(entry.key).set({
            'value': entry.value,
            'unit': 'inches',
            'timestamp': FieldValue.serverTimestamp(),
          });
          addedMeasurements++;
        } catch (e) {
          print('  ❌ Failed to add measurement ${entry.key}: $e');
        }
      }

      print('  ✅ Added $addedMeasurements measurements');
      updatedUsers++;
    }
    print('\n🎉 Script completed successfully!');
    print('📈 Summary:');
    print('  - Total users processed: ${usersSnapshot.docs.length}');
    print('  - Users updated: $updatedUsers');
    print('  - Users skipped (already had measurements): $skippedUsers');

// Sign out
    await auth.signOut();
    print('👋 Signed out admin user');
  } catch (e) {
    print('❌ Script failed with error: $e');
// Try to sign out even on error
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    rethrow;
  }
}
