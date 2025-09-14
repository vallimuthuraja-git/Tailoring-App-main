import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Enum representing different device types
enum DeviceType { mobile, tablet, desktop }

/// Breakpoints for responsive design
class ResponsiveBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 1024.0;
}

/// Utility class for responsive layout and design in Flutter
class ResponsiveUtils {
  /// Determines the device type based on screen width
  static DeviceType getDeviceType(double width) {
    if (width < ResponsiveBreakpoints.mobile) return DeviceType.mobile;
    if (width < ResponsiveBreakpoints.tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Gets device type from BuildContext
  static DeviceType getDeviceTypeFromContext(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size.width);
  }

  /// Builds a responsive layout using LayoutBuilder
  static Widget responsiveLayout({
    required Widget mobile,
    required Widget tablet,
    required Widget desktop,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final DeviceType device = getDeviceType(constraints.maxWidth);

        switch (device) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet;
          case DeviceType.desktop:
            return desktop;
        }
      },
    );
  }

  /// Returns responsive spacing based on device type
  static double responsiveSpacing(double baseSpacing, DeviceType device) {
    switch (device) {
      case DeviceType.mobile:
        return baseSpacing * 0.8;
      case DeviceType.tablet:
        return baseSpacing;
      case DeviceType.desktop:
        return baseSpacing * 1.2;
    }
  }

  /// Returns responsive EdgeInsets based on device type
  static EdgeInsets responsiveInsets(double basePadding, DeviceType device) {
    final spacing = responsiveSpacing(basePadding, device);
    return EdgeInsets.all(spacing);
  }

  /// Returns responsive EdgeInsets with symmetric values
  static EdgeInsets responsiveInsetsSymmetric({
    required double vertical,
    required double horizontal,
    required DeviceType device,
  }) {
    final v = responsiveSpacing(vertical, device);
    final h = responsiveSpacing(horizontal, device);
    return EdgeInsets.symmetric(vertical: v, horizontal: h);
  }

  /// Returns responsive EdgeInsets from only values
  static EdgeInsets responsiveInsetsOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
    required DeviceType device,
  }) {
    return EdgeInsets.only(
      left: responsiveSpacing(left, device),
      top: responsiveSpacing(top, device),
      right: responsiveSpacing(right, device),
      bottom: responsiveSpacing(bottom, device),
    );
  }

  /// Returns responsive font size based on device type
  static double responsiveFontSize(double baseFontSize, DeviceType device) {
    switch (device) {
      case DeviceType.mobile:
        return baseFontSize * 0.9;
      case DeviceType.tablet:
        return baseFontSize;
      case DeviceType.desktop:
        return baseFontSize * 1.1;
    }
  }

  /// Returns responsive TextStyle based on device type
  static TextStyle responsiveTextStyle(
    TextStyle baseStyle,
    DeviceType device,
  ) {
    final fontSize = responsiveFontSize(baseStyle.fontSize ?? 14.0, device);
    return baseStyle.copyWith(fontSize: fontSize);
  }

  /// Returns number of columns for responsive grid based on device type
  static int responsiveGridColumns(DeviceType device) {
    switch (device) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 4;
    }
  }

  /// Returns responsive SliverGridDelegate based on device type
  static SliverGridDelegate responsiveGridDelegate(DeviceType device) {
    final columns = responsiveGridColumns(device);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: responsiveSpacing(8.0, device),
      mainAxisSpacing: responsiveSpacing(8.0, device),
      childAspectRatio: device == DeviceType.mobile ? 0.8 : 1.0,
    );
  }

  /// Convenience function to get responsive spacing from BuildContext
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final DeviceType device = getDeviceTypeFromContext(context);
    return responsiveSpacing(baseSpacing, device);
  }

  /// Convenience function to get responsive insets from BuildContext
  static EdgeInsets getResponsiveInsets(
      BuildContext context, double basePadding) {
    final DeviceType device = getDeviceTypeFromContext(context);
    return responsiveInsets(basePadding, device);
  }

  /// Convenience function to get responsive insets symmetric from BuildContext
  static EdgeInsets getResponsiveInsetsSymmetric({
    required BuildContext context,
    required double vertical,
    required double horizontal,
  }) {
    final DeviceType device = getDeviceTypeFromContext(context);
    return responsiveInsetsSymmetric(
        vertical: vertical, horizontal: horizontal, device: device);
  }

  /// Convenience function to get responsive font size from BuildContext
  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    final DeviceType device = getDeviceTypeFromContext(context);
    return responsiveFontSize(baseFontSize, device);
  }

  /// Convenience function to get responsive TextStyle from BuildContext
  static TextStyle getResponsiveTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final DeviceType device = getDeviceTypeFromContext(context);
    return responsiveTextStyle(baseStyle, device);
  }

  /// Convenience function to get responsive grid columns from BuildContext
  static int getResponsiveGridColumns(BuildContext context) {
    final DeviceType device = getDeviceTypeFromContext(context);
    return responsiveGridColumns(device);
  }

  /// Convenience function to get responsive grid delegate from BuildContext
  static SliverGridDelegate getResponsiveGridDelegate(BuildContext context) {
    final DeviceType device = getDeviceTypeFromContext(context);
    return responsiveGridDelegate(device);
  }

  /// Checks if the current device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceTypeFromContext(context) == DeviceType.mobile;
  }

  /// Checks if the current device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceTypeFromContext(context) == DeviceType.tablet;
  }

  /// Checks if the current device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceTypeFromContext(context) == DeviceType.desktop;
  }

  /// Returns device type considering orientation (landscape vs portrait)
  static DeviceType getDeviceTypeWithOrientation(
    double width,
    Orientation orientation,
  ) {
    final adjustedWidth = orientation == Orientation.landscape && width < 900
        ? width * 1.5 // Adjust for landscape on smaller screens
        : width;
    return getDeviceType(adjustedWidth);
  }

  /// Advanced LayoutBuilder widget with orientation support
  static Widget responsiveLayoutWithOrientation({
    required Widget portraitMobile,
    required Widget landscapeMobile,
    required Widget portraitTablet,
    required Widget landscapeTablet,
    required Widget desktop,
  }) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final orientation = MediaQuery.of(context).orientation;
        final width = constraints.maxWidth;
        final device = getDeviceTypeWithOrientation(width, orientation);

        if (device == DeviceType.mobile) {
          return orientation == Orientation.portrait
              ? portraitMobile
              : landscapeMobile;
        } else if (device == DeviceType.tablet) {
          return orientation == Orientation.portrait
              ? portraitTablet
              : landscapeTablet;
        } else {
          return desktop;
        }
      },
    );
  }

  /// Cross-platform compatibility helpers
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isWindows => Platform.isWindows;
  static bool get isMacOS => Platform.isMacOS;
  static bool get isLinux => Platform.isLinux;

  /// Returns platform-specific spacing adjustments
  static double platformSpecificSpacing(double base, BuildContext context) {
    if (isWeb) return base * 1.1; // Slight increase for web
    if (isWindows || isMacOS) return base * 1.05; // Small increase for desktop
    return base; // Default for mobile
  }
}
