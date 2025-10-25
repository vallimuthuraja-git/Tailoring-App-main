import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/service.dart';
import '../../providers/service_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/theme_constants.dart';
import '../../utils/responsive_utils.dart';
import '../../screens/cart/cart_screen.dart';
import 'customer_service_detail_screen.dart';
import 'service_booking_wizard.dart';

class ServiceCatalogScreen extends StatefulWidget {
  const ServiceCatalogScreen({super.key});

  @override
  State<ServiceCatalogScreen> createState() => _ServiceCatalogScreenState();
}

class _ServiceCatalogScreenState extends State<ServiceCatalogScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  ServiceCategory? _selectedCategoryFilter;
  bool _isGridView = true; // Default to grid view

  bool _isLoaded = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLoaded) {
        _loadServices();
        _loadViewModePreference();
        _isLoaded = true;
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    debugPrint('ðŸ”„ ServiceCatalogScreen loading services');
    final serviceProvider =
        Provider.of<ServiceProvider>(context, listen: false);
    await serviceProvider.loadServices();
    debugPrint(
        'âœ… ServiceCatalogScreen services loaded successfully: ${serviceProvider.services.length}');
  }

  Future<void> _loadViewModePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isGridView = prefs.getBool('service_view_mode_grid') ?? true;
      });
    } catch (e) {
      debugPrint('Error loading view mode preference: $e');
    }
  }

  Future<void> _saveViewModePreference(bool isGrid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('service_view_mode_grid', isGrid);
    } catch (e) {
      debugPrint('Error saving view mode preference: $e');
    }
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
    _saveViewModePreference(_isGridView);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book a Service',
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
        ),
        backgroundColor: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
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
          // Cart Icon
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shopping_cart,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface
                          : AppColors.onSurface,
                    ),
                    tooltip: 'Cart',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.teal,
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

          // Logout Icon
          IconButton(
            icon: Icon(
              Icons.logout,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),

          // View Toggle Button
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            onPressed: _toggleViewMode,
            tooltip:
                _isGridView ? 'Switch to List View' : 'Switch to Grid View',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildSearchBar(themeProvider),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(themeProvider),
          Expanded(
            child: Consumer<ServiceProvider>(
              builder: (context, serviceProvider, child) {
                if (serviceProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (serviceProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading services',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(serviceProvider.errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadServices,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final services = serviceProvider.services
                    .where((service) => service.isActive)
                    .toList();
                debugPrint(
                    'ðŸ“Š ServiceCatalogScreen entered, services: ${services.length}');

                if (services.isEmpty) {
                  debugPrint(
                      'âš ï¸ No services available after filtering - total services: ${serviceProvider.services.length}');
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business_center,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No services available',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Please check back later',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isGridView
                        ? _buildGridView(services, themeProvider)
                        : _buildListView(services, themeProvider),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface
              : AppColors.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Search services...',
          prefixIcon: Icon(Icons.search,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                          : AppColors.onSurface.withValues(alpha: 0.7)),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<ServiceProvider>(context, listen: false)
                        .searchServices('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: themeProvider.isDarkMode
              ? DarkAppColors.surface
              : AppColors.surface,
        ),
        onChanged: (value) =>
            Provider.of<ServiceProvider>(context, listen: false)
                .searchServices(value),
      ),
    );
  }

  Widget _buildFilters(ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 8,
      ),
      color:
          themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All Categories', null, themeProvider),
            const SizedBox(width: 8),
            ...ServiceCategory.values.map((category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child:
                      _buildFilterChip(category.name, category, themeProvider),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, ServiceCategory? category, ThemeProvider themeProvider) {
    final isSelected = _selectedCategoryFilter == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedCategoryFilter = category);
        Provider.of<ServiceProvider>(context, listen: false)
            .filterByCategory(category);
      },
      backgroundColor:
          themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
      selectedColor:
          (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary)
              .withValues(alpha: 0.2),
      checkmarkColor:
          themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
    );
  }

  Widget _buildGridView(List<Service> services, ThemeProvider themeProvider) {
    return GridView.builder(
      key: const ValueKey('grid'),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width < 600
            ? 8.0
            : MediaQuery.of(context).size.width * 0.05,
        vertical: 16,
      ),
      gridDelegate: ResponsiveUtils.getOverflowSafeServiceGridDelegate(context),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(service, themeProvider);
      },
    );
  }

  Widget _buildListView(List<Service> services, ThemeProvider themeProvider) {
    return ListView.builder(
      key: const ValueKey('list'),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 16,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceListItem(service, themeProvider);
      },
    );
  }

  Widget _buildServiceCard(Service service, ThemeProvider themeProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) => Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showServiceOptions(service),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Icon and Title
                    Center(
                      child: Hero(
                        tag: 'service-icon-${service.id}',
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getServiceColor(service.category)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getServiceIcon(service.category),
                            color: _getServiceColor(service.category),
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service.shortDescription,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          // Price and Duration
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '\$${service.effectivePrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode
                                        ? DarkAppColors.primary
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 2),
                              Text(
                                service.durationText,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Wishlist button
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  if (authProvider.user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please log in to manage favorites')),
                    );
                    return;
                  }

                  final success =
                      await wishlistProvider.toggleWishlist(service.id);
                  if (success && mounted) {
                    final isInWishlist =
                        wishlistProvider.isServiceInWishlist(service.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isInWishlist
                            ? '${service.name} added to favorites'
                            : '${service.name} removed from favorites'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    wishlistProvider.isServiceInWishlist(service.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 20,
                    color: wishlistProvider.isServiceInWishlist(service.id)
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceListItem(Service service, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) => InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showServiceOptions(service),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Service Icon
                Hero(
                  tag: 'service-icon-${service.id}',
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getServiceColor(service.category)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getServiceIcon(service.category),
                      color: _getServiceColor(service.category),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Service Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.shortDescription,
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                              : AppColors.onSurface.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            service.durationText,
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.onSurface
                                      .withValues(alpha: 0.6)
                                  : AppColors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: service.category ==
                                      ServiceCategory.consultation
                                  ? Colors.blue.withValues(alpha: 0.1)
                                  : service.category ==
                                          ServiceCategory.customDesign
                                      ? Colors.purple.withValues(alpha: 0.1)
                                      : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              service.category.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: service.category ==
                                        ServiceCategory.consultation
                                    ? Colors.blue
                                    : service.category ==
                                            ServiceCategory.customDesign
                                        ? Colors.purple
                                        : Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Price and Wishlist
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price
                    Text(
                      '\$${service.effectivePrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Wishlist button
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        if (authProvider.user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please log in to manage favorites')),
                          );
                          return;
                        }

                        final success =
                            await wishlistProvider.toggleWishlist(service.id);
                        if (success && mounted) {
                          final isInWishlist =
                              wishlistProvider.isServiceInWishlist(service.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isInWishlist
                                  ? '${service.name} added to favorites'
                                  : '${service.name} removed from favorites'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (themeProvider.isDarkMode
                                  ? DarkAppColors.surface
                                  : AppColors.surface)
                              .withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          wishlistProvider.isServiceInWishlist(service.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color:
                              wishlistProvider.isServiceInWishlist(service.id)
                                  ? Colors.red
                                  : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showServiceOptions(Service service) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              service.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _bookService(service),
              icon: const Icon(Icons.book_online),
              label: const Text('Book This Service'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _viewServiceDetails(service),
              icon: const Icon(Icons.info),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bookService(Service service) async {
    Navigator.pop(context); // Close bottom sheet
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book services')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceBookingWizard(service: service),
      ),
    );
  }

  void _viewServiceDetails(Service service) {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerServiceDetailScreen(service: service),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
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
}
