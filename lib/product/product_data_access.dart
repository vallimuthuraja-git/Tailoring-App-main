/// File: product_data_access.dart
/// Purpose: Central export module for all product-related data access components
/// Functionality: Exports product models, repositories, and services for unified access across the application
/// Dependencies: Various product-related classes and services (models, repositories, analytics, cache, search)
/// Usage: Import this file to access all product data access functionality in one place
// Product data access library
// Exports all product-related repositories, services, and models

export 'product_models.dart';
export 'product_repository.dart';
// Repository interfaces and implementations are exported by product_repository.dart
export 'product_analytics_service.dart';
export 'product_cache_service.dart';
export 'product_search_service.dart';

// Constants
const String eventPurchase = 'product_purchase';
const String eventView = 'product_view';
const String eventAddToCart = 'add_to_cart';
const String eventWishlist = 'add_to_wishlist';

// Note: ProductCacheService and ProductSearchService are fully implemented
