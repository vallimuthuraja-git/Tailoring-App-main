import 'package:flutter/material.dart';
import '../services/demo_data_service.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/customer.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_constants.dart';

class DemoOverviewScreen extends StatefulWidget {
  const DemoOverviewScreen({super.key});

  @override
  State<DemoOverviewScreen> createState() => _DemoOverviewScreenState();
}

class _DemoOverviewScreenState extends State<DemoOverviewScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  final List<Product> _products = ComprehensiveDemoDataService.getDemoProducts();
  final List<Customer> _customers = ComprehensiveDemoDataService.getDemoCustomers();
  final List<Order> _orders = ComprehensiveDemoDataService.getDemoOrders();

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializePages();
  }

  void _initializePages() {
    _pages.addAll([
      DemoStatisticsTab(products: _products, orders: _orders, customers: _customers),
      DemoProductsTab(products: _products),
      DemoOrdersTab(orders: _orders),
      DemoCustomersTab(customers: _customers),
      DemoAnalyticsTab(products: _products, orders: _orders, customers: _customers),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeProvider.isDarkMode
                        ? Colors.blue.shade500
                        : Colors.blue.shade400,
                    themeProvider.isDarkMode
                        ? Colors.blue.shade600
                        : Colors.blue.shade500,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.slideshow,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Business Demo'),
          ],
        ),
        backgroundColor: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        elevation: 0,
        foregroundColor: themeProvider.isDarkMode
            ? DarkAppColors.onSurface
            : AppColors.onSurface,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Chip(
              avatar: Icon(
                Icons.data_object,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                size: 16,
              ),
              label: const Text('Static Demo Data'),
              backgroundColor: themeProvider.isDarkMode
                  ? DarkAppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // Tab Navigation
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.surface.withValues(alpha: 0.9)
                  : AppColors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                    : AppColors.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary,
                    (themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary)
                        .withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
              tabs: const [
                Tab(icon: Icon(Icons.show_chart), text: 'Overview'),
                Tab(icon: Icon(Icons.inventory), text: 'Products'),
                Tab(icon: Icon(Icons.receipt), text: 'Orders'),
                Tab(icon: Icon(Icons.people), text: 'Customers'),
                Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
              ],
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),

          // Content Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                        : AppColors.onSurface.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _pages[_currentIndex],
              ),
            ),
          ),
        ],
      ),

      // FAB (Floating Action Button) for Demo Actions
      floatingActionButton: Theme(
        data: Theme.of(context).copyWith(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: themeProvider.isDarkMode
                ? DarkAppColors.secondary
                : AppColors.secondary,
          ),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showDemoActionsSheet(context),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Demo Actions'),
          heroTag: 'demo_fab',
        ),
      ),
    );
  }

  void _showDemoActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const DemoActionsSheet(),
    );
  }
}

// Demo Statistics Tab - Overview Dashboard
class DemoStatisticsTab extends StatelessWidget {
  final List<Product> products;
  final List<Order> orders;
  final List<Customer> customers;

  const DemoStatisticsTab({
    super.key,
    required this.products,
    required this.orders,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final stats = ComprehensiveDemoDataService.getOrderStatistics();

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? DarkAppColors.background
          : AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeProvider.isDarkMode
                        ? DarkAppColors.primary.withValues(alpha: 0.8)
                        : AppColors.primary.withValues(alpha: 0.8),
                    themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.show_chart, size: 48, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Business Demo',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'AI-Enhanced Tailoring Management',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Key Metrics Cards
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Orders',
                    value: '${orders.length}',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                    themeProvider: themeProvider,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Revenue',
                    value: '₹${orders.fold<double>(0, (sum, order) => sum + order.totalAmount).toStringAsFixed(0)}',
                    icon: Icons.money,
                    color: Colors.green,
                    themeProvider: themeProvider,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Customers',
                    value: '${customers.length}',
                    icon: Icons.people,
                    color: Colors.purple,
                    themeProvider: themeProvider,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Products',
                    value: '${products.length}',
                    icon: Icons.inventory,
                    color: Colors.orange,
                    themeProvider: themeProvider,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Orders Section
            Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onBackground
                    : AppColors.onBackground,
              ),
            ),

            const SizedBox(height: 16),

            ...orders.take(2).map((order) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.surface
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                      : AppColors.onSurface.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.split('_').last}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface
                                : AppColors.onSurface,
                          ),
                        ),
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.primary
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(order.status.toString().split('.').last),
                    backgroundColor: Colors.blue.shade100,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// Products Demo Tab
class DemoProductsTab extends StatelessWidget {
  final List<Product> products;

  const DemoProductsTab({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? DarkAppColors.background
          : AppColors.background,
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 16,
          childAspectRatio: 3,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.surface
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                    : AppColors.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.surface
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.inventory,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface
                              : AppColors.onSurface,
                        ),
                      ),
                      Text(
                        product.description.length > 50
                            ? '${product.description.substring(0, 50)}...'
                            : product.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                              : AppColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${product.basePrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Orders Demo Tab
class DemoOrdersTab extends StatelessWidget {
  final List<Order> orders;

  const DemoOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? DarkAppColors.background
          : AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.surface
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                    : AppColors.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface
                            : AppColors.onSurface,
                      ),
                    ),
                    Chip(
                      label: Text(order.status.toString().split('.').last),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ₹${order.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Customers Demo Tab
class DemoCustomersTab extends StatelessWidget {
  final List<Customer> customers;

  const DemoCustomersTab({super.key, required this.customers});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? DarkAppColors.background
          : AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.surface
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                    : AppColors.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: themeProvider.isDarkMode
                      ? DarkAppColors.primary.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    customer.displayName[0].toUpperCase(),
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface
                              : AppColors.onSurface,
                        ),
                      ),
                      Text(
                        customer.email,
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                              : AppColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        customer.phone,
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                              : AppColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Analytics Demo Tab
class DemoAnalyticsTab extends StatelessWidget {
  final List<Product> products;
  final List<Order> orders;
  final List<Customer> customers;

  const DemoAnalyticsTab({
    super.key,
    required this.products,
    required this.orders,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? DarkAppColors.background
          : AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onBackground
                    : AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 20),

            // Analytics Cards
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Products',
                    value: '${products.length}',
                    icon: Icons.inventory,
                    color: Colors.orange,
                    themeProvider: themeProvider,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Total Customers',
                    value: '${customers.length}',
                    icon: Icons.people,
                    color: Colors.purple,
                    themeProvider: themeProvider,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Active Orders',
                    value: '${orders.length}',
                    icon: Icons.work,
                    color: Colors.green,
                    themeProvider: themeProvider,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Data Points',
                    value: '${((products.length + customers.length + orders.length) * 10)}',
                    icon: Icons.data_usage,
                    color: Colors.blue,
                    themeProvider: themeProvider,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Metrics Card Widget
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeProvider themeProvider;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
              : AppColors.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                  : AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// Demo Actions Bottom Sheet
class DemoActionsSheet extends StatelessWidget {
  const DemoActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                  : AppColors.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Demo Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          _DemoActionItem(
            icon: Icons.data_object,
            title: 'Static Data Generation',
            subtitle: '35 customers, 28 products, 22 orders',
            themeProvider: themeProvider,
          ),
          _DemoActionItem(
            icon: Icons.show_chart,
            title: 'Business Analytics',
            subtitle: 'Revenue tracking and KPIs',
            themeProvider: themeProvider,
          ),
          _DemoActionItem(
            icon: Icons.chat,
            title: 'AI Chatbot Demo',
            subtitle: 'Interactive tailoring assistant',
            themeProvider: themeProvider,
          ),
          _DemoActionItem(
            icon: Icons.cloud_sync,
            title: 'No Server Required',
            subtitle: 'Works offline with preloaded data',
            themeProvider: themeProvider,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check_circle),
              label: const Text('Got it!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                foregroundColor: themeProvider.isDarkMode
                    ? DarkAppColors.onPrimary
                    : AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeProvider themeProvider;

  const _DemoActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.background
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface
                        : AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                        : AppColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}