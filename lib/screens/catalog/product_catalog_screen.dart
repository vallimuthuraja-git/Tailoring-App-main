import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/theme_constants.dart';
import '../orders/order_creation_wizard.dart';
import '../cart/cart_screen.dart';
import 'product_edit_screen.dart';

// Using beautiful theme-level opacity extensions
// No more deprecated withValues(alpha:) calls - everything uses withValues() internally
// ignore_for_file: deprecated_member_use

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _searchFocusNode = FocusNode();

    // Add focus listener
    _searchFocusNode.addListener(() {
      setState(() {});
    });

    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadProducts();

    // If no products exist, load demo data
    if (productProvider.products.isEmpty) {
      await productProvider.loadDemoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductProvider, AuthProvider, ThemeProvider>(
      builder: (context, productProvider, authProvider, themeProvider, child) {
        final isShopOwner = authProvider.isShopOwnerOrAdmin;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: kToolbarHeight + 5,
            title: Center(
              child: SizedBox(
                height: 48,
                width: MediaQuery.of(context).size.width * 0.85,
                child: SearchAnchor(
                  builder: (BuildContext context, SearchController controller) {
                    return SearchBar(
                      controller: controller,
                      elevation: const WidgetStatePropertyAll<double>(0),
                      padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      onTap: () {
                        controller.openView();
                      },
                      onChanged: (_) {
                        controller.openView();
                      },
                      hintText: 'Search',
                      hintStyle: WidgetStatePropertyAll<TextStyle>(
                        TextStyle(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                              : AppColors.onSurface.withValues(alpha: 0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      textStyle: WidgetStatePropertyAll<TextStyle>(
                        TextStyle(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface
                              : AppColors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      trailing: [
                        Icon(
                          Icons.search,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.8)
                              : AppColors.onSurface.withValues(alpha: 0.8),
                          size: 20,
                        ),
                      ],
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        themeProvider.isDarkMode
                            ? DarkAppColors.surface.withValues(alpha: 0.9)
                            : AppColors.surface.withValues(alpha: 0.9),
                      ),
                      surfaceTintColor: WidgetStatePropertyAll<Color>(
                        themeProvider.isDarkMode
                            ? DarkAppColors.surface
                            : AppColors.surface,
                      ),
                      shape: WidgetStatePropertyAll<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          side: BorderSide(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.primary.withValues(alpha: 0.3)
                                : AppColors.primary.withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                        ),
                      ),
                    );
                  },
                  suggestionsBuilder: (BuildContext context, SearchController controller) {
                    if (controller.text.isEmpty) {
                      return <Widget>[];
                    }

                    // Trigger search in product provider
                    productProvider.searchProducts(controller.text);

                    return List<ListTile>.generate(5, (int index) {
                      final String item = 'item $index';
                      return ListTile(
                        title: Text(
                          item,
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface
                                : AppColors.onSurface,
                          ),
                        ),
                        onTap: () {
                          controller.closeView(item);
                        },
                      );
                    });
                  },
                ),
              ),
            ),
            backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
            elevation: 0,
            iconTheme: IconThemeData(
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
            actions: [
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth >= 800;

              return Column(
                children: [
                  // Category tabs in the body
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.surface.withValues(alpha: 0.8)
                          : AppColors.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
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
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                            (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                          : AppColors.onSurface.withValues(alpha: 0.7),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      tabs: [
                        _buildCategoryTab('All', Icons.apps),
                        _buildCategoryTab('Men\'s Wear', Icons.person),
                        _buildCategoryTab('Women\'s Wear', Icons.person_2),
                        _buildCategoryTab('Kids Wear', Icons.child_care),
                        _buildCategoryTab('Formal Wear', Icons.business_center),
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

                  // Main content area
                  Expanded(
                    child: isWideScreen ? Row(
                      children: [
                        // Left sidebar
                        Container(
                          width: 280,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
                                (themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface).withValues(alpha: 0.95),
                              ],
                            ),
                            border: Border(
                              right: BorderSide(
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                                    : AppColors.onSurface.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.05),
                                blurRadius: 8,
                                offset: const Offset(2, 0),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha: 0.1),
                                            (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha: 0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.filter_list_rounded,
                                        color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Discover Products',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha:0.08),
                                        (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha:0.04),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Quick Stats',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildStatItem(
                                        icon: Icons.inventory_2,
                                        label: '${productProvider.products.length} Products',
                                        themeProvider: themeProvider,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildStatItem(
                                        icon: Icons.category,
                                        label: '${ProductCategory.values.length} Categories',
                                        themeProvider: themeProvider,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showFilterBottomSheet(context),
                                    icon: const Icon(Icons.filter_alt_rounded, size: 20),
                                    label: const Text('Advanced Filters'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                                      foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      shadowColor: (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha:0.3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Main content area
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: productProvider.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : productProvider.products.isEmpty
                                    ? _buildEmptyState()
                                    : _buildProductGrid(productProvider),
                          ),
                        ),
                      ],
                    ) : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: productProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : productProvider.products.isEmpty
                              ? _buildEmptyState()
                              : _buildProductGrid(productProvider),
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: isShopOwner
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddProductDialog(context),
                  icon: const Icon(Icons.add),
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
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required ThemeProvider themeProvider,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: themeProvider.isDarkMode
              ? DarkAppColors.primary.withValues(alpha:0.7)
              : AppColors.primary.withValues(alpha:0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha:0.8)
                  : AppColors.onSurface.withValues(alpha:0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha: 0.1),
                    (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary.withValues(alpha:0.7)
                    : AppColors.primary.withValues(alpha:0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Products Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your search or filter criteria',
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha:0.7)
                    : AppColors.onSurface.withValues(alpha:0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _tabController.animateTo(0);
                Provider.of<ProductProvider>(context, listen: false).filterByCategory(null);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Show All Products'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider productProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Simplified responsive grid configuration
        int crossAxisCount;
        double childAspectRatio;
        double crossAxisSpacing;
        double mainAxisSpacing;

        final availableWidth = constraints.maxWidth;

        if (availableWidth >= 600) {
          // Tablet and desktop
          crossAxisCount = 3;
          childAspectRatio = 0.75;
          crossAxisSpacing = 12;
          mainAxisSpacing = 12;
        } else {
          // Mobile
          crossAxisCount = 2;
          childAspectRatio = 0.8;
          crossAxisSpacing = 8;
          mainAxisSpacing = 8;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: productProvider.products.length,
          itemBuilder: (context, index) {
            final product = productProvider.products[index];
            return _SimpleProductCard(product: product);
          },
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    // Navigate to add product screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductEditScreen(),
      ),
    );
  }

  void _navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
    );
  }
}

class _SimpleProductCard extends StatefulWidget {
  final Product product;

  const _SimpleProductCard({required this.product});

  @override
  State<_SimpleProductCard> createState() => _SimpleProductCardState();
}

class _SimpleProductCardState extends State<_SimpleProductCard> {
  bool _isAddingToCart = false;

  void _addToCart(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    setState(() {
      _isAddingToCart = true;
    });

    final success = await cartProvider.addToCart(widget.product, quantity: 1);

    setState(() {
      _isAddingToCart = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} added to cart!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartProvider.errorMessage ?? 'Failed to add item to cart'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final isShopOwner = authProvider.isShopOwnerOrAdmin;
    final isInCart = cartProvider.isInCart(widget.product.id);

    return GestureDetector(
      onTap: () => _showProductDetails(context, widget.product),
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                : AppColors.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.05)
                  : AppColors.onSurface.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.surface
                        : AppColors.background,
                  ),
                  child: widget.product.imageUrls.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            widget.product.imageUrls.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 140,
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
                                  size: 32,
                                  color: themeProvider.isDarkMode
                                      ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                      : AppColors.onSurface.withValues(alpha: 0.3),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.surface
                              : AppColors.background,
                          child: Icon(
                            Icons.inventory_2,
                            size: 32,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                : AppColors.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                ),

                // Out of stock overlay
                if (!widget.product.isActive)
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: const Center(
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                // Category badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(widget.product.category, themeProvider).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
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

                // Edit button for shop owners
                if (isShopOwner)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _navigateToEditProduct(context, widget.product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 14,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface
                          : AppColors.onSurface,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    '₹${widget.product.basePrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.product.isActive && !_isAddingToCart
                          ? () => _addToCart(context)
                          : null,
                      icon: _isAddingToCart
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(isInCart ? Icons.shopping_cart : Icons.add_shopping_cart, size: 16),
                      label: Text(
                        _isAddingToCart
                            ? 'Adding...'
                            : isInCart
                                ? 'In Cart'
                                : 'Add to Cart',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary,
                        foregroundColor: themeProvider.isDarkMode
                            ? DarkAppColors.onPrimary
                            : AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ProductCategory category, ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;

    switch (category) {
      case ProductCategory.mensWear:
        return isDark ? Colors.blue.shade400 : Colors.blue.shade600;
      case ProductCategory.womensWear:
        return isDark ? Colors.pink.shade400 : Colors.pink.shade600;
      case ProductCategory.kidsWear:
        return isDark ? Colors.orange.shade400 : Colors.orange.shade600;
      case ProductCategory.formalWear:
        return isDark ? Colors.purple.shade400 : Colors.purple.shade600;
      case ProductCategory.casualWear:
        return isDark ? Colors.green.shade400 : Colors.green.shade600;
      case ProductCategory.traditionalWear:
        return isDark ? Colors.indigo.shade400 : Colors.indigo.shade600;
      case ProductCategory.alterations:
        return isDark ? Colors.teal.shade400 : Colors.teal.shade600;
      case ProductCategory.customDesign:
        return isDark ? Colors.red.shade400 : Colors.red.shade600;
    }
  }

  void _showProductDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  void _navigateToEditProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductEditScreen(product: product),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 10000);
  ProductCategory? _selectedCategory;
  String _selectedSort = 'name';
  bool _isApplyingFilters = false;

  void _applyFilters(BuildContext context) async {
    setState(() {
      _isApplyingFilters = true;
    });

    try {
      // Get the ProductProvider instance
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      // Apply filters using the ProductProvider methods
      productProvider.filterByCategory(_selectedCategory);
      productProvider.filterByPriceRange((_priceRange.start != 0 || _priceRange.end != 10000)
          ? _priceRange
          : null);
      productProvider.sortProducts(_selectedSort);

      // Close the bottom sheet
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Filters applied successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying filters: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isApplyingFilters = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Price Range
            const Text(
              'Price Range',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 10000,
              divisions: 20,
              labels: RangeLabels(
                '₹${_priceRange.start.toInt()}',
                '₹${_priceRange.end.toInt()}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),

            const SizedBox(height: 20),

            // Category Filter
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ProductCategory.values.map((category) {
                return FilterChip(
                  label: Text(category.toString().split('.').last),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Sort Options
            const Text(
              'Sort By',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Name (A-Z)'),
                  value: 'name',
                  groupValue: _selectedSort,
                  onChanged: (value) => setState(() => _selectedSort = value!),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
                RadioListTile<String>(
                  title: const Text('Price (Low to High)'),
                  value: 'price_asc',
                  groupValue: _selectedSort,
                  onChanged: (value) => setState(() => _selectedSort = value!),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
                RadioListTile<String>(
                  title: const Text('Price (High to Low)'),
                  value: 'price_desc',
                  groupValue: _selectedSort,
                  onChanged: (value) => setState(() => _selectedSort = value!),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Apply Filters Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isApplyingFilters ? null : () => _applyFilters(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isApplyingFilters
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedQuantity = 1;
  final Map<String, dynamic> _customizations = {};

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final isShopOwner = authProvider.isShopOwnerOrAdmin;
    final isInCart = cartProvider.isInCart(widget.product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          if (isShopOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editProductFromDetails(context, widget.product),
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share product
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Add to favorites
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images
            SizedBox(
              height: 320,
              child: widget.product.imageUrls.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          itemCount: widget.product.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Hero(
                              tag: 'product_${widget.product.id}_$index',
                              child: Image.network(
                                widget.product.imageUrls[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: themeProvider.isDarkMode
                                        ? DarkAppColors.surface
                                        : AppColors.background,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
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
                                errorBuilder: (context, error, stack) => Container(
                                  color: themeProvider.isDarkMode
                                      ? DarkAppColors.surface
                                      : AppColors.background,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: themeProvider.isDarkMode
                                            ? DarkAppColors.onSurface.withValues(alpha:0.5)
                                            : AppColors.onSurface.withValues(alpha:0.5),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                          color: themeProvider.isDarkMode
                                              ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                              : AppColors.onSurface.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Image indicator
                        if (widget.product.imageUrls.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                widget.product.imageUrls.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha:0.8),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Image count badge
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha:0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${widget.product.imageUrls.length} image${widget.product.imageUrls.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.surface
                          : AppColors.background,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 80,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                : AppColors.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No product images available',
                            style: TextStyle(
                              fontSize: 16,
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                                  : AppColors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '₹${widget.product.basePrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Product Description
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha:0.7)
                          : AppColors.onSurface.withValues(alpha:0.7),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Specifications
                  Text(
                    'Specifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...widget.product.specifications.entries.map((spec) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              '${spec.key}: ',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(spec.value),
                          ],
                        ),
                      )),

                  const SizedBox(height: 20),

                  // Available Sizes
                  Text(
                    'Available Sizes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    children: widget.product.availableSizes.map((size) {
                      return Chip(
                        label: Text(size),
                        backgroundColor: Colors.grey.shade100,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Available Fabrics
                  Text(
                    'Available Fabrics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    children: widget.product.availableFabrics.map((fabric) {
                      return Chip(
                        label: Text(fabric),
                        backgroundColor: themeProvider.isDarkMode
                            ? DarkAppColors.primary.withValues(alpha:0.1)
                            : AppColors.primary.withValues(alpha:0.1),
                        labelStyle: TextStyle(
                          color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  // Quantity Selector
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _selectedQuantity > 1
                            ? () => setState(() => _selectedQuantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: themeProvider.isDarkMode
                              ? DarkAppColors.primary.withValues(alpha: 0.1)
                              : AppColors.primary.withValues(alpha: 0.1),
                          foregroundColor: themeProvider.isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.primary.withValues(alpha: 0.3)
                                : AppColors.primary.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_selectedQuantity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.primary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _selectedQuantity++),
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: themeProvider.isDarkMode
                              ? DarkAppColors.primary.withValues(alpha: 0.1)
                              : AppColors.primary.withValues(alpha: 0.1),
                          foregroundColor: themeProvider.isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _addToCart(context, cartProvider, widget.product),
                          icon: Icon(isInCart ? Icons.shopping_cart : Icons.add_shopping_cart),
                          label: Text(isInCart ? 'Add to Cart' : 'Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeProvider.isDarkMode
                                ? DarkAppColors.primary
                                : AppColors.primary,
                            foregroundColor: themeProvider.isDarkMode
                                ? DarkAppColors.onPrimary
                                : AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _quickOrder(context, cartProvider, widget.product, authProvider.isAuthenticated),
                          icon: const Icon(Icons.flash_on),
                          label: const Text('Quick Order'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Cart Navigation
                  if (cartProvider.itemCount > 0)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToCart(context),
                        icon: const Icon(Icons.shopping_cart),
                        label: Text('View Cart (${cartProvider.itemCount} items)'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.primary
                                : AppColors.primary,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editProductFromDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductEditScreen(product: product),
      ),
    );
  }

  // Cart-related methods
  void _addToCart(BuildContext context, CartProvider cartProvider, Product product) async {
    final success = await cartProvider.addToCart(product, quantity: _selectedQuantity, customizations: _customizations);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedQuantity}x ${product.name} added to cart!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartProvider.errorMessage ?? 'Failed to add item to cart'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _quickOrder(BuildContext context, CartProvider cartProvider, Product product, bool isAuthenticated) {
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to place an order'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // First add to cart, then proceed to checkout
    _addToCart(context, cartProvider, product);

    // Navigate to order creation wizard
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OrderCreationWizard(),
        ),
      );
    });
  }

  void _navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
    );
  }
}
