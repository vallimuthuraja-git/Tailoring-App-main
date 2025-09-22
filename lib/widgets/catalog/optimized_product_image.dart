import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/Provider.dart';
import '../../../models/product_models.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import 'price_display.dart';

/// Enhanced Optimized Product Image with Advanced Features
class OptimizedProductImage extends StatefulWidget {
  final Product product;
  final bool isInWishlist;
  final VoidCallback onWishlistToggle;
  final double? width;
  final double? height;
  final bool showWishlistButton;
  final bool showBadges;
  final bool showPriceOverlay;
  final BoxFit imageFit;
  final BorderRadiusGeometry? borderRadius;

  const OptimizedProductImage({
    super.key,
    required this.product,
    required this.isInWishlist,
    required this.onWishlistToggle,
    this.width,
    this.height,
    this.showWishlistButton = true,
    this.showBadges = true,
    this.showPriceOverlay = true,
    this.imageFit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<OptimizedProductImage> createState() => _OptimizedProductImageState();
}

class _OptimizedProductImageState extends State<OptimizedProductImage> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = widget.width ?? constraints.maxWidth;
        final containerHeight = widget.height ?? (constraints.maxWidth * 1.1);

        return AspectRatio(
          aspectRatio:
              1.1, // Slightly taller than square for better visual appeal
          child: Container(
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.background
                  : AppColors.background,
              borderRadius: widget.borderRadius ??
                  const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ENHANCED: Advanced Image Loading with Progressive Enhancement
                Positioned.fill(
                  child: _getImageWidget(
                      themeProvider, containerWidth, containerHeight),
                ),

                // Enhanced Badges - Smart positioning and adaptive count
                if (widget.showBadges && widget.product.activeBadges.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Builder(
                      builder: (context) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final maxBadges = _getResponsiveBadgeCount(screenWidth);
                        return Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: widget.product.activeBadges
                              .take(maxBadges)
                              .map((badge) =>
                                  _buildEnhancedBadge(badge, themeProvider))
                              .toList(),
                        );
                      },
                    ),
                  ),

                // Enhanced Wishlist Button - With ripple effect
                if (widget.showWishlistButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildEnhancedWishlistButton(),
                  ),

                // Smart Price Overlay - Conditional display
                if (widget.showPriceOverlay)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildSmartPriceOverlay(themeProvider),
                  ),

                // Loading overlay - Removed for cleaner grid view
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getImageWidget(
      ThemeProvider themeProvider, double width, double height) {
    if (widget.product.imageUrls.isEmpty) {
      return _buildEnhancedErrorWidget(themeProvider, width, height);
    }

    final imageUrl = widget.product.imageUrls.first;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ??
            const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ??
            const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
        child: Image.network(
          imageUrl,
          fit: widget.imageFit,
          width: width,
          height: height,
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
            return _buildEnhancedLoadingPlaceholder(
                themeProvider, width, height);
          },
          errorBuilder: (context, error, stackTrace) {
            // Defer setState to prevent "setState during build" error
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _hasError = true);
              }
            });
            return _buildEnhancedErrorWidget(themeProvider, width, height);
          },
        ),
      ),
    );
  }

  int _getResponsiveBadgeCount(double screenWidth) {
    if (screenWidth >= 1200) return 4; // Desktop
    if (screenWidth >= 900) return 3; // Large tablet
    if (screenWidth >= 600) return 2; // Tablet
    return 2; // Mobile
  }

  Widget _buildEnhancedBadge(String badge, ThemeProvider themeProvider) {
    final badgeColor = _getEnhancedBadgeColor(badge);
    final badgeText = _getBadgeText(badge);

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
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

  Widget _buildEnhancedWishlistButton() {
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

  Widget _buildSmartPriceOverlay(ThemeProvider themeProvider) {
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

  Widget _buildEnhancedLoadingPlaceholder(
    ThemeProvider themeProvider,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius: widget.borderRadius ??
            const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  Widget _buildEnhancedErrorWidget(
    ThemeProvider themeProvider,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius: widget.borderRadius ??
            const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
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

  Widget _buildProgressiveLoadingOverlay(
    ThemeProvider themeProvider,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface.withValues(alpha: 0.8)
            : AppColors.surface.withValues(alpha: 0.8),
        borderRadius: widget.borderRadius ??
            const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Color _getEnhancedBadgeColor(String badge) {
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
