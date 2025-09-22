import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_models.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/product_screen_constants.dart';
import 'unified_product_card.dart';

/// Modular widget for displaying products in grid or list view with pagination
class ProductGridView extends StatelessWidget {
  final List<Product> products;
  final bool isGridView;
  final ThemeProvider themeProvider;
  final void Function(Product)? onProductTap;

  const ProductGridView({
    super.key,
    required this.products,
    required this.isGridView,
    required this.themeProvider,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async =>
                context.read<ProductProvider>().loadProducts(),
            child: isGridView
                ? GridView.builder(
                    padding: ResponsiveUtils.getAdaptivePadding(context,
                        basePadding: ProductScreenConstants.screenPadding),
                    gridDelegate: ProductGridDelegate.fromContext(context),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return UnifiedProductCard(
                        key: ValueKey('product_card_${product.id}_$index'),
                        product: product,
                        index: index,
                        onTap: onProductTap != null
                            ? () => onProductTap!(product)
                            : null,
                      );
                    },
                  )
                : ListView.builder(
                    padding: ResponsiveUtils.getAdaptivePadding(context,
                        basePadding: ProductScreenConstants.screenPadding),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: UnifiedProductCard(
                          key: ValueKey('product_card_${product.id}_$index'),
                          product: product,
                          index: index,
                          onTap: onProductTap != null
                              ? () => onProductTap!(product)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ),
        // Load more section with lazy loading
        Consumer<ProductProvider>(
          builder: (context, provider, child) {
            if (provider.hasMoreProducts && !provider.isLoadingMore) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Semantics(
                  label: 'Load more products',
                  button: true,
                  child: ElevatedButton(
                    onPressed: () => provider.loadMoreProducts(),
                    child: const Text('Load More Products'),
                  ),
                ),
              );
            } else if (provider.isLoadingMore) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Semantics(
                  label: 'Loading more products',
                  child: const CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

/// Custom grid delegate for responsive product grid
class ProductGridDelegate extends SliverGridDelegateWithFixedCrossAxisCount {
  const ProductGridDelegate({
    required super.crossAxisCount,
    super.mainAxisSpacing = ProductScreenConstants.gridMainAxisSpacing,
    super.crossAxisSpacing = ProductScreenConstants.gridCrossAxisSpacing,
    super.childAspectRatio = ProductScreenConstants.imageAspectRatio,
  });

  factory ProductGridDelegate.fromContext(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        ProductScreenConstants.getGridCrossAxisCount(screenWidth);

    return ProductGridDelegate(
      crossAxisCount: crossAxisCount,
      childAspectRatio: ProductScreenConstants.imageAspectRatio,
    );
  }
}
