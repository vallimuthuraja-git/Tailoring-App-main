import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/customer.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
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
    return Consumer4<OrderProvider, CustomerProvider, ProductProvider, AuthProvider>(
      builder: (context, orderProvider, customerProvider, productProvider, authProvider, child) {
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
                icon: const Icon(Icons.download),
                onPressed: () => _exportAnalytics(context),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _refreshData(context, orderProvider, customerProvider, productProvider),
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

  Widget _buildOverviewTab(Map<String, dynamic> stats, List customers, List products) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Key Metrics Grid
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Orders',
                  value: '${stats['totalOrders']}',
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                  trend: '+${stats['thisMonthOrders']} this month',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  title: 'Revenue',
                  value: '₹${stats['totalRevenue'].toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: Colors.green,
                  trend: '+${((stats['thisMonthOrders'] / stats['totalOrders']) * 100).toStringAsFixed(1)}%',
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
                  trend: '${customers.where((c) => c.isActive).length} active',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  title: 'Products',
                  value: '${products.length}',
                  icon: Icons.inventory,
                  color: Colors.orange,
                  trend: '${products.where((p) => p.isActive).length} active',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Performance Indicators
          const Text(
            'Performance Indicators',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _PerformanceIndicator(
            label: 'Completion Rate',
            value: stats['completionRate'],
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _PerformanceIndicator(
            label: 'Average Order Value',
            value: stats['totalOrders'] > 0 ? stats['totalRevenue'] / stats['totalOrders'] : 0,
            color: Colors.blue,
            isCurrency: true,
          ),
          const SizedBox(height: 12),
          _PerformanceIndicator(
            label: 'Customer Retention',
            value: customers.isNotEmpty ? (customers.where((c) => c.isActive).length / customers.length) * 100 : 0,
            color: Colors.purple,
            isPercentage: true,
          ),

          const SizedBox(height: 32),

          // Recent Activity
          const Text(
            'Quick Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          const _InsightCard(
            icon: Icons.trending_up,
            title: 'Revenue Growth',
            description: 'Revenue increased by 25% compared to last month',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          const _InsightCard(
            icon: Icons.people,
            title: 'Customer Engagement',
            description: 'New customer acquisition rate is improving',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          const _InsightCard(
            icon: Icons.inventory,
            title: 'Product Performance',
            description: 'Top products are driving 60% of revenue',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTab(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Revenue Cards
          Row(
            children: [
              Expanded(
                child: _RevenueCard(
                  title: 'Total Revenue',
                  amount: stats['totalRevenue'],
                  period: 'All Time',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _RevenueCard(
                  title: 'Pending Payments',
                  amount: stats['pendingPayments'],
                  period: 'Outstanding',
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Revenue Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revenue Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RevenueBreakdownItem(
                    label: 'This Month',
                    amount: (stats['totalRevenue'] * 0.3).toStringAsFixed(0), // Mock data
                    percentage: 30,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _RevenueBreakdownItem(
                    label: 'Last Month',
                    amount: (stats['totalRevenue'] * 0.25).toStringAsFixed(0), // Mock data
                    percentage: 25,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _RevenueBreakdownItem(
                    label: 'Older',
                    amount: (stats['totalRevenue'] * 0.45).toStringAsFixed(0), // Mock data
                    percentage: 45,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Monthly Trends (Mock Data)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Revenue Trend',
                    style: TextStyle(
                      fontSize: 18,
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
                              child: LinearProgressIndicator(
                                value: trend['percentage'] / 100,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
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
  }

  Widget _buildCustomersTab(List customers, Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Customer Metrics
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Customers',
                  value: '${customers.length}',
                  icon: Icons.people,
                  color: Colors.blue,
                  trend: '${customers.where((c) => c.isActive).length} active',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  title: 'Avg Order Value',
                  value: '₹${stats['averageOrderValue'].toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: Colors.green,
                  trend: 'Per customer',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Customer Segments
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Segments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CustomerSegmentItem(
                    segment: 'Loyal Customers',
                    count: customers.where((c) => c.loyaltyTier == LoyaltyTier.gold || c.loyaltyTier == LoyaltyTier.platinum).length,
                    percentage: customers.isNotEmpty ? (customers.where((c) => c.loyaltyTier == LoyaltyTier.gold || c.loyaltyTier == LoyaltyTier.platinum).length / customers.length) * 100 : 0,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 8),
                  _CustomerSegmentItem(
                    segment: 'Regular Customers',
                    count: customers.where((c) => c.loyaltyTier == LoyaltyTier.silver).length,
                    percentage: customers.isNotEmpty ? (customers.where((c) => c.loyaltyTier == LoyaltyTier.silver).length / customers.length) * 100 : 0,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _CustomerSegmentItem(
                    segment: 'New Customers',
                    count: customers.where((c) => c.loyaltyTier == LoyaltyTier.bronze).length,
                    percentage: customers.isNotEmpty ? (customers.where((c) => c.loyaltyTier == LoyaltyTier.bronze).length / customers.length) * 100 : 0,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Top Customers
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Customers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...customers.take(5).map((customer) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: customer.photoUrl != null
                                  ? NetworkImage(customer.photoUrl!)
                                  : null,
                              child: customer.photoUrl == null
                                  ? Text(customer.displayName[0].toUpperCase())
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    customer.loyaltyTier,
                                    style: TextStyle(
                                      fontSize: 12,
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
  }

  Widget _buildProductsTab(List products, Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Product Metrics
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Products',
                  value: '${products.length}',
                  icon: Icons.inventory,
                  color: Colors.orange,
                  trend: '${products.where((p) => p.isActive).length} active',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  title: 'Categories',
                  value: '${products.map((p) => p.category).toSet().length}',
                  icon: Icons.category,
                  color: Colors.purple,
                  trend: 'Product types',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Product Categories
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._getCategoryDistribution(products).entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(entry.key),
                            ),
                            Text('${entry.value} products'),
                            const SizedBox(width: 12),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: entry.value / products.length,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Top Products
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...products.take(5).map((product) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(product.imageUrls.isNotEmpty
                                      ? product.imageUrls.first
                                      : 'https://via.placeholder.com/50x50?text=No+Image'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    product.categoryName,
                                    style: TextStyle(
                                      fontSize: 12,
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

  void _refreshData(BuildContext context, OrderProvider orderProvider,
      CustomerProvider customerProvider, ProductProvider productProvider) async {
    await orderProvider.loadOrders();
    await customerProvider.loadAllCustomers();
    await productProvider.loadProducts();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data refreshed successfully!')),
      );
    }
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
              value: isPercentage ? value / 100 : (value > 100 ? 1.0 : value / 100),
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
