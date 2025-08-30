import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/theme_constants.dart';
import '../cart/cart_screen.dart';

// Using beautiful theme-level opacity extensions
// No more deprecated withValues(alpha:) calls - everything uses withValues() internally
// ignore_for_file: deprecated_member_use

class ModernProductCatalogScreen extends StatefulWidget {
  const ModernProductCatalogScreen({super.key});

  @override
  State<ModernProductCatalogScreen> createState() => _ModernProductCatalogScreenState();
}

class _ModernProductCatalogScreenState extends State<ModernProductCatalogScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  late AnimationController _fabAnimationController;

  // Filter and sort states
  ProductCategory? _selectedCategory;
  String _selectedSort = 'name';
  RangeValues? _priceRange;

  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

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
    _fabAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductProvider, AuthProvider, ThemeProvider>(
      builder: (context, productProvider, authProvider, themeProvider, child) {
        final isShopOwner = authProvider.isShopOwnerOrAdmin;

        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Modern App Bar with Search
              _buildModernSliverAppBar(themeProvider, productProvider, isShopOwner),

              // Category Tabs
              _buildCategoryTabs(themeProvider),

              // Search Bar
              _buildSearchSliver(themeProvider),

              // Products Grid
              _buildProductsGrid(productProvider, themeProvider),
            ],
          ),

          // Modern FAB
          floatingActionButton: ScaleTransition(
            scale: _fabAnimationController,
            child: AnimatedBuilder(
              animation: _fabAnimationController,
              builder: (context, child) {
                return FloatingActionButton.extended(
                  onPressed: () => _showAddProductDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  backgroundColor: themeProvider.isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary,
                  foregroundColor: themeProvider.isDarkMode
                      ? DarkAppColors.onPrimary
                      : AppColors.onPrimary,
                  elevation: 8,
                  // Shadow color styling handled by elevation
                );
              },
            ),
          ),

          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildModernSliverAppBar(
    ThemeProvider themeProvider,
    ProductProvider productProvider,
    bool isShopOwner
  ) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      elevation: 0,
      backgroundColor: themeProvider.isDarkMode
          ? DarkAppColors.surface
          : AppColors.surface,

      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (themeProvider.isDarkMode
                      ? DarkAppColors.surface
                      : AppColors.surface)
                  .withValues(alpha: 0.95),
              themeProvider.isDarkMode
                  ? DarkAppColors.background
                  : AppColors.background,
            ],
          ),
        ),
      ),

      title: Text(
        'Discover Tailoring',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface
              : AppColors.onSurface,
        ),
      ),

      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode
                ? DarkAppColors.primary
                : AppColors.primary,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),

      actions: [
        // Cart Icon
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Stack(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_cart,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                    ),
                  ),
                  onPressed: () => _navigateToCart(context),
                  tooltip: 'View Cart',
                ),

                if (cartProvider.itemCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade500,
                            Colors.red.shade600,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
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

        // Filter Menu
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.filter_list,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
            ),
          ),
          onSelected: (value) {
            setState(() {
              _selectedSort = value;
            });
            productProvider.sortProducts(value);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'name',
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha, size: 18),
                  SizedBox(width: 8),
                  Text('Sort by Name'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'price_asc',
              child: Row(
                children: [
                  Icon(Icons.currency_rupee, size: 18),
                  SizedBox(width: 8),
                  Text('Price: Low to High'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'price_desc',
              child: Row(
                children: [
                  Icon(Icons.currency_rupee, size: 18),
                  SizedBox(width: 8),
                  Text('Price: High to Low'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'rating',
              child: Row(
                children: [
                  Icon(Icons.star_rate, size: 18),
                  SizedBox(width: 8),
                  Text('Sort by Rating'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTabs(ThemeProvider themeProvider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? DarkAppColors.surface.withValues(alpha: 0.9)
              : AppColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                : AppColors.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                (themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary)
                    .withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.7)
              : AppColors.onSurface.withValues(alpha: 0.7),
          tabs: [
            _buildModernTab('All', Icons.apps),
            _buildModernTab('Men\'s', Icons.person),
            _buildModernTab('Women\'s', Icons.person_2),
            _buildModernTab('Kids', Icons.child_care),
            _buildModernTab('Formal', Icons.business_center),
            _buildModernTab('Alterations', Icons.content_cut),
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
            setState(() {
              _selectedCategory = category;
            });
            Provider.of<ProductProvider>(context, listen: false)
                .filterByCategory(category);
          },
        ),
      ),
    );
  }

  Widget _buildModernTab(String text, IconData icon) {
    return Tab(
      height: 48,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSliver(ThemeProvider themeProvider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: Icon(
              Icons.search,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                  : AppColors.onSurface.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: themeProvider.isDarkMode
                ? DarkAppColors.surface.withValues(alpha: 0.8)
                : AppColors.surface.withValues(alpha: 0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                    : AppColors.onSurface.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                    : AppColors.onSurface.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
          onChanged: (query) {
            Provider.of<ProductProvider>(context, listen: false)
                .searchProducts(query);
          },
        ),
      ),
    );
  }

  Widget _buildProductsGrid(ProductProvider productProvider, ThemeProvider themeProvider) {
    if (productProvider.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Discovering amazing products...'),
              ],
            ),
          ),
        ),
      );
    }

    if (productProvider.products.isEmpty) {
      return _buildEmptyState(themeProvider);
    }

    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: productProvider.products.length,
      itemBuilder: (context, index) {
        return ModernProductCard(
          product: productProvider.products[index],
          index: index,
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return SliverToBoxAdapter(
      child: Container(
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
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary.withValues(alpha: 0.7)
                    : AppColors.primary.withValues(alpha: 0.7),
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
                    ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                    : AppColors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
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
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    // Navigate to add product screen or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Product feature coming soon!')),
    );
  }

  void _navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }
}

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

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_hoverController.value * 0.05),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                      : AppColors.onSurface.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: _hoverController.isAnimating
                    ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                    : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.surface.withValues(alpha: 0.95)
                        : AppColors.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                          : AppColors.onSurface.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.surface
                                    : AppColors.background,
                              ),
                              child: widget.product.imageUrls.isNotEmpty
                                  ? Image.network(
                                      widget.product.imageUrls.first,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: themeProvider.isDarkMode
                                              ? DarkAppColors.surface
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
                                              ? DarkAppColors.surface
                                              : AppColors.background,
                                          child: Icon(
                                            Icons.inventory_2,
                                            size: 48,
                                            color: themeProvider.isDarkMode
                                                ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                                : AppColors.onSurface.withValues(alpha: 0.3),
                                          ),
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.inventory_2,
                                      size: 48,
                                      color: themeProvider.isDarkMode
                                          ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                          : AppColors.onSurface.withValues(alpha: 0.3),
                                    ),
                            ),
                          ),

                          // Category Badge
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getCategoryColor(widget.product.category, themeProvider).withValues(alpha: 0.9),
                                    _getCategoryColor(widget.product.category, themeProvider),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.product.categoryName.length > 12
                                    ? '${widget.product.categoryName.substring(0, 12)}...'
                                    : widget.product.categoryName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // Edit Button (Shop Owner)
                          if (isShopOwner)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: themeProvider.isDarkMode
                                      ? DarkAppColors.primary
                                      : AppColors.primary,
                                ),
                              ),
                            ),

                          // Out of Stock Overlay
                          if (!widget.product.isActive)
                            Container(
                              color: Colors.black.withValues(alpha: 0.6),
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
                        ],
                      ),

                      // Product Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name
                              Text(
                                widget.product.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkMode
                                      ? DarkAppColors.onSurface
                                      : AppColors.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 8),

                              // Description Preview
                              Text(
                                widget.product.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: themeProvider.isDarkMode
                                      ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                      : AppColors.onSurface.withValues(alpha: 0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const Spacer(),

                              // Price and Cart Actions
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '₹${widget.product.basePrice.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.isDarkMode
                                            ? DarkAppColors.primary
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),

                                  // Add to Cart Button
                                  Material(
                                    color: themeProvider.isDarkMode
                                        ? DarkAppColors.primary
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: widget.product.isActive
                                          ? () => _addToCart(context)
                                          : null,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          isInCart ? Icons.shopping_cart : Icons.add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _addToCart(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final success = await cartProvider.addToCart(widget.product, quantity: 1);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${widget.product.name} added to cart!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Color _getCategoryColor(ProductCategory category, ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;

    switch (category) {
      case ProductCategory.mensWear:
        return isDark ? Colors.blue.shade500 : Colors.blue.shade600;
      case ProductCategory.womensWear:
        return isDark ? Colors.pink.shade500 : Colors.pink.shade600;
      case ProductCategory.kidsWear:
        return isDark ? Colors.orange.shade500 : Colors.orange.shade600;
      case ProductCategory.formalWear:
        return isDark ? Colors.purple.shade500 : Colors.purple.shade600;
      case ProductCategory.casualWear:
        return isDark ? Colors.green.shade500 : Colors.green.shade600;
      case ProductCategory.traditionalWear:
        return isDark ? Colors.indigo.shade500 : Colors.indigo.shade600;
      case ProductCategory.alterations:
        return isDark ? Colors.teal.shade500 : Colors.teal.shade600;
      case ProductCategory.customDesign:
        return isDark ? Colors.red.shade500 : Colors.red.shade600;
    }
  }
}