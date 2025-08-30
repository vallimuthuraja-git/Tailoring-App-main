# Product Catalog Screen Documentation

## Overview
The `product_catalog_screen.dart` file contains the advanced, responsive product catalog interface for the AI-Enabled Tailoring Shop Management System. It provides a comprehensive product browsing experience with sophisticated search, filtering, responsive design, and role-based functionality, featuring both desktop and mobile optimized layouts with extensive theme integration.

## Architecture

### Core Components
- **`ProductCatalogScreen`**: Main catalog screen with responsive layout and advanced features
- **Advanced Search System**: Real-time search with multiple filter criteria
- **Category-Based Navigation**: Tab-based category filtering with icons
- **Responsive Design**: Desktop sidebar layout and mobile-optimized interface
- **Role-Based Access Control**: Shop owner exclusive features and editing capabilities
- **Product Cards**: Animated, interactive product display with hover effects
- **Filter System**: Comprehensive bottom sheet filtering with price range, category, and sorting
- **Product Details Screen**: Full-screen product view with image gallery

### Key Features
- **Responsive Layout**: Adaptive design for desktop (with sidebar) and mobile devices
- **Advanced Search**: Real-time search with clear/reset functionality
- **Category Tabs**: Visual category navigation with icons and gradients
- **Theme Integration**: Complete theme system integration with dynamic colors
- **Product Cards**: Rich product display with animations, ratings, and quick actions
- **Filter System**: Price range, category, and sorting filters
- **Role-Based Features**: Shop owner editing capabilities and administrative functions
- **Image Handling**: Advanced image loading with error states and galleries
- **Statistics Display**: Product count and category statistics
- **Navigation Integration**: Seamless flow to product details and editing

## Responsive Layout System

### Desktop Layout (Wide Screen)
```dart
if (availableWidth >= 800) {
  return Row(
    children: [
      // Enhanced Left Sidebar
      Container(
        width: 280,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Header with icon and title
            Row(children: [
              Icon(Icons.filter_list_rounded, color: primaryColor),
              Text('Discover Products', style: headerStyle),
            ]),

            const SizedBox(height: 20),

            // Quick stats section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary.withOpacity(0.08), primary.withOpacity(0.04)]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withOpacity(0.2)),
              ),
              child: Column(children: [
                Text('Quick Stats', style: statsTitleStyle),
                _buildStatItem(icon: Icons.inventory_2, label: '${products.length} Products'),
                _buildStatItem(icon: Icons.category, label: '${categories.length} Categories'),
                _buildStatItem(icon: Icons.search, label: searchStatus),
              ]),
            ),

            // Advanced filters button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showFilterBottomSheet(context),
                icon: const Icon(Icons.filter_alt_rounded, size: 20),
                label: const Text('Advanced Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            // Quick actions
            Column(children: [
              _buildQuickAction(icon: Icons.refresh, label: 'Clear Filters', onTap: clearFilters),
              _buildQuickAction(icon: Icons.favorite_border, label: 'View Favorites', onTap: showFavorites),
              _buildQuickAction(icon: Icons.history, label: 'Recent Searches', onTap: showSearchHistory),
            ]),
          ]),
        ),
      ),

      // Main content area
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildProductGrid(productProvider),
        ),
      ),
    ],
  );
}
```

### Mobile Layout (Narrow Screen)
```dart
return Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: productProvider.isLoading
      ? const Center(child: CircularProgressIndicator())
      : productProvider.products.isEmpty
          ? _buildEmptyState()
          : _buildProductGrid(productProvider),
);
```

## Search and Filter System

### Enhanced Search Bar with Integrated Button
```dart
Container(
  width: MediaQuery.of(context).size.width * 0.65, // Increased to 65% width on desktop
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: primary.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))],
  ),
  child: Row(
    children: [
      // Expanded TextField without prefix icon
      Expanded(
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: onSurface, fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Search products, categories...',
            hintStyle: TextStyle(color: onSurface.withOpacity(0.5), fontSize: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
              borderSide: BorderSide.none
            ),
            filled: true,
            fillColor: surface.withOpacity(0.9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          onChanged: (value) => productProvider.searchProducts(value),
          onSubmitted: (value) => handleSearchSubmission(value),
        ),
      ),

      // Integrated Search Button (no border, merges with input)
      Container(
        height: 56, // Match TextField height
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
          boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
            onTap: () => handleSearchSubmission(_searchController.text),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                Icons.search_rounded,
                color: onPrimary,
                size: 24,
              ),
            ),
          ),
        ),
      ),

      // Additional actions button (clear/advanced search)
      if (_searchController.text.isNotEmpty || _showAdvancedSearch)
        Container(
          height: 56,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: onSurface.withOpacity(0.2)),
          ),
          child: IconButton(
            onPressed: _searchController.text.isNotEmpty ? clearSearch : showAdvancedSearch,
            icon: Icon(
              _searchController.text.isNotEmpty ? Icons.clear_rounded : Icons.tune_rounded,
              size: 20,
              color: onSurface.withOpacity(0.7),
            ),
            tooltip: _searchController.text.isNotEmpty ? 'Clear search' : 'Advanced search',
          ),
        ),
    ],
  ),
)
```

### Category Tabs Navigation
```dart
TabBar(
  controller: _tabController,
  isScrollable: true,
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  indicator: BoxDecoration(
    gradient: LinearGradient(colors: [primary, primary.withOpacity(0.8)]),
    borderRadius: BorderRadius.circular(8),
  ),
  tabs: [
    _buildCategoryTab('All', Icons.apps),
    _buildCategoryTab('Men\'s Wear', Icons.person),
    _buildCategoryTab('Women\'s Wear', Icons.person_2),
    _buildCategoryTab('Kids Wear', Icons.child_care),
    _buildCategoryTab('Formal Wear', Icons.business_center),
    _buildCategoryTab('Alterations', Icons.content_cut),
  ],
  onTap: (index) {
    ProductCategory? category = getCategoryFromIndex(index);
    productProvider.filterByCategory(category);
  },
)
```

### Filter Bottom Sheet
```dart
void _showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const FilterBottomSheet(),
  );
}
```

## Product Card System

### Compact Product Card with Animations
```dart
class _CompactProductCard extends StatefulWidget {
  final Product product;

  @override
  State<_CompactProductCard> createState() => _CompactProductCardState();
}

class _CompactProductCardState extends State<_CompactProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}
```

### Product Card Layout
```dart
Card(
  margin: const EdgeInsets.only(bottom: 12),
  child: InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () => navigateToProductDetails(product),
    child: Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isHovered ? primary.withOpacity(0.3) : onSurface.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: _isHovered ? primary.withOpacity(0.1) : Colors.black.withOpacity(0.04),
            blurRadius: _isHovered ? 12 : 8,
            offset: Offset(0, _isHovered ? 4 : 2),
          ),
        ],
        gradient: _isHovered ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surface.withOpacity(0.95), surface],
        ) : null,
      ),
      child: Stack(children: [
        // Product content
        Column(children: [
          // Image section with overlay and badges
          _buildProductImageSection(),

          // Details section with pricing and info
          _buildProductDetailsSection(),
        ]),

        // Hover overlay with quick actions
        if (_isHovered) _buildHoverOverlay(),
      ]),
    ),
  ),
)
```

### Product Image Section
```dart
Stack(
  children: [
    Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: background,
      ),
      child: product.imageUrls.isNotEmpty
          ? Hero(
              tag: 'product_${product.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product.imageUrls.first,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: background,
                      child: Center(child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      )),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: background,
                    child: Icon(Icons.inventory_2, size: 40, color: onSurface.withOpacity(0.3)),
                  ),
                ),
              ),
            )
          : Container(
              color: background,
              child: Icon(Icons.inventory_2, size: 40, color: onSurface.withOpacity(0.3)),
            ),
    ),

    // Out of stock overlay
    if (!product.isActive) Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(child: Text('Out of Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
    ),

    // Category badge and image count
    Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Category badge with icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [categoryColor.withOpacity(0.9), categoryColor.withOpacity(0.7)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: categoryColor.withOpacity(0.3), blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(children: [
              Icon(_getCategoryIcon(product.category), size: 10, color: Colors.white),
              const SizedBox(width: 4),
              Text(product.categoryName.length > 10 ? '${product.categoryName.substring(0, 10)}...' : product.categoryName,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
            ]),
          ),

          // Image count indicator
          if (product.imageUrls.length > 1) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(children: [
              const Icon(Icons.photo_library, size: 11, color: Colors.white),
              const SizedBox(width: 4),
              Text('${product.imageUrls.length}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    ),

    // Edit button for shop owners
    if (isShopOwner) Positioned(
      top: 10,
      right: 10,
      child: GestureDetector(
        onTap: () => _navigateToEditProduct(context, product),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.9)]),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Icon(Icons.edit, size: 16, color: primary),
        ),
      ),
    ),
  ],
)
```

### Product Details Section
```dart
Padding(
  padding: const EdgeInsets.all(14),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Product Name
      Text(
        product.name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: onSurface,
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      const SizedBox(height: 10),

      // Price and rating row
      Row(children: [
        // Enhanced Price Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primary.withOpacity(0.1), primary.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primary.withOpacity(0.2), width: 1),
          ),
          child: Text(
            '₹${product.basePrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ),

        const Spacer(),

        // Rating with enhanced design
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.amber.shade200, width: 1),
          ),
          child: Row(children: [
            Icon(Icons.star, size: 12, color: Colors.amber.shade600),
            const SizedBox(width: 3),
            Text('4.5', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.amber.shade700)),
          ]),
        ),

        const SizedBox(width: 8),

        // Sizes count with enhanced styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primary.withOpacity(0.15), primary.withOpacity(0.08)]),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: primary.withOpacity(0.3), width: 1),
          ),
          child: Row(children: [
            Icon(Icons.straighten, size: 10, color: primary),
            const SizedBox(width: 2),
            Text(
              '${product.availableSizes.length}',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: primary),
            ),
          ]),
        ),
      ]),
    ],
  ),
)
```

### Skills and Stats Section
```dart
Row(
  children: [
    // Skills Display
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skills', style: TextStyle(color: onSurface.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: product.skills.take(3).map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  skill.name,
                  style: TextStyle(fontSize: 10, color: primary),
                ),
              );
            }).toList(),
          ),
          if (product.skills.length > 3)
            Text('+${product.skills.length - 3} more', style: TextStyle(fontSize: 10, color: onSurface.withOpacity(0.6))),
        ],
      ),
    ),

    // Statistics Display
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.check_circle, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                '${product.totalOrdersCompleted}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('Completed', style: TextStyle(fontSize: 10, color: onSurface.withOpacity(0.6))),
        ],
      ),
    ),
  ],
)
```

### Hover Overlay with Quick Actions
```dart
if (_isHovered)
  Positioned.fill(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.02)],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => addToFavorites(product),
                icon: const Icon(Icons.favorite_border),
                iconSize: 18,
                color: Colors.red.shade400,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  padding: const EdgeInsets.all(6),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => shareProduct(product),
                icon: const Icon(Icons.share),
                iconSize: 18,
                color: primary,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  padding: const EdgeInsets.all(6),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
```

## Filter Bottom Sheet

### Filter Sheet Structure
```dart
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 10000);
  ProductCategory? _selectedCategory;
  String _selectedSort = 'name';
  bool _isApplyingFilters = false;

  void _applyFilters(BuildContext context) async {
    setState(() => _isApplyingFilters = true);

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      productProvider.filterByCategory(_selectedCategory);
      productProvider.filterByPriceRange((_priceRange.start != 0 || _priceRange.end != 10000) ? _priceRange : null);
      productProvider.sortProducts(_selectedSort);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filters applied successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error applying filters: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isApplyingFilters = false);
    }
  }
}
```

### Filter Controls
```dart
Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text('Filter Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    const SizedBox(height: 20),

    // Price Range Filter
    const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w600)),
    RangeSlider(
      values: _priceRange,
      min: 0,
      max: 10000,
      divisions: 20,
      labels: RangeLabels('₹${_priceRange.start.toInt()}', '₹${_priceRange.end.toInt()}'),
      onChanged: (values) => setState(() => _priceRange = values),
    ),

    const SizedBox(height: 20),

    // Category Filter
    const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8,
      children: ProductCategory.values.map((category) {
        return FilterChip(
          label: Text(category.toString().split('.').last),
          selected: _selectedCategory == category,
          onSelected: (selected) => setState(() => _selectedCategory = selected ? category : null),
        );
      }).toList(),
    ),

    const SizedBox(height: 20),

    // Sort Options
    const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    Column(children: [
      RadioListTile<String>(
        title: const Text('Name (A-Z)'),
        value: 'name',
        groupValue: _selectedSort,
        onChanged: (value) => setState(() => _selectedSort = value!),
        dense: true,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
      RadioListTile<String>(
        title: const Text('Price (Low to High)'),
        value: 'price_asc',
        groupValue: _selectedSort,
        onChanged: (value) => setState(() => _selectedSort = value!),
        dense: true,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
      RadioListTile<String>(
        title: const Text('Price (High to Low)'),
        value: 'price_desc',
        groupValue: _selectedSort,
        onChanged: (value) => setState(() => _selectedSort = value!),
        dense: true,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    ]),

    const SizedBox(height: 20),

    // Apply Filters Button
    SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isApplyingFilters ? null : () => _applyFilters(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isApplyingFilters
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    ),
  ],
)
```

## Product Details Screen

### Full-Screen Product View
```dart
class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isShopOwner = authProvider.isShopOwnerOrAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: surface,
        elevation: 0,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(color: onSurface, fontSize: 18, fontWeight: FontWeight.w600),
        actions: [
          if (isShopOwner)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => _editProductFromDetails(context, product)),
          IconButton(icon: const Icon(Icons.share), onPressed: () => shareProduct(product)),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () => addToFavorites(product)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Product Images Gallery
          _buildProductImageGallery(product),

          // Product Information
          _buildProductInformation(product, themeProvider, isShopOwner),
        ]),
      ),
    );
  }
}
```

### Image Gallery with Navigation
```dart
SizedBox(
  height: 320,
  child: product.imageUrls.isNotEmpty
      ? Stack(children: [
          PageView.builder(
            itemCount: product.imageUrls.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'product_${product.id}_$index',
                child: Image.network(
                  product.imageUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: background,
                      child: Center(child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      )),
                    );
                  },
                  errorBuilder: (context, error, stack) => Container(
                    color: background,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: onSurface.withOpacity(0.5)),
                        const SizedBox(height: 8),
                        Text('Failed to load image', style: TextStyle(color: onSurface.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Image indicator dots
          if (product.imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  product.imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),

          // Image count badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${product.imageUrls.length} image${product.imageUrls.length > 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ])
      : Container(
          color: background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2, size: 80, color: onSurface.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text('No product images available', style: TextStyle(color: onSurface.withOpacity(0.6))),
            ],
          ),
        ),
)
```

### Product Information Display
```dart
Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Product Name and Price
      Row(children: [
        Expanded(
          child: Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Text('₹${product.basePrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary)),
      ]),

      const SizedBox(height: 16),

      // Product Description
      Text(
        product.description,
        style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7), height: 1.5),
      ),

      const SizedBox(height: 20),

      // Specifications
      Text('Specifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onBackground)),
      const SizedBox(height: 12),
      ...product.specifications.entries.map((spec) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Text('${spec.key}: ', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(spec.value),
            ]),
          )),

      // Available Sizes
      const SizedBox(height: 20),
      Text('Available Sizes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onBackground)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: product.availableSizes.map((size) => Chip(label: Text(size))).toList(),
      ),

      // Available Fabrics
      const SizedBox(height: 20),
      Text('Available Fabrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onBackground)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: product.availableFabrics.map((fabric) => Chip(
          label: Text(fabric),
          backgroundColor: primary.withOpacity(0.1),
          labelStyle: TextStyle(color: primary),
        )).toList(),
      ),

      const SizedBox(height: 30),

      // Action Buttons
      Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => placeOrder(product),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Place Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => startChat(product),
          icon: const Icon(Icons.chat),
          label: const Text('Chat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
      ]),
    ],
  ),
)
```

## Responsive Grid System

### Dynamic Grid Configuration
```dart
LayoutBuilder(
  builder: (context, constraints) {
    final availableWidth = constraints.maxWidth;

    // Responsive grid configuration
    int crossAxisCount;
    double childAspectRatio;
    double crossAxisSpacing;
    double mainAxisSpacing;

    if (availableWidth >= 1200) {
      crossAxisCount = 5;
      childAspectRatio = 0.7;
      crossAxisSpacing = 16;
      mainAxisSpacing = 16;
    } else if (availableWidth >= 1000) {
      crossAxisCount = 4;
      childAspectRatio = 0.75;
      crossAxisSpacing = 14;
      mainAxisSpacing = 14;
    } else if (availableWidth >= 800) {
      crossAxisCount = 3;
      childAspectRatio = 0.8;
      crossAxisSpacing = 12;
      mainAxisSpacing = 12;
    } else if (availableWidth >= 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.75;
      crossAxisSpacing = 12;
      mainAxisSpacing = 12;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.85;
      crossAxisSpacing = 10;
      mainAxisSpacing = 10;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: productProvider.products.length,
      itemBuilder: (context, index) {
        final product = productProvider.products[index];
        return _CompactProductCard(product: product);
      },
    );
  },
)
```

## Empty State Handling

### No Products State
```dart
Center(
  child: Container(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primary.withOpacity(0.1), primary.withOpacity(0.05)]),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: primary.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'No Products Found',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: onSurface),
        ),
        const SizedBox(height: 12),
        Text(
          'Try adjusting your search or filter criteria',
          style: TextStyle(fontSize: 16, color: onSurface.withOpacity(0.7)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            _searchController.clear();
            _tabController.animateTo(0);
            productProvider.filterByCategory(null);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Show All Products'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ),
  ),
)
```

## Integration Points

### Provider Dependencies
```dart
// Required providers for the product catalog screen
- ProductProvider: Core product data management and CRUD operations
- AuthProvider: User authentication and role verification
- ThemeProvider: Theme management and dynamic styling

// Usage in widget tree
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ProductProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  child: ProductCatalogScreen(),
)
```

### Service Dependencies
```dart
// Firebase service integration through providers
- FirebaseService: Data persistence and real-time synchronization
- Product Service: Business logic for product operations
- Image Service: Product image management and optimization
- Search Service: Advanced product search and filtering
```

### Navigation Dependencies
```dart
// Screen navigation integration
- ProductDetailsScreen: Individual product information display
- ProductEditScreen: Product creation and editing interface
- FilterBottomSheet: Advanced filtering interface
- Role-based guards: Access control for administrative features
```

## Security Considerations

### Access Control
```dart
// Role-based feature visibility
final isShopOwner = authProvider.isShopOwnerOrAdmin;

if (isShopOwner) {
  // Show administrative features
  IconButton(onPressed: () => addProduct(), icon: Icon(Icons.add));
  IconButton(onPressed: () => editProduct(product), icon: Icon(Icons.edit));
}

// Data access filtering
productProvider.filterProductsByUserRole(authProvider.currentUser);
```

### Data Privacy
```dart
// Product visibility based on user permissions
if (product.isPrivate && !isShopOwner) {
  return SizedBox.shrink(); // Hide private products
}

// Sensitive information masking
if (!isShopOwner && product.containsSensitiveInfo) {
  product = product.maskSensitiveInformation();
}
```

## Performance Optimization

### Efficient Rendering
```dart
// Selective rebuilds with Consumer
Consumer3<ProductProvider, AuthProvider, ThemeProvider>(
  builder: (context, productProvider, authProvider, themeProvider, child) {
    // Only rebuilds when relevant data changes
    return LayoutBuilder(builder: (context, constraints) {
      // Responsive layout calculations
      return _buildResponsiveLayout(productProvider, constraints);
    });
  },
)

// Grid optimization
GridView.builder(
  // Efficient item building
  itemBuilder: (context, index) {
    final product = productProvider.products[index];
    return _CompactProductCard(product: product);
  },
)
```

### Memory Management
```dart
// Controller disposal
@override
void dispose() {
  _tabController.dispose();
  _searchController.dispose();
  super.dispose();
}

// Image caching and optimization
Image.network(
  product.imageUrls.first,
  fit: BoxFit.cover,
  cacheWidth: 400, // Optimize memory usage
  cacheHeight: 300,
  loadingBuilder: (context, child, loadingProgress) {
    // Progressive loading
  },
)
```

### Search Optimization
```dart
// Debounced search to reduce API calls
void _onSearchChanged(String value) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 500), () {
    productProvider.searchProducts(value);
  });
}
```

## Best Practices

### User Experience
- **Progressive Loading**: Show skeleton screens during data loading
- **Clear Visual Hierarchy**: Distinct sections for search, filters, and results
- **Consistent Interactions**: Standard tap behaviors for navigation
- **Feedback Mechanisms**: Loading states, error messages, and success indicators
- **Accessibility**: Screen reader support and keyboard navigation

### Performance
- **Lazy Loading**: Implement pagination for large product catalogs
- **Image Optimization**: Cached and resized product images
- **Efficient Filtering**: Client-side filtering with server-side fallbacks
- **Memory Optimization**: Proper disposal of resources and controllers

### Maintainability
- **Modular Components**: Separate widgets for different UI sections
- **Provider Pattern**: Centralized state management
- **Error Boundaries**: Graceful error handling at component level
- **Code Organization**: Clear separation of business logic and UI

## Recent Enhancements

### ✅ **Enhanced Search Box Design**
- **Larger Size**: Increased width from 45% to 65% on desktop for better usability
- **Integrated Search Button**: Search icon moved to right end as a button that merges seamlessly with input box
- **Modern Layout**: Removed prefix icon, created integrated button design with proper styling
- **Improved Visual Hierarchy**: Better spacing and typography with larger font size (16px)
- **Enhanced Interactions**: Smooth button animations and hover effects
- **Responsive Design**: Maintains functionality across all screen sizes

### ✅ **Search Experience Improvements**
- **Button Integration**: Search icon functions as a clickable button without outline
- **Visual Continuity**: Button merges seamlessly with the search input field
- **Better Accessibility**: Larger touch targets and clear visual feedback
- **Modern UI Pattern**: Follows current design trends for search interfaces

This comprehensive product catalog screen provides a professional, feature-rich product browsing experience with advanced filtering, responsive design, role-based access control, and seamless integration with the tailoring shop management system, demonstrating sophisticated Flutter development practices and user experience design principles. The enhanced search box provides a modern, intuitive search experience that improves user interaction and visual appeal.