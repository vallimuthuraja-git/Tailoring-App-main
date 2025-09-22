import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/auth_service.dart';
import '../../../utils/theme_constants.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/user_avatar.dart';

class HeroSection extends StatelessWidget {
  final UserModel? user;
  final bool isShopOwner;
  final VoidCallback onGetStarted;

  const HeroSection({
    super.key,
    required this.user,
    required this.isShopOwner,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final deviceType = ResponsiveUtils.getDeviceTypeFromContext(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsiveFontSize(double baseSize) {
      if (screenWidth >= 1200) return baseSize * 1.2;
      if (screenWidth >= 900) return baseSize * 1.1;
      if (screenWidth >= 600) return baseSize * 0.95;
      return baseSize * 0.9;
    }

    double getResponsiveHeight() {
      switch (deviceType) {
        case DeviceType.mobile:
          return 300;
        case DeviceType.tablet:
          return 350;
        case DeviceType.desktop:
          return 400;
      }
    }

    return Container(
      height: getResponsiveHeight(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeProvider.isDarkMode
              ? [
                  DarkAppColors.primary.withValues(alpha: 0.9),
                  DarkAppColors.primaryVariant.withValues(alpha: 0.8),
                  DarkAppColors.surface.withValues(alpha: 0.9),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.9),
                  AppColors.primaryVariant.withValues(alpha: 0.8),
                  AppColors.surface.withValues(alpha: 0.9),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/pattern.png'),
                    repeat: ImageRepeat.repeat,
                    scale: 2,
                  ),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
              vertical: ResponsiveUtils.getResponsiveSpacing(context, 40.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                Row(
                  children: [
                    UserAvatar(
                      displayName: user?.displayName ?? 'Guest',
                      imageUrl: user?.photoUrl,
                      radius: deviceType == DeviceType.mobile ? 24.0 : 32.0,
                    ),
                    SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                            context, 16.0)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: getResponsiveFontSize(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            user?.displayName ?? 'Guest User',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: getResponsiveFontSize(20),
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Main Content
                Text(
                  'Perfect Tailoring\nMade Simple',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getResponsiveFontSize(28),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                SizedBox(
                    height:
                        ResponsiveUtils.getResponsiveSpacing(context, 12.0)),

                Text(
                  isShopOwner
                      ? 'Manage your tailoring shop efficiently with our AI-powered platform. Track orders, manage inventory, and delight your customers.'
                      : 'Discover exceptional tailoring services tailored just for you. From custom suits to alterations, find the perfect fit.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: getResponsiveFontSize(16),
                    height: 1.4,
                  ),
                ),

                SizedBox(
                    height:
                        ResponsiveUtils.getResponsiveSpacing(context, 24.0)),

                // CTA Button
                ElevatedButton.icon(
                  onPressed: onGetStarted,
                  icon: Icon(
                    isShopOwner ? Icons.dashboard : Icons.shopping_bag,
                    size: getResponsiveFontSize(20),
                  ),
                  label: Text(
                    isShopOwner ? 'Manage Shop' : 'Explore Products',
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveUtils.getResponsiveSpacing(context, 24.0),
                      vertical:
                          ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                ),

                SizedBox(
                    height:
                        ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
              ],
            ),
          ),

          // Floating Elements
          Positioned(
            top: 40,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                isShopOwner ? Icons.business : Icons.star,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.trending_up,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
