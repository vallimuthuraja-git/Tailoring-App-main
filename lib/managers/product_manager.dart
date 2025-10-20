import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/product_models.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_events.dart';
import '../blocs/product/product_states.dart';
import '../product_data_access.dart' as data_access;

/// Product Manager that orchestrates business logic and coordinates between
/// BLoC, repositories, and services
class ProductManager {
  // Core dependencies
  final data_access.ProductRepository _productRepository;
  final ProductBloc _productBloc;
  final Connectivity _connectivity;

  // Services
  final data_access.ProductAnalyticsService _analyticsService;
  final data_access.ProductCacheService _cacheService;
  final data_access.ProductSearchService _searchService;

  // State management
  final StreamController<ProductState> _stateController =
      StreamController<ProductState>.broadcast();

  // Pagination state
  int _currentPage = 0;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;
  final int _pageSize = 20;

  // Constructor
  ProductManager({
    required data_access.ProductRepository productRepository,
    required ProductBloc productBloc,
    required Connectivity connectivity,
    required data_access.ProductAnalyticsService analyticsService,
    required data_access.ProductCacheService cacheService,
    required data_access.ProductSearchService searchService,
  })  : _productRepository = productRepository,
        _productBloc = productBloc,
        _connectivity = connectivity,
        _analyticsService = analyticsService,
        _cacheService = cacheService,
        _searchService = searchService {
    _initialize();
  }

  // Initialization
  void _initialize() {
    // Listen to bloc state changes
    _productBloc.stream.listen((state) {
      _stateController.add(state);
    });

    // Initialize services
    _analyticsService.initialize();
    _cacheService.initialize();
  }

  // State streams
  Stream<ProductState> get productState => _stateController.stream;

  // Current bloc state
  ProductState get currentState => _productBloc.state;

  // Pagination getters
  int get currentPage => _currentPage;
  bool get hasMorePages => _hasMorePages;
  bool get isLoadingMore => _isLoadingMore;
  int get pageSize => _pageSize;

  // Product loading methods
  Future<void> loadProducts() async {
    _productBloc.add(const LoadProducts());
  }

  Future<void> loadProduct(String productId) async {
    _productBloc.add(LoadProduct(productId));
    // Track analytics
    await _analyticsService.trackProductView(productId);
  }

  Future<void> refreshProducts() async {
    _productBloc.add(const RefreshProducts());
  }

  Future<void> loadFeaturedProducts() async {
    _productBloc.add(const LoadFeaturedProducts());
  }

  Future<void> loadTopSellingProducts({int limit = 10}) async {
    _productBloc.add(LoadTopSellingProducts(limit));
  }

  // Pagination methods
  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasMorePages) return;

    _isLoadingMore = true;
    _currentPage++;

    try {
      _productBloc.add(LoadProductsPage(
        page: _currentPage,
        pageSize: _pageSize,
      ));
    } catch (e) {
      _currentPage--; // Revert on error
      _isLoadingMore = false;
      rethrow;
    }
  }

  Future<void> loadPreviousPage() async {
    if (_isLoadingMore || _currentPage <= 0) return;

    _isLoadingMore = true;
    _currentPage--;

    try {
      _productBloc.add(LoadProductsPage(
        page: _currentPage,
        pageSize: _pageSize,
      ));
    } catch (e) {
      _currentPage++; // Revert on error
      _isLoadingMore = false;
      rethrow;
    }
  }

  Future<void> resetPagination() async {
    _currentPage = 0;
    _hasMorePages = true;
    _isLoadingMore = false;
  }

  void updatePaginationState({bool? hasMorePages, bool? isLoadingMore}) {
    if (hasMorePages != null) _hasMorePages = hasMorePages;
    if (isLoadingMore != null) _isLoadingMore = isLoadingMore;
  }

  // Product CRUD operations
  Future<bool> addProduct(Product product) async {
    try {
      final addedProduct = await _productRepository.addProduct(product);

      // Add to bloc
      _productBloc.add(AddProduct(addedProduct));

      // Track analytics
      await _analyticsService.trackEvent(
        productId: product.id,
        eventType: data_access.eventPurchase,
        metadata: {'action': 'product_added'},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final updatedProduct = await _productRepository.updateProduct(product);

      // Update in bloc
      _productBloc.add(UpdateProduct(updatedProduct));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _productRepository.deleteProduct(productId);

      // Delete in bloc
      _productBloc.add(DeleteProduct(productId));

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleProductStatus(String productId) async {
    _productBloc.add(ToggleProductStatus(productId));
    return true;
  }

  // Search and filter
  Future<void> searchProducts(String query) async {
    _productBloc.add(SearchProducts(query));

    // Track search analytics
    await _analyticsService.trackEvent(
      productId: 'search',
      eventType: 'search',
      metadata: {'query': query},
    );
  }

  void clearFilters() {
    _productBloc.add(const ClearFilters());
  }

  // Analytics integration
  Future<void> trackProductView(String productId,
      {String? userId, String? source}) async {
    await _analyticsService.trackProductView(productId,
        userId: userId, source: source);
  }

  Future<void> trackAddToCart(String productId,
      {String? userId, int quantity = 1}) async {
    await _analyticsService.trackAddToCart(productId,
        userId: userId, quantity: quantity);
  }

  Future<void> trackPurchase(String productId,
      {String? userId, int quantity = 1, double? revenue}) async {
    await _analyticsService.trackPurchase(productId,
        userId: userId, quantity: quantity, revenue: revenue);
  }

  // Bulk operations
  Future<bool> bulkUpdateProducts(List<Product> products) async {
    try {
      await _productRepository.bulkUpdateProducts(products);
      _productBloc.add(BulkUpdateProducts(products));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> bulkDeleteProducts(List<String> productIds) async {
    try {
      await _productRepository.bulkDeleteProducts(productIds);
      _productBloc.add(BulkDeleteProducts(productIds));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sync operations
  Future<void> syncOfflineData() async {
    _productBloc.add(const SyncOfflineData());
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    return await _productRepository.getSyncStatus();
  }

  // Analytics data access
  Future<Map<String, int>> getProductAnalytics(String productId) async {
    return _analyticsService.getProductAnalytics();
  }

  Future<List<Map<String, dynamic>>> getTopPerformingProducts({
    int limit = 10,
    String metric = 'views',
  }) async {
    return await _analyticsService.getTopPerformingProducts(
        limit: limit, metric: metric);
  }

  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    return await _analyticsService.getAnalyticsSummary();
  }

  Future<List<String>> getTrendingProducts({int limit = 10}) async {
    return await _analyticsService.getTrendingProducts(limit: limit);
  }

  // Cache operations
  Future<void> preloadCache() async {
    // Preload popular products - would need product IDs
    // await _cacheService.preloadPopularProducts([]);
  }

  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    return _cacheService.getCacheStats();
  }

  // Search service integration
  Future<List<Product>> advancedSearch({
    String? query,
    ProductCategory? category,
    double? minPrice,
    double? maxPrice,
    List<String>? tags,
    String? sortBy,
    bool? ascending,
  }) async {
    // Create SearchOptions
    final searchOptions = data_access.SearchOptions(
      query: query ?? '',
      categories: category != null ? [category.name] : [],
      priceRange: (minPrice != null && maxPrice != null)
          ? RangeValues(minPrice, maxPrice)
          : null,
      sortBy: sortBy ?? 'relevance',
    );

    final searchResults = await _searchService.searchProducts(searchOptions);

    // Convert ProductSearchResult back to Product by fetching from repository
    final products = <Product>[];
    for (final result in searchResults) {
      final product = await _productRepository.getProductById(result.productId);
      if (product != null) {
        products.add(product);
      }
    }

    return products;
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    return await _searchService.getAutocompleteSuggestions(query);
  }

  // Utility methods
  Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty && results.first != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Cleanup
  void dispose() {
    _stateController.close();
    _productBloc.close();
  }
}
