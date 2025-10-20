import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  UserRole get userRole => _userProfile?.role ?? UserRole.customer;
  AuthService get authService => _authService;
  User? get currentUser => _user; // For compatibility with existing code

  // Check if user is shop owner
  bool get isShopOwner {
    return _userProfile?.role == UserRole.shopOwner;
  }

  // Check if user is shop owner (legacy alias)
  bool get isShopOwnerOrAdmin {
    return isShopOwner;
  }

  // Get user display name
  String get displayName {
    return _userProfile?.displayName ?? _user?.displayName ?? 'User';
  }

  // Get user email
  String? get email {
    return _userProfile?.email ?? _user?.email;
  }

  // Get user phone number
  String? get phoneNumber {
    return _userProfile?.phoneNumber ?? _user?.phoneNumber;
  }

  // Get user photo URL
  String? get photoUrl {
    return _userProfile?.photoUrl ?? _user?.photoURL;
  }

  // Constructor
  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication
  void _initializeAuth() async {
    _user = _authService.currentUser;

    if (_user != null) {
      await _loadUserProfile();
    }

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile() async {
    if (_user != null) {
      try {
        _userProfile = await _authService.getUserProfile(_user!.uid);
        if (_userProfile?.email == 'admin@demo.com') {
          print(
              '🔍 AUTH PROVIDER LOAD: Admin user profile loaded with role: ${_userProfile?.role.name}');
        }
        notifyListeners();
      } on FirebaseException catch (e) {
        logError(e);
        _errorMessage = getUserFriendlyErrorMessage(e);
        throw FirebaseError('Failed to load user profile', originalError: e);
      } catch (e) {
        logError(e);
        _errorMessage = getUserFriendlyErrorMessage(e);
        throw AppException('Failed to load user profile');
      }
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    UserRole role = UserRole.customer,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential =
          await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
        role: role,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      _user = userCredential.user;
      await _loadUserProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _authService.signInWithGoogle();
      _user = userCredential.user;
      await _loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _authService.signInWithFacebook();
      _user = userCredential.user;
      await _loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential =
          await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      await _loadUserProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Phone authentication
  Future<bool> startPhoneVerification({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(UserCredential userCredential) onVerified,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onError: onError,
        onVerified: onVerified,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
    UserRole role = UserRole.customer,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _authService.verifyOTP(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      _user = userCredential.user;
      await _loadUserProfile();

      // If new user, create profile
      final existingProfile = await _authService.getUserProfile(_user!.uid);
      if (existingProfile == null) {
        // Create user profile for phone auth
        await _authService.createUserProfile(_user!, role, _user!.phoneNumber);
      }

      _isLoading = false;
      notifyListeners();
      return userCredential;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> resendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _authService.resendOTP(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onError: onError,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _userProfile = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      bool isVerified = await _authService.isEmailVerified();
      if (_userProfile != null) {
        _userProfile = UserModel(
          id: _userProfile!.id,
          email: _userProfile!.email,
          displayName: _userProfile!.displayName,
          phoneNumber: _userProfile!.phoneNumber,
          photoUrl: _userProfile!.photoUrl,
          role: _userProfile!.role,
          isEmailVerified: isVerified,
          createdAt: _userProfile!.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      notifyListeners();
      return isVerified;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(
        displayName: displayName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      // Reload user profile
      await _loadUserProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.deleteAccount();
      _user = null;
      _userProfile = null;
      _errorMessage = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.changePassword(currentPassword, newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      logError(e);
      _errorMessage = getUserFriendlyErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Check if user has required role
  bool hasRole(UserRole requiredRole) {
    return _userProfile?.role == requiredRole;
  }

  // Demo login methods with fallback to create account if it doesn't exist
  Future<bool> demoLoginAsCustomer() async {
    return await _demoLogin('customer', UserRole.customer);
  }

  Future<bool> demoLoginAsShopOwner() async {
    return await _demoLogin('shopOwner', UserRole.shopOwner);
  }

  Future<bool> demoLoginAsAdmin() async {
    return await _demoLogin('admin', UserRole.admin);
  }

  Future<bool> demoLoginAsEmployee() async {
    return await _demoLogin('employee', UserRole.employee);
  }

  // Updated demo login for employees - all use the consolidated employee role
  Future<bool> demoLoginAsTailor() async {
    return await _demoLogin('tailor', UserRole.employee);
  }

  Future<bool> demoLoginAsCutter() async {
    return await _demoLogin('cutter', UserRole.employee);
  }

  Future<bool> demoLoginAsFinisher() async {
    return await _demoLogin('finisher', UserRole.employee);
  }

  Future<bool> demoLoginAsHelper() async {
    return await _demoLogin('helper', UserRole.employee);
  }

  Future<bool> _demoLogin(String accountKey, UserRole role) async {
    final account = AuthService.demoAccounts[accountKey]!;
    final email = account['email']!;
    final password = account['password']!;
    final displayName = account['displayName']!;

    print('🔑 DEMO LOGIN START FOR: $accountKey');
    print('📧 Email: $email');
    print('🔒 Password: ***********'); // Hide actual password
    print('👤 Display Name: $displayName');
    print('⚡ Role: $role');

    debugPrint('🔑 DEMO LOGIN START: $accountKey - Email: $email, Role: $role');

    try {
      print(
          '🚀 DEMO LOGIN START: Attempting to login as $displayName ($email)');
      _isLoading = true;
      _errorMessage = 'Logging in as $displayName...';
      notifyListeners();

      debugPrint('🔄 DEMO LOGIN: Setting loading state');
      print('🔍 DEMO LOGIN: Current user before login: $_user');

      // First, try to sign in with existing demo account
      try {
        debugPrint(
            '🔍 DEMO LOGIN: Attempting to sign in existing demo account via AuthService');
        UserCredential userCredential =
            await _authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        _user = userCredential.user;

        debugPrint(
            '✅ DEMO LOGIN: Auth sign-in successful, now loading user profile');
        await _loadUserProfile();

        if (_userProfile == null) {
          debugPrint(
              '❌ DEMO LOGIN: User profile not found after successful auth');
          throw Exception(
              'Demo account exists but profile not found in Firestore');
        }

        debugPrint(
            '✅ DEMO LOGIN: Profile loaded. User: ${_user?.email}, Role: ${_userProfile?.role}, DisplayName: ${_userProfile?.displayName}');
        if (_userProfile?.email == 'admin@demo.com') {
          print(
              '🔍 AUTH PROVIDER: Admin demo login - assigned role: ${_userProfile?.role.name}');
        }
      } catch (e) {
        // If sign-in fails due to wrong password for existing account, try to reset the account
        if (e is FirebaseAuthException && e.code == 'invalid-credential') {
          debugPrint(
              '🚫 DEMO LOGIN: Sign in failed due to invalid credentials, attempting to reset demo account');

          try {
            // Try to delete the existing auth account and recreate it
            // First, try to sign in with whatever password allows access to delete the account
            await _resetAndRecreateDemoAccount(
                email, password, displayName, role);
          } catch (resetError) {
            debugPrint(
                '❌ DEMO LOGIN: Account reset failed ($resetError), trying normal signup fallback');
            // Fall back to trying signup anyway
            try {
              debugPrint(
                  '🔧 DEMO LOGIN: Creating account via AuthService signup');
              UserCredential userCredential =
                  await _authService.signUpWithEmailAndPassword(
                email: email,
                password: password,
                displayName: displayName,
                role: role,
              );

              _user = userCredential.user;

              debugPrint(
                  '✅ DEMO LOGIN: Account created successfully, loading profile');
              await _loadUserProfile();

              if (_userProfile == null) {
                debugPrint('❌ DEMO LOGIN: Profile creation/loading failed');
                throw Exception(
                    'Failed to create/load user profile in Firestore');
              }

              debugPrint(
                  '✅ DEMO LOGIN: Profile created. User: ${_user?.email}, Role: ${_userProfile?.role}, DisplayName: ${_userProfile?.displayName}');
            } catch (createError) {
              debugPrint(
                  '❌ DEMO LOGIN: Fallback account creation failed: $createError');
              throw Exception(
                  'Demo account exists but cannot be accessed. Please contact administrator to reset demo account password. Error: $createError');
            }
          }
        } else {
          // For other types of errors, try to create the account normally
          debugPrint(
              '🚫 DEMO LOGIN: Sign in failed with different error ($e), attempting to create new demo account');

          try {
            debugPrint(
                '🔧 DEMO LOGIN: Creating account via AuthService signup');
            UserCredential userCredential =
                await _authService.signUpWithEmailAndPassword(
              email: email,
              password: password,
              displayName: displayName,
              role: role,
            );

            _user = userCredential.user;

            debugPrint(
                '✅ DEMO LOGIN: Account created successfully, loading profile');
            await _loadUserProfile();

            if (_userProfile == null) {
              debugPrint('❌ DEMO LOGIN: Profile creation/loading failed');
              throw Exception(
                  'Failed to create/load user profile in Firestore');
            }

            debugPrint(
                '✅ DEMO LOGIN: Profile created. User: ${_user?.email}, Role: ${_userProfile?.role}, DisplayName: ${_userProfile?.displayName}');
          } catch (createError) {
            if (createError.toString().contains('An account already exists')) {
              debugPrint(
                  '💡 DEMO LOGIN: Account exists with different credentials - trying manual login fallback');

              // Try direct manual login as final fallback
              try {
                debugPrint('🔑 DEMO LOGIN: Attempting manual login fallback');
                UserCredential userCredential =
                    await _authService.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );

                _user = userCredential.user;

                debugPrint('✅ DEMO LOGIN: Manual login fallback successful');
                await _loadUserProfile();

                if (_userProfile != null) {
                  debugPrint(
                      '✅ DEMO LOGIN: Profile loaded successfully via manual login');
                  // Success! Don't throw error
                } else {
                  debugPrint(
                      '⚠️ DEMO LOGIN: Manual login succeeded but no profile found');
                  // Still consider it a success but log the issue
                }
              } catch (manualLoginError) {
                debugPrint(
                    '❌ DEMO LOGIN: Manual login fallback also failed: $manualLoginError');
                // Only throw error after all attempts fail
                throw Exception(
                    'Demo account exists but all login attempts failed. Please contact administrator to reset demo account password. Manual login: email: $email, password: $password.');
              }
            } else {
              debugPrint('❌ DEMO LOGIN: Account creation failed: $createError');
              rethrow;
            }
          }
        }
      }

      _isLoading = false;
      _errorMessage = 'Demo login successful for $displayName!';
      notifyListeners();

      debugPrint('🎉 DEMO LOGIN: Success! Navigating to home screen now');
      return true;
    } catch (e) {
      debugPrint('💥 DEMO LOGIN ERROR: $e');
      print('❌ DEMO LOGIN FAILURE: Detailed error: $e');
      print('🔍 DEMO LOGIN FAILURE: Error type: ${e.runtimeType.toString()}');
      print('🔍 DEMO LOGIN FAILURE: User profile after failure: $_userProfile');

      _isLoading = false;
      _errorMessage = 'Demo login failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Helper method to reset and recreate demo account
  Future<void> _resetAndRecreateDemoAccount(
      String email, String password, String displayName, UserRole role) async {
    debugPrint('🔄 Attempting to reset demo account: $email');

    // Try to delete the existing profile from Firestore first (we can do this without auth)
    try {
      final firestore = _authService.firestore;
      final query = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
        debugPrint('🗑️ Deleted old Firestore profile for $email');
      }

      // Also delete any employee profiles
      final employeeQuery = await firestore
          .collection('employees')
          .where('email', isEqualTo: email)
          .get();

      for (final doc in employeeQuery.docs) {
        await doc.reference.delete();
        debugPrint('🗑️ Deleted old employee profile for $email');
      }
    } catch (e) {
      debugPrint('⚠️ Could not delete old profiles: $e');
      // Continue anyway
    }

    // Since we can't delete Firebase Auth accounts without proper authentication,
    // we'll try to create a new account. If it fails with "email-already-in-use",
    // it means we need to handle this differently - perhaps the account has a different password
    // that we don't know. In that case, this method should throw an error to fall back to
    // manual signup or alternative approaches.

    debugPrint('🔧 Attempting to recreate demo account for $email');

    try {
      UserCredential userCredential =
          await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );

      _user = userCredential.user;

      debugPrint('✅ Demo account recreated successfully for $email');

      // Load the profile
      await _loadUserProfile();

      if (_userProfile == null) {
        throw Exception('Failed to create user profile after recreation');
      }

      debugPrint('✅ Profile created for recreated account: $email');
    } catch (e) {
      debugPrint('❌ Failed to recreate demo account: $e');
      // Re-throw so the caller can handle the fallback
      rethrow;
    }
  }
}
