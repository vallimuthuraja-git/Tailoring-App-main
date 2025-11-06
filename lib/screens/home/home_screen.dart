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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // TEMPORARY: Force show shop owner actions if user is owner@tailoring.com
    final userEmail = authProvider.email ?? '';
    final isForceShopOwner = userEmail == 'owner@tailoring.com' || isShopOwner;

    if (isForceShopOwner) {
      // Shop Owner Dashboard with 2-Column Quick Actions Grid
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section with Stats
          _buildWelcomeStatsSection(context, authProvider, themeProvider),

          const SizedBox(height: 32),

          // Quick Actions in 2-Column Grid
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(20.0, deviceType),
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),

          const SizedBox(height: 20),

          // Dynamic Responsive Grid Layout for Quick Actions
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final spacing = 16.0;

              // Calculate number of columns based on screen width
              int crossAxisCount;
              if (availableWidth < 600) {
                crossAxisCount = 2; // Mobile
              } else if (availableWidth < 900) {
                crossAxisCount = 3; // Tablet
              } else if (availableWidth < 1200) {
                crossAxisCount = 4; // Small desktop
              } else {
                crossAxisCount = 5; // Large desktop
              }

              final totalSpacing = spacing * (crossAxisCount - 1);
              final tileWidth =
                  (availableWidth - totalSpacing) / crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _ModernActionTile(
                    icon: Icons.inventory_2,
                    title: 'Product Catalog',
                    subtitle: 'Manage inventory & products',
                    color: const Color(0xFFFF9800),
                    width: tileWidth,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ProductCatalogScreen())),
                  ),
                  _ModernActionTile(
                    icon: Icons.add_box,
                    title: 'Add Products',
                    subtitle: 'Create new items',
                    color: const Color(0xFF4CAF50),
                    width: tileWidth,
                    onTap: () => _showAddProductOptions(context),
                  ),
                  _ModernActionTile(
                    icon: Icons.assignment,
                    title: 'Active Orders',
                    subtitle: 'Track current orders',
                    color: const Color(0xFF00BCD4),
                    width: tileWidth,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const OrderManagementDashboard())),
                  ),
                  _ModernActionTile(
                    icon: Icons.groups,
                    title: 'Employee Team',
                    subtitle: 'Manage staff & roles',
                    color: const Color(0xFF673AB7),
                    width: tileWidth,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const EmployeeManagementHome())),
                  ),
                  _ModernActionTile(
                    icon: Icons.people_alt,
                    title: 'Customer Database',
                    subtitle: 'Client management',
                    color: const Color(0xFF009688),
                    width: tileWidth,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CustomerManagementScreen())),
                  ),
                  _ModernActionTile(
                    icon: Icons.timeline,
                    title: 'Production Flow',
                    subtitle: 'Workflow management',
                    color: const Color(0xFF3F51B5),
                    width: tileWidth,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const TailoringWorkflowScreen())),
                  ),
                  _ModernActionTile(
                    icon: Icons.bar_chart,
                    title: 'Business Analytics',
                    subtitle: 'Reports & insights',
                    color: const Color(0xFFFFC107),
                    width: tileWidth,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AnalyticsDashboardScreen())),
                  ),
                  _ModernActionTile(
                    icon: Icons.admin_panel_settings,
                    title: 'System Admin',
                    subtitle: 'User management',
                    color: const Color(0xFF607D8B),
                    width: tileWidth,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const UserManagementScreen())),
                  ),
                  _ModernActionTile(
                    icon: Icons.backup_table,
                    title: 'Database Tools',
                    subtitle: 'Data management',
                    color: const Color(0xFF795548),
                    width: tileWidth,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const DatabaseManagementHome())),
                  ),
                  _ModernActionTile(
                    icon: Icons.smart_toy,
                    title: 'AI Assistant',
                    subtitle: 'Intelligent support',
                    color: const Color(0xFF2196F3),
                    width: tileWidth,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AIAssistanceScreen())),
                  ),
                ],
              );
            },
          ),
        ],
      );
    } else {
      // Customer Dashboard - Clean and Simple
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        DarkAppColors.primary.withValues(alpha: 0.1),
                        DarkAppColors.surface
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.05),
                        AppColors.surface
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode
                    ? DarkAppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      size: 32,
                      color: isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready to shop?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? DarkAppColors.onBackground
                                  : AppColors.onBackground,
                            ),
                          ),
                          Text(
                            'Discover our latest collection',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? DarkAppColors.onSurface
                                      .withValues(alpha: 0.7)
                                  : AppColors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Customer Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(20.0, deviceType),
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),

          const SizedBox(height: 20),

          // Customer Action Grid - 2 Columns
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final spacing = 16.0;
              final tileWidth = (availableWidth - spacing) / 2;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _ModernActionTile(
                    icon: Icons.shopping_bag,
                    title: 'Browse Products',
                    subtitle: 'Explore our collection',
                    color: Colors.blue,
                    width: tileWidth,
                    onTap: onNavigateToProducts ?? () {},
                  ),
                  _ModernActionTile(
                    icon: Icons.receipt_long,
                    title: 'My Orders',
                    subtitle: 'Track your purchases',
                    color: Colors.green,
                    width: tileWidth,
                    onTap: onNavigateToOrders,
                  ),
                  _ModernActionTile(
                    icon: Icons.smart_toy,
                    title: 'AI Assistant',
                    subtitle: 'Get personalized help',
                    color: Colors.purple,
                    width: tileWidth,
                    onTap: () => _showChatbot(context),
                  ),
                  _ModernActionTile(
                    icon: Icons.support_agent,
                    title: 'Support',
                    subtitle: 'Get help & support',
                    color: Colors.teal,
                    width: tileWidth,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Support coming soon!')),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      );
    }
  }

  Widget _buildWelcomeStatsSection(BuildContext context,
      AuthProvider authProvider, ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;
    final deviceType = ResponsiveUtils.getDeviceTypeFromContext(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  DarkAppColors.primary.withValues(alpha: 0.8),
                  DarkAppColors.primaryVariant.withValues(alpha: 0.9)
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.primaryVariant.withValues(alpha: 0.9)
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? DarkAppColors.primary : AppColors.primary)
                .withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveUtils.responsiveFontSize(
                            24.0, deviceType),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage your tailoring business efficiently',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: ResponsiveUtils.responsiveFontSize(
                            14.0, deviceType),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Stats Row
          Row(
            children: [
              _buildStatCard('Orders', '24', Icons.assignment, Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Revenue', '₹12.5K', Icons.attach_money, Colors.green),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Products', '156', Icons.inventory_2, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCategory(
      BuildContext context,
      String categoryTitle,
      List<_ModernActionTile> actions,
      ThemeProvider themeProvider,
      DeviceType deviceType) {
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? DarkAppColors.surface.withValues(alpha: 0.5)
            : AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
              : AppColors.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryTitle,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(16.0, deviceType),
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          ...actions.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: action,
              )),
        ],
      ),
    );
  }
}

class _ModernActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final double? width;

  const _ModernActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode
              ? DarkAppColors.surface.withValues(alpha: 0.8)
              : AppColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                : AppColors.onSurface.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? DarkAppColors.onSurface
                          : AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                          : AppColors.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.4)
                  : AppColors.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
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
