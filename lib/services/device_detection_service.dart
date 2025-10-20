import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:device_info_plus/device_info_plus.dart'; // TODO: Re-enable when dependency is resolved

/// Device detection service for cross-platform app functionality
/// Currently uses Platform and MediaQuery for basic detection
/// Future: Re-enable device_info_plus for detailed hardware information

class DeviceInfo {
  final String platform;
  final String model;
  final String? osVersion;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool isWeb;
  final Size? screenSize;
  final double? screenDensity;
  final Brightness? systemBrightness;

  const DeviceInfo({
    required this.platform,
    required this.model,
    this.osVersion,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isWeb,
    this.screenSize,
    this.screenDensity,
    this.systemBrightness,
  });

  bool get isIOS => platform == 'ios';
  bool get isAndroid => platform == 'android';
  bool get isWindows => platform == 'windows';
  bool get isMacOS => platform == 'macos';
  bool get isLinux => platform == 'linux';
  bool get isFuchsia => platform == 'fuchsia';

  // Determine if device prefers dark mode based on multiple factors
  bool get prefersDarkMode {
    // Check system brightness first
    if (systemBrightness == Brightness.dark) {
      return true;
    }

    // Platform-specific preferences
    if (isIOS || isMacOS) {
      // Apple devices often work well with system themes
      return systemBrightness == Brightness.dark;
    }

    // Android devices - consider device type
    if (isAndroid) {
      // Mobile devices often benefit from dark mode for battery
      if (isMobile) {
        // Check if it's a modern device that supports dark mode well
        return true; // Default to dark for modern Android mobiles
      }
      // Tablets and foldables might prefer light mode
      return false;
    }

    // Desktop platforms
    if (isDesktop) {
      // Windows often has system theme detection
      if (isWindows) {
        return systemBrightness == Brightness.dark;
      }
      // Linux and other desktops default to light
      return false;
    }

    // Web platforms - check system preference
    if (isWeb) {
      return systemBrightness == Brightness.dark;
    }

    return false;
  }

  // Get recommended theme mode for this device
  ThemeMode get recommendedThemeMode {
    if (prefersDarkMode) {
      return ThemeMode.dark;
    }
    return ThemeMode.light;
  }

  // Check if device supports advanced features like glassmorphism
  bool get supportsAdvancedFeatures {
    // Modern iOS devices support glassmorphism well
    if (isIOS && osVersion != null) {
      final version = double.tryParse(osVersion!.split('.').first) ?? 0;
      return version >= 13; // iOS 13+ supports glassmorphism
    }

    // Modern Android devices with Material You
    if (isAndroid && osVersion != null) {
      final version = double.tryParse(osVersion!.split('.').first) ?? 0;
      return version >= 12; // Android 12+ supports Material You
    }

    // Modern desktop platforms
    if (isDesktop) {
      return true; // Most modern desktops support advanced features
    }

    // Web platforms with modern browsers
    if (isWeb) {
      return true; // Modern web browsers support CSS features
    }

    return false;
  }
}

class DeviceDetectionService {
  static final DeviceDetectionService _instance =
      DeviceDetectionService._internal();
  static DeviceDetectionService get instance => _instance;

  DeviceDetectionService._internal();

  // final DeviceInfoPlugin? deviceInfo = DeviceInfoPlugin(); // TODO: Re-enable when dependency is resolved
  final dynamic deviceInfo = null;

  // Platform-independent method to detect system theme preference
  Future<Brightness?> _getSystemBrightness() async {
    // For web and other platforms, rely on MediaQuery brightness
    // This is handled in getDeviceInfo method using MediaQuery.of(context)
    return null;
  }

  // Setup system theme change listener (simplified for cross-platform)
  void setupThemeListener(Function(Brightness) onThemeChanged) {
    // Platform-independent theme detection is handled through MediaQuery
    // in Flutter, which automatically responds to system theme changes
    // No additional setup needed as Flutter handles this automatically
  }

  Future<DeviceInfo> getDeviceInfo(BuildContext context) async {
    try {
      final mediaQuery = MediaQuery.of(context);
      final screenSize = mediaQuery.size;
      Brightness brightness = mediaQuery.platformBrightness;

      if (kIsWeb) {
        // Web platform detection with system theme detection
        brightness = await _getSystemBrightness() ?? brightness;
        return DeviceInfo(
          platform: 'web',
          model: 'Web Browser',
          osVersion: 'Web',
          isMobile: false,
          isTablet: false,
          isDesktop: true,
          isWeb: true,
          screenSize: screenSize,
          systemBrightness: brightness,
        );
      }

      if (Platform.isIOS) {
        // Enhanced fallback detection for iOS
        final isTablet = screenSize.shortestSide >= 600;

        return DeviceInfo(
          platform: 'ios',
          model: isTablet ? 'iPad' : 'iPhone',
          osVersion: 'iOS ${Platform.operatingSystemVersion}',
          isMobile: !isTablet,
          isTablet: isTablet,
          isDesktop: false,
          isWeb: false,
          screenSize: screenSize,
          systemBrightness: brightness,
        );
      }

      if (Platform.isAndroid) {
        // Enhanced fallback detection for Android
        final isTablet = screenSize.shortestSide >= 600;

        return DeviceInfo(
          platform: 'android',
          model: isTablet ? 'Android Tablet' : 'Android Phone',
          osVersion: 'Android ${Platform.operatingSystemVersion}',
          isMobile: !isTablet,
          isTablet: isTablet,
          isDesktop: false,
          isWeb: false,
          screenSize: screenSize,
          screenDensity: mediaQuery.devicePixelRatio,
          systemBrightness: brightness,
        );
      }

      if (Platform.isWindows) {
        return DeviceInfo(
          platform: 'windows',
          model: 'Windows PC',
          osVersion: 'Windows ${Platform.operatingSystemVersion}',
          isMobile: false,
          isTablet: false,
          isDesktop: true,
          isWeb: false,
          screenSize: screenSize,
          systemBrightness: brightness,
        );
      }

      if (Platform.isMacOS) {
        return DeviceInfo(
          platform: 'macos',
          model: 'Mac',
          osVersion: 'macOS ${Platform.operatingSystemVersion}',
          isMobile: false,
          isTablet: false,
          isDesktop: true,
          isWeb: false,
          screenSize: screenSize,
          systemBrightness: brightness,
        );
      }

      if (Platform.isLinux) {
        return DeviceInfo(
          platform: 'linux',
          model: 'Linux System',
          osVersion: 'Linux ${Platform.operatingSystemVersion}',
          isMobile: false,
          isTablet: false,
          isDesktop: true,
          isWeb: false,
          screenSize: screenSize,
          systemBrightness: brightness,
        );
      }

      // Fallback for other platforms
      return DeviceInfo(
        platform: 'unknown',
        model: 'Unknown Device',
        isMobile: false,
        isTablet: false,
        isDesktop: true,
        isWeb: false,
        screenSize: screenSize,
        systemBrightness: brightness,
      );
    } catch (e) {
      // Fallback in case of errors
      final mediaQuery = MediaQuery.of(context);
      return DeviceInfo(
        platform: 'unknown',
        model: 'Unknown Device',
        isMobile: false,
        isTablet: false,
        isDesktop: true,
        isWeb: kIsWeb,
        screenSize: mediaQuery.size,
        systemBrightness: mediaQuery.platformBrightness,
      );
    }
  }

  // Get theme recommendation based on device info
  ThemeRecommendation getThemeRecommendation(DeviceInfo deviceInfo) {
    final prefersDark = deviceInfo.prefersDarkMode;
    final supportsAdvanced = deviceInfo.supportsAdvancedFeatures;

    return ThemeRecommendation(
      themeMode: prefersDark ? ThemeMode.dark : ThemeMode.light,
      useGlassyMode: supportsAdvanced && deviceInfo.isMobile,
      reasoning: _getRecommendationReasoning(
          deviceInfo, prefersDark, supportsAdvanced),
    );
  }

  String _getRecommendationReasoning(
      DeviceInfo deviceInfo, bool prefersDark, bool supportsAdvanced) {
    final reasons = <String>[];

    if (prefersDark) {
      reasons.add('System prefers dark mode');
      if (deviceInfo.isMobile) {
        reasons.add('Better battery life on mobile devices');
      }
    } else {
      reasons.add('System prefers light mode');
    }

    if (supportsAdvanced && deviceInfo.isMobile) {
      reasons.add('Device supports advanced visual effects');
    }

    return reasons.join(', ');
  }
}

class ThemeRecommendation {
  final ThemeMode themeMode;
  final bool useGlassyMode;
  final String reasoning;

  const ThemeRecommendation({
    required this.themeMode,
    required this.useGlassyMode,
    required this.reasoning,
  });

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;
}

