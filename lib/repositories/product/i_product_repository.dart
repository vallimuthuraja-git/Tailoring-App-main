import 'dart:async';
import '../../models/product_models.dart';

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
