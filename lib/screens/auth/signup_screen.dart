import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers for Step 1
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Controllers for Step 2
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  // State variables
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _emailVerificationSent = false;
  bool _phoneVerificationMode = false;
  String _verificationId = '';
  String _smsCode = '';
  int _currentStep = 0;

  UserRole _selectedRole = UserRole.customer;
  final List<UserRole> _availableRoles = [
    UserRole.customer,
    UserRole.employee,
    UserRole.tailor,
    UserRole.cutter,
    UserRole.finisher,
  ];

  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = 'Very Weak';
  Color _passwordStrengthColor = Colors.red;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Add listeners for real-time validation
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthText = 'Very Weak';
        _passwordStrengthColor = Colors.red;
      });
      return;
    }

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    // Common patterns (negative)
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) score = score > 0 ? score - 1 : 0;
    if (RegExp(r'(?:012|123|234|345|456|567|678|789|890)').hasMatch(password)) score = score > 0 ? score - 1 : 0;

    final strength = score / 6.0;
    setState(() {
      _passwordStrength = strength.clamp(0.0, 1.0);
      if (strength < 0.3) {
        _passwordStrengthText = 'Very Weak';
        _passwordStrengthColor = Colors.red;
      } else if (strength < 0.5) {
        _passwordStrengthText = 'Weak';
        _passwordStrengthColor = Colors.orange;
      } else if (strength < 0.7) {
        _passwordStrengthText = 'Good';
        _passwordStrengthColor = Colors.yellow.shade700;
      } else if (strength < 0.9) {
        _passwordStrengthText = 'Strong';
        _passwordStrengthColor = Colors.lightGreen;
      } else {
        _passwordStrengthText = 'Very Strong';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
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
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: themeProvider.isGlassyMode
                              ? [
                                  BoxShadow(
                                    color: (isDarkMode
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
                                    ? (isDarkMode
                                            ? Colors.white.withValues(alpha: 0.1)
                                            : Colors.white.withValues(alpha: 0.2))
                                        : (isDarkMode
                                            ? DarkAppColors.surface.withValues(alpha: 0.95)
                                            : AppColors.surface.withValues(alpha: 0.95)),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Progress Indicator
                                    Row(
                                      children: List.generate(3, (index) {
                                        return Expanded(
                                          child: Container(
                                            height: 4,
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            decoration: BoxDecoration(
                                              color: index <= _currentStep
                                                  ? (isDarkMode ? DarkAppColors.primary : AppColors.primary)
                                                  : Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),

                                    const SizedBox(height: 32),

                                    // Header
                                    Icon(
                                      Icons.person_add,
                                      size: 64,
                                      color: isDarkMode
                                          ? DarkAppColors.primary
                                          : AppColors.primary,
                                    ),

                                    const SizedBox(height: 24),

                                    Text(
                                      _getStepTitle(),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? DarkAppColors.onBackground
                                            : AppColors.onBackground,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      _getStepSubtitle(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDarkMode
                                            ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                            : AppColors.onSurface.withValues(alpha: 0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 40),

                                    // Step Content
                                    _buildStepContent(isDarkMode),

                                    const SizedBox(height: 24),

                                    // Navigation Buttons
                                    _buildNavigationButtons(isDarkMode),

                                    const SizedBox(height: 16),

                                    // Login Link
                                    if (_currentStep == 0) ...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Already have an account? ',
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? DarkAppColors.onSurface
                                                  : AppColors.onSurface,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text(
                                              'Sign In',
                                              style: TextStyle(
                                                color: isDarkMode
                                                    ? DarkAppColors.primary
                                                    : AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Create Account';
      case 1:
        return 'Personal Information';
      case 2:
        return 'Verification';
      default:
        return 'Create Account';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Join our tailoring community';
      case 1:
        return 'Tell us more about yourself';
      case 2:
        return 'Verify your account';
      default:
        return 'Join our tailoring community';
    }
  }

  Widget _buildStepContent(bool isDarkMode) {
    switch (_currentStep) {
      case 0:
        return _buildAccountSetupStep(isDarkMode);
      case 1:
        return _buildPersonalInfoStep(isDarkMode);
      case 2:
        return _buildVerificationStep(isDarkMode);
      default:
        return _buildAccountSetupStep(isDarkMode);
    }
  }

  Widget _buildNavigationButtons(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _goToPreviousStep,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDarkMode ? DarkAppColors.primary : AppColors.primary,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: isDarkMode ? DarkAppColors.primary : AppColors.primary,
                backgroundColor: themeProvider.isGlassyMode ? Colors.transparent : null,
              ),
              child: const Text('Back'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleStepNavigation,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? DarkAppColors.primary : AppColors.primary,
              foregroundColor: isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: themeProvider.isGlassyMode ? 0 : 4,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(_currentStep == 2 ? 'Complete Registration' : 'Continue'),
          ),
        ),
      ],
    );
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  void _goToNextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  Future<void> _handleStepNavigation() async {
    switch (_currentStep) {
      case 0:
        if (_validateAccountSetupStep()) {
          _goToNextStep();
        }
        break;
      case 1:
        if (_validatePersonalInfoStep()) {
          _goToNextStep();
        }
        break;
      case 2:
        await _handleFinalSignup();
        break;
    }
  }

  // Step 1: Account Setup
  Widget _buildAccountSetupStep(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email address',
              prefixIcon: Icon(
                Icons.email,
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                      : AppColors.onSurface.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                      : AppColors.onSurface.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: themeProvider.isGlassyMode
                  ? Colors.transparent
                  : (isDarkMode
                      ? DarkAppColors.surface.withValues(alpha: 0.8)
                      : AppColors.surface.withValues(alpha: 0.8)),
              labelStyle: TextStyle(
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
              hintStyle: TextStyle(
                color: isDarkMode
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

          const SizedBox(height: 16),

          // Phone Field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            style: TextStyle(
              color: isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(
                Icons.phone,
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                      : AppColors.onSurface.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                      : AppColors.onSurface.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: themeProvider.isGlassyMode
                  ? Colors.transparent
                  : (isDarkMode
                      ? DarkAppColors.surface.withValues(alpha: 0.8)
                      : AppColors.surface.withValues(alpha: 0.8)),
              labelStyle: TextStyle(
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
              hintStyle: TextStyle(
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                    : AppColors.onSurface.withValues(alpha: 0.5),
              ),
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password Field with Strength Indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(
                  color: isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Create a strong password',
                  prefixIcon: Icon(
                    Icons.lock,
                    color: isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                        : AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: isDarkMode
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
                      color: isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                          : AppColors.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                          : AppColors.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: themeProvider.isGlassyMode
                      ? Colors.transparent
                      : (isDarkMode
                          ? DarkAppColors.surface.withValues(alpha: 0.8)
                          : AppColors.surface.withValues(alpha: 0.8)),
                  labelStyle: TextStyle(
                    color: isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                        : AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                  hintStyle: TextStyle(
                    color: isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                        : AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  if (_passwordStrength < 0.5) {
                    return 'Please choose a stronger password';
                  }
                  return null;
                },
              ),

              if (_passwordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _passwordStrength,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _passwordStrengthText,
                      style: TextStyle(
                        color: _passwordStrengthColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDarkMode
                  ? DarkAppColors.surface.withValues(alpha: 0.5)
                  : AppColors.surface.withValues(alpha: 0.5),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Terms and Conditions
          Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: isDarkMode
                          ? DarkAppColors.onSurface
                          : AppColors.onSurface,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          color: isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        // Add onTap for terms and conditions
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        // Add onTap for privacy policy
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 2: Personal Information
  Widget _buildPersonalInfoStep(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Role Selection
        Text(
          'Select Your Role',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableRoles.map((role) {
            final isSelected = _selectedRole == role;
            return ChoiceChip(
              label: Text(_getRoleDisplayName(role)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedRole = role;
                  });
                }
              },
              backgroundColor: isDarkMode
                  ? DarkAppColors.surface
                  : AppColors.surface,
              selectedColor: isDarkMode
                  ? DarkAppColors.primary.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? (isDarkMode ? DarkAppColors.primary : AppColors.primary)
                    : (isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // First Name Field
        TextFormField(
          controller: _firstNameController,
          style: TextStyle(
            color: isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
          decoration: InputDecoration(
            labelText: 'First Name',
            hintText: 'Enter your first name',
            prefixIcon: Icon(
              Icons.person,
              color: isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                    : AppColors.onSurface.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                    : AppColors.onSurface.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: themeProvider.isGlassyMode
                ? Colors.transparent
                : (isDarkMode
                    ? DarkAppColors.surface.withValues(alpha: 0.8)
                    : AppColors.surface.withValues(alpha: 0.8)),
            labelStyle: TextStyle(
              color: isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
            hintStyle: TextStyle(
              color: isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                  : AppColors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your first name';
            }
            if (value.length < 2) {
              return 'First name must be at least 2 characters';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Last Name Field
        TextFormField(
          controller: _lastNameController,
          style: TextStyle(
            color: isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
          decoration: InputDecoration(
            labelText: 'Last Name',
            hintText: 'Enter your last name',
            prefixIcon: Icon(
              Icons.person_outline,
              color: isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                    : AppColors.onSurface.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                    : AppColors.onSurface.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: themeProvider.isGlassyMode
                ? Colors.transparent
                : (isDarkMode
                    ? DarkAppColors.surface.withValues(alpha: 0.8)
                    : AppColors.surface.withValues(alpha: 0.8)),
            labelStyle: TextStyle(
              color: isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
            hintStyle: TextStyle(
              color: isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                  : AppColors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your last name';
            }
            if (value.length < 2) {
              return 'Last name must be at least 2 characters';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Address Field
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          style: TextStyle(
            color: isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
          decoration: InputDecoration(
            labelText: 'Address',
            hintText: 'Enter your complete address',
            prefixIcon: Icon(
              Icons.home,
              color: isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                    : AppColors.onSurface.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                    : AppColors.onSurface.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: themeProvider.isGlassyMode
                ? Colors.transparent
                : (isDarkMode
                    ? DarkAppColors.surface.withValues(alpha: 0.8)
                    : AppColors.surface.withValues(alpha: 0.8)),
            labelStyle: TextStyle(
              color: isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
            hintStyle: TextStyle(
              color: isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                  : AppColors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            if (value.length < 10) {
              return 'Please enter a complete address';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // City and Pincode Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _cityController,
                style: TextStyle(
                  color: isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'City',
                  hintText: 'Enter your city',
                  prefixIcon: Icon(
                    Icons.location_city,
                    color: isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                        : AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                          : AppColors.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                          : AppColors.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: themeProvider.isGlassyMode
                      ? Colors.transparent
                      : (isDarkMode
                          ? DarkAppColors.surface.withValues(alpha: 0.8)
                          : AppColors.surface.withValues(alpha: 0.8)),
                  labelStyle: TextStyle(
                    color: isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                        : AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                  hintStyle: TextStyle(
                    color: isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                        : AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: TextStyle(
                  color: isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Pincode',
                  hintText: 'Enter pincode',
                  prefixIcon: Icon(
                    Icons.pin,
                    color: isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                        : AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                          : AppColors.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                          : AppColors.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: themeProvider.isGlassyMode
                      ? Colors.transparent
                      : (isDarkMode
                          ? DarkAppColors.surface.withValues(alpha: 0.8)
                          : AppColors.surface.withValues(alpha: 0.8)),
                  labelStyle: TextStyle(
                    color: isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                        : AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                  hintStyle: TextStyle(
                    color: isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                        : AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pincode';
                  }
                  if (value.length != 6) {
                    return 'Pincode must be 6 digits';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step 3: Verification
  Widget _buildVerificationStep(bool isDarkMode) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Verification Options
        Text(
          'Choose Verification Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
        ),

        const SizedBox(height: 16),

        // Email Verification Option
        Card(
          color: isDarkMode
              ? DarkAppColors.surface
              : AppColors.surface,
          child: ListTile(
            leading: Icon(
              Icons.email,
              color: isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
            ),
            title: const Text('Email Verification'),
            subtitle: Text('Send verification link to ${_emailController.text}'),
            trailing: _emailVerificationSent
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.arrow_forward_ios),
            onTap: _emailVerificationSent ? null : () => _sendEmailVerification(),
          ),
        ),

        const SizedBox(height: 12),

        // Phone Verification Option
        Card(
          color: isDarkMode
              ? DarkAppColors.surface
              : AppColors.surface,
          child: ListTile(
            leading: Icon(
              Icons.phone,
              color: isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
            ),
            title: const Text('Phone Verification'),
            subtitle: Text('Send OTP to ${_phoneController.text}'),
            trailing: _phoneVerificationMode
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.arrow_forward_ios),
            onTap: () => _sendPhoneVerification(),
          ),
        ),

        if (_phoneVerificationMode) ...[
          const SizedBox(height: 24),

          // OTP Input Field
          TextFormField(
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: TextStyle(
              color: isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'Enter OTP',
              hintText: 'Enter 6-digit OTP',
              prefixIcon: Icon(
                Icons.lock,
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                      : AppColors.onSurface.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                      : AppColors.onSurface.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: themeProvider.isGlassyMode
                  ? Colors.transparent
                  : (isDarkMode
                      ? DarkAppColors.surface.withValues(alpha: 0.8)
                      : AppColors.surface.withValues(alpha: 0.8)),
              labelStyle: TextStyle(
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
              hintStyle: TextStyle(
                color: isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                    : AppColors.onSurface.withValues(alpha: 0.5),
              ),
              counterText: '',
            ),
            onChanged: (value) {
              setState(() {
                _smsCode = value;
              });
            },
            validator: (value) {
              if (_phoneVerificationMode && (value == null || value.isEmpty)) {
                return 'Please enter the OTP';
              }
              if (_phoneVerificationMode && value!.length != 6) {
                return 'OTP must be 6 digits';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () => _resendOTP(),
            child: const Text('Resend OTP'),
          ),
        ],
      ],
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.employee:
        return 'Employee';
      case UserRole.tailor:
        return 'Master Tailor';
      case UserRole.cutter:
        return 'Fabric Cutter';
      case UserRole.finisher:
        return 'Finisher';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.apprentice:
        return 'Apprentice';
      default:
        return 'Customer';
    }
  }

  bool _validateAccountSetupStep() {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the Terms and Conditions to continue'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }
      return true;
    }
    return false;
  }

  bool _validatePersonalInfoStep() {
    // Create a temporary form key for validation
    final formKey = GlobalKey<FormState>();
    bool isValid = true;

    if (_firstNameController.text.isEmpty || _firstNameController.text.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid first name')),
      );
      isValid = false;
    }

    if (_lastNameController.text.isEmpty || _lastNameController.text.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid last name')),
      );
      isValid = false;
    }

    if (_addressController.text.isEmpty || _addressController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a complete address')),
      );
      isValid = false;
    }

    if (_cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your city')),
      );
      isValid = false;
    }

    if (_pincodeController.text.isEmpty || _pincodeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit pincode')),
      );
      isValid = false;
    }

    return isValid;
  }

  Future<void> _sendEmailVerification() async {
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      await authService.sendEmailVerification();
      setState(() => _emailVerificationSent = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendPhoneVerification() async {
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      await authService.verifyPhoneNumber(
        phoneNumber: '+91${_phoneController.text}',
        onCodeSent: (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _phoneVerificationMode = true;
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP sent to your phone number'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send OTP: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
        },
        onVerified: (userCredential) {
          // Auto-verification successful
          setState(() {
            _phoneVerificationMode = true;
            _isLoading = false;
          });
          _handleFinalSignup();
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    await _sendPhoneVerification();
  }

  Future<void> _handleFinalSignup() async {
    setState(() => _isLoading = true);

    try {
      // Verify OTP if phone verification is selected
      if (_phoneVerificationMode && _verificationId.isNotEmpty) {
        final authService = AuthService();
        final userCredential = await authService.verifyOTP(
          verificationId: _verificationId,
          smsCode: _smsCode,
        );

        // OTP verified, now create account
        await _createAccount();
            } else {
        // Email verification or skip verification
        await _createAccount();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createAccount() async {
    try {
      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);

      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text,
        displayName: '${_firstNameController.text} ${_lastNameController.text}',
        role: _selectedRole,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account creation failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


}
