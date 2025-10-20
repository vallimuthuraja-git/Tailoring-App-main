import 'package:flutter/material.dart';
import 'package:provider/Provider.dart';
import '../../models/product_models.dart';
import '../../../product_data_access.dart';
import '../../providers/theme_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme_constants.dart';
import '../../utils/product_screen_constants.dart';

// Base mixin for common bottom sheet functionality
mixin BottomSheetBase {
  double getResponsivePadding(double basePadding, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return basePadding * 1.2;
    if (screenWidth >= 900) return basePadding * 1.1;
    if (screenWidth >= 600) return basePadding * 0.95;
    return basePadding * 0.85;
  }

  double getResponsiveFontSize(double baseSize, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) return baseSize * 1.1;
    if (screenWidth >= 900) return baseSize * 1.05;
    if (screenWidth >= 600) return baseSize * 0.95;
    return baseSize * 0.9;
  }

  Widget buildHeader(BuildContext context, IconData icon, String title) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Row(
      children: [
        Icon(
          icon,
          color: themeProvider.isDarkMode
              ? DarkAppColors.primary
              : AppColors.primary,
          size: getResponsiveFontSize(24, context),
        ),
        SizedBox(width: getResponsivePadding(12, context)),
        Text(
          title,
          style: TextStyle(
            fontSize: getResponsiveFontSize(20, context),
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  SnackBar buildSuccessSnackBar(String message) {
    return SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// Enhanced Catalog Filter Bottom Sheet
class CatalogFilterBottomSheet extends StatefulWidget {
  const CatalogFilterBottomSheet({super.key});

  @override
  State<CatalogFilterBottomSheet> createState() =>
      _CatalogFilterBottomSheetState();
}

class _CatalogFilterBottomSheetState extends State<CatalogFilterBottomSheet>
    with BottomSheetBase {
  RangeValues _priceRange = const RangeValues(0, 10000);
  ProductCategory? _selectedCategory;
  bool? _activeStatusFilter;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(getResponsivePadding(20, context)),
      constraints: BoxConstraints(
        maxHeight:
            screenWidth < 600 ? MediaQuery.of(context).size.height * 0.7 : 500,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(context, Icons.filter_list, 'Filter Products'),
            SizedBox(height: getResponsivePadding(20, context)),

            // Price Range
            Text(
              'Price Range',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: getResponsiveFontSize(16, context),
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface,
              ),
            ),
            SizedBox(height: getResponsivePadding(12, context)),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: getResponsivePadding(16, context)),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.surface.withValues(alpha: 0.5)
                    : AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                      : AppColors.onSurface.withValues(alpha: 0.2),
                ),
              ),
              child: RangeSlider(
                values: _priceRange,
                min: 0,
                max: 10000,
                divisions: 100,
                labels: RangeLabels(
                  '₹${_priceRange.start.toInt()}',
                  '₹${_priceRange.end.toInt()}',
                ),
                activeColor: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                inactiveColor: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                    : AppColors.onSurface.withValues(alpha: 0.3),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
            ),

            SizedBox(height: getResponsivePadding(20, context)),

            // Category Filter
            Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: getResponsiveFontSize(16, context),
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface,
              ),
            ),
            SizedBox(height: getResponsivePadding(12, context)),
            Wrap(
              spacing: getResponsivePadding(8, context),
              runSpacing: getResponsivePadding(8, context),
              children: [
                _buildCategoryFilterChip('All', null),
                _buildCategoryFilterChip(
                    'Men\'s Wear', ProductCategory.mensWear),
                _buildCategoryFilterChip(
                    'Women\'s Wear', ProductCategory.womensWear),
                _buildCategoryFilterChip('Kids Wear', ProductCategory.kidsWear),
                _buildCategoryFilterChip(
                    'Formal Wear', ProductCategory.formalWear),
                _buildCategoryFilterChip(
                    'Alterations', ProductCategory.alterations),
              ],
            ),

            SizedBox(height: getResponsivePadding(20, context)),

            // Status Filter
            Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: getResponsiveFontSize(16, context),
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface,
              ),
            ),
            SizedBox(height: getResponsivePadding(12, context)),
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: const Text('Active Only'),
                    selected: _activeStatusFilter == true,
                    onSelected: (selected) {
                      setState(() {
                        _activeStatusFilter = selected ? true : null;
                      });
                    },
                  ),
                ),
                SizedBox(width: getResponsivePadding(12, context)),
                Expanded(
                  child: FilterChip(
                    label: const Text('All Products'),
                    selected: _activeStatusFilter == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _activeStatusFilter = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: getResponsivePadding(24, context)),

            // Apply and Reset Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                            : AppColors.onSurface.withValues(alpha: 0.3),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: getResponsivePadding(14, context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(16, context),
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface
                            : AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: getResponsivePadding(12, context)),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _applyFilters(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                      foregroundColor: themeProvider.isDarkMode
                          ? DarkAppColors.onPrimary
                          : AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(
                          vertical: getResponsivePadding(14, context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(16, context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChip(String label, ProductCategory? category) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: _selectedCategory == category,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 10000);
      _selectedCategory = null;
      _activeStatusFilter = null;
    });

    // Also clear filters in the provider
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    productProvider.clearFilters();
  }

  void _applyFilters(BuildContext context) {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    // Apply category filter
    if (_selectedCategory != null) {
      productProvider.filterByCategory(_selectedCategory);
    } else {
      productProvider.filterByCategory(null); // Show all categories
    }

    // Apply price range filter
    if (_priceRange.start != 0 || _priceRange.end != 10000) {
      productProvider.filterByPriceRange(_priceRange);
    } else {
      productProvider.filterByPriceRange(null); // Clear price filter
    }

    // Apply status filter
    if (_activeStatusFilter != null) {
      productProvider.filterByStatus(_activeStatusFilter);
    } else {
      productProvider.filterByStatus(null); // Clear status filter
    }

    Navigator.pop(context);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildSuccessSnackBar('Filters applied successfully!'),
      );
    }
  }
}

// Catalog Sort Bottom Sheet Widget
class CatalogSortBottomSheet extends StatelessWidget with BottomSheetBase {
  const CatalogSortBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Container(
      padding: EdgeInsets.all(getResponsivePadding(20, context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(context, Icons.sort, 'Sort Products'),
          SizedBox(height: getResponsivePadding(20, context)),
          ...ProductScreenConstants.sortOptions.map((sortOption) {
            final label = ProductScreenConstants.sortOptionLabels[sortOption] ??
                sortOption;
            return _buildSortOption(
              context,
              label,
              () => _applySort(productProvider, sortOption, context),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSortOption(
      BuildContext context, String title, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                  : AppColors.onSurface.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                  : AppColors.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _applySort(
      ProductProvider productProvider, String sortBy, BuildContext context) {
    productProvider.sortProducts(sortBy);
    Navigator.pop(context);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildSuccessSnackBar('Products sorted successfully!'),
      );
    }
  }
}
