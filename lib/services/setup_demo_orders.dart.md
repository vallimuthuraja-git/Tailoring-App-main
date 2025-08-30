# Demo Orders Setup Service Documentation

## Overview
The `setup_demo_orders.dart` file contains the comprehensive demo data generation service for orders in the AI-Enabled Tailoring Shop Management System. It provides automated creation of realistic customer orders, work assignments, and order lifecycle data for development, testing, and demonstration purposes.

## Architecture

### Core Components
- **`SetupDemoOrders`**: Main demo setup service class
- **Demo Customers**: 5 realistic Indian customer profiles
- **Demo Employees**: 4 specialized employee profiles
- **Order Templates**: 8 diverse order scenarios
- **Provider Integration**: Seamless integration with Product and Order providers
- **Lifecycle Management**: Complete order lifecycle simulation

### Key Features
- **Realistic Customer Data**: Indian names, phone numbers, and Bangalore addresses
- **Diverse Product Categories**: Men's wear, women's wear, kids wear, traditional wear, alterations
- **Order Status Progression**: Complete order lifecycle from pending to completed
- **Work Assignment Integration**: Automatic employee assignment and progress tracking
- **Measurement Data**: Realistic body measurements for different garment types
- **Customization Details**: Fabric choices, colors, styles, and special requirements
- **Time-based Scenarios**: Orders with different ages and delivery timelines

## Demo Data Structure

### Demo Customers
```dart
final List<Map<String, dynamic>> _demoCustomers = [
  {
    'id': 'demo-customer-1',
    'name': 'Rajesh Kumar',
    'email': 'rajesh.kumar@email.com',
    'phone': '+91-9876543210',
    'address': '123 MG Road, Bangalore, Karnataka - 560001'
  },
  // ... 4 more customers with different Bangalore addresses
];
```
- **Regional Focus**: Bangalore-based customers reflecting local market
- **Contact Information**: Realistic Indian phone numbers and email addresses
- **Diverse Demographics**: Mix of male and female customers

### Demo Employees
```dart
final List<Map<String, dynamic>> _demoEmployees = [
  {
    'id': 'demo-employee-1',
    'name': 'Ravi Tailor',
    'specialization': 'Suits & Formal Wear'
  },
  {
    'id': 'demo-employee-2', 
    'name': 'Meera Stitching',
    'specialization': 'Sarees & Traditional Wear'
  },
  {
    'id': 'demo-employee-3',
    'name': 'Kiran Alterations',
    'specialization': 'Alterations & Repairs'
  },
  {
    'id': 'demo-employee-4',
    'name': 'Suresh Designer',
    'specialization': 'Custom Design'
  }
];
```
- **Specialized Roles**: Each employee has specific area of expertise
- **Realistic Names**: Indian names appropriate for tailoring professions
- **Skill Distribution**: Covers major tailoring service categories

## Order Templates

### 1. Custom Business Suit
```dart
{
  'customerIndex': 0,
  'productType': ProductCategory.mensWear,
  'productName': 'Custom Business Suit',
  'customizations': {
    'fabric': 'Premium Wool Blend',
    'color': 'Navy Blue',
    'fit': 'Slim Fit',
    'style': 'Two-piece'
  },
  'measurements': {
    'chest': '42', 'waist': '34', 'length': '30',
    'shoulder': '18', 'sleeve': '25'
  },
  'specialInstructions': 'Customer wants double stitching for durability',
  'status': OrderStatus.confirmed,
  'assignedEmployee': 0,
  'daysAgo': 2
}
```
- **Business Formal**: Corporate wear order
- **Premium Fabric**: Wool blend with quality requirements
- **Detailed Measurements**: Complete suit measurements
- **Status**: Recently confirmed, assigned to tailor

### 2. Designer Wedding Lehenga
```dart
{
  'customerIndex': 1,
  'productType': ProductCategory.womensWear,
  'productName': 'Designer Wedding Lehenga',
  'customizations': {
    'fabric': 'Heavy Banarasi Silk',
    'color': 'Maroon with Gold',
    'embroidery': 'Heavy Zari Work',
    'dupatta': 'Matching Net Dupatta'
  },
  'measurements': {
    'bust': '36', 'waist': '28', 'hips': '38',
    'length': '42', 'blouse_size': 'M'
  },
  'specialInstructions': 'Urgent wedding order. Premium quality work.',
  'status': OrderStatus.inProduction,
  'assignedEmployee': 1,
  'daysAgo': 5
}
```
- **Wedding Wear**: High-value traditional garment
- **Luxury Materials**: Banarasi silk with heavy embroidery
- **Urgent Timeline**: Wedding deadline pressure
- **Status**: In production with traditional wear specialist

### 3. School Uniform Set
```dart
{
  'customerIndex': 2,
  'productType': ProductCategory.kidsWear,
  'productName': 'School Uniform Set',
  'quantity': 3,
  'customizations': {
    'fabric': 'Cotton Blend',
    'color': 'Navy Blue with White',
    'logo': 'School Emblem'
  },
  'measurements': {
    'chest': '32', 'waist': '30', 'length': '24',
    'age': '12 years'
  },
  'specialInstructions': 'School uniform for 3 children. School logo needed.',
  'status': OrderStatus.qualityCheck,
  'assignedEmployee': 2,
  'daysAgo': 7
}
```
- **Bulk Order**: Multiple items for family
- **Institutional**: School branding requirements
- **Children's Sizes**: Age-appropriate measurements
- **Status**: Quality check phase

### 4. Suit Alteration
```dart
{
  'customerIndex': 3,
  'productType': ProductCategory.alterations,
  'productName': 'Suit Alteration',
  'customizations': {
    'alteration_type': 'Full Suit Alteration',
    'original_size': '44',
    'new_size': '42'
  },
  'specialInstructions': 'Customer lost weight, needs suit taken in.',
  'status': OrderStatus.completed,
  'assignedEmployee': 2,
  'daysAgo': 10
}
```
- **Alteration Service**: Size adjustment order
- **Completed Order**: Shows finished work example
- **Size Changes**: Weight loss adjustment scenario
- **Quick Service**: Alterations specialist assignment

### 5. Corporate Blazer
```dart
{
  'customerIndex': 4,
  'productType': ProductCategory.formalWear,
  'productName': 'Corporate Blazer',
  'customizations': {
    'fabric': 'Premium Polyester',
    'buttons': 'Brass Company Buttons',
    'pocket': 'Company Logo Embroidery'
  },
  'specialInstructions': 'Corporate order with company branding.',
  'status': OrderStatus.assigned,
  'assignedEmployee': 0,
  'daysAgo': 1
}
```
- **Corporate Wear**: Business attire with branding
- **Company Identity**: Logo embroidery requirements
- **Premium Materials**: Professional quality specifications
- **Status**: Recently assigned to formal wear specialist

### 6. Festival Kurta Set
```dart
{
  'customerIndex': 0,
  'productType': ProductCategory.traditionalWear,
  'productName': 'Festival Kurta Set',
  'quantity': 2,
  'customizations': {
    'fabric': 'Cotton with Silk Border',
    'color': 'Cream with Gold Border',
    'style': 'Straight Kurta with Pajama'
  },
  'specialInstructions': 'Festival season order. Delivery before Diwali.',
  'status': OrderStatus.pending,
  'assignedEmployee': null,
  'daysAgo': 0
}
```
- **Seasonal Wear**: Festival-specific traditional clothing
- **Bulk Purchase**: Multiple items for family
- **Cultural Context**: Diwali festival deadline
- **Status**: New order, not yet assigned

### 7. Casual Shirt Collection
```dart
{
  'customerIndex': 2,
  'productType': ProductCategory.casualWear,
  'productName': 'Casual Shirt Collection',
  'quantity': 5,
  'customizations': {
    'fabric': 'Cotton Poplin',
    'colors': 'White, Light Blue, Grey',
    'style': 'Slim Fit Casual Shirts'
  },
  'specialInstructions': 'Bulk order for office casual wear.',
  'status': OrderStatus.confirmed,
  'assignedEmployee': 3,
  'daysAgo': 3
}
```
- **Bulk Business Order**: Multiple casual shirts
- **Color Variety**: Multiple color options
- **Office Wear**: Professional casual specifications
- **Status**: Confirmed with custom design specialist

### 8. Designer Dress
```dart
{
  'customerIndex': 1,
  'productType': ProductCategory.customDesign,
  'productName': 'Designer Dress',
  'customizations': {
    'fabric': 'Chiffon with Net Overlay',
    'color': 'Emerald Green',
    'embellishments': 'Crystal Work'
  },
  'specialInstructions': 'Custom design based on customer sketch.',
  'status': OrderStatus.inProduction,
  'assignedEmployee': 3,
  'daysAgo': 8
}
```
- **Custom Design**: High-end bespoke creation
- **Luxury Materials**: Chiffon with crystal embellishments
- **Creative Process**: Customer sketch-based design
- **Status**: In production with design specialist

## Setup Process

### Main Setup Method
```dart
Future<void> createDemoOrders({
  required ProductProvider productProvider,
  required OrderProvider orderProvider
}) async {
  // 1. Ensure products are loaded
  await productProvider.loadProducts();
  if (productProvider.products.isEmpty) {
    await productProvider.loadDemoData();
  }

  // 2. Create demo customers
  await _createDemoCustomers();

  // 3. Create demo orders from templates
  for (int i = 0; i < _demoOrderTemplates.length; i++) {
    final template = _demoOrderTemplates[i];
    await _createDemoOrder(template, productProvider, orderProvider, i);
  }
}
```

### Customer Creation
```dart
Future<void> _createDemoCustomers() async {
  for (final customer in _demoCustomers) {
    await _firestore.collection('customers').doc(customer['id']).set({
      ...customer,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
```

### Order Creation Process
```dart
Future<void> _createDemoOrder(
  Map<String, dynamic> template,
  ProductProvider productProvider,
  OrderProvider orderProvider,
  int index
) async {
  // 1. Get customer and find suitable product
  final customer = _demoCustomers[template['customerIndex']];
  final product = _findSuitableProduct(template, productProvider);

  // 2. Create order item with customizations
  final orderItem = OrderItem(
    id: 'demo-item-$index',
    productId: product.id,
    productName: template['productName'],
    category: product.category.toString().split('.').last,
    price: product.basePrice,
    quantity: template['quantity'],
    customizations: template['customizations'],
    notes: template['specialInstructions']
  );

  // 3. Calculate pricing and dates
  final totalAmount = orderItem.price * orderItem.quantity;
  final advanceAmount = totalAmount * 0.3; // 30% advance
  final remainingAmount = totalAmount - advanceAmount;

  final daysAgo = template['daysAgo'] as int;
  final orderDate = DateTime.now().subtract(Duration(days: daysAgo));
  final deliveryDate = orderDate.add(const Duration(days: 7));

  // 4. Create complete order with work assignments
  final order = Order(
    id: '',
    customerId: customer['id'],
    items: [orderItem],
    status: template['status'],
    paymentStatus: PaymentStatus.paid,
    totalAmount: totalAmount,
    advanceAmount: advanceAmount,
    remainingAmount: remainingAmount,
    orderDate: orderDate,
    deliveryDate: deliveryDate,
    specialInstructions: template['specialInstructions'],
    measurements: template['measurements'],
    orderImages: [],
    createdAt: orderDate,
    updatedAt: orderDate,
    // Work assignment details if employee assigned
    assignedEmployeeId: template['assignedEmployee'] != null
        ? _demoEmployees[template['assignedEmployee']]['id']
        : null,
    assignedEmployeeName: template['assignedEmployee'] != null
        ? _demoEmployees[template['assignedEmployee']]['name']
        : null,
    // ... additional assignment details
  );

  // 5. Save to Firestore and update customer
  final orderData = order.toJson();
  orderData.remove('id');
  final docRef = await _firestore.collection('orders').add(orderData);

  // 6. Add order reference to customer
  await _firestore.collection('customers').doc(customer['id']).update({
    'orderIds': FieldValue.arrayUnion([docRef.id])
  });
}
```

## Helper Functions

### Work Status Mapping
```dart
String _getWorkStatus(OrderStatus orderStatus) {
  switch (orderStatus) {
    case OrderStatus.assigned:
      return 'assigned';
    case OrderStatus.inProduction:
      return 'in_progress';
    case OrderStatus.qualityCheck:
      return 'quality_check';
    case OrderStatus.completed:
      return 'completed';
    case OrderStatus.readyForFitting:
      return 'ready_for_fitting';
    default:
      return 'pending';
  }
}
```

### Estimated Hours Calculation
```dart
int _getEstimatedHours(ProductCategory category) {
  switch (category) {
    case ProductCategory.mensWear:
    case ProductCategory.formalWear:
      return 24; // 3 work days
    case ProductCategory.womensWear:
    case ProductCategory.traditionalWear:
      return 32; // 4 work days
    case ProductCategory.kidsWear:
      return 8;  // 1 work day
    case ProductCategory.casualWear:
      return 12; // 1.5 work days
    case ProductCategory.alterations:
      return 6;  // Half day
    case ProductCategory.customDesign:
      return 48; // 6 work days
  }
}
```

### Progress Calculation
```dart
int _getProgressForStatus(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 0;
    case OrderStatus.confirmed:
      return 10;
    case OrderStatus.assigned:
      return 25;
    case OrderStatus.inProgress:
      return 50;
    case OrderStatus.inProduction:
      return 60;
    case OrderStatus.qualityCheck:
      return 85;
    case OrderStatus.readyForFitting:
      return 95;
    case OrderStatus.completed:
    case OrderStatus.delivered:
      return 100;
    case OrderStatus.cancelled:
      return 0;
  }
}
```

## Initialization and Management

### Demo Data Check
```dart
Future<bool> demoOrdersExist() async {
  final querySnapshot = await _firestore.collection('orders').get();
  return querySnapshot.docs.any((doc) => doc.id.startsWith('demo-order-'));
}
```

### Conditional Setup
```dart
Future<void> initializeDemoOrdersIfNeeded({
  required ProductProvider productProvider,
  required OrderProvider orderProvider
}) async {
  final ordersExist = await demoOrdersExist();
  if (!ordersExist) {
    await createDemoOrders(
      productProvider: productProvider,
      orderProvider: orderProvider
    );
  }
}
```

## Integration Points

### Related Components
- **Product Provider**: Product catalog and pricing integration
- **Order Provider**: Order management and state handling
- **Customer Model**: Customer data structure
- **Order Model**: Order lifecycle and data structure
- **Firebase Service**: Database operations and connectivity

### Dependencies
- **Firebase Firestore**: Order and customer data persistence
- **Flutter Foundation**: Date/time handling and async operations
- **Product Model**: Product category and pricing structure
- **Order Model**: Order status and lifecycle management

## Usage Examples

### Development Setup
```dart
class DevelopmentSetup {
  final SetupDemoOrders _demoOrders = SetupDemoOrders();

  Future<void> initializeDemoEnvironment() async {
    try {
      // Initialize providers
      final productProvider = ProductProvider();
      final orderProvider = OrderProvider();

      // Setup demo data
      await _demoOrders.createDemoOrders(
        productProvider: productProvider,
        orderProvider: orderProvider
      );

      debugPrint('✅ Demo environment ready!');
    } catch (e) {
      debugPrint('❌ Demo setup failed: $e');
    }
  }
}
```

### Testing Integration
```dart
class OrderProviderTests {
  final SetupDemoOrders _demoSetup = SetupDemoOrders();

  Future<void> testOrderCreation() async {
    final productProvider = ProductProvider();
    final orderProvider = OrderProvider();

    // Setup demo orders
    await _demoSetup.createDemoOrders(
      productProvider: productProvider,
      orderProvider: orderProvider
    );

    // Test order loading
    await orderProvider.loadOrders();
    final orders = orderProvider.orders;

    // Verify demo orders exist
    assert(orders.length >= 8, 'Demo orders not created');
    assert(orders.any((o) => o.customerId.startsWith('demo-customer-')),
        'Demo customers not linked');

    debugPrint('✅ Order creation tests passed!');
  }
}
```

### Quick Demo Setup
```dart
class DemoButton extends StatelessWidget {
  final SetupDemoOrders _demoSetup = SetupDemoOrders();

  Future<void> _setupDemoOrders(BuildContext context) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    await _demoSetup.createDemoOrders(
      productProvider: productProvider,
      orderProvider: orderProvider
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Demo orders created!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _setupDemoOrders(context),
      child: Text('Create Demo Orders'),
    );
  }
}
```

## Business Logic

### Realistic Order Scenarios
- **Business Suits**: Corporate professional wear with quality requirements
- **Wedding Lehenga**: High-value traditional wear with urgent timelines
- **School Uniforms**: Bulk orders with institutional branding
- **Alterations**: Size adjustments and garment modifications
- **Corporate Wear**: Business attire with company branding
- **Festival Wear**: Seasonal traditional clothing
- **Casual Collections**: Bulk casual wear orders
- **Custom Designs**: High-end bespoke creation services

### Order Lifecycle Simulation
- **Time-based Creation**: Orders created with different ages
- **Status Progression**: Realistic order status advancement
- **Work Assignment**: Proper employee assignment and tracking
- **Progress Tracking**: Realistic progress percentages
- **Delivery Dates**: Appropriate timelines for different garment types

### Customer Diversity
- **Regional Focus**: Bangalore-based customers
- **Order Variety**: Different product categories and budgets
- **Timeline Diversity**: Various delivery requirements
- **Complexity Range**: Simple alterations to complex custom designs

This comprehensive demo order setup service provides developers and testers with realistic, diverse order data that accurately represents a tailoring shop's operations, enabling comprehensive testing of order management, work assignment, and customer service features.