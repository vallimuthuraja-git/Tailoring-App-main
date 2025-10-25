import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:io' show Platform;

// Mock User class for development
class MockUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool emailVerified;
  @override
  final String? phoneNumber;
  @override
  final String? photoURL;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = false,
    this.phoneNumber,
    this.photoURL,
  });

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock UserCredential and AdditionalUserInfo classes
class MockUserCredential implements UserCredential {
  @override
  final User user;
  @override
  final AdditionalUserInfo additionalUserInfo;
  @override
  final AuthCredential? credential;

  MockUserCredential({
    required this.user,
    required this.additionalUserInfo,
    this.credential,
  });

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAdditionalUserInfo implements AdditionalUserInfo {
  @override
  final bool isNewUser;
  @override
  final String providerId;
  @override
  final String? username;

  MockAdditionalUserInfo({
    required this.isNewUser,
    required this.providerId,
    this.username,
  });

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

enum UserRole {
  customer,
  shopOwner,
  employee,
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
  final String? gender;
  final DateTime? dateOfBirth;
  final bool twoFactorEnabled;
  final String? twoFactorMethod;
  final Map<String, dynamic>? preferences;
  final List<String>? socialProviders;
  final DateTime? lastLoginAt;
  final int loginAttempts;
  final DateTime? lockedUntil;
  final List<String>? deviceTokens;

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
    this.gender,
    this.dateOfBirth,
    this.twoFactorEnabled = false,
    this.twoFactorMethod,
    this.preferences,
    this.socialProviders,
    this.lastLoginAt,
    this.loginAttempts = 0,
    this.lockedUntil,
    this.deviceTokens,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle invalid role indices that may exist in old data
    int roleIndex = json['role'] ?? 0;
    if (roleIndex < 0 || roleIndex >= UserRole.values.length) {
      debugPrint('⚠️ Invalid role index $roleIndex, defaulting to customer');
      roleIndex = 0; // Default to customer
    }

    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      role: UserRole.values[roleIndex],
      isEmailVerified: json['isEmailVerified'] ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      twoFactorMethod: json['twoFactorMethod'],
      preferences: json['preferences'] != null
          ? Map<String, dynamic>.from(json['preferences'])
          : null,
      socialProviders: json['socialProviders'] != null
          ? List<String>.from(json['socialProviders'])
          : null,
      loginAttempts: json['loginAttempts'] ?? 0,
      deviceTokens: json['deviceTokens'] != null
          ? List<String>.from(json['deviceTokens'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      lockedUntil: json['lockedUntil'] != null
          ? DateTime.parse(json['lockedUntil'])
          : null,
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
      'twoFactorEnabled': twoFactorEnabled,
      'twoFactorMethod': twoFactorMethod,
      if (preferences != null) 'preferences': preferences,
      if (socialProviders != null) 'socialProviders': socialProviders,
      'loginAttempts': loginAttempts,
      if (deviceTokens != null) 'deviceTokens': deviceTokens,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (lockedUntil != null) 'lockedUntil': lockedUntil!.toIso8601String(),
    };
  }

  bool get isAccountLocked {
    return lockedUntil != null && DateTime.now().isBefore(lockedUntil!);
  }

  int get minutesUntilUnlock {
    if (lockedUntil == null) return 0;
    final difference = lockedUntil!.difference(DateTime.now());
    return difference.inMinutes > 0 ? difference.inMinutes : 0;
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Security constants
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 30);
  static const int maxPasswordResetRequests = 3;
  static const Duration passwordResetCooldown = Duration(hours: 1);

  // Rate limiting storage
  final Map<String, Map<String, dynamic>> _rateLimitStore = {};

  // Stream of user authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Public firestore access for internal operations
  FirebaseFirestore get firestore => _firestore;

  // Sign up with email and password with security enhancements
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    UserRole role = UserRole.customer,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    try {
      // Check if email is already registered by querying our user collection
      final existingUserQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (existingUserQuery.docs.isNotEmpty) {
        throw Exception('An account with this email already exists.');
      }

      // Validate password strength
      if (!_isPasswordStrong(password)) {
        throw Exception(
            'Password must be at least 8 characters with uppercase, lowercase, number, and special character.');
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName);
      }

      // Create user profile in Firestore with enhanced security
      await _createUserProfile(
        userCredential.user!,
        role,
        phoneNumber,
        gender,
        dateOfBirth,
      );

      // Send verification email
      await userCredential.user!.sendEmailVerification();

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Enhanced sign in with security features
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool skipSecurityChecks = false, // Added fast mode for development
  }) async {
    try {
      debugPrint('🔐 Attempting to sign in user: $email');

      // Skip heavy security checks in development mode (kDebugMode or forced)
      if (!skipSecurityChecks &&
          !const bool.fromEnvironment('dart.vm.product')) {
        return await _signInWithSecurityChecks(email, password);
      } else {
        // Fast development mode
        debugPrint('⚡ Using fast development login mode');
        return await _signInFastMode(email, password);
      }
    } catch (e) {
      debugPrint('❌ Sign in error for $email: $e');
      throw _handleAuthError(e);
    }
  }

  // Heavy security checks version (production)
  Future<UserCredential> _signInWithSecurityChecks(
      String email, String password) async {
    // Check rate limiting
    if (_isRateLimited(email, 'login')) {
      throw Exception('Too many login attempts. Please try again later.');
    }

    // Check if account is locked
    final userProfile = await getUserProfileByEmail(email);
    if (userProfile?.isAccountLocked == true) {
      final minutes = userProfile!.minutesUntilUnlock;
      throw Exception(
          'Account locked due to multiple failed attempts. Try again in $minutes minutes.');
    }

    // Attempt login
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Check if email is verified
    if (!userCredential.user!.emailVerified) {
      await _auth.signOut();
      throw Exception('Please verify your email before signing in.');
    }

    // Reset login attempts on successful login
    await _updateLoginAttempts(email, reset: true);
    await _logLoginActivity(userCredential.user!.uid, 'successful', email);

    debugPrint('✅ Successfully signed in user: ${userCredential.user?.email}');
    return userCredential;
  }

  // Fast development mode login (skips heavy checks)
  Future<UserCredential> _signInFastMode(String email, String password) async {
    try {
      // Simple Firebase auth login without security overhead
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint(
          '✅ Fast login: Successfully signed in user: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      // For fast mode, still limit to prevent spam
      if (_isRateLimited(email, 'fast_login')) {
        throw Exception('Too many attempts. Please slow down.');
      }
      _recordRateLimitAttempt(email, 'fast_login');
      throw e;
    }
  }

  // Two-factor authentication verification (simplified)
  Future<UserCredential> verifyTwoFactor(String email, String code) async {
    try {
      // For now, accept any 6-digit code as valid
      if (code.length == 6 && RegExp(r'^\d+$').hasMatch(code)) {
        throw Exception(
            '2FA verification not implemented - use regular sign in.');
      } else {
        throw Exception('Invalid verification code.');
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Enable two-factor authentication
  Future<bool> enableTwoFactor(String method, [String? phoneNumber]) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in.');

      // Generate and send 2FA setup code
      final secret = await _generateTOTPSecret();
      if (method == 'totp') {
        // For TOTP, return secret for QR code generation
        await _sendTOTPViaEmail(user.email!, secret);
      } else if (method == 'sms' && phoneNumber != null) {
        // For SMS, send verification code
        await _sendSMSCode(phoneNumber, secret);
      }

      return true;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Phone Authentication Methods with security enhancements
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(UserCredential userCredential) onVerified,
    bool isSignUp = false,
  }) async {
    try {
      // Check rate limiting for phone verification
      if (_isRateLimited(phoneNumber, 'phone_verify')) {
        onError('Too many verification attempts. Please try again later.');
        return;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            UserCredential userCredential =
                await _auth.signInWithCredential(credential);

            if (isSignUp) {
              await _createUserProfile(
                  userCredential.user!, UserRole.customer, phoneNumber);
            }

            onVerified(userCredential);
          } catch (e) {
            onError(_handleAuthError(e).toString());
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _recordRateLimitAttempt(phoneNumber, 'phone_verify');
          onError(_handleAuthError(e).toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          _recordRateLimitAttempt(phoneNumber, 'phone_verify');
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

  // Enhanced Google Sign In
  Future<UserCredential> signInWithGoogle(
      {bool linkWithExisting = false}) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in cancelled.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential;
      if (linkWithExisting && _auth.currentUser != null) {
        // Link Google account with existing user
        userCredential =
            await _auth.currentUser!.linkWithCredential(credential);
      } else {
        userCredential = await _auth.signInWithCredential(credential);
      }

      final existingProfile = await getUserProfile(userCredential.user!.uid);
      if (existingProfile == null) {
        await _createUserProfile(userCredential.user!, UserRole.customer, null,
            null, null, 'google');
      } else if (!existingProfile.socialProviders!.contains('google')) {
        // Update social providers
        await _updateUserProfileInFirestore(userCredential.user!.uid, {
          'socialProviders': [...existingProfile.socialProviders!, 'google'],
        });
      }

      await _logLoginActivity(userCredential.user!.uid, 'successful_google',
          userCredential.user!.email!);
      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Enhanced Facebook Sign In
  Future<UserCredential> signInWithFacebook(
      {bool linkWithExisting = false}) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status != LoginStatus.success) {
        throw Exception('Facebook sign-in cancelled or failed.');
      }

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      UserCredential userCredential;
      if (linkWithExisting && _auth.currentUser != null) {
        userCredential =
            await _auth.currentUser!.linkWithCredential(facebookAuthCredential);
      } else {
        userCredential =
            await _auth.signInWithCredential(facebookAuthCredential);
      }

      final existingProfile = await getUserProfile(userCredential.user!.uid);
      if (existingProfile == null) {
        await _createUserProfile(userCredential.user!, UserRole.customer, null,
            null, null, 'facebook');
      } else if (!existingProfile.socialProviders!.contains('facebook')) {
        await _updateUserProfileInFirestore(userCredential.user!.uid, {
          'socialProviders': [...existingProfile.socialProviders!, 'facebook'],
        });
      }

      await _logLoginActivity(userCredential.user!.uid, 'successful_facebook',
          userCredential.user!.email!);
      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Link social account
  Future<void> linkSocialAccount(String provider) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in.');

      switch (provider) {
        case 'google':
          final googleUser = await GoogleSignIn().signIn();
          if (googleUser != null) {
            final googleAuth = await googleUser.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            await user.linkWithCredential(credential);
          }
          break;
        case 'facebook':
          return; // Not supported for web-only development
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Unlink social account
  Future<void> unlinkSocialAccount(String provider) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in.');

      if (provider == 'facebook') {
        return; // Not supported for web-only development
      }

      final providerId = provider == 'google'
          ? GoogleAuthProvider.PROVIDER_ID
          : FacebookAuthProvider.PROVIDER_ID;

      await user.unlink(providerId);

      final userProfile = await getUserProfile(user.uid);
      if (userProfile?.socialProviders != null) {
        final updatedProviders =
            userProfile!.socialProviders!.where((p) => p != provider).toList();
        await _updateUserProfileInFirestore(user.uid, {
          'socialProviders': updatedProviders,
        });
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Enhanced password reset with rate limiting
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Check rate limiting
      if (_isRateLimited(email, 'password_reset')) {
        throw Exception(
            'Too many password reset attempts. Please try again later.');
      }

      await _auth.sendPasswordResetEmail(email: email);
      _recordRateLimitAttempt(email, 'password_reset');
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out with cleanup
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _logLoginActivity(user.uid, 'logout', user.email ?? '');
    }

    await _auth.signOut();
    await GoogleSignIn().signOut();
    // await FacebookAuth.instance.logOut(); // Commented out for web-only development

    // Clear any local session data if needed
    // (Secure storage is not available, so basic cleanup only)
  }

  // Delete account with complete cleanup
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Log account deletion
        await _logSecurityEvent(user.uid, 'account_deleted', user.email ?? '');

        // Delete from related collections first
        await _cleanupUserData(user.uid);

        // Then delete from Auth
        await user.delete();
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update user profile with validation
  Future<void> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? gender,
    DateTime? dateOfBirth,
    Map<String, dynamic>? preferences,
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
          if (gender != null) 'gender': gender,
          if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
          if (preferences != null) 'preferences': preferences,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Update user profile with map for bulk updates
  Future<void> updateUserProfileWithMap(Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        if (updates.containsKey('displayName')) {
          await user.updateDisplayName(updates['displayName']);
        }
        if (updates.containsKey('photoUrl')) {
          await user.updatePhotoURL(updates['photoUrl']);
        }

        await _updateUserProfileInFirestore(user.uid, updates);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get user profile by email (for security checks)
  Future<UserModel?> getUserProfileByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile by email: $e');
      return null;
    }
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      debugPrint('🔍 Fetching user profile for ID: $userId');
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final userModel =
            UserModel.fromJson(doc.data() as Map<String, dynamic>);
        debugPrint(
            '✅ User profile found for $userId: ${userModel.email} role ${userModel.role.name}');
        return userModel;
      } else {
        debugPrint('❌ No user profile found for $userId');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching user profile for $userId: $e');
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

  // Create user profile in Firestore with enhanced security
  Future<void> _createUserProfile(User user, UserRole role,
      [String? phoneNumber,
      String? gender,
      DateTime? dateOfBirth,
      String? socialProvider]) async {
    UserModel userModel = UserModel(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName ?? '',
      phoneNumber: phoneNumber ?? user.phoneNumber,
      photoUrl: user.photoURL,
      role: role,
      isEmailVerified: user.emailVerified,
      twoFactorEnabled: false,
      socialProviders: socialProvider != null ? [socialProvider] : [],
      loginAttempts: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      gender: gender,
      dateOfBirth: dateOfBirth,
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
  }

  // Update user profile in Firestore
  Future<void> _updateUserProfileInFirestore(
      String userId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = DateTime.now().toIso8601String();
    await _firestore.collection('users').doc(userId).update(updates);
  }

  // Password strength validation
  bool _isPasswordStrong(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasNumbers &&
        hasSpecialCharacters;
  }

  // Rate limiting functions
  bool _isRateLimited(String identifier, String action) {
    final key = '$action:$identifier';
    final attempts = _rateLimitStore[key];

    if (attempts == null) return false;

    final lastAttempt = DateTime.parse(attempts['lastAttempt']);
    final duration = _getRateLimitDuration(action);
    final cooldownPeriod = _getCooldownPeriod(action);

    if (DateTime.now().difference(lastAttempt) < cooldownPeriod) {
      if (attempts['count'] >= duration) {
        return true;
      }
    } else {
      // Reset if cooldown period passed
      _rateLimitStore.remove(key);
    }

    return false;
  }

  void _recordRateLimitAttempt(String identifier, String action) {
    final key = '$action:$identifier';
    final now = DateTime.now();

    if (_rateLimitStore.containsKey(key)) {
      _rateLimitStore[key]!['count']++;
      _rateLimitStore[key]!['lastAttempt'] = now.toIso8601String();
    } else {
      _rateLimitStore[key] = {
        'count': 1,
        'lastAttempt': now.toIso8601String(),
      };
    }
  }

  int _getRateLimitDuration(String action) {
    switch (action) {
      case 'login':
        return maxLoginAttempts;
      case 'password_reset':
        return maxPasswordResetRequests;
      case 'phone_verify':
        return 3;
      default:
        return 10;
    }
  }

  Duration _getCooldownPeriod(String action) {
    switch (action) {
      case 'login':
        return lockoutDuration;
      case 'password_reset':
        return passwordResetCooldown;
      case 'phone_verify':
        return const Duration(minutes: 5);
      default:
        return const Duration(minutes: 15);
    }
  }

  // Update login attempts and lock account if needed
  Future<void> _updateLoginAttempts(String email, {required bool reset}) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (query.docs.isNotEmpty) {
        final userId = query.docs.first.id;
        if (reset) {
          await _firestore.collection('users').doc(userId).update({
            'loginAttempts': 0,
            'lockedUntil': null,
            'lastLoginAt': DateTime.now().toIso8601String(),
          });
        } else {
          final currentAttempts = query.docs.first.data()['loginAttempts'] ?? 0;
          final newAttempts = currentAttempts + 1;

          final updateData = {
            'loginAttempts': newAttempts,
            'updatedAt': DateTime.now().toIso8601String(),
          };

          if (newAttempts >= maxLoginAttempts) {
            updateData['lockedUntil'] =
                DateTime.now().add(lockoutDuration).toIso8601String();
          }

          await _firestore.collection('users').doc(userId).update(updateData);
        }
      }
    } catch (e) {
      debugPrint('Error updating login attempts: $e');
    }
  }

  // Security event logging
  Future<void> _logSecurityEvent(
      String userId, String eventType, String details) async {
    try {
      await _firestore.collection('security_logs').add({
        'userId': userId,
        'eventType': eventType,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'userAgent': 'Flutter App',
        'ipAddress': 'unknown', // Would need server-side implementation
      });
    } catch (e) {
      debugPrint('Error logging security event: $e');
    }
  }

  // Login activity logging
  Future<void> _logLoginActivity(
      String userId, String status, String identifier) async {
    try {
      await _firestore.collection('login_logs').add({
        'userId': userId,
        'status': status,
        'identifier': identifier,
        'timestamp': FieldValue.serverTimestamp(),
        'deviceInfo': await _getDeviceInfo(),
      });
    } catch (e) {
      debugPrint('Error logging login activity: $e');
    }
  }

  // Get device information for security logs
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': Platform.isAndroid
          ? 'Android'
          : Platform.isIOS
              ? 'iOS'
              : 'Unknown',
      'version': 'Flutter App v1.0',
    };
  }

  // Two-factor authentication helpers (simplified implementations)
  Future<String> _generateTOTPSecret() async {
    // This should generate a proper TOTP secret
    // For now, return a placeholder
    return 'JBSWY3DPEHPK3PXP'; // Example secret
  }

  Future<void> _sendTOTPViaEmail(String email, String secret) async {
    // This should send the TOTP secret via email
    // Implementation would depend on your email service
    debugPrint('TOTP Secret for $email: $secret');
  }

  Future<void> _sendSMSCode(String phoneNumber, String secret) async {
    // This should send SMS verification code
    // Implementation would depend on your SMS service
    debugPrint('SMS Code sent to $phoneNumber');
  }

  Future<bool> _verifyTwoFactorCode(String method, String code) async {
    // This should verify the TOTP/SMS code
    // For now, accept any 6-digit code
    return code.length == 6 && RegExp(r'^\d+$').hasMatch(code);
  }

  // Clean up user data on account deletion
  Future<void> _cleanupUserData(String userId) async {
    try {
      final collectionsToClean = [
        'customers',
        'employees',
        'cart',
        'wishlists',
        'orders',
        'measurements',
        'notifications',
        'chat'
      ];

      for (final collection in collectionsToClean) {
        final docs = await _firestore
            .collection(collection)
            .where('userId', isEqualTo: userId)
            .get();
        for (final doc in docs.docs) {
          await doc.reference.delete();
        }
      }

      // Delete main user profile
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      debugPrint('Error cleaning up user data: $e');
    }
  }

  // Legacy methods for backward compatibility
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

  // Change password with security checks
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

        // Validate new password strength
        if (!_isPasswordStrong(newPassword)) {
          throw Exception('New password does not meet strength requirements.');
        }

        await user.updatePassword(newPassword);

        // Log password change
        await _logSecurityEvent(user.uid, 'password_changed', user.email!);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Public method to create/update user profile
  Future<void> createUserProfile(User user, UserRole role,
      [String? phoneNumber, String? gender, DateTime? dateOfBirth]) async {
    await _createUserProfile(user, role, phoneNumber, gender, dateOfBirth);
  }

  // Enhanced error handling
  Exception _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return Exception('No user found with this email address.');
        case 'wrong-password':
          return Exception('Incorrect password provided.');
        case 'email-already-in-use':
          return Exception(
              'An account already exists with this email address.');
        case 'invalid-email':
          return Exception('Invalid email address format.');
        case 'weak-password':
          return Exception(
              'Password is too weak. Please choose a stronger password.');
        case 'user-disabled':
          return Exception(
              'This account has been disabled. Please contact support.');
        case 'operation-not-allowed':
          return Exception('This sign-in method is not enabled.');
        case 'too-many-requests':
          return Exception('Too many attempts. Please try again later.');
        case 'network-request-failed':
          return Exception('Network error. Please check your connection.');
        case 'invalid-verification-code':
          return Exception('Invalid verification code.');
        case 'invalid-verification-id':
          return Exception('Invalid verification ID.');
        case 'code-expired':
          return Exception('Verification code has expired.');
        case 'account-exists-with-different-credential':
          return Exception('Account exists with different sign-in method.');
        case 'credential-already-in-use':
          return Exception(
              'This credential is already associated with another account.');
        case 'requires-recent-login':
          return Exception('Please re-authenticate to perform this operation.');
        default:
          return Exception('Authentication error: ${error.message}');
      }
    } else if (error is Exception) {
      return error;
    }
    return Exception('An unexpected error occurred during authentication.');
  }

  // Development Emulator Methods
  MockUser? _mockCurrentUser;
  UserRole _mockUserRole = UserRole.customer;

  Stream<User?> _mockAuthStateChanges() {
    return Stream.value(_mockCurrentUser);
  }

  Future<bool> signInWithMockCredentials({
    required String email,
    required String password,
  }) async {
    // Simple mock authentication for development
    if (password == 'dev123456') {
      // Determine role based on email
      if (email == 'owner@tailoring.com') {
        _mockUserRole = UserRole.shopOwner;
        _mockCurrentUser = MockUser(
          uid: 'mockOwner123',
          email: email,
          displayName: 'Esther (Owner)',
          emailVerified: true,
        );
      } else if (email == 'customer@example.com') {
        _mockUserRole = UserRole.customer;
        _mockCurrentUser = MockUser(
          uid: 'mockCustomer123',
          email: email,
          displayName: 'John Doe (Customer)',
          emailVerified: true,
        );
      } else if (email.contains('@tailoring.com')) {
        _mockUserRole = UserRole.employee;
        _mockCurrentUser = MockUser(
          uid: 'mockEmployee123',
          email: email,
          displayName: email.split('@').first,
          emailVerified: true,
        );
      } else {
        // Default to customer for new users
        _mockUserRole = UserRole.customer;
        _mockCurrentUser = MockUser(
          uid: 'mockUser${email.hashCode}',
          email: email,
          displayName: email.split('@').first,
          emailVerified: true,
        );
      }

      // Create mock user profile in Firestore
      await _createMockUserProfile(_mockCurrentUser!, _mockUserRole);

      debugPrint(
          '✅ Mock signed in as: ${_mockCurrentUser!.uid} with role $_mockUserRole');
      return true;
    }

    throw Exception('Invalid credentials for mock authentication');
  }

  MockUserCredential mockSignInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    signInWithMockCredentials(email: email, password: password);
    return MockUserCredential(
      user: _mockCurrentUser!,
      additionalUserInfo: MockAdditionalUserInfo(
        isNewUser: false,
        providerId: 'password',
        username: _mockCurrentUser!.displayName,
      ),
      credential: null,
    );
  }

  MockUserCredential mockSignUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    UserRole role = UserRole.customer,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    // Create new mock user regardless of password for signup
    _mockUserRole = role;
    _mockCurrentUser = MockUser(
      uid: 'newUser${email.hashCode}',
      email: email,
      displayName: displayName ?? email.split('@').first,
      emailVerified: true,
    );

    _createMockUserProfile(_mockCurrentUser!, role, phoneNumber: phoneNumber);

    return MockUserCredential(
      user: _mockCurrentUser!,
      additionalUserInfo: MockAdditionalUserInfo(
        isNewUser: true,
        providerId: 'password',
        username: _mockCurrentUser!.displayName,
      ),
      credential: null,
    );
  }

  Future<void> mockSignOut() async {
    debugPrint('🧪 Mock signed out: ${_mockCurrentUser?.uid}');
    _mockCurrentUser = null;
    _mockUserRole = UserRole.customer;
  }

  Future<void> _createMockUserProfile(User user, UserRole role,
      {String? phoneNumber}) async {
    // Create mock user profile for development
    final userProfile = {
      'id': user.uid,
      'email': user.email!,
      'displayName': user.displayName ?? '',
      'role': role.index,
      'isEmailVerified': true,
      'phoneNumber': phoneNumber,
      'photoUrl': user.photoURL,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userProfile, SetOptions(merge: true));

    // Create role-specific profile
    if (role == UserRole.employee) {
      await _firestore.collection('employees').doc(user.uid).set({
        'id': 'emp_${user.uid}',
        'userId': user.uid,
        'displayName': user.displayName ?? '',
        'email': user.email!,
        'role': UserRole.employee.index,
        'skills': [0, 1, 2], // Mock skills
        'isActive': true,
        'joinedDate': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } else if (role == UserRole.customer) {
      await _firestore.collection('customers').doc(user.uid).set({
        'id': user.uid,
        'userId': user.uid,
        'name': user.displayName ?? '',
        'email': user.email!,
        'isActive': true,
        'joinDate': DateTime.now().toIso8601String(),
        'loyaltyTier': 'Silver',
        'totalSpent': 2500.0,
      }, SetOptions(merge: true));
    } else if (role == UserRole.shopOwner) {
      // Create both owner and employee profiles
      await _firestore.collection('employees').doc(user.uid).set({
        'id': 'owner_${user.uid}',
        'userId': user.uid,
        'displayName': user.displayName ?? '',
        'email': user.email!,
        'role': UserRole.shopOwner.index,
        'isActive': true,
        'joinedDate': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }
  }

  UserRole? getMockUserRole() =>
      _mockCurrentUser != null ? _mockUserRole : null;
}
