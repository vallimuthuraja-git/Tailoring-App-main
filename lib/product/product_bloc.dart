/// File: product_bloc.dart
/// Purpose: Business logic component for product management using BLoC pattern
/// Functionality: Manages product operations, state transitions, caching, filtering, searching, and offline/online synchronization
/// Dependencies: Flutter BLoC, connectivity_plus, product models, product repository, product events and states
/// Usage: Used as the central state manager for all product-related operations in the application
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'product_models.dart';
import 'product_repository.dart';
import 'product_events.dart';
import 'product_states.dart';

/// ProductBloc handles all product-related business logic using BLoC pattern
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final IProductRepository _productRepository;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<List<Product>>? _productsSubscription;
  Timer? _connectivityDebounceTimer; // Debounce connectivity changes

  // Cached data
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  ProductCategory? _selectedCategory;
  List<String> _productIds = []; // Track product IDs for change detection
  bool _currentOnlineStatus = false; // Cache connectivity status

  ProductBloc({
    required IProductRepository productRepository,
    required Connectivity connectivity,
  })  : _productRepository = productRepository,
        _connectivity = connectivity,
        super(const ProductInitial()) {
    // Register event handlers
    on<LoadProducts>(_onLoadProducts);
    on<LoadProduct>(_onLoadProduct);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<LoadFeaturedProducts>(_onLoadFeaturedProducts);
    on<ToggleProductStatus>(_onToggleProductStatus);
    on<BulkUpdateProducts>(_onBulkUpdateProducts);
    on<BulkDeleteProducts>(_onBulkDeleteProducts);
    on<LoadProductAnalytics>(_onLoadProductAnalytics);
    on<LoadTopSellingProducts>(_onLoadTopSellingProducts);
    on<ClearFilters>(_onClearFilters);
    on<RefreshProducts>(_onRefreshProducts);
    on<SyncOfflineData>(_onSyncOfflineData);
    on<ConnectivityStatusChanged>(_onConnectivityStatusChanged);

    // Initialize connectivity monitoring
    _initializeConnectivityMonitoring();
  }

  void _initializeConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.isNotEmpty) {
          final isOnline = results.first != ConnectivityResult.none;
          // Debounce connectivity changes to prevent spam
          _connectivityDebounceTimer?.cancel();
          _connectivityDebounceTimer =
              Timer(const Duration(milliseconds: 500), () {
            if (isOnline != _currentOnlineStatus) {
              _currentOnlineStatus = isOnline;
              add(ConnectivityStatusChanged(isOnline));
            }
          });
        }
      },
    );
  }

  Future<bool> _isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      debugPrint(
          'Bloc connectivity result: $results, type: ${results.runtimeType}');
      return results.isNotEmpty && results.first != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductState> emit) async {
    emit(const ProductLoading());

    try {
      final isOnline = await _isOnline();
      final products = await _productRepository.getProducts();
      _allProducts = products;
      _productIds = products.map((p) => p.id).toList();

      // Apply current filters if any
      _applyFilters();

      emit(ProductsLoaded(
        products:
            _filteredProducts.isNotEmpty ? _filteredProducts : _allProducts,
        isOnline: isOnline,
        hasOfflineData: true, // TODO: Check actual offline data status
      ));

      // Set up real-time subscription if online
      if (isOnline) {
        _setupProductsSubscription();
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      emit(ProductError(message: 'Failed to load products: $e'));
    }
  }

  Future<void> _onLoadProduct(
      LoadProduct event, Emitter<ProductState> emit) async {
    emit(const ProductLoading());

    try {
      final product = await _productRepository.getProductById(event.productId);
      if (product != null) {
        emit(ProductLoaded(product));
      } else {
        emit(const ProductError(message: 'Product not found'));
      }
    } catch (e) {
      debugPrint('Error loading product: $e');
      emit(ProductError(message: 'Failed to load product: $e'));
    }
  }

  Future<void> _onAddProduct(
      AddProduct event, Emitter<ProductState> emit) async {
    try {
      final addedProduct = await _productRepository.addProduct(event.product);
      _allProducts.add(addedProduct);

      emit(ProductOperationSuccess(
        message: 'Product added successfully',
        product: addedProduct,
      ));

      // Reload products to refresh the list
      add(const LoadProducts());
    } catch (e) {
      debugPrint('Error adding product: $e');
      emit(ProductError(message: 'Failed to add product: $e'));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event, Emitter<ProductState> emit) async {
    try {
      final updatedProduct =
          await _productRepository.updateProduct(event.product);

      // Update in local cache
      final index = _allProducts.indexWhere((p) => p.id == event.product.id);
      if (index != -1) {
        _allProducts[index] = updatedProduct;
      }

      emit(ProductOperationSuccess(
        message: 'Product updated successfully',
        product: updatedProduct,
      ));

      // Reload products to refresh the list
      add(const LoadProducts());
    } catch (e) {
      debugPrint('Error updating product: $e');
      emit(ProductError(message: 'Failed to update product: $e'));
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.deleteProduct(event.productId);
      _allProducts.removeWhere((p) => p.id == event.productId);

      emit(const ProductOperationSuccess(
          message: 'Product deleted successfully'));

      // Reload products to refresh the list
      add(const LoadProducts());
    } catch (e) {
      debugPrint('Error deleting product: $e');
      emit(ProductError(message: 'Failed to delete product: $e'));
    }
  }

  Future<void> _onSearchProducts(
      SearchProducts event, Emitter<ProductState> emit) async {
    _searchQuery = event.query;

    try {
      final searchResults =
          await _productRepository.searchProducts(event.query);
      _filteredProducts = searchResults;

      emit(SearchResultsLoaded(
        searchResults: searchResults,
        query: event.query,
      ));
    } catch (e) {
      debugPrint('Error searching products: $e');
      emit(ProductError(message: 'Failed to search products: $e'));
    }
  }

  Future<void> _onFilterProductsByCategory(
      FilterProductsByCategory event, Emitter<ProductState> emit) async {
    _selectedCategory = event.category;
    _applyFilters();

    emit(ProductsFiltered(
      filteredProducts: _filteredProducts,
      selectedCategory: event.category,
    ));
  }

  Future<void> _onLoadFeaturedProducts(
      LoadFeaturedProducts event, Emitter<ProductState> emit) async {
    try {
      final featuredProducts = await _productRepository.getFeaturedProducts();
      emit(FeaturedProductsLoaded(featuredProducts));
    } catch (e) {
      debugPrint('Error loading featured products: $e');
      emit(ProductError(message: 'Failed to load featured products: $e'));
    }
  }

  Future<void> _onToggleProductStatus(
      ToggleProductStatus event, Emitter<ProductState> emit) async {
    try {
      final product = _allProducts.firstWhere((p) => p.id == event.productId);
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        category: product.category,
        basePrice: product.basePrice,
        originalPrice: product.originalPrice,
        discountPercentage: product.discountPercentage,
        rating: product.rating,
        stockCount: product.stockCount,
        soldCount: product.soldCount,
        imageUrls: product.imageUrls,
        specifications: product.specifications,
        availableSizes: product.availableSizes,
        availableFabrics: product.availableFabrics,
        customizationOptions: product.customizationOptions,
        badges: product.badges,
        isActive: !product.isActive,
        isPopular: product.isPopular,
        isNewArrival: product.isNewArrival,
        isOnSale: product.isOnSale,
        brand: product.brand,
        createdAt: product.createdAt,
        updatedAt: DateTime.now(),
      );

      add(UpdateProduct(updatedProduct));
    } catch (e) {
      debugPrint('Error toggling product status: $e');
      emit(ProductError(message: 'Failed to toggle product status: $e'));
    }
  }

  Future<void> _onBulkUpdateProducts(
      BulkUpdateProducts event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.bulkUpdateProducts(event.products);
      emit(const ProductOperationSuccess(
          message: 'Products updated successfully'));

      // Reload products to refresh the list
      add(const LoadProducts());
    } catch (e) {
      debugPrint('Error bulk updating products: $e');
      emit(ProductError(message: 'Failed to bulk update products: $e'));
    }
  }

  Future<void> _onBulkDeleteProducts(
      BulkDeleteProducts event, Emitter<ProductState> emit) async {
    try {
      await _productRepository.bulkDeleteProducts(event.productIds);
      emit(const ProductOperationSuccess(
          message: 'Products deleted successfully'));

      // Reload products to refresh the list
      add(const LoadProducts());
    } catch (e) {
      debugPrint('Error bulk deleting products: $e');
      emit(ProductError(message: 'Failed to bulk delete products: $e'));
    }
  }

  Future<void> _onLoadProductAnalytics(
      LoadProductAnalytics event, Emitter<ProductState> emit) async {
    try {
      final analytics = await _productRepository.getProductAnalytics();
      emit(ProductAnalyticsLoaded(analytics));
    } catch (e) {
      debugPrint('Error loading product analytics: $e');
      emit(ProductError(message: 'Failed to load product analytics: $e'));
    }
  }

  Future<void> _onLoadTopSellingProducts(
      LoadTopSellingProducts event, Emitter<ProductState> emit) async {
    try {
      final topSellingProducts =
          await _productRepository.getTopSellingProducts(event.limit);
      emit(TopSellingProductsLoaded(topSellingProducts));
    } catch (e) {
      debugPrint('Error loading top selling products: $e');
      emit(ProductError(message: 'Failed to load top selling products: $e'));
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<ProductState> emit) {
    _searchQuery = '';
    _selectedCategory = null;
    _filteredProducts = [];
    add(const LoadProducts());
  }

  Future<void> _onRefreshProducts(
      RefreshProducts event, Emitter<ProductState> emit) async {
    emit(const ProductsRefreshing());
    add(const LoadProducts());
  }

  Future<void> _onSyncOfflineData(
      SyncOfflineData event, Emitter<ProductState> emit) async {
    emit(const SyncingOfflineData());

    try {
      // await _productRepository.syncOfflineDataToOnline(); // TODO: Implement in interface
      // final syncStatus = await _productRepository.getSyncStatus(); // TODO: Use sync status
      final syncedCount = 1; // TODO: Get actual count from sync result

      emit(OfflineDataSynced(syncedCount));
    } catch (e) {
      debugPrint('Error syncing offline data: $e');
      emit(ProductError(message: 'Failed to sync offline data: $e'));
    }
  }

  void _onConnectivityStatusChanged(
      ConnectivityStatusChanged event, Emitter<ProductState> emit) {
    // Update current state with connectivity info
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      emit(currentState.copyWith(isOnline: event.isOnline));
    }
  }

  void _applyFilters() {
    List<Product> filtered = _allProducts;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            product.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            product.brand.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    _filteredProducts = filtered;
  }

  void _setupProductsSubscription() {
    _productsSubscription?.cancel();
    _productsSubscription = _productRepository.getProductsStream().listen(
      (products) {
        final newIds = products.map((p) => p.id).toList();
        if (_haveIdsChanged(newIds)) {
          _allProducts = products;
          _productIds = newIds;
          _applyFilters();
          add(const LoadProducts());
        }
      },
      onError: (error) {
        debugPrint('Error in products stream: $error');
      },
    );
  }

  bool _haveIdsChanged(List<String> newIds) {
    if (newIds.length != _productIds.length) return true;
    for (int i = 0; i < newIds.length; i++) {
      if (newIds[i] != _productIds[i]) return true;
    }
    return false;
  }

  @override
  Future<void> close() {
    _connectivityDebounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    _productsSubscription?.cancel();
    return super.close();
  }
}
