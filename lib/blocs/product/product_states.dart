/// File: product_states.dart
/// Purpose: Definition of all possible states for the ProductBloc
/// Functionality: Contains state classes representing different conditions of product data (loading, loaded, error, filtered, etc.)
/// Dependencies: Equatable package for value comparison, product models
/// Usage: States are emitted by ProductBloc to notify UI components about changes in product data and application status
import 'package:equatable/equatable.dart';
import '../../models/product_models.dart';

/// Base class for all product-related states
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// Initial state when bloc is first created
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// State when products are being loaded
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// State when products are successfully loaded
class ProductsLoaded extends ProductState {
  final List<Product> products;
  final bool isOnline;
  final bool hasOfflineData;

  const ProductsLoaded({
    required this.products,
    required this.isOnline,
    required this.hasOfflineData,
  });

  @override
  List<Object?> get props => [products, isOnline, hasOfflineData];

  ProductsLoaded copyWith({
    List<Product>? products,
    bool? isOnline,
    bool? hasOfflineData,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      isOnline: isOnline ?? this.isOnline,
      hasOfflineData: hasOfflineData ?? this.hasOfflineData,
    );
  }
}

/// State when a single product is successfully loaded
class ProductLoaded extends ProductState {
  final Product product;

  const ProductLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

/// State when featured products are loaded
class FeaturedProductsLoaded extends ProductState {
  final List<Product> featuredProducts;

  const FeaturedProductsLoaded(this.featuredProducts);

  @override
  List<Object?> get props => [featuredProducts];
}

/// State when search results are loaded
class SearchResultsLoaded extends ProductState {
  final List<Product> searchResults;
  final String query;

  const SearchResultsLoaded({
    required this.searchResults,
    required this.query,
  });

  @override
  List<Object?> get props => [searchResults, query];
}

/// State when products are filtered by category
class ProductsFiltered extends ProductState {
  final List<Product> filteredProducts;
  final ProductCategory? selectedCategory;

  const ProductsFiltered({
    required this.filteredProducts,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [filteredProducts, selectedCategory];
}

/// State when top selling products are loaded
class TopSellingProductsLoaded extends ProductState {
  final List<Product> topSellingProducts;

  const TopSellingProductsLoaded(this.topSellingProducts);

  @override
  List<Object?> get props => [topSellingProducts];
}

/// State when product analytics are loaded
class ProductAnalyticsLoaded extends ProductState {
  final Map<String, int> analytics;

  const ProductAnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

/// State when a product operation is successful
class ProductOperationSuccess extends ProductState {
  final String message;
  final Product? product;

  const ProductOperationSuccess({
    required this.message,
    this.product,
  });

  @override
  List<Object?> get props => [message, product];
}

/// State when an error occurs
class ProductError extends ProductState {
  final String message;
  final String? code;

  const ProductError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// State when offline data is being synced
class SyncingOfflineData extends ProductState {
  const SyncingOfflineData();
}

/// State when offline data sync is complete
class OfflineDataSynced extends ProductState {
  final int syncedCount;

  const OfflineDataSynced(this.syncedCount);

  @override
  List<Object?> get props => [syncedCount];
}

/// State when connectivity status changes
class ConnectivityChanged extends ProductState {
  final bool isOnline;

  const ConnectivityChanged(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

/// State when products are being refreshed
class ProductsRefreshing extends ProductState {
  const ProductsRefreshing();
}
