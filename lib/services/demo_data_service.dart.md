# Demo Data Service Documentation

## Overview
The `demo_data_service.dart` file contains the comprehensive demo data management system for the AI-Enabled Tailoring Shop Management System. It provides realistic sample data for products, customers, and orders to facilitate testing, demonstrations, and development workflows without requiring live data.

## Architecture

### Core Components
- **`DemoDataService`**: Main service providing demo data across all major entities
- **Product Demo Data**: Sample product catalog with diverse categories
- **Customer Demo Data**: Sample customer profiles with measurements and preferences
- **Order Demo Data**: Placeholder for order scenarios (extensible)
- **Statistics Framework**: Pre-defined analytics structure for demo purposes

### Key Features
- **Realistic Sample Data**: Professionally crafted demo data reflecting real tailoring scenarios
- **Complete Product Catalog**: Diverse products across men's wear, women's wear, and alterations
- **Customer Profiling**: Detailed customer profiles with measurements and loyalty tiers
- **Extensible Framework**: Easy to expand with additional demo scenarios
- **Analytics Ready**: Pre-structured data for dashboard and reporting demonstrations

## Product Demo Data

### Product Categories
The service provides demo products across three main categories:

#### Men's Wear Products
```dart
Product(
  id: '1',
  name: 'Custom Suit - 3 Piece',
  description: 'Complete 3-piece suit with jacket, vest, and trousers. Premium wool fabric with perfect tailoring.',
  category: ProductCategory.mensWear,
  basePrice: 15000.0,
  specifications: {
    'Fabric': 'Premium Wool',
    'Pieces': '3 (Jacket, Vest, Trousers)',
    'Delivery Time': '14-21 days',
    'Alterations': 'Included',
    'Measurements': 'Required'
  },
  availableSizes: ['38', '40', '42', '44', '46', '48'],
  availableFabrics: ['Wool', 'Cotton Blend', 'Polyester'],
  customizationOptions: [
    'Fabric Selection',
    'Style Options',
    'Color Choice',
    'Button Style',
    'Pocket Options'
  ]
)
```

#### Women's Wear Products
```dart
Product(
  id: '2',
  name: 'Wedding Lehenga',
  description: 'Beautiful wedding lehenga with heavy embroidery and traditional design. Perfect for special occasions.',
  category: ProductCategory.womensWear,
  basePrice: 25000.0,
  specifications: {
    'Fabric': 'Heavy Silk',
    'Embroidery': 'Gold & Silver Thread',
    'Delivery Time': '21-30 days',
    'Alterations': 'Included',
    'Measurements': 'Required'
  }
)
```

#### Alteration Services
```dart
Product(
  id: '5',
  name: 'Suit Alteration Service',
  description: 'Professional suit alteration service including jacket, trousers, and vest adjustments.',
  category: ProductCategory.alterations,
  basePrice: 2000.0,
  specifications: {
    'Service Type': 'Complete Suit Alteration',
    'Delivery Time': '3-7 days',
    'Warranty': '30 days',
    'Fitting': 'Included'
  }
)
```

### Product Specifications
Each demo product includes comprehensive specifications:

#### Common Specifications
- **Fabric Type**: Material composition and quality indicators
- **Delivery Time**: Expected production timeline
- **Alterations**: Whether alterations are included in base price
- **Measurements**: Whether customer measurements are required

#### Category-Specific Specifications
- **Men's Wear**: Fit type, care instructions
- **Women's Wear**: Embroidery details, occasion suitability
- **Alterations**: Warranty period, service inclusions

### Customization Options
Products include extensive customization possibilities:

```dart
customizationOptions: [
  'Fabric Selection',
  'Style Options',
  'Color Choice',
  'Button Style',
  'Pocket Options'
]
```

## Customer Demo Data

### Customer Profiles
The service provides three diverse customer profiles representing different segments:

#### High-Value Customer (Rajesh Kumar)
```dart
Customer(
  id: '1',
  name: 'Rajesh Kumar',
  email: 'rajesh@example.com',
  phone: '+91 9876543210',
  measurements: {
    'chest': 40.0,
    'waist': 34.0,
    'shoulder': 18.0,
    'length': 28.0,
    'inseam': 32.0,
  },
  preferences: ['Formal Wear', 'Cotton Fabrics', 'Dark Colors'],
  totalSpent: 45000.0,
  loyaltyTier: LoyaltyTier.gold,
  isActive: true,
)
```

#### Premium Customer (Priya Sharma)
```dart
Customer(
  id: '2',
  name: 'Priya Sharma',
  email: 'priya@example.com',
  phone: '+91 8765432109',
  measurements: {
    'bust': 36.0,
    'waist': 28.0,
    'hips': 38.0,
    'shoulder': 14.0,
    'length': 42.0,
  },
  preferences: ['Traditional Wear', 'Bright Colors', 'Heavy Work'],
  totalSpent: 75000.0,
  loyaltyTier: LoyaltyTier.platinum,
)
```

#### Standard Customer (Amit Patel)
```dart
Customer(
  id: '3',
  name: 'Amit Patel',
  email: 'amit@example.com',
  phone: '+91 7654321098',
  measurements: {
    'chest': 42.0,
    'waist': 36.0,
    'shoulder': 19.0,
    'length': 29.0,
    'inseam': 33.0,
  },
  preferences: ['Business Casual', 'Light Fabrics', 'Navy Blue'],
  totalSpent: 15000.0,
  loyaltyTier: LoyaltyTier.silver,
)
```

### Customer Segmentation
The demo customers represent different market segments:

#### Loyalty Tiers
- **Platinum**: High-value customers (₹75,000+ spent)
- **Gold**: Regular high-value customers (₹45,000+ spent)
- **Silver**: Standard customers (₹15,000+ spent)

#### Measurement Standards
- **Men's Measurements**: Chest, waist, shoulder, length, inseam
- **Women's Measurements**: Bust, waist, hips, shoulder, length
- **Consistent Units**: All measurements in inches
- **Professional Standards**: Industry-standard measurement points

### Customer Preferences
Each customer includes preference data for personalized service:

```dart
preferences: ['Formal Wear', 'Cotton Fabrics', 'Dark Colors']
```

## Data Structure Integration

### Model Dependencies
```dart
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart';
```

### Product Model Integration
The demo products utilize all Product model fields:
- **Basic Information**: ID, name, description, category
- **Pricing**: Base price with customization pricing structure
- **Media**: Image URLs for visual representation
- **Specifications**: Technical details and requirements
- **Inventory**: Available sizes, fabrics, and options
- **Timestamps**: Creation and update tracking

### Customer Model Integration
Demo customers leverage complete Customer model:
- **Personal Information**: Name, contact details, profile photo
- **Measurements**: Complete measurement profiles
- **Preferences**: Style and fabric preferences
- **Loyalty Program**: Spending history and tier status
- **Lifecycle**: Creation dates and activity status

## Usage Examples

### Basic Demo Data Loading
```dart
class DemoDataManager {
  Future<void> loadDemoData() async {
    // Load demo products
    final products = DemoDataService.getDemoProducts();
    for (final product in products) {
      await ProductProvider().addProduct(product);
    }

    // Load demo customers
    final customers = DemoDataService.getDemoCustomers();
    for (final customer in customers) {
      await CustomerProvider().addCustomer(customer);
    }
  }
}
```

### Category-Specific Product Loading
```dart
class ProductCatalogManager {
  List<Product> getMensWearProducts() {
    final allProducts = DemoDataService.getDemoProducts();
    return allProducts.where((product) =>
      product.category == ProductCategory.mensWear
    ).toList();
  }

  List<Product> getWomensWearProducts() {
    final allProducts = DemoDataService.getDemoProducts();
    return allProducts.where((product) =>
      product.category == ProductCategory.womensWear
    ).toList();
  }

  List<Product> getAlterationServices() {
    final allProducts = DemoDataService.getDemoProducts();
    return allProducts.where((product) =>
      product.category == ProductCategory.alterations
    ).toList();
  }
}
```

### Customer Segmentation Management
```dart
class CustomerSegmentationManager {
  List<Customer> getHighValueCustomers() {
    final customers = DemoDataService.getDemoCustomers();
    return customers.where((customer) =>
      customer.loyaltyTier == LoyaltyTier.platinum ||
      customer.loyaltyTier == LoyaltyTier.gold
    ).toList();
  }

  List<Customer> getCustomersByPreference(String preference) {
    final customers = DemoDataService.getDemoCustomers();
    return customers.where((customer) =>
      customer.preferences.contains(preference)
    ).toList();
  }

  Map<LoyaltyTier, List<Customer>> segmentCustomersByTier() {
    final customers = DemoDataService.getDemoCustomers();
    return {
      LoyaltyTier.platinum: customers.where((c) => c.loyaltyTier == LoyaltyTier.platinum).toList(),
      LoyaltyTier.gold: customers.where((c) => c.loyaltyTier == LoyaltyTier.gold).toList(),
      LoyaltyTier.silver: customers.where((c) => c.loyaltyTier == LoyaltyTier.silver).toList(),
    };
  }
}
```

### Demo Data Validation
```dart
class DemoDataValidator {
  static bool validateDemoProducts() {
    final products = DemoDataService.getDemoProducts();

    for (final product in products) {
      if (!_isValidProduct(product)) {
        return false;
      }
    }

    return true;
  }

  static bool _isValidProduct(Product product) {
    return product.id.isNotEmpty &&
           product.name.isNotEmpty &&
           product.basePrice > 0 &&
           product.specifications.isNotEmpty &&
           product.availableSizes.isNotEmpty;
  }

  static bool validateDemoCustomers() {
    final customers = DemoDataService.getDemoCustomers();

    for (final customer in customers) {
      if (!_isValidCustomer(customer)) {
        return false;
      }
    }

    return true;
  }

  static bool _isValidCustomer(Customer customer) {
    return customer.id.isNotEmpty &&
           customer.name.isNotEmpty &&
           customer.email.isNotEmpty &&
           customer.measurements.isNotEmpty;
  }
}
```

### Analytics Dashboard Integration
```dart
class DemoAnalyticsManager {
  Map<String, dynamic> generateDemoAnalytics() {
    final products = DemoDataService.getDemoProducts();
    final customers = DemoDataService.getDemoCustomers();
    final stats = DemoDataService.getOrderStatistics();

    return {
      'totalProducts': products.length,
      'productsByCategory': _categorizeProducts(products),
      'totalCustomers': customers.length,
      'customersByTier': _categorizeCustomers(customers),
      'revenueByCategory': _calculateRevenueByCategory(products),
      'averageProductPrice': _calculateAveragePrice(products),
      'topSellingCategories': _getTopCategories(products),
      'orderStats': stats,
    };
  }

  Map<ProductCategory, int> _categorizeProducts(List<Product> products) {
    return products.fold<Map<ProductCategory, int>>({}, (map, product) {
      map[product.category] = (map[product.category] ?? 0) + 1;
      return map;
    });
  }

  Map<LoyaltyTier, int> _categorizeCustomers(List<Customer> customers) {
    return customers.fold<Map<LoyaltyTier, int>>({}, (map, customer) {
      map[customer.loyaltyTier] = (map[customer.loyaltyTier] ?? 0) + 1;
      return map;
    });
  }

  Map<ProductCategory, double> _calculateRevenueByCategory(List<Product> products) {
    return products.fold<Map<ProductCategory, double>>({}, (map, product) {
      map[product.category] = (map[product.category] ?? 0) + product.basePrice;
      return map;
    });
  }

  double _calculateAveragePrice(List<Product> products) {
    if (products.isEmpty) return 0.0;
    final total = products.fold<double>(0, (sum, product) => sum + product.basePrice);
    return total / products.length;
  }

  List<String> _getTopCategories(List<Product> products) {
    final categoryCount = _categorizeProducts(products);
    final sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedCategories.take(3).map((entry) => entry.key.toString()).toList();
  }
}
```

### Development Testing Utilities
```dart
class DevelopmentTestingUtils {
  static Future<void> populateDemoDataForTesting() async {
    // Clear existing data
    await _clearAllData();

    // Load demo data
    await DemoDataManager().loadDemoData();

    // Validate loaded data
    assert(DemoDataValidator.validateDemoProducts());
    assert(DemoDataValidator.validateDemoCustomers());

    debugPrint('Demo data populated successfully for testing');
  }

  static Future<void> _clearAllData() async {
    // Implementation to clear existing data
    await ProductProvider().clearAllProducts();
    await CustomerProvider().clearAllCustomers();
  }

  static Future<void> generateAdditionalDemoData(int count) async {
    final additionalProducts = _generateAdditionalProducts(count);
    final additionalCustomers = _generateAdditionalCustomers(count);

    for (final product in additionalProducts) {
      await ProductProvider().addProduct(product);
    }

    for (final customer in additionalCustomers) {
      await CustomerProvider().addCustomer(customer);
    }
  }

  static List<Product> _generateAdditionalProducts(int count) {
    // Generate additional demo products
    return List.generate(count, (index) => Product(
      id: 'generated_$index',
      name: 'Generated Product $index',
      description: 'Auto-generated demo product for testing',
      category: ProductCategory.mensWear,
      basePrice: 1000.0 + (index * 100),
      isActive: true,
      imageUrls: ['https://via.placeholder.com/300x300?text=Generated+$index'],
      specifications: {'Type': 'Generated', 'Index': index.toString()},
      availableSizes: ['M', 'L', 'XL'],
      availableFabrics: ['Cotton'],
      customizationOptions: ['Color'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }

  static List<Customer> _generateAdditionalCustomers(int count) {
    // Generate additional demo customers
    return List.generate(count, (index) => Customer(
      id: 'generated_customer_$index',
      name: 'Generated Customer $index',
      email: 'customer$index@example.com',
      phone: '+91 99999999$index',
      measurements: {'chest': 40.0 + index},
      preferences: ['Casual Wear'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      totalSpent: 0.0,
      loyaltyTier: LoyaltyTier.silver,
      isActive: true,
    ));
  }
}
```

## Integration Points

### Related Components
- **Product Provider**: Product catalog management and storage
- **Customer Provider**: Customer profile management
- **Order Provider**: Order creation using demo customer data
- **Analytics Service**: Business intelligence using demo data
- **Setup Demo Services**: Specialized demo data setup services

### Provider Integration
```dart
class DemoDataIntegrationManager {
  final ProductProvider _productProvider = ProductProvider();
  final CustomerProvider _customerProvider = CustomerProvider();

  Future<void> integrateDemoData() async {
    // Load demo products into provider
    final demoProducts = DemoDataService.getDemoProducts();
    for (final product in demoProducts) {
      await _productProvider.addProduct(product);
    }

    // Load demo customers into provider
    final demoCustomers = DemoDataService.getDemoCustomers();
    for (final customer in demoCustomers) {
      await _customerProvider.addCustomer(customer);
    }

    // Notify listeners of data changes
    _productProvider.notifyListeners();
    _customerProvider.notifyListeners();
  }
}
```

## Business Logic

### Demo Data Strategy
- **Realistic Scenarios**: Demo data reflects actual tailoring business patterns
- **Diverse Product Range**: Covers major product categories and price points
- **Customer Segmentation**: Represents different customer value tiers
- **Scalable Framework**: Easy to extend with additional demo scenarios

### Testing and Development
- **Rapid Prototyping**: Quick setup of realistic test data
- **Feature Validation**: Test new features with known data sets
- **Performance Testing**: Evaluate system performance with substantial data
- **Training Materials**: Provide consistent examples for user training

### Data Quality Assurance
- **Consistent Formatting**: Standardized data structure across all entities
- **Valid Relationships**: Proper relationships between products and categories
- **Realistic Values**: Pricing and measurements reflect market realities
- **Complete Profiles**: All required fields populated with appropriate data

This comprehensive demo data service provides the foundation for testing, development, and demonstration of the tailoring shop management system, ensuring consistent and realistic sample data across all application components.