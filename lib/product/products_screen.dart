import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'product_models.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_utils.dart';
import '../utils/theme_constants.dart';
import '../providers/wishlist_provider.dart';
import '../models/user_role.dart';
import '../widgets/optimized_image.dart';

// Catalog Configuration and Widget Classes

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

  /// Factory constructors for common configurations

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

class PriceDisplay extends StatelessWidget {
  final Product product;

  const PriceDisplay({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price - Bounded text
        Expanded(
          child: Text(
            product.formattedPrice,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Stock indicator - Fixed small size
        if (product.stockCount <= 5 && product.stockCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '${product.stockCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class RatingStars extends StatelessWidget {
  final Product product;

  const RatingStars({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Data validation: Check for valid rating data
    if (product.rating.averageRating <= 0 ||
        product.rating.averageRating.isNaN ||
        product.rating.reviewCount < 0) {
      return const SizedBox.shrink();
    }

    // Clamp rating to valid range (0-5)
    final clampedRating = product.rating.averageRating.clamp(0.0, 5.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          5,
          (index) => Icon(
            index < clampedRating.floor()
                ? Icons.star
                : index < clampedRating
                    ? Icons.star_half
                    : Icons.star_border,
            size: 10,
            color: Colors.amber[600],
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '${clampedRating.toStringAsFixed(1)} (${product.rating.reviewCount})',
          style: TextStyle(
            fontSize: 8,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                : AppColors.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

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

/// Ultra-modern Product Card with Advanced Design
class UnifiedProductCard extends StatelessWidget {
  final Product product;
  final int index;
  final VoidCallback? onTap;
  final double? aspectRatio;
  final bool showBadges;
  final bool showRating;

  const UnifiedProductCard({
    super.key,
    required this.product,
    required this.index,
    this.onTap,
    this.aspectRatio = 0.75,
    this.showBadges = true,
    this.showRating = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: aspectRatio!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          DarkAppColors.surface,
                          DarkAppColors.surface.withValues(alpha: 0.8),
                        ]
                      : [
                          Colors.white,
                          Colors.grey.shade50.withValues(alpha: 0.5),
                        ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap ?? () => _navigateToProduct(context),
                    borderRadius: BorderRadius.circular(20),
                    splashColor: Colors.orange.withValues(alpha: 0.1),
                    highlightColor: Colors.orange.withValues(alpha: 0.05),
                    child: _buildCardContent(context, constraints),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(BuildContext context, BoxConstraints constraints) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced Image Section with Overlay Effects
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              // Main Image with Optimized Caching
              Hero(
                tag: 'product_${product.id}_$index',
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [
                              DarkAppColors.surface,
                              DarkAppColors.surface.withValues(alpha: 0.8),
                            ]
                          : [
                              Colors.grey.shade100,
                              Colors.grey.shade200,
                            ],
                    ),
                  ),
                  child: product.imageUrls.isNotEmpty
                      ? ProductImage(
                          imageUrl: product.imageUrls.first,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : _buildImageFallback(context),
                ),
              ),

              // Gradient Overlay for Better Text Readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),

              // Enhanced Badge System
              if (showBadges) ...[
                // Sale Badge with Glow Effect
                if (product.originalPrice != null &&
                    product.originalPrice! > product.basePrice)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.lightGreen],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.savingsPercentage}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Stock Status with Advanced Styling
                if (product.stockCount <= 5)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.stockCount == 0
                            ? Colors.red.shade600
                            : Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        product.stockCount == 0 ? 'Sold Out' : 'Limited',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                // New Arrival Badge
                if (product.isNewArrival)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.lightBlue],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.new_releases,
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'NEW',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],

              // Premium Wishlist Button
              Positioned(
                top: 8,
                right: showBadges && product.stockCount <= 5 ? 65 : 8,
                child: _buildWishlistButton(),
              ),

              // Quick Add to Cart FAB
              Positioned(
                bottom: 12,
                right: 12,
                child: _buildQuickAddButton(context),
              ),
            ],
          ),
        ),

        // Enhanced Content Section with Typography Hierarchy
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Brand Badge
                if (product.brand.isNotEmpty) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.primary.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.brand.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Product Name with Typography
                Flexible(
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface
                          : AppColors.onSurface,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 6),

                // Rating Display
                if (showRating && product.rating.averageRating > 0) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 10,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.rating.reviewCount})',
                        style: TextStyle(
                          fontSize: 10,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                              : AppColors.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                // Price Section
                _buildPriceSection(themeProvider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(ThemeProvider themeProvider) {
    final hasDiscount = product.originalPrice != null &&
        product.originalPrice! > product.basePrice;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: hasDiscount
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      product.formattedPrice,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product.formattedOriginalPrice,
                        style: TextStyle(
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red.shade300,
                          decorationThickness: 2,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.4)
                              : AppColors.onSurface.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.green.shade900.withValues(alpha: 0.3)
                        : Colors.green.shade50,
                    border: Border.all(
                        color: themeProvider.isDarkMode
                            ? Colors.green.shade700
                            : Colors.green.shade200,
                        width: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Save ${product.savingsAmount}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: themeProvider.isDarkMode
                          ? Colors.green.shade300
                          : Colors.green,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              product.formattedPrice,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
    );
  }

  Widget _buildImageFallback(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.grey.shade700, Colors.grey.shade800]
              : [Colors.grey.shade200, Colors.grey.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade400,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Image\nUnavailable',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistButton() {
    return Selector<ProductProvider, bool>(
      selector: (context, productProvider) =>
          productProvider.isProductInWishlist(product.id),
      builder: (context, isInWishlist, child) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        final isDarkMode = themeProvider.isDarkMode;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isInWishlist
                ? const LinearGradient(
                    colors: [Colors.red, Colors.pink],
                  )
                : LinearGradient(
                    colors: isDarkMode
                        ? [
                            DarkAppColors.surface.withValues(alpha: 0.9),
                            DarkAppColors.surface.withValues(alpha: 0.7),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.9),
                            Colors.white.withValues(alpha: 0.7),
                          ],
                  ),
            border: Border.all(
              color: isInWishlist
                  ? Colors.red.shade300
                  : (isDarkMode
                      ? DarkAppColors.surface.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.5)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isInWishlist
                    ? Colors.red.withValues(alpha: 0.3)
                    : (isDarkMode
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1)),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => _toggleWishlist(context),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isInWishlist),
                size: 20,
                color: isInWishlist
                    ? Colors.white
                    : (isDarkMode
                        ? DarkAppColors.onSurface
                        : Colors.grey.shade700),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAddButton(BuildContext context) {
    return Selector<CartProvider, bool>(
      selector: (context, cartProvider) =>
          cartProvider.items.any((item) => item.product.id == product.id),
      builder: (context, isInCart, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          child: FloatingActionButton(
            heroTag: 'quick_add_${product.id}',
            mini: true,
            backgroundColor: isInCart ? Colors.green : Colors.orange,
            foregroundColor: Colors.white,
            elevation: 4,
            onPressed: () => _quickAddToCart(context),
            child: Icon(
              isInCart ? Icons.check : Icons.add_shopping_cart,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  void _navigateToProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _toggleWishlist(BuildContext context) {
    final wishlistProvider =
        Provider.of<ProductProvider>(context, listen: false);
    wishlistProvider.toggleWishlist(product.id);

    final isNowInWishlist = wishlistProvider.isProductInWishlist(product.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isNowInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isNowInWishlist ? Colors.red : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              isNowInWishlist ? 'Added to wishlist!' : 'Removed from wishlist',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _quickAddToCart(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isInCart =
        cartProvider.items.any((item) => item.product.id == product.id);

    if (!isInCart) {
      cartProvider.addToCart(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                'Added ${product.name} to cart!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already in cart!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Loading Skeleton Components
class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return AspectRatio(
      aspectRatio: 0.75,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              Expanded(
                flex: 6,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                  ),
                ),
              ),

              // Content skeleton
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand skeleton
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color:
                              isDarkMode ? Colors.grey.shade800 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Name skeletons
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              isDarkMode ? Colors.grey.shade800 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              isDarkMode ? Colors.grey.shade800 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rating skeleton
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color:
                              isDarkMode ? Colors.grey.shade800 : Colors.white,
                        ),
                      ),
                      const Spacer(),

                      // Price skeleton
                      Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              isDarkMode ? Colors.grey.shade800 : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Customer-Facing Product Screen with Performance Optimizations
/// Displays products for regular users to browse and purchase
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;
  bool _isGridView = true;
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _debouncedSearchQuery = '';
  final String _sortOption = 'name';
  bool _hasLoadedProducts = false;
  bool _isPullRefreshing = false;
  Timer? _searchDebounceTimer;

  // Performance optimization: Cache for filtered and sorted products
  final Map<String, (List<Product>, int)> _filteredProductsCache = {};

  // Optimization constants
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedProducts) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          Provider.of<ProductProvider>(context, listen: false).loadProducts();
          _hasLoadedProducts = true;
        } catch (e) {
          debugPrint('Error loading products: $e');
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            if (_isSearchExpanded) _buildSearchBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductGrid(), // All Products
                  _buildProductGrid(
                      category: ProductCategory.womensWear), // Women's
                  _buildProductGrid(productType: 'new'), // New Arrivals
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.totalQuantity > 0) {
              return FloatingActionButton(
                onPressed: () => _showCartBottomSheet(context),
                child: Badge(
                  label: Text('${cartProvider.totalQuantity}'),
                  child: const Icon(Icons.shopping_cart),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: const Text(
        'Products',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
          onPressed: () =>
              setState(() => _isSearchExpanded = !_isSearchExpanded),
        ),
        IconButton(
          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
      ],
      bottom: _buildTabBar(),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]!.withValues(alpha: 0.3 * 255)
              : Colors.grey[100]!.withValues(alpha: 0.8 * 255),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Women'),
            Tab(text: 'New'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _debounceSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // Debounced search functionality
  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _debounceSearch(value);
  }

  void _debounceSearch(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        setState(() => _debouncedSearchQuery = value);
      }
    });
  }

  // Pull-to-refresh functionality
  Future<void> _onRefresh() async {
    if (_isPullRefreshing) return;

    setState(() => _isPullRefreshing = true);

    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      await productProvider.refreshProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Products refreshed!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _onRefresh,
              textColor: Colors.white,
            ),
          ),
        );
      }
    } finally {
      setState(() => _isPullRefreshing = false);
    }
  }

  Widget _buildProductGrid({ProductCategory? category, String? productType}) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Memoize filtered and sorted products to avoid recalculation on every build
        final filteredProducts = _getFilteredProducts(
          productProvider.products,
          category: category,
          productType: productType,
          searchQuery: _debouncedSearchQuery,
        );

        // Loading state with skeleton
        if (productProvider.isLoading && filteredProducts.isEmpty) {
          return _buildSkeletonGrid();
        }

        // Pull-to-refresh wrapper
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: Colors.orange,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: CustomScrollView(
            key: const PageStorageKey('products_scroll_view'),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        '${filteredProducts.length} product${filteredProducts.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _showFilterBottomSheet(context),
                        icon: const Icon(Icons.sort, size: 16),
                        label: const Text('Sort & Filter'),
                      ),
                    ],
                  ),
                ),
              ),
              _isGridView
                  ? SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveUtils.getCrossAxisCount(
                            MediaQuery.of(context).size.width),
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= filteredProducts.length) return null;
                          final product = filteredProducts[index];
                          return UnifiedProductCard(
                            key: ValueKey('product_${product.id}_$index'),
                            product: product,
                            index: index,
                            onTap: () =>
                                _navigateToProductDetail(context, product),
                          );
                        },
                        childCount: filteredProducts.length,
                        addAutomaticKeepAlives: true,
                        addRepaintBoundaries: true,
                        addSemanticIndexes: false,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= filteredProducts.length) return null;
                          final product = filteredProducts[index];
                          final themeProvider = Provider.of<ThemeProvider>(
                              context,
                              listen: false);
                          return _buildProductListItem(product, themeProvider);
                        },
                        childCount: filteredProducts.length,
                        addAutomaticKeepAlives: true,
                        addRepaintBoundaries: true,
                        addSemanticIndexes: false,
                      ),
                    ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: 80)), // Space for FAB
            ],
          ),
        );
      },
    );
  }

  // Memoized filtering and sorting function
  List<Product> _getFilteredProducts(
    List<Product> allProducts, {
    ProductCategory? category,
    String? productType,
    String? searchQuery,
  }) {
    // Create a cache key for memoization
    final cacheKey =
        '${category?.name ?? 'all'}_${productType ?? 'all'}_${searchQuery ?? ''}_$_sortOption';

    // Check if we have cached results
    if (_filteredProductsCache.containsKey(cacheKey) &&
        _filteredProductsCache[cacheKey]!.$2 == allProducts.length) {
      return _filteredProductsCache[cacheKey]!.$1;
    }

    var products = List<Product>.from(allProducts);

    // Apply category filter
    if (category != null) {
      products = products.where((p) => p.category == category).toList();
    }

    // Apply product type filter
    if (productType == 'new') {
      products = products.where((p) => p.isNewArrival).toList();
    }

    // Apply search filter with debounced query for better performance
    if (searchQuery?.isNotEmpty ?? false) {
      final query = searchQuery!.toLowerCase();
      products = products.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.brand.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    products.sort(_sortComparator());

    // Cache the result
    _filteredProductsCache[cacheKey] = (products, allProducts.length);

    // Limit cache size
    if (_filteredProductsCache.length > 10) {
      _filteredProductsCache.remove(_filteredProductsCache.keys.first);
    }

    return products;
  }

  Widget _buildSkeletonGrid() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Loading products...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const _ProductCardSkeleton(),
              childCount: 6, // Show 6 skeleton cards
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for FAB
      ],
    );
  }

  int Function(Product a, Product b) _sortComparator() {
    switch (_sortOption) {
      case 'name':
        return (a, b) => a.name.compareTo(b.name);
      case 'name_desc':
        return (a, b) => b.name.compareTo(a.name);
      case 'price_asc':
        return (a, b) => a.basePrice.compareTo(b.basePrice);
      case 'price_desc':
        return (a, b) => b.basePrice.compareTo(a.basePrice);
      case 'rating':
        return (a, b) =>
            b.rating.averageRating.compareTo(a.rating.averageRating);
      default:
        return (a, b) => a.name.compareTo(b.name);
    }
  }

  void _navigateToProductDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final items = cartProvider.items;
          return Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[600]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Cart Items (${items.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: Text(
                          '${item.quantity}x',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        title: Text(item.product.name),
                        subtitle: Text(item.product.formattedPrice),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () =>
                              cartProvider.removeFromCart(item.product.id),
                        ),
                      );
                    },
                  ),
                ),
                if (items.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          items.isEmpty
                              ? '\$0.00'
                              : '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductListItem(Product product, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) => InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToProductDetail(context, product),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Product Image
                Hero(
                  tag: 'product_${product.id}_list',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      image: product.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(product.imageUrls.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: product.imageUrls.isEmpty
                        ? Icon(
                            Icons.inventory_2,
                            color: themeProvider.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            size: 32,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand
                      if (product.brand.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.brand.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.grey[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Product Name
                      Text(
                        product.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Description
                      Text(
                        product.description,
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Rating and Category
                      Row(
                        children: [
                          // Rating
                          if (product.rating.averageRating > 0) ...[
                            Icon(Icons.star,
                                size: 14, color: Colors.amber[600]),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],

                          // Category
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(product.category)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.categoryName,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getCategoryColor(product.category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price and Wishlist
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price
                    Text(
                      product.formattedPrice,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? Colors.orange[300]
                            : Colors.orange[800],
                      ),
                    ),

                    // Original price if discounted
                    if (product.originalPrice != null &&
                        product.originalPrice! > product.basePrice) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.formattedOriginalPrice,
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[500],
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Stock indicator
                    if (product.stockCount <= 5 && product.stockCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${product.stockCount} left',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    // Wishlist button
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        if (authProvider.user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please log in to manage favorites')),
                          );
                          return;
                        }

                        final success =
                            await wishlistProvider.toggleWishlist(product.id);
                        if (success && mounted) {
                          final isInWishlist =
                              wishlistProvider.isProductInWishlist(product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isInWishlist
                                  ? '${product.name} added to favorites'
                                  : '${product.name} removed from favorites'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        wishlistProvider.isProductInWishlist(product.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: wishlistProvider.isProductInWishlist(product.id)
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.mensWear:
        return Colors.blue;
      case ProductCategory.womensWear:
        return Colors.pink;
      case ProductCategory.kidsWear:
        return Colors.green;
      case ProductCategory.formalWear:
        return Colors.indigo;
      case ProductCategory.casualWear:
        return Colors.orange;
      case ProductCategory.traditionalWear:
        return Colors.brown;
      case ProductCategory.alterations:
        return Colors.teal;
      case ProductCategory.customDesign:
        return Colors.purple;
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }
}

/// UnifiedProductCard is now imported from unified_product_card.dart

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ThemeProvider themeProvider;
  RangeValues _priceRange = const RangeValues(0, 5000);
  final List<String> _selectedBrands = [];
  final List<String> _selectedCategories = [];
  double _minRating = 0.0;
  bool _onlyNewArrivals = false;
  bool _onlyOnSale = false;
  bool _inStockOnly = false;
  String _selectedSort = 'name'; // Add sort selection

  final List<String> _brands = [
    'Nike',
    'Adidas',
    'Puma',
    'Levis',
    'Zara',
    'H&M'
  ];
  final List<String> _categories = [
    'Men\'s Wear',
    'Women\'s Wear',
    'Kids Wear',
    'Custom Design'
  ];

  final Map<String, String> _sortOptions = {
    'name': 'Name (A-Z)',
    'name_desc': 'Name (Z-A)',
    'price_asc': 'Price (Low to High)',
    'price_desc': 'Price (High to Low)',
    'rating': 'Rating (Highest)',
    'newest': 'Newest First',
  };

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: themeProvider.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  foregroundColor:
                      themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sort Options - Moved to Top
          _buildModernSortOptions(),

          const SizedBox(height: 24),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range Slider
                  _buildSectionHeader('Price Range'),
                  _buildPriceRange(),

                  const SizedBox(height: 24),

                  // Brands
                  _buildSectionHeader('Brands'),
                  _buildBrandChips(),

                  const SizedBox(height: 24),

                  // Categories
                  _buildSectionHeader('Categories'),
                  _buildCategoryChips(),

                  const SizedBox(height: 24),

                  // Rating Filter
                  _buildSectionHeader('Minimum Rating'),
                  _buildRatingFilter(),

                  const SizedBox(height: 24),

                  // Additional Filters
                  _buildSectionHeader('Additional Filters'),
                  _buildAdditionalFilters(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPriceRange() {
    return Column(
      children: [
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 5000,
          divisions: 50,
          labels: RangeLabels(
            '₹${_priceRange.start.round()}',
            '₹${_priceRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
          activeColor: Colors.orange,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${_priceRange.start.round()}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              Text(
                '₹${_priceRange.end.round()}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrandChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _brands.map((brand) {
        final isSelected = _selectedBrands.contains(brand);
        return FilterChip(
          label: Text(
            brand,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.black87,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedBrands.add(brand);
              } else {
                _selectedBrands.remove(brand);
              }
            });
          },
          backgroundColor:
              themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
          selectedColor: Colors.orange[100],
          checkmarkColor: Colors.orange,
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return FilterChip(
          label: Text(
            category,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.black87,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
          backgroundColor:
              themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
          selectedColor: Colors.orange[100],
          checkmarkColor: Colors.orange,
        );
      }).toList(),
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      children: [
        Slider(
          value: _minRating,
          min: 0,
          max: 5,
          divisions: 10,
          label: _minRating.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _minRating = value;
            });
          },
          activeColor: Colors.orange,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                '${_minRating.toStringAsFixed(1)}+ stars',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sort Header
        Row(
          children: [
            Icon(Icons.sort, size: 20, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Horizontal Scrollable Sort Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _sortOptions.entries.map((entry) {
              final isSelected = _selectedSort == entry.key;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSort = entry.key;
                      });
                    }
                  },
                  backgroundColor: themeProvider.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  selectedColor: Colors.orange,
                  elevation: isSelected ? 2 : 0,
                  pressElevation: 4,
                  checkmarkColor: Colors.white,
                  avatar: isSelected
                      ? const Icon(
                          Icons.sort,
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.orange : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Currently Selected Sort Indicator
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              const SizedBox(width: 28), // Align with icon space
              Text(
                'Currently: ${_sortOptions[_selectedSort] ?? 'Name (A-Z)'}',
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.isDarkMode
                      ? Colors.grey[400]
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalFilters() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('New Arrivals Only'),
          value: _onlyNewArrivals,
          onChanged: (value) {
            setState(() {
              _onlyNewArrivals = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('On Sale Only'),
          value: _onlyOnSale,
          onChanged: (value) {
            setState(() {
              _onlyOnSale = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('In Stock Only'),
          value: _inStockOnly,
          onChanged: (value) {
            setState(() {
              _inStockOnly = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 5000);
      _selectedBrands.clear();
      _selectedCategories.clear();
      _minRating = 0.0;
      _selectedSort = 'name';
      _onlyNewArrivals = false;
      _onlyOnSale = false;
      _inStockOnly = false;
    });
  }

  void _applyFilters() {
    // Here you would apply the filters to the product provider
    // For now, just close the sheet
    debugPrint('Applied filters:');
    debugPrint('Price range: ${_priceRange.start} - ${_priceRange.end}');
    debugPrint('Selected brands: $_selectedBrands');
    debugPrint('Selected categories: $_selectedCategories');
    debugPrint('Min rating: $_minRating');
    debugPrint('Selected sort: $_selectedSort');
    debugPrint('New arrivals only: $_onlyNewArrivals');
    debugPrint('On sale only: $_onlyOnSale');
    debugPrint('In stock only: $_inStockOnly');

    // Close the bottom sheet
    Navigator.of(context).pop();

    // Show a snackbar to confirm filters applied
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Types of empty states for better handling
enum EmptyStateType {
  noProducts,
  noSearchResults,
  noFilterResults,
}

/// Enhanced empty state with context-aware messaging and actions
class EnhancedEmptyState extends StatelessWidget {
  final String? searchQuery;
  final bool? hasActiveFilters;

  const EnhancedEmptyState({
    super.key,
    this.searchQuery,
    this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        debugPrint(
            'Theme provider status: darkMode=${themeProvider.isDarkMode}');
        final query = searchQuery ?? productProvider.searchQuery;
        final filters = hasActiveFilters ?? _hasActiveFilters(productProvider);

        return _buildEmptyState(context, query, filters, productProvider);
      },
    );
  }

  bool _hasActiveFilters(ProductProvider provider) {
    return provider.selectedCategory != null ||
        provider.priceRange != null ||
        provider.activeStatusFilter != null;
  }

  Widget _buildEmptyState(BuildContext context, String query, bool hasFilters,
      ProductProvider provider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final responsivePadding =
        ResponsiveUtils.getResponsiveInsets(context, 20.0);

    // Determine the type of empty state
    final EmptyStateType stateType = _getEmptyStateType(query, hasFilters);

    return Container(
      padding: responsivePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary)
                      .withValues(alpha: 26),
                  (themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary)
                      .withValues(alpha: 13),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForState(stateType),
              size: ResponsiveUtils.getResponsiveFontSize(context, 64),
              color: (themeProvider.isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary)
                  .withValues(alpha: 179),
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),

          // Title
          Text(
            _getTitleForState(stateType, query),
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),

          // Subtitle
          Text(
            _getSubtitleForState(stateType, query),
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              color: (themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface)
                  .withValues(alpha: 179),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),

          // Actions
          _buildActionsForState(context, stateType, provider),
        ],
      ),
    );
  }

  EmptyStateType _getEmptyStateType(String query, bool hasFilters) {
    if (hasFilters) return EmptyStateType.noFilterResults;
    if (query.isNotEmpty) return EmptyStateType.noSearchResults;
    return EmptyStateType.noProducts;
  }

  IconData _getIconForState(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.noSearchResults:
        return Icons.search_off;
      case EmptyStateType.noFilterResults:
        return Icons.filter_list_off;
      case EmptyStateType.noProducts:
        return Icons.inventory_2_outlined;
    }
  }

  String _getTitleForState(EmptyStateType type, String query) {
    switch (type) {
      case EmptyStateType.noSearchResults:
        return 'No results found';
      case EmptyStateType.noFilterResults:
        return 'No products match your filters';
      case EmptyStateType.noProducts:
        return 'No products found';
    }
  }

  String _getSubtitleForState(EmptyStateType type, String query) {
    switch (type) {
      case EmptyStateType.noSearchResults:
        return 'Try adjusting your search terms or check spelling';
      case EmptyStateType.noFilterResults:
        return 'Try changing your filter criteria to see more products';
      case EmptyStateType.noProducts:
        return 'Check back later for new arrivals';
    }
  }

  Widget _buildActionsForState(
      BuildContext context, EmptyStateType type, ProductProvider provider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final actions = <Widget>[];

    // Primary action
    switch (type) {
      case EmptyStateType.noSearchResults:
        actions.add(_buildActionButton(
          context,
          'Clear Search',
          Icons.clear,
          () => _clearSearch(context, provider),
          isPrimary: true,
        ));
        break;
      case EmptyStateType.noFilterResults:
        actions.add(_buildActionButton(
          context,
          'Clear Filters',
          Icons.filter_list_off,
          () => _clearFilters(context, provider),
          isPrimary: true,
        ));
        break;
      case EmptyStateType.noProducts:
        actions.add(_buildActionButton(
          context,
          'Refresh',
          Icons.refresh,
          () => _refreshProducts(context, provider),
          isPrimary: true,
        ));
    }

    // Secondary actions
    if (type != EmptyStateType.noProducts) {
      actions.add(const SizedBox(height: 12));
      actions.add(_buildActionButton(
        context,
        'Show All Products',
        Icons.inventory_2,
        () => _showAllProducts(context, provider),
        isPrimary: false,
      ));
    }

    return Column(
      children: actions,
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    required bool isPrimary,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: ResponsiveUtils.getResponsiveFontSize(context, 20.0),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16.0),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? (themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary)
              : Colors.transparent,
          foregroundColor: isPrimary
              ? (themeProvider.isDarkMode
                  ? DarkAppColors.onPrimary
                  : AppColors.onPrimary)
              : (themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary),
          side: isPrimary
              ? null
              : BorderSide(
                  color: (themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary)
                      .withValues(alpha: 77),
                ),
          padding: ResponsiveUtils.getResponsiveInsets(context, 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: isPrimary ? 2 : 0,
        ),
      ),
    );
  }

  void _clearSearch(BuildContext context, ProductProvider provider) {
    provider.searchProducts('');
    _showFeedback(context, 'Search cleared');
  }

  void _clearFilters(BuildContext context, ProductProvider provider) {
    provider.clearFilters();
    _showFeedback(context, 'Filters cleared');
  }

  void _refreshProducts(BuildContext context, ProductProvider provider) async {
    await provider.refreshProducts();
    _showFeedback(context, 'Products refreshed');
  }

  void _showAllProducts(BuildContext context, ProductProvider provider) {
    provider.clearFilters();
    _showFeedback(context, 'Showing all products');
  }

  void _showFeedback(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedSize;
  int quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          // Edit button for admin users
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final isShopOwnerOrAdmin = authProvider.isShopOwnerOrAdmin;
              final userRole = authProvider.userRole;

              if (isShopOwnerOrAdmin || userRole == UserRole.employee) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Product',
                  onPressed: () => _editProduct(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              final isInWishlist =
                  wishlistProvider.isProductInWishlist(widget.product.id);
              return IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : null,
                ),
                tooltip:
                    isInWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
                onPressed: () {
                  if (isInWishlist) {
                    wishlistProvider.removeFromWishlist(widget.product.id);
                  } else {
                    wishlistProvider.addToWishlist(widget.product.id);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if it's a wide screen (desktop/tablet landscape)
          final isWideScreen = constraints.maxWidth > 800;

          if (isWideScreen) {
            // Amazon/Flipkart style layout for wide screens
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Images (60% width)
                Expanded(
                  flex: 6,
                  child: _buildImageGallery(context, isWideScreen: true),
                ),
                // Right side - Product details (40% width)
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildProductDetails(context, isWideScreen: true),
                  ),
                ),
              ],
            );
          } else {
            // Mobile layout - stacked
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images at top
                  _buildImageGallery(context, isWideScreen: false),
                  // Details below
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildProductDetails(context, isWideScreen: false),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context,
      {required bool isWideScreen}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Combine images and videos for gallery
    final allMedia = <Map<String, dynamic>>[];

    // Add images
    for (final imageUrl in widget.product.imageUrls) {
      allMedia.add({'type': 'image', 'url': imageUrl});
    }

    // Add videos (placeholder for now - you can extend this)
    // For demo, we'll add some sample video URLs if they exist in product data
    if (widget.product.specifications.containsKey('videos')) {
      final videos =
          widget.product.specifications['videos'] as List<dynamic>? ?? [];
      for (final videoUrl in videos) {
        allMedia.add({'type': 'video', 'url': videoUrl.toString()});
      }
    }

    if (allMedia.isEmpty) {
      return Container(
        height: isWideScreen ? double.infinity : 400,
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Container(
      height: isWideScreen ? double.infinity : 400,
      color: isDarkMode ? Colors.black : Colors.white,
      child: Column(
        children: [
          // Main image/video display
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
              ),
              child: _buildMediaDisplay(
                  allMedia[_selectedImageIndex], isWideScreen),
            ),
          ),

          // Thumbnail strip
          if (allMedia.length > 1)
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allMedia.length,
                itemBuilder: (context, index) {
                  final media = allMedia[index];
                  final isSelected = index == _selectedImageIndex;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedImageIndex = index),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: media['type'] == 'video'
                            ? Container(
                                color: Colors.black,
                                child: const Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              )
                            : Image.network(
                                media['url'],
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stack) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaDisplay(Map<String, dynamic> media, bool isWideScreen) {
    final mediaType = media['type'];
    final url = media['url'];

    if (mediaType == 'video') {
      // Handle YouTube or other video links
      if (url.contains('youtube.com') || url.contains('youtu.be')) {
        return _buildYouTubeVideo(url, isWideScreen);
      } else {
        // Handle other video formats
        return Container(
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 64,
            ),
          ),
        );
      }
    } else {
      // Handle images
      return InteractiveViewer(
        minScale: 1.0,
        maxScale: 3.0,
        child: Image.network(
          url,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[100],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildYouTubeVideo(String url, bool isWideScreen) {
    // Extract YouTube video ID
    final videoId = _extractYouTubeVideoId(url);
    if (videoId == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Invalid YouTube URL',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // For now, show thumbnail with play button
    // In a real app, you'd integrate youtube_player_flutter or similar
    final thumbnailUrl =
        'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          thumbnailUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (ctx, error, stack) => Container(
            color: Colors.black,
            child: const Center(
              child: Text(
                'Video thumbnail not available',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 40,
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'YouTube',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  String? _extractYouTubeVideoId(String url) {
    // Extract video ID from various YouTube URL formats
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  Widget _buildProductDetails(BuildContext context,
      {required bool isWideScreen}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name and Rating
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.product.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isWideScreen ? 28 : 24,
                    ),
              ),
            ),
            if (isWideScreen) const SizedBox(width: 16),
            RatingStars(product: widget.product),
          ],
        ),

        const SizedBox(height: 16),

        // Brand
        if (widget.product.brand.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Brand: ${widget.product.brand}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Price Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PriceDisplay(product: widget.product),
              const SizedBox(height: 8),

              // Stock status
              Row(
                children: [
                  Icon(
                    widget.product.stockCount > 0
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: widget.product.stockCount > 0
                        ? Colors.green
                        : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.product.stockCount > 0
                        ? '${widget.product.stockCount} in stock'
                        : 'Out of stock',
                    style: TextStyle(
                      color: widget.product.stockCount > 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Delivery info
              if (widget.product.stockCount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_shipping,
                        size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Free delivery available',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Size Selection
        if (widget.product.availableSizes.isNotEmpty) ...[
          Text(
            'Select Size',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.product.availableSizes.map((size) {
              final isSelected = selectedSize == size;
              return ChoiceChip(
                label: Text(
                  size,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selectedSize = selected ? size : null;
                  });
                },
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                selectedColor: Colors.orange[100],
                checkmarkColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? Colors.orange : Colors.grey[300]!,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Quantity Selection
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed:
                    quantity > 1 ? () => setState(() => quantity--) : null,
                color: quantity > 1 ? Colors.orange : Colors.grey,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: quantity < widget.product.stockCount
                    ? () => setState(() => quantity++)
                    : null,
                color: quantity < widget.product.stockCount
                    ? Colors.orange
                    : Colors.grey,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Action Buttons
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _canAddToCart() ? _addToCart : null,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _canAddToCart() ? _buyNow : null,
              icon: const Icon(Icons.flash_on),
              label: const Text('Buy Now'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.orange),
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Product Description
        Text(
          'Product Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),

        // Additional product info
        if (widget.product.availableFabrics.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Available Fabrics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.product.availableFabrics.map((fabric) {
              return Chip(
                label: Text(fabric),
                backgroundColor:
                    isDarkMode ? Colors.grey[700] : Colors.blue[50],
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.blue[900],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  bool _canAddToCart() {
    return widget.product.stockCount > 0 &&
        (selectedSize != null || widget.product.availableSizes.isEmpty);
  }

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(
      widget.product,
      quantity: quantity,
      customizations: selectedSize != null ? {'size': selectedSize} : {},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('${widget.product.name} added to cart'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _buyNow() {
    // Implement buy now functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buy Now feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductEditScreen(product: widget.product),
      ),
    );
  }
}

class ProductEditScreen extends StatefulWidget {
  final Product? product;

  const ProductEditScreen({super.key, this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;
  late TextEditingController _brandController;

  bool _isActive = true;
  bool _isPopular = false;
  bool _isNewArrival = false;
  bool _isOnSale = false;
  List<String> _imageUrls = [];
  List<String> _availableSizes = [];
  List<String> _availableFabrics = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.basePrice.toString() ?? '');
    _stockController = TextEditingController(
        text: widget.product?.stockCount.toString() ?? '');
    _categoryController =
        TextEditingController(text: widget.product?.categoryName ?? '');
    _brandController = TextEditingController(text: widget.product?.brand ?? '');

    if (widget.product != null) {
      _isActive = widget.product!.isActive;
      _isPopular = widget.product!.isPopular;
      _isNewArrival = widget.product!.isNewArrival;
      _isOnSale = widget.product!.isOnSale;
      _imageUrls = List.from(widget.product!.imageUrls);
      _availableSizes = List.from(widget.product!.availableSizes);
      _availableFabrics = List.from(widget.product!.availableFabrics);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Text(
                'Basic Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Count',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter stock count';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Status Options
              Text(
                'Status',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),

              SwitchListTile(
                title: const Text('Popular'),
                value: _isPopular,
                onChanged: (value) => setState(() => _isPopular = value),
              ),

              SwitchListTile(
                title: const Text('New Arrival'),
                value: _isNewArrival,
                onChanged: (value) => setState(() => _isNewArrival = value),
              ),

              SwitchListTile(
                title: const Text('On Sale'),
                value: _isOnSale,
                onChanged: (value) => setState(() => _isOnSale = value),
              ),

              const SizedBox(height: 24),

              // Image URLs
              Text(
                'Image URLs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              ..._imageUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: url,
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final index = _imageUrls.indexOf(url);
                              _imageUrls[index] = value;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              setState(() => _imageUrls.remove(url)),
                        ),
                      ],
                    ),
                  )),

              ElevatedButton.icon(
                onPressed: () => setState(() => _imageUrls.add('')),
                icon: const Icon(Icons.add),
                label: const Text('Add Image URL'),
              ),

              const SizedBox(height: 24),

              // Available Sizes
              Text(
                'Available Sizes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                children: [
                  ..._availableSizes.map((size) => Chip(
                        label: Text(size),
                        onDeleted: () =>
                            setState(() => _availableSizes.remove(size)),
                      )),
                  ActionChip(
                    label: const Text('Add Size'),
                    onPressed: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) =>
                            const _AddItemDialog(title: 'Add Size'),
                      );
                      if (result != null && result.isNotEmpty) {
                        setState(() => _availableSizes.add(result));
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Available Fabrics
              Text(
                'Available Fabrics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                children: [
                  ..._availableFabrics.map((fabric) => Chip(
                        label: Text(fabric),
                        onDeleted: () =>
                            setState(() => _availableFabrics.remove(fabric)),
                      )),
                  ActionChip(
                    label: const Text('Add Fabric'),
                    onPressed: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) =>
                            const _AddItemDialog(title: 'Add Fabric'),
                      );
                      if (result != null && result.isNotEmpty) {
                        setState(() => _availableFabrics.add(result));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      basePrice: double.parse(_priceController.text),
      originalPrice: widget.product?.originalPrice,
      discountPercentage: widget.product?.discountPercentage,
      category: ProductCategory.values.firstWhere(
        (cat) => cat.name == _categoryController.text,
        orElse: () => ProductCategory.mensWear,
      ),
      brand: _brandController.text,
      imageUrls: _imageUrls.where((url) => url.isNotEmpty).toList(),
      specifications: {},
      availableSizes: _availableSizes,
      availableFabrics: _availableFabrics,
      customizationOptions: [],
      stockCount: int.parse(_stockController.text),
      soldCount: widget.product?.soldCount ?? 0,
      rating: widget.product?.rating ??
          ProductRating(averageRating: 0, reviewCount: 0, recentReviews: []),
      isActive: _isActive,
      isPopular: _isPopular,
      isNewArrival: _isNewArrival,
      isOnSale: _isOnSale,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    if (widget.product == null) {
      productProvider.addProduct(product);
    } else {
      productProvider.updateProduct(product);
    }

    Navigator.of(context).pop();
  }
}

class _AddItemDialog extends StatefulWidget {
  final String title;

  const _AddItemDialog({required this.title});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Enter ${widget.title.toLowerCase()}',
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
