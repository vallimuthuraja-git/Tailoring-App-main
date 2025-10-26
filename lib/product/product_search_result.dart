import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

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
