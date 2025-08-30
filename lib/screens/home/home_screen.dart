import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/user_role.dart';
import '../../utils/theme_constants.dart';
import '../catalog/modern_product_catalog_screen.dart';
import '../services/service_catalog_screen.dart';
import '../orders/order_history_screen.dart';
import '../orders/order_management_dashboard.dart';
import '../profile/profile_screen.dart';
import '../demo_setup_screen.dart';
import '../employee/employee_management_home.dart';
import '../database/database_management_home.dart';
import '../customer/customer_management_screen.dart';
import '../cart/cart_screen.dart';
import '../workflow/tailoring_workflow_screen.dart';
import '../ai/ai_assistance_screen.dart';
import '../demo_overview_screen.dart';
import '../employee/simple_employee_list_screen.dart';

// Using beautiful theme-level opacity extensions
// No more deprecated withValues(alpha:) calls - everything uses withValues() internally
// ignore_for_file: deprecated_member_use

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _setupNavigation();
  }

  void _setupNavigation() {
    // Default setup - will be updated when context is available in build
    _screens = [
      DashboardTab(
        onNavigateToProducts: () => setState(() => _selectedIndex = 1),
        onNavigateToServices: () => setState(() => _selectedIndex = 2),
        onNavigateToOrders: () => setState(() => _selectedIndex = 3),
      ),
      const ModernProductCatalogScreen(),
      const ServiceCatalogScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];
    _navItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: 'Products',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.business),
        label: 'Services',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long),
        label: 'Orders',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  void _reconfigureForEmployee() {
    setState(() {
      _selectedIndex = 0; // Reset to first tab
      _screens = [
        DashboardTab(
          onNavigateToOrders: () => setState(() => _selectedIndex = 1),
        ),
        const OrderHistoryScreen(),
        const ProfileScreen(),
      ];
      _navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        // Check user role and configure navigation accordingly
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authProvider.userRole == UserRole.employee && _screens.length != 3) {
            _reconfigureForEmployee();
          } else if (authProvider.userRole != UserRole.employee && _screens.length != 5) {
            _setupNavigation();
          }
        });

        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
            selectedItemColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
            unselectedItemColor: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                : AppColors.onSurface.withValues(alpha: 0.6),
            items: _navItems,
          ),
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            toolbarHeight: kToolbarHeight + 5,
            backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
            elevation: 0,
            iconTheme: IconThemeData(
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
            titleTextStyle: TextStyle(
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
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
                           color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                         ),
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
                   Icons.notifications,
                   color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                 ),
                 onPressed: () {
                   // Navigate to notifications
                 },
               ),
               IconButton(
                 icon: Icon(
                   Icons.chat,
                   color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                 ),
                 onPressed: () {
                   // Open AI chatbot
                   _showChatbot(context);
                 },
               ),
               IconButton(
                 icon: Icon(
                   Icons.play_arrow,
                   color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                 ),
                 tooltip: 'View Demo',
                 onPressed: () => _showDemoOverview(context),
               ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                                  ? DarkAppColors.primaryVariant.withValues(alpha: 0.9)
                                  : AppColors.primaryVariant.withValues(alpha: 0.9),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                              themeProvider.isDarkMode ? DarkAppColors.primaryVariant : AppColors.primaryVariant,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                            backgroundImage: user?.photoUrl != null
                                ? NetworkImage(user!.photoUrl!)
                                : null,
                            child: user?.photoUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 30,
                                    color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                                  )
                                : null,
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
                    color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 16),

                if (isShopOwner) ...[
                  // Shop Owner Actions
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.people_alt,
                          title: 'View Employees',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SimpleEmployeeListScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.inventory,
                          title: 'Manage Products',
                          color: Colors.orange,
                          onTap: onNavigateToProducts ?? () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.people,
                          title: 'Customers',
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CustomerManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.group,
                          title: 'Team Management',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EmployeeManagementHome(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.receipt_long,
                          title: 'Order Mgmt',
                          color: Colors.indigo,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrderManagementDashboard(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.people,
                          title: 'Customer Mgmt',
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CustomerManagementScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.analytics,
                          title: 'Reports',
                          color: Colors.cyan,
                          onTap: () {
                            // Navigate to reports
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.build,
                          title: 'Demo Setup',
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DemoSetupScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.build,
                          title: 'Demo Setup',
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DemoSetupScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.storage,
                          title: 'Database Mgmt',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DatabaseManagementHome(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.engineering,
                          title: 'Workflow',
                          color: Colors.indigo,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TailoringWorkflowScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.analytics,
                          title: 'Analytics',
                          color: Colors.cyan,
                          onTap: () {
                            // Navigate to analytics
                          },
                        ),
                      ),
                    ],
                  ),

                  // Employee Analytics and Management
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
                                    builder: (context) => const EmployeeManagementHome(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.people),
                              label: const Text('Access Team Management'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1E3C72),
                                side: const BorderSide(color: Colors.white, width: 1),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Customer Actions
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.shopping_bag,
                          title: 'Browse Products',
                          color: Colors.blue,
                          onTap: onNavigateToProducts ?? () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.receipt_long,
                          title: 'My Orders',
                          color: Colors.green,
                          onTap: onNavigateToOrders,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.chat,
                          title: 'AI Assistant',
                          color: Colors.purple,
                          onTap: () {
                            _showChatbot(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.support_agent,
                          title: 'Support',
                          color: Colors.teal,
                          onTap: () {
                            // Navigate to support
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.support_agent,
                          title: 'Support',
                          color: Colors.blue,
                          onTap: () {
                            // Navigate to support
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.feedback,
                          title: 'Feedback',
                          color: Colors.orange,
                          onTap: () {
                            // Navigate to feedback
                          },
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                // Recent Activity
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 16),

                // Recent activity items would go here
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha:0.2)
                          : AppColors.onSurface.withValues(alpha:0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha:0.7)
                            : AppColors.onSurface.withValues(alpha:0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No recent activity yet. Start exploring our services!',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha:0.7)
                                : AppColors.onSurface.withValues(alpha:0.7),
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

  void _showDemoOverview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DemoOverviewScreen(),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha:0.2)
                : AppColors.onSurface.withValues(alpha:0.2),
          ),
          boxShadow: themeProvider.isGlassyMode
              ? null
              : [
                  BoxShadow(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha:0.1)
                        : AppColors.onSurface.withValues(alpha:0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
