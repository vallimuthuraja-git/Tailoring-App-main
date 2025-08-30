import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  ProductCategory? _selectedCategory;
  String _sortOption = 'name'; // 'name', 'price_asc', 'price_desc'
  RangeValues? _priceRange; // Price range filter

  // Getters
  List<Product> get products => _searchQuery.isEmpty && _selectedCategory == null && _priceRange == null
      ? _sortProducts(_products)
      : _sortProducts(_filteredProducts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProductCategory? get selectedCategory => _selectedCategory;
  String get sortOption => _sortOption;
  RangeValues? get priceRange => _priceRange;
  List<Product> get featuredProducts =>
      _products.where((product) => product.isActive).take(4).toList();

  List<Product> getProductsByCategory(ProductCategory category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Search and filter
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterByCategory(ProductCategory? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void filterByPriceRange(RangeValues? range) {
    _priceRange = range;
    _applyFilters();
  }

  void sortProducts(String sortOption) {
    _sortOption = sortOption;
    notifyListeners();
  }

  void _applyFilters() {
    List<Product> filtered = _products;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery) ||
                product.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }

    // Apply price range filter
    if (_priceRange != null) {
      filtered = filtered.where((product) {
        return product.basePrice >= _priceRange!.start &&
               product.basePrice <= _priceRange!.end;
      }).toList();
    }

    _filteredProducts = filtered;
    notifyListeners();
  }

  List<Product> _sortProducts(List<Product> products) {
    switch (_sortOption) {
      case 'price_asc':
        return List.from(products)..sort((a, b) => a.basePrice.compareTo(b.basePrice));
      case 'price_desc':
        return List.from(products)..sort((a, b) => b.basePrice.compareTo(a.basePrice));
      case 'name':
      default:
        return List.from(products)..sort((a, b) => a.name.compareTo(b.name));
    }
  }

  // Load products from Firestore
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _firebaseService.getCollection('products');
      _products = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();

      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load products: $e';
      notifyListeners();
    }
  }

  // Real-time products stream
  Stream<List<Product>> getProductsStream() {
    return _firebaseService.collectionStream('products').map((snapshot) {
      final products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();

      _products = products;
      _applyFilters();
      return products;
    });
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final docSnapshot = await _firebaseService.getDocument('products', productId);
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id;
        return Product.fromJson(data);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to load product: $e';
      notifyListeners();
      return null;
    }
  }

  // Stream single product
  Stream<Product?> getProductStream(String productId) {
    return _firebaseService.documentStream('products', productId).map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }
      return null;
    });
  }

  // Add new product (for shop owners)
  Future<bool> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final productData = product.toJson();
      productData.remove('id'); // Remove ID for new products

      await _firebaseService.addDocument('products', productData);

      // Reload products
      await loadProducts();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add product: $e';
      notifyListeners();
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final productData = product.toJson();
      productData.remove('id'); // Remove ID from data

      await _firebaseService.updateDocument('products', product.id, productData);

      // Reload products
      await loadProducts();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update product: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.deleteDocument('products', productId);

      // Reload products
      await loadProducts();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete product: $e';
      notifyListeners();
      return false;
    }
  }

  // Toggle product active status
  Future<bool> toggleProductStatus(String productId) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        category: product.category,
        basePrice: product.basePrice,
        imageUrls: product.imageUrls,
        specifications: product.specifications,
        availableSizes: product.availableSizes,
        availableFabrics: product.availableFabrics,
        customizationOptions: product.customizationOptions,
        isActive: !product.isActive,
        createdAt: product.createdAt,
        updatedAt: DateTime.now(),
      );

      return await updateProduct(updatedProduct);
    } catch (e) {
      _errorMessage = 'Failed to update product status: $e';
      notifyListeners();
      return false;
    }
  }

  // Get product categories
  List<ProductCategory> get categories => ProductCategory.values;

  String getCategoryName(ProductCategory category) {
    return category.toString().split('.').last;
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _priceRange = null;
    _filteredProducts = [];
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Demo data for testing
   Future<void> loadDemoData() async {
     final demoProducts = [
       Product(
         id: 'demo-shirt-001',
         name: 'Classic Cotton Shirt',
         description: 'Premium quality cotton shirt perfect for everyday wear. Made with 100% pure cotton fabric for maximum comfort.',
         category: ProductCategory.mensWear,
         basePrice: 1299.00,
         imageUrls: [
           'https://images.unsplash.com/photo-1602810316693-3667c854239a?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1602810316693-3667c854239a?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Material': '100% Cotton',
           'Care': 'Machine Wash',
           'Origin': 'India',
           'Warranty': '3 months'
         },
         availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
         availableFabrics: ['Cotton', 'Cotton Blend'],
         customizationOptions: ['Collar Type', 'Cuff Style', 'Pocket'],
         isActive: true,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),
       Product(
         id: 'demo-suit-001',
         name: 'Executive Business Suit',
         description: 'Professional business suit made from premium wool blend. Perfect for corporate meetings and formal occasions.',
         category: ProductCategory.formalWear,
         basePrice: 8999.00,
         imageUrls: [
           'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Material': 'Wool Blend',
           'Care': 'Dry Clean Only',
           'Origin': 'India',
           'Warranty': '6 months'
         },
         availableSizes: ['38', '40', '42', '44', '46'],
         availableFabrics: ['Wool', 'Wool Blend', 'Polyester Blend'],
         customizationOptions: ['Lapel Style', 'Vent Type', 'Button Style'],
         isActive: true,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),
       Product(
         id: 'demo-dress-001',
         name: 'Elegant Evening Dress',
         description: 'Stunning evening dress with intricate embroidery work. Perfect for weddings, parties, and special occasions.',
         category: ProductCategory.womensWear,
         basePrice: 5999.00,
         imageUrls: [
           'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Material': 'Silk Blend',
           'Care': 'Dry Clean Only',
           'Origin': 'India',
           'Warranty': '3 months'
         },
         availableSizes: ['XS', 'S', 'M', 'L', 'XL'],
         availableFabrics: ['Silk', 'Chiffon', 'Georgette'],
         customizationOptions: ['Neckline', 'Sleeve Length', 'Embroidery Pattern'],
         isActive: true,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),
       Product(
         id: 'demo-kids-001',
         name: 'Kids Party Outfit',
         description: 'Colorful and comfortable party outfit for kids. Made with soft, breathable fabric perfect for active children.',
         category: ProductCategory.kidsWear,
         basePrice: 899.00,
         imageUrls: [
           'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Material': 'Cotton Blend',
           'Care': 'Machine Wash',
           'Age Group': '3-10 years',
           'Warranty': '3 months'
         },
         availableSizes: ['3-4Y', '5-6Y', '7-8Y', '9-10Y'],
         availableFabrics: ['Cotton', 'Cotton Blend'],
         customizationOptions: ['Color', 'Design Pattern'],
         isActive: true,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),
       Product(
         id: 'demo-alteration-001',
         name: 'Garment Alteration Service',
         description: 'Professional alteration services for all types of clothing. Expert tailors ensure perfect fit and finish.',
         category: ProductCategory.alterations,
         basePrice: 299.00,
         imageUrls: [
           'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Service Type': 'Alteration',
           'Turnaround': '2-5 business days',
           'Quality Guarantee': 'Yes'
         },
         availableSizes: ['All Sizes'],
         availableFabrics: ['All Fabrics'],
         customizationOptions: ['Hem Length', 'Waist Adjustment', 'Shoulder Fit'],
         isActive: true,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),
     ];

    for (final product in demoProducts) {
      await addProduct(product);
    }
  }
}
