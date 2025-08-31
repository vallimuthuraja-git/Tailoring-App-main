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

  // Computed properties for search state
  bool get hasSearchQuery => _searchQuery.isNotEmpty;
  bool get hasSearchResults => hasSearchQuery && products.isNotEmpty;
  String get searchQuery => _searchQuery; // Add getter for public access
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
        // Premier Quality Branded Products
        Product(
          id: 'demo-premier-001',
          name: 'Ralph Lauren Premium Cotton Shirt',
          description: 'Luxury polo shirt from Ralph Lauren featuring breathable cotton fabric with signature embroidered logo. Perfect for casual and semi-formal occasions.',
          category: ProductCategory.mensWear,
          basePrice: 4999.00,
          originalPrice: 6999.00,
          discountPercentage: 28.57,
          rating: ProductRating(
            averageRating: 4.6,
            reviewCount: 142,
            recentReviews: [
              ProductReview(
                id: 'rev1',
                userId: 'user1',
                userName: 'Aman Sharma',
                rating: 5.0,
                comment: 'Excellent quality and comfort. Perfect fit!',
                createdAt: DateTime.now().subtract(const Duration(days: 2)),
              ),
            ],
          ),
          stockCount: 15,
          soldCount: 87,
          brand: 'Ralph Lauren',
          imageUrls: [
            'https://images.unsplash.com/photo-1602810316693-3667c854239a?w=300&h=300&fit=crop&crop=center',
            'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=300&h=300&fit=crop&crop=center',
            'https://images.unsplash.com/photo-1602810316693-3667c854239a?w=300&h=300&fit=crop&crop=center'
          ],
          specifications: {
            'Material': '100% Premium Cotton',
            'Fit': 'Regular Fit',
            'Care': 'Machine Wash Cold',
            'Origin': 'India',
            'Warranty': '1 Year'
          },
          availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
          availableFabrics: ['Cotton'],
          customizationOptions: ['Embroidery Color', 'Size Adjustment'],
          badges: {'bestseller': 'Bestseller', 'premium': 'Premium'},
          isActive: true,
          isPopular: true,
          isOnSale: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
       Product(
         id: 'demo-suit-001',
         name: 'Hugo Boss Three-Piece Suit',
         description: 'Elegant three-piece business suit by Hugo Boss featuring premium Italian wool fabric. Includes jacket, vest, and trousers with perfect tailoring.',
         category: ProductCategory.formalWear,
         basePrice: 15999.00,
         originalPrice: 19999.00,
         discountPercentage: 20.0,
         rating: ProductRating(
           averageRating: 4.8,
           reviewCount: 89,
           recentReviews: [
             ProductReview(
               id: 'rev2',
               userId: 'user2',
               userName: 'Ravi Kumar',
               rating: 5.0,
               comment: 'Outstanding fit and quality. Worth every penny!',
               createdAt: DateTime.now().subtract(const Duration(days: 1)),
             ),
           ],
         ),
         stockCount: 8,
         soldCount: 34,
         brand: 'Hugo Boss',
         imageUrls: [
           'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Material': '100% Italian Wool',
           'Country of Origin': 'Italy',
           'Care': 'Dry Clean Only',
           'Warranty': '2 Years',
           'Available Colors': 'Navy, Black, Grey'
         },
         availableSizes: ['38R', '40R', '42R', '44R', '46R'],
         availableFabrics: ['Italian Wool'],
         customizationOptions: ['Pant Length', 'Sleeve Length', 'Monogram'],
         badges: {'premium': 'Premium Brand', 'trending': 'Trending'},
         isActive: true,
         isPopular: true,
         isNewArrival: true,
         isOnSale: true,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),
       Product(
         id: 'demo-dress-001',
         name: 'Gucci Silk Evening Gown',
         description: 'Exquisite silk evening gown by Gucci featuring handcrafted embroidery and premium Italian silk. Perfect for red carpet events and exclusive gatherings.',
         category: ProductCategory.womensWear,
         basePrice: 25999.00,
         originalPrice: 32999.00,
         discountPercentage: 21.21,
         rating: ProductRating(
           averageRating: 4.7,
           reviewCount: 234,
           recentReviews: [
             ProductReview(
               id: 'rev3',
               userId: 'user3',
               userName: 'Priya Singh',
               rating: 4.5,
               comment: 'Absolutely stunning! Perfect for special occasions.',
               createdAt: DateTime.now().subtract(const Duration(days: 3)),
             ),
           ],
         ),
         stockCount: 5,
         soldCount: 123,
         brand: 'Gucci',
         imageUrls: [
           'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Material': 'Premium Italian Silk',
           'Design': 'Hand Embroidery',
           'Length': 'Floor Length',
           'Care': 'Dry Clean Only',
           'Country of Origin': 'Italy',
           'Warranty': '18 Months'
         },
         availableSizes: ['XS', 'S', 'M', 'L', 'XL'],
         availableFabrics: ['Italian Silk', 'Chiffon Lining'],
         customizationOptions: ['Hem Length', 'Accent Color', 'Neckline'],
         badges: {'luxury': 'Luxury Collection', 'bestseller': 'Bestseller'},
         isActive: true,
         isPopular: true,
         isOnSale: true,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),

       // Affordable Casual Wear
       Product(
         id: 'demo-casual-001',
         name: 'H&M Basic Cotton T-Shirt',
         description: 'Comfortable everyday basic tee made from soft organic cotton. Available in multiple colors with timeless design.',
         category: ProductCategory.casualWear,
         basePrice: 499.00,
         originalPrice: 799.00,
         discountPercentage: 37.67,
         rating: ProductRating(
           averageRating: 4.2,
           reviewCount: 1289,
           recentReviews: [],
         ),
         stockCount: 0,
         soldCount: 892,
         brand: 'H&M',
         imageUrls: [
           'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Material': 'Organic Cotton',
           'Fit': 'Regular Fit',
           'Care': 'Machine Wash',
           'Available Colors': '12 Colors',
           'Warranty': '6 Months'
         },
         availableSizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
         availableFabrics: ['Organic Cotton'],
         customizationOptions: [],
         isActive: true,
         isNewArrival: false,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),

       // Trending Kids Wear
       Product(
         id: 'demo-kids-001',
         name: 'Zara Kids Premium Party Outfit',
         description: 'Elegant and comfortable party dress for kids featuring premium fabrics and cute bow details. Perfect for birthdays and special occasions.',
         category: ProductCategory.kidsWear,
         basePrice: 2499.00,
         originalPrice: 3499.00,
         discountPercentage: 28.58,
         rating: ProductRating(
           averageRating: 4.4,
           reviewCount: 567,
           recentReviews: [],
         ),
         stockCount: 25,
         soldCount: 189,
         brand: 'Zara Kids',
         imageUrls: [
           'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Material': 'Cotton Blend with Satin',
           'Age Group': '2-8 Years',
           'Care': 'Gentle Machine Wash',
           'Includes': 'Dress, Hair Accessory',
           'Warranty': '6 Months'
         },
         availableSizes: ['2Y', '3Y', '4Y', '5Y', '6Y', '7Y', '8Y'],
         availableFabrics: ['Cotton Blend', 'Satin Details'],
         customizationOptions: ['Color Selection', 'Name Embroidery'],
         badges: {'bestseller': 'Kids Favorite', 'sale': 'Big Sale'},
         isActive: true,
         isPopular: true,
         isOnSale: true,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),

       // New Arrivals Section
       Product(
         id: 'demo-traditional-001',
         name: 'Traditional Lehenga Choli Set',
         description: 'Exquisite traditional embroidered lehenga choli with handcrafted mirror work and premium zari borders. Perfect for festivals and weddings.',
         category: ProductCategory.traditionalWear,
         basePrice: 12999.00,
         originalPrice: null, // New arrival, no original price
         discountPercentage: null,
         rating: ProductRating(
           averageRating: 4.9,
           reviewCount: 342,
           recentReviews: [],
         ),
         stockCount: 12,
         soldCount: 67,
         brand: 'Traditional Elegance',
         imageUrls: [
           'https://images.unsplash.com/photo-1583391733956-375a45fe0782?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1583391733956-375a45fe0782?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1583391733956-375a45fe0782?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Material': 'Banarasi Silk with Zari Work',
           'Work': 'Hand Embroidery & Mirror Work',
           'Stitching': 'Fully Stitched',
           'Dupatta': 'Included',
           'Care': 'Dry Clean Only'
         },
         availableSizes: ['S', 'M', 'L', 'XL'],
         availableFabrics: ['Banarasi Silk', 'Zari Threads', 'Mirror Work'],
         customizationOptions: ['Dupatta Color', 'Embroidery Pattern', 'Length'],
         badges: {'new': 'New Arrival'},
         isActive: true,
         isNewArrival: true,
         createdAt: DateTime.now().subtract(const Duration(days: 7)), // Recent arrival
         updatedAt: DateTime.now(),
       ),

       // Price Drop/Special Offer
       Product(
         id: 'demo-flash-sale-001',
         name: 'Lacoste Classic Polo Shirt - FLASH SALE!',
         description: 'Limited time offer! Classic Lacoste polo with signature crocodile logo. Premium piqué cotton fabric with comfortable fit.',
         category: ProductCategory.casualWear,
         basePrice: 1999.00,
         originalPrice: 3999.00,
         discountPercentage: 50.0,
         rating: ProductRating(
           averageRating: 4.5,
           reviewCount: 89,
           recentReviews: [],
         ),
         stockCount: 3,
         soldCount: 46,
         brand: 'Lacoste',
         imageUrls: [
           'https://images.unsplash.com/photo-1544966503-7cc5ac882d5e?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1544966503-7cc5ac882d5e?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1544966503-7cc5ac882d5e?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Material': 'Piqué Cotton',
           'Features': 'Signature Crocodile Logo',
           'Care': 'Machine Wash Warm',
           'Flash Sale': 'Ends in 2 Hours!',
           'Warranty': '1 Year'
         },
         availableSizes: ['XS', 'S', 'M', 'L', 'XL'],
         availableFabrics: ['Cotton'],
         customizationOptions: [],
         badges: {'flash': 'Flash Sale', 'clearance': 'Final Sale'},
         isActive: true,
         isOnSale: true,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),

       // Best Seller
       Product(
         id: 'demo-jeans-001',
         name: 'Levi\'s 511 Slim Fit Jeans',
         description: 'Iconic Levi\'s slim fit jeans with comfortable stretch fabric. Founded by Levi Strauss in 1873, these jeans feature signature red tab and quality craftsmanship.',
         category: ProductCategory.casualWear,
         basePrice: 3299.00,
         originalPrice: 4299.00,
         discountPercentage: 23.26,
         rating: ProductRating(
           averageRating: 4.6,
           reviewCount: 2156,
           recentReviews: [],
         ),
         stockCount: 20,
         soldCount: 785,
         brand: "Levi's",
         imageUrls: [
           'https://images.unsplash.com/photo-1542272604-787c3835535d?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1542272604-787c3835535d?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1542272604-787c3835535d?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Material': '98% Cotton, 2% Elastane',
           'Fit': 'Slim Fit',
           'Rise': 'Mid Rise',
           'Care': 'Machine Wash Cold',
           'Origin': 'Imported',
           'Founded': '1873'
         },
         availableSizes: ['28', '30', '32', '34', '36', '38'],
         availableFabrics: ['Denim'],
         customizationOptions: ['Hem Length'],
         badges: {'bestseller': 'Best Seller', 'iconic': 'Iconic Brand'},
         isActive: true,
         isPopular: true,
         isOnSale: true,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),
       Product(
         id: 'demo-alteration-001',
         name: 'Premium Tailoring Service',
         description: 'Expert tailoring service by master craftsmen. From hemming pants to complete custom suits, we deliver perfection with attention to detail.',
         category: ProductCategory.alterations,
         basePrice: 349.00,
         rating: ProductRating(
           averageRating: 4.8,
           reviewCount: 892,
           recentReviews: [],
         ),
         stockCount: 999,
         soldCount: 425,
         brand: 'Master Tailors',
         imageUrls: [
           'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop&crop=center',
           'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&h=300&fit=crop&crop=center'
         ],
         specifications: {
           'Service Type': 'Professional Alteration',
           'Turnaround': '2-5 business days',
           'Quality Guarantee': '100% Guarantee',
           'Services': 'Hemming, Taking In, Lengthening',
           'Repair Services': 'Included'
         },
         availableSizes: ['All Sizes'],
         availableFabrics: ['All Materials'],
         customizationOptions: ['Hem Length', 'Waist Adjustment', 'Shoulder Fit', 'Sleeve Length'],
         badges: {'bestseller': 'Most Popular', 'trusted': 'Trusted'},
         isActive: true,
         isPopular: true,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       ),
     ];

    for (final product in demoProducts) {
      await addProduct(product);
    }
  }
}
