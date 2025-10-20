import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/product_models.dart';
import '../../../product_data_access.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme_constants.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/catalog/product_edit_screen.dart';
import 'catalog_bottom_sheets.dart';

// Utility functions for catalog operations

Color getProductColor(ProductCategory category) {
  switch (category) {
    case ProductCategory.mensWear:
      return Colors.blue;
    case ProductCategory.womensWear:
      return Colors.pink;
    case ProductCategory.kidsWear:
      return Colors.orange;
    case ProductCategory.formalWear:
      return Colors.indigo;
    case ProductCategory.casualWear:
      return Colors.green;
    case ProductCategory.alterations:
      return Colors.red;
    case ProductCategory.traditionalWear:
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

void navigateToEditProduct(BuildContext context, Product product) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductEditScreen(product: product),
    ),
  ).then((_) {
    // Refresh the product list after editing
    if (context.mounted) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    }
  });
}

void navigateToCart(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const CartScreen()),
  );
}

Future<void> addToCart(BuildContext context, Product product) async {
  try {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final success = await cartProvider.addToCart(product, quantity: 1);

    if (context.mounted) {
      if (success) {
        // Trigger refresh of cart state
        Provider.of<CartProvider>(context, listen: false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${product.name} added to cart!',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(cartProvider.errorMessage ?? 'Failed to add item to cart'),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      debugdebugPrint('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('An error occurred while adding to cart'),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const CatalogFilterBottomSheet(),
  );
}

void showSortBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const CatalogSortBottomSheet(),
  );
}

// Helper function to get responsive font size
double getResponsiveFontSize(double baseSize, BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 1200) return baseSize * 1.1;
  if (screenWidth >= 900) return baseSize * 1.05;
  if (screenWidth >= 600) return baseSize * 0.95;
  return baseSize * 0.9; // Mobile
}

// Helper function to get responsive padding
double getResponsivePadding(double basePadding, BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 1200) return basePadding * 1.2;
  if (screenWidth >= 900) return basePadding * 1.1;
  if (screenWidth >= 600) return basePadding * 0.95;
  return basePadding * 0.85; // Mobile
}

// Helper function to get responsive icon size
double getResponsiveIconSize(double baseSize, BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth >= 1200) return baseSize * 1.1;
  if (screenWidth >= 600) return baseSize;
  return baseSize * 0.9; // Mobile
}

// Format price with currency
String formatPrice(double price) {
  return 'â‚¹${price.toStringAsFixed(0)}';
}

// Get availability text based on stock
String getAvailabilityText(Product product) {
  if (!product.isActive) {
    return 'Inactive';
  }
  if (product.stockCount <= 0) {
    return 'Out of Stock';
  }
  if (product.stockCount < 10) {
    return 'Only ${product.stockCount} left';
  }
  return 'In Stock';
}

// Get availability color based on stock
Color getAvailabilityColor(Product product) {
  if (!product.isActive) {
    return Colors.grey;
  }
  if (product.stockCount <= 0) {
    return Colors.red;
  }
  if (product.stockCount < 10) {
    return Colors.orange;
  }
  return Colors.green;
}

// Common catalog widgets

class ProductStatsOverview extends StatelessWidget {
  const ProductStatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final totalProducts = productProvider.products.length;
        final activeProducts =
            productProvider.products.where((p) => p.isActive).length;
        final popularProducts =
            productProvider.products.where((p) => p.isPopular).length;
        final totalSold = productProvider.products
            .fold<int>(0, (sum, p) => sum + p.soldCount);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatChip(
                  '$totalProducts',
                  'Total Products',
                  Icons.inventory,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  '$activeProducts',
                  'Active',
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  '$popularProducts',
                  'Popular',
                  Icons.star,
                  Colors.amber,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  '$totalSold',
                  'Sold',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 100),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CatalogCategoryTab extends StatelessWidget {
  final String text;
  final IconData icon;

  const CatalogCategoryTab({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(minHeight: 48), // Ensure minimum touch target
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16), // Increased size for better visibility
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CatalogHeroBanner extends StatelessWidget {
  const CatalogHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          height: 200,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary)
                    .withValues(alpha: 0.8),
                (themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary)
                    .withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (themeProvider.isDarkMode
                        ? DarkAppColors.onSurface
                        : AppColors.onSurface)
                    .withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.star,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Flash Sale',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Up to 70% off on premium fashion',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to deals - filter by sale products
                        final productProvider = Provider.of<ProductProvider>(
                            context,
                            listen: false);
                        productProvider
                            .filterByCategory(null); // Clear category filter
                        // Could add a specific sale filter if needed
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Showing all products with deals!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag, size: 18),
                      label: const Text('Shop Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CatalogQuickActions extends StatelessWidget {
  const CatalogQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildQuickActionButton(
                context,
                Icons.favorite,
                'Wishlist',
                themeProvider,
                () => Navigator.pushNamed(context, '/wishlist'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                context,
                Icons.history,
                'Recently Viewed',
                themeProvider,
                () {
                  // Navigate to recently viewed - show a snackbar for now
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Recently viewed products feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                context,
                Icons.local_shipping,
                'Track Order',
                themeProvider,
                () {
                  // Navigate to orders - show a snackbar for now
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order tracking feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    ThemeProvider themeProvider,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? DarkAppColors.surface
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface)
                  .withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CatalogEmptyState extends StatelessWidget {
  const CatalogEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final responsivePadding = screenWidth < 600 ? 32.0 : 64.0;

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(responsivePadding),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (themeProvider.isDarkMode
                                ? DarkAppColors.primary
                                : AppColors.primary)
                            .withValues(alpha: 0.1),
                        (themeProvider.isDarkMode
                                ? DarkAppColors.primary
                                : AppColors.primary)
                            .withValues(alpha: 0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: (themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary)
                        .withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface
                        : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Try adjusting your search or category filter',
                  style: TextStyle(
                    fontSize: 16,
                    color: (themeProvider.isDarkMode
                            ? DarkAppColors.onSurface
                            : AppColors.onSurface)
                        .withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Provider.of<ProductProvider>(context, listen: false)
                        .filterByCategory(null);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Show All Products'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary,
                    foregroundColor: themeProvider.isDarkMode
                        ? DarkAppColors.onPrimary
                        : AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ActionButton extends StatelessWidget {
  final Product product;
  final bool isInCart;
  final VoidCallback onAddToCart;

  const ActionButton({
    super.key,
    required this.product,
    required this.isInCart,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;
    final isExtraSmall = screenWidth < 400; // For very constrained grid items

    return SizedBox(
      width: double.infinity,
      height: isExtraSmall ? 32 : (isSmall ? 36 : 40),
      child: InkWell(
        onTap: (product.isActive && product.stockCount > 0 && !isInCart)
            ? () {
                // Add subtle animation feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to cart'),
                    duration: const Duration(seconds: 1),
                  ),
                );
                onAddToCart();
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        splashColor: themeProvider.isDarkMode
            ? DarkAppColors.primary.withValues(alpha: 0.2)
            : AppColors.primary.withValues(alpha: 0.2),
        highlightColor: themeProvider.isDarkMode
            ? DarkAppColors.primary.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isInCart
                ? Colors.green
                : product.stockCount <= 0
                    ? Colors.grey.shade400
                    : (themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isInCart
                ? [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : product.stockCount <= 0
                    ? []
                    : [
                        BoxShadow(
                          color: (themeProvider.isDarkMode
                                  ? DarkAppColors.primary
                                  : AppColors.primary)
                              .withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
          ),
          child: Center(
            child: Text(
              isInCart
                  ? 'âœ“ Added'
                  : product.stockCount <= 0
                      ? 'Out of Stock'
                      : 'Add to Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: isExtraSmall ? 10 : (isSmall ? 11 : 12),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}



