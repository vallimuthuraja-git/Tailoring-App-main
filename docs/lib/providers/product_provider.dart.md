# Product Provider

## Overview
The `product_provider.dart` file implements a comprehensive product management system for the AI-Enabled Tailoring Shop Management System. It provides complete CRUD operations, advanced search and filtering capabilities, real-time data synchronization, and extensive product catalog management with Firebase integration.

## Key Features

### Product Management
- **Complete CRUD Operations**: Create, read, update, delete products
- **Real-time Synchronization**: Live data updates with Firebase integration
- **Advanced Search**: Multi-field search with live filtering
- **Category-Based Organization**: Product categorization and management
- **Price Range Filtering**: Flexible price-based product discovery

### Advanced Filtering & Search
- **Multi-Criteria Filtering**: Category, price range, and search query filters
- **Dynamic Sorting**: Name, price (ascending/descending) sorting options
- **Combined Filters**: Multiple filter criteria applied simultaneously
- **Real-time Results**: Instant filter application with live results

### Business Intelligence
- **Product Analytics**: Category distribution and featured products
- **Inventory Management**: Active/inactive product status tracking
- **Performance Metrics**: Product popularity and availability tracking
- **Revenue Analytics**: Price-based analytics and product performance

## Architecture Components

### Provider Structure

#### ProductProvider Class
```dart
class ProductProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  ProductCategory? _selectedCategory;
  String _sortOption = 'name';
  RangeValues? _priceRange;
}
```

#### State Management
```dart
// Getters
List<Product> get products => _searchQuery.isEmpty && _selectedCategory == null && _priceRange == null
    ? _sortProducts(_products)
    : _sortProducts(_filteredProducts);

bool get isLoading => _isLoading;
String? get errorMessage => _errorMessage;
ProductCategory? get selectedCategory => _selectedCategory;
String get sortOption => _sortOption;
RangeValues? get priceRange => _priceRange;

// Computed properties
List<Product> get featuredProducts =>
    _products.where((product) => product.isActive).take(4).toList();

List<Product> getProductsByCategory(ProductCategory category) {
  return _products.where((product) => product.category == category).toList();
}
```

## Core Functionality

### Product CRUD Operations

#### Load Products
```dart
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
```

#### Add New Product
```dart
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
```

#### Update Product
```dart
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
```

#### Delete Product
```dart
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
```

### Advanced Search and Filtering

#### Search Products
```dart
void searchProducts(String query) {
  _searchQuery = query.toLowerCase();
  _applyFilters();
}
```

#### Filter by Category
```dart
void filterByCategory(ProductCategory? category) {
  _selectedCategory = category;
  _applyFilters();
}
```

#### Filter by Price Range
```dart
void filterByPriceRange(RangeValues? range) {
  _priceRange = range;
  _applyFilters();
}
```

#### Combined Filter Application
```dart
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
```

### Sorting Functionality

#### Product Sorting
```dart
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

void sortProducts(String sortOption) {
  _sortOption = sortOption;
  notifyListeners();
}
```

### Real-time Data Streaming

#### Products Collection Stream
```dart
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
```

#### Single Product Stream
```dart
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
```

### Product Status Management

#### Toggle Product Active Status
```dart
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
```

### Category Management

#### Get Product Categories
```dart
List<ProductCategory> get categories => ProductCategory.values;

String getCategoryName(ProductCategory category) {
  return category.toString().split('.').last;
}
```

#### Get Products by Category
```dart
List<Product> getProductsByCategory(ProductCategory category) {
  return _products.where((product) => product.category == category).toList();
}
```

### Utility Functions

#### Clear Filters
```dart
void clearFilters() {
  _searchQuery = '';
  _selectedCategory = null;
  _priceRange = null;
  _filteredProducts = [];
  notifyListeners();
}
```

#### Error Handling
```dart
void clearError() {
  _errorMessage = null;
  notifyListeners();
}
```

## Demo Data Management

### Comprehensive Demo Products
```dart
Future<void> loadDemoData() async {
  final demoProducts = [
    // Classic Cotton Shirt
    Product(
      id: 'demo-shirt-001',
      name: 'Classic Cotton Shirt',
      description: 'Premium quality cotton shirt perfect for everyday wear',
      category: ProductCategory.mensWear,
      basePrice: 1299.00,
      imageUrls: [...],
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

    // Executive Business Suit
    Product(
      id: 'demo-suit-001',
      name: 'Executive Business Suit',
      description: 'Professional business suit made from premium wool blend',
      category: ProductCategory.formalWear,
      basePrice: 8999.00,
      // ... additional properties
    ),

    // Elegant Evening Dress
    Product(
      id: 'demo-dress-001',
      name: 'Elegant Evening Dress',
      description: 'Stunning evening dress with intricate embroidery work',
      category: ProductCategory.womensWear,
      basePrice: 5999.00,
      // ... additional properties
    ),

    // Kids Party Outfit
    Product(
      id: 'demo-kids-001',
      name: 'Kids Party Outfit',
      description: 'Colorful and comfortable party outfit for kids',
      category: ProductCategory.kidsWear,
      basePrice: 899.00,
      // ... additional properties
    ),

    // Alteration Service
    Product(
      id: 'demo-alteration-001',
      name: 'Garment Alteration Service',
      description: 'Professional alteration services for all types of clothing',
      category: ProductCategory.alterations,
      basePrice: 299.00,
      // ... additional properties
    ),
  ];

  for (final product in demoProducts) {
    await addProduct(product);
  }
}
```

## Product Categories

### Available Product Categories
```dart
enum ProductCategory {
  mensWear,        // Men's clothing
  womensWear,      // Women's clothing
  kidsWear,        // Children's clothing
  formalWear,      // Formal/business attire
  casualWear,      // Casual clothing
  traditionalWear, // Traditional/ethnic wear
  alterations,     // Alteration services
  customDesign,    // Custom design services
  consultation,    // Consultation services
  measurements,    // Measurement services
  specialOccasion, // Special occasion wear
  corporateWear,   // Corporate uniforms
  uniformServices, // Uniform services
  bridalServices,  // Bridal wear services
}
```

## Integration Points

### With Firebase Service
- **Document Operations**: CRUD operations on product documents
  - Related: [`lib/services/firebase_service.dart`](../../services/firebase_service.md)
- **Real-time Streams**: Live product data synchronization
- **Collection Queries**: Bulk product data retrieval
- **Error Handling**: Firebase-specific error management

### With Product Catalog Screen
- **Search Integration**: Real-time search functionality
  - Related: [`lib/screens/catalog/product_catalog_screen.dart`](../../screens/catalog/product_catalog_screen.md)
- **Category Filtering**: Product category-based filtering
- **Price Range Filtering**: Price-based product discovery
- **Sorting Options**: Multiple product sorting criteria

### With Analytics Dashboard
- **Product Metrics**: Analytics dashboard data source
  - Related: [`lib/screens/dashboard/analytics_dashboard_screen.dart`](../../screens/dashboard/analytics_dashboard_screen.md)
- **Category Distribution**: Product categorization analytics
- **Performance Tracking**: Product performance metrics
- **Revenue Analytics**: Price and sales analytics

### With Order Provider
- **Product Information**: Order system product data
  - Related: [`lib/providers/order_provider.dart`](../../providers/order_provider.md)
- **Product Availability**: Real-time product status checking
- **Price Information**: Current product pricing for orders
- **Product Details**: Comprehensive product information for orders

## Performance Optimizations

### Efficient Filtering
- **Local Search**: In-memory product search capabilities
- **Indexed Queries**: Optimized Firebase queries
- **Caching Strategy**: Product data caching for performance
- **Debounced Search**: Optimized search with debouncing

### Real-time Updates
- **Stream Optimization**: Efficient Firebase document streams
- **Batch Operations**: Bulk product operations for performance
- **Memory Management**: Efficient state management
- **Lazy Loading**: On-demand product data retrieval

## Business Logic

### Product Status Management
- **Active/Inactive Toggle**: Product availability management
- **Bulk Status Updates**: Mass product status changes
- **Status Tracking**: Product lifecycle management
- **Automated Status**: Rule-based status updates

### Pricing Strategy
- **Dynamic Pricing**: Flexible price range filtering
- **Price Analytics**: Pricing-based business intelligence
- **Revenue Tracking**: Price-based performance metrics
- **Market Analysis**: Competitive pricing insights

## User Experience Features

### Advanced Filtering Workflow
```
Product Discovery
├── Search Query
│   ├── Product Name Matching
│   └── Description Matching
├── Category Selection
│   ├── Men's Wear
│   ├── Women's Wear
│   ├── Kids Wear
│   ├── Formal Wear
│   ├── Alterations
│   └── Custom Services
├── Price Range Filtering
│   ├── Minimum Price
│   ├── Maximum Price
│   └── Range Slider
└── Sorting Options
    ├── Name (A-Z)
    ├── Price (Low to High)
    └── Price (High to Low)
```

### Shop Owner Management Workflow
```
Product Management
├── Product Catalog
│   ├── View All Products
│   ├── Search & Filter
│   └── Category Organization
├── Product Operations
│   ├── Add New Product
│   ├── Edit Existing Product
│   ├── Delete Product
│   └── Toggle Status
├── Business Analytics
│   ├── Category Performance
│   ├── Price Analytics
│   └── Revenue Tracking
└── Inventory Management
    ├── Active Products
    ├── Inactive Products
    └── Stock Status
```

### Customer Experience
```
Product Browsing
├── Product Discovery
│   ├── Search Products
│   ├── Browse Categories
│   └── Filter by Price
├── Product Details
│   ├── Product Images
│   ├── Specifications
│   ├── Size Options
│   └── Fabric Choices
├── Customization
│   ├── Available Options
│   ├── Personalization
│   └── Special Requests
└── Purchase Process
    ├── Add to Cart
    ├── Place Order
    └── Track Status
```

## Future Enhancements

### Advanced Features
- **AI-Powered Recommendations**: Personalized product suggestions
- **Visual Search**: Image-based product discovery
- **Dynamic Pricing**: Market-based price optimization
- **Inventory Management**: Advanced stock tracking

### Integration Features
- **Multi-Channel Sales**: E-commerce platform integration
- **Supplier Management**: Vendor and supplier integration
- **Quality Control**: Product quality management system
- **Sustainability Tracking**: Eco-friendly material tracking

### Analytics & Intelligence
- **Predictive Analytics**: Demand forecasting
- **Customer Insights**: Purchase behavior analysis
- **Market Trends**: Industry trend analysis
- **Performance Optimization**: Automated product optimization

---

*This Product Provider serves as the comprehensive product data management hub for the tailoring shop system, providing advanced product catalog management, real-time search and filtering, comprehensive CRUD operations, and business intelligence capabilities that enable efficient product management and data-driven decision making across the entire product lifecycle.*