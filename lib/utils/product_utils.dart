// Consolidated Product Utilities and Constants
// Contains all product-related utility functions and screen constants

import 'package:flutter/material.dart';
import '../models/product_models.dart';
import 'responsive_utils.dart';

// Grid Layout
class GridLayoutConstants {
  static const double gridCrossAxisSpacing = 12.0;
  static const double gridMainAxisSpacing = 12.0;
  static const int gridCrossAxisCountMobile = 2;
  static const int gridCrossAxisCountTablet = 3;
  static const int gridCrossAxisCountDesktop = 4;

  static int getGridCrossAxisCount(double screenWidth) {
    if (screenWidth >= 1200.0) return gridCrossAxisCountDesktop;
    if (screenWidth >= ResponsiveBreakpoints.tablet)
      return gridCrossAxisCountTablet;
    return gridCrossAxisCountMobile;
  }
}

// List Layout
class ListLayoutConstants {
  static const double listItemHeight = 100.0;
  static const double listItemSpacing = 8.0;
}

// Pagination
class PaginationConstants {
  static const int pageSize = 20;
  static const double scrollThreshold = 0.8; // Load more at 80% scroll
}

// Timing
class TimingConstants {
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
  static const Duration heroAnimationDuration = Duration(milliseconds: 300);
  static const Duration filterAnimationDuration = Duration(milliseconds: 200);
}

// Dimensions
class DimensionConstants {
  static const double searchBarHeight = 56.0;
  static const double filterBarHeight = 48.0;
  static const double actionBarHeight = 64.0;
}

// Touch Targets
class TouchTargetConstants {
  static const double minTouchTargetSize = 44.0;
  static const double buttonPadding = 12.0;
}

// Spacing
class SpacingConstants {
  static const double screenPadding = 16.0;
  static const double componentSpacing = 16.0;
  static const double smallSpacing = 8.0;

  static double getResponsivePadding(double screenWidth) {
    if (screenWidth >= 1200.0) return screenPadding * 1.5;
    if (screenWidth >= ResponsiveBreakpoints.tablet) return screenPadding * 1.2;
    return screenPadding;
  }

  static double getResponsiveSpacing(double screenWidth) {
    if (screenWidth >= 1200.0) return componentSpacing * 1.2;
    if (screenWidth >= ResponsiveBreakpoints.tablet)
      return componentSpacing * 1.1;
    return componentSpacing;
  }
}

// Border Radius
class BorderRadiusConstants {
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
}

// Elevation
class ElevationConstants {
  static const double cardElevation = 2.0;
  static const double appBarElevation = 0.0;
}

// Opacity
class OpacityConstants {
  static const double disabledOpacity = 0.6;
  static const double hoverOpacity = 0.8;
}

// Image
class ImageConstants {
  static const double imageAspectRatio = 0.85;
  static const int imageCacheSize = 50;
  static const Duration imageFadeDuration = Duration(milliseconds: 200);
}

// Animation
class AnimationConstants {
  static const Curve defaultCurve = Curves.easeInOut;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}

// Loading
class LoadingConstants {
  static const double loadingIndicatorSize = 24.0;
  static const double skeletonHeight = 200.0;
}

// Messages
class MessageConstants {
  // Error messages
  static const String loadProductsError =
      'Failed to load products. Please try again.';
  static const String searchError =
      'Search failed. Please check your connection.';
  static const String filterError =
      'Failed to apply filters. Please try again.';
  static const String sortError = 'Failed to sort products. Please try again.';

  // Empty state messages
  static const String noProductsMessage = 'No products found';
  static const String noSearchResultsMessage = 'No products match your search';
  static const String noFilterResultsMessage = 'No products match your filters';
  static const String loadingMessage = 'Loading products...';
}

// Accessibility labels
class AccessibilityConstants {
  static const String searchHint = 'Search for products';
  static const String filterButtonLabel = 'Filter products';
  static const String sortButtonLabel = 'Sort products';
  static const String viewToggleLabel = 'Toggle view mode';
  static const String addToCartLabel = 'Add to cart';
  static const String addToWishlistLabel = 'Add to wishlist';
}

// Sort options
class SortConstants {
  static const List<String> sortOptions = [
    'name',
    'name_desc',
    'price_asc',
    'price_desc',
    'rating',
    'newest',
    'popular',
    'bestseller',
  ];

  static const Map<String, String> sortOptionLabels = {
    'name': 'Name (A-Z)',
    'name_desc': 'Name (Z-A)',
    'price_asc': 'Price (Low to High)',
    'price_desc': 'Price (High to Low)',
    'rating': 'Rating (High to Low)',
    'newest': 'Newest First',
    'popular': 'Popular First',
    'bestseller': 'Best Sellers',
  };
}

// Filter options
class FilterConstants {
  static const List<String> quickFilterOptions = [
    'active',
    'on_sale',
    'new_arrival',
    'popular',
  ];

  static const Map<String, String> quickFilterLabels = {
    'active': 'Active Only',
    'on_sale': 'On Sale',
    'new_arrival': 'New Arrivals',
    'popular': 'Popular',
  };
}

/// Main ProductUtils class with all utility functions
class ProductUtils {
  // Formatting utilities
  static String formatPrice(double price) {
    return '₹${price.toStringAsFixed(0)}';
  }

  static String formatPriceRange(double min, double max) {
    return '₹${min.toStringAsFixed(0)} - ₹${max.toStringAsFixed(0)}';
  }

  // Category utilities
  static String getCategoryDisplayName(ProductCategory category) {
    switch (category) {
      case ProductCategory.mensWear:
        return "Men's Wear";
      case ProductCategory.womensWear:
        return "Women's Wear";
      case ProductCategory.kidsWear:
        return "Kids Wear";
      case ProductCategory.formalWear:
        return "Formal Wear";
      case ProductCategory.casualWear:
        return "Casual Wear";
      case ProductCategory.traditionalWear:
        return "Traditional Wear";
      case ProductCategory.alterations:
        return "Alterations";
      case ProductCategory.customDesign:
        return "Custom Design";
    }
  }

  // Validation utilities
  static bool isValidPrice(double price) {
    return price >= 0;
  }

  static bool isValidProduct(Product product) {
    return product.name.isNotEmpty && product.basePrice > 0;
  }

  // Hero tags
  static String productImageHeroTag(String productId, int index) {
    return 'product-image-$productId-$index';
  }

  static String productCardHeroTag(String productId) {
    return 'product-card-$productId';
  }

  // Product filtering utilities
  static List<Product> filterByCategory(
      List<Product> products, ProductCategory category) {
    return products.where((p) => p.category == category).toList();
  }

  static List<Product> filterNewArrivals(List<Product> products) {
    return products.where((p) => p.isNewArrival).toList();
  }

  static List<Product> filterPopular(List<Product> products) {
    return products.where((p) => p.isPopular).toList();
  }

  static List<Product> filterOnSale(List<Product> products) {
    return products.where((p) => p.isOnSale).toList();
  }

  static List<Product> filterActive(List<Product> products) {
    return products.where((p) => p.isActive).toList();
  }

  // Sorting utilities
  static List<Product> sortByName(List<Product> products,
      {bool ascending = true}) {
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) {
      final comparison = a.name.compareTo(b.name);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  static List<Product> sortByPrice(List<Product> products,
      {bool ascending = true}) {
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) {
      final comparison = a.basePrice.compareTo(b.basePrice);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  static List<Product> sortByRating(List<Product> products,
      {bool descending = true}) {
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) {
      final comparison =
          a.rating.averageRating.compareTo(b.rating.averageRating);
      return descending ? -comparison : comparison;
    });
    return sorted;
  }

  static List<Product> sortByNewest(List<Product> products,
      {bool descending = true}) {
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) {
      final comparison = a.createdAt.compareTo(b.createdAt);
      return descending ? -comparison : comparison;
    });
    return sorted;
  }

  static List<Product> sortByPopularity(List<Product> products,
      {bool descending = true}) {
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) {
      final comparison = a.soldCount.compareTo(b.soldCount);
      return descending ? -comparison : comparison;
    });
    return sorted;
  }

  // Responsive utilities
  static double getResponsiveFontSize(double screenWidth, double baseSize) {
    if (screenWidth >= 1200.0) return baseSize * 1.1;
    if (screenWidth >= ResponsiveBreakpoints.tablet) return baseSize * 1.05;
    if (screenWidth >= ResponsiveBreakpoints.mobile) return baseSize * 0.95;
    return baseSize * 0.9; // Mobile
  }

  // Product analytics utilities
  static Map<String, dynamic> calculateProductStats(List<Product> products) {
    if (products.isEmpty) {
      return {
        'total_products': 0,
        'total_value': 0.0,
        'average_price': 0.0,
        'categories': <String, int>{},
      };
    }

    final totalValue = products.fold<double>(0, (sum, p) => sum + p.basePrice);
    final categories = <String, int>{};

    for (final product in products) {
      final categoryName = getCategoryDisplayName(product.category);
      categories[categoryName] = (categories[categoryName] ?? 0) + 1;
    }

    return {
      'total_products': products.length,
      'total_value': totalValue,
      'average_price': totalValue / products.length,
      'categories': categories,
    };
  }
}
