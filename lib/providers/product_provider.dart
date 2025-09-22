import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_models.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_events.dart';
import '../blocs/product/product_states.dart';

/// Enhanced loading states for better UX
enum LoadingState {
  idle,
  initialLoading,
  loadingMore,
  refreshing,
  error,
}

/// ProductProvider that integrates with ProductBloc for state management
class ProductProvider with ChangeNotifier {
  final ProductBloc _productBloc;

  // Local state for UI convenience
  List<Product> _products = [];
  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;
  String _searchQuery = '';
  ProductCategory? _selectedCategory;
  RangeValues? _priceRange;
  bool? _activeStatusFilter;
  String _sortOption = 'name';

  // Pagination fields
  int _currentPage = 0;
  bool _hasMoreProducts = true;
  final int _pageSize = 20;

  // Stream subscription to listen to bloc state changes
  StreamSubscription<ProductState>? _blocSubscription;

  ProductProvider(this._productBloc) {
    _initializeBlocSubscription();
  }

  void _initializeBlocSubscription() {
    _blocSubscription = _productBloc.stream.listen(_onBlocStateChanged);
  }

  void _onBlocStateChanged(ProductState state) {
    if (state is ProductsLoaded) {
      _products = state.products;
      _loadingState = LoadingState.idle;
    } else if (state is ProductLoading) {
      _loadingState = LoadingState.initialLoading;
    } else if (state is ProductsRefreshing) {
      _loadingState = LoadingState.refreshing;
    } else if (state is ProductError) {
      _loadingState = LoadingState.error;
      _errorMessage = state.message;
    }

    notifyListeners();
  }

  // Getters
  List<Product> get products => _sortProducts(_products);
  LoadingState get loadingState => _loadingState;
  bool get isLoading => _loadingState == LoadingState.initialLoading;
  bool get isLoadingMore => _loadingState == LoadingState.loadingMore;
  bool get isRefreshing => _loadingState == LoadingState.refreshing;
  bool get hasError => _loadingState == LoadingState.error;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  ProductCategory? get selectedCategory => _selectedCategory;
  RangeValues? get priceRange => _priceRange;
  bool? get activeStatusFilter => _activeStatusFilter;
  String get sortOption => _sortOption;
  bool get hasMoreProducts => _hasMoreProducts;
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedCategory != null;

  // Actions that delegate to BLoC
  void loadProducts() {
    _productBloc.add(const LoadProducts());
  }

  Future<void> loadMoreProducts() async {
    if (_loadingState == LoadingState.loadingMore || !_hasMoreProducts) return;

    _loadingState = LoadingState.loadingMore;
    notifyListeners();

    try {
      // For now, just reload all products
      // In a real implementation, this would load paginated data
      _productBloc.add(const LoadProducts());
    } finally {
      _loadingState = LoadingState.idle;
      notifyListeners();
    }
  }

  Future<void> refreshProducts() async {
    _currentPage = 0;
    _hasMoreProducts = true;
    _productBloc.add(const RefreshProducts());
  }

  Future<Product?> getProductById(String productId) async {
    _productBloc.add(LoadProduct(productId));
    // For immediate return, we could wait for state change
    // But for simplicity, return from current products
    return _products.where((p) => p.id == productId).isEmpty
        ? null
        : _products.firstWhere((p) => p.id == productId);
  }

  Future<bool> addProduct(Product product) async {
    _loadingState = LoadingState.refreshing;
    notifyListeners();

    try {
      _productBloc.add(AddProduct(product));
      _loadingState = LoadingState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _loadingState = LoadingState.idle;
      _errorMessage = 'Failed to add product: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    _loadingState = LoadingState.refreshing;
    notifyListeners();

    try {
      _productBloc.add(UpdateProduct(product));
      _loadingState = LoadingState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _loadingState = LoadingState.idle;
      _errorMessage = 'Failed to update product: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _loadingState = LoadingState.refreshing;
    notifyListeners();

    try {
      _productBloc.add(DeleteProduct(productId));
      _loadingState = LoadingState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _loadingState = LoadingState.idle;
      _errorMessage = 'Failed to delete product: $e';
      notifyListeners();
      return false;
    }
  }

  // Search and filter methods (local for now)
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterByCategory(ProductCategory? category) {
    _selectedCategory = category;
    _productBloc.add(FilterProductsByCategory(category));
  }

  void sortProducts(String sortOption) {
    _sortOption = sortOption;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _priceRange = null;
    _activeStatusFilter = null;
    _productBloc.add(const ClearFilters());
  }

  void filterByPriceRange(RangeValues? range) {
    _priceRange = range;
    notifyListeners();
  }

  void filterByStatus(bool? activeOnly) {
    _activeStatusFilter = activeOnly;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get product categories
  List<ProductCategory> get categories => ProductCategory.values;

  String getCategoryName(ProductCategory category) {
    return category.toString().split('.').last;
  }

  void _applyFilters() {
    // Local filtering for now - in a real implementation,
    // this would be handled by the repository or bloc
    notifyListeners();
  }

  List<Product> _sortProducts(List<Product> products) {
    switch (_sortOption) {
      case 'price_asc':
        return List.from(products)
          ..sort((a, b) => a.basePrice.compareTo(b.basePrice));
      case 'price_desc':
        return List.from(products)
          ..sort((a, b) => b.basePrice.compareTo(a.basePrice));
      case 'rating':
        return List.from(products)
          ..sort((a, b) =>
              b.rating.averageRating.compareTo(a.rating.averageRating));
      case 'newest':
        return List.from(products)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case 'popular':
        return List.from(products)
          ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
      case 'bestseller':
        return List.from(products)
          ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
      case 'name_desc':
        return List.from(products)..sort((a, b) => b.name.compareTo(a.name));
      case 'name':
      default:
        return List.from(products)..sort((a, b) => a.name.compareTo(b.name));
    }
  }

  // Wishlist functionality (simplified)
  bool isProductInWishlist(String productId) {
    // TODO: Implement wishlist functionality
    return false;
  }

  Future<bool> toggleWishlist(String productId) async {
    // TODO: Implement wishlist toggle
    return true;
  }

  // Cleanup
  @override
  void dispose() {
    _blocSubscription?.cancel();
    super.dispose();
  }

  // Factory method for provider
  static ProductProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<ProductProvider>(context, listen: listen);
  }
}
