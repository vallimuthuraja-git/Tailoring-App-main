import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/theme_constants.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum LoginStep {
  phone,
  otp,
  additional,
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(); // Keep for future phone OTP feature
  final _otpController = TextEditingController(); // Keep for future phone OTP feature
  bool _obscurePassword = true;
  bool _rememberMe = false;
  LoginStep _currentStep = LoginStep.phone; // Keep for future phone OTP feature
  String? _verificationId; // Keep for future phone OTP feature
  String? _phoneNumber; // Keep for future phone OTP feature

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose(); // Keep for future phone OTP feature
    _otpController.dispose(); // Keep for future phone OTP feature
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.isDarkMode
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DarkAppColors.background,
                        DarkAppColors.surface.withValues(alpha: 0.8),
                        DarkAppColors.primary.withValues(alpha: 0.1),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.05),
                        AppColors.background,
                        AppColors.secondary.withValues(alpha: 0.05),
                      ],
                    ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: themeProvider.isGlassyMode
                                  ? [
                                      BoxShadow(
                                        color: (themeProvider.isDarkMode
                                                ? Colors.white
                                                : Colors.black)
                                            .withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: themeProvider.isGlassyMode
                                    ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                                    : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: themeProvider.isGlassyMode
                                        ? (themeProvider.isDarkMode
                                                ? Colors.white.withValues(alpha: 0.1)
                                                : Colors.white.withValues(alpha: 0.2))
                                            : (themeProvider.isDarkMode
                                                ? DarkAppColors.surface.withValues(alpha: 0.95)
                                                : AppColors.surface.withValues(alpha: 0.95)),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : Colors.white.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Logo and Title
                                      Icon(
                                        Icons.design_services,
                                        size: 64,
                                        color: themeProvider.isDarkMode
                                            ? DarkAppColors.primary
                                            : AppColors.primary,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Welcome Back',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: themeProvider.isDarkMode
                                              ? DarkAppColors.onBackground
                                              : AppColors.onBackground,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Sign in with your email and password',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.isDarkMode
                                              ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                              : AppColors.onSurface.withValues(alpha: 0.7),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(height: 40),

                                      // Login Form
                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            // Email Field
                                            TextFormField(
                                              controller: _emailController,
                                              keyboardType: TextInputType.emailAddress,
                                              style: TextStyle(
                                                color: themeProvider.isDarkMode
                                                    ? DarkAppColors.onSurface
                                                    : AppColors.onSurface,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: 'Email',
                                                hintText: 'Enter your email',
                                                prefixIcon: Icon(
                                                  Icons.email,
                                                  color: themeProvider.isDarkMode
                                                      ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                                      : AppColors.onSurface.withValues(alpha: 0.7),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                                        : AppColors.onSurface.withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                                        : AppColors.onSurface.withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.primary
                                                        : AppColors.primary,
                                                    width: 2,
                                                  ),
                                                ),
                                                filled: true,
                                                fillColor: themeProvider.isGlassyMode
                                                    ? Colors.transparent
                                                    : (themeProvider.isDarkMode
                                                        ? DarkAppColors.surface.withValues(alpha: 0.8)
                                                        : AppColors.surface.withValues(alpha: 0.8)),
                                                labelStyle: TextStyle(
                                                  color: themeProvider.isDarkMode
                                                      ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                                      : AppColors.onSurface.withValues(alpha: 0.7),
                                                ),
                                                hintStyle: TextStyle(
                                                  color: themeProvider.isDarkMode
                                                      ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                                                      : AppColors.onSurface.withValues(alpha: 0.5),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter your email';
                                                }
                                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                                  return 'Please enter a valid email';
                                                }
                                                return null;
                                              },
                                            ),

                                            const SizedBox(height: 20),

                                            // Password Field
                                            TextFormField(
                                              controller: _passwordController,
                                              obscureText: _obscurePassword,
                                              style: TextStyle(
                                                color: themeProvider.isDarkMode
                                                    ? DarkAppColors.onSurface
                                                    : AppColors.onSurface,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: 'Password',
                                                hintText: 'Enter your password',
                                                prefixIcon: Icon(
                                                  Icons.lock,
                                                  color: themeProvider.isDarkMode
                                                      ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                                      : AppColors.onSurface.withValues(alpha: 0.7),
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                                        : AppColors.onSurface.withValues(alpha: 0.7),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscurePassword = !_obscurePassword;
                                                    });
                                                  },
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                                        : AppColors.onSurface.withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                                        : AppColors.onSurface.withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.primary
                                                        : AppColors.primary,
                                                    width: 2,
                                                  ),
                                                ),
                                                filled: true,
                                                fillColor: themeProvider.isGlassyMode
                                                    ? Colors.transparent
                                                    : (themeProvider.isDarkMode
                                                        ? DarkAppColors.surface.withValues(alpha: 0.8)
                                                        : AppColors.surface.withValues(alpha: 0.8)),
                                                labelStyle: TextStyle(
                                                  color: themeProvider.isDarkMode
                                                      ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                                      : AppColors.onSurface.withValues(alpha: 0.7),
                                                ),
                                                hintStyle: TextStyle(
                                                  color: themeProvider.isDarkMode
                                                      ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                                                      : AppColors.onSurface.withValues(alpha: 0.5),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please enter your password';
                                                }
                                                if (value.length < 6) {
                                                  return 'Password must be at least 6 characters';
                                                }
                                                return null;
                                              },
                                            ),

                                            const SizedBox(height: 12),

                                            // Remember Me Checkbox
                                            Row(
                                              children: [
                                                Checkbox(
                                                  value: _rememberMe,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _rememberMe = value ?? false;
                                                    });
                                                  },
                                                  activeColor: themeProvider.isDarkMode
                                                      ? DarkAppColors.primary
                                                      : AppColors.primary,
                                                  checkColor: themeProvider.isDarkMode
                                                      ? DarkAppColors.onPrimary
                                                      : AppColors.onPrimary,
                                                ),
                                                Text(
                                                  'Remember me',
                                                  style: TextStyle(
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.onSurface.withValues(alpha: 0.8)
                                                        : AppColors.onSurface.withValues(alpha: 0.8),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const Spacer(),
                                                // Forgot Password
                                                TextButton(
                                                  onPressed: () => _navigateToForgotPassword(context),
                                                  child: Text(
                                                    'Forgot Password?',
                                                    style: TextStyle(
                                                      color: themeProvider.isDarkMode
                                                          ? DarkAppColors.primary
                                                          : AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 20),

                                            const SizedBox(height: 32),

                                            // Error Message
                                            if (authProvider.errorMessage != null)
                                              Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: themeProvider.isDarkMode
                                                      ? DarkAppColors.error.withValues(alpha: 0.1)
                                                      : AppColors.error.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.error.withValues(alpha: 0.3)
                                                        : AppColors.error.withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  authProvider.errorMessage!,
                                                  style: TextStyle(
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.error
                                                        : AppColors.error,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),

                                            if (authProvider.errorMessage != null) const SizedBox(height: 24),

                                            // Login Button
                                            SizedBox(
                                              height: 56,
                                              child: ElevatedButton(
                                                onPressed: authProvider.isLoading ? null : _handleLogin,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: themeProvider.isDarkMode
                                                      ? DarkAppColors.primary
                                                      : AppColors.primary,
                                                  foregroundColor: themeProvider.isDarkMode
                                                      ? DarkAppColors.onPrimary
                                                      : AppColors.onPrimary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  elevation: themeProvider.isGlassyMode ? 0 : 4,
                                                ),
                                                child: authProvider.isLoading
                                                    ? const SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                        ),
                                                      )
                                                    : const Text(
                                                        'Sign In',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                              ),
                                            ),

                                            const SizedBox(height: 20),

                                            // Demo Login Buttons
                                             Column(
                                               children: [
                                                 // Demo Admin Button
                                                 ElevatedButton.icon(
                                                   onPressed: authProvider.isLoading
                                                       ? null
                                                       : () => _demoLogin(context, UserRole.admin),
                                                   icon: const Icon(Icons.admin_panel_settings, size: 18),
                                                   label: const Text('Demo Admin'),
                                                   style: ElevatedButton.styleFrom(
                                                     backgroundColor: themeProvider.isDarkMode
                                                         ? Colors.red.shade700.withValues(alpha: 0.8)
                                                         : Colors.red.shade600.withValues(alpha: 0.8),
                                                     foregroundColor: Colors.white,
                                                     shape: RoundedRectangleBorder(
                                                       borderRadius: BorderRadius.circular(12),
                                                     ),
                                                     elevation: 0,
                                                   ),
                                                 ),
                                                 const SizedBox(height: 16),
                                                 Row(
                                                   children: [
                                                     Expanded(
                                                       child: ElevatedButton.icon(
                                                         onPressed: authProvider.isLoading
                                                             ? null
                                                             : () => _demoLogin(context, UserRole.customer),
                                                         icon: const Icon(Icons.person, size: 18),
                                                         label: const Text('Demo Customer'),
                                                         style: ElevatedButton.styleFrom(
                                                           backgroundColor: themeProvider.isDarkMode
                                                               ? DarkAppColors.secondary.withValues(alpha: 0.8)
                                                               : AppColors.secondary.withValues(alpha: 0.8),
                                                           foregroundColor: themeProvider.isDarkMode
                                                               ? DarkAppColors.onSecondary
                                                               : AppColors.onSecondary,
                                                           shape: RoundedRectangleBorder(
                                                             borderRadius: BorderRadius.circular(12),
                                                           ),
                                                           elevation: 0,
                                                         ),
                                                       ),
                                                     ),
                                                     const SizedBox(width: 12),
                                                     Expanded(
                                                       child: ElevatedButton.icon(
                                                         onPressed: authProvider.isLoading
                                                             ? null
                                                             : () => _demoLogin(context, UserRole.shopOwner),
                                                         icon: const Icon(Icons.store, size: 18),
                                                         label: const Text('Demo Shop'),
                                                         style: ElevatedButton.styleFrom(
                                                           backgroundColor: themeProvider.isDarkMode
                                                               ? Colors.orange.shade700.withValues(alpha: 0.8)
                                                               : Colors.orange.shade600.withValues(alpha: 0.8),
                                                           foregroundColor: Colors.white,
                                                           shape: RoundedRectangleBorder(
                                                             borderRadius: BorderRadius.circular(12),
                                                           ),
                                                           elevation: 0,
                                                         ),
                                                       ),
                                                     ),
                                                   ],
                                                 ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'Demo Partners',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.onSurface
                                                        : AppColors.onSurface,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: authProvider.isLoading
                                                            ? null
                                                            : () => _demoLogin(context, UserRole.employee),
                                                        icon: const Icon(Icons.work, size: 18),
                                                        label: const Text('General Employee'),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: themeProvider.isDarkMode
                                                              ? Colors.green.shade700.withValues(alpha: 0.8)
                                                              : Colors.green.shade600.withValues(alpha: 0.8),
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          elevation: 0,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: authProvider.isLoading
                                                            ? null
                                                            : () => _demoLogin(context, UserRole.tailor),
                                                        icon: const Icon(Icons.content_cut, size: 18),
                                                        label: const Text('Tailor'),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: themeProvider.isDarkMode
                                                              ? Colors.green.shade500.withValues(alpha: 0.8)
                                                              : Colors.green.shade400.withValues(alpha: 0.8),
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          elevation: 0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: authProvider.isLoading
                                                            ? null
                                                            : () => _demoLogin(context, UserRole.cutter),
                                                        icon: const Icon(Icons.cut_sharp, size: 18),
                                                        label: const Text('Cutter'),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: themeProvider.isDarkMode
                                                              ? Colors.green.shade600.withValues(alpha: 0.8)
                                                              : Colors.green.shade500.withValues(alpha: 0.8),
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          elevation: 0,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed: authProvider.isLoading
                                                            ? null
                                                            : () => _demoLogin(context, UserRole.finisher),
                                                        icon: const Icon(Icons.check_circle, size: 18),
                                                        label: const Text('Finisher'),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: themeProvider.isDarkMode
                                                              ? Colors.green.shade800.withValues(alpha: 0.8)
                                                              : Colors.green.shade300.withValues(alpha: 0.8),
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          elevation: 0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 32),

                                            // Sign Up Link
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Don't have an account? ",
                                                  style: TextStyle(
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                                        : AppColors.onSurface.withValues(alpha: 0.7),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () => _navigateToSignUp(context),
                                                  child: Text(
                                                    'Sign Up',
                                                    style: TextStyle(
                                                      color: themeProvider.isDarkMode
                                                          ? DarkAppColors.primary
                                                          : AppColors.primary,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Load saved credentials from SharedPreferences
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final savedPassword = prefs.getString('saved_password');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      setState(() {
        _rememberMe = rememberMe;
        if (savedEmail != null && rememberMe) {
          _emailController.text = savedEmail;
        }
        if (savedPassword != null && rememberMe) {
          _passwordController.text = savedPassword;
        }
      });
    } catch (e) {
      // If loading fails, continue without saved credentials
      debugPrint('Error loading saved credentials: $e');
    }
  }

  // Save credentials to SharedPreferences
  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setString('saved_password', _passwordController.text);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  // Clear saved credentials
  Future<void> _clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    } catch (e) {
      debugPrint('Error clearing credentials: $e');
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        // Save credentials if Remember Me is checked
        await _saveCredentials();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  void _demoLogin(BuildContext context, UserRole role) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success;

    switch (role) {
      case UserRole.customer:
        success = await authProvider.demoLoginAsCustomer();
        break;
      case UserRole.shopOwner:
        success = await authProvider.demoLoginAsShopOwner();
        break;
      case UserRole.admin:
        success = await authProvider.demoLoginAsAdmin();
        break;
      case UserRole.employee:
        success = await authProvider.demoLoginAsEmployee();
        break;
      case UserRole.tailor:
        success = await authProvider.demoLoginAsTailor();
        break;
      case UserRole.cutter:
        success = await authProvider.demoLoginAsCutter();
        break;
      case UserRole.finisher:
        success = await authProvider.demoLoginAsFinisher();
        break;
      default:
        success = false;
    }

    if (success && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }


  void _navigateToSignUp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _navigateToForgotPassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }


  // Phone OTP methods (kept for future use but currently disabled)
  /*
  void _handleSendOTP() async {
    if (_formKey.currentState!.validate()) {
      // Parse full phone number
      String phoneNumber = '+91' + _phoneController.text.replaceAll('+91', '').replaceAll(' ', '').trim();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _phoneNumber = phoneNumber;
      });
      final success = await authProvider.startPhoneVerification(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _currentStep = LoginStep.otp;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent successfully')),
            );
          }
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          }
        },
        onVerified: (userCredential) async {
          if (mounted) {
            // Auto-verified, log in directly
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.verifyOTP(
              verificationId: _verificationId!,
              smsCode: 'auto',
              role: UserRole.customer,
            );
            if (authProvider.userProfile == null) {
              setState(() {
                _currentStep = LoginStep.additional;
              });
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          }
        },
      );
    }
  }

  void _handleVerifyOTP() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        final userCredential = await authProvider.verifyOTP(
          verificationId: _verificationId!,
          smsCode: _otpController.text,
          role: UserRole.customer,
        );
        if (authProvider.userProfile == null) {
          if (mounted) {
            setState(() {
              _currentStep = LoginStep.additional;
            });
          }
        } else {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } catch (e) {
        // Verification failed, error message already set in authProvider
      }
    }
  }

  void _handleResendOTP() async {
    if (_phoneNumber != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resendOTP(
        phoneNumber: _phoneNumber!,
        onCodeSent: (verificationId) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP resent successfully')),
            );
          }
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          }
        },
      );
    }
  }
  */

  void _handleAdditionalAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    // If email is provided, update profile with display name
    if (_emailController.text.isNotEmpty) {
      String displayName = _emailController.text.split('@')[0];
      try {
        success = await authProvider.updateUserProfile(displayName: displayName);
      } catch (e) {
        success = true; // If update fails, still allow login
      }
    } else {
      success = true; // Allow if no additional auth needed
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }
}
