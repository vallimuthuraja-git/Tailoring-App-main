import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/theme_constants.dart';
import '../../utils/product_screen_constants.dart';

class ExpandableSearchBar extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final Function(String) onSearchChanged;

  const ExpandableSearchBar({
    super.key,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.onSearchChanged,
  });

  @override
  State<ExpandableSearchBar> createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends State<ExpandableSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _isSearching = true);
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(
      ProductScreenConstants.searchDebounceDelay,
      () {
        widget.onSearchChanged(value);
        if (mounted) setState(() => _isSearching = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;

    // Always show expanded search bar without folding capability
    return SizedBox(
      height: ProductScreenConstants.searchBarHeight,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: ProductScreenConstants.searchHint,
          hintStyle: TextStyle(
            fontSize:
                ProductScreenConstants.getResponsiveFontSize(screenWidth, 14),
            color: (themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface)
                .withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: ProductScreenConstants.getResponsiveFontSize(screenWidth, 18),
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withOpacity(0.7)
                : AppColors.onSurface.withOpacity(0.7),
          ),
          suffixIcon: _isSearching
              ? Container(
                  width: ProductScreenConstants.getResponsiveFontSize(
                      screenWidth, 18),
                  height: ProductScreenConstants.getResponsiveFontSize(
                      screenWidth, 18),
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                    ),
                  ),
                )
              : productProvider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: ProductScreenConstants.getResponsiveFontSize(
                            screenWidth, 18),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      },
                      tooltip: 'Clear search',
                    )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                ProductScreenConstants.borderRadiusMedium),
            borderSide: BorderSide(
              color: (themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface)
                  .withOpacity(0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                ProductScreenConstants.borderRadiusMedium),
            borderSide: BorderSide(
              color: (themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface)
                  .withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                ProductScreenConstants.borderRadiusMedium),
            borderSide: BorderSide(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: themeProvider.isDarkMode
              ? DarkAppColors.surface
              : AppColors.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal:
                ProductScreenConstants.getResponsivePadding(screenWidth),
            vertical:
                ProductScreenConstants.getResponsivePadding(screenWidth) / 2,
          ),
        ),
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
