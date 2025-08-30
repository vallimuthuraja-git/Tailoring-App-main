import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class SetupDemoUsers {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create demo users in Firebase Auth and Firestore
  Future<void> createDemoUsers() async {
    try {
      // print('🔧 Setting up demo users...');

      // Demo customer
      await _createDemoUser(
        email: 'customer@demo.com',
        password: 'password123',
        displayName: 'Demo Customer',
        role: UserRole.customer,
      );

      // Demo shop owner
      await _createDemoUser(
        email: 'owner@demo.com',
        password: 'password123',
        displayName: 'Esther',
        role: UserRole.shopOwner,
      );

      // print('✅ Demo users setup completed successfully!');
    } catch (e) {
      // print('❌ Error setting up demo users: $e');
    }
  }

  // Create individual demo user
  Future<void> _createDemoUser({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      // print('🔍 Checking if user $email already exists...');

      // First, try to check if user exists by attempting to create
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
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

        // print('✅ Successfully created demo user: $email');
        return;

      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          // print('⚠️ User $email already exists in Auth, checking profile...');
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
  Future<void> _ensureUserProfileExists(String email, String displayName, UserRole role) async {
    try {
      // Since we know user exists (from email-already-in-use error), try to sign in
      final user = await _auth.signInWithEmailAndPassword(email: email, password: 'password123');

      // Check if profile exists in Firestore
      final existingProfile = await _firestore
          .collection('users')
          .doc(user.user!.uid)
          .get();

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
      }

      await _auth.signOut();
        } catch (e) {
      // print('❌ Error ensuring user profile exists: $e');
    }
  }

  // Check if demo users exist in Firebase Auth
  Future<bool> demoUsersExist() async {
    try {
      // print('🔍 Checking if demo users exist in Firebase Auth...');

      // Check customer
      bool customerExists = await _userExistsInAuth('customer@demo.com');
      // print('Customer exists in Auth: $customerExists');

      // Check shop owner
      bool shopExists = await _userExistsInAuth('shop@demo.com');
      // print('Shop owner exists in Auth: $shopExists');

      bool bothExist = customerExists && shopExists;
      // print('Both demo users exist: $bothExist');

      return bothExist;
    } catch (e) {
      // print('❌ Error checking demo users: $e');
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
        password: 'temp_password_123',
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
      final usersExist = await demoUsersExist();
      if (!usersExist) {
        // print('🔧 Demo users not found, creating them...');
        await createDemoUsers();
      } else {
        // print('✅ Demo users already exist');
      }
    } catch (e) {
      // print('❌ Error initializing demo data: $e');
    }
  }
}

// Helper function to setup demo users (can be called from main)
Future<void> setupDemoUsers() async {
  final setup = SetupDemoUsers();
  await setup.initializeDemoDataIfNeeded();
}
