import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/global_navigation_provider.dart';
import '../utils/theme_constants.dart';

/// Global Bottom Navigation Bar widget that can be used across all app screens
class GlobalBottomNavigationBar extends StatelessWidget {
  const GlobalBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GlobalNavigationProvider, ThemeProvider>(
      builder: (context, navProvider, themeProvider, child) {
        // Initialize navigation if not already done
        if (!navProvider.isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navProvider.initializeNavigation(context);
          });
          return const SizedBox.shrink();
        }

        return BottomNavigationBar(
          currentIndex: navProvider.currentIndex,
          onTap: (index) => navProvider.navigateToIndex(index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: themeProvider.isDarkMode
              ? DarkAppColors.surface
              : AppColors.surface,
          selectedItemColor: themeProvider.isDarkMode
              ? DarkAppColors.primary
              : AppColors.primary,
          unselectedItemColor: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.6)
              : AppColors.onSurface.withValues(alpha: 0.6),
          items: navProvider.navItems,
        );
      },
    );
  }
}
