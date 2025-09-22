import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme_constants.dart';
import '../../utils/product_screen_constants.dart';

/// Enhanced empty state with context-aware messaging and actions
class EnhancedEmptyState extends StatelessWidget {
  final String? searchQuery;
  final bool? hasActiveFilters;

  const EnhancedEmptyState({
    super.key,
    this.searchQuery,
    this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final query = searchQuery ?? productProvider.searchQuery;
        final filters = hasActiveFilters ?? _hasActiveFilters(productProvider);

        return _buildEmptyState(context, query, filters, productProvider);
      },
    );
  }

  bool _hasActiveFilters(ProductProvider provider) {
    return provider.selectedCategory != null ||
        provider.priceRange != null ||
        provider.activeStatusFilter != null;
  }

  Widget _buildEmptyState(BuildContext context, String query, bool hasFilters,
      ProductProvider provider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePadding =
        ProductScreenConstants.getResponsivePadding(screenWidth);

    // Determine the type of empty state
    final EmptyStateType stateType = _getEmptyStateType(query, hasFilters);

    return Container(
      padding: EdgeInsets.all(responsivePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary)
                      .withOpacity(0.1),
                  (themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary)
                      .withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForState(stateType),
              size:
                  ProductScreenConstants.getResponsiveFontSize(screenWidth, 64),
              color: (themeProvider.isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary)
                  .withOpacity(0.7),
            ),
          ),

          SizedBox(height: ProductScreenConstants.componentSpacing),

          // Title
          Text(
            _getTitleForState(stateType, query),
            style: TextStyle(
              fontSize:
                  ProductScreenConstants.getResponsiveFontSize(screenWidth, 24),
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: ProductScreenConstants.smallSpacing),

          // Subtitle
          Text(
            _getSubtitleForState(stateType, query),
            style: TextStyle(
              fontSize:
                  ProductScreenConstants.getResponsiveFontSize(screenWidth, 16),
              color: (themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface)
                  .withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: ProductScreenConstants.componentSpacing),

          // Actions
          _buildActionsForState(context, stateType, provider),
        ],
      ),
    );
  }

  EmptyStateType _getEmptyStateType(String query, bool hasFilters) {
    if (hasFilters) return EmptyStateType.noFilterResults;
    if (query.isNotEmpty) return EmptyStateType.noSearchResults;
    return EmptyStateType.noProducts;
  }

  IconData _getIconForState(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.noSearchResults:
        return Icons.search_off;
      case EmptyStateType.noFilterResults:
        return Icons.filter_list_off;
      case EmptyStateType.noProducts:
        return Icons.inventory_2_outlined;
    }
  }

  String _getTitleForState(EmptyStateType type, String query) {
    switch (type) {
      case EmptyStateType.noSearchResults:
        return 'No results found';
      case EmptyStateType.noFilterResults:
        return 'No products match your filters';
      case EmptyStateType.noProducts:
        return ProductScreenConstants.noProductsMessage;
    }
  }

  String _getSubtitleForState(EmptyStateType type, String query) {
    switch (type) {
      case EmptyStateType.noSearchResults:
        return 'Try adjusting your search terms or check spelling';
      case EmptyStateType.noFilterResults:
        return 'Try changing your filter criteria to see more products';
      case EmptyStateType.noProducts:
        return 'Check back later for new arrivals';
    }
  }

  Widget _buildActionsForState(
      BuildContext context, EmptyStateType type, ProductProvider provider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final actions = <Widget>[];

    // Primary action
    switch (type) {
      case EmptyStateType.noSearchResults:
        actions.add(_buildActionButton(
          context,
          'Clear Search',
          Icons.clear,
          () => _clearSearch(context, provider),
          isPrimary: true,
        ));
        break;
      case EmptyStateType.noFilterResults:
        actions.add(_buildActionButton(
          context,
          'Clear Filters',
          Icons.filter_list_off,
          () => _clearFilters(context, provider),
          isPrimary: true,
        ));
        break;
      case EmptyStateType.noProducts:
        actions.add(_buildActionButton(
          context,
          'Refresh',
          Icons.refresh,
          () => _refreshProducts(context, provider),
          isPrimary: true,
        ));
    }

    // Secondary actions
    if (type != EmptyStateType.noProducts) {
      actions.add(const SizedBox(height: 12));
      actions.add(_buildActionButton(
        context,
        'Show All Products',
        Icons.inventory_2,
        () => _showAllProducts(context, provider),
        isPrimary: false,
      ));
    }

    return Column(
      children: actions,
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed, {
    required bool isPrimary,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: ProductScreenConstants.getResponsiveFontSize(screenWidth, 20),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize:
                ProductScreenConstants.getResponsiveFontSize(screenWidth, 16),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? (themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary)
              : Colors.transparent,
          foregroundColor: isPrimary
              ? (themeProvider.isDarkMode
                  ? DarkAppColors.onPrimary
                  : AppColors.onPrimary)
              : (themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary),
          side: isPrimary
              ? null
              : BorderSide(
                  color: (themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary)
                      .withOpacity(0.3),
                ),
          padding: EdgeInsets.symmetric(
            vertical: ProductScreenConstants.getResponsivePadding(screenWidth),
            horizontal:
                ProductScreenConstants.getResponsivePadding(screenWidth),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                ProductScreenConstants.borderRadiusMedium),
          ),
          elevation: isPrimary ? 2 : 0,
        ),
      ),
    );
  }

  void _clearSearch(BuildContext context, ProductProvider provider) {
    provider.searchProducts('');
    _showFeedback(context, 'Search cleared');
  }

  void _clearFilters(BuildContext context, ProductProvider provider) {
    provider.clearFilters();
    _showFeedback(context, 'Filters cleared');
  }

  void _refreshProducts(BuildContext context, ProductProvider provider) async {
    await provider.refreshProducts();
    _showFeedback(context, 'Products refreshed');
  }

  void _showAllProducts(BuildContext context, ProductProvider provider) {
    provider.clearFilters();
    _showFeedback(context, 'Showing all products');
  }

  void _showFeedback(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ProductScreenConstants.borderRadiusMedium),
        ),
      ),
    );
  }
}

/// Types of empty states for better handling
enum EmptyStateType {
  noProducts,
  noSearchResults,
  noFilterResults,
}
