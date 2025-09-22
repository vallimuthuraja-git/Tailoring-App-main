import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import 'collection_detail_screen.dart';

class CollectionListScreen extends StatefulWidget {
  const CollectionListScreen({super.key});

  @override
  State<CollectionListScreen> createState() => _CollectionListScreenState();
}

class _CollectionListScreenState extends State<CollectionListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Define all available collections
  final List<Map<String, dynamic>> _collections = [
    {
      'name': 'customers',
      'displayName': 'Customers',
      'icon': Icons.people,
      'description': 'Customer profiles with measurements and loyalty data',
      'color': Colors.blue,
    },
    {
      'name': 'products',
      'displayName': 'Products',
      'icon': Icons.inventory,
      'description': 'Product catalog with categories and specifications',
      'color': Colors.green,
    },
    {
      'name': 'orders',
      'displayName': 'Orders',
      'icon': Icons.shopping_cart,
      'description': 'Customer orders and transaction history',
      'color': Colors.orange,
    },
    {
      'name': 'employees',
      'displayName': 'Employees',
      'icon': Icons.work,
      'description': 'Employee profiles with skills and performance data',
      'color': Colors.purple,
    },
    {
      'name': 'services',
      'displayName': 'Services',
      'icon': Icons.build,
      'description': 'Available tailoring services and pricing',
      'color': Colors.teal,
    },
    {
      'name': 'work_assignments',
      'displayName': 'Work Assignments',
      'icon': Icons.assignment,
      'description': 'Employee work assignments and task tracking',
      'color': Colors.indigo,
    },
    {
      'name': 'chat_conversations',
      'displayName': 'Chat Conversations',
      'icon': Icons.chat,
      'description': 'Customer support chat conversations',
      'color': Colors.pink,
    },
    {
      'name': 'chat_messages',
      'displayName': 'Chat Messages',
      'icon': Icons.message,
      'description': 'Individual chat messages',
      'color': Colors.amber,
    },
    {
      'name': 'users',
      'displayName': 'Users',
      'icon': Icons.account_circle,
      'description': 'User authentication and role data',
      'color': Colors.red,
    },
    {
      'name': 'measurements',
      'displayName': 'Measurements',
      'icon': Icons.straighten,
      'description': 'Customer measurement records',
      'color': Colors.cyan,
    },
    {
      'name': 'notifications',
      'displayName': 'Notifications',
      'icon': Icons.notifications,
      'description': 'System notifications and alerts',
      'color': Colors.brown,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _collections.length,
        itemBuilder: (context, index) {
          final collection = _collections[index];
          return _buildCollectionCard(collection, themeProvider);
        },
      ),
    );
  }

  Widget _buildCollectionCard(Map<String, dynamic> collection, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToCollectionDetail(collection),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: collection['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  collection['icon'],
                  color: collection['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection['displayName'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      collection['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                            : AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<QuerySnapshot>(
                      future: _firestore.collection(collection['name']).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }

                        final count = snapshot.data?.docs.length ?? 0;
                        return Text(
                          '$count records',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                                : AppColors.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.4)
                    : AppColors.onSurface.withValues(alpha: 0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCollectionDetail(Map<String, dynamic> collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionDetailScreen(
          collectionName: collection['name'],
          displayName: collection['displayName'],
          icon: collection['icon'],
          color: collection['color'],
        ),
      ),
    );
  }
}
