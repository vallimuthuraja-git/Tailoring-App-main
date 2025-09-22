// Product data access library
// Exports all product-related repositories, services, and models

export 'models/product_models.dart';
export 'repositories/product/product_repository.dart';
export 'repositories/product/i_product_repository.dart';
export 'services/product/product_analytics_service.dart';
export 'services/product/product_cache_service.dart';
export 'services/product/product_search_service.dart';

// Constants
const String EVENT_PURCHASE = 'product_purchase';
const String EVENT_VIEW = 'product_view';
const String EVENT_ADD_TO_CART = 'add_to_cart';
const String EVENT_WISHLIST = 'add_to_wishlist';

// Note: ProductCacheService and ProductSearchService are referenced but not implemented yet
// They would need to be created if required by the application
