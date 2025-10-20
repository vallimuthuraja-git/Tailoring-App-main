
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_models.dart';
import '../../providers/theme_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../screens/catalog/product_detail_screen.dart';
import '../../utils/theme_constants.dart';
import '../../utils/responsive_utils.dart';
import 'product_card_config.dart';

// Add import for post-frame callback

/// Unified Product Card - Clean, Maintainable, and Layout-Safe
/// Consolidates the best features from all existing implementations
/// while fixing layout issues and preventing overlapping elements
class UnifiedProductCard extends StatelessWidget {
  final Product product;
  final int index;
  final bool showHeroAnimation;
  final ProductCardConfig? config;
  final VoidCallback? onTap;

  const UnifiedProductCard({
    super.key,
    required this.product,
    required this.index,
    this.showHeroAnimation = true,
    this.config,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final themeProvider = Provider.of<ThemeProvider>(context);
      final deviceCategory =
          ResponsiveUtils.getDeviceCategory(MediaQuery.of(context).size.width);

      return LayoutBuilder(
        builder: (context, constraints) {
          try {
            // Get effective configuration (provided or default)
            final effectiveConfig = config ?? ProductCardConfig.standard();

            final layoutConfig = _calculateLayoutConfig(
              context,
              constraints,
              effectiveConfig,
            );

            return Container(
              margin: layoutConfig.margin,
              child: _buildCardContent(context, layoutConfig, effectiveConfig),
            );
          } catch (e) {
            // Fallback layout if layout calculation fails
            return _buildFallbackLayout(context, themeProvider, constraints);
          }
        },
      );
    } catch (e) {
      // Ultimate fallback if any provider or context issue occurs
      return _buildUltimateFallback(context);
    }
  }

  Widget _buildCardContent(
    BuildContext context,
    LayoutConfig layoutConfig,
    ProductCardConfig productConfig,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Use selectors for better performance
    final isInCart = context.select<CartProvider, bool>(
      (provider) => provider.isInCart(product.id),
    );

    final isInWishlist = context.select<ProductProvider, bool>(
      (provider) => provider.isProductInWishlist(product.id),
    );

    // Add overflow detection with safe exception handling (only if enabled)
    if (productConfig.enableOverflowProtection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null && renderBox.attached) {
            final size = renderBox.size;
            final screenWidth = MediaQuery.of(context).size.width;
            final expectedMaxHeight = layoutConfig.totalHeight +
                (layoutConfig.margin is EdgeInsets
                    ? (layoutConfig.margin as EdgeInsets).vertical
                    : 0);

            final hasOverflow =
                size.height > expectedMaxHeight || size.width > screenWidth;

            // DEBUG LOGGING: Overflow detection
            debugPrint(
              '[UnifiedProductCard] Render Size: ${size.width.toInt()}x${size.height.toInt()}px',
            );
            debugPrint(
              '[UnifiedProductCard] Expected Max: ${screenWidth.toInt()}x${expectedMaxHeight.toInt()}px',
            );

            if (hasOverflow) {
              debugPrint(
                'ðŸš¨ [UnifiedProductCard] OVERFLOW DETECTED! Content exceeds allocated space',
              );
              debugPrint(
                'ðŸš¨ [UnifiedProductCard] Height overflow: ${(size.height - expectedMaxHeight).toInt()}px',
              );
            } else {
              debugPrint('âœ… [UnifiedProductCard] No overflow detected');
            }
          }
        } catch (e) {
          // Safe exception handling for debug logging
          debugPrint('[UnifiedProductCard] Debug logging error: $e');
        }
      });
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: SizedBox(
        height: layoutConfig.totalHeight,
        width: double.infinity,
        child: Material(
          color: productConfig.customBackgroundColor ??
              (themeProvider.isDarkMode
                  ? DarkAppColors.surface
                  : AppColors.surface),
          elevation: layoutConfig.elevation,
          borderRadius: BorderRadius.circular(layoutConfig.borderRadius),
          shadowColor: themeProvider.isDarkMode
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.15),
          child: InkWell(
            onTap: onTap ?? () => _safeNavigateToDetail(context),
            borderRadius: BorderRadius.circular(layoutConfig.borderRadius),
            splashColor: themeProvider.isDarkMode
                ? DarkAppColors.primary.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            highlightColor: themeProvider.isDarkMode
                ? DarkAppColors.primary.withValues(alpha: 0.05)
                : AppColors.primary.withValues(alpha: 0.05),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(layoutConfig.borderRadius),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.outline.withValues(alpha: 0.08)
                      : AppColors.outline.withValues(alpha: 0.06),
                  width: 0.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    themeProvider.isDarkMode
                        ? DarkAppColors.surface
                        : AppColors.surface,
                    themeProvider.isDarkMode
                        ? DarkAppColors.surfaceContainerHighest
                            .withValues(alpha: 0.3)
                        : AppColors.surfaceContainerHighest
                            .withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fixed height image section with improved styling
                  _buildImageSection(
                    context,
                    themeProvider,
                    isInWishlist,
                    layoutConfig,
                    productConfig,
                  ),

                  // Content section with better spacing
                  _buildContentSection(
                    context,
                    themeProvider,
                    isInCart,
                    layoutConfig,
                    productConfig,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isInWishlist,
    LayoutConfig layoutConfig,
    ProductCardConfig productConfig,
  ) {
    return SizedBox(
      height:
          layoutConfig.imageHeight, // Use height from config for consistency
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? DarkAppColors.surfaceContainerHighest
              : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(layoutConfig.borderRadius),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Product image with proper error handling
            product.imageUrls.isNotEmpty
                ? _buildProductImage()
                : _buildNoImagePlaceholder(themeProvider),

            // Wishlist button - positioned safely
            Positioned(
              top: 8,
              right: 8,
              child: _buildWishlistButton(context, isInWishlist),
            ),

            // Stock indicator if needed
            if (product.stockCount <= 5 && product.stockCount > 0)
              Positioned(
                bottom: 8,
                left: 8,
                child: _buildStockBadge(themeProvider),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Hero(
      tag: showHeroAnimation
          ? 'product_image_${product.id}_$index'
          : 'static_${product.id}_$index',
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
        child: Image.network(
          product.imageUrls.first,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.isDarkMode
                ? DarkAppColors.surfaceContainerHighest.withValues(alpha: 0.6)
                : AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
            themeProvider.isDarkMode
                ? DarkAppColors.surface
                : AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                : AppColors.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                  : AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 48,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildWishlistButton(BuildContext context, bool isInWishlist) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      width: 44, // Minimum touch target for accessibility
      height: 44, // Minimum touch target for accessibility
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface.withValues(alpha: 0.9)
            : AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.outline.withValues(alpha: 0.3)
              : AppColors.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: () => _toggleWishlist(context),
        icon: Icon(
          isInWishlist ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: isInWishlist
              ? Colors.red.shade500
              : themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildStockBadge(ThemeProvider themeProvider) {
    final isLowStock = product.stockCount <= 2;
    final badgeColor = isLowStock ? Colors.red : Colors.orange;
    final textColor = isLowStock ? Colors.red.shade700 : Colors.orange.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.shade200, width: 1),
      ),
      child: Text(
        product.stockCount <= 0 ? 'Out of Stock' : 'Low Stock',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isInCart,
    LayoutConfig layoutConfig,
    ProductCardConfig productConfig,
  ) {
    // Dynamic content prioritization based on available height
    final contentConfig = _calculateContentDisplayConfig(
      layoutConfig.contentAreaHeight,
    );

    return Container(
      height: layoutConfig.contentAreaHeight,
      padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 0.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: layoutConfig.contentAreaHeight,
            maxHeight: double.infinity,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand indicator (if enabled and brand exists)
              if (productConfig.showBrand && product.brand.isNotEmpty)
                _buildBrandIndicator(themeProvider),

              // Product name with improved text wrapping
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                  height: 1.2,
                ),
                maxLines: contentConfig.titleMaxLines,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),

              const SizedBox(height: 3),

              // Price section
              _buildPriceSection(themeProvider),

              const SizedBox(height: 3),

              // Rating if available and configured to show
              if (contentConfig.showRating && product.rating.averageRating > 0)
                _buildRatingSection(themeProvider),

              // Customization indicator
              if (productConfig.showCustomizationIndicator &&
                  product.customizationOptions.isNotEmpty)
                _buildCustomizationIndicator(themeProvider),

              // Badges section
              if (productConfig.badgeDisplayMode != BadgeDisplayMode.none)
                _buildBadgesSection(context, themeProvider),

              // Delivery indicator
              if (productConfig.showDeliveryInfo)
                _buildDeliveryIndicator(themeProvider),

              // Action button - always visible but scaled
              if (contentConfig.showActionButton)
                _buildActionButton(
                  context,
                  themeProvider,
                  isInCart,
                  productConfig,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection(ThemeProvider themeProvider) {
    final hasDiscount = product.originalPrice != null &&
        product.originalPrice! > product.basePrice;

    if (!hasDiscount) {
      return Text(
        product.formattedPrice,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: themeProvider.isDarkMode
              ? DarkAppColors.primary
              : AppColors.primary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current price
        Text(
          product.formattedPrice,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: themeProvider.isDarkMode
                ? DarkAppColors.primary
                : AppColors.primary,
          ),
        ),

        // Original price with strikethrough
        Text(
          product.formattedOriginalPrice,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                : AppColors.onSurface.withValues(alpha: 0.5),
            decoration: TextDecoration.lineThrough,
          ),
        ),

        // Discount percentage
        Container(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200, width: 1),
          ),
          child: Text(
            '-${product.savingsPercentage}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(ThemeProvider themeProvider) {
    return Row(
      children: [
        Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade600),
        const SizedBox(width: 4),
        Text(
          product.rating.averageRating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isInCart,
    ProductCardConfig productConfig,
  ) {
    // Handle different action button modes
    switch (productConfig.actionButtonMode) {
      case ActionButtonMode.none:
        return const SizedBox.shrink();

      case ActionButtonMode.dual:
        return _buildDualActionButtons(context, isInCart);

      case ActionButtonMode.wishlistOnly:
        return _buildWishlistOnlyButton(context, themeProvider);

      case ActionButtonMode.single:
      default:
        return _buildSingleActionButton(context, isInCart);
    }
  }

  Widget _buildSingleActionButton(BuildContext context, bool isInCart) {
    // Ensure minimum touch target of 44px (accessibility standard)
    return SizedBox(
      width: double.infinity,
      height: 44, // Minimum touch target height
      child: ElevatedButton.icon(
        onPressed: () => _addToCart(context),
        icon: Icon(
          isInCart ? Icons.check_circle : Icons.add_shopping_cart,
          size: 18,
        ),
        label: Text(
          isInCart ? 'IN CART' : 'ADD TO CART',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isInCart ? Colors.green.shade600 : const Color(0xFFFF9F00),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          minimumSize: const Size(double.infinity, 44), // Explicit minimum size
        ),
      ),
    );
  }

  Widget _buildDualActionButtons(BuildContext context, bool isInCart) {
    // Ensure minimum touch targets: 44px mobile, 48px desktop
    // Use IntrinsicWidth to allow buttons to size themselves while respecting constraints
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ADD TO CART button
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: () => _addToCart(context),
              icon: Icon(
                isInCart ? Icons.check_circle : Icons.add_shopping_cart,
                size: 16,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isInCart ? 'IN CART' : 'ADD TO CART',
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F00), // #ff9f00
                foregroundColor: Colors.white,
                elevation: 0.0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                minimumSize: const Size(0, 44),
              ),
            ),
          ),
          const SizedBox(width: 6.0),
          // BUY NOW button
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: () => _buyNow(context),
              icon: Icon(Icons.flash_on, size: 16),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: const Text(
                  'BUY NOW',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFB641B), // #fb641b
                foregroundColor: Colors.white,
                elevation: 0.0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                minimumSize: const Size(0, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistOnlyButton(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final isInWishlist = context.select<ProductProvider, bool>(
      (provider) => provider.isProductInWishlist(product.id),
    );

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () => _toggleWishlist(context),
        icon: Icon(
          isInWishlist ? Icons.favorite : Icons.favorite_border,
          size: 18,
        ),
        label: Text(
          isInWishlist ? 'IN WISHLIST' : 'ADD TO WISHLIST',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isInWishlist ? Colors.red.shade600 : Colors.grey.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          minimumSize: const Size(double.infinity, 44),
        ),
      ),
    );
  }

  // New widget builders for enhanced features
  Widget _buildBrandIndicator(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.secondaryContainer
            : AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        product.brand.toUpperCase(),
        style: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.w700,
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSecondaryContainer
              : AppColors.onSecondaryContainer,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCustomizationIndicator(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.primaryContainer
            : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        'Custom',
        style: TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.w500,
          color: themeProvider.isDarkMode
              ? DarkAppColors.onPrimaryContainer
              : AppColors.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildBadgesSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final badges = product.activeBadges.take(2);
    final stockStatus = _getStockStatus();

    if (badges.isEmpty && stockStatus == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Wrap(
        spacing: 4.0,
        runSpacing: 2.0,
        children: [
          if (stockStatus != null) stockStatus,
          ...badges.map(
            (badge) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.secondaryContainer
                    : AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSecondaryContainer
                      : AppColors.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryIndicator(ThemeProvider themeProvider) {
    // Simple delivery indicator - in real app, this would come from product data
    final deliveryTime = product.stockCount > 0 ? '2-3 days' : 'Out of stock';

    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 12.0,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                : AppColors.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 3.0),
          Text(
            deliveryTime,
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _getStockStatus() {
    if (product.stockCount <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.red.shade200, width: 0.5),
        ),
        child: Text(
          'Out of Stock',
          style: TextStyle(
            fontSize: 9.0,
            fontWeight: FontWeight.w700,
            color: Colors.red.shade700,
            letterSpacing: 0.2,
          ),
        ),
      );
    } else if (product.stockCount <= 5) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.orange.shade200, width: 0.5),
        ),
        child: Text(
          'Low Stock',
          style: TextStyle(
            fontSize: 9.0,
            fontWeight: FontWeight.w700,
            color: Colors.orange.shade700,
            letterSpacing: 0.2,
          ),
        ),
      );
    }

    return null; // In stock, no badge needed
  }

  LayoutConfig _calculateLayoutConfig(
    BuildContext context,
    BoxConstraints constraints,
    ProductCardConfig productConfig,
  ) {
    final deviceCategory = ResponsiveUtils.getDeviceCategory(
      MediaQuery.of(context).size.width,
    );

    return LayoutConfig.calculate(
      constraints: constraints,
      deviceCategory: deviceCategory,
      cardConfig: productConfig,
    );
  }

  void _navigateToDetail(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open product details'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _addToCart(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleWishlist(BuildContext context) {
    final wishlistProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    wishlistProvider.toggleWishlist(product.id);

    final isNowInWishlist = wishlistProvider.isProductInWishlist(product.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowInWishlist ? 'Added to wishlist' : 'Removed from wishlist',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _buyNow(BuildContext context) {
    // Navigate to checkout or handle buy now logic
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buy Now functionality - Coming Soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Safe navigation with error handling
  void _safeNavigateToDetail(BuildContext context) {
    try {
      _navigateToDetail(context);
    } catch (e) {
      // Show error message instead of crashing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open product details'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Fallback layout when layout calculation fails
  Widget _buildFallbackLayout(BuildContext context, ThemeProvider themeProvider,
      BoxConstraints constraints) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      height: constraints.maxHeight.isFinite ? constraints.maxHeight : 200.0,
      child: Material(
        elevation: 2.0,
        borderRadius: BorderRadius.circular(12.0),
        color: themeProvider.isDarkMode
            ? const Color(0xFF1E1E1E) // DarkAppColors.surface equivalent
            : const Color(0xFFFFFFFF), // AppColors.surface equivalent
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 32,
                color: themeProvider.isDarkMode
                    ? const Color(0xFFCF6679) // DarkAppColors.error equivalent
                    : Colors.red,
              ),
              const SizedBox(height: 8),
              Text(
                'Display Error',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode
                      ? const Color(
                          0xFFE0E0E0) // DarkAppColors.onSurface equivalent
                      : const Color(
                          0xFF1C1B1F), // AppColors.onSurface equivalent
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.isDarkMode
                      ? const Color(
                          0xFFB0B0B0) // DarkAppColors.onSurface with opacity
                      : const Color(
                          0xFF49454F), // AppColors.onSurface with opacity
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ultimate fallback when even providers fail
  Widget _buildUltimateFallback(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      height: 200.0,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 32, color: Colors.orange),
            SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

ContentDisplayConfig _calculateContentDisplayConfig(double availableHeight) {
  // DEBUG LOGGING: Content display configuration
  debugPrint(
    '[UnifiedProductCard] Content Area Height: ${availableHeight.toInt()}px',
  );

  // Dynamic content prioritization based on available height
  if (availableHeight >= 120) {
    // Plenty of space - show everything
    debugPrint(
      '[UnifiedProductCard] Content Config: Plenty of space (>=120px) - Title:3 lines, Rating:YES, Action:YES',
    );
    return const ContentDisplayConfig(
      titleMaxLines: 3,
      showRating: true,
      showActionButton: true,
    );
  } else if (availableHeight >= 90) {
    // Moderate space - show most content
    debugPrint(
      '[UnifiedProductCard] Content Config: Moderate space (90-119px) - Title:2 lines, Rating:YES, Action:YES',
    );
    return const ContentDisplayConfig(
      titleMaxLines: 2,
      showRating: true,
      showActionButton: true,
    );
  } else if (availableHeight >= 70) {
    // Limited space - essential content only
    debugPrint(
      '[UnifiedProductCard] Content Config: Limited space (70-89px) - Title:2 lines, Rating:NO, Action:YES',
    );
    return const ContentDisplayConfig(
      titleMaxLines: 2,
      showRating: false,
      showActionButton: true,
    );
  } else {
    // Very limited space - critical content only
    debugPrint(
      '[UnifiedProductCard] Content Config: Very limited space (<70px) - Title:1 line, Rating:NO, Action:YES',
    );
    return const ContentDisplayConfig(
      titleMaxLines: 1,
      showRating: false,
      showActionButton: true,
    );
  }
}

/// Configuration class for the unified product card
class CardConfig {
  final EdgeInsets margin;
  final double elevation;
  final double borderRadius;
  final double totalHeight;
  final double imageHeight;
  final double contentAreaHeight;

  const CardConfig({
    required this.margin,
    required this.elevation,
    required this.borderRadius,
    required this.totalHeight,
    required this.imageHeight,
    required this.contentAreaHeight,
  });
}

/// Configuration for dynamic content display based on available height
class ContentDisplayConfig {
  final int titleMaxLines;
  final bool showRating;
  final bool showActionButton;

  const ContentDisplayConfig({
    required this.titleMaxLines,
    required this.showRating,
    required this.showActionButton,
  });
}
