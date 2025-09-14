import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/theme_constants.dart';
import '../../widgets/user_avatar.dart';
import '../auth/login_screen.dart';
import 'change_password_screen.dart';
import 'personal_information_screen.dart';
import 'measurements_screen.dart';
import 'address_book_screen.dart';

// Using beautiful theme-level opacity extensions
// No more deprecated withValues(alpha:) calls - everything uses withValues() internally
// ignore_for_file: deprecated_member_use

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        final user = authProvider.userProfile;
        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeScreen = screenWidth > 600; // Tablet breakpoint

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            toolbarHeight: kToolbarHeight + 5,
            backgroundColor: themeProvider.isDarkMode
                ? DarkAppColors.surface
                : AppColors.surface,
            elevation: 0,
            iconTheme: IconThemeData(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            titleTextStyle: TextStyle(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
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
                    constraints: const BoxConstraints(
                        maxWidth: 1200), // Wider for 2-column layout
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
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
                                        ? DarkAppColors.surface
                                            .withValues(alpha: 0.95)
                                        : AppColors.surface
                                            .withValues(alpha: 0.95)),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Main Profile Card (inside the main card container)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: themeProvider.isGlassyMode
                                          ? LinearGradient(
                                              colors: [
                                                themeProvider.isDarkMode
                                                    ? DarkAppColors.primary
                                                        .withValues(alpha: 0.8)
                                                    : AppColors.primary
                                                        .withValues(alpha: 0.8),
                                                themeProvider.isDarkMode
                                                    ? DarkAppColors
                                                        .primaryVariant
                                                        .withValues(alpha: 0.9)
                                                    : AppColors.primaryVariant
                                                        .withValues(alpha: 0.9),
                                              ],
                                            )
                                          : LinearGradient(
                                              colors: [
                                                themeProvider.isDarkMode
                                                    ? DarkAppColors.primary
                                                    : AppColors.primary,
                                                themeProvider.isDarkMode
                                                    ? DarkAppColors
                                                        .primaryVariant
                                                    : AppColors.primaryVariant,
                                              ],
                                            ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            UserAvatar(
                                              displayName:
                                                  user?.displayName ?? 'User',
                                              imageUrl: user?.photoUrl,
                                              radius: 40.0,
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user?.displayName ?? 'User',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    user?.email ?? '',
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.9),
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Text(
                                                      authProvider.userRole ==
                                                              UserRole.customer
                                                          ? 'Customer'
                                                          : authProvider
                                                                      .userRole ==
                                                                  UserRole
                                                                      .shopOwner
                                                              ? 'Esther (Owner)'
                                                              : 'Admin',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Manage your account settings and preferences',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.9),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Responsive Profile Sections
                                  if (isLargeScreen) ...[
                                    // Large screen: 2-column layout
                                    _buildLargeScreenLayout(
                                        context, authProvider, themeProvider),
                                  ] else ...[
                                    // Small screen: Single column layout
                                    _buildSmallScreenLayout(
                                        context, authProvider, themeProvider),
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
        );
      },
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context,
      AuthProvider authProvider, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Settings & App Preferences in 2 columns
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onBackground
                          : AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProfileOption(
                    icon: Icons.person,
                    title: 'Personal Information',
                    subtitle: 'Update your profile details',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const PersonalInformationScreen(),
                        ),
                      );
                    },
                  ),
                  _ProfileOption(
                    icon: Icons.lock,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  _ProfileOption(
                    icon: Icons.straighten,
                    title: 'Measurements',
                    subtitle: 'Manage your body measurements',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MeasurementsScreen(),
                        ),
                      );
                    },
                  ),
                  _ProfileOption(
                    icon: Icons.location_on,
                    title: 'Address Book',
                    subtitle: 'Manage delivery addresses',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddressBookScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onBackground
                          : AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildThemeSelection(context),
                  const SizedBox(height: 24),
                  Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onBackground
                          : AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProfileOption(
                    icon: Icons.help,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                  _ProfileOption(
                    icon: Icons.info,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Logout Button (full width)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _showLogoutDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context,
      AuthProvider authProvider, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Settings
        Text(
          'Account Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onBackground
                : AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 12),

        _ProfileOption(
          icon: Icons.person,
          title: 'Personal Information',
          subtitle: 'Update your profile details',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PersonalInformationScreen(),
              ),
            );
          },
        ),

        _ProfileOption(
          icon: Icons.lock,
          title: 'Change Password',
          subtitle: 'Update your password',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ChangePasswordScreen(),
              ),
            );
          },
        ),

        _ProfileOption(
          icon: Icons.straighten,
          title: 'Measurements',
          subtitle: 'Manage your body measurements',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MeasurementsScreen(),
              ),
            );
          },
        ),

        _ProfileOption(
          icon: Icons.location_on,
          title: 'Address Book',
          subtitle: 'Manage delivery addresses',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddressBookScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // App Preferences
        Text(
          'App Preferences',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onBackground
                : AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 12),

        _buildThemeSelection(context),

        const SizedBox(height: 24),

        // Support
        Text(
          'Support',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onBackground
                : AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 12),

        _ProfileOption(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            // Navigate to help
          },
        ),

        _ProfileOption(
          icon: Icons.info,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () {
            _showAboutDialog(context);
          },
        ),

        const SizedBox(height: 24),

        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _showLogoutDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: [
            _ThemeOption(
              icon: Icons.light_mode,
              title: 'Light Mode',
              subtitle: 'Clean and bright interface',
              color: AppColors.primary,
              isSelected: themeProvider.isLightMode,
              onTap: () => themeProvider.switchToLightMode(),
            ),
            _ThemeOption(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Easy on the eyes in low light',
              color: DarkAppColors.primary,
              isSelected: themeProvider.isDarkMode,
              onTap: () => themeProvider.switchToDarkMode(),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Tailoring Shop Management',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Tailoring App',
      children: [
        const SizedBox(height: 16),
        const Text(
          'AI-Enabled Web-Based Tailoring Shop Management System with Customer Support Chatbot.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: themeProvider.isDarkMode
                ? AppColors.primary
                : AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                : AppColors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.5)
              : AppColors.onSurface.withValues(alpha: 0.5),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                : AppColors.onSurface.withValues(alpha: 0.2),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: color.withValues(alpha: 0.3))
                : null,
          ),
          child: Icon(
            icon,
            color: isSelected ? color : Colors.grey.shade600,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: color)
            : Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected
                ? color.withValues(alpha: 0.3)
                : Colors.grey.shade200,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
