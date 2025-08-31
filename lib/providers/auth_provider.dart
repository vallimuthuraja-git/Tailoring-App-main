import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';


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
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Failed to load user profile';
        notifyListeners();
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
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
        role: role,
      );

      _user = userCredential.user;
      await _loadUserProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
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
      UserCredential userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      await _loadUserProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
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
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
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
      throw e;
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
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(
        displayName: displayName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
      );

      // Reload user profile
      await _loadUserProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
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
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.changePassword(currentPassword, newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
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

    try {
      _isLoading = true;
      _errorMessage = 'Logging in as $displayName...';
      notifyListeners();

      debugPrint('DEBUG: Attempting demo login for $email as $role');

      // First, try to sign in with existing demo account
      try {
        debugPrint('DEBUG: Attempting to sign in existing demo account');
        UserCredential userCredential = await _authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        _user = userCredential.user;
        await _loadUserProfile();

        debugPrint('DEBUG: Successfully signed in existing demo account: ${_user?.email}');

      } catch (e) {
        // If sign-in fails (e.g., account doesn't exist), try to create the account
        debugPrint('DEBUG: Sign in failed, attempting to create demo account: $e');

        try {
          UserCredential userCredential = await _authService.signUpWithEmailAndPassword(
            email: email,
            password: password,
            displayName: displayName,
            role: role,
          );

          _user = userCredential.user;
          // User profile is already created in signUpWithEmailAndPassword
          await _loadUserProfile();

          debugPrint('DEBUG: Successfully created and signed in demo account: ${_user?.email}');

        } catch (createError) {
          debugPrint('DEBUG: Failed to create demo account: $createError');
          throw createError;
        }
      }

      _isLoading = false;
      _errorMessage = 'Demo login successful for $displayName!';
      notifyListeners();

      debugPrint('DEBUG: Demo login completed successfully');
      return true;

    } catch (e) {
      debugPrint('DEBUG: Demo login error: $e');
      _isLoading = false;
      _errorMessage = 'Demo login failed: $e';
      notifyListeners();
      return false;
    }
  }
}
