/// File: product_events.dart
/// Purpose: Definition of all events that can be dispatched to the ProductBloc
/// Functionality: Contains event classes for product operations like loading, adding, updating, deleting, searching, filtering, and synchronization
/// Dependencies: Equatable package for value comparison, product models
/// Usage: Events are dispatched to ProductBloc to trigger state changes and business logic execution
import 'package:equatable/equatable.dart';
import '../../models/product_models.dart';

/// Base class for all product-related events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all products
class LoadProducts extends ProductEvent {
  const LoadProducts();
}

/// Event to load products with pagination
class LoadProductsPage extends ProductEvent {
  final int page;
  final int pageSize;

  const LoadProductsPage({
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object?> get props => [page, pageSize];
}

/// Event to load a specific product by ID
class LoadProduct extends ProductEvent {
  final String productId;

  const LoadProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Event to add a new product
class AddProduct extends ProductEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

/// Event to update an existing product
class UpdateProduct extends ProductEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

/// Event to delete a product
class DeleteProduct extends ProductEvent {
  final String productId;

  const DeleteProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Event to search products
class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to filter products by category
class FilterProductsByCategory extends ProductEvent {
  final ProductCategory? category;

  const FilterProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event to load featured/popular products
class LoadFeaturedProducts extends ProductEvent {
  const LoadFeaturedProducts();
}

/// Event to toggle product active status
class ToggleProductStatus extends ProductEvent {
  final String productId;

  const ToggleProductStatus(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Event for bulk operations
class BulkUpdateProducts extends ProductEvent {
  final List<Product> products;

  const BulkUpdateProducts(this.products);

  @override
  List<Object?> get props => [products];
}

/// Event to bulk delete products
class BulkDeleteProducts extends ProductEvent {
  final List<String> productIds;

  const BulkDeleteProducts(this.productIds);

  @override
  List<Object?> get props => [productIds];
}

/// Event to load product analytics
class LoadProductAnalytics extends ProductEvent {
  const LoadProductAnalytics();
}

/// Event to load top selling products
class LoadTopSellingProducts extends ProductEvent {
  final int limit;

  const LoadTopSellingProducts(this.limit);

  @override
  List<Object?> get props => [limit];
}

/// Event to clear search/filter
class ClearFilters extends ProductEvent {
  const ClearFilters();
}

/// Event to refresh products data
class RefreshProducts extends ProductEvent {
  const RefreshProducts();
}

/// Event to sync offline data
class SyncOfflineData extends ProductEvent {
  const SyncOfflineData();
}

/// Event when connectivity changes
class ConnectivityStatusChanged extends ProductEvent {
  final bool isOnline;

  const ConnectivityStatusChanged(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}
