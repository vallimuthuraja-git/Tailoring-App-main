import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../models/product_models.dart';
import 'i_product_repository.dart';
import 'firebase_product_repository.dart';
import 'offline_product_repository.dart';

// Export repository classes for convenience
export 'firebase_product_repository.dart';
export 'offline_product_repository.dart';

/// Facade repository that combines online and offline storage
/// Automatically falls back to offline when online is unavailable
class ProductRepository implements IProductRepository {
  final FirebaseProductRepository _onlineRepo;
  final OfflineProductRepository _offlineRepo;
  final Connectivity _connectivity;

  ProductRepository(this._onlineRepo, this._offlineRepo, this._connectivity);

  /// Check if device is online
  Future<bool> _isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      debugPrint(
          'Repository connectivity result: $results, type: ${results.runtimeType}');
      return results.isNotEmpty && results.first != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  /// Get repository based on connectivity
  Future<IProductRepository> _getRepository() async {
    final isOnline = await _isOnline();
    return isOnline ? _onlineRepo : _offlineRepo;
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      final repo = await _getRepository();
      final products = await repo.getProducts();

      // If we got data from online, sync to offline for future use
      if (repo == _onlineRepo && products.isNotEmpty) {
        try {
          await _offlineRepo.syncFromOnline(products);
          debugPrint('✅ Synced ${products.length} products to offline storage');
        } catch (e) {
          debugPrint('⚠️ Failed to sync products to offline: $e');
        }
      }

      return products;
    } catch (e) {
      debugPrint(
          '❌ Failed to get products from primary repository, trying fallback...');

      // Try fallback repository
      try {
        final fallbackRepo = await _isOnline() ? _offlineRepo : _onlineRepo;
        final products = await fallbackRepo.getProducts();
        debugPrint(
            '✅ Retrieved ${products.length} products from fallback repository');
        return products;
      } catch (fallbackError) {
        debugPrint('❌ Both repositories failed: $fallbackError');
        throw Exception(
            'Failed to load products from both online and offline storage');
      }
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final repo = await _getRepository();
      return await repo.getProductById(id);
    } catch (e) {
      debugPrint(
          '❌ Failed to get product from primary repository, trying fallback...');

      // Try fallback repository
      try {
        final fallbackRepo = await _isOnline() ? _offlineRepo : _onlineRepo;
        return await fallbackRepo.getProductById(id);
      } catch (fallbackError) {
        debugPrint('❌ Both repositories failed: $fallbackError');
        throw Exception('Failed to load product from both repositories');
      }
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    // Always try to add to online first if available
    final isOnline = await _isOnline();

    if (isOnline) {
      try {
        final addedProduct = await _onlineRepo.addProduct(product);

        // Sync to offline storage
        try {
          await _offlineRepo.addProduct(addedProduct);
          debugPrint('✅ Synced new product to offline storage');
        } catch (e) {
          debugPrint('⚠️ Failed to sync product to offline: $e');
        }

        return addedProduct;
      } catch (e) {
        debugPrint('❌ Failed to add product online, storing offline only...');
        // Fall back to offline storage
        return await _offlineRepo.addProduct(product);
      }
    } else {
      // Store offline only
      debugPrint('📱 Device offline, storing product locally');
      return await _offlineRepo.addProduct(product);
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final isOnline = await _isOnline();

    if (isOnline) {
      try {
        final updatedProduct = await _onlineRepo.updateProduct(product);

        // Sync to offline storage
        try {
          await _offlineRepo.updateProduct(updatedProduct);
          debugPrint('✅ Synced updated product to offline storage');
        } catch (e) {
          debugPrint('⚠️ Failed to sync updated product to offline: $e');
        }

        return updatedProduct;
      } catch (e) {
        debugPrint(
            '❌ Failed to update product online, updating offline only...');
        // Fall back to offline storage
        return await _offlineRepo.updateProduct(product);
      }
    } else {
      // Update offline only
      debugPrint('📱 Device offline, updating product locally');
      return await _offlineRepo.updateProduct(product);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    final isOnline = await _isOnline();

    if (isOnline) {
      try {
        await _onlineRepo.deleteProduct(id);

        // Sync to offline storage
        try {
          await _offlineRepo.deleteProduct(id);
          debugPrint('✅ Synced product deletion to offline storage');
        } catch (e) {
          debugPrint('⚠️ Failed to sync product deletion to offline: $e');
        }
      } catch (e) {
        debugPrint(
            '❌ Failed to delete product online, deleting offline only...');
        await _offlineRepo.deleteProduct(id);
      }
    } else {
      // Delete offline only
      debugPrint('📱 Device offline, deleting product locally');
      await _offlineRepo.deleteProduct(id);
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final repo = await _getRepository();
      return await repo.searchProducts(query);
    } catch (e) {
      debugPrint(
          '❌ Failed to search products in primary repository, trying fallback...');

      try {
        final fallbackRepo = await _isOnline() ? _offlineRepo : _onlineRepo;
        return await fallbackRepo.searchProducts(query);
      } catch (fallbackError) {
        debugPrint('❌ Both repositories failed: $fallbackError');
        throw Exception('Failed to search products in both repositories');
      }
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    try {
      final repo = await _getRepository();
      return await repo.getProductsByCategory(category);
    } catch (e) {
      debugPrint(
          '❌ Failed to get products by category from primary repository, trying fallback...');

      try {
        final fallbackRepo = await _isOnline() ? _offlineRepo : _onlineRepo;
        return await fallbackRepo.getProductsByCategory(category);
      } catch (fallbackError) {
        debugPrint('❌ Both repositories failed: $fallbackError');
        throw Exception(
            'Failed to get products by category from both repositories');
      }
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final repo = await _getRepository();
      return await repo.getFeaturedProducts();
    } catch (e) {
      debugPrint(
          '❌ Failed to get featured products from primary repository, trying fallback...');

      try {
        final fallbackRepo = await _isOnline() ? _offlineRepo : _onlineRepo;
        return await fallbackRepo.getFeaturedProducts();
      } catch (fallbackError) {
        debugPrint('❌ Both repositories failed: $fallbackError');
        throw Exception(
            'Failed to get featured products from both repositories');
      }
    }
  }

  @override
  Stream<List<Product>> getProductsStream() {
    // Prefer online stream if available
    return _onlineRepo.getProductsStream();
  }

  @override
  Stream<Product?> getProductStream(String id) {
    // Prefer online stream if available
    return _onlineRepo.getProductStream(id);
  }

  @override
  Future<void> bulkUpdateProducts(List<Product> products) async {
    final isOnline = await _isOnline();

    if (isOnline) {
      try {
        await _onlineRepo.bulkUpdateProducts(products);

        // Sync to offline storage
        try {
          await _offlineRepo.bulkUpdateProducts(products);
          debugPrint('✅ Synced bulk update to offline storage');
        } catch (e) {
          debugPrint('⚠️ Failed to sync bulk update to offline: $e');
        }
      } catch (e) {
        debugPrint('❌ Failed to bulk update online, updating offline only...');
        await _offlineRepo.bulkUpdateProducts(products);
      }
    } else {
      debugPrint('📱 Device offline, bulk updating locally');
      await _offlineRepo.bulkUpdateProducts(products);
    }
  }

  @override
  Future<void> bulkDeleteProducts(List<String> ids) async {
    final isOnline = await _isOnline();

    if (isOnline) {
      try {
        await _onlineRepo.bulkDeleteProducts(ids);

        // Sync to offline storage
        try {
          await _offlineRepo.bulkDeleteProducts(ids);
          debugPrint('✅ Synced bulk deletion to offline storage');
        } catch (e) {
          debugPrint('⚠️ Failed to sync bulk deletion to offline: $e');
        }
      } catch (e) {
        debugPrint('❌ Failed to bulk delete online, deleting offline only...');
        await _offlineRepo.bulkDeleteProducts(ids);
      }
    } else {
      debugPrint('📱 Device offline, bulk deleting locally');
      await _offlineRepo.bulkDeleteProducts(ids);
    }
  }

  @override
  Future<Map<String, int>> getProductAnalytics() async {
    try {
      final repo = await _getRepository();
      return await repo.getProductAnalytics();
    } catch (e) {
      debugPrint(
          '❌ Failed to get analytics from primary repository, trying fallback...');

      try {
        final fallbackRepo = await _isOnline() ? _offlineRepo : _onlineRepo;
        return await fallbackRepo.getProductAnalytics();
      } catch (fallbackError) {
        debugPrint('❌ Both repositories failed: $fallbackError');
        throw Exception('Failed to get analytics from both repositories');
      }
    }
  }

  @override
  Future<List<Product>> getTopSellingProducts(int limit) async {
    try {
      final repo = await _getRepository();
      return await repo.getTopSellingProducts(limit);
    } catch (e) {
      debugPrint(
          '❌ Failed to get top selling products from primary repository, trying fallback...');

      try {
        final fallbackRepo = await _isOnline() ? _offlineRepo : _onlineRepo;
        return await fallbackRepo.getTopSellingProducts(limit);
      } catch (fallbackError) {
        debugPrint('❌ Both repositories failed: $fallbackError');
        throw Exception(
            'Failed to get top selling products from both repositories');
      }
    }
  }

  /// Sync offline data to online when connection is restored
  Future<void> syncOfflineDataToOnline() async {
    final isOnline = await _isOnline();
    if (!isOnline) {
      debugPrint('⚠️ Cannot sync: device is offline');
      return;
    }

    try {
      debugPrint('🔄 Syncing offline data to online...');

      // Check if there's offline data to sync
      final hasOfflineData = await _offlineRepo.hasOfflineData();
      if (!hasOfflineData) {
        debugPrint('ℹ️ No offline data to sync');
        return;
      }

      final offlineProducts = await _offlineRepo.getProducts();
      debugPrint('📤 Syncing ${offlineProducts.length} products to online...');

      // Sync each product
      for (final product in offlineProducts) {
        try {
          await _onlineRepo.addProduct(product);
          debugPrint('✅ Synced product: ${product.name}');
        } catch (e) {
          if (e.toString().contains('already exists')) {
            // Product already exists online, update it instead
            try {
              await _onlineRepo.updateProduct(product);
              debugPrint('✅ Updated existing product: ${product.name}');
            } catch (updateError) {
              debugPrint(
                  '❌ Failed to update product ${product.name}: $updateError');
            }
          } else {
            debugPrint('❌ Failed to sync product ${product.name}: $e');
          }
        }
      }

      // Clear offline data after successful sync
      await _offlineRepo.clearOfflineData();
      debugPrint('✅ Successfully synced all offline data to online');
    } catch (e) {
      debugPrint('❌ Failed to sync offline data to online: $e');
      throw Exception('Failed to sync offline data to online: $e');
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final isOnline = await _isOnline();
    final hasOfflineData = await _offlineRepo.hasOfflineData();
    final lastSyncTime = _offlineRepo.getLastSyncTime();

    return {
      'isOnline': isOnline,
      'hasOfflineData': hasOfflineData,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'needsSync': hasOfflineData && isOnline,
    };
  }
}
