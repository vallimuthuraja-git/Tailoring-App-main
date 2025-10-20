import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/theme_constants.dart';
import '../../utils/product_screen_constants.dart';
import '../../widgets/catalog/expandable_search_bar.dart';
import '../../screens/cart/cart_screen.dart';

/// Unified app bar for catalog screens with configurable actions
class CatalogAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearchBar;
  final bool showFilterButton;
  final bool showSortButton;
  final bool showGridToggle;
  final bool showRefreshButton;
  final bool showCartBadge;
  final bool showLogoutButton;
  final bool isSearchExpanded;
  final bool isGridView;
  final ValueChanged<bool> onSearchExpandedChanged;
  final ValueChanged<bool> onGridViewChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onSortPressed;
  final VoidCallback onRefreshPressed;
  final ThemeProvider themeProvider;

  const CatalogAppBar({
    super.key,
    required this.title,
    required this.themeProvider,
    this.showSearchBar = true,
    this.showFilterButton = true,
    this.showSortButton = true,
    this.showGridToggle = true,
    this.showRefreshButton = true,
    this.showCartBadge = false,
    this.showLogoutButton = false,
    this.isSearchExpanded = true,
    this.isGridView = true,
    required this.onSearchExpandedChanged,
    required this.onGridViewChanged,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.onSortPressed,
    required this.onRefreshPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen =
        screenWidth >= ProductScreenConstants.tabletBreakpoint;

    return AppBar(
      centerTitle: true,
      title: showSearchBar
          ? SizedBox(
              width: isLargeScreen
                  ? ProductScreenConstants.screenPadding * 25
                  : ProductScreenConstants.screenPadding * 18.75,
              child: ExpandableSearchBar(
                isExpanded: isSearchExpanded,
                onExpandToggle: () {
                  onSearchExpandedChanged(!isSearchExpanded);
                },
                onSearchChanged: onSearchChanged,
              ),
            )
          : Text(
              title,
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface,
                fontSize: ProductScreenConstants.getResponsiveFontSize(
                    screenWidth, ProductScreenConstants.screenPadding * 1.25),
                fontWeight: FontWeight.w600,
              ),
            ),
      backgroundColor:
          themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
      foregroundColor: themeProvider.isDarkMode
          ? DarkAppColors.onSurface
          : AppColors.onSurface,
      elevation: ProductScreenConstants.appBarElevation,
      actions: _buildActions(context, isLargeScreen),
    );
  }

  List<Widget> _buildActions(BuildContext context, bool isLargeScreen) {
    final actions = <Widget>[];

    // Cart badge (from intelligent app bar)
    if (showCartBadge) {
      actions.add(const CartBadgeIcon());
    }

    // Logout button (from intelligent app bar)
    if (showLogoutButton) {
      actions.add(const LogoutIcon());
    }

    // Filter button
    if (showFilterButton) {
      actions.add(
        IconButton(
          onPressed: onFilterPressed,
          icon: Icon(
            Icons.filter_list,
            color: themeProvider.isDarkMode
                ? AppColors.primary
                : DarkAppColors.primary,
          ),
          tooltip: 'Filter products',
        ),
      );
    }

    // Sort button
    if (showSortButton) {
      actions.add(
        IconButton(
          onPressed: onSortPressed,
          icon: Icon(
            Icons.sort,
            color: themeProvider.isDarkMode
                ? AppColors.primary
                : DarkAppColors.primary,
          ),
          tooltip: 'Sort products',
        ),
      );
    }

    // Grid/List toggle
    if (showGridToggle) {
      actions.add(
        IconButton(
          onPressed: () => onGridViewChanged(!isGridView),
          icon: Icon(
            isGridView ? Icons.grid_view : Icons.list,
            color: themeProvider.isDarkMode
                ? AppColors.primary
                : DarkAppColors.primary,
          ),
          tooltip: isGridView ? 'Grid view' : 'List view',
        ),
      );
    }

    // Refresh button
    if (showRefreshButton) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefreshPressed,
          tooltip: 'Refresh',
        ),
      );
    }

    return actions;
  }
}

/// Specialized app bar for product detail screens with back button and actions
class ProductDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onEditPressed;
  final ThemeProvider themeProvider;
  final bool showEditButton;

  const ProductDetailAppBar({
    super.key,
    required this.title,
    required this.themeProvider,
    this.isFavorite = false,
    this.onFavoritePressed,
    this.onSharePressed,
    this.onEditPressed,
    this.showEditButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      actions: [
        // Favorite button
        IconButton(
          onPressed: onFavoritePressed,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFavorite),
              color: isFavorite ? Colors.red : Colors.white,
            ),
          ),
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),

        // Share button
        IconButton(
          onPressed: onSharePressed,
          icon: const Icon(Icons.share, color: Colors.white),
          tooltip: 'Share product',
        ),

        // Edit button (conditional)
        if (showEditButton)
          IconButton(
            onPressed: onEditPressed,
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit product',
          ),
      ],
    );
  }
}

/// Compact app bar for edit screens with save action
class ProductEditAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isLoading;
  final VoidCallback? onSavePressed;
  final ThemeProvider themeProvider;

  const ProductEditAppBar({
    super.key,
    required this.title,
    required this.themeProvider,
    this.isLoading = false,
    this.onSavePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor:
          themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
      elevation: 0,
      iconTheme: IconThemeData(
        color: themeProvider.isDarkMode
            ? DarkAppColors.onSurface
            : AppColors.onSurface,
      ),
      titleTextStyle: TextStyle(
        color: themeProvider.isDarkMode
            ? DarkAppColors.onSurface
            : AppColors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : onSavePressed,
          child: Text(
            'Save',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Enhanced cart icon with badge for app bar actions
class CartBadgeIcon extends StatelessWidget {
  const CartBadgeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: cartProvider.itemCount > 0
                        ? [
                            themeProvider.isDarkMode
                                ? DarkAppColors.primary.withValues(alpha: 0.8)
                                : AppColors.primary.withValues(alpha: 0.8),
                            themeProvider.isDarkMode
                                ? DarkAppColors.secondary.withValues(alpha: 0.8)
                                : AppColors.secondary.withValues(alpha: 0.8),
                          ]
                        : [
                            Colors.transparent,
                            Colors.transparent,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: cartProvider.itemCount > 0
                      ? [
                          BoxShadow(
                            color: (themeProvider.isDarkMode
                                    ? DarkAppColors.primary
                                    : AppColors.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: cartProvider.itemCount > 0
                        ? (themeProvider.isDarkMode
                            ? DarkAppColors.onPrimary
                            : AppColors.onPrimary)
                        : (themeProvider.isDarkMode
                            ? DarkAppColors.onSurface
                            : AppColors.onSurface),
                    size: 24,
                  ),
                  tooltip: 'Cart (${cartProvider.itemCount} items)',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor:
                        cartProvider.itemCount > 0 ? Colors.transparent : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeProvider.isDarkMode
                              ? DarkAppColors.error
                              : AppColors.error,
                          themeProvider.isDarkMode
                              ? DarkAppColors.error.withOpacity(0.8)
                              : AppColors.error.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (themeProvider.isDarkMode
                                  ? DarkAppColors.error
                                  : AppColors.error)
                              .withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.surface
                            : AppColors.surface,
                        width: 1.5,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 18,
                    ),
                    child: Text(
                      cartProvider.itemCount > 99
                          ? '99+'
                          : cartProvider.itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Logout icon button for app bar actions
class LogoutIcon extends StatelessWidget {
  const LogoutIcon({super.key});

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await authProvider.signOut();
                // The AuthWrapper will handle navigation to login screen
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return IconButton(
      icon: Icon(
        Icons.logout,
        color: themeProvider.isDarkMode
            ? DarkAppColors.onSurface
            : AppColors.onSurface,
      ),
      tooltip: 'Logout',
      onPressed: () => _showLogoutDialog(context, authProvider),
    );
  }
}
