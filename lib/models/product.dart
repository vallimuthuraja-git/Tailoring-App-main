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

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.imageUrls,
    required this.specifications,
    required this.availableSizes,
    required this.availableFabrics,
    required this.customizationOptions,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

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
