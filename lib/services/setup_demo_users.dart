import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import '../utils/demo_constants.dart';

class SetupDemoUsers {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create demo users in Firebase Auth and Firestore
  Future<void> createDemoUsers() async {
    print('🔧 Setting up demo users...');

    // Demo customer
    try {
      await _createDemoUser(
        email: DemoConstants.customerEmail,
        password: DemoConstants.demoPassword,
        displayName: 'Demo Customer',
        role: UserRole.customer,
      );
    } catch (e) {
      print('❌ Error creating demo customer: $e');
    }

    // Demo shop owner
    try {
      await _createDemoUser(
        email: DemoConstants.shopOwnerEmail,
        password: DemoConstants.demoPassword,
        displayName: 'Esther',
        role: UserRole.shopOwner,
      );
    } catch (e) {
      print('❌ Error creating demo shop owner: $e');
    }

    // Demo admin
    try {
      await _createDemoUser(
        email: DemoConstants.adminEmail,
        password: DemoConstants.demoPassword,
        displayName: 'Admin',
        role: UserRole.admin,
      );
    } catch (e) {
      print('❌ Error creating demo admin: $e');
    }

    print('✅ Demo users setup completed successfully!');
  }

  // Create individual demo user
  Future<void> _createDemoUser({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      print('🔍 Checking if user $email already exists...');

      // First, try to check if user exists by attempting to create
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Update display name
        await userCredential.user!.updateDisplayName(displayName);

        // Create user profile in Firestore
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: email,
          displayName: displayName,
          role: role,
          isEmailVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());

        print(
            '✅ Successfully created demo user: $email with role ${role.name}');
        if (email == 'admin@demo.com') {
          print(
              '🔍 ADMIN CREATION: User role set to ${role.name} in Firestore');
        }
        return;
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          print('⚠️ User $email already exists in Auth, checking profile...');
          await _ensureUserProfileExists(email, displayName, role);
          return;
        } else {
          // print('❌ Error creating demo user $email: $e');
          rethrow;
        }
      }
    } catch (e) {
      // print('❌ Error in demo user creation process for $email: $e');
      rethrow;
    }
  }

  // Ensure user profile exists in Firestore
  Future<void> _ensureUserProfileExists(
      String email, String displayName, UserRole role) async {
    try {
      // Since we know user exists (from email-already-in-use error), try to sign in
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: DemoConstants.demoPassword);

      // Check if profile exists in Firestore
      final existingProfile =
          await _firestore.collection('users').doc(user.user!.uid).get();

      if (!existingProfile.exists) {
        // Create profile
        final userModel = UserModel(
          id: user.user!.uid,
          email: email,
          displayName: displayName,
          role: role,
          isEmailVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.user!.uid)
            .set(userModel.toJson());

        // print('✅ Created missing profile for existing user: $email');
        print(
            '✅ Created missing profile for existing user: $email with role ${role.name}');
        if (email == 'admin@demo.com') {
          print(
              '🔍 ADMIN PROFILE: Created missing admin profile with role ${role.name}');
        }
      }

      await _auth.signOut();
    } catch (e) {
      // print('❌ Error ensuring user profile exists: $e');
    }
  }

  // Check if demo users exist in Firebase Auth
  Future<bool> demoUsersExist() async {
    try {
      print('🔍 Checking if demo users exist in Firebase Auth...');

      // Check customer
      bool customerExists =
          await _userExistsInAuth(DemoConstants.customerEmail);
      print('Customer exists in Auth: $customerExists');

      // Check shop owner
      bool shopExists = await _userExistsInAuth(DemoConstants.shopOwnerEmail);
      print('Shop owner exists in Auth: $shopExists');

      // Check admin
      bool adminExists = await _userExistsInAuth(DemoConstants.adminEmail);
      print('Admin exists in Auth: $adminExists');
      if (adminExists) {
        final adminInfo = await getDemoUserInfo(DemoConstants.adminEmail);
        if (adminInfo != null) {
          print('🔍 ADMIN EXISTENCE: Role in Firestore: ${adminInfo['role']}');
        } else {
          print('❌ ADMIN EXISTENCE: No Firestore profile found for admin');
        }
      }

      bool allExist = customerExists && shopExists && adminExists;
      print('All demo users exist: $allExist');
      print('Missing admin: ${!adminExists}');
      print('One/more demo user missing: ${!allExist}');

      return allExist;
    } catch (e) {
      print('❌ Error checking demo users: $e');
      return false;
    }
  }

  // Check if user exists in Firebase Auth
  Future<bool> _userExistsInAuth(String email) async {
    try {
      // Try to create a temporary user to check if email exists
      // This will throw 'email-already-in-use' if user exists
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: DemoConstants.tempPassword,
      );

      // If we reach here, user didn't exist, so delete the temp user
      try {
        await _auth.currentUser?.delete();
      } catch (e) {
        // Ignore deletion errors
      }

      return false; // User didn't exist
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        return true; // User exists
      }
      // print('❌ Error checking if user $email exists in Auth: $e');
      return false;
    }
  }

  // Get demo user info
  Future<Map<String, dynamic>?> getDemoUserInfo(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      // print('❌ Error getting demo user info: $e');
      return null;
    }
  }

  // Initialize demo data if needed
  Future<void> initializeDemoDataIfNeeded() async {
    try {
      print('🚀 Starting demo data initialization check...');
      final usersExist = await demoUsersExist();
      if (!usersExist) {
        print('🔧 Demo users not found or incomplete, creating them...');
        await createDemoUsers();
        print('✅ Demo users creation completed!');
      } else {
        print('✅ All demo users already exist, no action needed');
      }
      print('🎉 Demo data initialization check finished');
    } catch (e) {
      print('❌ Error initializing demo data: $e');
    }
  }
}

// Helper function to setup demo users (can be called from main)
Future<void> setupDemoUsers() async {
  final setup = SetupDemoUsers();
  await setup.initializeDemoDataIfNeeded();
}
