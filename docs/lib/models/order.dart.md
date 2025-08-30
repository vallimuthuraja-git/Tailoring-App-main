# Order Model

## Overview
The `order.dart` file defines the core data structures for order management in the AI-Enabled Tailoring Shop Management System. It provides comprehensive order lifecycle management with status tracking, payment processing, employee assignments, and complete serialization support for Firebase integration.

## Key Features

### Order Lifecycle Management
- **9 Status Levels**: Complete order workflow from pending to delivered
- **Payment Tracking**: Multi-stage payment processing with advance payments
- **Employee Assignment**: Work assignment and tracking system
- **Time Management**: Order dates, delivery dates, and completion tracking
- **Quality Assurance**: Built-in quality check workflow

### Advanced Business Logic
- **Status Color Coding**: Visual status indicators for quick recognition
- **Computed Properties**: Dynamic calculations for pricing and status
- **Extension Methods**: Business logic extensions for status management
- **Firebase Integration**: Complete serialization with type safety

## Architecture Components

### OrderStatus Enum

#### Complete Order Lifecycle (9 Statuses)
```dart
enum OrderStatus {
  pending,          // Order placed, awaiting confirmation
  confirmed,        // Order confirmed by shop
  inProgress,       // Order processing started
  assigned,         // Order assigned to specific employee
  inProduction,     // Employee actively working on order
  qualityCheck,     // Order under quality review
  readyForFitting,  // Order ready for customer fitting
  completed,        // Order completed and ready for delivery
  delivered,        // Order delivered to customer
  cancelled         // Order cancelled
}
```

#### Status Business Applications
- **pending**: Initial order state, awaiting shop confirmation
- **confirmed**: Order accepted, customer notified
- **inProgress**: Basic preparations and planning underway
- **assigned**: Specific employee assigned to handle the order
- **inProduction**: Active tailoring work in progress
- **qualityCheck**: Final inspection and quality assurance
- **readyForFitting**: Order completed, awaiting customer fitting
- **completed**: Final adjustments made, ready for delivery
- **delivered**: Order successfully delivered to customer
- **cancelled**: Order terminated (by customer or shop)

### OrderStatus Extension

#### Status Text Formatting
```dart
extension OrderStatusExtension on OrderStatus {
  String get statusText {
    switch (this) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.inProgress: return 'In Progress';
      case OrderStatus.assigned: return 'Assigned to Employee';
      case OrderStatus.inProduction: return 'In Production';
      case OrderStatus.qualityCheck: return 'Quality Check';
      case OrderStatus.readyForFitting: return 'Ready for Fitting';
      case OrderStatus.completed: return 'Completed';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
}
```

#### Status Color Coding
```dart
Color get statusColor {
  switch (this) {
    case OrderStatus.pending: return Colors.orange;
    case OrderStatus.confirmed: return Colors.blue;
    case OrderStatus.inProgress:
    case OrderStatus.assigned:
    case OrderStatus.inProduction: return Colors.purple;
    case OrderStatus.qualityCheck: return Colors.amber;
    case OrderStatus.readyForFitting: return Colors.teal;
    case OrderStatus.completed:
    case OrderStatus.delivered: return Colors.green;
    case OrderStatus.cancelled: return Colors.red;
  }
}
```

### PaymentStatus Enum

#### Payment Processing States
```dart
enum PaymentStatus {
  pending,    // Payment not yet received
  paid,       // Payment fully received
  failed,     // Payment processing failed
  refunded    // Payment refunded to customer
}
```

### Order Class

#### Core Order Properties
```dart
class Order {
  final String id;                           // Unique order identifier
  final String customerId;                   // Customer who placed the order
  final List<OrderItem> items;               // Products/services in the order
  final OrderStatus status;                  // Current order status
  final PaymentStatus paymentStatus;         // Current payment status
  final double totalAmount;                  // Total order value
  final double advanceAmount;                // Advance payment received
  final double remainingAmount;              // Remaining payment due
  final DateTime orderDate;                  // When order was placed
  final DateTime? deliveryDate;              // Promised delivery date
  final String? specialInstructions;         // Customer special requests
  final Map<String, dynamic> measurements;   // Customer measurements
  final List<String> orderImages;            // Order reference images
  final DateTime createdAt;                  // Order creation timestamp
  final DateTime updatedAt;                  // Last update timestamp
}
```

#### Employee Assignment Properties
```dart
final String? assignedEmployeeId;           // Assigned employee identifier
final String? assignedEmployeeName;         // Assigned employee name
final DateTime? assignedAt;                 // When order was assigned
final DateTime? startedAt;                  // When work began
final DateTime? completedAt;                // When work was completed
final Map<String, dynamic> workAssignments; // Detailed work assignments
```

### OrderItem Class

#### Individual Order Item Structure
```dart
class OrderItem {
  final String id;                           // Unique item identifier
  final String productId;                    // Reference to product/service
  final String productName;                  // Display name
  final String category;                     // Product category
  final double price;                        // Item price
  final int quantity;                        // Quantity ordered
  final Map<String, dynamic> customizations; // Selected customizations
  final String? notes;                       // Special notes for this item
}
```

## Order Workflow Management

### Order Status Transitions
```
Pending → Confirmed → In Progress → Assigned → In Production
     ↓                                              ↓
Cancelled                                    Quality Check
                                                  ↓
                                        Ready for Fitting → Completed → Delivered
```

### Employee Assignment Workflow
1. **Order Assignment**: Order assigned to specific employee
2. **Work Start**: Employee begins working on the order
3. **Progress Tracking**: Status updates throughout production
4. **Quality Assurance**: Order goes through quality check
5. **Completion**: Employee marks order as ready for fitting
6. **Delivery**: Final delivery to customer

### Payment Processing Workflow
1. **Advance Payment**: Initial payment (typically 30% of total)
2. **Progress Payments**: Additional payments at key milestones
3. **Final Payment**: Remaining balance before delivery
4. **Payment Tracking**: Complete payment history and status

## JSON Serialization

### Order Serialization
```dart
factory Order.fromJson(Map<String, dynamic> json) {
  return Order(
    id: json['id'],
    customerId: json['customerId'],
    items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
    status: OrderStatus.values[json['status']],
    paymentStatus: PaymentStatus.values[json['paymentStatus']],
    totalAmount: json['totalAmount'].toDouble(),
    advanceAmount: json['advanceAmount'].toDouble(),
    remainingAmount: json['remainingAmount'].toDouble(),
    orderDate: DateTime.parse(json['orderDate']),
    deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
    specialInstructions: json['specialInstructions'],
    measurements: Map<String, dynamic>.from(json['measurements'] ?? {}),
    orderImages: List<String>.from(json['orderImages'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    assignedEmployeeId: json['assignedEmployeeId'],
    assignedEmployeeName: json['assignedEmployeeName'],
    assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
    startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    workAssignments: Map<String, dynamic>.from(json['workAssignments'] ?? {}),
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'customerId': customerId,
    'items': items.map((item) => item.toJson()).toList(),
    'status': status.index,
    'paymentStatus': paymentStatus.index,
    'totalAmount': totalAmount,
    'advanceAmount': advanceAmount,
    'remainingAmount': remainingAmount,
    'orderDate': orderDate.toIso8601String(),
    'deliveryDate': deliveryDate?.toIso8601String(),
    'specialInstructions': specialInstructions,
    'measurements': measurements,
    'orderImages': orderImages,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'assignedEmployeeId': assignedEmployeeId,
    'assignedEmployeeName': assignedEmployeeName,
    'assignedAt': assignedAt?.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'workAssignments': workAssignments,
  };
}
```

### OrderItem Serialization
```dart
factory OrderItem.fromJson(Map<String, dynamic> json) {
  return OrderItem(
    id: json['id'],
    productId: json['productId'],
    productName: json['productName'],
    category: json['category'],
    price: json['price'].toDouble(),
    quantity: json['quantity'],
    customizations: Map<String, dynamic>.from(json['customizations'] ?? {}),
    notes: json['notes'],
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'productId': productId,
    'productName': productName,
    'category': category,
    'price': price,
    'quantity': quantity,
    'customizations': customizations,
    'notes': notes,
  };
}
```

## Business Logic

### Order Status Management
- **Sequential Processing**: Logical order status transitions
- **Employee Accountability**: Clear assignment and tracking
- **Quality Assurance**: Built-in quality check workflow
- **Customer Communication**: Status-driven notifications

### Financial Management
- **Advance Payment System**: Standard 30% advance payment
- **Payment Tracking**: Complete payment history
- **Outstanding Balance**: Real-time remaining payment calculation
- **Revenue Recognition**: Proper revenue tracking and reporting

### Time Management
- **Delivery Promises**: Realistic delivery date commitments
- **Progress Tracking**: Time-based status monitoring
- **SLA Management**: Service level agreement tracking
- **Performance Metrics**: Time-based performance analysis

### Customer Management
- **Measurement Integration**: Customer measurements for accurate tailoring
- **Special Instructions**: Customer-specific requirements
- **Order History**: Complete customer order tracking
- **Communication**: Order status and delivery updates

## Usage Examples

### Creating a New Order
```dart
final order = Order(
  id: 'order-001',
  customerId: 'customer-123',
  items: [
    OrderItem(
      id: 'item-001',
      productId: 'shirt-001',
      productName: 'Classic Cotton Shirt',
      category: 'Men\'s Wear',
      price: 1299.00,
      quantity: 2,
      customizations: {'collar': 'button_down', 'sleeve': 'full'},
      notes: 'Please ensure extra fabric for future alterations',
    ),
  ],
  status: OrderStatus.pending,
  paymentStatus: PaymentStatus.pending,
  totalAmount: 2598.00,
  advanceAmount: 779.40,  // 30% advance
  remainingAmount: 1818.60,
  orderDate: DateTime.now(),
  deliveryDate: DateTime.now().add(const Duration(days: 14)),
  specialInstructions: 'Customer prefers traditional stitching',
  measurements: {
    'chest': 40.0,
    'waist': 32.0,
    'shoulder': 18.0,
    'sleeveLength': 25.0,
  },
  orderImages: ['design-reference-001.jpg'],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### Order Status Update
```dart
// Update order status
final updatedOrder = Order(
  // ... existing order data
  status: OrderStatus.assigned,
  assignedEmployeeId: 'emp-001',
  assignedEmployeeName: 'Rajesh Kumar',
  assignedAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Save to Firebase
await firebaseService.updateDocument('orders', order.id, updatedOrder.toJson());
```

### Payment Processing
```dart
// Record payment
final paymentUpdate = {
  'paymentStatus': PaymentStatus.paid.index,
  'advanceAmount': 779.40,
  'remainingAmount': 1818.60,
  'updatedAt': DateTime.now().toIso8601String(),
};

await firebaseService.updateDocument('orders', order.id, paymentUpdate);
```

### Order Completion
```dart
// Mark order as completed
final completionUpdate = {
  'status': OrderStatus.completed.index,
  'completedAt': DateTime.now().toIso8601String(),
  'updatedAt': DateTime.now().toIso8601String(),
};

await firebaseService.updateDocument('orders', order.id, completionUpdate);
```

## Integration Points

### With Order Provider
- **State Management**: Order CRUD operations and real-time updates
  - Related: [`lib/providers/order_provider.dart`](../../providers/order_provider.md)
- **Status Management**: Order status transitions and validation
- **Search & Filtering**: Order discovery and filtering capabilities
- **Analytics**: Order statistics and business intelligence

### With Customer Provider
- **Customer Data**: Customer information and measurement integration
  - Related: [`lib/providers/customer_provider.dart`](../../providers/customer_provider.md)
- **Order History**: Customer order tracking and history
- **Loyalty Integration**: Customer loyalty tier calculations
- **Communication**: Customer notifications and updates

### With Product Provider
- **Product Information**: Product details and pricing integration
  - Related: [`lib/providers/product_provider.dart`](../../providers/product_provider.md)
- **Availability Checking**: Real-time product availability
- **Customization**: Product customization options and pricing
- **Inventory**: Product stock and availability management

### With Analytics Dashboard
- **Business Intelligence**: Order analytics and performance metrics
  - Related: [`lib/screens/dashboard/analytics_dashboard_screen.dart`](../../screens/dashboard/analytics_dashboard_screen.md)
- **Revenue Tracking**: Financial performance and trends
- **Customer Insights**: Customer behavior and preferences
- **Operational Metrics**: Order processing and delivery analytics

### With Order Management Screens
- **Order Details**: Comprehensive order information display
  - Related: [`lib/screens/orders/order_details_screen.dart`](../../screens/orders/order_details_screen.md)
- **Order History**: Customer order history and tracking
  - Related: [`lib/screens/orders/order_history_screen.dart`](../../screens/orders/order_history_screen.md)
- **Status Updates**: Real-time order status management
- **Employee Assignment**: Work assignment and tracking

## Performance Considerations

### Data Efficiency
- **Indexed Enums**: Status enums stored as integers for query performance
- **Optimized Lists**: Efficient handling of order items and images
- **Timestamp Management**: ISO string format for Firebase compatibility
- **Lazy Loading**: On-demand related data loading

### Real-time Updates
- **Stream Optimization**: Efficient Firebase real-time listeners
- **Batch Operations**: Bulk status updates for performance
- **Memory Management**: Efficient state management
- **Caching Strategy**: Order data caching for performance

## Future Enhancements

### Advanced Order Management
- **Order Templates**: Pre-configured order templates
- **Bulk Operations**: Mass order status and payment updates
- **Order Scheduling**: Advanced delivery date management
- **Quality Assurance**: Automated quality check workflows

### Payment Integration
- **Payment Gateway**: Integrated payment processing
- **Multi-currency**: Support for multiple currencies
- **Payment Plans**: Flexible payment installment options
- **Tax Calculation**: Automated tax computation and reporting

### Customer Experience
- **Order Tracking**: Real-time GPS delivery tracking
- **Customer Portal**: Self-service order management
- **Feedback System**: Post-delivery customer feedback
- **Reorder Functionality**: Easy order duplication

### Analytics & Intelligence
- **Predictive Analytics**: Delivery time estimation
- **Demand Forecasting**: Order volume prediction
- **Customer Insights**: Purchase behavior analysis
- **Performance Optimization**: Automated workflow optimization

---

*This Order model serves as the comprehensive data foundation for the tailoring shop's order management system, providing robust data structures, business logic, and integration capabilities that support the complete order lifecycle from creation to delivery and analytics.*