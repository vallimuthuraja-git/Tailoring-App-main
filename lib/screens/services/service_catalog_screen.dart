// Service Catalog Screen - Main entry point for all tailoring services
// Displays services integrated with cart functionality and full order types

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service.dart';
import '../../providers/service_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/theme_constants.dart';
import '../cart/cart_screen.dart';
import 'service_detail_screen.dart';
import 'service_create_screen.dart';

class ServiceCatalogScreen extends StatefulWidget {
  const ServiceCatalogScreen({super.key});

  @override
  State<ServiceCatalogScreen> createState() => _ServiceCatalogScreenState();
}

class _ServiceCatalogScreenState extends State<ServiceCatalogScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  ServiceCategory? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);

    // Delay the service loading to avoid calling notifyListeners during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadServices();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);

    // Load services - this is now safe to call as PostFrameCallback ensures build phase is complete
    await serviceProvider.loadServices();

    // If no services exist, load demo data
    if (serviceProvider.services.isEmpty) {
      await serviceProvider.initializeSampleServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<ServiceProvider, AuthProvider, ThemeProvider, CartProvider>(
      builder: (context, serviceProvider, authProvider, themeProvider, cartProvider, child) {
        final isShopOwner = authProvider.isShopOwnerOrAdmin;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: kToolbarHeight + 5,
            title: Center(
              child: SizedBox(
                height: 48,
                width: MediaQuery.of(context).size.width * 0.85,
                child: SearchAnchor(
                  builder: (BuildContext context, SearchController controller) {
                    return SearchBar(
                      controller: controller,
                      elevation: const WidgetStatePropertyAll<double>(0),
                      padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      onTap: () {
                        controller.openView();
                      },
                      onChanged: (_) {
                        controller.openView();
                      },
                      hintText: 'Search services...',
                      hintStyle: WidgetStatePropertyAll<TextStyle>(
                        TextStyle(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                              : AppColors.onSurface.withValues(alpha: 0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      textStyle: WidgetStatePropertyAll<TextStyle>(
                        TextStyle(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface
                              : AppColors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      trailing: [
                        Icon(
                          Icons.search,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.8)
                              : AppColors.onSurface.withValues(alpha: 0.8),
                          size: 20,
                        ),
                      ],
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        themeProvider.isDarkMode
                            ? DarkAppColors.surface.withValues(alpha: 0.9)
                            : AppColors.surface.withValues(alpha: 0.9),
                      ),
                      surfaceTintColor: WidgetStatePropertyAll<Color>(
                        themeProvider.isDarkMode
                            ? DarkAppColors.surface
                            : AppColors.surface,
                      ),
                      shape: WidgetStatePropertyAll<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          side: BorderSide(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.primary.withValues(alpha: 0.3)
                                : AppColors.primary.withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                        ),
                      ),
                    );
                  },
                  suggestionsBuilder: (BuildContext context, SearchController controller) {
                    if (controller.text.isEmpty) {
                      return <Widget>[];
                    }

                    serviceProvider.searchServices(controller.text);

                    return List<ListTile>.generate(5, (int index) {
                      final String item = 'service $index';
                      return ListTile(
                        title: Text(
                          item,
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface
                                : AppColors.onSurface,
                          ),
                        ),
                        onTap: () {
                          controller.closeView(item);
                        },
                      );
                    });
                  },
                ),
              ),
            ),
            backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
            elevation: 0,
            iconTheme: IconThemeData(
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
            actions: [
              // Cart Icon with Badge
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                        onPressed: () => _navigateToCart(context),
                        tooltip: 'View Cart',
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              cartProvider.itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
                onPressed: () => _showFilterBottomSheet(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Service Category Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.surface.withValues(alpha: 0.8)
                      : AppColors.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                        : AppColors.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                        (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                      : AppColors.onSurface.withValues(alpha: 0.7),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  tabs: [
                    _buildCategoryTab('All', Icons.apps),
                    _buildCategoryTab('Saree', Icons.woman),
                    _buildCategoryTab('Garment', Icons.checkroom),
                    _buildCategoryTab('Alterations', Icons.content_cut),
                    _buildCategoryTab('Custom', Icons.design_services),
                    _buildCategoryTab('Consultation', Icons.chat),
                    _buildCategoryTab('Measurements', Icons.straighten),
                    _buildCategoryTab('Special Occasion', Icons.celebration),
                    _buildCategoryTab('Corporate', Icons.business),
                    _buildCategoryTab('Bridal', Icons.diamond),
                  ],
                  onTap: (index) {
                    ServiceCategory? category;
                    switch (index) {
                      case 1:
                        category = ServiceCategory.sareeServices;
                        break;
                      case 2:
                        category = ServiceCategory.garmentServices;
                        break;
                      case 3:
                        category = ServiceCategory.alterationServices;
                        break;
                      case 4:
                        category = ServiceCategory.customDesign;
                        break;
                      case 5:
                        category = ServiceCategory.consultation;
                        break;
                      case 6:
                        category = ServiceCategory.measurements;
                        break;
                      case 7:
                        category = ServiceCategory.specialOccasion;
                        break;
                      case 8:
                        category = ServiceCategory.corporateWear;
                        break;
                      case 9:
                        category = ServiceCategory.bridalServices;
                        break;
                      default:
                        category = null;
                    }
                    serviceProvider.filterByCategory(category);
                  },
                ),
              ),

              // Main Content
              Expanded(
                child: serviceProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : serviceProvider.services.isEmpty
                        ? _buildEmptyState()
                        : _buildServiceGrid(serviceProvider),
              ),
            ],
          ),
          floatingActionButton: isShopOwner
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddServiceDialog(context),
                  icon: const Icon(Icons.add_business),
                  label: const Text('Add Service'),
                  backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                  foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                )
              : null,
        );
      },
    );
  }

  Widget _buildCategoryTab(String text, IconData icon) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha: 0.1),
                    (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business_center_outlined,
                size: 64,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary.withValues(alpha: 0.7)
                    : AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Services Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your search or filter criteria',
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _tabController.animateTo(0);
                Provider.of<ServiceProvider>(context, listen: false).filterByCategory(null);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Show All Services'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGrid(ServiceProvider serviceProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        final availableWidth = constraints.maxWidth;

        if (availableWidth >= 600) {
          crossAxisCount = 3;
          childAspectRatio = 0.8;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 0.85;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: serviceProvider.services.length,
          itemBuilder: (context, index) {
            final service = serviceProvider.services[index];
            return _ServiceCard(service: service);
          },
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ServiceFilterBottomSheet(),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ServiceCreateScreen(),
      ),
    );
  }

  void _navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final Service service;

  const _ServiceCard({required this.service});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _isAddingToCart = false;

  void _addToCart(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    setState(() {
      _isAddingToCart = true;
    });

    // For now, we'll add a placeholder - need to extend CartProvider for services
    // TODO: Implement service ordering in cart

    setState(() {
      _isAddingToCart = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Service ordering coming soon!'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isShopOwner = authProvider.isShopOwnerOrAdmin;

    return GestureDetector(
      onTap: () => _showServiceDetails(context, widget.service),
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                : AppColors.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.05)
                  : AppColors.onSurface.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image/Icon
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(
                  colors: [
                    _getServiceColor(widget.service.category).withValues(alpha: 0.1),
                    _getServiceColor(widget.service.category).withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  _getServiceIcon(widget.service.category),
                  size: 48,
                  color: _getServiceColor(widget.service.category),
                ),
              ),
            ),

            // Service Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Name
                  Text(
                    widget.service.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface
                          : AppColors.onSurface,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getServiceColor(widget.service.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.service.categoryName,
                      style: TextStyle(
                        fontSize: 10,
                        color: _getServiceColor(widget.service.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    '₹${widget.service.effectivePrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Duration
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                            : AppColors.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.service.durationText,
                        style: TextStyle(
                          fontSize: 11,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                              : AppColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Book Service Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.service.isActive && !_isAddingToCart
                          ? () => _addToCart(context)
                          : null,
                      icon: _isAddingToCart
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.book_online, size: 16),
                      label: Text(
                        _isAddingToCart
                            ? 'Booking...'
                            : 'Book Service',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary,
                        foregroundColor: themeProvider.isDarkMode
                            ? DarkAppColors.onPrimary
                            : AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  // Edit button for shop owners
                  if (isShopOwner) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _editService(context, widget.service),
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getServiceColor(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.sareeServices:
        return Colors.pink;
      case ServiceCategory.garmentServices:
        return Colors.blue;
      case ServiceCategory.alterationServices:
        return Colors.green;
      case ServiceCategory.customDesign:
        return Colors.purple;
      case ServiceCategory.consultation:
        return Colors.orange;
      case ServiceCategory.measurements:
        return Colors.teal;
      case ServiceCategory.specialOccasion:
        return Colors.red;
      case ServiceCategory.corporateWear:
        return Colors.indigo;
      case ServiceCategory.uniformServices:
        return Colors.brown;
      case ServiceCategory.bridalServices:
        return Colors.deepPurple;
    }
  }

  IconData _getServiceIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.sareeServices:
        return Icons.woman;
      case ServiceCategory.garmentServices:
        return Icons.checkroom;
      case ServiceCategory.alterationServices:
        return Icons.content_cut;
      case ServiceCategory.customDesign:
        return Icons.design_services;
      case ServiceCategory.consultation:
        return Icons.chat;
      case ServiceCategory.measurements:
        return Icons.straighten;
      case ServiceCategory.specialOccasion:
        return Icons.celebration;
      case ServiceCategory.corporateWear:
        return Icons.business;
      case ServiceCategory.uniformServices:
        return Icons.school;
      case ServiceCategory.bridalServices:
        return Icons.diamond;
    }
  }

  void _showServiceDetails(BuildContext context, Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
      ),
    );
  }

  void _editService(BuildContext context, Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceEditScreen(service: service),
      ),
    );
  }
}

class ServiceFilterBottomSheet extends StatefulWidget {
  const ServiceFilterBottomSheet({super.key});

  @override
  State<ServiceFilterBottomSheet> createState() => _ServiceFilterBottomSheetState();
}

class _ServiceFilterBottomSheetState extends State<ServiceFilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 500);
  ServiceCategory? _selectedCategory;
  ServiceDuration? _selectedDuration;
  ServiceComplexity? _selectedComplexity;
  bool? _activeStatusFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Price Range
            const Text(
              'Price Range',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 500,
              divisions: 50,
              labels: RangeLabels(
                '₹${_priceRange.start.toInt()}',
                '₹${_priceRange.end.toInt()}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),

            const SizedBox(height: 20),

            // Category Filter
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ServiceCategory.values.map((category) {
                return FilterChip(
                  label: Text(category.name),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Duration Filter
            const Text(
              'Duration',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ServiceDuration.values.map((duration) {
                return FilterChip(
                  label: Text(duration.name),
                  selected: _selectedDuration == duration,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDuration = selected ? duration : null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Complexity Filter
            const Text(
              'Complexity',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ServiceComplexity.values.map((complexity) {
                return FilterChip(
                  label: Text(complexity.name),
                  selected: _selectedComplexity == complexity,
                  onSelected: (selected) {
                    setState(() {
                      _selectedComplexity = selected ? complexity : null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Apply Filters Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _applyFilters(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);

    // Apply all filters
    if (_selectedCategory != null) {
      serviceProvider.filterByCategory(_selectedCategory);
    }
    if (_activeStatusFilter != null) {
      serviceProvider.filterByActiveStatus(_activeStatusFilter);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Placeholder for service edit screen
class ServiceEditScreen extends StatelessWidget {
  final Service service;

  const ServiceEditScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${service.name}'),
      ),
      body: const Center(
        child: Text('Service Edit Screen - Coming Soon!'),
      ),
    );
  }
}
