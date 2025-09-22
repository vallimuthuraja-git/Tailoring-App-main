import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../utils/responsive_utils.dart';
import '../../../../models/product_models.dart';

class FeaturedContent extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onProductTap;

  const FeaturedContent({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  State<FeaturedContent> createState() => _FeaturedContentState();
}

class _FeaturedContentState extends State<FeaturedContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onBackground
                      : AppColors.onBackground,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all featured products
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.products.isEmpty)
            _buildEmptyState(context, themeProvider)
          else
            _buildCarousel(context, themeProvider),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.2)
              : AppColors.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: const Center(
        child: Text('No featured products available'),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.products.length,
            itemBuilder: (context, index) {
              final product = widget.products[index];
              return _FeaturedProductCard(
                product: product,
                onTap: () => widget.onProductTap(product),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.products.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? (themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary)
                    : (themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                        : AppColors.onSurface.withValues(alpha: 0.3)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _FeaturedProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsiveFontSize(double baseSize) {
      if (screenWidth >= 1200) return baseSize * 1.1;
      if (screenWidth >= 900) return baseSize * 1.05;
      if (screenWidth >= 600) return baseSize * 0.95;
      return baseSize * 0.9;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.isDarkMode
                  ? DarkAppColors.surface
                  : AppColors.surface,
              themeProvider.isDarkMode
                  ? DarkAppColors.background
                  : AppColors.background,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Product Image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: product.imageUrls.isNotEmpty
                    ? Image.network(
                        product.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.background
                                : AppColors.background,
                            child: Icon(
                              Icons.inventory_2,
                              size: 48,
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.onSurface
                                      .withValues(alpha: 0.5)
                                  : AppColors.onSurface.withValues(alpha: 0.5),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.background
                            : AppColors.background,
                        child: Icon(
                          Icons.inventory_2,
                          size: 48,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                              : AppColors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
              ),
            ),

            // Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: getResponsiveFontSize(18),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.basePrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: getResponsiveFontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Featured badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Featured',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getResponsiveFontSize(10),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
