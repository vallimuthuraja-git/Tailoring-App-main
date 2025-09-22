import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product_models.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import 'dart:convert';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Calculated properties
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get cart item for a specific product
  CartItem? getCartItem(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Add product to cart
  Future<bool> addToCart(Product product,
      {int quantity = 1,
      Map<String, dynamic> customizations = const {},
      String? notes}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final existingItemIndex =
          _items.indexWhere((item) => item.product.id == product.id);

      if (existingItemIndex >= 0) {
        // Update existing item quantity
        final existingItem = _items[existingItemIndex];
        final updatedItem = CartItem(
          id: existingItem.id,
          product: product,
          quantity: existingItem.quantity + quantity,
          customizations: {...existingItem.customizations, ...customizations},
          notes: notes ?? existingItem.notes,
          addedAt: existingItem.addedAt,
        );
        _items[existingItemIndex] = updatedItem;
      } else {
        // Add new item
        final cartItem = CartItem(
          id: 'cart_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
          product: product,
          quantity: quantity,
          customizations: customizations,
          notes: notes,
        );
        _items.add(cartItem);
      }

      await _saveCartToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add item to cart: $e';
      notifyListeners();
      return false;
    }
  }

  // Update item quantity
  Future<bool> updateQuantity(String cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        return await removeFromCart(cartItemId);
      }

      final itemIndex = _items.indexWhere((item) => item.id == cartItemId);
      if (itemIndex >= 0) {
        final existingItem = _items[itemIndex];
        final updatedItem = CartItem(
          id: existingItem.id,
          product: existingItem.product,
          quantity: newQuantity,
          customizations: existingItem.customizations,
          notes: existingItem.notes,
          addedAt: existingItem.addedAt,
        );
        _items[itemIndex] = updatedItem;
        await _saveCartToStorage();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update quantity: $e';
      notifyListeners();
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String cartItemId) async {
    try {
      _items.removeWhere((item) => item.id == cartItemId);
      await _saveCartToStorage();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove item: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear entire cart
  Future<bool> clearCart() async {
    try {
      _items.clear();
      await _clearCartFromStorage();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to clear cart: $e';
      notifyListeners();
      return false;
    }
  }

  // Place order from cart
  Future<bool> placeOrderFromCart({
    required BuildContext context,
    required String customerId,
    required OrderProvider orderProvider,
    Map<String, dynamic>? measurements,
    String? specialInstructions,
    List<String>? orderImages,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_items.isEmpty) {
        _errorMessage = 'Cart is empty';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Convert cart items to order items
      final orderItems = _items.map((cartItem) {
        return OrderItem.fromJson(cartItem.toOrderItemData());
      }).toList();

      final success = await orderProvider.createOrder(
        customerId: customerId,
        items: orderItems,
        measurements: measurements ?? {},
        specialInstructions: specialInstructions,
        orderImages: orderImages ?? [],
      );

      if (success) {
        // Clear cart after successful order
        await clearCart();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to place order: $e';
      notifyListeners();
      return false;
    }
  }

  // Load cart from storage
  Future<void> loadCart() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart_items');

      if (cartData != null) {
        final List<dynamic> decodedData = json.decode(cartData);
        _items.clear();

        // Note: In a real app, you'd need to fetch the actual Product objects
        // from the ProductProvider or Firebase based on the productId
        // For now, we'll store basic product info in the cart persistence

        // This is a simplified version - you'd need proper product fetching
        for (final itemData in decodedData) {
          // Skip items without valid product data for now
          // In a full implementation, you'd fetch the product from the database
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load cart: $e';
      notifyListeners();
    }
  }

  // Save cart to storage
  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert cart items to storable format
      final cartData = _items.map((item) {
        return {
          'id': item.id,
          'productId': item.product.id,
          'productName': item.product.name,
          'productBasePrice': item.product.basePrice,
          'productCategory': item.product.category.index,
          'productImageUrl': item.product.imageUrls.isNotEmpty
              ? item.product.imageUrls.first
              : '',
          'quantity': item.quantity,
          'customizations': item.customizations,
          'notes': item.notes,
          'addedAt': item.addedAt.toIso8601String(),
        };
      }).toList();

      await prefs.setString('cart_items', json.encode(cartData));
      await prefs.setInt('cart_item_count', _items.length);
    } catch (e) {
      print('Error saving cart to storage: $e');
    }
  }

  // Clear cart from storage
  Future<void> _clearCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cart_items');
      await prefs.setInt('cart_item_count', 0);
    } catch (e) {
      print('Error clearing cart from storage: $e');
    }
  }

  // Get cart summary for display
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'estimatedAdvance': totalAmount * 0.3, // 30% advance
      'estimatedRemaining': totalAmount * 0.7,
    };
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get cart item count (for app bar badge, etc.)
  static Future<int> getCartItemCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('cart_item_count') ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
