import 'package:flutter/material.dart';
import '../widgets/user_avatar.dart';

void main() {
  runApp(const StandaloneTailoringApp());
}

class StandaloneTailoringApp extends StatelessWidget {
  const StandaloneTailoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tailoring Shop - Free Tier Demo',
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
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    ProductsScreen(),
    OrdersScreen(),
    CustomersScreen(),
    AnalyticsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  void _showChatbot(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
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
                      ChatMessage(
                        message:
                            "Hello! I'm your AI tailoring assistant. How can I help you today?",
                        isUser: false,
                      ),
                      ChatMessage(
                        message: "I need help with suit measurements",
                        isUser: true,
                      ),
                      ChatMessage(
                        message:
                            "I'd be happy to help you with suit measurements! For a proper fit, we'll need to measure: chest, waist, shoulder, length, and inseam. Would you like me to guide you through the process?",
                        isUser: false,
                      ),
                      ChatMessage(
                        message: "What's the delivery time for a custom suit?",
                        isUser: true,
                      ),
                      ChatMessage(
                        message:
                            "For our custom 3-piece suits, the typical delivery time is 14-21 days, including fittings and alterations. Premium fabrics may take 21-30 days. We offer express service for urgent orders!",
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
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Type your message...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Icon(Icons.send, color: Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatMessage({
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome to your tailoring shop management system',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // Key Metrics
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

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          const _ActivityCard(
            title: 'New Order Received',
            subtitle: 'Rajesh Kumar ordered Custom Suit',
            time: '2 hours ago',
            icon: Icons.receipt,
            color: Colors.blue,
          ),

          const SizedBox(height: 12),

          const _ActivityCard(
            title: 'Order Completed',
            subtitle: 'Business Shirt delivery completed',
            time: '1 day ago',
            icon: Icons.check_circle,
            color: Colors.green,
          ),

          const SizedBox(height: 12),

          const _ActivityCard(
            title: 'New Customer',
            subtitle: 'Amit Patel joined as customer',
            time: '2 days ago',
            icon: Icons.person_add,
            color: Colors.purple,
          ),
        ],
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 16),
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

class _ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  final List<Map<String, dynamic>> demoProducts = const [
    {
      'name': 'Custom Suit - 3 Piece',
      'description':
          'Complete 3-piece suit with jacket, vest, and trousers. Premium wool fabric.',
      'price': '₹15,000',
      'category': 'Men\'s Wear',
    },
    {
      'name': 'Wedding Lehenga',
      'description':
          'Beautiful wedding lehenga with heavy embroidery and traditional design.',
      'price': '₹25,000',
      'category': 'Women\'s Wear',
    },
    {
      'name': 'Business Shirt - Cotton',
      'description':
          'Professional cotton business shirt with perfect fit and comfort.',
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
      'description':
          'Professional suit alteration service including adjustments.',
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
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

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

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
                  UserAvatar(
                    displayName: customer['name'],
                    radius: 30,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
          _buildTopProduct(
              'Evening Gown - Designer', 'Women\'s Wear', '₹18,000'),
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
              value: isPercentage
                  ? value / 100
                  : (value > 100 ? 1.0 : value / 100),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }
}
