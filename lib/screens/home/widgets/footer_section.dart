import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../utils/responsive_utils.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsiveFontSize(double baseSize) {
      if (screenWidth >= 1200) return baseSize * 1.1;
      if (screenWidth >= 900) return baseSize * 1.05;
      if (screenWidth >= 600) return baseSize * 0.95;
      return baseSize * 0.9;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 32.0),
      ),
      padding:
          EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
              : AppColors.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Logo and tagline
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.design_services,
                size: getResponsiveFontSize(32),
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
              ),
              SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI-Enabled Tailoring',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(18),
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface
                            : AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Perfect fit, every time',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(12),
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                            : AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),

          // Links
          Wrap(
            spacing: ResponsiveUtils.getResponsiveSpacing(context, 24.0),
            runSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
            children: [
              _FooterLinkColumn(
                title: 'Services',
                links: [
                  'Custom Tailoring',
                  'Alterations',
                  'Repairs',
                  'Consultation'
                ],
              ),
              _FooterLinkColumn(
                title: 'Support',
                links: ['Help Center', 'Contact Us', 'Size Guide', 'FAQ'],
              ),
              _FooterLinkColumn(
                title: 'Company',
                links: ['About Us', 'Careers', 'Press', 'Blog'],
              ),
              _FooterLinkColumn(
                title: 'Legal',
                links: ['Privacy Policy', 'Terms of Service', 'Cookie Policy'],
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),

          // Social links and app info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Social media icons
              Row(
                children: [
                  _SocialIcon(icon: Icons.facebook, onTap: () {}),
                  SizedBox(
                      width:
                          ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
                  _SocialIcon(
                      icon: Icons.camera_alt, onTap: () {}), // Instagram
                  SizedBox(
                      width:
                          ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
                  _SocialIcon(icon: Icons.chat, onTap: () {}), // WhatsApp
                ],
              ),

              // App version
              Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(10),
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                      : AppColors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),

          // Copyright
          Container(
            width: double.infinity,
            height: 1,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                : AppColors.onSurface.withValues(alpha: 0.1),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),

          Text(
            '© 2024 AI-Enabled Tailoring Shop. All rights reserved.',
            style: TextStyle(
              fontSize: getResponsiveFontSize(10),
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                  : AppColors.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FooterLinkColumn extends StatelessWidget {
  final String title;
  final List<String> links;

  const _FooterLinkColumn({
    required this.title,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsiveFontSize(double baseSize) {
      if (screenWidth >= 1200) return baseSize * 1.1;
      if (screenWidth >= 900) return baseSize * 1.05;
      if (screenWidth >= 600) return baseSize * 0.95;
      return baseSize * 0.9;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: getResponsiveFontSize(14),
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
        ...links.map((link) => Padding(
              padding: EdgeInsets.only(
                  bottom: ResponsiveUtils.getResponsiveSpacing(context, 4.0)),
              child: InkWell(
                onTap: () {
                  // Handle link tap
                },
                child: Text(
                  link,
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(12),
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                        : AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? DarkAppColors.background
              : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                : AppColors.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.7)
              : AppColors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
