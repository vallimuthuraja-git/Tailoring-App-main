import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/dev_setup_service.dart';
import '../../utils/theme_constants.dart';
import '../../utils/responsive_utils.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();

    // For development mode, pre-fill with first demo account for quick testing
    if (!const bool.fromEnvironment('dart.vm.product')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_emailController.text.isEmpty) {
          final demoAccount = DevSetupService.getDevCredentials().first;
          _emailController.text = demoAccount['email']!;
          _passwordController.text = demoAccount['password']!;
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final deviceType =
                    ResponsiveUtils.getDeviceType(constraints.maxWidth);
                final isDesktop = deviceType == DeviceType.desktop;
                final isMobile = deviceType == DeviceType.mobile;

                return SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop
                              ? 800
                              : (isMobile ? double.infinity : 500),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.responsiveSpacing(
                                24.0, deviceType),
                            vertical: ResponsiveUtils.responsiveSpacing(
                                32.0, deviceType),
                          ),
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
                                        ? ImageFilter.blur(
                                            sigmaX: 10, sigmaY: 10)
                                        : ImageFilter.blur(
                                            sigmaX: 0, sigmaY: 0),
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        ResponsiveUtils.responsiveSpacing(
                                            32.0, deviceType),
                                      ),
                                      decoration: BoxDecoration(
                                        color: themeProvider.isGlassyMode
                                            ? (themeProvider.isDarkMode
                                                ? Colors.white
                                                    .withValues(alpha: 0.1)
                                                : Colors.white
                                                    .withValues(alpha: 0.2))
                                            : (themeProvider.isDarkMode
                                                ? DarkAppColors.surface
                                                    .withValues(alpha: 0.95)
                                                : AppColors.surface
                                                    .withValues(alpha: 0.95)),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                                  .withValues(alpha: 0.2)
                                              : Colors.white
                                                  .withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
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
                                              fontSize: ResponsiveUtils
                                                  .responsiveFontSize(
                                                      28.0, deviceType),
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
                                              fontSize: ResponsiveUtils
                                                  .responsiveFontSize(
                                                      16.0, deviceType),
                                              color: themeProvider.isDarkMode
                                                  ? DarkAppColors.onSurface
                                                      .withValues(alpha: 0.7)
                                                  : AppColors.onSurface
                                                      .withValues(alpha: 0.7),
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
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  style: TextStyle(
                                                    color: themeProvider
                                                            .isDarkMode
                                                        ? DarkAppColors
                                                            .onSurface
                                                        : AppColors.onSurface,
                                                  ),
                                                  decoration: InputDecoration(
                                                    labelText: 'Email',
                                                    hintText:
                                                        'Enter your email',
                                                    prefixIcon: Icon(
                                                      Icons.email,
                                                      color: themeProvider
                                                              .isDarkMode
                                                          ? DarkAppColors
                                                              .onSurface
                                                              .withValues(
                                                                  alpha: 0.7)
                                                          : AppColors.onSurface
                                                              .withValues(
                                                                  alpha: 0.7),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      borderSide: BorderSide(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.3)
                                                            : AppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.3),
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      borderSide: BorderSide(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.3)
                                                            : AppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.3),
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      borderSide: BorderSide(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .primary
                                                            : AppColors.primary,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    filled: true,
                                                    fillColor: themeProvider
                                                            .isGlassyMode
                                                        ? Colors.transparent
                                                        : (themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .surface
                                                                .withValues(
                                                                    alpha: 0.8)
                                                            : AppColors.surface
                                                                .withValues(
                                                                    alpha:
                                                                        0.8)),
                                                    labelStyle: TextStyle(
                                                      color: themeProvider
                                                              .isDarkMode
                                                          ? DarkAppColors
                                                              .onSurface
                                                              .withValues(
                                                                  alpha: 0.7)
                                                          : AppColors.onSurface
                                                              .withValues(
                                                                  alpha: 0.7),
                                                    ),
                                                    hintStyle: TextStyle(
                                                      color: themeProvider
                                                              .isDarkMode
                                                          ? DarkAppColors
                                                              .onSurface
                                                              .withValues(
                                                                  alpha: 0.5)
                                                          : AppColors.onSurface
                                                              .withValues(
                                                                  alpha: 0.5),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter your email';
                                                    }
                                                    if (!RegExp(
                                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                        .hasMatch(value)) {
                                                      return 'Please enter a valid email';
                                                    }
                                                    return null;
                                                  },
                                                ),

                                                const SizedBox(height: 20),

                                                // Password Field
                                                TextFormField(
                                                  controller:
                                                      _passwordController,
                                                  obscureText: _obscurePassword,
                                                  style: TextStyle(
                                                    color: themeProvider
                                                            .isDarkMode
                                                        ? DarkAppColors
                                                            .onSurface
                                                        : AppColors.onSurface,
                                                  ),
                                                  decoration: InputDecoration(
                                                    labelText: 'Password',
                                                    hintText:
                                                        'Enter your password',
                                                    prefixIcon: Icon(
                                                      Icons.lock,
                                                      color: themeProvider
                                                              .isDarkMode
                                                          ? DarkAppColors
                                                              .onSurface
                                                              .withValues(
                                                                  alpha: 0.7)
                                                          : AppColors.onSurface
                                                              .withValues(
                                                                  alpha: 0.7),
                                                    ),
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                        _obscurePassword
                                                            ? Icons.visibility
                                                            : Icons
                                                                .visibility_off,
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.7)
                                                            : AppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.7),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _obscurePassword =
                                                              !_obscurePassword;
                                                        });
                                                      },
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      borderSide: BorderSide(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.3)
                                                            : AppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.3),
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      borderSide: BorderSide(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.3)
                                                            : AppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.3),
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      borderSide: BorderSide(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .primary
                                                            : AppColors.primary,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    filled: true,
                                                    fillColor: themeProvider
                                                            .isGlassyMode
                                                        ? Colors.transparent
                                                        : (themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .surface
                                                                .withValues(
                                                                    alpha: 0.8)
                                                            : AppColors.surface
                                                                .withValues(
                                                                    alpha:
                                                                        0.8)),
                                                    labelStyle: TextStyle(
                                                      color: themeProvider
                                                              .isDarkMode
                                                          ? DarkAppColors
                                                              .onSurface
                                                              .withValues(
                                                                  alpha: 0.7)
                                                          : AppColors.onSurface
                                                              .withValues(
                                                                  alpha: 0.7),
                                                    ),
                                                    hintStyle: TextStyle(
                                                      color: themeProvider
                                                              .isDarkMode
                                                          ? DarkAppColors
                                                              .onSurface
                                                              .withValues(
                                                                  alpha: 0.5)
                                                          : AppColors.onSurface
                                                              .withValues(
                                                                  alpha: 0.5),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
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
                                                          _rememberMe =
                                                              value ?? false;
                                                        });
                                                      },
                                                      activeColor: themeProvider
                                                              .isDarkMode
                                                          ? DarkAppColors
                                                              .primary
                                                          : AppColors.primary,
                                                      checkColor: themeProvider
                                                              .isDarkMode
                                                          ? DarkAppColors
                                                              .onPrimary
                                                          : AppColors.onPrimary,
                                                    ),
                                                    Text(
                                                      'Remember me',
                                                      style: TextStyle(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.8)
                                                            : AppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.8),
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    // Forgot Password
                                                    TextButton(
                                                      onPressed: () =>
                                                          _navigateToForgotPassword(
                                                              context),
                                                      child: Text(
                                                        'Forgot Password?',
                                                        style: TextStyle(
                                                          color: themeProvider
                                                                  .isDarkMode
                                                              ? DarkAppColors
                                                                  .primary
                                                              : AppColors
                                                                  .primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 20),

                                                const SizedBox(height: 32),

                                                // Error Message
                                                if (authProvider.errorMessage !=
                                                    null)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration: BoxDecoration(
                                                      color: themeProvider
                                                              .isDarkMode
                                                          ? DarkAppColors.error
                                                              .withValues(
                                                                  alpha: 0.1)
                                                          : AppColors.error
                                                              .withValues(
                                                                  alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .error
                                                                .withValues(
                                                                    alpha: 0.3)
                                                            : AppColors.error
                                                                .withValues(
                                                                    alpha: 0.3),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      authProvider
                                                          .errorMessage!,
                                                      style: TextStyle(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .error
                                                            : AppColors.error,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),

                                                if (authProvider.errorMessage !=
                                                    null)
                                                  const SizedBox(height: 24),

                                                // Login Button
                                                SizedBox(
                                                  height: 56,
                                                  child: ElevatedButton(
                                                    onPressed:
                                                        authProvider.isLoading
                                                            ? null
                                                            : _handleLogin,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          themeProvider
                                                                  .isDarkMode
                                                              ? DarkAppColors
                                                                  .primary
                                                              : AppColors
                                                                  .primary,
                                                      foregroundColor:
                                                          themeProvider
                                                                  .isDarkMode
                                                              ? DarkAppColors
                                                                  .onPrimary
                                                              : AppColors
                                                                  .onPrimary,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      elevation: themeProvider
                                                              .isGlassyMode
                                                          ? 0
                                                          : 4,
                                                    ),
                                                    child: authProvider
                                                            .isLoading
                                                        ? const SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .white),
                                                            ),
                                                          )
                                                        : const Text(
                                                            'Sign In',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                  ),
                                                ),

                                                const SizedBox(height: 20),

                                                // Social Login Buttons
                                                Column(
                                                  children: [
                                                    Text(
                                                      'Or sign in with',
                                                      style: TextStyle(
                                                        fontSize: ResponsiveUtils
                                                            .responsiveFontSize(
                                                                14.0,
                                                                deviceType),
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.6)
                                                            : AppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.6),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: ResponsiveUtils
                                                            .responsiveSpacing(
                                                                12.0,
                                                                deviceType)),
                                                    if (isMobile) ...[
                                                      // Mobile: Stack vertically
                                                      ElevatedButton.icon(
                                                        onPressed: () =>
                                                            _handleGoogleSignIn(
                                                                context),
                                                        icon: Icon(
                                                            Icons.g_mobiledata,
                                                            size: ResponsiveUtils
                                                                .responsiveFontSize(
                                                                    20.0,
                                                                    deviceType)),
                                                        label: Text('Google',
                                                            style: TextStyle(
                                                                fontSize: ResponsiveUtils
                                                                    .responsiveFontSize(
                                                                        16.0,
                                                                        deviceType))),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          foregroundColor:
                                                              Colors.black87,
                                                          minimumSize: Size(
                                                              double.infinity,
                                                              ResponsiveUtils
                                                                  .responsiveSpacing(
                                                                      48.0,
                                                                      deviceType)),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            side:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          elevation: 0,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      ElevatedButton.icon(
                                                        onPressed: () =>
                                                            _handleFacebookSignIn(
                                                                context),
                                                        icon: Icon(
                                                            Icons.facebook,
                                                            size: ResponsiveUtils
                                                                .responsiveFontSize(
                                                                    20.0,
                                                                    deviceType)),
                                                        label: Text('Facebook',
                                                            style: TextStyle(
                                                                fontSize: ResponsiveUtils
                                                                    .responsiveFontSize(
                                                                        16.0,
                                                                        deviceType))),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFF1877F2),
                                                          foregroundColor:
                                                              Colors.white,
                                                          minimumSize: Size(
                                                              double.infinity,
                                                              ResponsiveUtils
                                                                  .responsiveSpacing(
                                                                      48.0,
                                                                      deviceType)),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          elevation: 0,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Desktop/Tablet: Side by side
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                ElevatedButton
                                                                    .icon(
                                                              onPressed: () =>
                                                                  _handleGoogleSignIn(
                                                                      context),
                                                              icon: Icon(
                                                                  Icons
                                                                      .g_mobiledata,
                                                                  size: ResponsiveUtils
                                                                      .responsiveFontSize(
                                                                          20.0,
                                                                          deviceType)),
                                                              label: Text(
                                                                  'Google',
                                                                  style: TextStyle(
                                                                      fontSize: ResponsiveUtils.responsiveFontSize(
                                                                          16.0,
                                                                          deviceType))),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                foregroundColor:
                                                                    Colors
                                                                        .black87,
                                                                minimumSize: Size.fromHeight(
                                                                    ResponsiveUtils
                                                                        .responsiveSpacing(
                                                                            48.0,
                                                                            deviceType)),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                  side: const BorderSide(
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                                elevation: 0,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width: ResponsiveUtils
                                                                  .responsiveSpacing(
                                                                      12.0,
                                                                      deviceType)),
                                                          Expanded(
                                                            child:
                                                                ElevatedButton
                                                                    .icon(
                                                              onPressed: () =>
                                                                  _handleFacebookSignIn(
                                                                      context),
                                                              icon: Icon(
                                                                  Icons
                                                                      .facebook,
                                                                  size: ResponsiveUtils
                                                                      .responsiveFontSize(
                                                                          20.0,
                                                                          deviceType)),
                                                              label: Text(
                                                                  'Facebook',
                                                                  style: TextStyle(
                                                                      fontSize: ResponsiveUtils.responsiveFontSize(
                                                                          16.0,
                                                                          deviceType))),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    const Color(
                                                                        0xFF1877F2),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                minimumSize: Size.fromHeight(
                                                                    ResponsiveUtils
                                                                        .responsiveSpacing(
                                                                            48.0,
                                                                            deviceType)),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                                elevation: 0,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ],
                                                ),

                                                const SizedBox(height: 32),

                                                // Development Login Buttons (only in development)
                                                if (const bool.fromEnvironment(
                                                        'dart.vm.product') ==
                                                    false) ...[
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.green.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: Colors
                                                              .green.shade200),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        const Text(
                                                          '🚀 Firebase Demo Accounts',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        const Text(
                                                          'All accounts created via firebase_data_setup.js',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 12),
                                                        const Text(
                                                          'Password: Pass123',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 12),
                                                        Wrap(
                                                          spacing: 8,
                                                          runSpacing: 8,
                                                          children: DevSetupService
                                                                  .getDevCredentials()
                                                              .map((cred) {
                                                            return ElevatedButton
                                                                .icon(
                                                              onPressed: () =>
                                                                  _handleDevLogin(
                                                                      cred[
                                                                          'email']!,
                                                                      cred[
                                                                          'password']!),
                                                              icon: Icon(
                                                                  _getRoleIcon(cred[
                                                                      'role']!)),
                                                              label: Text(cred[
                                                                  'displayName']!),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    _getRoleColor(
                                                                        cred[
                                                                            'role']!),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        8),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 24),
                                                ],

                                                // Sign Up Link
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Don't have an account? ",
                                                      style: TextStyle(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? DarkAppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.7)
                                                            : AppColors
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.7),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          _navigateToSignUp(
                                                              context),
                                                      child: Text(
                                                        'Sign Up',
                                                        style: TextStyle(
                                                          color: themeProvider
                                                                  .isDarkMode
                                                              ? DarkAppColors
                                                                  .primary
                                                              : AppColors
                                                                  .primary,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ), // Column
                                    ), // inner Container
                                  ), // BackdropFilter
                                ), // ClipRRect
                              ); // Container
                            }, // builder
                          ), // Consumer
                        ), // Padding
                      ), // ConstrainedBox
                    ), // Center
                  ), // SingleChildScrollView
                ); // SafeArea
              }, // LayoutBuilder builder
            ), // LayoutBuilder
          ), // Container
        ); // Scaffold
      }, // builder
    ); // Consumer<ThemeProvider>
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

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        // Save credentials if Remember Me is checked
        await _saveCredentials();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
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

  void _handleGoogleSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _handleFacebookSignIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithFacebook();

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // Development login handlers
  void _handleDevLogin(String email, String password) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(email: email, password: password);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'shop owner':
        return Icons.business;
      case 'employee':
        return Icons.work;
      case 'customer':
        return Icons.person;
      default:
        return Icons.account_circle;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'shop owner':
        return Colors.purple;
      case 'employee':
        return Colors.blue;
      case 'customer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
