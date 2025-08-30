import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleDemoApp());
}

class SimpleDemoApp extends StatelessWidget {
  const SimpleDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tailoring Shop Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const DemoHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({super.key});

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    ProductsTab(),
    OrdersTab(),
    CustomersTab(),
    AnalyticsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tailoring Shop Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => _showChatbot(context),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  void _showChatbot(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          height: 500,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.smart_toy, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Assistant Demo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: const [
                    ChatBubble(
                      message: "Hello! I'm your AI tailoring assistant. How can I help you today?",
                      isUser: false,
                    ),
                    ChatBubble(
                      message: "I need help with suit measurements",
                      isUser: true,
                    ),
                    ChatBubble(
                      message: "I'd be happy to help you with suit measurements! For a proper fit, we'll need to measure: chest, waist, shoulder, length, and inseam. Would you like me to guide you through the process?",
                      isUser: false,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Type your message...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.design_services,
                  size: 64,
                  color: Colors.blue,
                ),
                SizedBox(height: 16),
                Text(
                  'Welcome to Your',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Tailoring Shop Demo',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Complete AI-Enabled Solution for Modern Tailoring Businesses',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Key Metrics
          const Text(
            'Business Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Orders',
                  value: '3',
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  title: 'Revenue',
                  value: '₹78,750',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Customers',
                  value: '3',
                  icon: Icons.people,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  title: 'Products',
                  value: '5',
                  icon: Icons.inventory,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Orders
          const Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildDemoOrder('Rajesh Kumar', '₹15,750', 'Confirmed'),
          const SizedBox(height: 12),
          _buildDemoOrder('Priya Sharma', '₹26,250', 'In Progress'),
          const SizedBox(height: 12),
          _buildDemoOrder('Amit Patel', '₹7,875', 'Completed'),
        ],
      ),
    );
  }

  Widget _buildDemoOrder(String customerName, String amount, String status) {
    Color statusColor;
    switch (status) {
      case 'Confirmed':
        statusColor = Colors.blue;
        break;
      case 'In Progress':
        statusColor = Colors.purple;
        break;
      case 'Completed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    amount,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsTab extends StatelessWidget {
  const ProductsTab({super.key});

  final List<Map<String, dynamic>> demoProducts = const [
    {
      'name': 'Custom Suit - 3 Piece',
      'description': 'Complete 3-piece suit with jacket, vest, and trousers. Premium wool fabric.',
      'price': '₹15,000',
      'category': 'Men\'s Wear',
    },
    {
      'name': 'Wedding Lehenga',
      'description': 'Beautiful wedding lehenga with heavy embroidery and traditional design.',
      'price': '₹25,000',
      'category': 'Women\'s Wear',
    },
    {
      'name': 'Business Shirt - Cotton',
      'description': 'Professional cotton business shirt with perfect fit and comfort.',
      'price': '₹2,500',
      'category': 'Men\'s Wear',
    },
    {
      'name': 'Evening Gown - Designer',
      'description': 'Elegant evening gown for parties and special events.',
      'price': '₹18,000',
      'category': 'Women\'s Wear',
    },
    {
      'name': 'Suit Alteration Service',
      'description': 'Professional suit alteration service including adjustments.',
      'price': '₹2,000',
      'category': 'Alterations',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: demoProducts.length,
        itemBuilder: (context, index) {
          final product = demoProducts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: const Icon(
                      Icons.inventory,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['description'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              product['price'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                product['category'],
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  final List<Map<String, dynamic>> demoOrders = const [
    {
      'id': '1',
      'customer': 'Rajesh Kumar',
      'amount': '₹15,750',
      'status': 'Confirmed',
      'date': '2024-08-20',
    },
    {
      'id': '2',
      'customer': 'Priya Sharma',
      'amount': '₹26,250',
      'status': 'In Progress',
      'date': '2024-08-18',
    },
    {
      'id': '3',
      'customer': 'Amit Patel',
      'amount': '₹7,875',
      'status': 'Completed',
      'date': '2024-08-15',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: demoOrders.length,
        itemBuilder: (context, index) {
          final order = demoOrders[index];
          Color statusColor;
          switch (order['status']) {
            case 'Confirmed':
              statusColor = Colors.blue;
              break;
            case 'In Progress':
              statusColor = Colors.purple;
              break;
            case 'Completed':
              statusColor = Colors.green;
              break;
            default:
              statusColor = Colors.grey;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order['id']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          order['status'],
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order['customer'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['amount'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        order['date'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }
}

class CustomersTab extends StatelessWidget {
  const CustomersTab({super.key});

  final List<Map<String, dynamic>> demoCustomers = const [
    {
      'name': 'Rajesh Kumar',
      'email': 'rajesh@example.com',
      'phone': '+91 9876543210',
      'tier': 'Gold',
      'spent': '₹45,000',
    },
    {
      'name': 'Priya Sharma',
      'email': 'priya@example.com',
      'phone': '+91 8765432109',
      'tier': 'Platinum',
      'spent': '₹75,000',
    },
    {
      'name': 'Amit Patel',
      'email': 'amit@example.com',
      'phone': '+91 7654321098',
      'tier': 'Silver',
      'spent': '₹15,000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: demoCustomers.length,
        itemBuilder: (context, index) {
          final customer = demoCustomers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      customer['name'][0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer['email'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer['phone'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(
                         color: Colors.blue.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(16),
                       ),
                        child: Text(
                          customer['tier'],
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer['spent'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
    );
  }
}

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Key Metrics Grid
          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Orders',
                  value: '3',
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  title: 'Revenue',
                  value: '₹78,750',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Customers',
                  value: '3',
                  icon: Icons.people,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  title: 'Products',
                  value: '5',
                  icon: Icons.inventory,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Performance Indicators
          const Text(
            'Performance Indicators',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          const _PerformanceIndicator(
            label: 'Completion Rate',
            value: 66.67,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          const _PerformanceIndicator(
            label: 'Average Order Value',
            value: 26250.0,
            color: Colors.blue,
            isCurrency: true,
          ),
          const SizedBox(height: 12),
          const _PerformanceIndicator(
            label: 'Customer Retention',
            value: 100.0,
            color: Colors.purple,
            isPercentage: true,
          ),

          const SizedBox(height: 32),

          // Top Products
          const Text(
            'Top Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildTopProduct('Wedding Lehenga', 'Women\'s Wear', '₹25,000'),
          const SizedBox(height: 12),
          _buildTopProduct('Custom Suit - 3 Piece', 'Men\'s Wear', '₹15,000'),
          const SizedBox(height: 12),
          _buildTopProduct('Evening Gown - Designer', 'Women\'s Wear', '₹18,000'),
        ],
      ),
    );
  }

  Widget _buildTopProduct(String name, String category, String price) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: const Icon(
                Icons.inventory,
                size: 24,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceIndicator extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isCurrency;
  final bool isPercentage;

  const _PerformanceIndicator({
    required this.label,
    required this.value,
    required this.color,
    this.isCurrency = false,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    String displayValue;
    if (isCurrency) {
      displayValue = '₹${value.toStringAsFixed(0)}';
    } else if (isPercentage) {
      displayValue = '${value.toStringAsFixed(1)}%';
    } else {
      displayValue = '${value.toStringAsFixed(1)}%';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: isPercentage ? value / 100 : (value > 100 ? 1.0 : value / 100),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }
}
