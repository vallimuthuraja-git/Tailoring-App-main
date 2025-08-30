import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  ),
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
                                        // Back Button
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: IconButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            icon: Icon(
                                              Icons.arrow_back,
                                              color: themeProvider.isDarkMode
                                                  ? DarkAppColors.onSurface
                                                  : AppColors.onSurface,
                                            ),
                                          ),
                                        ),

                                        // Icon and Title
                                        Icon(
                                          Icons.lock_reset,
                                          size: 64,
                                          color: themeProvider.isDarkMode
                                              ? DarkAppColors.primary
                                              : AppColors.primary,
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'Reset Password',
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
                                          'Enter your email address and we\'ll send you a link to reset your password',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: themeProvider.isDarkMode
                                                ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                                : AppColors.onSurface.withValues(alpha: 0.7),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),

                                        const SizedBox(height: 40),

                                        // Reset Password Form
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
                                                  hintText: 'Enter your email address',
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

                                              // Send Reset Email Button
                                              SizedBox(
                                                height: 56,
                                                child: ElevatedButton(
                                                  onPressed: _isLoading ? null : _handlePasswordReset,
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
                                                  child: _isLoading
                                                      ? const SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                          ),
                                                        )
                                                      : const Text(
                                                          'Send Reset Email',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                ),
                                              ),

                                              const SizedBox(height: 24),

                                              // Back to Login
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: Text(
                                                  'Back to Login',
                                                  style: TextStyle(
                                                    color: themeProvider.isDarkMode
                                                        ? DarkAppColors.primary
                                                        : AppColors.primary,
                                                    fontSize: 16,
                                                  ),
                                                ),
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
          ),
        );
      },
    );
  }

  void _handlePasswordReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password reset email sent! Check your inbox.'),
            backgroundColor: Provider.of<ThemeProvider>(context, listen: false).isDarkMode
                ? DarkAppColors.secondary
                : AppColors.secondary,
          ),
        );

        // Navigate back to login after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }
}