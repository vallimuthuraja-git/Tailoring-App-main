/// Consolidated Product Cards Library
/// This file contains the unified product card implementation and utilities
/// for the catalog module.

import 'package:flutter/material.dart';

export 'unified_product_card.dart';

/// Common card configurations and utilities
class ProductCardUtils {
  /// Get standard card margins for grid layouts
  static EdgeInsets getStandardCardMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return const EdgeInsets.all(4.0); // Mobile
    } else if (screenWidth < 1200) {
      return const EdgeInsets.all(6.0); // Tablet
    } else {
      return const EdgeInsets.all(8.0); // Desktop
    }
  }

  /// Calculate optimal grid columns based on screen size
  static int getOptimalGridColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 2; // Mobile
    } else if (screenWidth < 900) {
      return 3; // Small tablet
    } else if (screenWidth < 1200) {
      return 4; // Large tablet
    } else {
      return 5; // Desktop
    }
  }

  /// Get responsive card dimensions
  static CardDimensions getResponsiveCardDimensions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = getOptimalGridColumns(context);
    final availableWidth =
        screenWidth - (columns + 1) * 8.0; // Account for margins
    final cardWidth = availableWidth / columns;

    // Aspect ratio for cards (width:height)
    const aspectRatio = 0.75; // 3:4 ratio
    final cardHeight = cardWidth / aspectRatio;

    return CardDimensions(
      width: cardWidth,
      height: cardHeight,
      imageHeight: cardHeight * 0.6, // 60% for image
      contentHeight: cardHeight * 0.4, // 40% for content
    );
  }
}

/// Dimensions class for card calculations
class CardDimensions {
  final double width;
  final double height;
  final double imageHeight;
  final double contentHeight;

  const CardDimensions({
    required this.width,
    required this.height,
    required this.imageHeight,
    required this.contentHeight,
  });
}
