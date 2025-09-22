import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme_constants.dart';
import '../../utils/product_screen_constants.dart';
import 'catalog_bottom_sheets.dart';

/// Displays active filters and allows quick removal
class ProductScreenFiltersBar extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onToggleView;

  const ProductScreenFiltersBar({
    super.key,
    required this.isGridView,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final activeFilters = _getActiveFilters(productProvider);

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: ProductScreenConstants.screenPadding,
            vertical: ProductScreenConstants.smallSpacing,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Sort indicator
                _buildSortIndicator(context),

                SizedBox(width: ProductScreenConstants.smallSpacing),

                // Filter indicator
                _buildFilterIndicator(context),

                SizedBox(width: ProductScreenConstants.smallSpacing),

                // View toggle indicator
                _buildViewToggleIndicator(context),

                // Active filters
                if (activeFilters.isNotEmpty) ...[
                  SizedBox(width: ProductScreenConstants.smallSpacing),
                  ...activeFilters
                      .map((filter) => _buildFilterChip(context, filter)),

                  // Clear all button
                  if (activeFilters.length > 1) ...[
                    SizedBox(width: ProductScreenConstants.smallSpacing),
                    _buildClearAllButton(context),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<_FilterChipData> _getActiveFilters(ProductProvider provider) {
    final filters = <_FilterChipData>[];

    // Category filter
    if (provider.selectedCategory != null) {
      filters.add(_FilterChipData(
        label: provider.getCategoryName(provider.selectedCategory!),
        type: 'category',
        value: provider.selectedCategory!.name,
      ));
    }

    // Price range filter
    if (provider.priceRange != null) {
      final range = provider.priceRange!;
      if (range.start > 0 || range.end < 10000) {
        filters.add(_FilterChipData(
          label: '₹${range.start.toInt()} - ₹${range.end.toInt()}',
          type: 'price',
          value: range,
        ));
      }
    }

    // Status filter
    if (provider.activeStatusFilter != null) {
      filters.add(_FilterChipData(
        label: provider.activeStatusFilter! ? 'Active Only' : 'Inactive Only',
        type: 'status',
        value: provider.activeStatusFilter!,
      ));
    }

    return filters;
  }

  Widget _buildFilterChip(BuildContext context, _FilterChipData filter) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(right: ProductScreenConstants.smallSpacing),
      child: Chip(
        label: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.3, // Limit width on small screens
          ),
          child: Text(
            filter.label,
            style: TextStyle(
              fontSize:
                  ProductScreenConstants.getResponsiveFontSize(screenWidth, 12),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        deleteIcon: Icon(
          Icons.close,
          size: ProductScreenConstants.getResponsiveFontSize(screenWidth, 16),
        ),
        onDeleted: () => _removeFilter(context, filter),
        backgroundColor: themeProvider.isDarkMode
            ? DarkAppColors.surface.withOpacity(0.8)
            : AppColors.surface.withOpacity(0.8),
        side: BorderSide(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withOpacity(0.2)
              : AppColors.onSurface.withOpacity(0.2),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ProductScreenConstants.smallSpacing,
          vertical: ProductScreenConstants.smallSpacing,
        ),
      ),
    );
  }

  Widget _buildClearAllButton(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return TextButton.icon(
      onPressed: () => _clearAllFilters(context),
      icon: Icon(
        Icons.clear_all,
        size: ProductScreenConstants.getResponsiveFontSize(screenWidth, 16),
        color: themeProvider.isDarkMode
            ? DarkAppColors.primary
            : AppColors.primary,
      ),
      label: Text(
        'Clear All',
        style: TextStyle(
          fontSize:
              ProductScreenConstants.getResponsiveFontSize(screenWidth, 12),
          fontWeight: FontWeight.w600,
          color: themeProvider.isDarkMode
              ? DarkAppColors.primary
              : AppColors.primary,
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: ProductScreenConstants.smallSpacing,
          vertical: ProductScreenConstants.smallSpacing,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ProductScreenConstants.borderRadiusSmall),
        ),
      ),
    );
  }

  void _removeFilter(BuildContext context, _FilterChipData filter) {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    switch (filter.type) {
      case 'category':
        productProvider.filterByCategory(null);
        break;
      case 'price':
        productProvider.filterByPriceRange(null);
        break;
      case 'status':
        productProvider.filterByStatus(null);
        break;
    }

    // Show feedback
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed ${filter.type} filter'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildSortIndicator(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final sortOption = productProvider.sortOption;
    final sortLabel =
        ProductScreenConstants.sortOptionLabels[sortOption] ?? sortOption;

    return InkWell(
      onTap: () => _showSortBottomSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ProductScreenConstants.smallSpacing,
          vertical: ProductScreenConstants.smallSpacing / 2,
        ),
        decoration: BoxDecoration(
          color: (themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary)
              .withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(ProductScreenConstants.borderRadiusSmall),
        ),
        child: Row(
          children: [
            Icon(
              Icons.sort,
              size:
                  ProductScreenConstants.getResponsiveFontSize(screenWidth, 14),
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
            ),
            SizedBox(width: ProductScreenConstants.smallSpacing / 2),
            Text(
              sortLabel,
              style: TextStyle(
                fontSize: ProductScreenConstants.getResponsiveFontSize(
                    screenWidth, 12),
                fontWeight: FontWeight.w500,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterIndicator(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final activeFilters = _getActiveFilters(productProvider);

    return InkWell(
      onTap: () => _showFilterBottomSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ProductScreenConstants.smallSpacing,
          vertical: ProductScreenConstants.smallSpacing / 2,
        ),
        decoration: BoxDecoration(
          color: (themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary)
              .withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(ProductScreenConstants.borderRadiusSmall),
        ),
        child: Row(
          children: [
            Icon(
              Icons.filter_list,
              size:
                  ProductScreenConstants.getResponsiveFontSize(screenWidth, 14),
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
            ),
            SizedBox(width: ProductScreenConstants.smallSpacing / 2),
            Text(
              activeFilters.isNotEmpty
                  ? 'Filter (${activeFilters.length})'
                  : 'Filter',
              style: TextStyle(
                fontSize: ProductScreenConstants.getResponsiveFontSize(
                    screenWidth, 12),
                fontWeight: FontWeight.w500,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const CatalogSortBottomSheet(),
      ),
    );
  }

  Widget _buildViewToggleIndicator(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius:
            BorderRadius.circular(ProductScreenConstants.borderRadiusSmall),
        border: Border.all(
          color: (themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface)
              .withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: (themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface)
                .withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onToggleView,
        icon: Icon(
          isGridView ? Icons.view_list : Icons.grid_view,
          size: ProductScreenConstants.getResponsiveFontSize(screenWidth, 20),
          color: themeProvider.isDarkMode
              ? DarkAppColors.primary
              : AppColors.primary,
        ),
        tooltip: isGridView ? 'Switch to list view' : 'Switch to grid view',
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const CatalogFilterBottomSheet(),
      ),
    );
  }

  void _clearAllFilters(BuildContext context) {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    productProvider.clearFilters();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cleared all filters'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Data class for filter chip information
class _FilterChipData {
  final String label;
  final String type;
  final dynamic value;

  const _FilterChipData({
    required this.label,
    required this.type,
    required this.value,
  });
}
