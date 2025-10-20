import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product_models.dart';
import 'i_product_repository.dart';

/// Offline implementation of product repository for local storage
class OfflineProductRepository implements IProductRepository {
  static const String _productsKey = 'offline_products';
  static const String _analyticsKey = 'offline_product_analytics';

  late final SharedPreferences _prefs;
  final Map<String, Product> _products = {};
  final Map<String, int> _analytics = {};

  OfflineProductRepository();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      // Load products
      final productsJson = _prefs.getString(_productsKey);
      if (productsJson != null) {
        final List<dynamic> productsData = jsonDecode(productsJson);
        for (final productData in productsData) {
          try {
            final product = Product.fromJson(productData);
            _products[product.id] = product;
          } catch (e) {
            debugPrint('Error parsing offline product: $e');
          }
        }
      }

      // Load analytics
      final analyticsJson = _prefs.getString(_analyticsKey);
      if (analyticsJson != null) {
        final Map<String, dynamic> analyticsData = jsonDecode(analyticsJson);
        analyticsData.forEach((key, value) {
          _analytics[key] = value as int;
        });
      }
    } catch (e) {
      debugPrint('Error loading offline products: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      // Save products
      final productsData = _products.values.map((p) => p.toJson()).toList();
      await _prefs.setString(_productsKey, jsonEncode(productsData));

      // Save analytics
      await _prefs.setString(_analyticsKey, jsonEncode(_analytics));
    } catch (e) {
      debugPrint('Error saving offline products: $e');
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    return _products.values.where((p) => p.isActive).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    return _products[id];
  }

  @override
  Future<Product> addProduct(Product product) async {
    _products[product.id] = product;
    await _saveToStorage();
    return product;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    _products[product.id] = product;
    await _saveToStorage();
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.remove(id);
    await _saveToStorage();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final lowerQuery = query.toLowerCase();
    return _products.values.where((product) {
      return product.isActive &&
          (product.name.toLowerCase().contains(lowerQuery) ||
              product.description.toLowerCase().contains(lowerQuery) ||
              product.brand.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  @override
  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    return _products.values
        .where((product) => product.isActive && product.category == category)
        .toList();
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    return _products.values
        .where((product) =>
            product.isActive &&
            (product.isPopular || product.isNewArrival || product.isOnSale))
        .toList();
  }

  @override
  Stream<List<Product>> getProductsStream() {
    // Offline repository doesn't support real-time streams
    // Return a stream that emits current data once
    return Stream.value(_products.values.where((p) => p.isActive).toList());
  }

  @override
  Stream<Product?> getProductStream(String id) {
    // Offline repository doesn't support real-time streams
    return Stream.value(_products[id]);
  }

  @override
  Future<void> bulkUpdateProducts(List<Product> products) async {
    for (final product in products) {
      _products[product.id] = product;
    }
    await _saveToStorage();
  }

  @override
  Future<void> bulkDeleteProducts(List<String> ids) async {
    for (final id in ids) {
      _products.remove(id);
    }
    await _saveToStorage();
  }

  @override
  Future<Map<String, int>> getProductAnalytics() async {
    // Calculate analytics from current data
    final products = await getProducts();

    _analytics.clear();
    _analytics['total_products'] = products.length;
    _analytics['active_products'] = products.where((p) => p.isActive).length;
    _analytics['inactive_products'] = products.where((p) => !p.isActive).length;
    _analytics['featured_products'] =
        products.where((p) => p.isPopular || p.isNewArrival).length;
    _analytics['out_of_stock'] =
        products.where((p) => p.stockCount == 0).length;

    await _saveToStorage();
    return Map.from(_analytics);
  }

  @override
  Future<List<Product>> getTopSellingProducts(int limit) async {
    final products = (await getProducts()).where((p) => p.isActive).toList()
      ..sort((a, b) => b.soldCount.compareTo(a.soldCount));

    return products.take(limit).toList();
  }

  /// Clear all offline data
  Future<void> clearAllData() async {
    _products.clear();
    _analytics.clear();
    await _prefs.remove(_productsKey);
    await _prefs.remove(_analyticsKey);
  }

  /// Sync products from another repository (e.g., Firebase)
  Future<void> syncFromOnline(List<Product> onlineProducts) async {
    for (final product in onlineProducts) {
      _products[product.id] = product;
    }
    await _saveToStorage();
  }

  /// Check if there's offline data available
  Future<bool> hasOfflineData() async {
    await _loadFromStorage();
    return _products.isNotEmpty;
  }

  /// Clear all offline data
  Future<void> clearOfflineData() async {
    _products.clear();
    _analytics.clear();
    await _prefs.remove(_productsKey);
    await _prefs.remove(_analyticsKey);
  }

  /// Get last sync time (return last modified time of any product)
  DateTime? getLastSyncTime() {
    if (_products.isEmpty) return null;

    DateTime? latest;
    for (final product in _products.values) {
      if (latest == null || product.updatedAt.isAfter(latest)) {
        latest = product.updatedAt;
      }
    }
    return latest;
  }

  /// Check if there are any pending sync operations
  Future<bool> hasPendingSync() async {
    // Simple implementation: check if we have data
    return await hasOfflineData();
  }
}


