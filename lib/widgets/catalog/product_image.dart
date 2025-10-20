import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product_models.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import 'price_display.dart';

class ProductImage extends StatelessWidget {
  final Product product;
  final bool isInWishlist;
  final VoidCallback onWishlistToggle;

  const ProductImage({
    super.key,
    required this.product,
    required this.isInWishlist,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxWidth *
              0.8, // Rectangular aspect ratio (4:5) for better space usage
          child: Container(
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.background
                  : AppColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image - No overflow possible
                Positioned.fill(
                  child: product.imageUrls.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.surface
                                  : AppColors.surface,
                              child: Icon(
                                Icons.inventory_2,
                                size: 32,
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                    : AppColors.onSurface.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.surface
                              : AppColors.surface,
                          child: Icon(
                            Icons.inventory_2,
                            size: 32,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                : AppColors.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                ),

                // Top Left: Badges - Responsive count based on screen size
                if (product.activeBadges.isNotEmpty)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Builder(
                      builder: (context) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final maxBadges = screenWidth > 600
                            ? 3
                            : 2; // More badges on larger screens
                        return Wrap(
                          spacing: 2,
                          runSpacing: 2,
                          children: product.activeBadges
                              .take(maxBadges)
                              .map((badge) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: _getBadgeColor(badge)
                                          .withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      badge,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ),

                // Top Right: Wishlist Button - Fixed size with animation
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: onWishlistToggle,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(isInWishlist),
                          color: isInWishlist ? Colors.red : Colors.grey[600],
                          size: 16,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),

                // Bottom Overlay: Essential Info Only - Compact
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: PriceDisplay(product: product),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'new':
      case 'new arrival':
        return Colors.blue;
      case 'bestseller':
      case 'best seller':
        return Colors.red;
      case 'sale':
      case 'flash sale':
      case 'clearance':
        return Colors.orange;
      case 'premium':
      case 'luxury':
        return Colors.purple;
      case 'limited':
      case 'limited stock':
        return Colors.amber;
      case 'top rated':
        return Colors.green;
      case 'trending':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}

