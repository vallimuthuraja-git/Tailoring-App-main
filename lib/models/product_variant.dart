import 'package:equatable/equatable.dart';

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
