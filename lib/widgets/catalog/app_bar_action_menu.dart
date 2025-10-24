import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme_constants.dart';
import '../../widgets/catalog/catalog_bottom_sheets.dart';

class AppBarActionMenu extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onToggleView;
  final VoidCallback onFilterPressed;
  final VoidCallback onSortPressed;

  const AppBarActionMenu({
    super.key,
    required this.isGridView,
    required this.onToggleView,
    required this.onFilterPressed,
    required this.onSortPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'More actions',
      onSelected: (value) {
        switch (value) {
          case 'filter':
            _showFilterBottomSheet(context);
            break;
          case 'sort':
            _showSortBottomSheet(context);
            break;
          case 'view_toggle':
            onToggleView();
            break;
          case 'clear_filters':
            productProvider.clearFilters();
            break;
        }
      },
      itemBuilder: (context) => [
        if (productProvider.hasActiveFilters)
          PopupMenuItem(
            value: 'clear_filters',
            child: Row(
              children: [
                Icon(
                  Icons.clear_all,
                  size: 20,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.error
                      : AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Clear All Filters',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.error
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CatalogFilterBottomSheet(),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CatalogSortBottomSheet(),
    );
  }
}
