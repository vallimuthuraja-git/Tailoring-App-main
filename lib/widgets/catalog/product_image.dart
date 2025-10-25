import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../models/product_models.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import 'price_display.dart';
import 'product_card_config.dart';

/// Unified Product Image Widget - Grid-safe and configurable
/// Combines features from ProductImage and OptimizedProductImage
/// without LayoutBuilder to prevent grid rendering issues
class ProductImage extends StatefulWidget {
  final Product product;
  final bool isInWishlist;
  final VoidCallback onWishlistToggle;
  final ProductCardConfig config;
  final double? aspectRatio;
  final BoxFit imageFit;
  final BorderRadiusGeometry? borderRadius;

  const ProductImage({
    super.key,
    required this.product,
    required this.isInWishlist,
    required this.onWishlistToggle,
    this.config = const ProductCardConfig(
      displayMode: CardDisplayMode.compact,
      actionButtonMode: ActionButtonMode.single,
      badgeDisplayMode: BadgeDisplayMode.none,
      showBrand: false,
      showRating: false,
      showDeliveryInfo: false,
      showCustomizationIndicator: false,
      showHeroAnimation: true,
    ),
    this.aspectRatio = 1.0, // Square by default for grid compatibility
    this.imageFit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AspectRatio(
      aspectRatio: widget.aspectRatio!,
      child: Container(
        decoration: BoxDecoration(
          color: widget.config.customBackgroundColor ??
              (themeProvider.isDarkMode
                  ? DarkAppColors.background
                  : AppColors.background),
          borderRadius: widget.borderRadius ??
              BorderRadius.circular(widget.config.customBorderRadius ?? 12.0),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Enhanced Image Loading with Progressive Enhancement
            Positioned.fill(
              child: _getImageWidget(themeProvider),
            ),

            // Configurable Badges
            if (_shouldShowBadges())
              Positioned(
                top: 8,
                left: 8,
                child: _buildBadgeRow(themeProvider),
              ),

            // Configurable Wishlist Button
            if (_shouldShowWishlist())
              Positioned(
                top: 8,
                right: 8,
                child: _buildWishlistButton(),
              ),

            // Smart Price Overlay
            if (widget.config.displayMode != CardDisplayMode.minimal)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildPriceOverlay(themeProvider),
              ),

            // Loading overlay - only show if needed
            if (_isLoading && !_hasError)
              Positioned.fill(
                child: _buildLoadingOverlay(themeProvider),
              ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowBadges() {
    switch (widget.config.badgeDisplayMode) {
      case BadgeDisplayMode.none:
        return false;
      case BadgeDisplayMode.stockOnly:
        return widget.product.activeBadges.any((badge) =>
            badge.toLowerCase().contains('stock') ||
            badge.toLowerCase().contains('limited') ||
            badge.toLowerCase().contains('sold'));
      case BadgeDisplayMode.allBadges:
        return widget.product.activeBadges.isNotEmpty;
      case BadgeDisplayMode.custom:
        return widget.config.customBadges?.isNotEmpty ?? false;
      default:
        return true;
    }
  }

  bool _shouldShowWishlist() {
    return widget.config.actionButtonMode != ActionButtonMode.none;
  }

  Widget _getImageWidget(ThemeProvider themeProvider) {
    // Data validation: Check for null/empty image URLs
    if (widget.product.imageUrls.isEmpty ||
        widget.product.imageUrls.first.isEmpty) {
      _hasError = true;
      _isLoading = false;
      return _buildErrorWidget(themeProvider);
    }

    final imageUrl = widget.product.imageUrls.first.trim();
    // Additional validation: Check for valid URL format (basic check)
    if (!imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://') &&
        !imageUrl.startsWith('data:')) {
      _hasError = true;
      _isLoading = false;
      return _buildErrorWidget(themeProvider);
    }

    return ClipRRect(
      borderRadius: widget.borderRadius ??
          BorderRadius.circular(widget.config.customBorderRadius ?? 12.0),
      child: Image.network(
        imageUrl,
        fit: widget.imageFit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            // Defer setState to prevent "setState during build" error
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            });
            return child;
          }
          _isLoading = true;
          return _buildLoadingPlaceholder(themeProvider);
        },
        errorBuilder: (context, error, stackTrace) {
          // Defer setState to prevent "setState during build" error
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          });
          return _buildErrorWidget(themeProvider);
        },
      ),
    );
  }

  Widget _buildBadgeRow(ThemeProvider themeProvider) {
    final badgesToShow = _getDisplayBadges();
    if (badgesToShow.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final maxBadges = _getResponsiveBadgeCount(screenWidth);

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: badgesToShow
          .take(maxBadges)
          .map((badge) => _buildBadge(badge, themeProvider))
          .toList(),
    );
  }

  List<String> _getDisplayBadges() {
    if (widget.config.badgeDisplayMode == BadgeDisplayMode.custom) {
      return widget.config.customBadges ?? [];
    }
    return widget.product.activeBadges;
  }

  int _getResponsiveBadgeCount(double screenWidth) {
    if (screenWidth >= 1200) return 4; // Desktop
    if (screenWidth >= 900) return 3; // Large tablet
    if (screenWidth >= 600) return 2; // Tablet
    return 2; // Mobile
  }

  Widget _buildBadge(String badge, ThemeProvider themeProvider) {
    final badgeColor = _getBadgeColor(badge);
    final badgeText = _getBadgeText(badge);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor,
            badgeColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        badgeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _getBadgeText(String badge) {
    switch (badge.toLowerCase()) {
      case 'new':
        return 'NEW';
      case 'new arrival':
        return 'NEW';
      case 'bestseller':
        return 'BEST';
      case 'best seller':
        return 'BEST';
      case 'sale':
        return 'SALE';
      case 'flash sale':
        return 'FLASH';
      case 'clearance':
        return 'CLEAR';
      case 'premium':
        return 'PREM';
      case 'limited':
        return 'LIMITED';
      case 'limited stock':
        return 'LOW STOCK';
      case 'top rated':
        return 'TOP';
      case 'trending':
        return 'HOT';
      default:
        return badge.toUpperCase();
    }
  }

  Widget _buildWishlistButton() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: widget.onWishlistToggle,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Icon(
              widget.isInWishlist ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(widget.isInWishlist),
              color: widget.isInWishlist ? Colors.red : Colors.grey[600],
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceOverlay(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.85),
            Colors.black.withValues(alpha: 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: PriceDisplay(product: widget.product),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface.withValues(alpha: 0.7)
            : AppColors.surface.withValues(alpha: 0.7),
        borderRadius: widget.borderRadius ??
            BorderRadius.circular(widget.config.customBorderRadius ?? 12.0),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ThemeProvider themeProvider) {
    return Container(
      color:
          themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
    );
  }

  Widget _buildErrorWidget(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius: widget.borderRadius ??
            BorderRadius.circular(widget.config.customBorderRadius ?? 12.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.4)
                  : AppColors.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(
                fontSize: 10,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                    : AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'new':
      case 'new arrival':
        return Colors.blue;
      case 'bestseller':
      case 'best seller':
        return Colors.deepOrange;
      case 'sale':
      case 'flash sale':
      case 'clearance':
        return Colors.red;
      case 'premium':
      case 'luxury':
        return Colors.purple;
      case 'limited':
      case 'limited stock':
        return Colors.orange;
      case 'top rated':
        return Colors.green;
      case 'trending':
        return Colors.pink;
      case 'hot':
        return Colors.redAccent;
      default:
        return Colors.teal;
    }
  }
}
