import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import '../../utils/product_screen_constants.dart';
import 'catalog_bottom_sheets.dart';

/// Action bar with sort and filter quick access buttons
class ProductScreenActionBar extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onToggleView;

  const ProductScreenActionBar({
    super.key,
    required this.isGridView,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.all(ProductScreenConstants.screenPadding),
      child: Row(
        children: [
          // Sort Button
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.sort,
              label: 'Sort',
              onPressed: () => _showSortBottomSheet(context),
              themeProvider: themeProvider,
              screenWidth: screenWidth,
            ),
          ),

          SizedBox(width: ProductScreenConstants.componentSpacing),

          // Filter Button
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.filter_list,
              label: 'Filter',
              onPressed: () => _showFilterBottomSheet(context),
              themeProvider: themeProvider,
              screenWidth: screenWidth,
            ),
          ),

          SizedBox(width: ProductScreenConstants.componentSpacing),

          // View Toggle Button (Grid/List)
          SizedBox(
            width: ProductScreenConstants.actionBarHeight * 0.6,
            height: ProductScreenConstants.actionBarHeight * 0.6,
            child: _buildViewToggleButton(context, themeProvider, screenWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeProvider themeProvider,
    required double screenWidth,
  }) {
    return Container(
      height: ProductScreenConstants.actionBarHeight,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius:
            BorderRadius.circular(ProductScreenConstants.borderRadiusMedium),
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
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: ProductScreenConstants.getResponsiveFontSize(screenWidth, 20),
          color: themeProvider.isDarkMode
              ? DarkAppColors.primary
              : AppColors.primary,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize:
                ProductScreenConstants.getResponsiveFontSize(screenWidth, 14),
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal:
                ProductScreenConstants.getResponsivePadding(screenWidth),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                ProductScreenConstants.borderRadiusMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggleButton(
      BuildContext context, ThemeProvider themeProvider, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius:
            BorderRadius.circular(ProductScreenConstants.borderRadiusMedium),
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
}
