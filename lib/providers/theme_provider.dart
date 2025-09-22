import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme_constants.dart';
import '../services/device_detection_service.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  static const String _isDarkKey = 'is_dark_mode';
  static const String _autoDetectKey = 'auto_detect_enabled';

  ThemeMode _currentTheme = ThemeMode.light;
  bool _isDarkMode = false;
  bool _isGlassyMode = false;
  bool _isAutoDetectEnabled = true; // Enable auto-detection by default
  DeviceInfo? _deviceInfo;
  SharedPreferences? _prefs; // Cache SharedPreferences instance

  ThemeMode get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  bool get isGlassyMode => _isGlassyMode;
  bool get isLightMode => !_isDarkMode;
  bool get isAutoDetectEnabled => _isAutoDetectEnabled;
  DeviceInfo? get deviceInfo => _deviceInfo;

  ThemeData get currentThemeData {
    if (_isGlassyMode) {
      return AppThemes.glassyTheme(_isDarkMode);
    }
    return _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;
  }

  // Optimized SharedPreferences access with caching
  Future<SharedPreferences> get _getPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Helper method to update theme state and notify listeners
  void _updateThemeState({
    required ThemeMode themeMode,
    required bool isDarkMode,
    required bool isGlassyMode,
    bool saveToPrefs = true,
  }) {
    _currentTheme = themeMode;
    _isDarkMode = isDarkMode;
    _isGlassyMode = isGlassyMode;

    if (saveToPrefs) {
      _saveThemePreference();
    }

    notifyListeners();
  }

  // Initialize theme from saved preferences or system
  Future<void> initializeTheme() async {
    final prefs = await _getPrefs;
    final savedTheme = prefs.getString(_themeKey);
    final savedIsDark = prefs.getBool(_isDarkKey) ?? false;
    final autoDetectEnabled = prefs.getBool(_autoDetectKey) ?? true;

    _isAutoDetectEnabled = autoDetectEnabled;

    if (savedTheme == null) {
      // New user - use system theme by default
      _updateThemeState(
        themeMode: ThemeMode.system,
        isDarkMode: false,
        isGlassyMode: false,
        saveToPrefs: false,
      );
    } else {
      // Load saved preferences
      _loadSavedTheme(savedTheme, savedIsDark);
    }
  }

  // Helper method to load saved theme configuration
  void _loadSavedTheme(String themeString, bool isDark) {
    final themeConfig = _getThemeConfig(themeString, isDark);
    _currentTheme = themeConfig.themeMode;
    _isDarkMode = themeConfig.isDarkMode;
    _isGlassyMode = themeConfig.isGlassyMode;
    notifyListeners();
  }

  // Helper method to get theme configuration from string
  ({ThemeMode themeMode, bool isDarkMode, bool isGlassyMode}) _getThemeConfig(
      String themeString, bool isDark) {
    switch (themeString) {
      case 'dark':
        return (
          themeMode: ThemeMode.dark,
          isDarkMode: true,
          isGlassyMode: false
        );
      case 'glassy':
        return (
          themeMode: ThemeMode.system,
          isDarkMode: isDark,
          isGlassyMode: true
        );
      case 'system':
        return (
          themeMode: ThemeMode.system,
          isDarkMode: isDark,
          isGlassyMode: false
        );
      default:
        return (
          themeMode: ThemeMode.light,
          isDarkMode: false,
          isGlassyMode: false
        );
    }
  }

  // Initialize auto theme detection with device info
  Future<void> initializeAutoTheme(BuildContext context) async {
    if (!_isAutoDetectEnabled) return;

    try {
      // Store device info for potential future use
      final deviceInfo =
          await DeviceDetectionService.instance.getDeviceInfo(context);
      _deviceInfo = deviceInfo;

      // For web browsers, use direct brightness detection instead of ThemeMode.system
      if (deviceInfo.isWeb && deviceInfo.systemBrightness != null) {
        // Use direct theme mode based on detected system brightness
        final isDark = deviceInfo.systemBrightness == Brightness.dark;
        _currentTheme = isDark ? ThemeMode.dark : ThemeMode.light;
        _isDarkMode = isDark;
      } else {
        // For non-web platforms, use system theme mode
        _currentTheme = ThemeMode.system;
        _isDarkMode = false; // Let Flutter determine based on system
      }

      _isGlassyMode = false;
      await _saveThemePreference();
      notifyListeners();
    } catch (e) {
      // If device detection fails, use system theme as fallback
      _currentTheme = ThemeMode.system;
      _isDarkMode = false;
      _isGlassyMode = false;
      notifyListeners();
    }
  }

  // Enable or disable auto theme detection
  Future<void> setAutoDetectEnabled(bool enabled) async {
    _isAutoDetectEnabled = enabled;
    final prefs = await _getPrefs;
    await prefs.setBool(_autoDetectKey, enabled);

    if (enabled) {
      // When enabling auto-detection, switch to system theme following
      _updateThemeState(
        themeMode: ThemeMode.system,
        isDarkMode: false, // Let system determine
        isGlassyMode: false,
      );
    }
  }

  // Force refresh system theme (useful for testing or manual updates)
  Future<void> refreshSystemTheme() async {
    if (_isAutoDetectEnabled) {
      _updateThemeState(
        themeMode: ThemeMode.system,
        isDarkMode: false, // Reset to let system determine
        isGlassyMode: false,
      );
    }
  }

  // Setup theme change listener
  void setupThemeListener(BuildContext context) {
    DeviceDetectionService.instance.setupThemeListener((Brightness brightness) {
      if (_isAutoDetectEnabled && _deviceInfo?.isWeb == true) {
        final isDark = brightness == Brightness.dark;
        if (_isDarkMode != isDark) {
          _isDarkMode = isDark;
          _currentTheme = isDark ? ThemeMode.dark : ThemeMode.light;
          notifyListeners();
        }
      }
    });
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _updateThemeState(
      themeMode: _isDarkMode ? ThemeMode.light : ThemeMode.dark,
      isDarkMode: !_isDarkMode,
      isGlassyMode: false,
    );
  }

  // Enable glass morphism mode
  Future<void> enableGlassyMode() async {
    _updateThemeState(
      themeMode: ThemeMode.system,
      isDarkMode: _isDarkMode,
      isGlassyMode: true,
    );
  }

  // Switch to light mode
  Future<void> switchToLightMode() async {
    _updateThemeState(
      themeMode: ThemeMode.light,
      isDarkMode: false,
      isGlassyMode: false,
    );
  }

  // Switch to dark mode
  Future<void> switchToDarkMode() async {
    _updateThemeState(
      themeMode: ThemeMode.dark,
      isDarkMode: true,
      isGlassyMode: false,
    );
  }

  // Switch to glass morphism mode
  Future<void> switchToGlassyMode() async {
    _updateThemeState(
      themeMode: ThemeMode.system,
      isDarkMode: _isDarkMode,
      isGlassyMode: true,
    );
  }

  // Follow system theme (default behavior)
  Future<void> followSystemTheme() async {
    _updateThemeState(
      themeMode: ThemeMode.system,
      isDarkMode: _isDarkMode,
      isGlassyMode: false,
    );
  }

  // Optimized theme preference saving
  Future<void> _saveThemePreference() async {
    final prefs = await _getPrefs;

    final themeString = _getThemeString();
    await Future.wait([
      prefs.setString(_themeKey, themeString),
      prefs.setBool(_isDarkKey, _isDarkMode),
      prefs.setBool(_autoDetectKey, _isAutoDetectEnabled),
    ]);
  }

  // Helper method to determine theme string
  String _getThemeString() {
    if (_isGlassyMode) return 'glassy';
    if (_currentTheme == ThemeMode.system) return 'system';
    return _isDarkMode ? 'dark' : 'light';
  }

  // Get theme display name
  String get currentThemeName {
    if (_isGlassyMode) {
      return 'Glassy (${_isDarkMode ? 'Dark' : 'Light'})';
    }
    return _isDarkMode ? 'Dark Mode' : 'Light Mode';
  }

  // Get theme icon
  IconData get currentThemeIcon {
    if (_isGlassyMode) {
      return Icons.blur_on;
    }
    return _isDarkMode ? Icons.dark_mode : Icons.light_mode;
  }
}
