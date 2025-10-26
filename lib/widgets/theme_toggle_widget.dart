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
                  color:
                      themeProvider.isLightMode && !themeProvider.isGlassyMode
                          ? AppColors.primary
                          : null,
                ),
                title: const Text('Light Mode'),
                trailing:
                    themeProvider.isLightMode && !themeProvider.isGlassyMode
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
                trailing:
                    themeProvider.isDarkMode && !themeProvider.isGlassyMode
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
                      ? (themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary)
                      : null,
                ),
                title: Text(
                    'Glassy Mode (${themeProvider.isDarkMode ? 'Dark' : 'Light'})'),
                trailing: themeProvider.isGlassyMode
                    ? Icon(Icons.check,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary)
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
                      ? (themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary)
                      : null,
                ),
                title: const Text('Follow System'),
                subtitle: const Text('Automatically match device theme'),
                trailing: themeProvider.currentTheme == ThemeMode.system
                    ? Icon(Icons.check,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary)
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
                title: Text(
                    'Quick ${themeProvider.isDarkMode ? 'Light' : 'Dark'} Toggle'),
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
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
          ),
        );
      },
    );
  }
}
