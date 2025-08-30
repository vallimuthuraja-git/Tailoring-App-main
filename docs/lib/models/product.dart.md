# Product Model

## Overview
The `product.dart` file defines the core data structures for product management in the AI-Enabled Tailoring Shop Management System. It provides comprehensive product modeling with category classification, customization options, and complete serialization support for Firebase integration.

## Key Features

### Product Data Structure
- **Comprehensive Product Fields**: Complete product information with 13+ properties
- **Category Classification**: 8 distinct product categories covering all tailoring services
- **Customization Support**: Flexible customization options with pricing
- **Firebase Integration**: Complete JSON serialization/deserialization
- **Business Logic**: Computed properties and business rule validation

### Product Categories
- **Service Diversity**: 8 categories covering men's, women's, kids, formal, casual, traditional wear
- **Specialized Services**: Alterations and custom design services
- **Scalable Architecture**: Easy addition of new categories
- **Business Focus**: Categories aligned with tailoring industry standards

## Architecture Components

### ProductCategory Enum

#### Available Product Categories
```dart
enum ProductCategory {
  mensWear,        // Men's clothing items
  womensWear,      // Women's clothing items
  kidsWear,        // Children's clothing items
  formalWear,      // Business and formal attire
  casualWear,      // Casual and everyday wear
  traditionalWear, // Ethnic and traditional clothing
  alterations,     // Alteration and modification services
  customDesign     // Custom design and bespoke services
}
```

#### Category Business Applications
- **Men's Wear**: Shirts, trousers, jackets, traditional wear
- **Women's Wear**: Salwar kameez, sarees, dresses, blouses
- **Kids Wear**: School uniforms, party wear, casual clothing
- **Formal Wear**: Business suits, shirts, ties, corporate uniforms
- **Casual Wear**: T-shirts, jeans, casual shirts, everyday wear
- **Traditional Wear**: Ethnic clothing, wedding attire, cultural garments
- **Alterations**: Size modifications, fit adjustments, repairs
- **Custom Design**: Bespoke clothing, made-to-measure services

### Product Class

#### Core Product Properties
```dart
class Product {
  final String id;
  final String name;
  final String description;
  final ProductCategory category;
  final double basePrice;
  final List<String> imageUrls;
  final Map<String, dynamic> specifications;
  final List<String> availableSizes;
  final List<String> availableFabrics;
  final List<String> customizationOptions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Product Property Details

**Identity & Basic Information**
- **`id`**: Unique product identifier (Firebase document ID)
- **`name`**: Product display name (e.g., "Classic Cotton Shirt")
- **`description`**: Detailed product description with features and benefits
- **`category`**: Product classification using ProductCategory enum

**Pricing & Commerce**
- **`basePrice`**: Standard product price in rupees
- **`specifications`**: Technical details (material, care, origin, warranty)

**Product Variants**
- **`availableSizes`**: Size options (S, M, L, XL, XXL, or custom measurements)
- **`availableFabrics`**: Fabric choices (Cotton, Silk, Wool, etc.)
- **`customizationOptions`**: Personalization choices (collar style, cuff type, etc.)

**Status & Lifecycle**
- **`isActive`**: Product availability status
- **`createdAt`**: Product creation timestamp
- **`updatedAt`**: Last modification timestamp

### ProductCustomization Class

#### Customization Structure
```dart
class ProductCustomization {
  final String id;
  final String name;
  final String type; // 'color', 'size', 'fabric', 'style'
  final List<String> options;
  final double additionalPrice;
  final bool isRequired;
}
```

#### Customization Types
- **`color`**: Color selection options with visual swatches
- **`size`**: Size modifications or additional sizing options
- **`fabric`**: Alternative fabric choices with different pricing
- **`style`**: Style variations (collar type, sleeve length, etc.)

## JSON Serialization

### Product Serialization
```dart
factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    category: ProductCategory.values[json['category']],
    basePrice: json['basePrice'].toDouble(),
    imageUrls: List<String>.from(json['imageUrls'] ?? []),
    specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
    availableSizes: List<String>.from(json['availableSizes'] ?? []),
    availableFabrics: List<String>.from(json['availableFabrics'] ?? []),
    customizationOptions: List<String>.from(json['customizationOptions'] ?? []),
    isActive: json['isActive'] ?? true,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'name': name,
    'description': description,
    'category': category.index,
    'basePrice': basePrice,
    'imageUrls': imageUrls,
    'specifications': specifications,
    'availableSizes': availableSizes,
    'availableFabrics': availableFabrics,
    'customizationOptions': customizationOptions,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
```

### Customization Serialization
```dart
factory ProductCustomization.fromJson(Map<String, dynamic> json) {
  return ProductCustomization(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    options: List<String>.from(json['options'] ?? []),
    additionalPrice: json['additionalPrice'].toDouble(),
    isRequired: json['isRequired'] ?? false,
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'name': name,
    'type': type,
    'options': options,
    'additionalPrice': additionalPrice,
    'isRequired': isRequired,
  };
}
```

## Computed Properties

### Category Name Resolution
```dart
String get categoryName {
  switch (category) {
    case ProductCategory.mensWear:
      return "Men's Wear";
    case ProductCategory.womensWear:
      return "Women's Wear";
    case ProductCategory.kidsWear:
      return "Kids Wear";
    case ProductCategory.formalWear:
      return "Formal Wear";
    case ProductCategory.casualWear:
      return "Casual Wear";
    case ProductCategory.traditionalWear:
      return "Traditional Wear";
    case ProductCategory.alterations:
      return "Alterations";
    case ProductCategory.customDesign:
      return "Custom Design";
  }
}
```

## Data Integrity

### Firebase Integration
- **Document ID Handling**: Automatic ID assignment for new products
- **Timestamp Management**: ISO 8601 string conversion for Firebase
- **Enum Serialization**: Index-based enum storage for compatibility
- **Null Safety**: Default values for optional fields

### Data Validation
- **Type Safety**: Strong typing for all properties
- **Required Fields**: Essential fields marked as required
- **Default Values**: Sensible defaults for optional properties
- **List Handling**: Safe list conversion from JSON

## Business Logic

### Product Status Management
- **Active/Inactive States**: Product availability control
- **Soft Deletes**: Status-based product hiding instead of deletion
- **Bulk Operations**: Mass status updates for inventory management
- **Automated Rules**: Business rule-based status changes

### Pricing Strategy
- **Base Price Model**: Standard pricing with customization add-ons
- **Dynamic Pricing**: Category-based pricing strategies
- **Additional Costs**: Customization and premium option pricing
- **Transparent Pricing**: Clear price breakdown for customers

### Inventory Management
- **Size Availability**: Multiple size options tracking
- **Fabric Options**: Material choice management
- **Customization Tracking**: Available customization options
- **Stock Status**: Real-time availability monitoring

## Usage Examples

### Creating a New Product
```dart
final shirt = Product(
  id: 'unique-product-id',
  name: 'Classic Cotton Shirt',
  description: 'Premium quality cotton shirt perfect for everyday wear',
  category: ProductCategory.mensWear,
  basePrice: 1299.00,
  imageUrls: [
    'https://example.com/shirt1.jpg',
    'https://example.com/shirt2.jpg'
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
);
```

### Product Customization
```dart
final collarCustomization = ProductCustomization(
  id: 'collar-style-001',
  name: 'Collar Style',
  type: 'style',
  options: ['Regular Collar', 'Mandarin Collar', 'Button Down'],
  additionalPrice: 150.00,
  isRequired: false,
);
```

### Firebase Operations
```dart
// Save to Firebase
await firebaseService.addDocument('products', shirt.toJson());

// Load from Firebase
final doc = await firebaseService.getDocument('products', 'product-id');
final product = Product.fromJson(doc.data()!);
```

## Integration Points

### With Product Provider
- **Data Management**: CRUD operations via ProductProvider
  - Related: [`lib/providers/product_provider.dart`](../../providers/product_provider.md)
- **Search & Filtering**: Product discovery and filtering
- **Real-time Updates**: Live product data synchronization
- **State Management**: Provider-based product state handling

### With Product Catalog Screen
- **Display Logic**: Product information rendering
  - Related: [`lib/screens/catalog/product_catalog_screen.dart`](../../screens/catalog/product_catalog_screen.md)
- **Category Navigation**: Category-based product browsing
- **Search Integration**: Product search and discovery
- **Customization Display**: Available options presentation

### With Order System
- **Product Selection**: Order creation product integration
  - Related: [`lib/providers/order_provider.dart`](../../providers/order_provider.md)
- **Price Calculation**: Base price and customization pricing
- **Availability Checking**: Real-time product availability
- **Order Items**: Product information in order details

### With Analytics Dashboard
- **Product Metrics**: Analytics data source
  - Related: [`lib/screens/dashboard/analytics_dashboard_screen.dart`](../../screens/dashboard/analytics_dashboard_screen.md)
- **Category Analytics**: Product category performance tracking
- **Revenue Analysis**: Product-based financial metrics
- **Performance Insights**: Product popularity and trend analysis

## Performance Considerations

### Data Efficiency
- **Minimal Payloads**: Essential data only in JSON serialization
- **Indexed Categories**: Enum-based category storage for query performance
- **Optimized Lists**: Efficient list handling for large product catalogs
- **Timestamp Optimization**: ISO string format for Firebase compatibility

### Memory Management
- **Immutable Objects**: Final properties ensure data consistency
- **Efficient Collections**: List and Map optimizations
- **Serialization Performance**: Fast JSON conversion
- **Caching Strategy**: Product data caching for performance

## Future Enhancements

### Advanced Product Features
- **Product Variants**: Size, color, and style variants
- **Bulk Operations**: Mass product updates and management
- **Product Images**: Multiple image management with thumbnails
- **SEO Optimization**: Search engine friendly product data

### Business Intelligence
- **Product Analytics**: Advanced performance tracking
- **Recommendation Engine**: AI-powered product suggestions
- **Dynamic Pricing**: Automated price optimization
- **Inventory Forecasting**: Demand prediction and stock management

### Integration Features
- **Multi-Channel Sales**: E-commerce platform integration
- **Supplier Management**: Vendor and supplier data integration
- **Quality Control**: Product quality tracking and assurance
- **Sustainability Tracking**: Eco-friendly material certifications

---

*This Product model serves as the comprehensive data foundation for the tailoring shop's product catalog, providing robust data structures, business logic, and integration capabilities that support the entire product lifecycle from creation to analytics and customer purchasing.*