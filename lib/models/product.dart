import 'package:flutter/material.dart';

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
          .toList() ?? [],
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
  final Map<String, String> badges; // e.g., {'new': 'New Arrival', 'bestseller': 'Best Seller'}
  final bool isActive;
  final bool isPopular;
  final bool isNewArrival;
  final bool isOnSale;
  final String brand;
  final DateTime createdAt;
  final DateTime updatedAt;

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
  }) : rating = rating ?? ProductRating(averageRating: 0.0, reviewCount: 0, recentReviews: []),
       badges = badges ?? {};

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: ProductCategory.values[json['category']],
      basePrice: json['basePrice'].toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      discountPercentage: json['discountPercentage']?.toDouble(),
      rating: json['rating'] != null ? ProductRating.fromJson(json['rating']) : null,
      stockCount: json['stockCount'] ?? 99,
      soldCount: json['soldCount'] ?? 0,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      availableSizes: List<String>.from(json['availableSizes'] ?? []),
      availableFabrics: List<String>.from(json['availableFabrics'] ?? []),
      customizationOptions: List<String>.from(json['customizationOptions'] ?? []),
      badges: Map<String, String>.from(json['badges'] ?? {}),
      isActive: json['isActive'] ?? true,
      isPopular: json['isPopular'] ?? false,
      isNewArrival: json['isNewArrival'] ?? false,
      isOnSale: json['isOnSale'] ?? false,
      brand: json['brand'] ?? '',
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
  double get savingsAmount => originalPrice != null ? (originalPrice! - basePrice) : 0.0;

  double get savingsPercentage => originalPrice != null ? ((originalPrice! - basePrice) / originalPrice! * 100).roundToDouble() : 0.0;

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
    if (discountPercentage != null && discountPercentage! > 0) result.add('${discountPercentage!.toStringAsFixed(0)}% OFF');
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
