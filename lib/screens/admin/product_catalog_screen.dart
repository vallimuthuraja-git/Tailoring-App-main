import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import '../../services/firebase_service.dart';

class ProductCatalogScreen extends StatefulWidget {
  const ProductCatalogScreen({super.key});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Mens Wear',
    'Womens Wear',
    'Kids Wear'
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final firebaseService = FirebaseService();
      final snapshot = await firebaseService.getCollection('products');

      setState(() {
        _products = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown Product',
            'price': data['basePrice'] ?? 0.0,
            'category': _getCategoryName(data['category']),
            'stock': data['stockCount'] ?? 0,
            'active': data['isActive'] ?? true,
            'image': data['imageUrls']?.first,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load products: $e');
    }
  }

  String _getCategoryName(dynamic category) {
    const categoryMap = {
      0: 'Mens Wear',
      1: 'Womens Wear',
      2: 'Kids Wear',
      3: 'Custom',
    };
    return categoryMap[category] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        backgroundColor: isDark ? DarkAppColors.surface : AppColors.surface,
        foregroundColor: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddProduct,
            tooltip: 'Add New Product',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? DarkAppColors.surface : AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color:
                      (isDark ? DarkAppColors.onSurface : AppColors.onSurface)
                          .withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? DarkAppColors.background
                        : AppColors.background,
                  ),
                ),
                const SizedBox(height: 12),
                // Category Filter
                Row(
                  children: _categories.map((category) {
                    return Expanded(
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() =>
                              _selectedCategory = selected ? category : 'All');
                        },
                        selectedColor:
                            (isDark ? DarkAppColors.primary : AppColors.primary)
                                .withValues(alpha: 0.2),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total', _products.length.toString()),
                    _buildStatItem('Active',
                        _products.where((p) => p['active']).length.toString()),
                    _buildStatItem(
                        'Out of Stock',
                        _products
                            .where((p) => (p['stock'] ?? 0) <= 0)
                            .length
                            .toString()),
                  ],
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No products found',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : _buildProductsList(themeProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: isDark ? DarkAppColors.primary : AppColors.primary,
        foregroundColor: isDark ? DarkAppColors.onPrimary : AppColors.onPrimary,
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? DarkAppColors.primary : AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: (isDark ? DarkAppColors.onSurface : AppColors.onSurface)
                .withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList(ThemeProvider themeProvider) {
    final filteredProducts = _products.where((product) {
      final matchesSearch =
          product['name'].toString().toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'All' ||
          product['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product, themeProvider.isDarkMode);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? DarkAppColors.surface : AppColors.surface,
      child: InkWell(
        onTap: () => _navigateToProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image Placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (isDark ? DarkAppColors.primary : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory,
                  color: isDark ? DarkAppColors.primary : AppColors.primary,
                ),
              ),

              const SizedBox(width: 16),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DarkAppColors.onSurface
                            : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(product['category']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product['category'] ?? 'Unknown',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (product['active'] ?? false)
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (product['active'] ?? false)
                                ? 'Active'
                                : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              color: (product['active'] ?? false)
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price and Stock
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${(product['price'] ?? 0).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? DarkAppColors.primary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product['stock'] ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark
                              ? DarkAppColors.onSurface
                              : AppColors.onSurface)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showProductOptions(product),
                color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Mens Wear':
        return Colors.blue;
      case 'Womens Wear':
        return Colors.pink;
      case 'Kids Wear':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _navigateToAddProduct() {
    // TODO: Navigate to add product screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Product screen - Coming soon!')),
    );
  }

  void _navigateToProductDetails(Map<String, dynamic> product) {
    // TODO: Navigate to product details/edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${product['name']} - Coming soon!')),
    );
  }

  void _showProductOptions(Map<String, dynamic> product) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? DarkAppColors.surface : AppColors.surface,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit,
                color: isDark ? DarkAppColors.primary : AppColors.primary),
            title: const Text('Edit Product'),
            onTap: () {
              Navigator.pop(context);
              _navigateToProductDetails(product);
            },
          ),
          ListTile(
            leading: Icon(
              product['active'] ? Icons.pause : Icons.play_arrow,
              color: product['active'] ? Colors.orange : Colors.green,
            ),
            title: Text(product['active'] ? 'Deactivate' : 'Activate'),
            onTap: () {
              Navigator.pop(context);
              _toggleProductStatus(product);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Product'),
            textColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteProduct(product);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _toggleProductStatus(Map<String, dynamic> product) async {
    try {
      final firestore = FirebaseService();
      await firestore.updateDocument('products', product['id'], {
        'isActive': !product['active'],
        'updatedAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        product['active'] = !product['active'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Product ${product['active'] ? 'activated' : 'deactivated'} successfully',
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to update product status: $e');
    }
  }

  void _confirmDeleteProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
            'Are you sure you want to delete "${product['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(Map<String, dynamic> product) async {
    try {
      final firestore = FirebaseService();
      await firestore.deleteDocument('products', product['id']);

      setState(() {
        _products.removeWhere((p) => p['id'] == product['id']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product['name']} deleted successfully')),
      );
    } catch (e) {
      _showError('Failed to delete product: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
