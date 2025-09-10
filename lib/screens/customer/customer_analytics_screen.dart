import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/customer.dart';
import '../../utils/theme_constants.dart';
import '../../services/firebase_service.dart';

class CustomerAnalyticsScreen extends StatefulWidget {
  const CustomerAnalyticsScreen({super.key});

  @override
  State<CustomerAnalyticsScreen> createState() => _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends State<CustomerAnalyticsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Analytics'),
        backgroundColor: isDark ? DarkAppColors.surface : AppColors.surface,
        foregroundColor: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          if (customerProvider.isLoading || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (customerProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${customerProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => customerProvider.loadAllCustomers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return _buildAnalyticsView(customerProvider.customers, isDark);
        },
      ),
    );
  }

  Widget _buildAnalyticsView(List<Customer> customers, bool isDark) {
    if (customers.isEmpty) {
      return const Center(
        child: Text('No customers available for analytics'),
      );
    }

    // Calculate analytics data
    final totalCustomers = customers.length;
    final activeCustomers = customers.where((c) => c.isActive).length;
    final inactiveCustomers = totalCustomers - activeCustomers;
    final totalRevenue = customers.fold<double>(0, (sum, c) => sum + c.totalSpent);

    final loyaltyTierDistribution = <String, int>{};
    for (final customer in customers) {
      final tier = customer.loyaltyTier.name;
      loyaltyTierDistribution[tier] = (loyaltyTierDistribution[tier] ?? 0) + 1;
    }

    final topCustomers = customers
        .where((c) => c.totalSpent > 0)
        .toList()
      ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent))
      ..take(5);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Customers',
                  value: totalCustomers.toString(),
                  icon: Icons.people,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Active Customers',
                  value: activeCustomers.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Inactive',
                  value: inactiveCustomers.toString(),
                  icon: Icons.cancel,
                  color: Colors.red,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Revenue',
                  value: '₹${totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Loyalty Tier Distribution
          _buildSection(
            title: 'Loyalty Tier Distribution',
            icon: Icons.star,
            children: [
              ...loyaltyTierDistribution.entries.map((entry) {
                final percentage = (entry.value / totalCustomers * 100).round();
                return _buildProgressBarItem(
                  label: '${entry.key.capitalize()}',
                  value: entry.value,
                  percentage: percentage,
                  isDark: isDark,
                );
              }),
            ],
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Top Customers
          if (topCustomers.isNotEmpty)
            _buildSection(
              title: 'Top Customers',
              icon: Icons.leaderboard,
              children: topCustomers.take(5).map((customer) {
                final rank = topCustomers.indexOf(customer) + 1;
                return _buildTopCustomerItem(
                  rank: rank,
                  customer: customer,
                  isDark: isDark,
                );
              }).toList(),
              isDark: isDark,
            ),

          const SizedBox(height: 24),

          // Customer Activity
          _buildSection(
            title: 'Recent Activity',
            icon: Icons.history,
            children: [
              _buildActivityItem(
                title: 'Customers Added Today',
                value: '3',
                isDark: isDark,
              ),
              _buildActivityItem(
                title: 'Measurements Updated',
                value: '12',
                isDark: isDark,
              ),
              _buildActivityItem(
                title: 'Orders Completed',
                value: '28',
                isDark: isDark,
              ),
            ],
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    Color? color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkAppColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? DarkAppColors.onSurface : AppColors.onSurface).withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color ?? (isDark ? DarkAppColors.primary : AppColors.primary),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: (isDark ? DarkAppColors.onSurface : AppColors.onSurface).withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkAppColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? DarkAppColors.onSurface : AppColors.onSurface).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? DarkAppColors.primary : AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBarItem({
    required String label,
    required int value,
    required int percentage,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
              ),
              Text(
                '$value ($percentage%)',
                style: TextStyle(
                  color: (isDark ? DarkAppColors.onSurface : AppColors.onSurface).withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: (isDark ? DarkAppColors.onSurface : AppColors.onSurface).withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(
              isDark ? DarkAppColors.primary : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomerItem({
    required int rank,
    required Customer customer,
    required bool isDark,
  }) {
    final rankColors = [
      Colors.amber, // Gold
      Colors.grey,  // Silver
      const Color(0xFFCD7F32), // Bronze
      Colors.blue,
      Colors.green,
    ];

    final color = rank <= rankColors.length ? rankColors[rank - 1] : Colors.purple;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
                  ),
                ),
                Text(
                  customer.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: (isDark ? DarkAppColors.onSurface : AppColors.onSurface).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${customer.totalSpent.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? DarkAppColors.primary : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isDark ? DarkAppColors.primary : AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? DarkAppColors.primary : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension for string capitalization
extension _StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}