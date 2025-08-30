# Order Details Screen

## Overview
The `order_details_screen.dart` file implements a comprehensive order details interface for the AI-Enabled Tailoring Shop Management System. It provides detailed order information with role-based functionality, allowing shop owners to manage order status, payments, and delivery dates, while giving customers access to their order details and communication tools.

## Key Features

### Comprehensive Order Information
- **Order Status Tracking**: Visual status indicators with color coding
- **Payment Management**: Advance payment and remaining balance tracking
- **Customer Measurements**: Detailed measurement display with visual chips
- **Special Instructions**: Customer-specific requirements and notes
- **Order Images**: Photo attachments with zoom functionality

### Role-Based Functionality
- **Shop Owner Features**: Full order management and status updates
- **Customer Features**: Order tracking and communication tools
- **Permission-Based UI**: Dynamic interface based on user role
- **Secure Operations**: Protected administrative functions

### Advanced Order Management
- **Status Updates**: Comprehensive order status lifecycle management
- **Payment Tracking**: Multi-stage payment processing
- **Delivery Management**: Date scheduling and tracking
- **Order Modification**: Dynamic order information updates

## Architecture Components

### Main Widget Structure

#### OrderDetailsScreen Widget
```dart
class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}
```

#### State Management
```dart
class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<OrderProvider, AuthProvider>(
      builder: (context, orderProvider, authProvider, child) {
        final isShopOwner = authProvider.isShopOwnerOrAdmin;
        final order = widget.order;

        return Scaffold(
          appBar: _buildAppBar(order, isShopOwner, orderProvider),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildStatusCard(order),
                _buildOrderItems(order),
                _buildPricingCard(order),
                _buildMeasurementsCard(order),
                if (order.specialInstructions != null) _buildInstructionsCard(order),
                if (order.orderImages.isNotEmpty) _buildImagesCard(order),
                _buildActionButtons(orderProvider, authProvider, order),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### App Bar with Role-Based Actions
```dart
AppBar(
  title: Text('Order #${order.id.substring(0, 8).toUpperCase()}'),
  actions: [
    if (isShopOwner) ...[
      PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(context, value, orderProvider, order),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'update_status',
            child: Text('Update Status'),
          ),
          const PopupMenuItem(
            value: 'update_payment',
            child: Text('Update Payment'),
          ),
          const PopupMenuItem(
            value: 'update_delivery',
            child: Text('Update Delivery Date'),
          ),
        ],
      ),
    ],
  ],
)
```

## Order Information Cards

### Status Card Implementation
```dart
Widget _buildStatusCard(Order order) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${_getStatusText(order.status)}'),
                    Text(
                      'Payment: ${_getPaymentStatusText(order.paymentStatus)}',
                      style: TextStyle(
                        color: order.paymentStatus == PaymentStatus.paid
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    Text(
                      'Ordered: ${_formatDate(order.orderDate)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (order.deliveryDate != null)
                      Text(
                        'Delivery: ${_formatDate(order.deliveryDate!)}',
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                  ],
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
        ],
      ),
    ),
  );
}
```

### Order Items Display
```dart
Widget _buildOrderItems(Order order) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${item.category} • Quantity: ${item.quantity}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          if (item.notes != null && item.notes!.isNotEmpty)
                            Text(
                              'Notes: ${item.notes}',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ),
  );
}
```

### Pricing Card with Payment Tracking
```dart
Widget _buildPricingCard(Order order) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _PricingRow('Subtotal', '₹${order.totalAmount.toStringAsFixed(0)}'),
          const Divider(),
          _PricingRow('Advance Payment (30%)', '₹${order.advanceAmount.toStringAsFixed(0)}',
              color: Colors.green),
          _PricingRow('Remaining Amount', '₹${order.remainingAmount.toStringAsFixed(0)}',
              color: order.remainingAmount > 0 ? Colors.orange : Colors.green),
          const Divider(),
          _PricingRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(0)}',
              isBold: true, fontSize: 18),
        ],
      ),
    ),
  );
}
```

### Measurements Display
```dart
Widget _buildMeasurementsCard(Order order) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Measurements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (order.measurements.isEmpty)
            const Text(
              'No measurements provided',
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: order.measurements.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key}: ${entry.value}'),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                );
              }).toList(),
            ),
        ],
      ),
    ),
  );
}
```

### Special Instructions Card
```dart
Widget _buildInstructionsCard(Order order) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Special Instructions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            order.specialInstructions!,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    ),
  );
}
```

### Order Images Gallery
```dart
Widget _buildImagesCard(Order order) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Images',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: order.orderImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _showImageDialog(context, order.orderImages[index]),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(order.orderImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
```

## Management Dialogs

### Status Update Dialog
```dart
void _showStatusUpdateDialog(BuildContext context, OrderProvider orderProvider, Order order) {
  OrderStatus? selectedStatus = order.status;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderStatus.values.map((status) {
            return RadioListTile<OrderStatus>(
              title: Text(_getStatusText(status)),
              value: status,
              groupValue: selectedStatus,
              onChanged: (value) => setState(() => selectedStatus = value),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: selectedStatus != null && selectedStatus != order.status
                ? () async {
                    Navigator.of(context).pop();
                    await orderProvider.updateOrderStatus(order.id, selectedStatus!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order status updated!')),
                    );
                  }
                : null,
            child: const Text('Update'),
          ),
        ],
      ),
    ),
  );
}
```

### Payment Update Dialog
```dart
void _showPaymentUpdateDialog(BuildContext context, OrderProvider orderProvider, Order order) {
  PaymentStatus? selectedStatus = order.paymentStatus;
  final amountController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Update Payment Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...PaymentStatus.values.map((status) {
              return RadioListTile<PaymentStatus>(
                title: Text(_getPaymentStatusText(status)),
                value: status,
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value),
              );
            }),
            if (selectedStatus == PaymentStatus.paid) ...[
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount Paid',
                  hintText: 'Enter amount',
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: selectedStatus != null
                ? () async {
                    Navigator.of(context).pop();
                    final amount = amountController.text.isEmpty
                        ? null
                        : double.tryParse(amountController.text);
                    await orderProvider.updatePaymentStatus(
                      order.id,
                      selectedStatus!,
                      paidAmount: amount,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment status updated!')),
                    );
                  }
                : null,
            child: const Text('Update'),
          ),
        ],
      ),
    ),
  );
}
```

### Delivery Date Update
```dart
void _showDeliveryUpdateDialog(BuildContext context, OrderProvider orderProvider, Order order) {
  DateTime selectedDate = order.deliveryDate ?? DateTime.now().add(const Duration(days: 7));

  showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  ).then((date) async {
    if (date != null) {
      await orderProvider.updateDeliveryDate(order.id, date);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery date updated!')),
      );
    }
  });
}
```

## Visual Components

### Status Badge
```dart
class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
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

### Pricing Row Component
```dart
class _PricingRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isBold;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
```

## Action Buttons

### Customer Action Buttons
```dart
Widget _buildActionButtons(BuildContext context, OrderProvider orderProvider,
    AuthProvider authProvider, Order order) {
  final isShopOwner = authProvider.isShopOwnerOrAdmin;

  if (!isShopOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Contact shop owner
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chat with shop owner coming soon!')),
            );
          },
          icon: const Icon(Icons.chat),
          label: const Text('Contact Shop Owner'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        if (order.remainingAmount > 0)
          ElevatedButton.icon(
            onPressed: () {
              // Make payment
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment feature coming soon!')),
              );
            },
            icon: const Icon(Icons.payment),
            label: Text('Pay Remaining ₹${order.remainingAmount.toStringAsFixed(0)}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
      ],
    );
  }

  return const SizedBox.shrink();
}
```

## Utility Functions

### Status Text Formatting
```dart
String _getStatusText(OrderStatus status) {
  return status.toString().split('.').last.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => ' ${match.group(1)}',
      ).trim();
}

String _getPaymentStatusText(PaymentStatus status) {
  return status.toString().split('.').last;
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
```

### Image Dialog
```dart
void _showImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: InteractiveViewer(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) =>
              const Text('Failed to load image'),
        ),
      ),
    ),
  );
}
```

## Menu Action Handler
```dart
void _handleMenuAction(BuildContext context, String action, OrderProvider orderProvider, Order order) {
  switch (action) {
    case 'update_status':
      _showStatusUpdateDialog(context, orderProvider, order);
      break;
    case 'update_payment':
      _showPaymentUpdateDialog(context, orderProvider, order);
      break;
    case 'update_delivery':
      _showDeliveryUpdateDialog(context, orderProvider, order);
      break;
  }
}
```

## Integration Points

### With Order Provider
- **Data Management**: Centralized order data handling
  - Related: [`lib/providers/order_provider.dart`](../../providers/order_provider.md)
- **Status Updates**: Real-time order status synchronization
- **Payment Tracking**: Payment status and amount management
- **Delivery Management**: Date scheduling and updates

### With Authentication Provider
- **User Context**: Role-based access and UI adaptation
  - Related: [`lib/providers/auth_provider.dart`](../../providers/auth_provider.md)
- **Permission Validation**: Shop owner vs customer features
- **Session Management**: Secure user context handling

### With Navigation System
- **Screen Transitions**: Seamless navigation from order list
- **State Preservation**: Maintain order context during updates
- **Deep Linking**: Direct access to specific orders
- **Back Navigation**: Proper navigation stack management

## User Experience Features

### Information Hierarchy
```
Order Header (ID, Status)
├── Order Status Card
│   ├── Current Status
│   ├── Payment Status
│   ├── Order Date
│   └── Delivery Date
├── Order Items Card
│   ├── Product Details
│   ├── Quantities
│   └── Item Notes
├── Pricing Card
│   ├── Subtotal
│   ├── Advance Payment
│   ├── Remaining Amount
│   └── Total Amount
├── Measurements Card
│   └── Customer Measurements
├── Special Instructions
└── Order Images
```

### Shop Owner Workflow
```
Order Management
├── View Complete Details
├── Update Order Status
│   ├── Pending → Confirmed
│   ├── Confirmed → In Progress
│   ├── In Progress → Ready for Fitting
│   ├── Ready for Fitting → Completed
│   └── Completed → Delivered
├── Update Payment Status
│   ├── Track Payments
│   ├── Record Amounts
│   └── Update Balances
└── Update Delivery Date
    ├── Schedule Delivery
    ├── Update Estimates
    └── Track Changes
```

### Customer Experience
```
Order Tracking
├── View Order Details
├── Check Status Updates
├── Review Measurements
├── View Special Instructions
├── Contact Shop Owner
└── Make Remaining Payments
```

## Performance Optimizations

### Efficient Rendering
- **Conditional Card Display**: Only show relevant information
- **Lazy Image Loading**: Network images with loading states
- **Minimal Rebuilds**: Targeted widget updates
- **Memory Management**: Proper resource disposal

### State Management
- **Provider Integration**: Centralized state access
- **Real-time Updates**: Live data synchronization
- **Optimistic Updates**: Immediate UI feedback
- **Error Handling**: Graceful failure management

## Future Enhancements

### Advanced Features
- **Real-time Updates**: Live order status notifications
- **Order History**: Complete order timeline tracking
- **Quality Assurance**: Photo uploads for quality checks
- **Customer Communication**: Integrated messaging system

### Integration Features
- **Payment Gateway**: Direct payment processing
- **Calendar Integration**: Delivery scheduling sync
- **Notification System**: Automated status alerts
- **Analytics Integration**: Order performance metrics

### User Experience
- **Order Comparison**: Side-by-side order viewing
- **Bulk Operations**: Mass order status updates
- **Advanced Search**: Order filtering and search
- **Export Capabilities**: Order data export options

---

*This Order Details Screen serves as the comprehensive order management hub for the tailoring shop system, providing detailed order information with powerful management tools for shop owners and a transparent tracking experience for customers, ensuring smooth communication and efficient order processing throughout the entire order lifecycle.*