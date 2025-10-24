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
          debugPrint(
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

    debugPrint('🔑 DEMO LOGIN: Starting for $accountKey ($email)');
    _isLoading = true;
    _errorMessage = 'Logging in as $displayName...';
    notifyListeners();

    try {
      // Step 1: Try to sign in first
      UserCredential userCredential;
      try {
        debugPrint('🔄 DEMO LOGIN: Attempting sign in for $email');
        userCredential = await _authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('✅ DEMO LOGIN: Sign in successful');
      } catch (e) {
        // If account doesn't exist or wrong password, create it
        debugPrint('🔄 DEMO LOGIN: Sign in failed, creating account: $e');
        userCredential = await _authService.signUpWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
          role: role,
        );
        debugPrint('✅ DEMO LOGIN: Account created successfully');
      }

      _user = userCredential.user;

      // Step 2: Ensure profile exists in Firestore
      await _loadUserProfile();

      // If profile doesn't exist (shouldn't happen but safety check)
      if (_userProfile == null && _user != null) {
        debugPrint('🔄 DEMO LOGIN: Profile missing, creating it');
        await _authService.createUserProfile(_user!, role);
        await _loadUserProfile();
      }

      if (_userProfile == null) {
        throw Exception('Failed to create or load user profile');
      }

      debugPrint(
          '✅ DEMO LOGIN: Complete - User: ${_user?.email}, Role: ${_userProfile?.role.name}');

      _isLoading = false;
      _errorMessage = 'Demo login successful!';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ DEMO LOGIN FAILED: $e');
      _isLoading = false;
      _errorMessage = 'Demo login failed: $e';
      notifyListeners();
      return false;
    }
  }
}
