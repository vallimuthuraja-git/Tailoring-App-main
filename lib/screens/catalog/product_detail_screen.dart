import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/theme_constants.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late PageController _imageController;
  late AnimationController _sizeSelectorController;
  late AnimationController _fabricSelectorController;
  late AnimationController _reviewExpansionController;

  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedFabric;
  String? _selectedCustomization;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    _sizeSelectorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabricSelectorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _reviewExpansionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfFavorite();
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    _sizeSelectorController.dispose();
    _fabricSelectorController.dispose();
    _reviewExpansionController.dispose();
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    if (wishlistProvider.wishlistServiceIds.isEmpty) {
      await wishlistProvider.loadWishlist();
    }
    setState(() {
      _isFavorite = wishlistProvider.isServiceInWishlist(widget.product.id);
    });
  }

  void _toggleFavorite() async {
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    try {
      if (_isFavorite) {
        await wishlistProvider.removeFromWishlist(widget.product.id);
        setState(() => _isFavorite = false);
        _showSnackBar('Removed from favorites');
      } else {
        await wishlistProvider.addToWishlist(widget.product.id);
        setState(() => _isFavorite = true);
        _showSnackBar('Added to favorites');
      }
    } catch (e) {
      _showSnackBar('Error updating favorites: $e');
    }
  }

  void _addToCart() async {
    if (!widget.product.isActive) {
      _showSnackBar('Product is currently unavailable');
      return;
    }

    if (widget.product.stockCount <= 0) {
      _showSnackBar('Product is out of stock');
      return;
    }

    if (widget.product.availableSizes.isNotEmpty && _selectedSize == null) {
      _showSnackBar('Please select a size');
      return;
    }

    if (widget.product.availableFabrics.isNotEmpty && _selectedFabric == null) {
      _showSnackBar('Please select a fabric');
      return;
    }

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final success = await cartProvider.addToCart(widget.product);

      if (success) {
        _showSnackBar('Added to cart successfully!');
        // Small animation feedback
        setState(() {});
      } else {
        _showSnackBar('Failed to add item to cart');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        final isShopOwner = authProvider.isShopOwnerOrAdmin;

        return Scaffold(
          backgroundColor: themeProvider.isDarkMode
              ? DarkAppColors.background
              : AppColors.background,
          body: CustomScrollView(
            slivers: [
              // Image Gallery App Bar
              _buildImageGalleryAppBar(themeProvider, isShopOwner),

              // Main Content
              SliverToBoxAdapter(
                child: Container(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.surface
                      : AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Basic Info
                      _buildProductBasicInfo(themeProvider),

                      // Pricing Section
                      _buildPricingSection(themeProvider),

                      // Size Selection
                      if (widget.product.availableSizes.isNotEmpty)
                        _buildSizeSelector(themeProvider),

                      // Fabric Selection
                      if (widget.product.availableFabrics.isNotEmpty)
                        _buildFabricSelector(themeProvider),

                      // Customization Options
                      if (widget.product.customizationOptions.isNotEmpty)
                        _buildCustomizationOptions(themeProvider),

                      // Product Description
                      _buildProductDescription(themeProvider),

                      // Technical Specifications
                      if (widget.product.specifications.isNotEmpty)
                        _buildSpecifications(themeProvider),

                      // Reviews Section
                      if (widget.product.rating.reviewCount > 0)
                        _buildReviewsSection(themeProvider),

                      // Additional Info
                      _buildAdditionalInfo(themeProvider),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Bar with Add to Cart
          bottomNavigationBar: _buildBottomNavigationBar(themeProvider, isShopOwner),
        );
      },
    );
  }

  Widget _buildImageGalleryAppBar(ThemeProvider themeProvider, bool isShopOwner) {
    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: MediaQuery.of(context).size.height * 0.5,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image Gallery
            PageView.builder(
              controller: _imageController,
              onPageChanged: (index) => setState(() => _currentImageIndex = index),
              itemCount: widget.product.imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = widget.product.imageUrls[index];
                return Hero(
                  tag: 'product-image-${widget.product.id}-$index',
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            // Image Indicators
            if (widget.product.imageUrls.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.product.imageUrls.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentImageIndex == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      // App Bar Actions
      actions: [
        // Favorite Button
        IconButton(
          onPressed: _toggleFavorite,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(_isFavorite),
              color: _isFavorite ? Colors.red : Colors.white,
            ),
          ),
        ),

        // Share Button
        IconButton(
          onPressed: () {
            // TODO: Add share functionality when share_plus dependency is available
            _showSnackBar('Share feature coming soon!');
          },
          icon: const Icon(Icons.share, color: Colors.white),
        ),

        // Edit Button (Shop Owner only)
        if (isShopOwner)
          IconButton(
            onPressed: () {
              // TODO: Navigate to edit screen
              _showSnackBar('Edit functionality coming soon');
            },
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildProductBasicInfo(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          if (widget.product.brand.isNotEmpty) ...[
            Text(
              widget.product.brand.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Product Name
          Text(
            widget.product.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          // Category and Rating Row
          Row(
            children: [
              // Category
              Text(
                widget.product.categoryName,
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withOpacity(0.8)
                      : AppColors.onSurface.withOpacity(0.8),
                ),
              ),

              const SizedBox(width: 16),

              // Rating
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.product.rating.averageRating.toStringAsFixed(1)} (${widget.product.rating.reviewCount})',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withOpacity(0.7)
                          : AppColors.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Badges
          if (widget.product.activeBadges.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.product.activeBadges.map((badge) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(badge).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getBadgeColor(badge).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getBadgeColor(badge),
                    ),
                  ),
                ),
              ).toList(),
            ),

          const SizedBox(height: 16),

          // Stock Status
          Row(
            children: [
              Icon(
                widget.product.stockCount > 0 ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: widget.product.availabilityColor,
              ),
              const SizedBox(width: 8),
              Text(
                widget.product.availabilityText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.product.availabilityColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface.withOpacity(0.8)
            : AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Price
              Text(
                widget.product.formattedPrice,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
              ),

              // Original Price and Savings
              if (widget.product.originalPrice != null && widget.product.savingsAmount > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      widget.product.formattedOriginalPrice,
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withOpacity(0.6)
                            : AppColors.onSurface.withOpacity(0.6),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Save ₹${widget.product.savingsAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // Sold Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  '${widget.product.soldCount} sold',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelector(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Size',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.product.availableSizes.map((size) {
              final isSelected = _selectedSize == size;
              return ChoiceChip(
                label: Text(size),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedSize = selected ? size : null);
                },
                backgroundColor: themeProvider.isDarkMode
                    ? DarkAppColors.background
                    : AppColors.background,
                selectedColor: (themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary).withOpacity(0.2),
                checkmarkColor: themeProvider.isDarkMode
                    ? DarkAppColors.onPrimary
                    : AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary)
                        : themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withOpacity(0.2)
                            : AppColors.onSurface.withOpacity(0.2),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFabricSelector(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Fabric',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.product.availableFabrics.map((fabric) {
              final isSelected = _selectedFabric == fabric;
              return ChoiceChip(
                label: Text(fabric),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedFabric = selected ? fabric : null);
                },
                backgroundColor: themeProvider.isDarkMode
                    ? DarkAppColors.background
                    : AppColors.background,
                selectedColor: (themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary).withOpacity(0.2),
                checkmarkColor: themeProvider.isDarkMode
                    ? DarkAppColors.onPrimary
                    : AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary)
                        : themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withOpacity(0.2)
                            : AppColors.onSurface.withOpacity(0.2),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationOptions(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customization Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.product.customizationOptions.map((option) {
            final isSelected = _selectedCustomization == option;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _selectedCustomization,
                onChanged: (value) {
                  setState(() => _selectedCustomization = value);
                },
                activeColor: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductDescription(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withOpacity(0.8)
                  : AppColors.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Technical Specifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.product.specifications.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${entry.key}:',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.value.toString(),
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withOpacity(0.8)
                            : AppColors.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Rating Summary
          Row(
            children: [
              const Icon(Icons.star, size: 24, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                '${widget.product.rating.averageRating.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.product.rating.reviewCount} reviews)',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withOpacity(0.6)
                      : AppColors.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Recent Reviews
          ...widget.product.rating.recentReviews.take(3).map((review) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            if (index < review.rating) {
                              return const Icon(Icons.star, size: 16, color: Colors.amber);
                            }
                            return const Icon(Icons.star_border, size: 16, color: Colors.grey);
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(review.comment),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(review.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withOpacity(0.6)
                            : AppColors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          if (widget.product.rating.reviewCount > 3)
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to full reviews screen
                _showSnackBar('View all reviews coming soon');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All Reviews'),
            ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withOpacity(0.6)
                    : AppColors.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Added ${_formatDate(widget.product.createdAt)}',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withOpacity(0.6)
                      : AppColors.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.update,
                size: 20,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withOpacity(0.6)
                    : AppColors.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Updated ${_formatDate(widget.product.updatedAt)}',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withOpacity(0.6)
                      : AppColors.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(ThemeProvider themeProvider, bool isShopOwner) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector (Collapsed for now)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: !widget.product.isActive
                    ? null
                    : () => _addToCart(),
                icon: Icon(
                  widget.product.stockCount <= 0 ? Icons.block : Icons.add_shopping_cart,
                  size: 20,
                ),
                label: Text(
                  widget.product.stockCount <= 0
                      ? 'Out of Stock'
                      : 'Add to Cart',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.product.stockCount <= 0
                      ? Colors.grey
                      : (themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary),
                  foregroundColor: themeProvider.isDarkMode
                      ? DarkAppColors.onPrimary
                      : AppColors.onPrimary,
                  disabledBackgroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: widget.product.stockCount <= 0 ? 0 : 3,
                ),
              ),
            ),

            if (isShopOwner) ...[
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  // TODO: Edit product
                  _showSnackBar('Edit function coming soon');
                },
                icon: const Icon(Icons.edit),
                style: IconButton.styleFrom(
                  backgroundColor: (themeProvider.isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary).withOpacity(0.1),
                  foregroundColor: themeProvider.isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'new':
      case 'new arrival':
        return Colors.blue;
      case 'bestseller':
      case 'best seller':
        return Colors.red;
      case 'sale':
      case 'flash sale':
      case 'clearance':
        return Colors.orange;
      case 'premium':
      case 'luxury':
        return Colors.purple;
      case 'limited':
      case 'limited stock':
        return Colors.amber;
      case 'top rated':
        return Colors.green;
      case 'trending':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}