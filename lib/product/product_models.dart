/// File: product_models.dart
/// Purpose: Core data models for product management including Product, ProductVariant, ProductReview, and search-related classes
/// Functionality: Defines the structure and behavior of products, their variants, reviews, ratings, and search functionality
/// Dependencies: Flutter Material, Equatable package
/// Usage: Used throughout the application to represent product data, handle serialization/deserialization, and manage product-related operations
library;

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum ProductCategory {
  mensWear,
  womensWear,
  kidsWear,
  formalWear,
  casualWear,
  traditionalWear,
  alterations,
  customDesign
}

class ProductRating {
  final double averageRating;
  final int reviewCount;
  final List<ProductReview> recentReviews;

  ProductRating({
    required this.averageRating,
    required this.reviewCount,
    required this.recentReviews,
  });

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      recentReviews: (json['recentReviews'] as List<dynamic>?)
              ?.map((review) => ProductReview.fromJson(review))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'recentReviews': recentReviews.map((review) => review.toJson()).toList(),
    };
  }
}

class ProductReview {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ProductReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final ProductCategory category;
  final double basePrice;
  final double? originalPrice; // For discount displays
  final double? discountPercentage;
  final ProductRating rating;
  final int stockCount;
  final int soldCount;
  final List<String> imageUrls;
  final Map<String, dynamic> specifications;
  final List<String> availableSizes;
  final List<String> availableFabrics;
  final List<String> customizationOptions;
  final Map<String, String>
      badges; // e.g., {'new': 'New Arrival', 'bestseller': 'Best Seller'}
  final bool isActive;
  final bool isPopular;
  final bool isNewArrival;
  final bool isOnSale;
  final String brand;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Analytics fields
  final int viewCount;
  final int wishlistCount;
  final int cartCount;
  final double conversionRate;
  final Map<String, int> categoryViews; // Views by category
  final Map<String, int> sizePreferences; // Size selection preferences
  final Map<String, int> colorPreferences; // Color selection preferences
  final Map<String, int> fabricPreferences; // Fabric selection preferences
  final List<DateTime> viewTimestamps; // Recent view timestamps
  final Map<String, dynamic> performanceMetrics; // Additional performance data

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.basePrice,
    this.originalPrice,
    this.discountPercentage,
    ProductRating? rating,
    this.stockCount = 99,
    this.soldCount = 0,
    required this.imageUrls,
    required this.specifications,
    required this.availableSizes,
    required this.availableFabrics,
    required this.customizationOptions,
    Map<String, String>? badges,
    required this.isActive,
    this.isPopular = false,
    this.isNewArrival = false,
    this.isOnSale = false,
    this.brand = '',
    required this.createdAt,
    required this.updatedAt,
    // Analytics fields with defaults
    this.viewCount = 0,
    this.wishlistCount = 0,
    this.cartCount = 0,
    this.conversionRate = 0.0,
    Map<String, int>? categoryViews,
    Map<String, int>? sizePreferences,
    Map<String, int>? colorPreferences,
    Map<String, int>? fabricPreferences,
    List<DateTime>? viewTimestamps,
    Map<String, dynamic>? performanceMetrics,
  })  : rating = rating ??
            ProductRating(
                averageRating: 0.0, reviewCount: 0, recentReviews: []),
        badges = badges ?? {},
        categoryViews = categoryViews ?? {},
        sizePreferences = sizePreferences ?? {},
        colorPreferences = colorPreferences ?? {},
        fabricPreferences = fabricPreferences ?? {},
        viewTimestamps = viewTimestamps ?? [],
        performanceMetrics = performanceMetrics ?? {};

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      // Handle category - could be int index or string name
      ProductCategory category;
      if (json['category'] is int) {
        category = ProductCategory.values[json['category']];
      } else if (json['category'] is String) {
        // Try to find by name
        category = ProductCategory.values.firstWhere(
          (cat) => cat.name == json['category'],
          orElse: () => ProductCategory.customDesign,
        );
      } else {
        category = ProductCategory.customDesign; // Default fallback
      }

      // Handle timestamps - could be Firestore Timestamp or ISO string
      DateTime createdAt;
      DateTime updatedAt;
      try {
        if (json['createdAt'] is String) {
          createdAt = DateTime.parse(json['createdAt']);
        } else {
          // Firestore Timestamp object
          createdAt = DateTime.now(); // Fallback for now
        }
      } catch (e) {
        createdAt = DateTime.now();
      }

      try {
        if (json['updatedAt'] is String) {
          updatedAt = DateTime.parse(json['updatedAt']);
        } else {
          // Firestore Timestamp object
          updatedAt = DateTime.now(); // Fallback for now
        }
      } catch (e) {
        updatedAt = DateTime.now();
      }

      return Product(
        id: json['id'] ?? '',
        name: json['name'] ?? 'Unknown Product',
        description: json['description'] ?? '',
        category: category,
        basePrice: (json['basePrice'] ?? 0.0).toDouble(),
        originalPrice: json['originalPrice']?.toDouble(),
        discountPercentage: json['discountPercentage']?.toDouble(),
        rating: json['rating'] != null
            ? ProductRating.fromJson(json['rating'])
            : ProductRating(
                averageRating: 0.0, reviewCount: 0, recentReviews: []),
        stockCount: json['stockCount'] ?? 99,
        soldCount: json['soldCount'] ?? 0,
        imageUrls: List<String>.from(json['imageUrls'] ?? []),
        specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
        availableSizes: List<String>.from(json['availableSizes'] ?? []),
        availableFabrics: List<String>.from(json['availableFabrics'] ?? []),
        customizationOptions:
            List<String>.from(json['customizationOptions'] ?? []),
        badges: Map<String, String>.from(json['badges'] ?? {}),
        isActive: json['isActive'] ?? true,
        isPopular: json['isPopular'] ?? false,
        isNewArrival: json['isNewArrival'] ?? false,
        isOnSale: json['isOnSale'] ?? false,
        brand: json['brand'] ?? '',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      // If parsing fails, create a minimal product with safe defaults
      debugPrint('Error parsing product JSON: $e');
      debugPrint('JSON data: $json');
      return Product(
        id: json['id'] ?? 'error_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Product Loading Error',
        description: 'There was an error loading this product',
        category: ProductCategory.customDesign,
        basePrice: 0.0,
        imageUrls: [],
        specifications: {},
        availableSizes: [],
        availableFabrics: [],
        customizationOptions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.index,
      'basePrice': basePrice,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'rating': rating.toJson(),
      'stockCount': stockCount,
      'soldCount': soldCount,
      'imageUrls': imageUrls,
      'specifications': specifications,
      'availableSizes': availableSizes,
      'availableFabrics': availableFabrics,
      'customizationOptions': customizationOptions,
      'badges': badges,
      'isActive': isActive,
      'isPopular': isPopular,
      'isNewArrival': isNewArrival,
      'isOnSale': isOnSale,
      'brand': brand,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

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

  // Computed properties for e-commerce display
  double get savingsAmount =>
      originalPrice != null ? (originalPrice! - basePrice) : 0.0;

  double get savingsPercentage => originalPrice != null
      ? ((originalPrice! - basePrice) / originalPrice! * 100).roundToDouble()
      : 0.0;

  String get formattedPrice {
    if (originalPrice != null && originalPrice! > basePrice) {
      return '₹${basePrice.toStringAsFixed(0)}';
    }
    return '₹${basePrice.toStringAsFixed(0)}';
  }

  String get formattedOriginalPrice {
    return originalPrice != null ? '₹${originalPrice!.toStringAsFixed(0)}' : '';
  }

  String get availabilityText {
    if (stockCount <= 0) return 'Out of Stock';
    if (stockCount <= 5) return 'Only $stockCount left in stock';
    return 'In Stock';
  }

  Color get availabilityColor {
    if (stockCount <= 0) return Colors.red;
    if (stockCount <= 5) return Colors.orange;
    return Colors.green;
  }

  List<String> get activeBadges {
    List<String> result = [];
    if (isNewArrival) result.add('NEW');
    if (isPopular) result.add('BESTSELLER');
    if (isOnSale) result.add('SALE');
    if (discountPercentage != null && discountPercentage! > 0) {
      result.add('${discountPercentage!.toStringAsFixed(0)}% OFF');
    }
    if (rating.averageRating >= 4.5) result.add('TOP RATED');
    result.addAll(badges.values);
    return result.take(2).toList(); // Limit to 2 badges for clean display
  }
}

class ProductCustomization {
  final String id;
  final String name;
  final String type; // 'color', 'size', 'fabric', 'style'
  final List<String> options;
  final double additionalPrice;
  final bool isRequired;

  ProductCustomization({
    required this.id,
    required this.name,
    required this.type,
    required this.options,
    required this.additionalPrice,
    required this.isRequired,
  });

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
}

/// Represents a specific variant of a product (size, color, fabric combination)
class ProductVariant extends Equatable {
  final String id;
  final String productId;
  final String sku; // Stock Keeping Unit
  final String size;
  final String color;
  final String fabric;
  final double additionalPrice;
  final int stockCount;
  final List<String> imageUrls;
  final Map<String, dynamic>
      attributes; // Additional variant-specific attributes
  final bool isActive;
  final bool isDefault;

  const ProductVariant({
    required this.id,
    required this.productId,
    required this.sku,
    required this.size,
    required this.color,
    required this.fabric,
    this.additionalPrice = 0.0,
    this.stockCount = 0,
    this.imageUrls = const [],
    this.attributes = const {},
    this.isActive = true,
    this.isDefault = false,
  });

  /// Get the display name for this variant
  String get displayName {
    return '$size - $color - $fabric';
  }

  /// Get the full price including base product price + variant additional price
  double getFullPrice(double basePrice) {
    return basePrice + additionalPrice;
  }

  /// Check if variant is available
  bool get isAvailable => isActive && stockCount > 0;

  /// Get formatted additional price
  String get formattedAdditionalPrice {
    if (additionalPrice == 0) return '';
    return additionalPrice > 0
        ? '+₹${additionalPrice.toStringAsFixed(0)}'
        : '-₹${additionalPrice.abs().toStringAsFixed(0)}';
  }

  /// Create a copy with modified fields
  ProductVariant copyWith({
    String? id,
    String? productId,
    String? sku,
    String? size,
    String? color,
    String? fabric,
    double? additionalPrice,
    int? stockCount,
    List<String>? imageUrls,
    Map<String, dynamic>? attributes,
    bool? isActive,
    bool? isDefault,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      size: size ?? this.size,
      color: color ?? this.color,
      fabric: fabric ?? this.fabric,
      additionalPrice: additionalPrice ?? this.additionalPrice,
      stockCount: stockCount ?? this.stockCount,
      imageUrls: imageUrls ?? this.imageUrls,
      attributes: attributes ?? this.attributes,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'sku': sku,
      'size': size,
      'color': color,
      'fabric': fabric,
      'additionalPrice': additionalPrice,
      'stockCount': stockCount,
      'imageUrls': imageUrls,
      'attributes': attributes,
      'isActive': isActive,
      'isDefault': isDefault,
    };
  }

  /// Create from JSON
  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      sku: json['sku'] ?? '',
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      fabric: json['fabric'] ?? '',
      additionalPrice: (json['additionalPrice'] ?? 0.0).toDouble(),
      stockCount: json['stockCount'] ?? 0,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
      isActive: json['isActive'] ?? true,
      isDefault: json['isDefault'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        sku,
        size,
        color,
        fabric,
        additionalPrice,
        stockCount,
        imageUrls,
        attributes,
        isActive,
        isDefault,
      ];
}

/// Represents a selected product variant for cart/order
class SelectedProductVariant extends Equatable {
  final ProductVariant variant;
  final String selectedSize;
  final String selectedColor;
  final String selectedFabric;
  final int quantity;

  const SelectedProductVariant({
    required this.variant,
    required this.selectedSize,
    required this.selectedColor,
    required this.selectedFabric,
    this.quantity = 1,
  });

  /// Get the total price for this selection
  double getTotalPrice(double baseProductPrice) {
    return (baseProductPrice + variant.additionalPrice) * quantity;
  }

  /// Check if this selection matches the variant
  bool matchesVariant(ProductVariant variant) {
    return this.variant.id == variant.id &&
        selectedSize == variant.size &&
        selectedColor == variant.color &&
        selectedFabric == variant.fabric;
  }

  @override
  List<Object?> get props => [
        variant,
        selectedSize,
        selectedColor,
        selectedFabric,
        quantity,
      ];
}

/// Represents a search result for products
class ProductSearchResult extends Equatable {
  final String productId;
  final String productName;
  final String productDescription;
  final String brand;
  final List<String> imageUrls;
  final double price;
  final double? originalPrice;
  final bool isActive;
  final bool isOnSale;
  final double relevanceScore; // 0.0 to 1.0
  final Map<String, dynamic> highlights; // Highlighted search terms
  final List<String> matchedFields; // Which fields matched the search

  const ProductSearchResult({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.brand,
    required this.imageUrls,
    required this.price,
    this.originalPrice,
    required this.isActive,
    required this.isOnSale,
    required this.relevanceScore,
    required this.highlights,
    required this.matchedFields,
  });

  /// Get formatted price for display
  String get formattedPrice {
    return '₹${price.toStringAsFixed(0)}';
  }

  /// Get formatted original price for display
  String get formattedOriginalPrice {
    return originalPrice != null ? '₹${originalPrice!.toStringAsFixed(0)}' : '';
  }

  /// Check if product is available
  bool get isAvailable => isActive;

  /// Get discount percentage if applicable
  double? get discountPercentage {
    if (originalPrice != null && originalPrice! > price) {
      return ((originalPrice! - price) / originalPrice! * 100);
    }
    return null;
  }

  /// Get highlighted text for a specific field
  String getHighlightedText(String fieldName) {
    return highlights[fieldName] ?? '';
  }

  /// Check if a specific field was matched
  bool fieldMatched(String fieldName) {
    return matchedFields.contains(fieldName);
  }

  @override
  List<Object?> get props => [
        productId,
        productName,
        productDescription,
        brand,
        imageUrls,
        price,
        originalPrice,
        isActive,
        isOnSale,
        relevanceScore,
        highlights,
        matchedFields,
      ];

  /// Create from JSON
  factory ProductSearchResult.fromJson(Map<String, dynamic> json) {
    return ProductSearchResult(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productDescription: json['productDescription'] ?? '',
      brand: json['brand'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      isActive: json['isActive'] ?? true,
      isOnSale: json['isOnSale'] ?? false,
      relevanceScore: (json['relevanceScore'] ?? 0.0).toDouble(),
      highlights: Map<String, dynamic>.from(json['highlights'] ?? {}),
      matchedFields: List<String>.from(json['matchedFields'] ?? []),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'brand': brand,
      'imageUrls': imageUrls,
      'price': price,
      'originalPrice': originalPrice,
      'isActive': isActive,
      'isOnSale': isOnSale,
      'relevanceScore': relevanceScore,
      'highlights': highlights,
      'matchedFields': matchedFields,
    };
  }
}

/// Search filters and options
class SearchOptions {
  final String query;
  final List<String> categories;
  final RangeValues? priceRange;
  final List<String> brands;
  final bool includeInactive;
  final String sortBy; // 'relevance', 'price_asc', 'price_desc', 'name'
  final int limit;
  final int offset;

  const SearchOptions({
    required this.query,
    this.categories = const [],
    this.priceRange,
    this.brands = const [],
    this.includeInactive = false,
    this.sortBy = 'relevance',
    this.limit = 20,
    this.offset = 0,
  });

  /// Check if any filters are applied
  bool get hasFilters =>
      categories.isNotEmpty ||
      priceRange != null ||
      brands.isNotEmpty ||
      includeInactive;

  /// Create a copy with modified fields
  SearchOptions copyWith({
    String? query,
    List<String>? categories,
    RangeValues? priceRange,
    List<String>? brands,
    bool? includeInactive,
    String? sortBy,
    int? limit,
    int? offset,
  }) {
    return SearchOptions(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      priceRange: priceRange ?? this.priceRange,
      brands: brands ?? this.brands,
      includeInactive: includeInactive ?? this.includeInactive,
      sortBy: sortBy ?? this.sortBy,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}
