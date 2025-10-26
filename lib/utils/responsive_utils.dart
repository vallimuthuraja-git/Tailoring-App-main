import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../product/product_models.dart';
import '../product/products_screen.dart';

/// Enum representing different device types
enum DeviceType { mobile, tablet, desktop }

/// Enum representing content density levels for adaptive layouts
enum ContentDensity { compact, standard, spacious }

/// Enum representing content priority levels for intelligent display
enum ContentPriority {
  price,
  rating,
  brand,
  stockInfo,
  customization,
  description
}

/// Configuration class for responsive grid layouts
class GridConfiguration {
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisExtent;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double padding;

  const GridConfiguration({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.mainAxisExtent,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.padding,
  });
}

/// Configuration class for grid spacing based on screen size
class GridSpacing {
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double padding;

  const GridSpacing({
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.padding,
  });

  static GridSpacing getSpacing(double screenWidth) {
    // Improved spacing based on design specifications with smoother transitions
    if (screenWidth < 360) {
      return GridSpacing(crossAxisSpacing: 6, mainAxisSpacing: 8, padding: 8);
    }
    if (screenWidth < 480) {
      return GridSpacing(crossAxisSpacing: 8, mainAxisSpacing: 10, padding: 10);
    }
    if (screenWidth < 600) {
      return GridSpacing(
          crossAxisSpacing: 10, mainAxisSpacing: 12, padding: 12);
    }
    if (screenWidth < 768) {
      return GridSpacing(
          crossAxisSpacing: 12, mainAxisSpacing: 14, padding: 14);
    }
    if (screenWidth < 900) {
      return GridSpacing(
          crossAxisSpacing: 14, mainAxisSpacing: 16, padding: 16);
    }
    if (screenWidth < 1200) {
      return GridSpacing(
          crossAxisSpacing: 16, mainAxisSpacing: 18, padding: 18);
    }
    if (screenWidth < 1600) {
      return GridSpacing(
          crossAxisSpacing: 18, mainAxisSpacing: 20, padding: 20);
    }
    return GridSpacing(crossAxisSpacing: 20, mainAxisSpacing: 24, padding: 24);
  }
}

/// Centralized grid configuration class for product grids (backward compatibility)
class ProductGridConfig {
  /// Legacy method - backward compatibility wrapper using new ProductGridDelegate
  static GridConfiguration getConfiguration(BuildContext context) {
    return ResponsiveUtils.getProductGridConfiguration(context);
  }
}

/// Breakpoints for responsive design
class ResponsiveBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 1024.0;
}

/// Extended breakpoints for comprehensive device coverage
class ExtendedBreakpoints {
  static const double xs = 360.0; // Extra small phones (iPhone SE, etc.)
  static const double sm = 480.0; // Small phones (Galaxy S, etc.)
  static const double md = 600.0; // Tablets/small laptops
  static const double lg = 900.0; // Large tablets
  static const double xl = 1200.0; // Desktop
  static const double xxl = 1600.0; // Large desktop
}

/// Device category enum for granular control
enum DeviceCategory {
  extraSmall, // xs: < 360px
  small, // sm: 360-480px
  medium, // md: 480-600px
  large, // lg: 600-900px
  extraLarge, // xl: 900-1200px
  extraExtraLarge // xxl: > 1200px
}

/// Utility class for responsive layout and design in Flutter
class ResponsiveUtils {
  /// Determines the device type based on screen width
  static DeviceType getDeviceType(double width) {
    if (width < ResponsiveBreakpoints.mobile) return DeviceType.mobile;
    if (width < ResponsiveBreakpoints.tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Determines the device category based on screen width (more granular)
  static DeviceCategory getDeviceCategory(double width) {
    if (width < ExtendedBreakpoints.xs) return DeviceCategory.extraSmall;
    if (width < ExtendedBreakpoints.sm) return DeviceCategory.small;
    if (width < ExtendedBreakpoints.md) return DeviceCategory.medium;
    if (width < ExtendedBreakpoints.lg) return DeviceCategory.large;
    if (width < ExtendedBreakpoints.xl) return DeviceCategory.extraLarge;
    return DeviceCategory.extraExtraLarge;
  }

  /// Gets device category from BuildContext
  static DeviceCategory getDeviceCategoryFromContext(BuildContext context) {
    return getDeviceCategory(MediaQuery.of(context).size.width);
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

  /// Returns dynamic font size based on available space and content length
  static double dynamicFontSize({
    required double baseFontSize,
    required double availableWidth,
    required String text,
    double minFontSize = 10.0,
    double maxFontSize = 24.0,
  }) {
    // Calculate optimal font size based on text length and available space
    final textLength = text.length;
    final estimatedTextWidth =
        textLength * (baseFontSize * 0.6); // Rough estimate

    if (estimatedTextWidth <= availableWidth) {
      return baseFontSize.clamp(minFontSize, maxFontSize);
    }

    // Scale down font size proportionally
    final scaleFactor = availableWidth / estimatedTextWidth;
    final scaledSize = baseFontSize * scaleFactor;

    return scaledSize.clamp(minFontSize, maxFontSize);
  }

  /// Returns dynamic font size from BuildContext with space awareness
  static double getDynamicFontSize({
    required BuildContext context,
    required double baseFontSize,
    required String text,
    double minFontSize = 10.0,
    double maxFontSize = 24.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final device = getDeviceTypeFromContext(context);

    // Get base responsive size first
    final responsiveSize = responsiveFontSize(baseFontSize, device);

    // Apply dynamic scaling based on available space
    return dynamicFontSize(
      baseFontSize: responsiveSize,
      availableWidth: screenWidth * 0.8, // Use 80% of screen width as available
      text: text,
      minFontSize: minFontSize,
      maxFontSize: maxFontSize,
    );
  }

  /// Calculates optimal content density based on screen size and content complexity
  static ContentDensity getContentDensity(
    BuildContext context, {
    bool hasRichContent = false,
    int itemCount = 1,
    bool isGridView = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate content density score
    double densityScore = 0.0;

    // Screen size factors
    if (screenWidth >= 1200) {
      densityScore += 2.0; // Desktop
    } else if (screenWidth >= 768) {
      densityScore += 1.5; // Tablet
    } else if (screenWidth >= 480) {
      densityScore += 1.0; // Large mobile
    } else {
      densityScore += 0.5; // Small mobile
    }

    // Content factors
    if (hasRichContent) densityScore += 0.5;
    if (itemCount > 10) {
      densityScore -= 0.3; // More items = less density per item
    }
    if (!isGridView) densityScore += 0.2; // List view can handle more density

    // Height factor (taller screens can handle more density)
    if (screenHeight > 800) {
      densityScore += 0.3;
    } else if (screenHeight < 600) {
      densityScore -= 0.2;
    }

    // Determine density level
    if (densityScore >= 2.5) return ContentDensity.spacious;
    if (densityScore >= 1.5) return ContentDensity.standard;
    return ContentDensity.compact;
  }

  /// Calculates content density based on available space per item (for grid layouts)
  static ContentDensity getContentDensityFromSpace(
      double screenWidth, double screenHeight) {
    // Calculate available space per item
    final crossAxisCount = getCrossAxisCount(screenWidth);
    final availableWidth = screenWidth -
        (GridSpacing.getSpacing(screenWidth).crossAxisSpacing *
            (crossAxisCount - 1));
    final itemWidth = availableWidth / crossAxisCount;
    final itemHeight =
        itemWidth / getAspectRatio(screenWidth, getDeviceType(screenWidth));

    // Determine density based on item dimensions
    if (itemHeight < 200) return ContentDensity.compact;
    if (itemHeight < 280) return ContentDensity.standard;
    return ContentDensity.spacious;
  }

  /// Returns adaptive spacing based on content density
  static double getAdaptiveSpacing(
    BuildContext context, {
    double baseSpacing = 16.0,
    bool hasRichContent = false,
    int itemCount = 1,
    bool isGridView = true,
  }) {
    final density = getContentDensity(
      context,
      hasRichContent: hasRichContent,
      itemCount: itemCount,
      isGridView: isGridView,
    );

    switch (density) {
      case ContentDensity.compact:
        return baseSpacing * 0.5;
      case ContentDensity.standard:
        return baseSpacing;
      case ContentDensity.spacious:
        return baseSpacing * 1.25;
    }
  }

  /// Returns adaptive padding based on content density and screen size
  static EdgeInsets getAdaptivePadding(
    BuildContext context, {
    double basePadding = 16.0,
    bool hasRichContent = false,
    int itemCount = 1,
    bool isGridView = true,
  }) {
    final adaptiveSpacing = getAdaptiveSpacing(
      context,
      baseSpacing: basePadding,
      hasRichContent: hasRichContent,
      itemCount: itemCount,
      isGridView: isGridView,
    );

    return EdgeInsets.all(adaptiveSpacing);
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

  /// Returns crossAxisCount based on screen width for product grids (improved based on design specs)
  static int getCrossAxisCount(double screenWidth) {
    // Extra small phones (iPhone SE, small Android)
    if (screenWidth < 360) return 1;

    // Small phones (Galaxy S, iPhone standard)
    if (screenWidth < 480) return 2;

    // Medium phones (iPhone Pro, Pixel)
    if (screenWidth < 600) return 2;

    // Small tablets (iPad mini, 7-8 inch tablets)
    if (screenWidth < 768) return 3;

    // Medium tablets (iPad, 9-10 inch tablets)
    if (screenWidth < 900) return 3;

    // Small laptops/desktops
    if (screenWidth < 1200) return 4;

    // Medium desktops
    if (screenWidth < 1440) return 4;

    // Large desktops
    if (screenWidth < 1600) return 5;

    // Ultra wide screens (capped at 6 for usability)
    return 6;
  }

  /// Returns aspect ratio based on screen width and device type (improved based on design specs)
  static double getAspectRatio(double screenWidth, DeviceType device) {
    // Improved aspect ratios based on design specifications
    if (screenWidth < 360) {
      return 1.8; // Extra small screens - very tall for content
    } else if (screenWidth < 480) {
      return 1.6; // Small phones
    } else if (screenWidth < 600) {
      return screenWidth < 360 ? 1.8 : 1.6; // Mobile devices
    } else if (screenWidth < 768) {
      return 1.4; // Small tablets
    } else if (screenWidth < 900) {
      return 1.3; // Medium tablets
    } else if (screenWidth < 1200) {
      return 1.2; // Large tablets/small laptops
    } else if (screenWidth < 1600) {
      return 1.1; // Standard desktop
    } else {
      return 1.0; // Large desktop - wider cards
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

  /// Legacy method - backward compatibility wrapper using LazyResponsiveCalculator
  static SliverGridDelegate overflowSafeProductGridDelegateWithMaxExtent(
      DeviceType device, double screenWidth) {
    // Calculate columns with MAXIMUM of 4
    int crossAxisCount;
    if (screenWidth < 480) {
      crossAxisCount = 2;
    } else if (screenWidth < 1024) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }

    // Use LazyResponsiveCalculator for aspect ratio
    final aspectRatio = LazyResponsiveCalculator.getAspectRatio(
        screenWidth, 800); // Default height
    final spacing = GridSpacing.getSpacing(screenWidth);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: aspectRatio,
      crossAxisSpacing: spacing.crossAxisSpacing,
      mainAxisSpacing: spacing.mainAxisSpacing,
    );
  }

  /// Legacy method - kept for backward compatibility
  static SliverGridDelegate overflowSafeProductGridDelegate(
      DeviceType device, double screenWidth) {
    return overflowSafeProductGridDelegateWithMaxExtent(device, screenWidth);
  }

  /// Legacy method - backward compatibility wrapper using LazyResponsiveCalculator
  static SliverGridDelegate overflowSafeServiceGridDelegate(
      double screenWidth) {
    int crossAxisCount;
    if (screenWidth < 400) {
      crossAxisCount = 1;
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    // Service aspect ratios are different from product grids
    double aspectRatio;
    if (screenWidth < 360) {
      aspectRatio = 2.0;
    } else if (screenWidth < 600) {
      aspectRatio = 1.8;
    } else if (screenWidth < 1200) {
      aspectRatio = 1.4;
    } else {
      aspectRatio = 1.3;
    }

    final spacing = GridSpacing.getSpacing(screenWidth);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: aspectRatio,
      crossAxisSpacing: spacing.crossAxisSpacing,
      mainAxisSpacing: spacing.mainAxisSpacing,
    );
  }

  /// Legacy method - backward compatibility wrapper using new ProductGridDelegate
  static GridConfiguration getProductGridConfiguration(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final delegate = ProductGridDelegate.fromContext(context);

    return GridConfiguration(
      crossAxisCount: ResponsiveUtils.getCrossAxisCount(screenWidth),
      childAspectRatio:
          LazyResponsiveCalculator.getAspectRatio(screenWidth, screenHeight),
      mainAxisExtent: delegate.mainAxisExtent ?? 400,
      crossAxisSpacing: GridSpacing.getSpacing(screenWidth).crossAxisSpacing,
      mainAxisSpacing: GridSpacing.getSpacing(screenWidth).mainAxisSpacing,
      padding: GridSpacing.getSpacing(screenWidth).padding,
    );
  }

  /// Legacy method - backward compatibility wrapper using new ProductGridDelegate
  static SliverGridDelegate getOverflowSafeProductGridDelegate(
      BuildContext context) {
    return ProductGridDelegate.fromContext(context);
  }

  /// Legacy method - backward compatibility wrapper using new ProductGridDelegate
  static SliverGridDelegate getOverflowSafeServiceGridDelegate(
      BuildContext context) {
    return ProductGridDelegate.serviceGrid(context);
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

  /// Returns prioritized content elements based on screen real estate
  static List<ContentPriority> getPrioritizedContent(
    BuildContext context, {
    required bool hasRating,
    required bool hasCustomization,
    required bool hasDescription,
    required bool hasBrand,
    required bool hasStockInfo,
    required bool hasPrice,
    double availableHeight = double.infinity,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final device = getDeviceTypeFromContext(context);
    final density = getContentDensity(context);

    List<ContentPriority> prioritizedContent = [];

    // Critical content - always show if available
    if (hasPrice) prioritizedContent.add(ContentPriority.price);

    // High priority content
    if (hasRating &&
        (device != DeviceType.mobile || density != ContentDensity.compact)) {
      prioritizedContent.add(ContentPriority.rating);
    }

    if (hasBrand && screenWidth >= 600) {
      prioritizedContent.add(ContentPriority.brand);
    }

    // Medium priority content
    if (hasStockInfo && (device != DeviceType.mobile || screenWidth >= 480)) {
      prioritizedContent.add(ContentPriority.stockInfo);
    }

    if (hasCustomization && screenWidth >= 600) {
      prioritizedContent.add(ContentPriority.customization);
    }

    // Low priority content - only show on larger screens or when space allows
    if (hasDescription && screenWidth >= 768 && availableHeight > 200) {
      prioritizedContent.add(ContentPriority.description);
    }

    return prioritizedContent;
  }

  /// Determines if a specific content element should be displayed
  static bool shouldShowContent(
    BuildContext context,
    ContentPriority priority, {
    bool hasRating = false,
    bool hasCustomization = false,
    bool hasDescription = false,
    bool hasBrand = false,
    bool hasStockInfo = false,
    bool hasPrice = false,
    double availableHeight = double.infinity,
  }) {
    final prioritizedContent = getPrioritizedContent(
      context,
      hasRating: hasRating,
      hasCustomization: hasCustomization,
      hasDescription: hasDescription,
      hasBrand: hasBrand,
      hasStockInfo: hasStockInfo,
      hasPrice: hasPrice,
      availableHeight: availableHeight,
    );

    return prioritizedContent.contains(priority);
  }
}

/// Lazy calculator for responsive values with caching for performance
class LazyResponsiveCalculator {
  static final Map<String, dynamic> _cache = {};

  /// Gets cached responsive aspect ratio for given screen width (improved based on design specs)
  static double getAspectRatio(double screenWidth, double screenHeight) {
    final key = 'aspect_$screenWidth';
    if (_cache.containsKey(key)) return _cache[key];

    double aspectRatio;
    final deviceType = ResponsiveUtils.getDeviceType(screenWidth);

    // Improved aspect ratios based on design specifications
    if (screenWidth < 360) {
      aspectRatio = 1.8; // Extra small screens - very tall for content
    } else if (screenWidth < 480) {
      aspectRatio = 1.6; // Small phones
    } else if (screenWidth < 600) {
      aspectRatio = screenWidth < 360 ? 1.8 : 1.6; // Mobile devices
    } else if (screenWidth < 768) {
      aspectRatio = 1.4; // Small tablets
    } else if (screenWidth < 900) {
      aspectRatio = 1.3; // Medium tablets
    } else if (screenWidth < 1200) {
      aspectRatio = 1.2; // Large tablets/small laptops
    } else if (screenWidth < 1600) {
      aspectRatio = 1.1; // Standard desktop
    } else {
      aspectRatio = 1.0; // Large desktop - wider cards
    }

    // Integrate ContentDensity calculations with improved logic
    final density =
        ResponsiveUtils.getContentDensityFromSpace(screenWidth, screenHeight);
    switch (density) {
      case ContentDensity.compact:
        aspectRatio *= 0.95; // Slightly more compact
        break;
      case ContentDensity.spacious:
        aspectRatio *= 1.05; // Slightly more spacious
        break;
      case ContentDensity.standard:
        // Keep as is
        break;
    }

    // Ensure reasonable bounds
    aspectRatio = aspectRatio.clamp(0.8, 2.2);

    _cache[key] = aspectRatio;
    return aspectRatio;
  }

  /// Gets cached max cross axis extent for given screen width (responsive based on 200px target item width)
  static double getMaxCrossAxisExtent(double screenWidth) {
    final key = 'maxExtent_$screenWidth';
    if (_cache.containsKey(key)) return _cache[key];

    final spacing = GridSpacing.getSpacing(screenWidth);
    final availableWidth = screenWidth - spacing.padding * 2;

    // Calculate crossAxisCount based on desired item width of 200 pixels
    const double desiredItemWidth = 200.0;
    int crossAxisCount = (availableWidth / desiredItemWidth).floor();

    // Ensure minimum of 1 column and maximum reasonable columns
    crossAxisCount = crossAxisCount.clamp(1, 8);

    // Special case for very small screens - ensure at least 1 column
    if (screenWidth < 250) {
      crossAxisCount = 1;
    } else if (screenWidth < 400) {
      crossAxisCount = crossAxisCount.clamp(1, 2);
    }

    final extent = availableWidth / crossAxisCount;

    _cache[key] = extent;
    return extent;
  }

  /// Clears the cache (useful for testing or orientation changes)
  static void clearCache() {
    _cache.clear();
  }
}

/// Consolidated ProductGridDelegate - Single source of truth for all grid configuration
class ProductGridDelegate extends SliverGridDelegateWithMaxCrossAxisExtent {
  final BuildContext context;
  final int itemCount;
  final bool fillLastRowWithPlaceholders;
  final double? customAspectRatio;

  ProductGridDelegate({
    required this.context,
    this.itemCount = 0,
    this.fillLastRowWithPlaceholders = true,
    this.customAspectRatio,
  }) : super(
          maxCrossAxisExtent: LazyResponsiveCalculator.getMaxCrossAxisExtent(
              MediaQuery.of(context).size.width),
          mainAxisExtent: _calculateMainAxisExtent(context),
          crossAxisSpacing:
              GridSpacing.getSpacing(MediaQuery.of(context).size.width)
                  .crossAxisSpacing,
          mainAxisSpacing:
              GridSpacing.getSpacing(MediaQuery.of(context).size.width)
                  .mainAxisSpacing,
          childAspectRatio: customAspectRatio ??
              LazyResponsiveCalculator.getAspectRatio(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
        );

  static double _calculateMainAxisExtent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceCategory = ResponsiveUtils.getDeviceCategory(screenWidth);

    // Standardized card heights for consistent grid layout
    // Fixed heights ensure uniform appearance across all products
    switch (deviceCategory) {
      case DeviceCategory.extraSmall:
        return 340.0; // Compact height for small screens
      case DeviceCategory.small:
        return 360.0; // Balanced height for small phones
      case DeviceCategory.medium:
        return 380.0; // Standard height for medium screens
      case DeviceCategory.large:
        return 400.0; // Comfortable height for large screens
      case DeviceCategory.extraLarge:
        return 420.0; // Spacious height for XL screens
      case DeviceCategory.extraExtraLarge:
        return 440.0; // Maximum height for XXL screens
    }
  }

  /// Factory method to create delegate from BuildContext
  factory ProductGridDelegate.fromContext(
    BuildContext context, {
    int itemCount = 0,
    bool fillLastRowWithPlaceholders = true,
    double? customAspectRatio,
  }) {
    return ProductGridDelegate(
      context: context,
      itemCount: itemCount,
      fillLastRowWithPlaceholders: fillLastRowWithPlaceholders,
      customAspectRatio: customAspectRatio,
    );
  }

  /// Factory method for service grids (uses different aspect ratios)
  factory ProductGridDelegate.serviceGrid(
    BuildContext context, {
    int itemCount = 0,
    bool fillLastRowWithPlaceholders = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Service grids typically need different aspect ratios
    double serviceAspectRatio;
    if (screenWidth < 360) {
      serviceAspectRatio = 2.0; // Very tall for small screens
    } else if (screenWidth < 600) {
      serviceAspectRatio = 1.8; // Tall for mobile
    } else if (screenWidth < 1200) {
      serviceAspectRatio = 1.4; // Balanced for tablets
    } else {
      serviceAspectRatio = 1.3; // Desktop
    }

    return ProductGridDelegate(
      context: context,
      itemCount: itemCount,
      fillLastRowWithPlaceholders: fillLastRowWithPlaceholders,
      customAspectRatio: serviceAspectRatio,
    );
  }

  /// Calculates the total number of items including placeholders for last row filling
  int getTotalItemCount() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = ResponsiveUtils.getCrossAxisCount(screenWidth);

    if (itemCount == 0 || crossAxisCount == 0) return itemCount;

    if (!fillLastRowWithPlaceholders) return itemCount;

    final remainder = itemCount % crossAxisCount;
    if (remainder == 0) return itemCount; // Already fills complete rows

    // Add placeholders to fill the last row
    return itemCount + (crossAxisCount - remainder);
  }

  /// Determines if an index is a placeholder item
  bool isPlaceholder(int index) {
    return fillLastRowWithPlaceholders && index >= itemCount;
  }

  /// Creates a placeholder widget for grid items
  Widget createPlaceholderWidget() {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = GridSpacing.getSpacing(screenWidth);

    return Container(
      margin: EdgeInsets.all(spacing.padding / 2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) {
    if (oldDelegate is! ProductGridDelegate) return true;
    return (itemCount != oldDelegate.itemCount ||
        fillLastRowWithPlaceholders !=
            oldDelegate.fillLastRowWithPlaceholders ||
        customAspectRatio != oldDelegate.customAspectRatio ||
        MediaQuery.of(context).size != MediaQuery.of(oldDelegate.context).size);
  }
}

// Consolidated Grid Item with Product Card functionality
class UnifiedProductGridItem extends StatelessWidget {
  final Product product;
  final int index;
  final VoidCallback? onTap;

  const UnifiedProductGridItem({
    super.key,
    required this.product,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use the new unified product card for better layout and maintainability
    return UnifiedProductCard(
      product: product,
      onTap: onTap ?? () {}, // Provide empty callback if no tap handler
      index: index,
    );
  }
}
