# Order History Screen

## Overview
The `order_history_screen.dart` file implements a comprehensive order management interface for the AI-Enabled Tailoring Shop Management System. It provides role-based order viewing with advanced search, filtering, and analytics capabilities, featuring a sophisticated tab-based interface for order status management and detailed order cards with real-time status tracking.

## Key Features

### Role-Based Order Management
- **Shop Owner View**: Access to all orders with analytics and statistics
- **Customer View**: Personalized order history with focused functionality
- **Permission-Based UI**: Dynamic interface based on user role
- **Secure Data Access**: Proper data isolation and access control

### Advanced Search & Filtering
- **Real-time Search**: Instant order search across multiple fields
- **Status-Based Tabs**: 6 distinct order status categories
- **Advanced Filters**: Date range, status, and sorting options
- **Multi-criteria Filtering**: Combined search and filter functionality

### Analytics & Statistics
- **Order Statistics**: Comprehensive metrics for shop owners
- **Performance Tracking**: Completion rates and revenue analytics
- **Visual Reports**: Detailed order status breakdowns
- **Business Intelligence**: Key performance indicators

## Architecture Components

### Main Widget Structure

#### OrderHistoryScreen Widget
```dart
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}
```

#### State Management
```dart
class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }
}
```

### Order Loading Logic
```dart
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
```

## User Interface Components

### App Bar with Advanced Features
```dart
AppBar(
  title: const Text('Orders'),
  actions: [
    IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: () => _showFilterBottomSheet(context),
    ),
    if (isShopOwner) ...[
      IconButton(
        icon: Icon(Icons.analytics),
        onPressed: () => _showStatisticsDialog(context, orderProvider),
      ),
    ],
  ],
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(120),
    child: Column(
      children: [
        _buildSearchBar(),
        _buildStatusTabs(),
      ],
    ),
  ),
)
```

### Search Bar Implementation
```dart
TextField(
  controller: _searchController,
  decoration: InputDecoration(
    hintText: 'Search orders...',
    prefixIcon: Icon(Icons.search),
    suffixIcon: _searchController.text.isNotEmpty
        ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              orderProvider.searchOrders('');
            },
          )
        : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background,
  ),
  onChanged: (value) => orderProvider.searchOrders(value),
)
```

### Status Tab System
```dart
TabBar(
  controller: _tabController,
  isScrollable: true,
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
      case 1: status = OrderStatus.pending; break;
      case 2: status = OrderStatus.inProgress; break;
      case 3: status = OrderStatus.readyForFitting; break;
      case 4: status = OrderStatus.completed; break;
      case 5: status = OrderStatus.delivered; break;
      default: status = null;
    }
    orderProvider.filterByStatus(status);
  },
)
```

## Order Card Design

### Order Card Component
```dart
class _OrderCard extends StatelessWidget {
  final Order order;
  final bool isShopOwner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              _buildOrderHeader(order),
              _buildOrderItems(order),
              _buildOrderFooter(order),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Order Header
```dart
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
)
```

### Status Chip Component
```dart
class _StatusChip extends StatelessWidget {
  final OrderStatus status;

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
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.confirmed: return Colors.blue;
      case OrderStatus.assigned: return Colors.teal;
      case OrderStatus.inProgress: return Colors.purple;
      case OrderStatus.inProduction: return Colors.deepPurple;
      case OrderStatus.qualityCheck: return Colors.amber;
      case OrderStatus.readyForFitting: return Colors.teal;
      case OrderStatus.completed: return Colors.green;
      case OrderStatus.delivered: return Colors.indigo;
      case OrderStatus.cancelled: return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    return status.toString().split('.').last.toUpperCase();
  }
}
```

## Advanced Filtering System

### Filter Bottom Sheet
```dart
class OrderFilterBottomSheet extends StatefulWidget {
  const OrderFilterBottomSheet({super.key});

  @override
  State<OrderFilterBottomSheet> createState() => _OrderFilterBottomSheetState();
}
```

#### Filter Options
- **Date Range Picker**: Select custom date ranges for order filtering
- **Status Filter Chips**: Multi-select status filtering
- **Sort Options**: Multiple sorting criteria (newest, oldest, amount-based)

#### Date Range Selection
```dart
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
)
```

#### Status Filter Chips
```dart
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
)
```

#### Sort Options
```dart
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
)
```

## Analytics & Statistics

### Statistics Dialog
```dart
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
```

### Statistics Item Component
```dart
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
```

## Role-Based Features

### Shop Owner Features
#### Advanced Analytics
- **Order Statistics**: Comprehensive business metrics
- **Revenue Tracking**: Financial performance indicators
- **Completion Rates**: Operational efficiency metrics
- **Payment Tracking**: Outstanding payment monitoring

#### Management Tools
- **Bulk Operations**: Mass order management capabilities
- **Advanced Filtering**: Sophisticated search and filter options
- **Export Capabilities**: Data export for external analysis
- **Performance Insights**: Business intelligence dashboards

### Customer Features
#### Personalized Experience
- **Order History**: Complete personal order tracking
- **Quick Actions**: Easy order creation and management
- **Status Updates**: Real-time order status notifications
- **Payment Tracking**: Outstanding balance visibility

#### User-Friendly Interface
- **Simplified Navigation**: Focused on customer needs
- **Order Details**: Comprehensive order information
- **Support Integration**: Direct access to customer support
- **Favorites Management**: Saved preferences and items

## Integration Points

### With Order Provider
- **Data Management**: Centralized order data handling
  - Related: [`lib/providers/order_provider.dart`](../../providers/order_provider.md)
- **Search & Filter**: Advanced query capabilities
- **Real-time Updates**: Live order status synchronization
- **Statistics Generation**: Automated analytics calculation

### With Authentication System
- **User Context**: Role-based access and data filtering
  - Related: [`lib/providers/auth_provider.dart`](../../providers/auth_provider.md)
- **Permission Validation**: Secure data access control
- **Session Management**: Proper authentication state handling

### With Theme System
- **Dynamic Styling**: Consistent theming across all components
  - Related: [`lib/providers/theme_provider.dart`](../../providers/theme_provider.md)
- **Adaptive Colors**: Theme-aware UI elements
- **Accessibility**: High contrast and readability support

### With Order Details Screen
- **Navigation Flow**: Seamless transition to detailed views
  - Related: [`order_details_screen.dart`](../orders/order_details_screen.md)
- **Data Consistency**: Synchronized order information
- **State Preservation**: Maintain search and filter state

## Performance Optimizations

### Efficient Rendering
- **Lazy Loading**: Load orders on demand
- **Pagination Support**: Handle large order datasets
- **Optimized Filtering**: Efficient search algorithms
- **Memory Management**: Proper resource cleanup

### State Management
- **Provider Integration**: Centralized state management
- **Real-time Updates**: Live data synchronization
- **Search Optimization**: Fast search response times
- **Filter Caching**: Cached filter results

## User Experience Features

### Loading States
```dart
body: orderProvider.isLoading
    ? const Center(child: CircularProgressIndicator())
    : orderProvider.orders.isEmpty
        ? _buildEmptyState()
        : _buildOrderList(orderProvider, isShopOwner),
```

### Empty State Handling
```dart
Widget _buildEmptyState() {
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
```

### Action Button Integration
```dart
floatingActionButton: !isShopOwner
    ? FloatingActionButton.extended(
        onPressed: () => _showCreateOrderDialog(context, authProvider),
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
        backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
        foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
      )
    : null,
```

## Future Enhancements

### Advanced Features
- **Bulk Operations**: Mass order status updates and management
- **Export Functionality**: CSV/Excel export capabilities
- **Advanced Analytics**: Detailed performance dashboards
- **Notification System**: Real-time order status alerts

### AI-Powered Features
- **Smart Search**: AI-assisted order discovery
- **Predictive Analytics**: Order completion time estimation
- **Automated Categorization**: Intelligent order classification
- **Personalized Insights**: Customer behavior analytics

### Integration Features
- **Calendar Integration**: Order scheduling and reminders
- **Payment Gateway**: Integrated payment processing
- **Inventory Linking**: Automatic stock updates
- **CRM Integration**: Customer relationship management

---

*This Order History Screen serves as the comprehensive command center for order management in the tailoring shop system, providing both shop owners and customers with powerful tools to track, manage, and analyze orders through an intuitive, feature-rich interface that adapts to different user roles and needs.*