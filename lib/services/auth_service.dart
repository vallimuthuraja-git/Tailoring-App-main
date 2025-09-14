import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

enum UserRole {
  customer,
  shopOwner,
  admin,
  employee,
  tailor, // Master tailor/couturier
  cutter, // Fabric cutting specialist
  finisher, // Final touches and quality control
  supervisor, // Team supervisor/manager
  apprentice // Training/new employee
}

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final UserRole role;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.role,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      role: UserRole.values[json['role'] ?? 0],
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role.index,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of user authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    UserRole role = UserRole.customer,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
      }

      // Create user profile in Firestore
      await _createUserProfile(userCredential.user!, role, phoneNumber);

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Phone Authentication Methods
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(UserCredential userCredential) onVerified,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (for Android devices with SMS retriever)
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          onVerified(userCredential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_handleAuthError(e).toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onError(_handleAuthError(e).toString());
    }
  }

  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> resendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onVerified: (userCredential) {
        // This shouldn't happen on resend, but handle it anyway
        onError('Unexpected auto-verification on resend');
      },
    );
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting to sign in user: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Successfully signed in user: ${userCredential.user?.email}');

      // Fetch and log user role for debugging
      if (email == 'admin@demo.com') {
        final profile = await getUserProfile(userCredential.user!.uid);
        if (profile != null) {
          print('🔍 ADMIN LOGIN: User role assigned is ${profile.role.name}');
        } else {
          print('❌ ADMIN LOGIN: No profile found for admin user');
        }
      }

      return userCredential;
    } catch (e) {
      print('❌ Sign in error for $email: $e');
      throw _handleAuthError(e);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if user profile exists, if not create one
      final existingProfile = await getUserProfile(userCredential.user!.uid);
      if (existingProfile == null) {
        await _createUserProfile(userCredential.user!, UserRole.customer);
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with Facebook
  Future<UserCredential> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Once signed in, return the UserCredential
      UserCredential userCredential =
          await _auth.signInWithCredential(facebookAuthCredential);

      // Check if user profile exists, if not create one
      final existingProfile = await getUserProfile(userCredential.user!.uid);
      if (existingProfile == null) {
        await _createUserProfile(userCredential.user!, UserRole.customer);
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Email verification
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }

        // Update Firestore profile
        await _updateUserProfileInFirestore(user.uid, {
          if (displayName != null) 'displayName': displayName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (photoUrl != null) 'photoUrl': photoUrl,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      print('🔍 Fetching user profile for ID: $userId');
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final userModel =
            UserModel.fromJson(doc.data() as Map<String, dynamic>);
        print(
            '✅ User profile found for $userId: ${userModel.email} role ${userModel.role.name}');
        if (userModel.email == 'admin@demo.com') {
          print('🔍 ADMIN PROFILE FETCH: Role is ${userModel.role.name}');
        }
        return userModel;
      } else {
        print('❌ No user profile found for $userId');
        if ('admin@demo.com' == 'admin@demo.com') {
          // placeholder, but actually check if this is admin id
          print('❌ ADMIN PROFILE FETCH: No profile exists');
        }
        return null;
      }
    } catch (e) {
      print('❌ Error fetching user profile for $userId: $e');
      throw _handleAuthError(e);
    }
  }

  // Stream user profile
  Stream<UserModel?> getUserProfileStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await getUserProfile(user.uid);
    }
    return null;
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(User user, UserRole role,
      [String? phoneNumber]) async {
    UserModel userModel = UserModel(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName ?? '',
      phoneNumber: phoneNumber ?? user.phoneNumber,
      photoUrl: user.photoURL,
      role: role,
      isEmailVerified: user.emailVerified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
  }

  // Public method to create/update user profile
  Future<void> createUserProfile(User user, UserRole role,
      [String? phoneNumber]) async {
    UserModel userModel = UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      phoneNumber: phoneNumber ?? user.phoneNumber,
      photoUrl: user.photoURL,
      role: role,
      isEmailVerified: user.emailVerified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
  }

  // Update user profile in Firestore
  Future<void> _updateUserProfileInFirestore(
      String userId, Map<String, dynamic> updates) async {
    await _firestore.collection('users').doc(userId).update(updates);
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete from Firestore first
        await _firestore.collection('users').doc(user.uid).delete();
        // Then delete from Auth
        await user.delete();
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Change password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate user before changing password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Handle authentication errors
  Exception _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Incorrect password.');
        case 'email-already-in-use':
          return Exception('An account already exists with this email.');
        case 'invalid-email':
          return Exception('Invalid email address.');
        case 'weak-password':
          return Exception('Password is too weak.');
        case 'user-disabled':
          return Exception('This user account has been disabled.');
        case 'operation-not-allowed':
          return Exception('Email/password accounts are not enabled.');
        case 'too-many-requests':
          return Exception('Too many attempts. Please try again later.');
        case 'network-request-failed':
          return Exception('Network error. Please check your connection.');
        default:
          return Exception('Authentication error: ${error.message}');
      }
    }
    return Exception('An unexpected error occurred.');
  }

  // Demo accounts for testing
  static const Map<String, Map<String, String>> demoAccounts = {
    'admin': {
      'email': 'admin@demo.com',
      'password': 'password123',
      'displayName': 'Admin',
    },
    'customer': {
      'email': 'customer@demo.com',
      'password': 'password123',
      'displayName': 'Demo Customer',
    },
    'shopOwner': {
      'email': 'shop@demo.com',
      'password': 'password123',
      'displayName': 'Demo Esther',
    },
    'employee': {
      'email': 'employee@demo.com',
      'password': 'password123',
      'displayName': 'Demo Employee',
    },
    'tailor': {
      'email': 'tailor@demo.com',
      'password': 'password123',
      'displayName': 'Demo Tailor',
    },
    'cutter': {
      'email': 'cutter@demo.com',
      'password': 'password123',
      'displayName': 'Demo Cutter',
    },
    'finisher': {
      'email': 'finisher@demo.com',
      'password': 'password123',
      'displayName': 'Demo Finisher',
    },
  };
}
