// Wishlist Screen to view user's favorite services
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../providers/wishlist_provider.dart';
import '../providers/service_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme_constants.dart';
import 'services/service_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with TickerProviderStateMixin {
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
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        if (authProvider.user == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Favorites'),
              backgroundColor: themeProvider.isDarkMode
                  ? DarkAppColors.surface
                  : AppColors.surface,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Please log in to view your favorites',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Favorites'),
            backgroundColor: themeProvider.isDarkMode
                ? DarkAppColors.surface
                : AppColors.surface,
            actions: [
              Consumer<WishlistProvider>(
                builder: (context, wishlistProvider, child) {
                  if (wishlistProvider.wishlistCount > 0) {
                    return TextButton(
                      onPressed: () =>
                          _showClearWishlistDialog(context, wishlistProvider),
                      style: TextButton.styleFrom(
                        foregroundColor: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary,
                      ),
                      child: const Text('Clear All'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: Consumer2<WishlistProvider, ServiceProvider>(
            builder: (context, wishlistProvider, serviceProvider, child) {
              if (wishlistProvider.wishlistServiceIds.isEmpty) {
                return const _EmptyWishlistView();
              }

              final wishlistServices = serviceProvider.services
                  .where((service) =>
                      wishlistProvider.isServiceInWishlist(service.id))
                  .toList();

              if (wishlistServices.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: 16,
                  ),
                  itemCount: wishlistServices.length,
                  itemBuilder: (context, index) {
                    final service = wishlistServices[index];
                    return _buildWishlistItem(
                        service, wishlistProvider, themeProvider, context);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWishlistItem(
    Service service,
    WishlistProvider wishlistProvider,
    ThemeProvider themeProvider,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Hero(
          tag: 'service-icon-${service.id}',
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getServiceColor(service.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getServiceIcon(service.category),
              color: _getServiceColor(service.category),
              size: 24,
            ),
          ),
        ),
        title: Text(
          service.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.shortDescription,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${service.effectivePrice.toStringAsFixed(0)} • ${service.durationText}',
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () async {
            final success =
                await wishlistProvider.removeFromWishlist(service.id);
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${service.name} removed from favorites'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        onTap: () {
          // Navigate to service details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(service: service),
            ),
          );
        },
      ),
    );
  }

  void _showClearWishlistDialog(
      BuildContext context, WishlistProvider wishlistProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text(
            'Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await wishlistProvider.clearWishlist();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wishlist cleared')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
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
}

class _EmptyWishlistView extends StatelessWidget {
  const _EmptyWishlistView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Add services to your favorites for quick access',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Text(
            '💡 Tap the heart icon on services to add them here',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Temporary placeholder for service details - replace with actual service detail screen
class _ServiceDetailPlaceholder extends StatelessWidget {
  final Service service;

  const _ServiceDetailPlaceholder({required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              service.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              service.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              '\$${service.effectivePrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
