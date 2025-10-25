import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_models.dart';
import '../../providers/theme_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../screens/catalog/product_detail_screen.dart';
import '../../utils/theme_constants.dart';
import '../../utils/responsive_utils.dart';

/// Simple Modern Product Card - Layout-Safe Implementation
/// Clean, performant design with proper error handling
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
    return AspectRatio(
      aspectRatio: aspectRatio!,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap ?? () => _navigateToProduct(context),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section (60% of height)
              Expanded(
                flex: 6,
                child: _buildImageSection(context),
              ),
              // Content Section (40% of height)
              Expanded(
                flex: 4,
                child: _buildContentSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Product Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: product.imageUrls.isNotEmpty
              ? Hero(
                  tag: 'product_${product.id}_$index',
                  child: Image.network(
                    product.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stack) =>
                        _buildImageFallback(context),
                  ),
                )
              : _buildImageFallback(context),
        ),

        // Wishlist Button
        Positioned(
          top: 8,
          right: 8,
          child: _buildWishlistButton(context),
        ),

        // Sale Badge
        if (product.originalPrice != null &&
            product.originalPrice! > product.basePrice)
          Positioned(
            bottom: 8,
            left: 8,
            child: _buildSaleBadge(),
          ),

        // Stock Badge
        if (product.stockCount <= 5)
          Positioned(
            top: 8,
            left: 8,
            child: _buildStockBadge(),
          ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          if (product.brand.isNotEmpty) ...[
            Text(
              product.brand.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
          ],

          // Product Name
          Expanded(
            child: Text(
              product.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 4),

          // Price
          _buildPriceSection(themeProvider),

          // Rating (if available)
          if (showRating && product.rating.averageRating > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, size: 12, color: Colors.amber.shade600),
                const SizedBox(width: 2),
                Text(
                  product.rating.averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                        : AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSection(ThemeProvider themeProvider) {
    final hasDiscount = product.originalPrice != null &&
        product.originalPrice! > product.basePrice;

    return hasDiscount
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                product.formattedPrice,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                product.formattedOriginalPrice,
                style: TextStyle(
                  fontSize: 11,
                  decoration: TextDecoration.lineThrough,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                      : AppColors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          )
        : Text(
            product.formattedPrice,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
            ),
          );
  }

  Widget _buildImageFallback(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildWishlistButton(BuildContext context) {
    final isInWishlist = context.select<ProductProvider, bool>(
      (provider) => provider.isProductInWishlist(product.id),
    );

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () => _toggleWishlist(context),
        icon: Icon(
          isInWishlist ? Icons.favorite : Icons.favorite_border,
          size: 18,
          color: isInWishlist ? Colors.red.shade600 : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildSaleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${product.savingsPercentage}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: product.stockCount == 0
            ? Colors.red.shade600
            : Colors.orange.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        product.stockCount == 0 ? 'Out of Stock' : 'Low Stock',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
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
        content: Text(
          isNowInWishlist ? 'Added to wishlist' : 'Removed from wishlist',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
