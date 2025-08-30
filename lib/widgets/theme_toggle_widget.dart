import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_constants.dart';

class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'light':
                themeProvider.switchToLightMode();
                break;
              case 'dark':
                themeProvider.switchToDarkMode();
                break;
              case 'glassy':
                themeProvider.switchToGlassyMode();
                break;
              case 'system':
                themeProvider.followSystemTheme();
                break;
              case 'toggle':
                themeProvider.toggleTheme();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'light',
              child: ListTile(
                leading: Icon(
                  Icons.light_mode,
                  color: themeProvider.isLightMode && !themeProvider.isGlassyMode
                      ? AppColors.primary
                      : null,
                ),
                title: const Text('Light Mode'),
                trailing: themeProvider.isLightMode && !themeProvider.isGlassyMode
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
              ),
            ),
            PopupMenuItem(
              value: 'dark',
              child: ListTile(
                leading: Icon(
                  Icons.dark_mode,
                  color: themeProvider.isDarkMode && !themeProvider.isGlassyMode
                      ? DarkAppColors.primary
                      : null,
                ),
                title: const Text('Dark Mode'),
                trailing: themeProvider.isDarkMode && !themeProvider.isGlassyMode
                    ? const Icon(Icons.check, color: DarkAppColors.primary)
                    : null,
              ),
            ),
            PopupMenuItem(
              value: 'glassy',
              child: ListTile(
                leading: Icon(
                  Icons.blur_on,
                  color: themeProvider.isGlassyMode
                      ? (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary)
                      : null,
                ),
                title: Text('Glassy Mode (${themeProvider.isDarkMode ? 'Dark' : 'Light'})'),
                trailing: themeProvider.isGlassyMode
                    ? Icon(Icons.check, color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary)
                    : null,
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'system',
              child: ListTile(
                leading: Icon(
                  Icons.smartphone,
                  color: themeProvider.currentTheme == ThemeMode.system
                      ? (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary)
                      : null,
                ),
                title: const Text('Follow System'),
                subtitle: const Text('Automatically match device theme'),
                trailing: themeProvider.currentTheme == ThemeMode.system
                    ? Icon(Icons.check, color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary)
                    : null,
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'toggle',
              child: ListTile(
                leading: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                title: Text('Quick ${themeProvider.isDarkMode ? 'Light' : 'Dark'} Toggle'),
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: GlassMorphism.glassDecoration(
              isDark: themeProvider.isDarkMode,
              blur: 15,
              opacity: 0.1,
            ),
            child: Icon(
              themeProvider.currentThemeIcon,
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
          ),
        );
      },
    );
  }
}

// Alternative: Floating Action Button for theme toggle
class ThemeToggleFAB extends StatelessWidget {
  const ThemeToggleFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return FloatingActionButton.extended(
          onPressed: () => _showThemeBottomSheet(context, themeProvider),
          backgroundColor: themeProvider.isGlassyMode
              ? Colors.transparent
              : (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary),
          elevation: themeProvider.isGlassyMode ? 0 : 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            themeProvider.currentThemeIcon,
            color: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
          ),
          label: Text(
            themeProvider.currentThemeName,
            style: TextStyle(
              color: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
            ),
          ),
        );
      },
    );
  }

  void _showThemeBottomSheet(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: GlassMorphism.cardGlassDecoration(
          isDark: themeProvider.isDarkMode,
        ),
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                context,
                themeProvider,
                'Light Mode',
                Icons.light_mode,
                AppColors.primary,
                'light',
                themeProvider.isLightMode && !themeProvider.isGlassyMode,
              ),
              _buildThemeOption(
                context,
                themeProvider,
                'Dark Mode',
                Icons.dark_mode,
                DarkAppColors.primary,
                'dark',
                themeProvider.isDarkMode && !themeProvider.isGlassyMode,
              ),
              _buildThemeOption(
                context,
                themeProvider,
                'Glassy Mode',
                Icons.blur_on,
                themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                'glassy',
                themeProvider.isGlassyMode,
              ),
              _buildThemeOption(
                context,
                themeProvider,
                'Follow System',
                Icons.smartphone,
                themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                'system',
                themeProvider.currentTheme == ThemeMode.system,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    String title,
    IconData icon,
    Color color,
    String value,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: GlassMorphism.buttonGlassDecoration(
        isDark: themeProvider.isDarkMode,
        opacity: isSelected ? 0.3 : 0.1,
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: color)
            : Icon(
                Icons.circle_outlined,
                color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
              ),
        onTap: () {
          Navigator.pop(context);
          switch (value) {
            case 'light':
              themeProvider.switchToLightMode();
              break;
            case 'dark':
              themeProvider.switchToDarkMode();
              break;
            case 'glassy':
              themeProvider.switchToGlassyMode();
              break;
            case 'system':
              themeProvider.followSystemTheme();
              break;
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// Simple theme toggle button (compact version)
class SimpleThemeToggle extends StatelessWidget {
  const SimpleThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          onPressed: () => themeProvider.toggleTheme(),
          icon: Icon(
            themeProvider.currentThemeIcon,
            color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
          ),
          tooltip: 'Toggle ${themeProvider.isDarkMode ? 'Light' : 'Dark'} Mode',
        );
      },
    );
  }
}