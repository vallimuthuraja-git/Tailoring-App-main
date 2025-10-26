import '../product/product_models.dart';

class CartItem {
  final String id;
  final Product product;
  int quantity;
  final Map<String, dynamic> customizations;
  final String? notes;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.customizations,
    this.notes,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  // Calculate total price for this item (base price + customizations)
  double get totalPrice {
    double baseTotal = product.basePrice * quantity;
    // Add customization costs if any
    double customizationTotal = customizations.values
        .whereType<num>()
        .fold(0.0, (sum, price) => sum + (price).toDouble());
    return baseTotal + customizationTotal;
  }

  // Create copy with updated quantity
  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
      customizations: customizations,
      notes: notes,
      addedAt: addedAt,
    );
  }

  // Convert to OrderItem for order creation
  Map<String, dynamic> toOrderItemData() {
    return {
      'id': id,
      'productId': product.id,
      'productName': product.name,
      'category': product.category.toString().split('.').last,
      'price': product.basePrice,
      'quantity': quantity,
      'customizations': customizations,
      'notes': notes,
    };
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': product.id,
      'quantity': quantity,
      'customizations': customizations,
      'notes': notes,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json, Product product) {
    return CartItem(
      id: json['id'],
      product: product,
      quantity: json['quantity'] ?? 1,
      customizations: Map<String, dynamic>.from(json['customizations'] ?? {}),
      notes: json['notes'],
      addedAt: json['addedAt'] != null ? DateTime.parse(json['addedAt']) : null,
    );
  }
}
