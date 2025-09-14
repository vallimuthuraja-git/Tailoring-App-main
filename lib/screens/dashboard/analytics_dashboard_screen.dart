import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/customer.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/user_avatar.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<OrderProvider, CustomerProvider, ProductProvider,
        AuthProvider>(
      builder: (context, orderProvider, customerProvider, productProvider,
          authProvider, child) {
        final isShopOwner = authProvider.isShopOwnerOrAdmin;

        // Redirect non-shop owners
        if (!isShopOwner) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Restricted'),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black87),
              titleTextStyle: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Analytics Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Available only for shop owners',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        final orderStats = orderProvider.getOrderStatistics();
        final customers = customerProvider.customers;
        final products = productProvider.products;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Business Analytics'),
            toolbarHeight: kToolbarHeight + 5,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            titleTextStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilters(context),
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _exportAnalytics(context),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _refreshData(
                    context, orderProvider, customerProvider, productProvider),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.blue.shade700,
                  labelColor: Colors.blue.shade700,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                    Tab(text: 'Revenue', icon: Icon(Icons.trending_up)),
                    Tab(text: 'Customers', icon: Icon(Icons.people)),
                    Tab(text: 'Products', icon: Icon(Icons.inventory)),
                  ],
                ),
              ),
            ),
          ),
          drawer: _buildFiltersDrawer(context),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(orderStats, customers, products),
              _buildRevenueTab(orderStats),
              _buildCustomersTab(customers, orderStats),
              _buildProductsTab(products, orderStats),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(
      Map<String, dynamic> stats, List customers, List products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceType(constraints.maxWidth);
        final crossAxisCount = deviceType == DeviceType.mobile
            ? 2
            : (deviceType == DeviceType.tablet ? 2 : 3);
        final spacing = ResponsiveUtils.responsiveSpacing(16.0, deviceType);

        return SingleChildScrollView(
          padding: EdgeInsets.all(
              ResponsiveUtils.responsiveSpacing(20.0, deviceType)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Overview',
                style: TextStyle(
                  fontSize:
                      ResponsiveUtils.responsiveFontSize(24.0, deviceType),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(20.0, deviceType)),

              // Key Metrics Grid
              GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MetricCard(
                    title: 'Total Orders',
                    value: '${stats['totalOrders']}',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                    trend: '+${stats['thisMonthOrders']} this month',
                  ),
                  _MetricCard(
                    title: 'Revenue',
                    value: '₹${stats['totalRevenue'].toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                    trend:
                        '+${((stats['thisMonthOrders'] / stats['totalOrders']) * 100).toStringAsFixed(1)}%',
                  ),
                  _MetricCard(
                    title: 'Customers',
                    value: '${customers.length}',
                    icon: Icons.people,
                    color: Colors.purple,
                    trend:
                        '${customers.where((c) => c.isActive).length} active',
                  ),
                  _MetricCard(
                    title: 'Products',
                    value: '${products.length}',
                    icon: Icons.inventory,
                    color: Colors.orange,
                    trend: '${products.where((p) => p.isActive).length} active',
                  ),
                ],
              ),

              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(32.0, deviceType)),

              // Performance Indicators
              Text(
                'Performance Indicators',
                style: TextStyle(
                  fontSize:
                      ResponsiveUtils.responsiveFontSize(20.0, deviceType),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(16.0, deviceType)),

              _PerformanceIndicator(
                label: 'Completion Rate',
                value: stats['completionRate'],
                color: Colors.green,
              ),
              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(12.0, deviceType)),
              _PerformanceIndicator(
                label: 'Average Order Value',
                value: stats['totalOrders'] > 0
                    ? stats['totalRevenue'] / stats['totalOrders']
                    : 0,
                color: Colors.blue,
                isCurrency: true,
              ),
              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(12.0, deviceType)),
              _PerformanceIndicator(
                label: 'Customer Retention',
                value: customers.isNotEmpty
                    ? (customers.where((c) => c.isActive).length /
                            customers.length) *
                        100
                    : 0,
                color: Colors.purple,
                isPercentage: true,
              ),

              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(32.0, deviceType)),

              // Recent Activity
              Text(
                'Quick Insights',
                style: TextStyle(
                  fontSize:
                      ResponsiveUtils.responsiveFontSize(20.0, deviceType),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(16.0, deviceType)),

              const _InsightCard(
                icon: Icons.trending_up,
                title: 'Revenue Growth',
                description: 'Revenue increased by 25% compared to last month',
                color: Colors.green,
              ),
              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(12.0, deviceType)),
              const _InsightCard(
                icon: Icons.people,
                title: 'Customer Engagement',
                description: 'New customer acquisition rate is improving',
                color: Colors.blue,
              ),
              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(12.0, deviceType)),
              const _InsightCard(
                icon: Icons.inventory,
                title: 'Product Performance',
                description: 'Top products are driving 60% of revenue',
                color: Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueTab(Map<String, dynamic> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceType(constraints.maxWidth);
        final crossAxisCount = deviceType == DeviceType.mobile
            ? 1
            : (deviceType == DeviceType.tablet ? 2 : 2);
        final spacing = ResponsiveUtils.responsiveSpacing(16.0, deviceType);

        return SingleChildScrollView(
          padding: EdgeInsets.all(
              ResponsiveUtils.responsiveSpacing(20.0, deviceType)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Revenue Analytics',
                style: TextStyle(
                  fontSize:
                      ResponsiveUtils.responsiveFontSize(24.0, deviceType),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(20.0, deviceType)),

              // Revenue Cards
              GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _RevenueCard(
                    title: 'Total Revenue',
                    amount: stats['totalRevenue'],
                    period: 'All Time',
                    color: Colors.green,
                  ),
                  _RevenueCard(
                    title: 'Pending Payments',
                    amount: stats['pendingPayments'],
                    period: 'Outstanding',
                    color: Colors.orange,
                  ),
                ],
              ),

              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(20.0, deviceType)),

              // Revenue Breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenue Breakdown',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                              18.0, deviceType),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _RevenueBreakdownItem(
                        label: 'This Month',
                        amount: (stats['totalRevenue'] * 0.3)
                            .toStringAsFixed(0), // Mock data
                        percentage: 30,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _RevenueBreakdownItem(
                        label: 'Last Month',
                        amount: (stats['totalRevenue'] * 0.25)
                            .toStringAsFixed(0), // Mock data
                        percentage: 25,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _RevenueBreakdownItem(
                        label: 'Older',
                        amount: (stats['totalRevenue'] * 0.45)
                            .toStringAsFixed(0), // Mock data
                        percentage: 45,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(20.0, deviceType)),

              // Monthly Trends (Mock Data)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Revenue Trend',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                              18.0, deviceType),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._generateMonthlyTrends().map((trend) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(trend['month']),
                                ),
                                Text('₹${trend['revenue']}'),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: ResponsiveUtils.responsiveSpacing(
                                        8.0, deviceType),
                                    child: LinearProgressIndicator(
                                      value: trend['percentage'] / 100,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue.shade600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomersTab(List customers, Map<String, dynamic> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceType(constraints.maxWidth);
        final crossAxisCount = deviceType == DeviceType.mobile
            ? 1
            : (deviceType == DeviceType.tablet ? 2 : 2);
        final spacing = ResponsiveUtils.responsiveSpacing(16.0, deviceType);

        return SingleChildScrollView(
          padding: EdgeInsets.all(
              ResponsiveUtils.responsiveSpacing(20.0, deviceType)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Analytics',
                style: TextStyle(
                  fontSize:
                      ResponsiveUtils.responsiveFontSize(24.0, deviceType),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(20.0, deviceType)),

              // Customer Metrics
              GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MetricCard(
                    title: 'Total Customers',
                    value: '${customers.length}',
                    icon: Icons.people,
                    color: Colors.blue,
                    trend:
                        '${customers.where((c) => c.isActive).length} active',
                  ),
                  _MetricCard(
                    title: 'Avg Order Value',
                    value: '₹${stats['averageOrderValue'].toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: Colors.green,
                    trend: 'Per customer',
                  ),
                ],
              ),

              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(20.0, deviceType)),

              // Customer Segments
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Segments',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                              18.0, deviceType),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CustomerSegmentItem(
                        segment: 'Loyal Customers',
                        count: customers
                            .where((c) =>
                                c.loyaltyTier == LoyaltyTier.gold ||
                                c.loyaltyTier == LoyaltyTier.platinum)
                            .length,
                        percentage: customers.isNotEmpty
                            ? (customers
                                        .where((c) =>
                                            c.loyaltyTier == LoyaltyTier.gold ||
                                            c.loyaltyTier ==
                                                LoyaltyTier.platinum)
                                        .length /
                                    customers.length) *
                                100
                            : 0,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 8),
                      _CustomerSegmentItem(
                        segment: 'Regular Customers',
                        count: customers
                            .where((c) => c.loyaltyTier == LoyaltyTier.silver)
                            .length,
                        percentage: customers.isNotEmpty
                            ? (customers
                                        .where((c) =>
                                            c.loyaltyTier == LoyaltyTier.silver)
                                        .length /
                                    customers.length) *
                                100
                            : 0,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _CustomerSegmentItem(
                        segment: 'New Customers',
                        count: customers
                            .where((c) => c.loyaltyTier == LoyaltyTier.bronze)
                            .length,
                        percentage: customers.isNotEmpty
                            ? (customers
                                        .where((c) =>
                                            c.loyaltyTier == LoyaltyTier.bronze)
                                        .length /
                                    customers.length) *
                                100
                            : 0,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(20.0, deviceType)),

              // Top Customers
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Customers',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                              18.0, deviceType),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...customers.take(5).map((customer) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                UserAvatar(
                                  displayName: customer.displayName,
                                  imageUrl: customer.photoUrl,
                                  radius: ResponsiveUtils.responsiveSpacing(
                                      20.0, deviceType),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.displayName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        customer.loyaltyTier,
                                        style: TextStyle(
                                          fontSize: ResponsiveUtils
                                              .responsiveFontSize(
                                                  12.0, deviceType),
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${customer.totalSpent.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsTab(List products, Map<String, dynamic> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceType(constraints.maxWidth);
        final crossAxisCount = deviceType == DeviceType.mobile
            ? 1
            : (deviceType == DeviceType.tablet ? 2 : 2);
        final spacing = ResponsiveUtils.responsiveSpacing(16.0, deviceType);

        return SingleChildScrollView(
          padding: EdgeInsets.all(
              ResponsiveUtils.responsiveSpacing(20.0, deviceType)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Analytics',
                style: TextStyle(
                  fontSize:
                      ResponsiveUtils.responsiveFontSize(24.0, deviceType),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(20.0, deviceType)),

              // Product Metrics
              GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MetricCard(
                    title: 'Total Products',
                    value: '${products.length}',
                    icon: Icons.inventory,
                    color: Colors.orange,
                    trend: '${products.where((p) => p.isActive).length} active',
                  ),
                  _MetricCard(
                    title: 'Categories',
                    value: '${products.map((p) => p.category).toSet().length}',
                    icon: Icons.category,
                    color: Colors.purple,
                    trend: 'Product types',
                  ),
                ],
              ),

              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(20.0, deviceType)),

              // Product Categories
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Categories',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                              18.0, deviceType),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._getCategoryDistribution(products)
                          .entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(entry.key),
                                    ),
                                    Text('${entry.value} products'),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SizedBox(
                                        height:
                                            ResponsiveUtils.responsiveSpacing(
                                                8.0, deviceType),
                                        child: LinearProgressIndicator(
                                          value: entry.value / products.length,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.blue.shade600),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                    ],
                  ),
                ),
              ),

              SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(20.0, deviceType)),

              // Top Products
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Products',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                              18.0, deviceType),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...products.take(5).map((product) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: ResponsiveUtils.responsiveSpacing(
                                      50.0, deviceType),
                                  height: ResponsiveUtils.responsiveSpacing(
                                      50.0, deviceType),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(product
                                              .imageUrls.isNotEmpty
                                          ? product.imageUrls.first
                                          : 'https://via.placeholder.com/50x50?text=No+Image'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        product.categoryName,
                                        style: TextStyle(
                                          fontSize: ResponsiveUtils
                                              .responsiveFontSize(
                                                  12.0, deviceType),
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${product.basePrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, int> _getCategoryDistribution(List products) {
    final distribution = <String, int>{};
    for (final product in products) {
      final category = product.categoryName;
      distribution[category] = (distribution[category] ?? 0) + 1;
    }
    return distribution;
  }

  List<Map<String, dynamic>> _generateMonthlyTrends() {
    return [
      {'month': 'January', 'revenue': '45000', 'percentage': 30},
      {'month': 'February', 'revenue': '52000', 'percentage': 35},
      {'month': 'March', 'revenue': '48000', 'percentage': 32},
      {'month': 'April', 'revenue': '61000', 'percentage': 40},
      {'month': 'May', 'revenue': '55000', 'percentage': 36},
      {'month': 'June', 'revenue': '75000', 'percentage': 50},
    ];
  }

  void _exportAnalytics(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics export feature coming soon!')),
    );
  }

  void _refreshData(
      BuildContext context,
      OrderProvider orderProvider,
      CustomerProvider customerProvider,
      ProductProvider productProvider) async {
    await orderProvider.loadOrders();
    await customerProvider.loadAllCustomers();
    await productProvider.loadProducts();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data refreshed successfully!')),
      );
    }
  }

  void _showFilters(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      showModalBottomSheet(
        context: context,
        builder: (context) => _buildFiltersBottomSheet(context),
      );
    } else {
      Scaffold.of(context).openDrawer();
    }
  }

  Widget _buildFiltersDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Filters',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Date Range'),
            onTap: () {
              // Handle date range filter
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Category'),
            onTap: () {
              // Handle category filter
            },
          ),
          ListTile(
            leading: const Icon(Icons.clear),
            title: const Text('Clear Filters'),
            onTap: () {
              // Handle clear filters
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Date Range'),
            onTap: () {
              // Handle date range filter
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Category'),
            onTap: () {
              // Handle category filter
            },
          ),
          ListTile(
            leading: const Icon(Icons.clear),
            title: const Text('Clear Filters'),
            onTap: () {
              // Handle clear filters
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

// Helper Widgets
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final String title;
  final double amount;
  final String period;
  final Color color;

  const _RevenueCard({
    required this.title,
    required this.amount,
    required this.period,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              period,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceIndicator extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isCurrency;
  final bool isPercentage;

  const _PerformanceIndicator({
    required this.label,
    required this.value,
    required this.color,
    this.isCurrency = false,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    String displayValue;
    if (isCurrency) {
      displayValue = '₹${value.toStringAsFixed(0)}';
    } else if (isPercentage) {
      displayValue = '${value.toStringAsFixed(1)}%';
    } else {
      displayValue = '${value.toStringAsFixed(1)}%';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: isPercentage
                  ? value / 100
                  : (value > 100 ? 1.0 : value / 100),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueBreakdownItem extends StatelessWidget {
  final String label;
  final String amount;
  final double percentage;
  final Color color;

  const _RevenueBreakdownItem({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label),
        ),
        Text('₹$amount'),
        const SizedBox(width: 12),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _CustomerSegmentItem extends StatelessWidget {
  final String segment;
  final int count;
  final double percentage;
  final Color color;

  const _CustomerSegmentItem({
    required this.segment,
    required this.count,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(segment),
        ),
        Text('$count customers'),
        const SizedBox(width: 12),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
