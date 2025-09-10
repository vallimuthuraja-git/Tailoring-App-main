import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/theme_constants.dart';
import '../cart/cart_screen.dart';
import 'product_edit_screen.dart';
import 'product_detail_screen.dart';

// Modern Product Catalog Screen with Enhanced Dynamic Sizing
class ModernProductCatalogScreen extends StatefulWidget {
  const ModernProductCatalogScreen({super.key});

  @override
  State<ModernProductCatalogScreen> createState() => _ModernProductCatalogScreenState();
}

class _ModernProductCatalogScreenState extends State<ModernProductCatalogScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Load view mode preference
    _loadViewModePreference();

    // Load products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (productProvider.products.isEmpty) {
        _loadProducts();
      }
    });
  }

  Future<void> _loadProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadProducts();

    if (productProvider.products.isEmpty) {
      await productProvider.loadDemoData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadViewModePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isGridView = prefs.getBool('product_view_mode_grid') ?? false;
      });
    } catch (e) {
      debugPrint('Error loading view mode preference: $e');
    }
  }

  Future<void> _saveViewModePreference(bool isGrid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('product_view_mode_grid', isGrid);
    } catch (e) {
      debugPrint('Error saving view mode preference: $e');
    }
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
    _saveViewModePreference(_isGridView);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<ProductProvider, AuthProvider, ThemeProvider, CartProvider>(
      builder: (context, productProvider, authProvider, themeProvider, cartProvider, child) {
        final isShopOwner = authProvider.isShopOwnerOrAdmin;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: kToolbarHeight + 5,
            title: Center(
              child: SizedBox(
                height: 48,
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface
                        : AppColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withThemeOpacity(0.7)
                          : AppColors.onSurface.withThemeOpacity(0.7),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.onSurface.withThemeOpacity(0.7)
                                  : AppColors.onSurface.withThemeOpacity(0.7),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              productProvider.searchProducts('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withThemeOpacity(0.3)
                            : AppColors.onSurface.withThemeOpacity(0.3),
                      ),
                    ),
                    filled: true,
                    fillColor: themeProvider.isDarkMode
                        ? DarkAppColors.background
                        : AppColors.background,
                  ),
                  onChanged: (value) => productProvider.searchProducts(value),
                ),
              ),
            ),
            backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
            elevation: 0,
            iconTheme: IconThemeData(
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
            actions: [
              // View Toggle Button
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.view_list : Icons.grid_view,
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
                onPressed: _toggleViewMode,
                tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
              ),
              // Cart Icon with Badge
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                        onPressed: () => _navigateToCart(context),
                        tooltip: 'View Cart',
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              cartProvider.itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
                onPressed: () => _showFilterBottomSheet(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Category Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.surface.withThemeOpacity(0.8)
                      : AppColors.surface.withThemeOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withThemeOpacity(0.1)
                        : AppColors.onSurface.withThemeOpacity(0.1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                        (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withThemeOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withThemeOpacity(0.7)
                      : AppColors.onSurface.withThemeOpacity(0.7),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  tabs: [
                    _buildCategoryTab('All', Icons.apps),
                    _buildCategoryTab('Men\'s', Icons.person),
                    _buildCategoryTab('Women\'s', Icons.person_2),
                    _buildCategoryTab('Kids', Icons.child_care),
                    _buildCategoryTab('Formal', Icons.business_center),
                    _buildCategoryTab('Alterations', Icons.content_cut),
                  ],
                  onTap: (index) {
                    ProductCategory? category;
                    switch (index) {
                      case 1:
                        category = ProductCategory.mensWear;
                        break;
                      case 2:
                        category = ProductCategory.womensWear;
                        break;
                      case 3:
                        category = ProductCategory.kidsWear;
                        break;
                      case 4:
                        category = ProductCategory.formalWear;
                        break;
                      case 5:
                        category = ProductCategory.alterations;
                        break;
                      default:
                        category = null;
                    }
                    productProvider.filterByCategory(category);
                  },
                ),
              ),

              // Stats Overview
              _buildStatsOverview(),

              // Main Content
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width < 600 ? 90 : 80),
                  child: productProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : productProvider.products.isEmpty
                          ? _buildEmptyState(themeProvider)
                          : SafeArea(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                switchInCurve: Curves.easeInOut,
                                switchOutCurve: Curves.easeInOut,
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: _buildProductsList(productProvider, themeProvider),
                              ),
                            ),
                ),
              ),
            ],
          ),
          floatingActionButton: isShopOwner
              ? FloatingActionButton.extended(
                  onPressed: () => _navigateToAddProduct(context),
                  icon: const Icon(Icons.add_business),
                  label: const Text('Add Product'),
                  backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                  foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                )
              : null,
        );
      },
    );
  }

  Widget _buildCategoryTab(String text, IconData icon) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductProvider productProvider, ThemeProvider themeProvider) {
    if (productProvider.isLoading) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Discovering amazing products...'),
          ],
        ),
      );
    }

    if (productProvider.products.isEmpty) {
      return _buildEmptyState(themeProvider);
    }

    if (_isGridView) {
      // Grid View with Enhanced Constraints
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      int crossAxisCount = 2; // Default for mobile
      if (screenWidth >= 1200) {
        crossAxisCount = 4; // Large desktop
      } else if (screenWidth >= 900) {
        crossAxisCount = 3; // Tablet/desktop
      } else if (screenWidth >= 600) {
        crossAxisCount = 3; // Small desktop
      }

      // Calculate responsive grid items per row and column
      final int totalProducts = productProvider.products.length;
      final int maxRowsVisible = screenWidth < 600 ? 4 : screenWidth < 1200 ? 5 : 6;
      final int maxItemsVisible = crossAxisCount * maxRowsVisible;
      final int effectiveItemCount = totalProducts > maxItemsVisible ? maxItemsVisible : totalProducts;

      // Constrain grid height based on screen size and content
      final double baseItemHeight = screenWidth < 600 ? 300 : screenWidth < 1200 ? 340 : 380;
      final double gridHeight = baseItemHeight * (effectiveItemCount / crossAxisCount).ceil();

      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: gridHeight.clamp(200, screenHeight * 0.7),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: screenWidth < 600 ? 8 : 12,
            mainAxisSpacing: screenWidth < 600 ? 8 : 12,
            childAspectRatio: screenWidth < 600 ? 0.65 : screenWidth < 1200 ? 0.72 : 0.75,
          ),
          itemCount: totalProducts,
          itemBuilder: (context, index) {
            final product = productProvider.products[index];
            return ModernProductCard(product: product, index: index);
          },
        ),
      );
    } else {
      // List View
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: productProvider.products.length,
        itemBuilder: (context, index) {
          final product = productProvider.products[index];
          return _buildProductCard(product);
        },
      );
    }
  }

  Widget _buildProductCard(Product product) {
    return Consumer3<ProductProvider, ThemeProvider, CartProvider>(
      builder: (context, productProvider, themeProvider, cartProvider, child) {
        final isShopOwner = Provider.of<AuthProvider>(context).isShopOwnerOrAdmin;
        final isInCart = cartProvider.isInCart(product.id);

        // Get responsive text sizes
        final screenWidth = MediaQuery.of(context).size.width;
        double getResponsiveFontSize(double baseSize) {
          if (screenWidth >= 1200) return baseSize * 1.1;
          if (screenWidth >= 900) return baseSize * 1.05;
          if (screenWidth >= 600) return baseSize * 0.95;
          return baseSize * 0.9;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Product Image/Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getProductColor(product.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getProductColor(product.category).withOpacity(0.3),
                          ),
                        ),
                        child: product.imageUrls.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.imageUrls.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.inventory_2,
                                      color: _getProductColor(product.category),
                                      size: 24,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.inventory_2,
                                color: _getProductColor(product.category),
                                size: 24,
                              ),
                      ),
                      const SizedBox(width: 12),

                      // Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (product.brand.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      product.brand,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.purple[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: product.isActive ? Colors.green[100] : Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    product.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: product.isActive ? Colors.green[800] : Colors.red[800],
                                    ),
                                  ),
                                ),
                                if (product.isOnSale) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Sale',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Price and Rating
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${product.basePrice.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.averageRating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Product Stats
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${product.stockCount} in stock',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (product.isPopular) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Popular',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      if (isShopOwner) ...[
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.primary
                                : AppColors.primary,
                            size: 16,
                          ),
                          onPressed: () => _navigateToEditProduct(product, context),
                        ),
                        const SizedBox(width: 8),
                      ],
                      ElevatedButton.icon(
                        onPressed: (product.isActive && product.stockCount > 0 && !isInCart)
                            ? () => _addToCart(product, context)
                            : null,
                        icon: Icon(
                          isInCart ? Icons.check_circle : Icons.add,
                          size: 16,
                        ),
                        label: Text(
                          isInCart ? 'In Cart' :
                          product.stockCount <= 0 ? 'Out of Stock' : 'Add to Cart',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: isInCart ? Colors.green :
                                             product.stockCount <= 0 ? Colors.grey : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getProductColor(ProductCategory category) {
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

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(64),
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
                      .withThemeOpacity(0.1),
                  (themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary)
                      .withThemeOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary.withThemeOpacity(0.7)
                  : AppColors.primary.withThemeOpacity(0.7),
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
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withThemeOpacity(0.6)
                  : AppColors.onSurface.withThemeOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _tabController.animateTo(0);
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final totalProducts = productProvider.products.length;
        final activeProducts = productProvider.products.where((p) => p.isActive).length;
        final popularProducts = productProvider.products.where((p) => p.isPopular).length;
        final totalSold = productProvider.products.fold<int>(0, (sum, p) => sum + p.soldCount);

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

  Widget _buildStatChip(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
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

  void _navigateToEditProduct(Product product, BuildContext context) {
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

  void _navigateToAddProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductEditScreen(),
      ),
    ).then((_) {
      // Refresh products after returning from edit screen
      _loadProducts();
    });
  }

  void _navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  void _addToCart(Product product, BuildContext context) async {
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
              content: Text(cartProvider.errorMessage ?? 'Failed to add item to cart'),
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
        debugPrint('Error adding to cart: $e');
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ProductFilterBottomSheet(),
    );
  }
}

// Enhanced Modern Product Card with Dynamic Sizing
class ModernProductCard extends StatefulWidget {
  final Product product;
  final int index;

  const ModernProductCard({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  State<ModernProductCard> createState() => _ModernProductCardState();
}

class _ModernProductCardState extends State<ModernProductCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isShopOwner = authProvider.isShopOwnerOrAdmin;
    final isInCart = cartProvider.isInCart(widget.product.id);

    // Content density analysis for dynamic sizing
    final bool hasBrand = widget.product.brand.isNotEmpty;
    final bool hasRating = widget.product.rating.averageRating > 0;
    final bool hasPromotion = widget.product.originalPrice != null && widget.product.savingsAmount > 0;

    // Get responsive text sizes based on screen width
    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsiveFontSize(double baseSize) {
      if (screenWidth >= 1200) return baseSize * 1.1;
      if (screenWidth >= 900) return baseSize * 1.05;
      if (screenWidth >= 600) return baseSize * 0.95;
      return baseSize * 0.9; // Mobile
    }

    double getResponsivePadding(double basePadding) {
      if (screenWidth >= 1200) return basePadding * 1.2;
      if (screenWidth >= 900) return basePadding * 1.1;
      if (screenWidth >= 600) return basePadding * 0.95;
      return basePadding * 0.85; // Mobile
    }

    double getResponsiveIconSize(double baseSize) {
      if (screenWidth >= 1200) return baseSize * 1.1;
      if (screenWidth >= 600) return baseSize;
      return baseSize * 0.9; // Mobile
    }

    // Dynamic min height based on content density and screen size
    double getMinHeight() {
      double baseHeight = screenWidth >= 1200 ? 400 : screenWidth >= 900 ? 380 : screenWidth >= 600 ? 340 : 300;
      double contentBonus = (hasBrand ? 1 : 0) + (hasRating ? 1 : 0) + (hasPromotion ? 1 : 0);
      contentBonus *= screenWidth >= 600 ? 20 : 15;
      return baseHeight + contentBonus;
    }

    // Dynamic spacing based on content availability
    double getContentSpacing(bool isCompact) {
      double baseSpacing = getResponsivePadding(8);
      if (isCompact) return baseSpacing * 0.6; // Compact spacing for minimal content
      return baseSpacing;
    }

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0,
          child: Container(
            constraints: BoxConstraints(
              minHeight: getMinHeight(),
              maxWidth: screenWidth >= 600 ? 400 : double.infinity,
            ),
            margin: EdgeInsets.symmetric(
              vertical: getResponsivePadding(4),
              horizontal: getResponsivePadding(2),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.product.stockCount <= 0 ? Colors.red.shade100 :
                        widget.product.isOnSale ? Colors.green.shade100 :
                        themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withThemeOpacity(0.08)
                      : AppColors.onSurface.withThemeOpacity(0.08),
                  blurRadius: screenWidth < 600 ? 6 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.surface
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.product.stockCount <= 0 ? Colors.red.shade300 :
                        widget.product.isOnSale ? Colors.green.shade300 :
                        themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withThemeOpacity(0.1)
                      : AppColors.onSurface.withThemeOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image with Enhanced Badges
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.background
                                : AppColors.background,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: widget.product.imageUrls.isNotEmpty
                              ? Image.network(
                                  widget.product.imageUrls.first,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: themeProvider.isDarkMode
                                          ? DarkAppColors.background
                                          : AppColors.background,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            themeProvider.isDarkMode
                                                ? DarkAppColors.primary
                                                : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: themeProvider.isDarkMode
                                          ? DarkAppColors.background
                                          : AppColors.background,
                                      child: Icon(
                                        Icons.inventory_2,
                                        size: getResponsiveIconSize(48),
                                        color: themeProvider.isDarkMode
                                            ? DarkAppColors.onSurface.withThemeOpacity(0.3)
                                            : AppColors.onSurface.withThemeOpacity(0.3),
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
                                    size: getResponsiveIconSize(48),
                                    color: themeProvider.isDarkMode
                                        ? DarkAppColors.onSurface.withThemeOpacity(0.3)
                                        : AppColors.onSurface.withThemeOpacity(0.3),
                                  ),
                                ),
                        ),
                      ),

                      // Enhanced Badge System with Anti-Overflow Protection
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.product.activeBadges.take(2).map((badge) =>
                            Container(
                              margin: EdgeInsets.only(bottom: getResponsivePadding(4)),
                              padding: EdgeInsets.symmetric(
                                horizontal: getResponsivePadding(6),
                                vertical: getResponsivePadding(3),
                              ),
                              decoration: BoxDecoration(
                                color: _getBadgeColor(badge),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withThemeOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              constraints: BoxConstraints(maxWidth: screenWidth >= 600 ? 100 : 70),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: getResponsiveFontSize(9),
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ).toList(),
                        ),
                      ),

                      // Fast Delivery Badge with Anti-Overlap
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(getResponsivePadding(4)),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.green.shade600],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withThemeOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: getResponsiveIconSize(14),
                          ),
                        ),
                      ),

                      // Out of Stock Overlay
                      if (!widget.product.isActive || widget.product.stockCount <= 0)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withThemeOpacity(0.6),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Out of Stock',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                      // Edit Button (Shop Owner only) - Safe Positioned
                      if (isShopOwner)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(getResponsivePadding(6)),
                            decoration: BoxDecoration(
                              color: Colors.white.withThemeOpacity(0.95),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withThemeOpacity(0.15),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: getResponsiveIconSize(16),
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.primary
                                    : AppColors.primary,
                              ),
                              onPressed: () => _navigateToEditProduct(context),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minWidth: getResponsiveIconSize(24),
                                minHeight: getResponsiveIconSize(24),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Product Details Section with Optimized Spacing
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(getResponsivePadding(screenWidth >= 600 ? 14 : 12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Brand Name with Enhanced Safe Truncation
                          if (widget.product.brand.isNotEmpty) ...[
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth >= 600 ? 280 : screenWidth * 0.58,
                              ),
                              child: Text(
                                widget.product.brand,
                                style: TextStyle(
                                  fontSize: getResponsiveFontSize(11),
                                  color: themeProvider.isDarkMode
                                      ? DarkAppColors.primary
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: getContentSpacing(false)),
                          ],

                          // Product Name with Better Visual Layout Control
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth >= 600 ? 280 : screenWidth * 0.58,
                              minHeight: screenWidth < 600 ? getResponsiveFontSize(16) : getResponsiveFontSize(32),
                            ),
                            child: Text(
                              widget.product.name,
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(14),
                                fontWeight: FontWeight.w700,
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.onSurface
                                    : AppColors.onSurface,
                                height: 1.2,
                              ),
                              maxLines: screenWidth < 600 ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Rating Stars with Improved Overflow Protection
                          if (widget.product.rating.averageRating > 0) ...[
                            SizedBox(height: getContentSpacing(hasBrand ? false : true)),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth >= 600 ? 140 : screenWidth * 0.35,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Star Rating with Fixed Number
                                  Row(
                                    children: List.generate(5, (index) {
                                      double rating = widget.product.rating.averageRating;
                                      if (index < rating.floor()) {
                                        return Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: getResponsiveIconSize(12),
                                        );
                                      } else if (index < rating) {
                                        return Icon(
                                          Icons.star_half,
                                          color: Colors.amber,
                                          size: getResponsiveIconSize(12),
                                        );
                                      } else {
                                        return Icon(
                                          Icons.star_border,
                                          color: Colors.grey,
                                          size: getResponsiveIconSize(12),
                                        );
                                      }
                                    }),
                                  ),
                                  SizedBox(width: getResponsivePadding(4)),
                                  Flexible(
                                    child: Text(
                                      '${widget.product.rating.averageRating.toStringAsFixed(1)} (${widget.product.rating.reviewCount})',
                                      style: TextStyle(
                                        fontSize: getResponsiveFontSize(10),
                                        color: themeProvider.isDarkMode
                                            ? DarkAppColors.onSurface.withThemeOpacity(0.8)
                                            : AppColors.onSurface.withThemeOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Stock Status with Improved Color Indicator
                          SizedBox(height: getContentSpacing(!hasRating && !hasBrand)),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth >= 600 ? 180 : screenWidth * 0.35,
                            ),
                            child: Text(
                              widget.product.availabilityText,
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(10),
                                color: widget.product.availabilityColor,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Spacer replaced with flexible spacing
                          SizedBox(
                            height: screenWidth < 600 ? 4 : 8,
                            width: double.infinity,
                          ),

                          // Pricing Section with Safe Layout
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Current Price with Bold Styling
                              Text(
                                widget.product.formattedPrice,
                                style: TextStyle(
                                  fontSize: getResponsiveFontSize(16),
                                  fontWeight: FontWeight.w800,
                                  color: themeProvider.isDarkMode
                                      ? DarkAppColors.onSurface
                                      : AppColors.onSurface,
                                ),
                              ),

                              // Original Price and Savings - Constrained Layout
                              if (widget.product.originalPrice != null && widget.product.savingsAmount > 0) ...[
                                SizedBox(height: getResponsivePadding(2)),
                                SizedBox(
                                  width: double.infinity,
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: getResponsivePadding(6),
                                    runSpacing: getResponsivePadding(2),
                                    children: [
                                      // Crossed-out Original Price
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: screenWidth >= 600 ? 100 : screenWidth * 0.25,
                                        ),
                                        child: Text(
                                          widget.product.formattedOriginalPrice,
                                          style: TextStyle(
                                            fontSize: getResponsiveFontSize(12),
                                            color: themeProvider.isDarkMode
                                                ? DarkAppColors.onSurface.withThemeOpacity(0.6)
                                                : AppColors.onSurface.withThemeOpacity(0.6),
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),

                                    // Savings Amount with Improved Sizing
                                    Flexible(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          minWidth: screenWidth >= 600 ? 60 : 50,
                                          maxWidth: screenWidth >= 600 ? 90 : 75,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: getResponsivePadding(6),
                                          vertical: getResponsivePadding(3),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Save ₹${widget.product.savingsAmount.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: getResponsiveFontSize(10),
                                              color: Colors.green.shade800,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),

                          SizedBox(height: getContentSpacing(false)),

                          // Full-Width Add to Cart Button with Enhanced Constraints
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight: getResponsivePadding(32),
                            ),
                            child: ElevatedButton(
                              onPressed: (widget.product.isActive && widget.product.stockCount > 0 && !isInCart)
                                  ? () => _addToCart(context)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInCart ? Colors.green :
                                               widget.product.stockCount <= 0 ? Colors.grey :
                                               (widget.product.isActive ? (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary) : Colors.grey.shade400),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: getResponsivePadding(10),
                                  horizontal: getResponsivePadding(12),
                                ),
                                disabledBackgroundColor: Colors.grey.shade400,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: double.infinity,
                                  minHeight: getResponsivePadding(14),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isInCart ? Icons.check_circle :
                                      widget.product.stockCount <= 0 ? Icons.block : Icons.add_shopping_cart,
                                      size: getResponsiveIconSize(14),
                                    ),
                                    SizedBox(width: getResponsivePadding(6)),
                                    Flexible(
                                      child: Text(
                                        isInCart ? 'Added to Cart' :
                                        widget.product.stockCount <= 0 ? 'Out of Stock' : 'Add to Cart',
                                        style: TextStyle(
                                          fontSize: getResponsiveFontSize(11),
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
      },
    );
  }

  void _navigateToEditProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductEditScreen(product: widget.product),
      ),
    ).then((_) {
      // Refresh the product list after editing
      if (context.mounted) {
        Provider.of<ProductProvider>(context, listen: false).loadProducts();
      }
    });
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

  void _addToCart(BuildContext context) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      final success = await cartProvider.addToCart(widget.product, quantity: 1);

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
                      '${widget.product.name} added to cart!',
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
              content: Text(cartProvider.errorMessage ?? 'Failed to add item to cart'),
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
        debugPrint('Error adding to cart: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred while adding to cart'),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}

// Enhanced Product Filter Bottom Sheet
class ProductFilterBottomSheet extends StatefulWidget {
  const ProductFilterBottomSheet({super.key});

  @override
  State<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 10000);
  ProductCategory? _selectedCategory;
  bool? _activeStatusFilter;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsivePadding(double basePadding) {
      if (screenWidth >= 1200) return basePadding * 1.2;
      if (screenWidth >= 900) return basePadding * 1.1;
      if (screenWidth >= 600) return basePadding * 0.95;
      return basePadding * 0.85;
    }

    double getResponsiveFontSize(double baseSize) {
      if (screenWidth >= 1200) return baseSize * 1.1;
      if (screenWidth >= 900) return baseSize * 1.05;
      if (screenWidth >= 600) return baseSize * 0.95;
      return baseSize * 0.9;
    }

    return Container(
      padding: EdgeInsets.all(getResponsivePadding(20)),
      constraints: BoxConstraints(
        maxHeight: screenWidth < 600 ? MediaQuery.of(context).size.height * 0.7 : 500,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                  size: getResponsiveFontSize(24),
                ),
                SizedBox(width: getResponsivePadding(12)),
                Text(
                  'Filter Products',
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(20),
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface
                        : AppColors.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: getResponsivePadding(20)),

            // Price Range
            Text(
              'Price Range',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: getResponsiveFontSize(16),
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface,
              ),
            ),
            SizedBox(height: getResponsivePadding(12)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: getResponsivePadding(16)),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.surface.withThemeOpacity(0.5)
                    : AppColors.surface.withThemeOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withThemeOpacity(0.2)
                      : AppColors.onSurface.withThemeOpacity(0.2),
                ),
              ),
              child: RangeSlider(
                values: _priceRange,
                min: 0,
                max: 10000,
                divisions: 100,
                labels: RangeLabels(
                  '₹${_priceRange.start.toInt()}',
                  '₹${_priceRange.end.toInt()}',
                ),
                activeColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                inactiveColor: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withThemeOpacity(0.3)
                    : AppColors.onSurface.withThemeOpacity(0.3),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
            ),

            SizedBox(height: getResponsivePadding(20)),

            // Category Filter
            Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: getResponsiveFontSize(16),
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface,
              ),
            ),
            SizedBox(height: getResponsivePadding(12)),
            Wrap(
              spacing: getResponsivePadding(8),
              runSpacing: getResponsivePadding(8),
              children: [
                _buildCategoryFilterChip('All', null),
                _buildCategoryFilterChip('Men\'s Wear', ProductCategory.mensWear),
                _buildCategoryFilterChip('Women\'s Wear', ProductCategory.womensWear),
                _buildCategoryFilterChip('Kids Wear', ProductCategory.kidsWear),
                _buildCategoryFilterChip('Formal Wear', ProductCategory.formalWear),
                _buildCategoryFilterChip('Alterations', ProductCategory.alterations),
              ],
            ),

            SizedBox(height: getResponsivePadding(20)),

            // Status Filter
            Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: getResponsiveFontSize(16),
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface,
              ),
            ),
            SizedBox(height: getResponsivePadding(12)),
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: const Text('Active Only'),
                    selected: _activeStatusFilter == true,
                    onSelected: (selected) {
                      setState(() {
                        _activeStatusFilter = selected ? true : null;
                      });
                    },
                  ),
                ),
                SizedBox(width: getResponsivePadding(12)),
                Expanded(
                  child: FilterChip(
                    label: const Text('All Products'),
                    selected: _activeStatusFilter == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _activeStatusFilter = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: getResponsivePadding(24)),

            // Apply and Reset Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withThemeOpacity(0.3)
                            : AppColors.onSurface.withThemeOpacity(0.3),
                      ),
                      padding: EdgeInsets.symmetric(vertical: getResponsivePadding(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(16),
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface
                            : AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: getResponsivePadding(12)),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _applyFilters(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                      foregroundColor: themeProvider.isDarkMode
                          ? DarkAppColors.onPrimary
                          : AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: getResponsivePadding(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChip(String label, ProductCategory? category) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsivePadding(double basePadding) {
      if (screenWidth >= 1200) return basePadding * 1.2;
      if (screenWidth >= 900) return basePadding * 1.1;
      if (screenWidth >= 600) return basePadding * 0.95;
      return basePadding * 0.85;
    }

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: screenWidth < 600 ? 12 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: _selectedCategory == category,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 10000);
      _selectedCategory = null;
      _activeStatusFilter = null;
    });
  }

  void _applyFilters(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    // Apply all filters
    if (_selectedCategory != null) {
      productProvider.filterByCategory(_selectedCategory);
    } else {
      productProvider.filterByCategory(null); // Show all
    }

    if (_activeStatusFilter != null) {
      // Filter by active status if needed
      // This would require additional implementation in ProductProvider
    }

    Navigator.pop(context);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Filters applied successfully!',
                  style: TextStyle(fontSize: 14),
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
    }
  }
}
