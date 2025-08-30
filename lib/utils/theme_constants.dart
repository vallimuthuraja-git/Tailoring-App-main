import 'package:flutter/material.dart';

// Color Opacity Extensions for Theme-Level Consistency
extension ColorOpacityExtension on Color {
  /// Creates a color with the specified alpha value using withValues() for precision
  Color withThemeOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0, 'Opacity must be between 0.0 and 1.0');
    return withValues(alpha: opacity);
  }

  // Predefined opacity levels for consistent theming
  Color get o10 => withThemeOpacity(0.1);
  Color get o15 => withThemeOpacity(0.15);
  Color get o20 => withThemeOpacity(0.2);
  Color get o30 => withThemeOpacity(0.3);
  Color get o40 => withThemeOpacity(0.4);
  Color get o50 => withThemeOpacity(0.5);
  Color get o60 => withThemeOpacity(0.6);
  Color get o70 => withThemeOpacity(0.7);
  Color get o80 => withThemeOpacity(0.8);
  Color get o90 => withThemeOpacity(0.9);

  // Semantic opacity levels for common use cases
  Color get subtle => withThemeOpacity(0.04);      // Very subtle backgrounds
  Color get muted => withThemeOpacity(0.08);       // Muted backgrounds
  Color get soft => withThemeOpacity(0.12);        // Soft borders/disabled states
  Color get medium => withThemeOpacity(0.16);      // Medium emphasis text
  Color get high => withThemeOpacity(0.24);        // High emphasis elements
  Color get strong => withThemeOpacity(0.32);      // Strong emphasis elements
  Color get intense => withThemeOpacity(0.48);     // Intense elements
  Color get vibrant => withThemeOpacity(0.64);     // Vibrant elements
  Color get bold => withThemeOpacity(0.80);        // Bold elements
  Color get vivid => withThemeOpacity(0.96);       // Vivid elements
}

// Theme Opacity Utilities for consistent application across the app
class ThemeOpacity {
  // Glass morphism opacities
  static const double glassBackground = 0.1;
  static const double glassCard = 0.15;
  static const double glassButton = 0.2;
  static const double glassBorder = 0.2;

  // Text opacities
  static const double textPrimary = 1.0;
  static const double textSecondary = 0.7;
  static const double textTertiary = 0.5;
  static const double textDisabled = 0.4;

  // Interactive element opacities
  static const double hover = 0.08;
  static const double focus = 0.12;
  static const double pressed = 0.16;
  static const double selected = 0.2;

  // Utility method to apply theme-aware opacity
  static Color apply({
    required Color color,
    required double opacity,
    bool isDark = false,
  }) {
    // Adjust opacity based on theme for better contrast
    final adjustedOpacity = isDark ? opacity * 1.2 : opacity;
    return color.withThemeOpacity(adjustedOpacity.clamp(0.0, 1.0));
  }
}


class AppColors {
  // Light Theme Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryVariant = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF10B981);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFEF4444);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF1F2937);
  static const Color onSurface = Color(0xFF1F2937);
  static const Color onError = Colors.white;
  static const Color glassBorder = Color(0xFFCBD5E1);

  // Light Theme Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class DarkAppColors {
  // Dark Theme Colors
  static const Color primary = Color(0xFF818CF8);
  static const Color primaryVariant = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF34D399);
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color error = Color(0xFFF87171);
  static const Color onPrimary = Color(0xFF0F172A);
  static const Color onSecondary = Color(0xFF0F172A);
  static const Color onBackground = Color(0xFFF1F5F9);
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color onError = Color(0xFF0F172A);
  static const Color glassDarkBorder = Color(0xFF475569);

  // Dark Theme Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF818CF8), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class GlassyAppColors {
  // Glassy Theme Colors (works with both light and dark)
  static const Color glassBackground = Colors.white;
  static const Color glassDarkBackground = Color(0xFF1E293B);
  static const Color glassBorder = Color(0xFFCBD5E1);
  static const Color glassDarkBorder = Color(0xFF475569);
  static const Color glassShadow = Color(0x1A000000);
  static const Color glassDarkShadow = Color(0x4D000000);
}

// Glass Morphism Effects
class GlassMorphism {
  static BoxDecoration glassDecoration({
    required bool isDark,
    double blur = 20,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: isDark
          ? GlassyAppColors.glassDarkBackground.withThemeOpacity(opacity)
          : GlassyAppColors.glassBackground.withThemeOpacity(opacity),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark
            ? GlassyAppColors.glassDarkBorder.o20
            : GlassyAppColors.glassBorder.o20,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? GlassyAppColors.glassDarkShadow
              : GlassyAppColors.glassShadow,
          blurRadius: blur,
          spreadRadius: 0,
        ),
      ],
    );
  }

  static BoxDecoration cardGlassDecoration({
    required bool isDark,
    double blur = 15,
    double opacity = 0.15,
  }) {
    return BoxDecoration(
      color: isDark
          ? GlassyAppColors.glassDarkBackground.withThemeOpacity(opacity)
          : GlassyAppColors.glassBackground.withThemeOpacity(opacity),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? GlassyAppColors.glassDarkBorder.o30
            : GlassyAppColors.glassBorder.o30,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? GlassyAppColors.glassDarkShadow
              : GlassyAppColors.glassShadow,
          blurRadius: blur,
          spreadRadius: 0,
        ),
      ],
    );
  }

  static BoxDecoration buttonGlassDecoration({
    required bool isDark,
    double blur = 10,
    double opacity = 0.2,
  }) {
    return BoxDecoration(
      color: isDark
          ? GlassyAppColors.glassDarkBackground.withThemeOpacity(opacity)
          : GlassyAppColors.glassBackground.withThemeOpacity(opacity),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? GlassyAppColors.glassDarkBorder.o40
            : GlassyAppColors.glassBorder.o40,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? GlassyAppColors.glassDarkShadow
              : GlassyAppColors.glassShadow,
          blurRadius: blur,
          spreadRadius: 0,
        ),
      ],
    );
  }
}

// Theme Data
class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryVariant,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.onSurface,
      onError: AppColors.onError,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.onSurface),
      titleTextStyle: TextStyle(
        color: AppColors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: AppColors.background,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: TextStyle(color: AppColors.onSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      modalBackgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.onSurface.o60,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      deleteIconColor: AppColors.primary,
      labelStyle: const TextStyle(color: AppColors.onSurface),
      secondaryLabelStyle: const TextStyle(color: AppColors.onPrimary),
      secondarySelectedColor: AppColors.primary,
      selectedColor: AppColors.primary.o20,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.onSurface.o10,
      thickness: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.onSurface.o50;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.o30;
        }
        return AppColors.onSurface.o10;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.onPrimary),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.onSurface.o60;
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: DarkAppColors.primary,
      primaryContainer: DarkAppColors.primaryVariant,
      secondary: DarkAppColors.secondary,
      surface: DarkAppColors.surface,
      error: DarkAppColors.error,
      onPrimary: DarkAppColors.onPrimary,
      onSecondary: DarkAppColors.onSecondary,
      onSurface: DarkAppColors.onSurface,
      onError: DarkAppColors.onError,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: DarkAppColors.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: DarkAppColors.onSurface),
      titleTextStyle: TextStyle(
        color: DarkAppColors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: DarkAppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkAppColors.primary,
        foregroundColor: DarkAppColors.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: DarkAppColors.glassDarkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: DarkAppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: DarkAppColors.background,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: DarkAppColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: DarkAppColors.surface,
      contentTextStyle: TextStyle(color: DarkAppColors.onSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DarkAppColors.surface,
      modalBackgroundColor: DarkAppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: DarkAppColors.primary,
      unselectedLabelColor: DarkAppColors.onSurface.o60,
      indicatorColor: DarkAppColors.primary,
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: DarkAppColors.primary,
      foregroundColor: DarkAppColors.onPrimary,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: DarkAppColors.background,
      deleteIconColor: DarkAppColors.primary,
      labelStyle: const TextStyle(color: DarkAppColors.onSurface),
      secondaryLabelStyle: const TextStyle(color: DarkAppColors.onPrimary),
      secondarySelectedColor: DarkAppColors.primary,
      selectedColor: DarkAppColors.primary.o20,
    ),
    dividerTheme: DividerThemeData(
      color: DarkAppColors.onSurface.o10,
      thickness: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return DarkAppColors.primary;
        }
        return DarkAppColors.onSurface.o50;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return DarkAppColors.primary.o30;
        }
        return DarkAppColors.onSurface.o10;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return DarkAppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(DarkAppColors.onPrimary),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return DarkAppColors.primary;
        }
        return DarkAppColors.onSurface.o60;
      }),
    ),
  );

  static ThemeData glassyTheme(bool isDark) {
    final baseTheme = isDark ? darkTheme : lightTheme;
    return baseTheme.copyWith(
      cardTheme: baseTheme.cardTheme.copyWith(
        color: Colors.transparent,
        elevation: 0,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
