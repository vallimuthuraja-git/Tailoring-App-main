# Order Provider

## Overview
The `order_provider.dart` file implements comprehensive order state management for the AI-Enabled Tailoring Shop Management System. It provides complete CRUD operations, real-time updates, search/filtering, analytics, and integration with Firebase for order management.

## Key Features

### State Management
- **Order CRUD Operations**: Create, read, update, delete orders
- **Real-time Updates**: Live order status synchronization
- **Search & Filtering**: Advanced order search and status filtering
- **Analytics**: Comprehensive order statistics and reporting

### Business Logic
- **Payment Processing**: Advance and balance payment tracking
- **Status Management**: Complete order lifecycle management
- **Employee Assignment**: Order-to-employee assignment system
- **Quality Control**: Order inspection and approval workflow

## Core Properties

### Data Storage
- **`_orders`**: Complete list of all orders (List<Order>)
- **`_filteredOrders`**: Filtered/search results (List<Order>)
- **`_isLoading`**: Operation status indicator (bool)
- **`_errorMessage`**: Error message storage (String?)

### Filtering System
- **`_selectedStatusFilter`**: Active status filter (OrderStatus?)
- **`_searchQuery`**: Current search query (String)

## Computed Properties

### Order Lists
```dart
List<Order> get orders => _searchQuery.isEmpty && _selectedStatusFilter == null
    ? _orders
    : _filteredOrders;
```

### Status-Based Getters
```dart
List<Order> get pendingOrders => _orders.where((order) => order.status == OrderStatus.pending).toList();
List<Order> get inProgressOrders => _orders.where((order) => order.status == OrderStatus.inProgress).toList();
List<Order> get completedOrders => _orders.where((order) => order.status == OrderStatus.completed).toList();
```

### Statistics Getters
```dart
int get totalOrders => _orders.length;
int get pendingOrdersCount => pendingOrders.length;
int get inProgressOrdersCount => inProgressOrders.length;
int get completedOrdersCount => completedOrders.length;

double get totalRevenue => _orders
    .where((order) => order.paymentStatus == PaymentStatus.paid)
    .fold(0.0, (sum, order) => sum + order.totalAmount);

double get pendingPayments => _orders
    .where((order) => order.paymentStatus == PaymentStatus.pending)
    .fold(0.0, (sum, order) => sum + order.remainingAmount);
```

## Search & Filtering System

### Text Search
```dart
void searchOrders(String query) {
  _searchQuery = query.toLowerCase();
  _applyFilters();
}
```

### Status Filtering
```dart
void filterByStatus(OrderStatus? status) {
  _selectedStatusFilter = status;
  _applyFilters();
}
```

### Combined Filtering
```dart
void _applyFilters() {
  List<Order> filtered = _orders;

  // Apply search filter
  if (_searchQuery.isNotEmpty) {
    filtered = filtered.where((order) {
      return order.id.toLowerCase().contains(_searchQuery) ||
             order.customerId.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  // Apply status filter
  if (_selectedStatusFilter != null) {
    filtered = filtered.where((order) => order.status == _selectedStatusFilter).toList();
  }

  _filteredOrders = filtered;
  notifyListeners();
}
```

## Data Operations

### Loading Orders
```dart
Future<void> loadOrders({String? userId}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final querySnapshot = await _firebaseService.getCollection('orders');
    final orders = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Order.fromJson(data);
    }).toList();

    // Filter by user if specified (for customers)
    if (userId != null) {
      _orders = orders.where((order) => order.customerId == userId).toList();
    } else {
      _orders = orders;
    }

    _applyFilters();
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _errorMessage = 'Failed to load orders: $e';
    notifyListeners();
  }
}
```

### Real-time Streams
```dart
Stream<List<Order>> getOrdersStream({String? userId}) {
  return _firebaseService.collectionStream('orders').map((snapshot) {
    final orders = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Order.fromJson(data);
    }).toList();

    if (userId != null) {
      return orders.where((order) => order.customerId == userId).toList();
    }
    return orders;
  });
}
```

### Individual Order Operations
```dart
Future<Order?> getOrderById(String orderId)
Stream<Order?> getOrderStream(String orderId)
```

## Order Creation & Management

### Order Creation
```dart
Future<bool> createOrder({
  required String customerId,
  required List<OrderItem> items,
  required Map<String, dynamic> measurements,
  required String? specialInstructions,
  required List<String> orderImages,
})
```

**Order Creation Process:**
1. **Calculate Totals**: Sum all item prices
2. **Payment Structure**: 30% advance, 70% balance
3. **Default Timeline**: 7-day delivery window
4. **Data Validation**: Ensure all required fields
5. **Firebase Storage**: Save to Firestore collection

### Status Management
```dart
Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus)
```

**Status Update Process:**
1. **Validation**: Check status transition validity
2. **Timestamp Updates**: Record status change time
3. **Notification Triggers**: Alert relevant parties
4. **Audit Trail**: Log status change history

### Payment Processing
```dart
Future<bool> updatePaymentStatus(String orderId, PaymentStatus newStatus, {double? paidAmount})
```

**Payment Processing:**
1. **Amount Calculation**: Update advance/balance amounts
2. **Status Validation**: Ensure valid payment transitions
3. **Financial Tracking**: Update revenue calculations
4. **Customer Communication**: Send payment confirmations

## Analytics & Reporting

### Order Statistics
```dart
Map<String, dynamic> getOrderStatistics() {
  final now = DateTime.now();
  final thisMonth = DateTime(now.year, now.month, 1);
  final lastMonth = DateTime(now.year, now.month - 1, 1);

  final thisMonthOrders = _orders.where((order) => order.createdAt.isAfter(thisMonth)).toList();
  final lastMonthOrders = _orders.where((order) =>
      order.createdAt.isAfter(lastMonth) && order.createdAt.isBefore(thisMonth)).toList();

  return {
    'totalOrders': _orders.length,
    'thisMonthOrders': thisMonthOrders.length,
    'lastMonthOrders': lastMonthOrders.length,
    'pendingOrders': pendingOrders.length,
    'completedOrders': completedOrders.length,
    'totalRevenue': totalRevenue,
    'pendingPayments': pendingPayments,
    'averageOrderValue': _orders.isEmpty ? 0.0 : totalRevenue / _orders.length,
    'completionRate': _orders.isEmpty ? 0.0 : (completedOrders.length / _orders.length) * 100,
  };
}
```

### Business Metrics
- **Revenue Tracking**: Total and monthly revenue
- **Order Volume**: Monthly order comparisons
- **Payment Analytics**: Pending vs. completed payments
- **Performance Metrics**: Completion rates and averages

## Demo & Testing Features

### Demo Order Creation
```dart
Future<void> createDemoOrder(String customerId, Product product) async {
  final orderItem = OrderItem(
    id: 'demo-item-${DateTime.now().millisecondsSinceEpoch}',
    productId: product.id,
    productName: product.name,
    category: product.category.toString().split('.').last,
    price: product.basePrice,
    quantity: 1,
    customizations: {},
    notes: 'Demo order',
  );

  await createOrder(
    customerId: customerId,
    items: [orderItem],
    measurements: {
      'chest': '40',
      'waist': '32',
      'length': '28',
    },
    specialInstructions: 'Demo order for testing',
    orderImages: [],
  );
}
```

## Integration Points

### With Data Models
- **Order Model**: Core order data structure
  - Related: [`lib/models/order.dart`](../models/order.dart.md)
- **Customer Model**: Customer data integration
  - Related: [`lib/models/customer.dart`](../models/customer.dart.md)
- **Product Model**: Product catalog integration
  - Related: [`lib/models/product.dart`](../models/product.md)

### With Services
- **Firebase Service**: Data persistence and real-time updates
  - Related: [`lib/services/firebase_service.dart`](../services/firebase_service.md)
- **Order Notifications**: Status change notifications
  - Related: [`lib/services/order_notification_service.dart`](../services/order_notification_service.md)

### With UI Components
- **Order Dashboard**: Main order management interface
  - Related: [`lib/screens/orders/order_management_dashboard.dart`](../screens/orders/order_management_dashboard.md)
- **Order Creation**: Order placement workflow
  - Related: [`lib/screens/orders/order_creation_wizard.dart`](../screens/orders/order_creation_wizard.md)
- **Order Details**: Individual order tracking
  - Related: [`lib/screens/orders/order_details_screen.dart`](../screens/orders/order_details_screen.md)

### With Theme System
- **Theme Provider**: UI consistency with theming
  - Related: [`lib/providers/theme_provider.dart`](../providers/theme_provider.md)

## Error Handling

### Comprehensive Error Management
- **Firebase Errors**: Network and database errors
- **Validation Errors**: Data validation failures
- **Permission Errors**: Access control violations
- **State Errors**: Invalid state transitions

### Error Recovery
```dart
void clearError() {
  _errorMessage = null;
  notifyListeners();
}
```

## Performance Optimizations

### Efficient Data Loading
- **Lazy Loading**: Load data on demand
- **Pagination**: Handle large order lists
- **Caching**: Cache frequently accessed data
- **Background Updates**: Non-blocking operations

### Query Optimization
- **Indexed Queries**: Fast status and date filtering
- **Batch Operations**: Bulk status updates
- **Stream Optimization**: Efficient real-time updates

## Usage Examples

### Basic Order Loading
```dart
class OrderDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading) {
          return CircularProgressIndicator();
        }

        return ListView.builder(
          itemCount: orderProvider.orders.length,
          itemBuilder: (context, index) {
            final order = orderProvider.orders[index];
            return ListTile(
              title: Text('Order ${order.id}'),
              subtitle: Text(order.statusText),
              trailing: Text('\$${order.totalAmount}'),
            );
          },
        );
      },
    );
  }
}
```

### Order Creation
```dart
final orderProvider = Provider.of<OrderProvider>(context, listen: false);

final success = await orderProvider.createOrder(
  customerId: currentUserId,
  items: selectedItems,
  measurements: customerMeasurements,
  specialInstructions: 'Handle with care',
  orderImages: uploadedImages,
);

if (success) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Order created successfully!')),
  );
}
```

### Real-time Order Tracking
```dart
class OrderTracker extends StatelessWidget {
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Order?>(
      stream: context.read<OrderProvider>().getOrderStream(orderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final order = snapshot.data!;
        return Column(
          children: [
            Text('Order Status: ${order.statusText}'),
            LinearProgressIndicator(value: _getProgressValue(order.status)),
            Text('Estimated Delivery: ${order.deliveryDate ?? 'TBD'}'),
          ],
        );
      },
    );
  }

  double _getProgressValue(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 0.1;
      case OrderStatus.confirmed: return 0.2;
      case OrderStatus.inProgress: return 0.4;
      case OrderStatus.assigned: return 0.5;
      case OrderStatus.inProduction: return 0.7;
      case OrderStatus.qualityCheck: return 0.8;
      case OrderStatus.readyForFitting: return 0.9;
      case OrderStatus.completed: return 1.0;
      case OrderStatus.delivered: return 1.0;
      case OrderStatus.cancelled: return 0.0;
    }
  }
}
```

### Analytics Dashboard
```dart
class OrderAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final stats = orderProvider.getOrderStatistics();

    return Column(
      children: [
        Text('Total Orders: ${stats['totalOrders']}'),
        Text('This Month: ${stats['thisMonthOrders']}'),
        Text('Total Revenue: \$${stats['totalRevenue']}'),
        Text('Pending Payments: \$${stats['pendingPayments']}'),
        Text('Completion Rate: ${stats['completionRate']}%'),
      ],
    );
  }
}
```

## Firebase Integration

### Collection Structure
```
orders/
├── {orderId}/
│   ├── id: string
│   ├── customerId: string
│   ├── items: array
│   ├── status: number
│   ├── paymentStatus: number
│   ├── totalAmount: number
│   ├── advanceAmount: number
│   ├── remainingAmount: number
│   ├── orderDate: timestamp
│   ├── deliveryDate: timestamp
│   ├── specialInstructions: string
│   ├── measurements: object
│   ├── orderImages: array
│   ├── assignedEmployeeId: string
│   ├── assignedEmployeeName: string
│   ├── assignedAt: timestamp
│   ├── startedAt: timestamp
│   ├── completedAt: timestamp
│   ├── workAssignments: object
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
```

### Real-time Subscriptions
- **Order Status**: Live status updates
- **Payment Tracking**: Real-time payment processing
- **Assignment Updates**: Employee assignment notifications
- **Delivery Tracking**: Delivery status updates

## Security & Permissions

### Access Control
- **Role-Based Access**: Different permissions for different roles
- **Customer Isolation**: Customers only see their orders
- **Employee Assignment**: Employees see assigned orders
- **Manager Oversight**: Managers see all orders

### Data Validation
- **Order Integrity**: Validate order data before saving
- **Payment Security**: Secure payment processing
- **Status Validation**: Prevent invalid status transitions

## Future Enhancements

### Advanced Features
- **AI Matching**: Smart employee-order assignment
- **Predictive Analytics**: Delivery time predictions
- **Automated Scheduling**: Smart delivery date suggestions
- **Quality Prediction**: AI-powered quality assessment

### Integration Features
- **Calendar Integration**: External calendar synchronization
- **SMS Notifications**: Automated customer notifications
- **Payment Integration**: Multiple payment gateway support
- **Inventory Integration**: Real-time inventory updates

### Analytics Features
- **Performance Metrics**: Detailed productivity analytics
- **Customer Insights**: Advanced customer behavior analysis
- **Quality Metrics**: Comprehensive quality tracking
- **Financial Analytics**: Profitability and cost analysis

---

*This comprehensive OrderProvider serves as the central hub for order management in the AI-Enabled Tailoring Shop Management System, providing complete CRUD operations, real-time updates, advanced analytics, and seamless integration with Firebase for efficient order processing and business intelligence.*