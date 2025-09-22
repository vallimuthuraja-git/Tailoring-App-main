import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';
import '../models/product_models.dart';
import '../product_data_access.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';

class SetupDemoOrders {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Demo customers data
  final List<Map<String, dynamic>> _demoCustomers = [
    {
      'id': 'demo-customer-1',
      'name': 'Rajesh Kumar',
      'email': 'rajesh.kumar@email.com',
      'phone': '+91-9876543210',
      'address': '123 MG Road, Bangalore, Karnataka - 560001'
    },
    {
      'id': 'demo-customer-2',
      'name': 'Priya Sharma',
      'email': 'priya.sharma@email.com',
      'phone': '+91-9876543211',
      'address': '456 Brigade Road, Bangalore, Karnataka - 560025'
    },
    {
      'id': 'demo-customer-3',
      'name': 'Amit Patel',
      'email': 'amit.patel@email.com',
      'phone': '+91-9876543212',
      'address': '789 Koramangala, Bangalore, Karnataka - 560034'
    },
    {
      'id': 'demo-customer-4',
      'name': 'Sunita Gupta',
      'email': 'sunita.gupta@email.com',
      'phone': '+91-9876543213',
      'address': '321 Indiranagar, Bangalore, Karnataka - 560038'
    },
    {
      'id': 'demo-customer-5',
      'name': 'Vikram Singh',
      'email': 'vikram.singh@email.com',
      'phone': '+91-9876543214',
      'address': '654 Jayanagar, Bangalore, Karnataka - 560011'
    }
  ];

  // Demo employees for assignment
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

  // Demo order templates with realistic scenarios
  final List<Map<String, dynamic>> _demoOrderTemplates = [
    {
      'customerIndex': 0,
      'productType': ProductCategory.mensWear,
      'productName': 'Custom Business Suit',
      'quantity': 1,
      'customizations': {
        'fabric': 'Premium Wool Blend',
        'color': 'Navy Blue',
        'fit': 'Slim Fit',
        'style': 'Two-piece'
      },
      'measurements': {
        'chest': '42',
        'waist': '34',
        'length': '30',
        'shoulder': '18',
        'sleeve': '25'
      },
      'specialInstructions':
          'Customer wants double stitching for durability. Delivery by next Friday.',
      'status': OrderStatus.confirmed,
      'assignedEmployee': 0,
      'daysAgo': 2
    },
    {
      'customerIndex': 1,
      'productType': ProductCategory.womensWear,
      'productName': 'Designer Wedding Lehenga',
      'quantity': 1,
      'customizations': {
        'fabric': 'Heavy Banarasi Silk',
        'color': 'Maroon with Gold',
        'embroidery': 'Heavy Zari Work',
        'dupatta': 'Matching Net Dupatta'
      },
      'measurements': {
        'bust': '36',
        'waist': '28',
        'hips': '38',
        'length': '42',
        'blouse_size': 'M'
      },
      'specialInstructions':
          'Urgent wedding order. Customer wants premium quality work. Delivery in 10 days.',
      'status': OrderStatus.inProduction,
      'assignedEmployee': 1,
      'daysAgo': 5
    },
    {
      'customerIndex': 2,
      'productType': ProductCategory.kidsWear,
      'productName': 'School Uniform Set',
      'quantity': 3,
      'customizations': {
        'fabric': 'Cotton Blend',
        'color': 'Navy Blue with White',
        'size': 'School Size',
        'logo': 'School Emblem'
      },
      'measurements': {
        'chest': '32',
        'waist': '30',
        'length': '24',
        'age': '12 years'
      },
      'specialInstructions':
          'School uniform for 3 children. Need school logo embroidered.',
      'status': OrderStatus.qualityCheck,
      'assignedEmployee': 2,
      'daysAgo': 7
    },
    {
      'customerIndex': 3,
      'productType': ProductCategory.alterations,
      'productName': 'Suit Alteration',
      'quantity': 1,
      'customizations': {
        'alteration_type': 'Full Suit Alteration',
        'original_size': '44',
        'new_size': '42'
      },
      'measurements': {
        'chest': '42',
        'waist': '34',
        'length': '30',
        'inseam': '32'
      },
      'specialInstructions':
          'Customer lost weight, needs suit taken in. Keep same style and quality.',
      'status': OrderStatus.completed,
      'assignedEmployee': 2,
      'daysAgo': 10
    },
    {
      'customerIndex': 4,
      'productType': ProductCategory.formalWear,
      'productName': 'Corporate Blazer',
      'quantity': 1,
      'customizations': {
        'fabric': 'Premium Polyester',
        'color': 'Charcoal Grey',
        'buttons': 'Brass Company Buttons',
        'pocket': 'Company Logo Embroidery'
      },
      'measurements': {
        'chest': '40',
        'waist': '36',
        'length': '28',
        'shoulder': '17'
      },
      'specialInstructions':
          'Corporate order with company branding. High quality required.',
      'status': OrderStatus.assigned,
      'assignedEmployee': 0,
      'daysAgo': 1
    },
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
      'measurements': {
        'chest': '44',
        'waist': '36',
        'length': '38',
        'inseam': '40'
      },
      'specialInstructions':
          'Festival season order. Need delivery before Diwali.',
      'status': OrderStatus.pending,
      'assignedEmployee': null,
      'daysAgo': 0
    },
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
      'measurements': {
        'chest': '42',
        'waist': '34',
        'length': '28',
        'sleeve': '25'
      },
      'specialInstructions':
          'Bulk order for office casual wear. Mix of colors.',
      'status': OrderStatus.confirmed,
      'assignedEmployee': 3,
      'daysAgo': 3
    },
    {
      'customerIndex': 1,
      'productType': ProductCategory.customDesign,
      'productName': 'Designer Dress',
      'quantity': 1,
      'customizations': {
        'fabric': 'Chiffon with Net Overlay',
        'color': 'Emerald Green',
        'design': 'Custom Design by Customer',
        'embellishments': 'Crystal Work'
      },
      'measurements': {
        'bust': '34',
        'waist': '26',
        'hips': '36',
        'length': '48'
      },
      'specialInstructions':
          'Custom design based on customer sketch. High-end finishing required.',
      'status': OrderStatus.inProduction,
      'assignedEmployee': 3,
      'daysAgo': 8
    }
  ];

  Future<void> createDemoOrders(
      {required ProductProvider productProvider,
      required OrderProvider orderProvider}) async {
    try {
      print('🔧 Setting up demo orders...');

      // First, ensure we have products loaded
      productProvider.loadProducts();
      // Wait a moment for products to load
      await Future.delayed(const Duration(milliseconds: 500));
      if (productProvider.products.isEmpty) {
        await productProvider.refreshProducts();
      }

      // Create demo customers in Firestore
      await _createDemoCustomers();

      // Create demo orders
      for (int i = 0; i < _demoOrderTemplates.length; i++) {
        final template = _demoOrderTemplates[i];
        await _createDemoOrder(template, productProvider, orderProvider, i);
      }

      print('✅ Demo orders setup completed successfully!');
    } catch (e) {
      print('❌ Error setting up demo orders: $e');
    }
  }

  Future<void> _createDemoCustomers() async {
    print('📝 Creating demo customers...');

    for (final customer in _demoCustomers) {
      try {
        await _firestore.collection('customers').doc(customer['id']).set({
          ...customer,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Created customer: ${customer['name']}');
      } catch (e) {
        print('⚠️ Customer ${customer['name']} may already exist: $e');
      }
    }
  }

  Future<void> _createDemoOrder(
      Map<String, dynamic> template,
      ProductProvider productProvider,
      OrderProvider orderProvider,
      int index) async {
    try {
      // Get customer
      final customer = _demoCustomers[template['customerIndex']];

      // Find a suitable product from the loaded products
      final products = productProvider.products
          .where((p) => p.category == template['productType'])
          .toList();

      if (products.isEmpty) {
        print('⚠️ No products found for category ${template['productType']}');
        return;
      }

      final product = products.first; // Use first available product

      // Create order item
      final orderItem = OrderItem(
          id: 'demo-item-$index',
          productId: product.id,
          productName: template['productName'],
          category: product.category.toString().split('.').last,
          price: product.basePrice,
          quantity: template['quantity'],
          customizations: template['customizations'],
          notes: template['specialInstructions']);

      // Calculate order totals
      final totalAmount = orderItem.price * orderItem.quantity;
      final advanceAmount = totalAmount * 0.3; // 30% advance
      final remainingAmount = totalAmount - advanceAmount;

      // Create order date
      final daysAgo = template['daysAgo'] as int;
      final orderDate = DateTime.now().subtract(Duration(days: daysAgo));
      final deliveryDate = orderDate.add(const Duration(days: 7));

      // Create order
      final order = Order(
          id: '',
          customerId: customer['id'],
          items: [orderItem],
          status: template['status'],
          paymentStatus: PaymentStatus.paid, // Assume advance paid for demo
          totalAmount: totalAmount,
          advanceAmount: advanceAmount,
          remainingAmount: remainingAmount,
          orderDate: orderDate,
          deliveryDate: deliveryDate,
          specialInstructions: template['specialInstructions'],
          measurements: template['measurements'],
          orderImages: [], // Empty for demo
          createdAt: orderDate,
          updatedAt: orderDate,
          assignedEmployeeId: template['assignedEmployee'] != null
              ? _demoEmployees[template['assignedEmployee']]['id']
              : null,
          assignedEmployeeName: template['assignedEmployee'] != null
              ? _demoEmployees[template['assignedEmployee']]['name']
              : null,
          assignedAt: template['assignedEmployee'] != null
              ? orderDate.add(const Duration(hours: 2))
              : null,
          startedAt: template['status'] == OrderStatus.inProduction
              ? orderDate.add(const Duration(hours: 4))
              : null,
          completedAt: template['status'] == OrderStatus.completed
              ? orderDate.add(const Duration(days: 6))
              : null,
          workAssignments: template['assignedEmployee'] != null
              ? {
                  _demoEmployees[template['assignedEmployee']]['id']: {
                    'employeeName': _demoEmployees[template['assignedEmployee']]
                        ['name'],
                    'assignedAt': orderDate
                        .add(const Duration(hours: 2))
                        .toIso8601String(),
                    'specialization':
                        _demoEmployees[template['assignedEmployee']]
                            ['specialization'],
                    'status': _getWorkStatus(template['status']),
                    'estimatedHours':
                        _getEstimatedHours(template['productType']),
                    'progress': _getProgressForStatus(template['status'])
                  }
                }
              : {});

      // Save to Firestore
      final orderData = order.toJson();
      orderData.remove('id'); // Remove ID for new orders

      final docRef = await _firestore.collection('orders').add(orderData);

      print(
          '✅ Created order #${index + 1}: ${template['productName']} for ${customer['name']}');

      // Add order ID to customer document
      await _firestore.collection('customers').doc(customer['id']).update({
        'orderIds': FieldValue.arrayUnion([docRef.id])
      });
    } catch (e) {
      print('❌ Error creating demo order $index: $e');
    }
  }

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

  int _getEstimatedHours(ProductCategory category) {
    switch (category) {
      case ProductCategory.mensWear:
      case ProductCategory.formalWear:
        return 24; // 3 work days
      case ProductCategory.womensWear:
      case ProductCategory.traditionalWear:
        return 32; // 4 work days
      case ProductCategory.kidsWear:
        return 8; // 1 work day
      case ProductCategory.casualWear:
        return 12; // 1.5 work days
      case ProductCategory.alterations:
        return 6; // Half day
      case ProductCategory.customDesign:
        return 48; // 6 work days
    }
  }

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

  Future<bool> demoOrdersExist() async {
    try {
      final querySnapshot = await _firestore.collection('orders').get();
      return querySnapshot.docs.any((doc) => doc.id.startsWith('demo-order-'));
    } catch (e) {
      print('❌ Error checking demo orders: $e');
      return false;
    }
  }

  Future<void> initializeDemoOrdersIfNeeded(
      {required ProductProvider productProvider,
      required OrderProvider orderProvider}) async {
    try {
      final ordersExist = await demoOrdersExist();
      if (!ordersExist) {
        print('🔧 Demo orders not found, creating them...');
        final Future<void> demoOrdersTask = createDemoOrders(
            productProvider: productProvider, orderProvider: orderProvider);
        await demoOrdersTask;
        print('✅ Demo orders created successfully');
        return;
      } else {
        print('✅ Demo orders already exist');
        return;
      }
    } catch (e) {
      print('❌ Error initializing demo orders: $e');
    }
  }
}

// Helper function to setup demo orders (can be called from main)
Future<void> setupDemoOrders() async {
  print(
      'Demo orders setup helper called - integrate with providers in main app');
}
