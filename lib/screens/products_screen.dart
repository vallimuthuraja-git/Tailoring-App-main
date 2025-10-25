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

/// Customer-Facing Product Screen with Performance Optimizations
/// Displays products for regular users to browse and purchase
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  bool _isGridView = true;
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ProductCategory? _selectedCategory = ProductCategory.mensWear;
  String _sortOption = 'name';
  bool _hasLoadedProducts = false; // Prevent multiple load attempts

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
          appBar: _buildAppBar(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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

        // Apply sorting
        products.sort(_sortComparator());

        if (productProvider.isLoading && products.isEmpty) {
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
                      onPressed: () => _showFilterBottomSheet(context),
                      icon: const Icon(Icons.sort, size: 16),
                      label: const Text('Sort & Filter'),
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

  int Function(Product a, Product b) _sortComparator() {
    switch (_sortOption) {
      case 'name':
        return (a, b) => a.name.compareTo(b.name);
      case 'name_desc':
        return (a, b) => b.name.compareTo(a.name);
      case 'price_asc':
        return (a, b) => a.basePrice.compareTo(b.basePrice);
      case 'price_desc':
        return (a, b) => b.basePrice.compareTo(a.basePrice);
      case 'rating':
        return (a, b) =>
            b.rating.averageRating.compareTo(a.rating.averageRating);
      default:
        return (a, b) => a.name.compareTo(b.name);
    }
  }

  void _sortProducts(String sortOption) {
    // This would update the provider's sort option
    // For now, we can implement local sorting in the product grid
    Provider.of<ProductProvider>(context, listen: false)
        .sortProducts(sortOption);
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 5000);
  List<String> _selectedBrands = [];
  List<String> _selectedCategories = [];
  double _minRating = 0.0;
  bool _onlyNewArrivals = false;
  bool _onlyOnSale = false;
  bool _inStockOnly = false;
  String _selectedSort = 'name'; // Add sort selection

  final List<String> _brands = [
    'Nike',
    'Adidas',
    'Puma',
    'Levis',
    'Zara',
    'H&M'
  ];
  final List<String> _categories = [
    'Men\'s Wear',
    'Women\'s Wear',
    'Kids Wear',
    'Custom Design'
  ];

  final Map<String, String> _sortOptions = {
    'name': 'Name (A-Z)',
    'name_desc': 'Name (Z-A)',
    'price_asc': 'Price (Low to High)',
    'price_desc': 'Price (High to Low)',
    'rating': 'Rating (Highest)',
    'newest': 'Newest First',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sort Options - Moved to Top
          _buildModernSortOptions(),

          const SizedBox(height: 24),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range Slider
                  _buildSectionHeader('Price Range'),
                  _buildPriceRange(),

                  const SizedBox(height: 24),

                  // Brands
                  _buildSectionHeader('Brands'),
                  _buildBrandChips(),

                  const SizedBox(height: 24),

                  // Categories
                  _buildSectionHeader('Categories'),
                  _buildCategoryChips(),

                  const SizedBox(height: 24),

                  // Rating Filter
                  _buildSectionHeader('Minimum Rating'),
                  _buildRatingFilter(),

                  const SizedBox(height: 24),

                  // Additional Filters
                  _buildSectionHeader('Additional Filters'),
                  _buildAdditionalFilters(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPriceRange() {
    return Column(
      children: [
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 5000,
          divisions: 50,
          labels: RangeLabels(
            '₹${_priceRange.start.round()}',
            '₹${_priceRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
          activeColor: Colors.orange,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${_priceRange.start.round()}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '₹${_priceRange.end.round()}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrandChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _brands.map((brand) {
        final isSelected = _selectedBrands.contains(brand);
        return FilterChip(
          label: Text(brand),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedBrands.add(brand);
              } else {
                _selectedBrands.remove(brand);
              }
            });
          },
          backgroundColor: Colors.grey[100],
          selectedColor: Colors.orange[100],
          checkmarkColor: Colors.orange,
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          },
          backgroundColor: Colors.grey[100],
          selectedColor: Colors.orange[100],
          checkmarkColor: Colors.orange,
        );
      }).toList(),
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      children: [
        Slider(
          value: _minRating,
          min: 0,
          max: 5,
          divisions: 10,
          label: _minRating.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _minRating = value;
            });
          },
          activeColor: Colors.orange,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                '${_minRating.toStringAsFixed(1)}+ stars',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sort Header
        Row(
          children: [
            Icon(Icons.sort, size: 20, color: Colors.orange),
            const SizedBox(width: 8),
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Horizontal Scrollable Sort Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _sortOptions.entries.map((entry) {
              final isSelected = _selectedSort == entry.key;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSort = entry.key;
                      });
                    }
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: Colors.orange,
                  elevation: isSelected ? 2 : 0,
                  pressElevation: 4,
                  checkmarkColor: Colors.white,
                  avatar: isSelected
                      ? const Icon(
                          Icons.sort,
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.orange : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Currently Selected Sort Indicator
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              const SizedBox(width: 28), // Align with icon space
              Text(
                'Currently: ${_sortOptions[_selectedSort] ?? 'Name (A-Z)'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptionsOld() {
    return Column(
      children: _sortOptions.entries.map((entry) {
        final isSelected = _selectedSort == entry.key;
        return RadioListTile<String>(
          title: Text(
            entry.value,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.orange : null,
            ),
          ),
          value: entry.key,
          groupValue: _selectedSort,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedSort = value;
              });
            }
          },
          activeColor: Colors.orange,
          contentPadding: EdgeInsets.zero,
          dense: true,
        );
      }).toList(),
    );
  }

  Widget _buildAdditionalFilters() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('New Arrivals Only'),
          value: _onlyNewArrivals,
          onChanged: (value) {
            setState(() {
              _onlyNewArrivals = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('On Sale Only'),
          value: _onlyOnSale,
          onChanged: (value) {
            setState(() {
              _onlyOnSale = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('In Stock Only'),
          value: _inStockOnly,
          onChanged: (value) {
            setState(() {
              _inStockOnly = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 5000);
      _selectedBrands.clear();
      _selectedCategories.clear();
      _minRating = 0.0;
      _selectedSort = 'name';
      _onlyNewArrivals = false;
      _onlyOnSale = false;
      _inStockOnly = false;
    });
  }

  void _applyFilters() {
    // Here you would apply the filters to the product provider
    // For now, just close the sheet
    debugPrint('Applied filters:');
    debugPrint('Price range: ${_priceRange.start} - ${_priceRange.end}');
    debugPrint('Selected brands: $_selectedBrands');
    debugPrint('Selected categories: $_selectedCategories');
    debugPrint('Min rating: $_minRating');
    debugPrint('Selected sort: $_selectedSort');
    debugPrint('New arrivals only: $_onlyNewArrivals');
    debugPrint('On sale only: $_onlyOnSale');
    debugPrint('In stock only: $_inStockOnly');

    // Close the bottom sheet
    Navigator.of(context).pop();

    // Show a snackbar to confirm filters applied
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
