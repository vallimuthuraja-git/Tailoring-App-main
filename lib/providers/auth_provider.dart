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

  // Enhanced security states
  bool _isTwoFactorRequired = false;
  String? _twoFactorMethod;
  bool _isAccountLocked = false;
  int _minutesUntilUnlock = 0;
  int _loginAttemptsRemaining = 5;

  // Getters
  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  UserRole get userRole => _userProfile?.role ?? UserRole.customer;
  bool get isTwoFactorRequired => _isTwoFactorRequired;
  String? get twoFactorMethod => _twoFactorMethod;
  bool get isAccountLocked => _isAccountLocked;
  int get minutesUntilUnlock => _minutesUntilUnlock;
  int get loginAttemptsRemaining => _loginAttemptsRemaining;
  AuthService get authService => _authService;
  User? get currentUser => _user; // For compatibility with existing code

  // Check if user is shop owner
  bool get isShopOwner {
    return _userProfile?.role == UserRole.shopOwner;
  }

  // Check if user is admin (now maps to shop owner)
  bool get isAdmin {
    return _userProfile?.role == UserRole.shopOwner;
  }

  // Check if user is employee (includes all specialized roles now consolidated into employee)
  bool get isEmployee {
    return _userProfile?.role == UserRole.employee;
  }

  // Check if user is customer
  bool get isCustomer {
    return _userProfile?.role == UserRole.customer;
  }

  // Check if user is shop owner (legacy alias) - includes special case for owner@tailoring.com
  bool get isShopOwnerOrAdmin {
    // Special case: owner@tailoring.com is treated as shop owner even if role is different
    if (_userProfile?.email == 'owner@tailoring.com') return true;
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

  // Get social providers
  List<String>? get socialProviders {
    return _userProfile?.socialProviders;
  }

  // Get preferences
  Map<String, dynamic>? get userPreferences {
    return _userProfile?.preferences;
  }

  // Get account security status
  bool get twoFactorEnabled {
    return _userProfile?.twoFactorEnabled ?? false;
  }

  // Constructor
  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication with enhanced security
  void _initializeAuth() async {
    _user = _authService.currentUser;

    if (_user != null) {
      // Defer profile loading for faster initial auth check
      Future.delayed(const Duration(milliseconds: 100), () async {
        await _loadUserProfile();
        _updateSecurityStatus();
      });
    }

    // Listen to auth state changes
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Handle auth state changes
  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserProfile();
      _updateSecurityStatus();
    } else {
      _userProfile = null;
      _resetSecurityStatus();
    }
    notifyListeners();
  }

  // Update security status based on user profile
  void _updateSecurityStatus() {
    if (_userProfile != null) {
      _isTwoFactorRequired = _userProfile!.twoFactorEnabled;
      _twoFactorMethod = _userProfile!.twoFactorMethod;
      _isAccountLocked = _userProfile!.isAccountLocked;
      _minutesUntilUnlock = _userProfile!.minutesUntilUnlock;
      _loginAttemptsRemaining = 5 - (_userProfile!.loginAttempts % 5);
    }
  }

  // Reset security status
  void _resetSecurityStatus() {
    _isTwoFactorRequired = false;
    _twoFactorMethod = null;
    _isAccountLocked = false;
    _minutesUntilUnlock = 0;
    _loginAttemptsRemaining = 5;
  }

  // Load user profile from Firestore
  Future<void> _loadUserProfile() async {
    if (_user != null) {
      try {
        _userProfile = await _authService.getUserProfile(_user!.uid);
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

  // Check if the current user has the specified role
  bool hasRole(UserRole role) {
    return userRole == role;
  }

  // Sign out the current user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
      _user = null;
      _userProfile = null;
      _resetSecurityStatus();
    } catch (e) {
      _errorMessage = 'Failed to sign out';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change password for the current user
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to change password';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? gender,
    DateTime? dateOfBirth,
    Map<String, dynamic>? preferences,
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
        preferences: preferences,
      );
      await _loadUserProfile();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Use fast mode for development to avoid security overhead
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
        skipSecurityChecks: !const bool.fromEnvironment('dart.vm.product'),
      );
      return true;
    } catch (e) {
      _errorMessage = 'Failed to sign in';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up with email and password
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
    notifyListeners();
    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName ?? email.split('@').first,
        phoneNumber: phoneNumber,
        role: role,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Failed to sign up';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to sign in with Google';
      return false;
    }
  }

  // Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    try {
      await _authService.signInWithFacebook();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to sign in with Facebook';
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send password reset email';
      return false;
    }
  }
}
