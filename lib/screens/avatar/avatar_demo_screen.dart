import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/common_app_bar_actions.dart';
import '../../utils/theme_constants.dart';

class AvatarDemoScreen extends StatelessWidget {
  const AvatarDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Customization Demo'),
        backgroundColor: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        actions: const [
          CommonAppBarActions(showLogout: true),
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
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.05),
                    AppColors.background,
                  ],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and description
                Text(
                  'Enhanced Avatar System',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onBackground
                        : AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Experience Meta-inspired 3D avatar customization with modern Flutter UI. Customize appearance, clothing, and more with real-time 3D preview.',
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),

                // Section: Current Avatar
                _buildSectionTitle('Current Avatar', themeProvider),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      UserAvatar(
                        displayName: authProvider.displayName,
                        imageUrl: authProvider.photoUrl,
                        radius: 60,
                        showCustomization: true,
                        onTap: () {
                          Navigator.pushNamed(context, '/avatar-customization');
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to Customize',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Section: Features
                _buildSectionTitle('Features', themeProvider),
                const SizedBox(height: 16),
                _buildFeatureGrid(context, themeProvider),

                const SizedBox(height: 32),

                // Section: How to Use
                _buildSectionTitle('How to Use', themeProvider),
                const SizedBox(height: 16),
                _buildHowToUse(context, themeProvider),

                const SizedBox(height: 32),

                // Section: Avatar Showcase
                _buildSectionTitle('Avatar Showcase', themeProvider),
                const SizedBox(height: 16),
                _buildAvatarShowcase(context, themeProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeProvider themeProvider) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: themeProvider.isDarkMode
            ? DarkAppColors.onBackground
            : AppColors.onBackground,
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, ThemeProvider themeProvider) {
    final features = [
      {
        'icon': Icons.palette,
        'title': 'Appearance',
        'description':
            'Customize skin tone, hair color, eye color, and hair style',
      },
      {
        'icon': Icons.checkroom,
        'title': 'Clothing',
        'description': 'Choose from various tops, bottoms, and shoes',
      },
      {
        'icon': Icons.threed_rotation,
        'title': '3D Preview',
        'description': 'Real-time 3D model rendering with flutter_cube',
      },
      {
        'icon': Icons.touch_app,
        'title': 'Interactive',
        'description': 'Rotate, zoom, and pan the 3D avatar',
      },
      {
        'icon': Icons.save,
        'title': 'Persistent',
        'description': 'Save customizations to Firebase',
      },
      {
        'icon': Icons.accessibility,
        'title': 'Accessible',
        'description': 'Responsive design for all screen sizes',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                feature['icon'] as IconData,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                feature['title'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onBackground
                      : AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                feature['description'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHowToUse(BuildContext context, ThemeProvider themeProvider) {
    final steps = [
      {
        'step': '1',
        'title': 'Access Customization',
        'description':
            'Tap on your avatar in the demo or navigate to the customization screen.',
      },
      {
        'step': '2',
        'title': 'Choose Category',
        'description': 'Select from Appearance, Clothing, or Accessories tabs.',
      },
      {
        'step': '3',
        'title': 'Customize',
        'description':
            'Pick colors, styles, and clothing options from the available selections.',
      },
      {
        'step': '4',
        'title': '3D Preview',
        'description': 'View your changes in real-time on the 3D avatar model.',
      },
      {
        'step': '5',
        'title': 'Save',
        'description': 'Save your customization to persist across sessions.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: steps.map((step) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      step['step'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onBackground
                              : AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAvatarShowcase(
      BuildContext context, ThemeProvider themeProvider) {
    // This would show different avatar variations
    // For now, we'll show placeholder content
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.threed_rotation,
              size: 48,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(height: 16),
            Text(
              'Avatar Showcase',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onBackground
                    : AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Different avatar variations will be displayed here',
              style: TextStyle(
                color:
                    themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
