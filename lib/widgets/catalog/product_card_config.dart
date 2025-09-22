import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

/// Configuration enums for different card display modes
enum CardDisplayMode {
  compact,
  standard,
  detailed,
  minimal,
}

enum ActionButtonMode {
  single, // Only "Add to Cart"
  dual, // "Add to Cart" and "Buy Now"
  wishlistOnly, // Only wishlist functionality
  none, // No action buttons
}

enum BadgeDisplayMode {
  none,
  stockOnly,
  allBadges,
  custom,
}

/// Main configuration class for Product Card appearance and behavior
class ProductCardConfig {
  final CardDisplayMode displayMode;
  final ActionButtonMode actionButtonMode;
  final BadgeDisplayMode badgeDisplayMode;
  final bool showBrand;
  final bool showRating;
  final bool showDeliveryInfo;
  final bool showCustomizationIndicator;
  final bool showHeroAnimation;
  final bool enableErrorHandling;
  final bool enableOverflowProtection;
  final EdgeInsetsGeometry? customMargin;
  final EdgeInsetsGeometry? customPadding;
  final double? customBorderRadius;
  final Color? customBackgroundColor;
  final List<String>? customBadges;

  const ProductCardConfig({
    this.displayMode = CardDisplayMode.standard,
    this.actionButtonMode = ActionButtonMode.single,
    this.badgeDisplayMode = BadgeDisplayMode.stockOnly,
    this.showBrand = true,
    this.showRating = true,
    this.showDeliveryInfo = false,
    this.showCustomizationIndicator = true,
    this.showHeroAnimation = true,
    this.enableErrorHandling = true,
    this.enableOverflowProtection = true,
    this.customMargin,
    this.customPadding,
    this.customBorderRadius,
    this.customBackgroundColor,
    this.customBadges,
  });

  // Factory constructors for common configurations

  /// Compact card for grid layouts with minimal content
  factory ProductCardConfig.compact({
    ActionButtonMode actionButtonMode = ActionButtonMode.single,
    bool showHeroAnimation = true,
  }) {
    return ProductCardConfig(
      displayMode: CardDisplayMode.compact,
      actionButtonMode: actionButtonMode,
      badgeDisplayMode: BadgeDisplayMode.none,
      showBrand: false,
      showRating: false,
      showDeliveryInfo: false,
      showCustomizationIndicator: false,
      showHeroAnimation: showHeroAnimation,
    );
  }

  /// Standard card with full features
  factory ProductCardConfig.standard({
    ActionButtonMode actionButtonMode = ActionButtonMode.dual,
    BadgeDisplayMode badgeDisplayMode = BadgeDisplayMode.allBadges,
    bool showHeroAnimation = true,
    bool enableErrorHandling = true,
  }) {
    return ProductCardConfig(
      displayMode: CardDisplayMode.standard,
      actionButtonMode: actionButtonMode,
      badgeDisplayMode: badgeDisplayMode,
      showBrand: true,
      showRating: true,
      showDeliveryInfo: true,
      showCustomizationIndicator: true,
      showHeroAnimation: showHeroAnimation,
      enableErrorHandling: enableErrorHandling,
    );
  }

  /// Detailed card for product detail pages or featured items
  factory ProductCardConfig.detailed({
    ActionButtonMode actionButtonMode = ActionButtonMode.dual,
    bool showHeroAnimation = true,
  }) {
    return ProductCardConfig(
      displayMode: CardDisplayMode.detailed,
      actionButtonMode: actionButtonMode,
      badgeDisplayMode: BadgeDisplayMode.allBadges,
      showBrand: true,
      showRating: true,
      showDeliveryInfo: true,
      showCustomizationIndicator: true,
      showHeroAnimation: showHeroAnimation,
    );
  }

  /// Minimal card with only essential information
  factory ProductCardConfig.minimal({
    ActionButtonMode actionButtonMode = ActionButtonMode.single,
    bool showHeroAnimation = false,
  }) {
    return ProductCardConfig(
      displayMode: CardDisplayMode.minimal,
      actionButtonMode: actionButtonMode,
      badgeDisplayMode: BadgeDisplayMode.stockOnly,
      showBrand: false,
      showRating: false,
      showDeliveryInfo: false,
      showCustomizationIndicator: false,
      showHeroAnimation: showHeroAnimation,
    );
  }

  /// Error-resistant card with maximum fallback protection
  factory ProductCardConfig.failSafe({
    ActionButtonMode actionButtonMode = ActionButtonMode.single,
    bool showHeroAnimation = false,
  }) {
    return ProductCardConfig(
      displayMode: CardDisplayMode.standard,
      actionButtonMode: actionButtonMode,
      badgeDisplayMode: BadgeDisplayMode.stockOnly,
      showBrand: false,
      showRating: false,
      showDeliveryInfo: false,
      showCustomizationIndicator: false,
      showHeroAnimation: showHeroAnimation,
      enableErrorHandling: true,
      enableOverflowProtection: true,
    );
  }

  /// Copy with method for creating modified configurations
  ProductCardConfig copyWith({
    CardDisplayMode? displayMode,
    ActionButtonMode? actionButtonMode,
    BadgeDisplayMode? badgeDisplayMode,
    bool? showBrand,
    bool? showRating,
    bool? showDeliveryInfo,
    bool? showCustomizationIndicator,
    bool? showHeroAnimation,
    bool? enableErrorHandling,
    bool? enableOverflowProtection,
    EdgeInsetsGeometry? customMargin,
    EdgeInsetsGeometry? customPadding,
    double? customBorderRadius,
    Color? customBackgroundColor,
    List<String>? customBadges,
  }) {
    return ProductCardConfig(
      displayMode: displayMode ?? this.displayMode,
      actionButtonMode: actionButtonMode ?? this.actionButtonMode,
      badgeDisplayMode: badgeDisplayMode ?? this.badgeDisplayMode,
      showBrand: showBrand ?? this.showBrand,
      showRating: showRating ?? this.showRating,
      showDeliveryInfo: showDeliveryInfo ?? this.showDeliveryInfo,
      showCustomizationIndicator:
          showCustomizationIndicator ?? this.showCustomizationIndicator,
      showHeroAnimation: showHeroAnimation ?? this.showHeroAnimation,
      enableErrorHandling: enableErrorHandling ?? this.enableErrorHandling,
      enableOverflowProtection:
          enableOverflowProtection ?? this.enableOverflowProtection,
      customMargin: customMargin ?? this.customMargin,
      customPadding: customPadding ?? this.customPadding,
      customBorderRadius: customBorderRadius ?? this.customBorderRadius,
      customBackgroundColor:
          customBackgroundColor ?? this.customBackgroundColor,
      customBadges: customBadges ?? this.customBadges,
    );
  }
}

/// Configuration for content display behavior based on available space
class ContentDisplayConfig {
  final int titleMaxLines;
  final bool showRating;
  final bool showDeliveryInfo;
  final bool showBadges;
  final bool showActionButton;
  final bool showBrand;
  final bool showCustomizationIndicator;
  final bool compactMode;

  const ContentDisplayConfig({
    required this.titleMaxLines,
    required this.showRating,
    required this.showDeliveryInfo,
    required this.showBadges,
    required this.showActionButton,
    required this.showBrand,
    required this.showCustomizationIndicator,
    required this.compactMode,
  });

  /// Factory method to create config based on available height
  factory ContentDisplayConfig.fromAvailableHeight(
    double availableHeight,
    ProductCardConfig cardConfig,
  ) {
    if (availableHeight >= 200) {
      // Plenty of space - show everything configured
      return ContentDisplayConfig(
        titleMaxLines: 3,
        showRating: cardConfig.showRating,
        showDeliveryInfo: cardConfig.showDeliveryInfo,
        showBadges: cardConfig.badgeDisplayMode != BadgeDisplayMode.none,
        showActionButton: cardConfig.actionButtonMode != ActionButtonMode.none,
        showBrand: cardConfig.showBrand,
        showCustomizationIndicator: cardConfig.showCustomizationIndicator,
        compactMode: false,
      );
    } else if (availableHeight >= 150) {
      // Moderate space - show most content
      return ContentDisplayConfig(
        titleMaxLines: 2,
        showRating: cardConfig.showRating,
        showDeliveryInfo: cardConfig.showDeliveryInfo && availableHeight > 160,
        showBadges: cardConfig.badgeDisplayMode != BadgeDisplayMode.none &&
            availableHeight > 170,
        showActionButton: cardConfig.actionButtonMode != ActionButtonMode.none,
        showBrand: cardConfig.showBrand && availableHeight > 155,
        showCustomizationIndicator:
            cardConfig.showCustomizationIndicator && availableHeight > 165,
        compactMode: false,
      );
    } else if (availableHeight >= 120) {
      // Limited space - essential content only
      return ContentDisplayConfig(
        titleMaxLines: 2,
        showRating: false,
        showDeliveryInfo: cardConfig.showDeliveryInfo && availableHeight > 130,
        showBadges: false,
        showActionButton: cardConfig.actionButtonMode != ActionButtonMode.none,
        showBrand: false,
        showCustomizationIndicator: false,
        compactMode: true,
      );
    } else {
      // Very limited space - critical content only
      return ContentDisplayConfig(
        titleMaxLines: 1,
        showRating: false,
        showDeliveryInfo: false,
        showBadges: false,
        showActionButton: cardConfig.actionButtonMode != ActionButtonMode.none,
        showBrand: false,
        showCustomizationIndicator: false,
        compactMode: true,
      );
    }
  }
}

/// Configuration for action button appearance and behavior
class ActionButtonConfig {
  final ActionButtonMode mode;
  final double buttonHeight;
  final double buttonSpacing;
  final double iconSize;
  final double textSize;
  final EdgeInsetsGeometry buttonPadding;
  final BorderRadiusGeometry buttonBorderRadius;
  final Color addToCartColor;
  final Color buyNowColor;
  final Color buttonTextColor;
  final FontWeight buttonFontWeight;
  final double letterSpacing;

  const ActionButtonConfig({
    required this.mode,
    this.buttonHeight = 44.0,
    this.buttonSpacing = 6.0,
    this.iconSize = 18.0,
    this.textSize = 12.0,
    this.buttonPadding =
        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    this.buttonBorderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.addToCartColor = const Color(0xFFFF9F00),
    this.buyNowColor = const Color(0xFFFB641B),
    this.buttonTextColor = Colors.white,
    this.buttonFontWeight = FontWeight.w700,
    this.letterSpacing = 0.5,
  });

  /// Factory method to create responsive button config
  factory ActionButtonConfig.responsive(
    ActionButtonMode mode,
    DeviceCategory deviceCategory,
    ContentDensity contentDensity,
  ) {
    double buttonHeight;
    double iconSize;
    double textSize;
    double spacing;

    // Ensure minimum touch targets: 44px mobile, 48px desktop
    final minTouchTarget =
        deviceCategory.index <= DeviceCategory.medium.index ? 44.0 : 48.0;

    switch (deviceCategory) {
      case DeviceCategory.extraSmall:
        buttonHeight = contentDensity == ContentDensity.compact ? 36.0 : 40.0;
        iconSize = contentDensity == ContentDensity.compact ? 14.0 : 16.0;
        textSize = contentDensity == ContentDensity.compact ? 10.0 : 11.0;
        spacing = 4.0;
        break;
      case DeviceCategory.small:
        buttonHeight = contentDensity == ContentDensity.compact ? 40.0 : 44.0;
        iconSize = contentDensity == ContentDensity.compact ? 16.0 : 18.0;
        textSize = contentDensity == ContentDensity.compact ? 11.0 : 12.0;
        spacing = 6.0;
        break;
      default:
        buttonHeight = contentDensity == ContentDensity.compact ? 44.0 : 48.0;
        iconSize = 18.0;
        textSize = 12.0;
        spacing = 8.0;
        break;
    }

    // Ensure minimum touch target is met
    if (buttonHeight < minTouchTarget) {
      buttonHeight = minTouchTarget;
    }

    return ActionButtonConfig(
      mode: mode,
      buttonHeight: buttonHeight,
      buttonSpacing: spacing,
      iconSize: iconSize,
      textSize: textSize,
      buttonPadding:
          EdgeInsets.symmetric(vertical: buttonHeight * 0.18, horizontal: 16.0),
    );
  }
}

/// Configuration for layout and sizing calculations
class LayoutConfig {
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double elevation;
  final double totalHeight;
  final double imageHeight;
  final double contentAreaHeight;
  final EdgeInsetsGeometry contentPadding;
  final double imageRatio;

  const LayoutConfig({
    required this.margin,
    required this.borderRadius,
    required this.elevation,
    required this.totalHeight,
    required this.imageHeight,
    required this.contentAreaHeight,
    required this.contentPadding,
    this.imageRatio = 0.6,
  });

  /// Factory method to calculate layout config based on device and constraints
  factory LayoutConfig.calculate({
    required BoxConstraints constraints,
    required DeviceCategory deviceCategory,
    required ProductCardConfig cardConfig,
  }) {
    final screenWidth = constraints.maxWidth;
    final availableHeight =
        constraints.maxHeight.isFinite ? constraints.maxHeight : 400.0;

    // Base configuration that works across all devices
    double marginValue;
    double elevation;
    double borderRadius;
    double totalHeight;
    double imageRatio;

    switch (deviceCategory) {
      case DeviceCategory.extraSmall:
        marginValue = 2.0;
        elevation = 1.0;
        borderRadius = cardConfig.customBorderRadius ?? 8.0;
        totalHeight = 320.0;
        imageRatio = 0.55;
        break;

      case DeviceCategory.small:
        marginValue = 3.0;
        elevation = 2.0;
        borderRadius = cardConfig.customBorderRadius ?? 10.0;
        totalHeight = 340.0;
        imageRatio = 0.58;
        break;

      case DeviceCategory.medium:
        marginValue = 4.0;
        elevation = 3.0;
        borderRadius = cardConfig.customBorderRadius ?? 12.0;
        totalHeight = 360.0;
        imageRatio = 0.60;
        break;

      case DeviceCategory.large:
        marginValue = 5.0;
        elevation = 4.0;
        borderRadius = cardConfig.customBorderRadius ?? 14.0;
        totalHeight = 380.0;
        imageRatio = 0.62;
        break;

      case DeviceCategory.extraLarge:
        marginValue = 6.0;
        elevation = 5.0;
        borderRadius = cardConfig.customBorderRadius ?? 16.0;
        totalHeight = 400.0;
        imageRatio = 0.65;
        break;

      case DeviceCategory.extraExtraLarge:
        marginValue = 8.0;
        elevation = 6.0;
        borderRadius = cardConfig.customBorderRadius ?? 18.0;
        totalHeight = 420.0;
        imageRatio = 0.65;
        break;
    }

    // Apply custom margin if provided
    final EdgeInsetsGeometry margin =
        cardConfig.customMargin ?? EdgeInsets.all(marginValue);

    // Clamp total height to available space
    totalHeight = totalHeight.clamp(200.0, availableHeight);

    // Calculate aspect ratio for image vs content
    final imageHeight = totalHeight * imageRatio;
    final contentAreaHeight = totalHeight * (1.0 - imageRatio);

    // Calculate content padding
    final EdgeInsetsGeometry contentPadding = cardConfig.customPadding ??
        EdgeInsets.symmetric(
          horizontal: marginValue * 2,
          vertical: marginValue,
        );

    return LayoutConfig(
      margin: margin,
      borderRadius: borderRadius,
      elevation: elevation,
      totalHeight: totalHeight,
      imageHeight: imageHeight,
      contentAreaHeight: contentAreaHeight,
      contentPadding: contentPadding,
      imageRatio: imageRatio,
    );
  }
}
