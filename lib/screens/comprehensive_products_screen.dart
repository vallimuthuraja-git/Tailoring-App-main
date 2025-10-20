
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/injection_container.dart';
import '../models/product_models.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/product_provider.dart';
import '../utils/responsive_utils.dart';

import '../widgets/catalog/expandable_search_bar.dart';
import '../widgets/catalog/product_grid_view.dart';
import '../widgets/catalog/product_screen_filters_bar.dart';
import '../widgets/catalog/enhanced_empty_state.dart';
import '../widgets/catalog/skeleton_loading_widgets.dart';
import '../screens/catalog/product_detail_screen.dart';
import '../screens/catalog/product_edit_screen.dart';

/// Comprehensive Products Screen integrating all product features
class ComprehensiveProductsScreen extends StatefulWidget {
  const ComprehensiveProductsScreen({super.key});

  @override
  State<ComprehensiveProductsScreen> createState() =>
      _ComprehensiveProductsScreenState();
}

class _ComprehensiveProductsScreenState
    extends State<ComprehensiveProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSearchExpanded = false;
  bool _isGridView = true;
  Product? _selectedProduct;
  Product? _editingProduct;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load products when dependencies change (Provider becomes available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Provider.of<ProductProvider>(context, listen: false).loadProducts();
      } catch (e) {
        debugPrint('Error loading products: $e');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(injectionContainer.productBloc),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products Hub'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.grid_view), text: 'Catalog'),
              Tab(icon: Icon(Icons.new_releases), text: 'New'),
              Tab(icon: Icon(Icons.details), text: 'Details'),
              Tab(icon: Icon(Icons.edit), text: 'Edit'),
              Tab(icon: Icon(Icons.shopping_cart), text: 'Cart'),
              Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(_isSearchExpanded ? Icons.search_off : Icons.search),
              onPressed: () =>
                  setState(() => _isSearchExpanded = !_isSearchExpanded),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar (conditionally shown)
            if (_isSearchExpanded)
              Padding(
                padding: ResponsiveUtils.getAdaptivePadding(context,
                    basePadding: 16.0),
                child: ExpandableSearchBar(
                  isExpanded: true,
                  onExpandToggle: () =>
                      setState(() => _isSearchExpanded = !_isSearchExpanded),
                  onSearchChanged: _onSearchChanged,
                ),
              ),

            // Filters
            Padding(
              padding: ResponsiveUtils.getAdaptivePadding(context,
                  basePadding: 16.0,
                  hasRichContent: false,
                  itemCount: 1,
                  isGridView: true),
              child: ProductScreenFiltersBar(
                isGridView: _isGridView,
                onToggleView: () => setState(() => _isGridView = !_isGridView),
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCatalogTab(),
                  _buildNewProductsTab(),
                  _buildDetailsTab(),
                  _buildEditTab(),
                  _buildCartTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewProduct,
          tooltip: 'Add New Product',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildNewProductsTab() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return ProductGridSkeleton();
        }

        if (productProvider.hasError) {
          return EnhancedEmptyState();
        }

        final allProducts = productProvider.products;
        final newProducts = allProducts.where((p) => p.isNewArrival).toList();

        if (newProducts.isEmpty) {
          return EnhancedEmptyState();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    '${newProducts.length} New Products',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _isGridView ? Icons.list : Icons.grid_view,
                    ),
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                    tooltip: _isGridView
                        ? 'Switch to List View'
                        : 'Switch to Grid View',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ProductGridView(
                products: newProducts,
                isGridView: _isGridView,
                themeProvider: Provider.of<ThemeProvider>(context),
                onProductTap: _onProductTap,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailsTab() {
    if (_selectedProduct == null) {
      return EnhancedEmptyState();
    }

    return ProductDetailScreen(product: _selectedProduct!);
  }

  Widget _buildEditTab() {
    return ProductEditScreen(product: _editingProduct);
  }

  Widget _buildCatalogTab() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return ProductGridSkeleton();
        }

        if (productProvider.hasError) {
          return EnhancedEmptyState();
        }

        final products = productProvider.products;
        if (products.isEmpty) {
          return EnhancedEmptyState();
        }

        return Column(
          children: [
            // Product count and view toggle
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    '${products.length} Products',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _isGridView ? Icons.list : Icons.grid_view,
                    ),
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                    tooltip: _isGridView
                        ? 'Switch to List View'
                        : 'Switch to Grid View',
                  ),
                ],
              ),
            ),

            // Product grid
            Expanded(
              child: ProductGridView(
                products: products,
                isGridView: _isGridView,
                themeProvider: Provider.of<ThemeProvider>(context),
                onProductTap: _onProductTap,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartTab() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.items;

        if (cartItems.isEmpty) {
          return EnhancedEmptyState();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    '${cartItems.length} Items in Cart',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    'Total: \$${cartProvider.totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            '\$${(item.product.basePrice * item.quantity).toStringAsFixed(2)}'),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => cartProvider.updateQuantity(
                              item.product.id, item.quantity - 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => cartProvider.updateQuantity(
                              item.product.id, item.quantity + 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              cartProvider.removeFromCart(item.product.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _showCheckoutDialog(cartProvider),
                child: const Text('Proceed to Checkout'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future:
          injectionContainer.productAnalyticsService.getPerformanceMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return EnhancedEmptyState();
        }

        final metrics = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildAnalyticsCard(
                'Total Products', metrics['total_products'].toString()),
            _buildAnalyticsCard('New Products (30 days)',
                metrics['new_products_30_days'].toString()),
            _buildAnalyticsCard(
                'Featured Products', metrics['featured_products'].toString()),
            _buildAnalyticsCard(
                'Average Rating', metrics['average_rating'].toStringAsFixed(1)),
            _buildAnalyticsCard('Total Sold', metrics['total_sold'].toString()),
            _buildAnalyticsCard('Total Revenue',
                '\$${metrics['total_revenue'].toStringAsFixed(2)}'),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    productProvider.searchProducts(query);
  }

  void _onProductTap(Product product) {
    setState(() {
      _selectedProduct = product;
    });
    _tabController.animateTo(2); // Switch to Details tab
  }

  void _addNewProduct() {
    setState(() {
      _editingProduct = null; // null for new product
    });
    _tabController.animateTo(3); // Switch to Edit tab
  }

  void _showAddProductDialog() {
    // TODO: Implement add product dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add product feature coming soon')),
    );
  }

  void _showCheckoutDialog(CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content:
            Text('Total: \$${cartProvider.totalAmount.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement checkout
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checkout completed!')),
              );
              cartProvider.clearCart();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

/// Extension to add isGridView to ThemeProvider (assuming it exists)
extension ThemeProviderExtension on ThemeProvider {
  bool get isGridView =>
      true; // Placeholder - implement based on your ThemeProvider
  void
      toggleViewMode() {} // Placeholder - implement based on your ThemeProvider
}
