import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_models.dart';
import '../../../product_data_access.dart';
import '../../providers/theme_provider.dart';
import '../../providers/product_provider.dart';
import '../../screens/catalog/product_detail_screen.dart';
import '../../utils/theme_constants.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/product_screen_constants.dart';
import '../../widgets/catalog/catalog_components.dart';
import 'unified_product_card.dart';
import 'skeleton_loading_widgets.dart';

/// Main content widget for product screen with lazy loading and grid/list views
class ProductScreenContent extends StatefulWidget {
  final bool isGridView;

  const ProductScreenContent({
    super.key,
    required this.isGridView,
  });

  @override
  State<ProductScreenContent> createState() => _ProductScreenContentState();
}

class _ProductScreenContentState extends State<ProductScreenContent> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final threshold =
        position.maxScrollExtent * ProductScreenConstants.scrollThreshold;

    if (position.pixels >= threshold) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore) return;

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    if (!productProvider.hasMoreProducts) return;

    setState(() => _isLoadingMore = true);

    try {
      await productProvider.loadMoreProducts();
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.products;
        final isLoading =
            productProvider.loadingState == LoadingState.initialLoading;

        // Show smooth transition between loading and content
        return SmoothContentTransition(
          isLoading: isLoading && products.isEmpty,
          loadingWidget: _buildSkeletonLoading(),
          contentWidget: products.isEmpty && !isLoading
              ? _buildEmptyState(productProvider)
              : RefreshIndicator(
                  onRefresh: productProvider.refreshProducts,
                  child: widget.isGridView
                      ? _buildGridView(products, productProvider)
                      : _buildListView(products, productProvider),
                ),
        );
      },
    );
  }

  Widget _buildGridView(
      List<Product> products, ProductProvider productProvider) {
    final config = _getResponsiveGridConfiguration(context);

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(config.padding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: config.crossAxisCount,
              crossAxisSpacing: config.crossAxisSpacing,
              mainAxisSpacing: config.mainAxisSpacing,
              mainAxisExtent: config
                  .mainAxisExtent, // Use fixed height instead of aspect ratio
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= products.length) {
                  return _buildLoadingIndicator();
                }

                final product = products[index];
                return FadeInContent(
                  key: ValueKey('fade_grid_item_${product.id}_$index'),
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: index * 50),
                  child: UnifiedProductCard(
                    key: ValueKey('grid_item_${product.id}_$index'),
                    product: product,
                    index: index,
                  ),
                );
              },
              childCount:
                  products.length + (productProvider.hasMoreProducts ? 1 : 0),
            ),
          ),
        ),
      ],
    );
  }

  // Enhanced responsive grid configuration with device-specific optimizations
  GridConfiguration _getResponsiveGridConfiguration(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = ResponsiveUtils.getDeviceType(screenWidth);
    final crossAxisCount = ResponsiveUtils.getCrossAxisCount(screenWidth);
    final childAspectRatio =
        ResponsiveUtils.getAspectRatio(screenWidth, deviceType);
    final spacing = GridSpacing.getSpacing(screenWidth);

    // Calculate mainAxisExtent for compatibility
    final availableWidth = screenWidth - spacing.padding * 2;
    final itemWidth =
        (availableWidth - spacing.crossAxisSpacing * (crossAxisCount - 1)) /
            crossAxisCount;
    final mainAxisExtent = itemWidth / childAspectRatio;

    return GridConfiguration(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: spacing.crossAxisSpacing,
      mainAxisSpacing: spacing.mainAxisSpacing,
      padding: spacing.padding,
      mainAxisExtent: mainAxisExtent.clamp(300, 800), // Reasonable bounds
    );
  }

  Widget _buildListView(
      List<Product> products, ProductProvider productProvider) {
    // Get loading state from widget state
    final isLoadingMore = _isLoadingMore;

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(ProductScreenConstants.screenPadding),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= products.length) {
                  return _buildLoadingIndicator();
                }

                final product = products[index];
                return FadeInContent(
                  key: ValueKey('fade_list_item_${product.id}_$index'),
                  duration: const Duration(milliseconds: 300),
                  delay: Duration(milliseconds: index * 30),
                  child: Container(
                    key: ValueKey('list_item_${product.id}_$index'),
                    margin: EdgeInsets.only(
                        bottom: ProductScreenConstants.componentSpacing),
                    child: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return _buildListItem(product, themeProvider);
                      },
                    ),
                  ),
                );
              },
              childCount:
                  products.length + (productProvider.hasMoreProducts ? 1 : 0),
            ),
          ),
        ),
        if (isLoadingMore)
          SliverToBoxAdapter(
            child: ProgressiveLoadingIndicator(
              isLoadingMore: isLoadingMore,
              loadingMessage: 'Loading more products...',
            ),
          ),
      ],
    );
  }

  Widget _buildListItem(Product product, ThemeProvider themeProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentDensity = ResponsiveUtils.getContentDensity(
      context,
      hasRichContent: product.description.isNotEmpty ||
          product.customizationOptions.isNotEmpty,
      itemCount: 1,
      isGridView: false,
    );

    return Card(
      elevation: ProductScreenConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(ProductScreenConstants.borderRadiusMedium),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(ProductScreenConstants.borderRadiusMedium),
        onTap: () => _navigateToProductDetail(product),
        child: Padding(
          padding: ResponsiveUtils.getAdaptivePadding(
            context,
            basePadding:
                ProductScreenConstants.getResponsivePadding(screenWidth),
            hasRichContent: product.description.isNotEmpty ||
                product.customizationOptions.isNotEmpty,
            itemCount: 1,
            isGridView: false,
          ),
          child: Row(
            children: [
              // Product Image
              Container(
                width: ProductScreenConstants.listItemHeight,
                height: ProductScreenConstants.listItemHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      ProductScreenConstants.borderRadiusSmall),
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.background
                      : AppColors.background,
                ),
                child: product.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                            ProductScreenConstants.borderRadiusSmall),
                        child: Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.inventory_2,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                : AppColors.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.inventory_2,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                            : AppColors.onSurface.withValues(alpha: 0.3),
                      ),
              ),

              SizedBox(width: ProductScreenConstants.componentSpacing),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    if (product.brand.isNotEmpty) ...[
                      Text(
                        product.brand.toUpperCase(),
                        style: TextStyle(
                          fontSize:
                              ProductScreenConstants.getResponsiveFontSize(
                                  screenWidth, 10),
                          fontWeight: FontWeight.w600,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                        ),
                      ),
                      SizedBox(height: ProductScreenConstants.smallSpacing),
                    ],

                    // Name with dynamic sizing
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth;
                        final dynamicFontSize = ResponsiveUtils.dynamicFontSize(
                          baseFontSize:
                              ProductScreenConstants.getResponsiveFontSize(
                                  screenWidth, 14),
                          availableWidth: availableWidth,
                          text: product.name,
                          minFontSize: 12.0,
                          maxFontSize: 16.0,
                        );

                        return Text(
                          product.name,
                          style: TextStyle(
                            fontSize: dynamicFontSize,
                            fontWeight: FontWeight.w600,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface
                                : AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),

                    SizedBox(height: ProductScreenConstants.smallSpacing),

                    // Description
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: ProductScreenConstants.getResponsiveFontSize(
                            screenWidth, 12),
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                            : AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: ProductScreenConstants.smallSpacing),

                    // Rating and Stock - Conditional display based on screen size
                    Row(
                      children: [
                        // Rating - Always show on list view
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size:
                                  ProductScreenConstants.getResponsiveFontSize(
                                      screenWidth, 12),
                              color: Colors.amber,
                            ),
                            SizedBox(
                                width: ProductScreenConstants.smallSpacing),
                            Text(
                              product.rating.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: ProductScreenConstants
                                    .getResponsiveFontSize(screenWidth, 11),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                            width: ProductScreenConstants.componentSpacing),

                        // Stock Status - Show on all screens but with different detail level
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ProductScreenConstants.smallSpacing,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: product.availabilityColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                ProductScreenConstants.borderRadiusSmall),
                          ),
                          child: Text(
                            product.stockCount <= 0
                                ? 'Out of Stock'
                                : screenWidth < 600
                                    ? (product.stockCount <= 5 ? 'Low' : 'In')
                                    : (product.stockCount <= 5
                                        ? 'Low Stock'
                                        : 'In Stock'),
                            style: TextStyle(
                              fontSize:
                                  ProductScreenConstants.getResponsiveFontSize(
                                      screenWidth, 10),
                              fontWeight: FontWeight.w500,
                              color: product.availabilityColor,
                            ),
                          ),
                        ),

                        // Additional info for larger screens
                        if (screenWidth >= 768) ...[
                          SizedBox(
                              width: ProductScreenConstants.componentSpacing),
                          if (product.brand.isNotEmpty)
                            Text(
                              'by ${product.brand}',
                              style: TextStyle(
                                fontSize: ProductScreenConstants
                                    .getResponsiveFontSize(screenWidth, 10),
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.onSurface
                                        .withValues(alpha: 0.6)
                                    : AppColors.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ],
                    ),

                    // Customization options for larger screens
                    if (screenWidth >= 600 &&
                        product.customizationOptions.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                            top: ProductScreenConstants.smallSpacing),
                        child: Row(
                          children: [
                            Icon(
                              Icons.design_services,
                              size:
                                  ProductScreenConstants.getResponsiveFontSize(
                                      screenWidth, 12),
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.primary
                                  : AppColors.primary,
                            ),
                            SizedBox(
                                width: ProductScreenConstants.smallSpacing),
                            Text(
                              'Customizable',
                              style: TextStyle(
                                fontSize: ProductScreenConstants
                                    .getResponsiveFontSize(screenWidth, 10),
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.primary
                                    : AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(width: ProductScreenConstants.componentSpacing),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.formattedPrice,
                    style: TextStyle(
                      fontSize: ProductScreenConstants.getResponsiveFontSize(
                          screenWidth, 16),
                      fontWeight: FontWeight.w700,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface
                          : AppColors.onSurface,
                    ),
                  ),
                  if (product.originalPrice != null &&
                      product.savingsAmount > 0) ...[
                    SizedBox(height: ProductScreenConstants.smallSpacing),
                    Text(
                      product.formattedOriginalPrice,
                      style: TextStyle(
                        fontSize: ProductScreenConstants.getResponsiveFontSize(
                            screenWidth, 12),
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                            : AppColors.onSurface.withValues(alpha: 0.6),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState(ProductProvider productProvider) {
    final hasActiveFilters = productProvider.selectedCategory != null ||
        productProvider.priceRange != null ||
        productProvider.activeStatusFilter != null;

    if (hasActiveFilters) {
      return CatalogEmptyState();
    }

    return Container(
      padding: EdgeInsets.all(ProductScreenConstants.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: ProductScreenConstants.componentSpacing),
          Text(
            ProductScreenConstants.noProductsMessage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ProductScreenConstants.smallSpacing),
          Text(
            'Check back later for new products',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width < 600 ? 8.0 : 16.0,
          ),
          sliver: widget.isGridView
              ? const ProductGridSkeleton(itemCount: 6)
              : const ProductListSkeleton(itemCount: 8),
        ),
      ],
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}
