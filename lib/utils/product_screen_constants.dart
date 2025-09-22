import 'package:flutter/material.dart';
import 'responsive_utils.dart';

/// Consolidated Product Screen Constants - moved from responsive_utils.dart for better organization
class ProductScreenConstants {
  // Grid Layout
  static const double gridCrossAxisSpacing = 12.0;
  static const double gridMainAxisSpacing = 12.0;
  static const int gridCrossAxisCountMobile = 2;
  static const int gridCrossAxisCountTablet = 3;
  static const int gridCrossAxisCountDesktop = 4;

  // List Layout
  static const double listItemHeight = 100.0;
  static const double listItemSpacing = 8.0;

  // Pagination
  static const int pageSize = 20;
  static const double scrollThreshold = 0.8; // Load more at 80% scroll

  // Timing
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);
  static const Duration heroAnimationDuration = Duration(milliseconds: 300);
  static const Duration filterAnimationDuration = Duration(milliseconds: 200);

  // Dimensions
  static const double searchBarHeight = 56.0;
  static const double filterBarHeight = 48.0;
  static const double actionBarHeight = 64.0;

  // Touch Targets
  static const double minTouchTargetSize = 44.0;
  static const double buttonPadding = 12.0;

  // Spacing
  static const double screenPadding = 16.0;
  static const double componentSpacing = 16.0;
  static const double smallSpacing = 8.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Elevation
  static const double cardElevation = 2.0;
  static const double appBarElevation = 0.0;

  // Opacity
  static const double disabledOpacity = 0.6;
  static const double hoverOpacity = 0.8;

  // Image
  static const double imageAspectRatio =
      0.85; // Slightly taller for better visual balance
  static const int imageCacheSize = 50; // Number of images to cache
  static const Duration imageFadeDuration = Duration(milliseconds: 200);

  // Animation
  static const Curve defaultCurve = Curves.easeInOut;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Loading
  static const double loadingIndicatorSize = 24.0;
  static const double skeletonHeight = 200.0;

  // Breakpoints for responsive design (aligned with ResponsiveUtils)
  static const double mobileBreakpoint = ResponsiveBreakpoints.mobile;
  static const double tabletBreakpoint = ResponsiveBreakpoints.tablet;
  static const double desktopBreakpoint = 1200.0; // Extended for desktop

  // Grid responsive calculations (using ResponsiveUtils breakpoints)
  static int getGridCrossAxisCount(double screenWidth) {
    if (screenWidth >= desktopBreakpoint) return gridCrossAxisCountDesktop;
    if (screenWidth >= tabletBreakpoint) return gridCrossAxisCountTablet;
    return gridCrossAxisCountMobile;
  }

  static double getResponsivePadding(double screenWidth) {
    if (screenWidth >= desktopBreakpoint) return screenPadding * 1.5;
    if (screenWidth >= tabletBreakpoint) return screenPadding * 1.2;
    return screenPadding;
  }

  static double getResponsiveSpacing(double screenWidth) {
    if (screenWidth >= desktopBreakpoint) return componentSpacing * 1.2;
    if (screenWidth >= tabletBreakpoint) return componentSpacing * 1.1;
    return componentSpacing;
  }

  static double getResponsiveFontSize(double screenWidth, double baseSize) {
    if (screenWidth >= desktopBreakpoint) return baseSize * 1.1;
    if (screenWidth >= tabletBreakpoint) return baseSize * 1.05;
    if (screenWidth >= mobileBreakpoint) return baseSize * 0.95;
    return baseSize * 0.9; // Mobile
  }

  // Hero tags
  static String productImageHeroTag(String productId, int index) {
    return 'product-image-$productId-$index';
  }

  static String productCardHeroTag(String productId) {
    return 'product-card-$productId';
  }

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

  // Accessibility labels
  static const String searchHint = 'Search for products';
  static const String filterButtonLabel = 'Filter products';
  static const String sortButtonLabel = 'Sort products';
  static const String viewToggleLabel = 'Toggle view mode';
  static const String addToCartLabel = 'Add to cart';
  static const String addToWishlistLabel = 'Add to wishlist';

  // Sort options
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

  // Filter options
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
