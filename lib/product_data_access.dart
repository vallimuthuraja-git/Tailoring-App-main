// Product data access library
// Exports all product-related repositories, services, and models

export 'models/product_models.dart';
export 'repositories/product/product_repository.dart';
export 'repositories/product/i_product_repository.dart';
export 'services/product/product_analytics_service.dart';
export 'services/product/product_cache_service.dart';
export 'services/product/product_search_service.dart';

// Constants
const String eventPurchase = 'product_purchase';
const String eventView = 'product_view';
const String eventAddToCart = 'add_to_cart';
const String eventWishlist = 'add_to_wishlist';

// Note: ProductCacheService and ProductSearchService are referenced but not implemented yet
// They would need to be created if required by the application
