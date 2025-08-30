# Order Provider Documentation

## Overview
The `order_provider.dart` file contains the comprehensive state management solution for order operations in the AI-Enabled Tailoring Shop Management System. It extends `ChangeNotifier` to provide reactive state management for order lifecycle, payment processing, filtering, and business analytics.

## Architecture

### Core Features
- **Order CRUD Operations**: Complete order lifecycle management
- **Advanced Filtering**: Multi-criteria search and status filtering
- **Payment Processing**: Comprehensive payment status tracking
- **Real-time Updates**: Stream-based live order synchronization
- **Business Analytics**: Order statistics and revenue tracking
- **Demo Data Generation**: Testing and demonstration support

### State Management
```dart
class OrderProvider with ChangeNotifier {
  // Core data
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];

  // UI state
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  OrderStatus? _selectedStatusFilter;
  String _searchQuery = '';
}
```

## Core Functionality

### Order Data Management

#### Loading Orders
```dart
Future<void> loadOrders({String? userId})
```
- Loads all orders from Firestore collection
- Supports customer-specific order filtering
- Applies current filters automatically
- Handles loading states and error management
- Updates UI through `notifyListeners()`

#### Real-time Order Stream
```dart
Stream<List<Order>> getOrdersStream({String? userId})
```
- Provides real-time updates when order data changes
- Supports customer-specific filtering
- Automatically maps Firestore documents to Order objects
- Enables reactive UI updates without manual polling

#### CRUD Operations
- **`createOrder()`**: Creates new order with automatic pricing calculations
- **`updateOrderStatus()`**: Updates order workflow status
- **`updatePaymentStatus()`**: Manages payment processing
- **`deleteOrder()`**: Removes orders with cascade cleanup

### Advanced Filtering System

#### Filter Types
- **Text Search**: Searches across order ID and customer ID
- **Status Filter**: Filters by order status (pending, in-progress, completed)
- **Customer Filter**: User-specific order views
- **Real-time Updates**: Filters apply to live data streams

#### Filter Implementation
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

### Payment Management

#### Payment Status Tracking
```dart
Future<bool> updatePaymentStatus(String orderId, PaymentStatus newStatus, {double? paidAmount})
```
- Updates payment status with flexible amount handling
- Supports partial payments and advance payments
- Automatically calculates remaining balances
- Tracks payment history and timestamps

#### Payment Calculations
- **Advance Payment**: 30% of total amount by default
- **Remaining Balance**: Automatic calculation after payments
- **Revenue Tracking**: Paid orders contribute to total revenue
- **Pending Payments**: Tracks outstanding balances

### Order Lifecycle Management

#### Status Transitions
```dart
Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus)
```
Supports complete order workflow:
- **Pending**: Initial order state
- **In Progress**: Work has begun
- **Completed**: Order finished and ready for delivery
- **Cancelled**: Order terminated

#### Delivery Management
```dart
Future<bool> updateDeliveryDate(String orderId, DateTime newDate)
```
- Flexible delivery date management
- Supports rush orders and extensions
- Tracks delivery commitments
- Updates customer expectations

### Business Analytics

#### Order Statistics
```dart
Map<String, dynamic> getOrderStatistics()
```
Comprehensive analytics including:
- **Order Counts**: Total, monthly, and status-based counts
- **Revenue Metrics**: Total revenue and pending payments
- **Performance Indicators**: Completion rates and averages
- **Trend Analysis**: Month-over-month comparisons

#### Computed Properties
```dart
// Real-time statistics
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

### Order Creation Workflow

#### Comprehensive Order Creation
```dart
Future<bool> createOrder({
  required String customerId,
  required List<OrderItem> items,
  required Map<String, dynamic> measurements,
  required String? specialInstructions,
  required List<String> orderImages,
})
```
- **Automatic Pricing**: Calculates totals from order items
- **Default Advance**: 30% advance payment requirement
- **Flexible Delivery**: 7-day default delivery window
- **Measurement Integration**: Links customer measurements
- **Image Support**: Order reference photos

#### Demo Order Generation
```dart
Future<void> createDemoOrder(String customerId, Product product)
```
- Creates realistic test orders
- Includes sample measurements and instructions
- Supports product catalog integration
- Useful for testing and demonstrations

## Firebase Integration

### Data Operations
- **Collection**: `orders` - Main order records
- **Real-time Streams**: Live updates for order changes
- **Document Relationships**: Links to customers and products
- **Timestamp Tracking**: Creation and update timestamps

### Data Flow
```dart
// Load orders with real-time updates
Stream<List<Order>> orderStream = getOrdersStream();

// Create new order with automatic calculations
await createOrder(
  customerId: 'customer_123',
  items: [orderItem],
  measurements: {'chest': '40', 'waist': '32'},
  specialInstructions: 'Rush order needed',
  orderImages: ['image_url_1', 'image_url_2'],
);

// Update order status with automatic UI refresh
await updateOrderStatus('order_456', OrderStatus.inProgress);
```

## Usage Examples

### Order Management Screen
```dart
class OrderManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading) {
          return CircularProgressIndicator();
        }

        return Column(
          children: [
            // Order Statistics
            Row(
              children: [
                Text('Total Orders: ${orderProvider.totalOrders}'),
                Text('Revenue: \$${orderProvider.totalRevenue}'),
                Text('Pending: ${orderProvider.pendingOrdersCount}'),
              ],
            ),

            // Order List
            Expanded(
              child: ListView.builder(
                itemCount: orderProvider.orders.length,
                itemBuilder: (context, index) {
                  final order = orderProvider.orders[index];
                  return ListTile(
                    title: Text('Order ${order.id}'),
                    subtitle: Text('${order.status} - \$${order.totalAmount}'),
                    trailing: Text('${order.remainingAmount} due'),
                    onTap: () => _viewOrderDetails(context, order),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
```

### Order Creation Form
```dart
class CreateOrderScreen extends StatefulWidget {
  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  Future<void> _createOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final success = await orderProvider.createOrder(
      customerId: widget.customerId,
      items: _selectedItems,
      measurements: _measurements,
      specialInstructions: _instructionsController.text,
      orderImages: _selectedImages,
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order created successfully!')),
      );
    }
  }
}
```

### Payment Processing
```dart
class PaymentScreen extends StatelessWidget {
  Future<void> _processPayment(BuildContext context, String orderId, double amount) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final success = await orderProvider.updatePaymentStatus(
      orderId,
      PaymentStatus.paid,
      paidAmount: amount,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment processed successfully!')),
      );
    }
  }
}
```

### Analytics Dashboard
```dart
class OrderAnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final stats = orderProvider.getOrderStatistics();

        return Column(
          children: [
            Text('Total Orders: ${stats['totalOrders']}'),
            Text('This Month: ${stats['thisMonthOrders']}'),
            Text('Last Month: ${stats['lastMonthOrders']}'),
            Text('Revenue: \$${stats['totalRevenue']}'),
            Text('Pending Payments: \$${stats['pendingPayments']}'),
            Text('Completion Rate: ${stats['completionRate']}%'),
            Text('Average Order Value: \$${stats['averageOrderValue']}'),
          ],
        );
      },
    );
  }
}
```

## Integration Points

### Related Components
- **Order Model**: Core data structure for order information
- **Customer Provider**: Customer data and relationship management
- **Product Provider**: Product catalog and pricing integration
- **Order Management Screens**: UI components for order operations
- **Payment Service**: External payment processing integration
- **Analytics Service**: Business intelligence and reporting

### Dependencies
- **Firebase Firestore**: Data persistence and real-time subscriptions
- **Cloud Firestore**: Timestamp handling and data relationships
- **Provider Package**: State management and dependency injection
- **Flutter Framework**: UI updates and reactive programming

## Performance Optimization

### Data Loading Strategies
- **Lazy Loading**: Load order details on demand
- **Pagination**: Handle large order lists efficiently
- **Caching**: Cache frequently accessed order data
- **Real-time Updates**: Efficient listeners for live data

### Query Optimization
- **Filtered Queries**: Apply filters before loading full datasets
- **Stream Optimization**: Efficient real-time data subscriptions
- **Batch Operations**: Minimize database round trips
- **Memory Management**: Clear unused data to reduce memory footprint

## Security Considerations

### Data Access Control
- **Customer Isolation**: Users can only access their own orders
- **Role-Based Access**: Different permissions for customers vs. staff
- **Order Privacy**: Secure handling of customer order data
- **Payment Security**: Secure payment information handling

### Data Validation
- **Order Validation**: Validate order data and business rules
- **Payment Validation**: Ensure payment amounts and status consistency
- **Date Validation**: Validate delivery dates and order timelines
- **Image Security**: Secure handling of order reference images

## Business Logic

### Order Processing Workflow
- **Order Creation**: Comprehensive order setup with automatic calculations
- **Status Management**: Clear workflow states with business rules
- **Payment Processing**: Flexible payment handling with advance requirements
- **Delivery Management**: Realistic delivery timeframes and adjustments

### Revenue Management
- **Advance Payments**: Configurable advance payment requirements
- **Revenue Tracking**: Real-time revenue calculations
- **Payment Status**: Clear payment state management
- **Outstanding Balance**: Automatic balance calculations

### Customer Experience
- **Order Visibility**: Customers can track their orders in real-time
- **Status Updates**: Clear communication of order progress
- **Payment Tracking**: Transparent payment status and amounts
- **Delivery Updates**: Accurate delivery date management

### Analytics and Insights
- **Performance Metrics**: Order completion rates and times
- **Revenue Analytics**: Monthly and overall revenue tracking
- **Customer Insights**: Order patterns and preferences
- **Business Intelligence**: Data-driven decision making

This comprehensive order provider serves as the central hub for all order-related operations, providing a robust foundation for order management in the tailoring shop system with real-time updates, comprehensive analytics, and seamless integration with the business workflow.