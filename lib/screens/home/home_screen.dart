import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/global_navigation_provider.dart';
import '../../utils/theme_constants.dart';
import '../../widgets/user_avatar.dart';
import '../orders/order_management_dashboard.dart';
import '../employee/employee_management_home.dart';
import '../database/database_management_home.dart';
import '../customer/customer_management_screen.dart';
import '../cart/cart_screen.dart';
import '../workflow/tailoring_workflow_screen.dart';
import '../ai/ai_assistance_screen.dart';
import '../dashboard/analytics_dashboard_screen.dart';
import '../admin/user_management_screen.dart';
import '../admin/product_catalog_screen.dart';
import '../auth/login_screen.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/global_bottom_navigation_bar.dart';
import '../../widgets/role_based_guard.dart';
import '../../services/auth_service.dart' as auth;
import '../../services/firebase_service.dart';

// Using beautiful theme-level opacity extensions
// No more deprecated withValues(alpha:) calls - everything uses withValues() internally
// ignore_for_file: deprecated_member_use

/// Navigation Container Screen that manages global navigation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalNavigationProvider>(
      builder: (context, navProvider, child) {
        // Initialize navigation if needed
        if (!navProvider.isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navProvider.initializeNavigation(context);
          });
        }

        return Scaffold(
          body: navProvider.currentScreen,
          bottomNavigationBar: const GlobalBottomNavigationBar(),
        );
      },
    );
  }
}

class DashboardTab extends StatelessWidget {
  final VoidCallback? onNavigateToProducts;
  final VoidCallback? onNavigateToServices;
  final VoidCallback onNavigateToOrders;

  const DashboardTab({
    super.key,
    this.onNavigateToProducts,
    this.onNavigateToServices,
    required this.onNavigateToOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        final user = authProvider.userProfile;
        final isShopOwner = authProvider.isShopOwnerOrAdmin;
        final deviceType = ResponsiveUtils.getDeviceTypeFromContext(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            toolbarHeight: kToolbarHeight + 5,
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
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
                tooltip: 'Logout',
                onPressed: () => _showLogoutDialog(context, authProvider),
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
                tooltip: 'Notifications',
                onPressed: () {
                  // Navigate to notifications
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon!')),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.chat,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
                tooltip: 'AI Assistant',
                onPressed: () {
                  // Open AI chatbot
                  _showChatbot(context);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
              vertical: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: themeProvider.isGlassyMode
                        ? LinearGradient(
                            colors: [
                              themeProvider.isDarkMode
                                  ? DarkAppColors.primary.withValues(alpha: 0.8)
                                  : AppColors.primary.withValues(alpha: 0.8),
                              themeProvider.isDarkMode
                                  ? DarkAppColors.primaryVariant
                                      .withValues(alpha: 0.9)
                                  : AppColors.primaryVariant
                                      .withValues(alpha: 0.9),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              themeProvider.isDarkMode
                                  ? DarkAppColors.primary
                                  : AppColors.primary,
                              themeProvider.isDarkMode
                                  ? DarkAppColors.primaryVariant
                                  : AppColors.primaryVariant,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            displayName: user?.displayName ?? 'User',
                            imageUrl: user?.photoUrl,
                            radius: 30.0,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  user?.displayName ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isShopOwner
                            ? 'Manage your tailoring shop efficiently'
                            : 'Discover perfect tailoring services',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onBackground
                        : AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 16),

                _buildQuickActions(
                    authProvider,
                    isShopOwner,
                    onNavigateToProducts,
                    onNavigateToOrders,
                    context,
                    deviceType),

                const SizedBox(height: 32),

                // Recent Activity
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onBackground
                        : AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 16),

                // Recent activity items would go here
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.surface
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                          : AppColors.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                            : AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No recent activity yet. Start exploring our services!',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                : AppColors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChatbot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AIAssistanceScreen(),
      ),
    );
  }

  void _showAddProductOptions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? DarkAppColors.surface : AppColors.surface,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.inventory_2,
                color: isDark ? DarkAppColors.primary : AppColors.primary),
            title: const Text('Upload from CSV'),
            subtitle: const Text('Import products in bulk'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV upload coming soon!')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add_circle, color: const Color(0xFF4CAF50)),
            title: const Text('Add Single Product'),
            subtitle: const Text('Manual product entry'),
            onTap: () {
              Navigator.pop(context);
              _showAddSingleProductDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.library_add, color: const Color(0xFF2196F3)),
            title: const Text('Add Product Variant'),
            subtitle: const Text('Add variant to existing product'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product variants coming soon!')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.category, color: const Color(0xFF9C27B0)),
            title: const Text('Add Product Category'),
            subtitle: const Text('Create new category'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Category management coming soon!')),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAddSingleProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Mens Wear';

    final categories = ['Mens Wear', 'Womens Wear', 'Kids Wear', 'Custom'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price (₹)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) => selectedCategory = value!,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Implement product creation
              final productData = {
                'name': nameController.text,
                'basePrice': double.tryParse(priceController.text) ?? 0.0,
                'stockCount': int.tryParse(stockController.text) ?? 0,
                'category': _getCategoryIndex(selectedCategory),
                'description': descriptionController.text,
                'imageUrls': [],
                'availableSizes': ['S', 'M', 'L'],
                'availableFabrics': ['Cotton', 'Polyester'],
                'isActive': true,
                'brand': 'Royal Tailors',
              };

              try {
                final firebaseService = FirebaseService();
                await firebaseService.addDocument('products', productData);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${productData['name']} added successfully!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to add product: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  int _getCategoryIndex(String categoryName) {
    const categoryMap = {
      'Mens Wear': 0,
      'Womens Wear': 1,
      'Kids Wear': 2,
      'Custom': 3,
    };
    return categoryMap[categoryName] ?? 3;
  }

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
                // Force navigation to login by clearing all routes and pushing login
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false, // Remove all routes
                  );
                }
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

  Widget _buildQuickActions(
      AuthProvider authProvider,
      bool isShopOwner,
      VoidCallback? onNavigateToProducts,
      VoidCallback onNavigateToOrders,
      BuildContext context,
      DeviceType deviceType) {
    // TEMPORARY: Force show shop owner actions if user is owner@tailoring.com
    final userEmail = authProvider.email ?? '';
    final isForceShopOwner = userEmail == 'owner@tailoring.com' || isShopOwner;
    if (isForceShopOwner) {
      final actions = [
        // Core Business Management
        _QuickActionCard(
          icon: Icons.dashboard,
          title: 'Business Dashboard',
          color: const Color(0xFF2196F3), // Blue
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnalyticsDashboardScreen(),
              ),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.inventory_2,
          title: 'Product Catalog',
          color: const Color(0xFFFF9800), // Orange
          onTap: () {
            // Use RoleBased navigation widget for proper access control
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoleBasedRouteGuard(
                  requiredRole: auth.UserRole.shopOwner,
                  fallbackWidget: const Scaffold(
                    body: Center(
                      child: Text(
                          'All access disabled: Shop Owner privileges required'),
                    ),
                  ),
                  child: const ProductCatalogScreen(),
                ),
              ),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.admin_panel_settings,
          title: 'System Admin',
          color: const Color(0xFF607D8B), // Blue Grey
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoleBasedRouteGuard(
                  requiredRole: auth.UserRole.shopOwner,
                  fallbackWidget: const Scaffold(
                    body: Center(
                      child: Text(
                          'All access disabled: System Admin privileges required'),
                    ),
                  ),
                  child: const UserManagementScreen(),
                ),
              ),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.backup_table,
          title: 'Database Tools',
          color: const Color(0xFF795548), // Brown
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoleBasedRouteGuard(
                  requiredRole: auth.UserRole.shopOwner,
                  fallbackWidget: const Scaffold(
                    body: Center(
                      child: Text(
                          'All access disabled: Database Admin privileges required'),
                    ),
                  ),
                  child: const DatabaseManagementHome(),
                ),
              ),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.add_box,
          title: 'Add New Product',
          color: const Color(0xFF4CAF50), // Green
          onTap: () {
            // Check role before allowing access
            if (authProvider.isShopOwnerOrAdmin) {
              _showAddProductOptions(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Access denied: Shop Owner privileges required'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),

        // Service Management
        _QuickActionCard(
          icon: Icons.design_services,
          title: 'Service Management',
          color: const Color(0xFF9C27B0), // Purple
          onTap: () {
            // Navigate to service management
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Service management coming soon!')),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.rule,
          title: 'Pricing Rules',
          color: const Color(0xFFFF5722), // Red-Orange
          onTap: () {
            // Navigate to pricing rules
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pricing rules coming soon!')),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.category,
          title: 'Fabric Inventory',
          color: const Color(0xFF795548), // Brown
          onTap: () {
            // Navigate to fabric inventory
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fabric inventory coming soon!')),
            );
          },
        ),

        // Order & Workflow Management
        _QuickActionCard(
          icon: Icons.assignment,
          title: 'Active Orders',
          color: const Color(0xFF00BCD4), // Cyan
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderManagementDashboard(),
              ),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.timeline,
          title: 'Production Flow',
          color: const Color(0xFF3F51B5), // Indigo
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TailoringWorkflowScreen(),
              ),
            );
          },
        ),

        // Customer & Employee Management
        _QuickActionCard(
          icon: Icons.people_alt,
          title: 'Customer Database',
          color: const Color(0xFF009688), // Teal
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerManagementScreen(),
              ),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.groups,
          title: 'Employee Team',
          color: const Color(0xFF673AB7), // Deep Purple
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmployeeManagementHome(),
              ),
            );
          },
        ),

        // Financial & Analytics
        _QuickActionCard(
          icon: Icons.attach_money,
          title: 'Financial Reports',
          color: const Color(0xFF8BC34A), // Light Green
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Financial reports coming soon!')),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.bar_chart,
          title: 'Business Analytics',
          color: const Color(0xFFFFC107), // Amber
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnalyticsDashboardScreen(),
              ),
            );
          },
        ),

        // System Administration
        _QuickActionCard(
          icon: Icons.admin_panel_settings,
          title: 'System Admin',
          color: const Color(0xFF607D8B), // Blue Grey
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserManagementScreen(),
              ),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.settings_applications,
          title: 'Business Settings',
          color: const Color(0xFF9E9E9E), // Grey
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Business settings coming soon!')),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.backup_table,
          title: 'Database Tools',
          color: const Color(0xFF795548), // Brown
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DatabaseManagementHome(),
              ),
            );
          },
        ),

        // Marketing & Communication
        _QuickActionCard(
          icon: Icons.campaign,
          title: 'Marketing Hub',
          color: const Color(0xFFE91E63), // Pink
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Marketing hub coming soon!')),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.smart_toy,
          title: 'AI Assistant',
          color: const Color(0xFF2196F3), // Blue
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AIAssistanceScreen(),
              ),
            );
          },
        ),
      ];

      final actionsWidget = deviceType == DeviceType.mobile
          ? Column(
              children: actions
                  .map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: card,
                      ))
                  .toList(),
            )
          : GridView.count(
              crossAxisCount: ResponsiveUtils.responsiveGridColumns(deviceType),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: actions,
            );

      return Column(
        children: [
          actionsWidget,
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E3C72).withValues(alpha: 0.9),
                  const Color(0xFF2A5298).withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.business_center,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Employee Management Hub',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Complete employee tools & analytics',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const EmployeeManagementHome(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('Access Team Management'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E3C72),
                        side: const BorderSide(color: Colors.white, width: 1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      final actions = [
        Hero(
          tag: 'action-shopping-bag',
          child: _QuickActionCard(
            icon: Icons.shopping_bag,
            title: 'Browse Products',
            color: Colors.blue,
            onTap: onNavigateToProducts ?? () {},
          ),
        ),
        _QuickActionCard(
          icon: Icons.receipt_long,
          title: 'My Orders',
          color: Colors.green,
          onTap: onNavigateToOrders,
        ),
        _QuickActionCard(
          icon: Icons.chat,
          title: 'AI Assistant',
          color: Colors.purple,
          onTap: () {
            _showChatbot(context);
          },
        ),
        _QuickActionCard(
          icon: Icons.support_agent,
          title: 'Support',
          color: Colors.teal,
          onTap: () {
            // Navigate to support
          },
        ),
        _QuickActionCard(
          icon: Icons.feedback,
          title: 'Feedback',
          color: Colors.orange,
          onTap: () {
            // Navigate to feedback
          },
        ),
      ];

      final actionsWidget = deviceType == DeviceType.mobile
          ? Column(
              children: actions
                  .map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: card,
                      ))
                  .toList(),
            )
          : GridView.count(
              crossAxisCount: ResponsiveUtils.responsiveGridColumns(deviceType),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: actions,
            );

      return actionsWidget;
    }
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? DarkAppColors.surface
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                  : AppColors.onSurface.withValues(alpha: 0.2),
            ),
            boxShadow: themeProvider.isGlassyMode
                ? null
                : [
                    BoxShadow(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                          : AppColors.onSurface.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Icon(widget.icon, size: 32, color: widget.color),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
