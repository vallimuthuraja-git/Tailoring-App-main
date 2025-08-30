import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore_for_file: deprecated_member_use
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import 'order_details_screen.dart';
import 'order_creation_wizard.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
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

  void _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.isShopOwnerOrAdmin) {
      // Shop owners see all orders
      await orderProvider.loadOrders();
    } else {
      // Customers see only their orders
      await orderProvider.loadOrders(userId: authProvider.user?.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<OrderProvider, AuthProvider, ThemeProvider>(
      builder: (context, orderProvider, authProvider, themeProvider, child) {
        final isShopOwner = authProvider.isShopOwnerOrAdmin;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Orders'),
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
                  Icons.filter_list,
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
                onPressed: () => _showFilterBottomSheet(context),
              ),
              if (isShopOwner) ...[
                IconButton(
                  icon: Icon(
                    Icons.analytics,
                    color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                  ),
                  onPressed: () => _showStatisticsDialog(context, orderProvider),
                ),
              ],
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
                                  orderProvider.searchOrders('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.3) : AppColors.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.3) : AppColors.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background,
                        hintStyle: TextStyle(
                           color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.5) : AppColors.onSurface.withValues(alpha: 0.5),
                         ),
                       ),
                       onChanged: (value) => orderProvider.searchOrders(value),
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
                      Tab(text: 'Delivered'),
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
                          status = OrderStatus.delivered;
                          break;
                        default:
                          status = null;
                      }
                      orderProvider.filterByStatus(status);
                    },
                  ),
                ],
              ),
            ),
          ),
          body: orderProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : orderProvider.orders.isEmpty
                  ? _buildEmptyState()
                  : _buildOrderList(orderProvider, isShopOwner),
          floatingActionButton: isShopOwner
              ? FloatingActionButton.extended(
                  onPressed: () => _showCreateOrderDialog(context, authProvider),
                  icon: const Icon(Icons.add),
                  label: const Text('New Order'),
                  backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                  foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                )
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
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
              color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your orders will appear here',
            style: TextStyle(
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

  Widget _buildOrderList(OrderProvider orderProvider, bool isShopOwner) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderProvider.orders.length,
      itemBuilder: (context, index) {
        final order = orderProvider.orders[index];
        return _OrderCard(
          order: order,
          isShopOwner: isShopOwner,
          onTap: () => _navigateToOrderDetails(context, order),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const OrderFilterBottomSheet(),
    );
  }

  void _showStatisticsDialog(BuildContext context, OrderProvider orderProvider) {
    final stats = orderProvider.getOrderStatistics();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatItem('Total Orders', '${stats['totalOrders']}'),
            _StatItem('This Month', '${stats['thisMonthOrders']}'),
            _StatItem('Pending Orders', '${stats['pendingOrders']}'),
            _StatItem('In Progress', '${stats['inProgressOrders']}'),
            _StatItem('Completed', '${stats['completedOrders']}'),
            _StatItem('Total Revenue', '₹${stats['totalRevenue'].toStringAsFixed(0)}'),
            _StatItem('Pending Payments', '₹${stats['pendingPayments'].toStringAsFixed(0)}'),
            _StatItem('Completion Rate', '${stats['completionRate'].toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateOrderDialog(BuildContext context, AuthProvider authProvider) async {
    // Navigate to order creation wizard
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderCreationWizard(),
      ),
    );

    // If order was created successfully, refresh the list
    if (result == true) {
      _loadOrders();
    }
  }

  void _navigateToOrderDetails(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final bool isShopOwner;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.isShopOwner,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8).toUpperCase()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ordered on ${_formatDate(order.orderDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                : AppColors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: order.status),
                ],
              ),

              const SizedBox(height: 12),

              // Order Items
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          'Qty: ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                : AppColors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: ₹${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (order.remainingAmount > 0)
                          Text(
                            'Due: ₹${order.remainingAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (order.deliveryDate != null)
                    Text(
                      'Due: ${_formatDate(order.deliveryDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.assigned:
        return Colors.teal;
      case OrderStatus.inProgress:
        return Colors.purple;
      case OrderStatus.inProduction:
        return Colors.deepPurple;
      case OrderStatus.qualityCheck:
        return Colors.amber;
      case OrderStatus.readyForFitting:
        return Colors.teal;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.indigo;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    return status.toString().split('.').last.toUpperCase();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class OrderFilterBottomSheet extends StatefulWidget {
  const OrderFilterBottomSheet({super.key});

  @override
  State<OrderFilterBottomSheet> createState() => _OrderFilterBottomSheetState();
}

class _OrderFilterBottomSheetState extends State<OrderFilterBottomSheet> {
  DateTimeRange? _dateRange;
  OrderStatus? _selectedStatus;
  String _selectedSort = 'newest';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Date Range
          const Text(
            'Date Range',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) {
                setState(() => _dateRange = picked);
              }
            },
            child: Text(_dateRange == null
                ? 'Select Date Range'
                : '${_dateRange!.start.toString().split(' ')[0]} - ${_dateRange!.end.toString().split(' ')[0]}'),
          ),

          const SizedBox(height: 20),

          // Status Filter
          const Text(
            'Order Status',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: OrderStatus.values.map((status) {
              return FilterChip(
                label: Text(status.toString().split('.').last),
                selected: _selectedStatus == status,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? status : null;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Sort Options
          const Text(
            'Sort By',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              RadioListTile<String>(
                title: const Text('Newest First'),
                value: 'newest',
                groupValue: _selectedSort,
                onChanged: (String? value) => setState(() => _selectedSort = value ?? 'newest'),
              ),
              RadioListTile<String>(
                title: const Text('Oldest First'),
                value: 'oldest',
                groupValue: _selectedSort,
                onChanged: (String? value) => setState(() => _selectedSort = value ?? 'oldest'),
              ),
              RadioListTile<String>(
                title: const Text('Amount (High to Low)'),
                value: 'amount_desc',
                groupValue: _selectedSort,
                onChanged: (String? value) => setState(() => _selectedSort = value ?? 'amount_desc'),
              ),
              RadioListTile<String>(
                title: const Text('Amount (Low to High)'),
                value: 'amount_asc',
                groupValue: _selectedSort,
                onChanged: (String? value) => setState(() => _selectedSort = value ?? 'amount_asc'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Apply Filters Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters logic here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filters applied!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
