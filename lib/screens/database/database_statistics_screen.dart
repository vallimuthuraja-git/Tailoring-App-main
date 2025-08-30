import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseStatisticsScreen extends StatefulWidget {
  const DatabaseStatisticsScreen({super.key});

  @override
  State<DatabaseStatisticsScreen> createState() => _DatabaseStatisticsScreenState();
}

class _DatabaseStatisticsScreenState extends State<DatabaseStatisticsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final stats = <String, dynamic>{};

      // Define all collections to analyze
      final collections = [
        'customers',
        'products',
        'orders',
        'employees',
        'services',
        'work_assignments',
        'chat_conversations',
        'chat_messages',
        'users',
        'measurements',
        'notifications'
      ];

      // Get collection counts
      final collectionCounts = <String, int>{};
      int totalDocuments = 0;

      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        final count = snapshot.docs.length;
        collectionCounts[collection] = count;
        totalDocuments += count;
      }

      stats['collectionCounts'] = collectionCounts;
      stats['totalDocuments'] = totalDocuments;

      // Get detailed statistics for specific collections
      stats['customerStats'] = await _getCustomerStatistics();
      stats['orderStats'] = await _getOrderStatistics();
      stats['employeeStats'] = await _getEmployeeStatistics();
      stats['productStats'] = await _getProductStatistics();
      stats['chatStats'] = await _getChatStatistics();

      // Calculate database health metrics
      stats['databaseHealth'] = _calculateDatabaseHealth(stats);

      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading statistics: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _getCustomerStatistics() async {
    final snapshot = await _firestore.collection('customers').get();
    final customers = snapshot.docs;

    final loyaltyTiers = <String, int>{};
    final activeCustomers = customers.where((doc) {
      final data = doc.data();
      return data['isActive'] == true;
    }).length;

    for (final doc in customers) {
      final data = doc.data();
      final tier = data['loyaltyTier']?.toString() ?? 'unknown';
      loyaltyTiers[tier] = (loyaltyTiers[tier] ?? 0) + 1;
    }

    return {
      'total': customers.length,
      'active': activeCustomers,
      'inactive': customers.length - activeCustomers,
      'loyaltyTiers': loyaltyTiers,
    };
  }

  Future<Map<String, dynamic>> _getOrderStatistics() async {
    final snapshot = await _firestore.collection('orders').get();
    final orders = snapshot.docs;

    final statusCounts = <String, int>{};
    double totalRevenue = 0;
    double totalAdvance = 0;

    for (final doc in orders) {
      final data = doc.data();
      final status = data['status']?.toString() ?? 'unknown';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;

      totalRevenue += (data['totalAmount'] ?? 0).toDouble();
      totalAdvance += (data['advanceAmount'] ?? 0).toDouble();
    }

    return {
      'total': orders.length,
      'statusCounts': statusCounts,
      'totalRevenue': totalRevenue,
      'totalAdvance': totalAdvance,
      'pendingAmount': totalRevenue - totalAdvance,
    };
  }

  Future<Map<String, dynamic>> _getEmployeeStatistics() async {
    final snapshot = await _firestore.collection('employees').get();
    final employees = snapshot.docs;

    final skillCounts = <String, int>{};
    final availabilityCounts = <String, int>{};
    final activeEmployees = employees.where((doc) {
      final data = doc.data();
      return data['isActive'] == true;
    }).length;

    for (final doc in employees) {
      final data = doc.data();
      final availability = data['availability']?.toString() ?? 'unknown';
      availabilityCounts[availability] = (availabilityCounts[availability] ?? 0) + 1;

      final skills = data['skills'] as List<dynamic>? ?? [];
      for (final skill in skills) {
        final skillName = skill.toString();
        skillCounts[skillName] = (skillCounts[skillName] ?? 0) + 1;
      }
    }

    return {
      'total': employees.length,
      'active': activeEmployees,
      'inactive': employees.length - activeEmployees,
      'availabilityCounts': availabilityCounts,
      'skillCounts': skillCounts,
    };
  }

  Future<Map<String, dynamic>> _getProductStatistics() async {
    final snapshot = await _firestore.collection('products').get();
    final products = snapshot.docs;

    final categoryCounts = <String, int>{};
    final activeProducts = products.where((doc) {
      final data = doc.data();
      return data['isActive'] == true;
    }).length;

    double totalValue = 0;
    for (final doc in products) {
      final data = doc.data();
      final category = data['category']?.toString() ?? 'unknown';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      totalValue += (data['basePrice'] ?? 0).toDouble();
    }

    return {
      'total': products.length,
      'active': activeProducts,
      'inactive': products.length - activeProducts,
      'categoryCounts': categoryCounts,
      'totalValue': totalValue,
    };
  }

  Future<Map<String, dynamic>> _getChatStatistics() async {
    final conversationsSnapshot = await _firestore.collection('chat_conversations').get();
    final messagesSnapshot = await _firestore.collection('chat_messages').get();

    final activeConversations = conversationsSnapshot.docs.where((doc) {
      final data = doc.data();
      return data['isActive'] == true;
    }).length;

    return {
      'totalConversations': conversationsSnapshot.docs.length,
      'activeConversations': activeConversations,
      'totalMessages': messagesSnapshot.docs.length,
      'inactiveConversations': conversationsSnapshot.docs.length - activeConversations,
    };
  }

  Map<String, dynamic> _calculateDatabaseHealth(Map<String, dynamic> stats) {
    final collectionCounts = stats['collectionCounts'] as Map<String, dynamic>;
    final totalDocuments = stats['totalDocuments'] as int;

    // Calculate health score based on various metrics
    double healthScore = 100;

    // Reduce score for empty collections (except notifications which might be empty)
    final essentialCollections = ['customers', 'products', 'orders', 'employees'];
    for (final collection in essentialCollections) {
      if ((collectionCounts[collection] ?? 0) == 0) {
        healthScore -= 15;
      }
    }

    // Reduce score for too few records
    if (totalDocuments < 50) {
      healthScore -= 20;
    }

    // Check data balance
    final customerStats = stats['customerStats'] as Map<String, dynamic>;
    final activeCustomers = customerStats['active'] ?? 0;
    final totalCustomers = customerStats['total'] ?? 0;

    if (totalCustomers > 0 && (activeCustomers / totalCustomers) < 0.5) {
      healthScore -= 10; // Less than 50% active customers
    }

    return {
      'score': healthScore.clamp(0, 100),
      'status': healthScore >= 80 ? 'Excellent' :
                healthScore >= 60 ? 'Good' :
                healthScore >= 40 ? 'Fair' : 'Poor',
      'color': healthScore >= 80 ? Colors.green :
               healthScore >= 60 ? Colors.blue :
               healthScore >= 40 ? Colors.orange : Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildDatabaseHealthCard(),
          const SizedBox(height: 20),
          _buildCollectionOverview(),
          const SizedBox(height: 20),
          _buildDetailedStatistics(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.analytics,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            const Text(
              'Database Statistics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_statistics['totalDocuments'] ?? 0} total documents across all collections',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseHealthCard() {
    final health = _statistics['databaseHealth'] as Map<String, dynamic>? ?? {};
    final score = (health['score'] ?? 0).toDouble();
    final status = health['status'] ?? 'Unknown';
    final color = health['color'] ?? Colors.grey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.health_and_safety, size: 24),
                SizedBox(width: 12),
                Text(
                  'Database Health',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: ${score.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionOverview() {
    final collectionCounts = _statistics['collectionCounts'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.storage, size: 24),
                SizedBox(width: 12),
                Text(
                  'Collection Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...collectionCounts.entries.map((entry) {
              final collection = entry.key;
              final count = entry.value as int;
              final percentage = _statistics['totalDocuments'] != null && _statistics['totalDocuments'] > 0
                  ? (count / _statistics['totalDocuments'] * 100).toStringAsFixed(1)
                  : '0';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatCollectionName(collection),
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          '$count ($percentage%)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: _statistics['totalDocuments'] != null && _statistics['totalDocuments'] > 0
                          ? count / _statistics['totalDocuments']
                          : 0,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStatistics() {
    final customerStats = _statistics['customerStats'] as Map<String, dynamic>? ?? {};
    final orderStats = _statistics['orderStats'] as Map<String, dynamic>? ?? {};
    final employeeStats = _statistics['employeeStats'] as Map<String, dynamic>? ?? {};
    final productStats = _statistics['productStats'] as Map<String, dynamic>? ?? {};
    final chatStats = _statistics['chatStats'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        _buildStatsCard('Customer Analytics', customerStats, [
          'total', 'active', 'inactive'
        ]),
        const SizedBox(height: 16),
        _buildStatsCard('Order Analytics', orderStats, [
          'total', 'totalRevenue', 'pendingAmount'
        ]),
        const SizedBox(height: 16),
        _buildStatsCard('Employee Analytics', employeeStats, [
          'total', 'active', 'inactive'
        ]),
        const SizedBox(height: 16),
        _buildStatsCard('Product Analytics', productStats, [
          'total', 'active', 'totalValue'
        ]),
        const SizedBox(height: 16),
        _buildStatsCard('Chat Analytics', chatStats, [
          'totalConversations', 'activeConversations', 'totalMessages'
        ]),
      ],
    );
  }

  Widget _buildStatsCard(String title, Map<String, dynamic> stats, List<String> keys) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...keys.map((key) {
              final value = stats[key];
              if (value == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatStatKey(key),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      _formatStatValue(key, value),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatCollectionName(String name) {
    return name.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _formatStatKey(String key) {
    return key.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _formatStatValue(String key, dynamic value) {
    if (value is double && key.contains('Revenue')) {
      return '₹${value.toStringAsFixed(0)}';
    } else if (value is double && key.contains('Value')) {
      return '₹${value.toStringAsFixed(0)}';
    } else if (value is double) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }
}