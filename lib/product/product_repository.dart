import 'dart:async';
import 'product_models.dart';
import '../services/firebase_service.dart';
import './firebase_product_repository.dart';

/// Abstract interface for product repository operations
abstract class IProductRepository {
  /// Get all products
  Future<List<Product>> getProducts();

  /// Get a single product by ID
  Future<Product?> getProductById(String id);

  /// Add a new product
  Future<Product> addProduct(Product product);

  /// Update an existing product
  Future<Product> updateProduct(Product product);

  /// Delete a product by ID
  Future<void> deleteProduct(String id);

  /// Search products by query
  Future<List<Product>> searchProducts(String query);

  /// Get products by category
  Future<List<Product>> getProductsByCategory(ProductCategory category);

  /// Get featured products (popular, new arrivals, on sale)
  Future<List<Product>> getFeaturedProducts();

  /// Stream of all products
  Stream<List<Product>> getProductsStream();

  /// Stream of a single product
  Stream<Product?> getProductStream(String id);

  /// Bulk update products
  Future<void> bulkUpdateProducts(List<Product> products);

  /// Bulk delete products
  Future<void> bulkDeleteProducts(List<String> ids);

  /// Get product analytics
  Future<Map<String, int>> getProductAnalytics();

  /// Get top selling products
  Future<List<Product>> getTopSellingProducts(int limit);
}

// Main product repository factory
class ProductRepository implements IProductRepository {
  final IProductRepository _repository;

  /// Factory constructor that delegates to FirebaseProductRepository
  factory ProductRepository() {
    final firebaseService = FirebaseService();
    return ProductRepository._internal(
        FirebaseProductRepository(firebaseService));
  }

  ProductRepository._internal(this._repository);

  // Delegate all methods to the actual repository implementation

  @override
  Future<List<Product>> getProducts() async => await _repository.getProducts();

  @override
  Future<Product?> getProductById(String id) async =>
      await _repository.getProductById(id);

  @override
  Future<Product> addProduct(Product product) async =>
      await _repository.addProduct(product);

  @override
  Future<Product> updateProduct(Product product) async =>
      await _repository.updateProduct(product);

  @override
  Future<void> deleteProduct(String id) async =>
      await _repository.deleteProduct(id);

  @override
  Future<List<Product>> searchProducts(String query) async =>
      await _repository.searchProducts(query);

  @override
  Future<List<Product>> getProductsByCategory(ProductCategory category) async =>
      await _repository.getProductsByCategory(category);

  @override
  Future<List<Product>> getFeaturedProducts() async =>
      await _repository.getFeaturedProducts();

  @override
  Stream<List<Product>> getProductsStream() => _repository.getProductsStream();

  @override
  Stream<Product?> getProductStream(String id) =>
      _repository.getProductStream(id);

  @override
  Future<void> bulkUpdateProducts(List<Product> products) async =>
      await _repository.bulkUpdateProducts(products);

  @override
  Future<void> bulkDeleteProducts(List<String> ids) async =>
      await _repository.bulkDeleteProducts(ids);

  @override
  Future<Map<String, int>> getProductAnalytics() async =>
      await _repository.getProductAnalytics();

  @override
  Future<List<Product>> getTopSellingProducts(int limit) async =>
      await _repository.getTopSellingProducts(limit);

  // Additional method for sync status (only available in Firebase repo)
  Future<Map<String, dynamic>> getSyncStatus() async {
    // Default implementation - can be overridden by actual repo
    return {};
  }
}
