import 'product_models.dart';
import 'product_repository.dart';

/// Service for product analytics and reporting
class ProductAnalyticsService {
  final IProductRepository _repository;

  ProductAnalyticsService(this._repository);

  /// Get comprehensive product analytics
  Future<Map<String, int>> getProductAnalytics() async {
    return await _repository.getProductAnalytics();
  }

  /// Get top selling products
  Future<List<Product>> getTopSellingProducts(int limit) async {
    return await _repository.getTopSellingProducts(limit);
  }

  /// Get sales performance by category
  Future<Map<String, dynamic>> getCategoryPerformance() async {
    final products = await _repository.getProducts();
    final categoryData = <String, dynamic>{};

    for (final product in products) {
      final categoryName = product.categoryName;
      if (!categoryData.containsKey(categoryName)) {
        categoryData[categoryName] = {
          'total_products': 0,
          'total_sales': 0,
          'total_revenue': 0.0,
          'average_rating': 0.0,
          'active_products': 0,
        };
      }

      final data = categoryData[categoryName];
      data['total_products'] += 1;
      data['total_sales'] += product.soldCount;
      data['total_revenue'] += product.basePrice * product.soldCount;
      data['average_rating'] =
          (data['average_rating'] + product.rating.averageRating) / 2;
      if (product.isActive) {
        data['active_products'] += 1;
      }
    }

    return categoryData;
  }

  /// Get inventory status report
  Future<Map<String, dynamic>> getInventoryStatus() async {
    final products = await _repository.getProducts();

    return {
      'total_products': products.length,
      'active_products': products.where((p) => p.isActive).length,
      'inactive_products': products.where((p) => !p.isActive).length,
      'out_of_stock': products.where((p) => p.stockCount == 0).length,
      'low_stock':
          products.where((p) => p.stockCount > 0 && p.stockCount <= 5).length,
      'in_stock': products.where((p) => p.stockCount > 5).length,
      'total_inventory_value': products.where((p) => p.isActive).fold(
            0.0,
            (sum, p) => sum + (p.basePrice * p.stockCount),
          ),
    };
  }

  /// Get performance metrics by time period
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    final products = await _repository.getProducts();

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentProducts =
        products.where((p) => p.createdAt.isAfter(thirtyDaysAgo)).toList();

    return {
      'total_products': products.length,
      'new_products_30_days': recentProducts.length,
      'featured_products': products
          .where((p) => p.isPopular || p.isNewArrival || p.isOnSale)
          .length,
      'average_rating': products.isEmpty
          ? 0.0
          : products
                  .map((p) => p.rating.averageRating)
                  .reduce((a, b) => a + b) /
              products.length,
      'total_sold': products.fold(0, (sum, p) => sum + p.soldCount),
      'total_revenue': products.fold(
        0.0,
        (sum, p) => sum + (p.basePrice * p.soldCount),
      ),
    };
  }

  /// Get popular search terms (mock implementation)
  Future<List<String>> getPopularSearchTerms() async {
    // In a real implementation, this would analyze search logs
    final products = await _repository.getProducts();
    final brands = products
        .map((p) => p.brand)
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();
    final categories = products.map((p) => p.categoryName).toSet().toList();

    return [...brands.take(5), ...categories.take(5)];
  }

  /// Get product recommendations based on analytics
  Future<List<Product>> getRecommendedProducts(
      String productId, int limit) async {
    final allProducts = await _repository.getProducts();
    final currentProduct =
        allProducts.where((p) => p.id == productId).firstOrNull;

    if (currentProduct == null) return [];

    // Simple recommendation logic: same category, high rating, popular
    final recommendations = allProducts
        .where((p) =>
            p.id != productId &&
            p.category == currentProduct.category &&
            p.rating.averageRating >= 4.0 &&
            (p.isPopular || p.isNewArrival))
        .toList();

    // Sort by rating and sold count
    recommendations.sort((a, b) {
      final aScore = a.rating.averageRating * 10 + a.soldCount;
      final bScore = b.rating.averageRating * 10 + b.soldCount;
      return bScore.compareTo(aScore);
    });

    return recommendations.take(limit).toList();
  }

  /// Get conversion funnel data
  Future<Map<String, int>> getConversionFunnel() async {
    final products = await _repository.getProducts();

    return {
      'total_views': products.fold(0, (sum, p) => sum + p.viewCount),
      'wishlist_adds': products.fold(0, (sum, p) => sum + p.wishlistCount),
      'cart_adds': products.fold(0, (sum, p) => sum + p.cartCount),
      'purchases': products.fold(0, (sum, p) => sum + p.soldCount),
    };
  }

  /// Get customer preference insights
  Future<Map<String, Map<String, int>>> getCustomerPreferences() async {
    final products = await _repository.getProducts();

    final sizePrefs = <String, int>{};
    final colorPrefs = <String, int>{};
    final fabricPrefs = <String, int>{};

    for (final product in products) {
      if (product.viewCount > 0) {
        // Aggregate preferences based on product attributes and view counts
        for (final size in product.availableSizes) {
          sizePrefs[size] = (sizePrefs[size] ?? 0) + product.viewCount.toInt();
        }

        // Note: product doesn't have colors/fabrics in the same way
        // This is a simplified implementation
        final color = 'default'; // Would need to be extracted from product data
        final fabric =
            'default'; // Would need to be extracted from product data

        colorPrefs[color] =
            (colorPrefs[color] ?? 0) + product.viewCount.toInt();
        fabricPrefs[fabric] =
            (fabricPrefs[fabric] ?? 0) + product.viewCount.toInt();
      }
    }

    return {
      'sizes': sizePrefs,
      'colors': colorPrefs,
      'fabrics': fabricPrefs,
    };
  }

  /// Initialize service (stub for compatibility)
  Future<void> initialize() async {
    // No-op: service doesn't need initialization
  }

  /// Track product view (stub for compatibility)
  Future<void> trackProductView(String productId,
      {String? userId, String? source}) async {
    // Stub implementation - would send to analytics service
  }

  /// Track product event (stub for compatibility)
  Future<void> trackEvent({
    required String productId,
    required String eventType,
    required Map<String, dynamic> metadata,
  }) async {
    // Stub implementation - would send to analytics service
  }

  /// Track add to cart (stub for compatibility)
  Future<void> trackAddToCart(String productId,
      {String? userId, int quantity = 1}) async {
    // Stub implementation - would send to analytics service
  }

  /// Track purchase (stub for compatibility)
  Future<void> trackPurchase(String productId,
      {String? userId, int quantity = 1, double? revenue}) async {
    // Stub implementation - would send to analytics service
  }

  /// Get analytics summary
  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    final analytics = await getCategoryPerformance();
    final conversion = await getConversionFunnel();

    return {
      'category_performance': analytics,
      'conversion_funnel': conversion,
      'top_performing_products': await getTopPerformingProducts(limit: 10),
      'performance_metrics': await getPerformanceMetrics(),
    };
  }

  /// Get top performing products by metric
  Future<List<Map<String, dynamic>>> getTopPerformingProducts({
    int limit = 10,
    String metric = 'views',
  }) async {
    final products = await _repository.getProducts();

    // Sort by metric
    switch (metric) {
      case 'views':
        products.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'sales':
        products.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case 'rating':
        products.sort(
            (a, b) => b.rating.averageRating.compareTo(a.rating.averageRating));
        break;
      default:
        products.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    }

    return products
        .take(limit)
        .map((p) => {
              'id': p.id,
              'name': p.name,
              'views': p.viewCount,
              'sales': p.soldCount,
              'rating': p.rating.averageRating,
            })
        .toList();
  }

  /// Get trending products
  Future<List<String>> getTrendingProducts({int limit = 10}) async {
    final products = await _repository.getProducts();
    products.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return products.take(limit).map((p) => p.id).toList();
  }
}
