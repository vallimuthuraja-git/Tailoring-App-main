import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_constants.dart';

/// AutoThemeApp - Automatically applies themes to all child widgets
/// Similar to CSS, any new component will automatically inherit the theme
class AutoThemeApp extends StatelessWidget {
  final Widget child;
  final ThemeProvider? themeProvider;

  const AutoThemeApp({
    super.key,
    required this.child,
    this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = this.themeProvider ?? Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.currentThemeData,
      themeMode: themeProvider.currentTheme,
      home: Theme(
        data: themeProvider.currentThemeData,
        child: Builder(
          builder: (context) => DefaultTextStyle(
            style: TextStyle(
              color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
            ),
            child: Container(
              color: themeProvider.isDarkMode ? DarkAppColors.background : AppColors.background,
              child: child,
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// AutoThemeWrapper - Wraps any widget to automatically apply theme
class AutoThemeWrapper extends StatelessWidget {
  final Widget child;

  const AutoThemeWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Theme(
      data: themeProvider.currentThemeData,
      child: DefaultTextStyle(
        style: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
        ),
        child: Container(
          color: themeProvider.isDarkMode ? DarkAppColors.background : AppColors.background,
          child: child,
        ),
      ),
    );
  }
}

/// AutoThemeBuilder - Automatically rebuilds when theme changes
class AutoThemeBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ThemeProvider themeProvider) builder;

  const AutoThemeBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Theme(
        data: themeProvider.currentThemeData,
        child: builder(context, themeProvider),
      ),
    );
  }
}

/// Extension methods for automatic theme application
extension AutoThemeExtension on Widget {
  /// Automatically applies current theme to this widget
  Widget withAutoTheme() {
    return AutoThemeWrapper(child: this);
  }

  /// Applies theme with custom background
  Widget withThemeBackground({
    Color? lightBackground,
    Color? darkBackground,
    bool useGlassEffect = false,
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final backgroundColor = themeProvider.isDarkMode
            ? (darkBackground ?? DarkAppColors.background)
            : (lightBackground ?? AppColors.background);

        Widget themedWidget = Container(
          color: backgroundColor,
          child: Theme(
            data: themeProvider.currentThemeData,
            child: DefaultTextStyle(
              style: TextStyle(
                color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
              ),
              child: this,
            ),
          ),
        );

        if (useGlassEffect && themeProvider.isGlassyMode) {
          themedWidget = Container(
            decoration: GlassMorphism.cardGlassDecoration(
              isDark: themeProvider.isDarkMode,
            ),
            child: themedWidget,
          );
        }

        return themedWidget;
      },
    );
  }
}

/// Pre-themed common widgets
class AutoThemeScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;

  const AutoThemeScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Scaffold(
        backgroundColor: backgroundColor ?? (themeProvider.isDarkMode ? DarkAppColors.background : AppColors.background),
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
    );
  }
}

class AutoThemeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Widget? leading;

  const AutoThemeAppBar({
    super.key,
    this.title,
    this.actions,
    this.centerTitle = true,
    this.elevation = 0,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => AppBar(
        title: title,
        actions: actions,
        centerTitle: centerTitle,
        elevation: elevation,
        leading: leading,
        backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}