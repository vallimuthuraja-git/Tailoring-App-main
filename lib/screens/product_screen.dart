import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/injection_container.dart';
import '../models/product_models.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../utils/responsive_utils.dart';
import '../widgets/catalog/enhanced_empty_state.dart';
import '../widgets/catalog/unified_product_card.dart';
import '../screens/catalog/product_detail_screen.dart';

/// Simplified, Modern Product Screen with Performance Optimizations
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  bool _isGridView = true;
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ProductCategory? _selectedCategory = ProductCategory.mensWear;

  @override
  bool get wantKeepAlive => true; // Keep alive to prevent unnecessary rebuilds

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return SafeArea(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ProductProvider>(
            create: (_) => ProductProvider(injectionContainer.productBloc),
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: const Text(
              'Products',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            actions: [
              IconButton(
                icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
                onPressed: () =>
                    setState(() => _isSearchExpanded = !_isSearchExpanded),
              ),
              IconButton(
                icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                onPressed: () => setState(() => _isGridView = !_isGridView),
              ),
            ],
            bottom: _buildTabBar(),
          ),
          body: Column(
            children: [
              if (_isSearchExpanded) _buildSearchBar(),
              _buildCategoryFilters(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductGrid(), // All Products
                    _buildProductGrid(
                        category: ProductCategory.womensWear), // Women's
                    _buildProductGrid(productType: 'new'), // New Arrivals
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.totalQuantity > 0) {
                return FloatingActionButton(
                  onPressed: () => _showCartBottomSheet(context),
                  child: Badge(
                    label: Text('${cartProvider.totalQuantity}'),
                    child: const Icon(Icons.shopping_cart),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]!.withValues(alpha: 0.3 * 255)
              : Colors.grey[100]!.withValues(alpha: 0.8 * 255),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Women'),
            Tab(text: 'New'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      ProductCategory.mensWear,
      ProductCategory.womensWear,
      ProductCategory.kidsWear,
      ProductCategory.customDesign,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                category.name.replaceAll('Wear', '').toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100],
              selectedColor: Colors.orange,
              checkmarkColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid({ProductCategory? category, String? productType}) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        var products = productProvider.products;

        // Apply category filter
        if (category != null) {
          products = products.where((p) => p.category == category).toList();
        }

        // Apply product type filter
        if (productType == 'new') {
          products = products.where((p) => p.isNewArrival).toList();
        }

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          products = products.where((p) {
            return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                p.brand.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }

        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (products.isEmpty) {
          return EnhancedEmptyState(
            searchQuery: _searchQuery,
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      '${products.length} product${products.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, size: 16),
                      label: const Text('Filter'),
                    ),
                  ],
                ),
              ),
            ),
            _isGridView
                ? SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.getCrossAxisCount(
                          MediaQuery.of(context).size.width),
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return UnifiedProductCard(
                          key: ValueKey('product_${product.id}'),
                          product: product,
                          index: index,
                          onTap: () =>
                              _navigateToProductDetail(context, product),
                        );
                      },
                      childCount: products.length,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          height: 300, // Fixed height for consistency
                          child: UnifiedProductCard(
                            key: ValueKey('product_${product.id}'),
                            product: product,
                            index: index,
                            onTap: () =>
                                _navigateToProductDetail(context, product),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
            const SliverToBoxAdapter(
                child: SizedBox(height: 80)), // Space for FAB
          ],
        );
      },
    );
  }

  void _navigateToProductDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final items = cartProvider.items;
          return Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Cart Items (${items.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: Text(
                          '${item.quantity}x',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        title: Text(item.product.name),
                        subtitle: Text(item.product.formattedPrice),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () =>
                              cartProvider.removeFromCart(item.product.id),
                        ),
                      );
                    },
                  ),
                ),
                if (items.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          items.isEmpty
                              ? '\$0.00'
                              : '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
