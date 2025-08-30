import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import 'order_creation_wizard.dart';
import 'order_details_screen.dart';
import 'package:intl/intl.dart';

class OrderManagementDashboard extends StatefulWidget {
  const OrderManagementDashboard({super.key});

  @override
  State<OrderManagementDashboard> createState() => _OrderManagementDashboardState();
}

class _OrderManagementDashboardState extends State<OrderManagementDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Load orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
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
          IconButton(
            icon: Icon(
              Icons.add,
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
            onPressed: () => _navigateToCreateOrder(context),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
            onPressed: _loadOrders,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              Provider.of<OrderProvider>(context, listen: false).searchOrders('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.3) : AppColors.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                    filled: true,
                    fillColor: themeProvider.isDarkMode ? DarkAppColors.background : AppColors.background,
                  ),
                  onChanged: (value) => Provider.of<OrderProvider>(context, listen: false).searchOrders(value),
                ),
              ),

              // Status Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                labelColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                unselectedLabelColor: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                    : AppColors.onSurface.withValues(alpha: 0.6),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'In Progress'),
                  Tab(text: 'Ready'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
                onTap: (index) {
                  OrderStatus? status;
                  switch (index) {
                    case 1:
                      status = OrderStatus.pending;
                      break;
                    case 2:
                      status = OrderStatus.inProgress;
                      break;
                    case 3:
                      status = OrderStatus.readyForFitting;
                      break;
                    case 4:
                      status = OrderStatus.completed;
                      break;
                    case 5:
                      status = OrderStatus.cancelled;
                      break;
                    default:
                      status = null;
                  }
                  Provider.of<OrderProvider>(context, listen: false).filterByStatus(status);
                },
              ),
            ],
          ),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          return Column(
            children: [
              // Statistics Cards
              _buildStatisticsCards(orderProvider, themeProvider),

              // Orders List
              Expanded(
                child: orderProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : orderProvider.orders.isEmpty
                        ? _buildEmptyState(themeProvider)
                        : _buildOrdersList(orderProvider, themeProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateOrder(context),
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
        foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
      ),
    );
  }

  Widget _buildStatisticsCards(OrderProvider orderProvider, ThemeProvider themeProvider) {
    final stats = orderProvider.getOrderStatistics();

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            'Total Orders',
            stats['totalOrders'].toString(),
            Icons.shopping_cart,
            themeProvider,
          ),
          _buildStatCard(
            'This Month',
            stats['thisMonthOrders'].toString(),
            Icons.calendar_month,
            themeProvider,
          ),
          _buildStatCard(
            'Pending',
            orderProvider.pendingOrders.length.toString(),
            Icons.pending,
            themeProvider,
            color: Colors.orange,
          ),
          _buildStatCard(
            'In Progress',
            orderProvider.inProgressOrders.length.toString(),
            Icons.work,
            themeProvider,
            color: Colors.blue,
          ),
          _buildStatCard(
            'Completed',
            orderProvider.completedOrders.length.toString(),
            Icons.check_circle,
            themeProvider,
            color: Colors.green,
          ),
          _buildStatCard(
            'Revenue',
            '₹${stats['totalRevenue'].toStringAsFixed(0)}',
            Icons.attach_money,
            themeProvider,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, ThemeProvider themeProvider, {Color? color}) {
    final cardColor = color ?? (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
              : AppColors.onSurface.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.08)
                : AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: cardColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
            color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory,
            size: 64,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                : AppColors.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first order to get started',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateOrder(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
              foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrderProvider orderProvider, ThemeProvider themeProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderProvider.orders.length,
      itemBuilder: (context, index) {
        final order = orderProvider.orders[index];
        return _buildOrderCard(order, themeProvider);
      },
    );
  }

  Widget _buildOrderCard(Order order, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(order.orderDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                                : AppColors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(order.status, themeProvider),
                ],
              ),

              const SizedBox(height: 12),

              // Order Items
              Text(
                '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.8)
                      : AppColors.onSurface.withValues(alpha: 0.8),
                ),
              ),

              const SizedBox(height: 8),

              // First item preview
              if (order.items.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.items.first.productName,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (order.items.length > 1)
                      Text(
                        ' +${order.items.length - 1} more',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                              : AppColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Order Footer
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: ₹${order.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                          ),
                        ),
                        if (order.remainingAmount > 0)
                          Text(
                            'Due: ₹${order.remainingAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Quick Actions
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showOrderActions(context, order),
                        icon: const Icon(Icons.more_vert, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status, ThemeProvider themeProvider) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case OrderStatus.inProgress:
      case OrderStatus.assigned:
      case OrderStatus.inProduction:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        break;
      case OrderStatus.qualityCheck:
        backgroundColor = Colors.amber.shade100;
        textColor = Colors.amber.shade800;
        break;
      case OrderStatus.readyForFitting:
        backgroundColor = Colors.teal.shade100;
        textColor = Colors.teal.shade800;
        break;
      case OrderStatus.completed:
      case OrderStatus.delivered:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _navigateToCreateOrder(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderCreationWizard(),
      ),
    );

    if (result == true) {
      // Order was created successfully, refresh the list
      _loadOrders();
    }
  }

  void _navigateToOrderDetails(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ),
    );
  }

  void _showOrderActions(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.id.substring(0, 8)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              'View Details',
              Icons.visibility,
              () {
                Navigator.pop(context);
                _navigateToOrderDetails(order);
              },
            ),
            _buildActionButton(
              context,
              'Update Status',
              Icons.update,
              () => _showStatusUpdateDialog(context, order),
            ),
            _buildActionButton(
              context,
              'Add Payment',
              Icons.payment,
              () => _showPaymentDialog(context, order),
            ),
            _buildActionButton(
              context,
              'Assign Employee',
              Icons.person_add,
              () => _showEmployeeAssignmentDialog(context, order),
            ),
            const SizedBox(height: 10),
            _buildActionButton(
              context,
              'Cancel Order',
              Icons.cancel,
              () => _showCancelOrderDialog(context, order),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showStatusUpdateDialog(BuildContext context, Order order) {
    final statuses = OrderStatus.values.where((status) => status != order.status).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            return ListTile(
              title: Text(status.statusText),
              onTap: () async {
                Navigator.pop(context);
                final success = await Provider.of<OrderProvider>(context, listen: false)
                    .updateOrderStatus(order.id, status);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order status updated to ${status.statusText}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update order status')),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Order order) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Remaining Amount: ₹${order.remainingAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '₹',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                final success = await Provider.of<OrderProvider>(context, listen: false)
                    .updatePaymentStatus(order.id, PaymentStatus.paid, paidAmount: amount);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment recorded successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to record payment')),
                  );
                }
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  void _showEmployeeAssignmentDialog(BuildContext context, Order order) {
    // This would integrate with employee management
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Employee assignment feature coming soon!')),
    );
  }

  void _showCancelOrderDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<OrderProvider>(context, listen: false)
                  .updateOrderStatus(order.id, OrderStatus.cancelled);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to cancel order')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }
}
