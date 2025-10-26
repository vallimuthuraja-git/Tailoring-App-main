import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_role.dart';

/// Service for migrating users from old 9-role system to new multi-specialty system
class RoleMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Map old roles to new specialty combinations
  static const Map<int, List<EmployeeSpecialty>> _oldRoleToSpecialties = {
    0: [], // customer - stays customer
    1: [], // employee - becomes general employee
    2: [], // admin - becomes shopOwner
    3: [], // shopOwner - stays shopOwner
    4: [EmployeeSpecialty.tailor], // tailor -> tailor specialty
    5: [EmployeeSpecialty.cutter], // cutter -> cutter specialty
    6: [EmployeeSpecialty.finisher], // finisher -> finisher specialty
    7: [EmployeeSpecialty.supervisor], // supervisor -> supervisor specialty
    8: [EmployeeSpecialty.apprentice], // apprentice -> apprentice specialty
  };

  /// Map old role numbers to new role enums
  UserRole _getNewRole(int oldRole) {
    switch (oldRole) {
      case 0:
        return UserRole.customer;
      case 1:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
        return UserRole.employee; // All specialized roles become employees
      case 2:
      case 3:
        return UserRole.shopOwner; // Admin becomes shopOwner
      default:
        return UserRole.customer; // Default to customer
    }
  }

  /// Get specialties for an old role
  List<EmployeeSpecialty> _getSpecialtiesForOldRole(int oldRole) {
    return _oldRoleToSpecialties[oldRole] ?? [];
  }

  /// Run the migration for all users in the database
  Future<Map<String, dynamic>> migrateAllUsers() async {
    if (kDebugMode) debugPrint('🚀 Starting user role migration...');

    final List<String> errors = [];
    final List<Map<String, dynamic>> details = [];
    int totalProcessed = 0;
    int successfullyMigrated = 0;

    try {
      // Get all users from Firestore
      final usersSnapshot = await _firestore.collection('users').get();

      if (kDebugMode) {
        debugPrint('📊 Found ${usersSnapshot.docs.length} users to process');
      }

      totalProcessed = usersSnapshot.docs.length;

      // Process each user
      for (final userDoc in usersSnapshot.docs) {
        try {
          final userId = userDoc.id;
          final userData = userDoc.data();

          final migrationResult = await _migrateUser(userId, userData);

          details.add(migrationResult);

          if (migrationResult['success']) {
            successfullyMigrated++;
          } else {
            errors.add('User $userId: ${migrationResult['error']}');
          }

          if (kDebugMode) {
            debugPrint('✅ Processed user: ${userData['email'] ?? userId}');
          }
        } catch (e) {
          final errorMsg = 'Failed to process user ${userDoc.id}: $e';
          errors.add(errorMsg);
          details.add({
            'userId': userDoc.id,
            'success': false,
            'error': errorMsg,
          });

          if (kDebugMode) debugPrint('❌ $errorMsg');
        }
      }

      if (kDebugMode) {
        debugPrint('🎉 Migration completed!');
        debugPrint(
            '📈 Results: $successfullyMigrated/$totalProcessed users migrated successfully');
      }
    } catch (e) {
      final errorMsg = 'Migration failed: $e';
      errors.add(errorMsg);
      if (kDebugMode) debugPrint('💥 $errorMsg');
    }

    return {
      'totalProcessed': totalProcessed,
      'successfullyMigrated': successfullyMigrated,
      'errors': errors,
      'details': details,
    };
  }

  /// Migrate a single user
  Future<Map<String, dynamic>> _migrateUser(
      String userId, Map<String, dynamic> userData) async {
    final oldRoleInt = userData['role'] as int? ?? 0;
    final email = userData['email'] as String?;

    // Calculate new role and specialties
    final newRole = _getNewRole(oldRoleInt);
    final specialties = _getSpecialtiesForOldRole(oldRoleInt);

    // Prepare update data
    final updateData = <String, dynamic>{
      'role': UserRole.values.indexOf(newRole), // Store as index
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // For employees, add specialty information
    if (newRole == UserRole.employee) {
      updateData.addAll({
        'specialties': specialties.map((s) => s.name).toList(),
        'employeeType': specialties.isEmpty ? 'general' : 'specialized',
        'primarySpecialty':
            specialties.isEmpty ? 'General' : specialties.first.displayName,
      });

      // Update available features based on specialties
      final availableFeatures =
          SpecialtyFeatures.getEmployeeFeatures(specialties);
      updateData['availableFeatures'] = availableFeatures.toList();

      // If has specialties, also update employee collection
      if (specialties.isNotEmpty) {
        await _updateEmployeeProfile(userId, specialties, availableFeatures);
      }
    }

    // Update the user document
    await _firestore.collection('users').doc(userId).update(updateData);

    return {
      'userId': userId,
      'email': email,
      'oldRole': oldRoleInt,
      'newRole': newRole.name,
      'specialties': specialties.map((s) => s.displayName).toList(),
      'success': true,
    };
  }

  /// Update employee profile with specialty information
  Future<void> _updateEmployeeProfile(
      String userId,
      List<EmployeeSpecialty> specialties,
      Set<String> availableFeatures) async {
    final employeeDoc = _firestore.collection('employees').doc('emp_$userId');

    // Check if employee document exists
    final docSnapshot = await employeeDoc.get();
    if (!docSnapshot.exists) {
      if (kDebugMode) {
        debugPrint(
            '⚠️  Employee profile not found for $userId, skipping update');
      }
      return;
    }

    // Add specialty information to employee profile
    await employeeDoc.update({
      'specialties': specialties.map((s) => s.name).toList(),
      'availableFeatures': availableFeatures.toList(),
      'employeeType': 'specialized',
      'primarySpecialty': specialties.first.displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (kDebugMode) {
      debugPrint(
          '✅ Updated employee profile for $userId with specialties: ${specialties.map((s) => s.displayName).join(', ')}');
    }
  }

  /// Create demo migration (for testing)
  Future<void> createDemoMigration() async {
    if (kDebugMode) debugPrint('🎭 Creating demo migration data...');

    // This would typically be called from setup scripts
    // For now, it's a placeholder for demo data migration

    if (kDebugMode) debugPrint('✅ Demo migration data created');
  }

  /// Dry run - show what would be changed without actually changing it
  Future<List<Map<String, dynamic>>> dryRunMigration() async {
    if (kDebugMode) debugPrint('🔍 Running migration dry run...');

    final previewResults = <Map<String, dynamic>>[];

    try {
      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final oldRoleInt = userData['role'] as int? ?? 0;

        final newRole = _getNewRole(oldRoleInt);
        final specialties = _getSpecialtiesForOldRole(oldRoleInt);

        previewResults.add({
          'userId': userDoc.id,
          'email': userData['email'],
          'currentRole': oldRoleInt,
          'newRole': newRole.name,
          'specialties': specialties.map((s) => s.displayName).toList(),
        });
      }

      if (kDebugMode) {
        debugPrint('📋 Dry run completed for ${previewResults.length} users');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Dry run failed: $e');
    }

    return previewResults;
  }
}

/// Function to run migration (can be called from anywhere)
Future<Map<String, dynamic>> runUserRoleMigration() async {
  final migrator = RoleMigrationService();
  return await migrator.migrateAllUsers();
}

/// Function for dry run (preview changes)
Future<List<Map<String, dynamic>>> previewUserRoleMigration() async {
  final migrator = RoleMigrationService();
  return await migrator.dryRunMigration();
}
