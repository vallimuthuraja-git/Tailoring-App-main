import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/customer.dart';
import '../../utils/theme_constants.dart';
import '../../services/demo_data_service.dart';
import '../../services/firebase_service.dart';
import '../../widgets/user_avatar.dart';
import 'customer_create_screen.dart';
import 'customer_detail_screen.dart';
import 'customer_analytics_screen.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load customers when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadCustomers() {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    customerProvider.loadAllCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        toolbarHeight: kToolbarHeight + 5,
        backgroundColor: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface
              : AppColors.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface
              : AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.flash_on,
              color: themeProvider.isDarkMode ? Colors.amber : Colors.amber,
            ),
            onPressed: () => _showQuickCustomerAdd(context),
            tooltip: 'Quick Add Customer',
          ),
          IconButton(
            icon: Icon(
              Icons.analytics,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            onPressed: () => _navigateToAnalytics(context),
            tooltip: 'Customer Analytics',
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            onPressed: _loadCustomers,
            tooltip: 'Refresh',
          ),
          // Demo Data Actions
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            tooltip: 'More Actions',
            onSelected: (value) {
              switch (value) {
                case 'test_customer':
                  _addTestCustomerEvenIfBroken(context);
                  break;
                case 'add_demo_customer':
                  _addDemoCustomer(context);
                  break;
                case 'populate_demo':
                  _populateDemoCustomers(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'test_customer',
                child: Row(
                  children: [
                    Icon(Icons.bug_report),
                    SizedBox(width: 8),
                    Text('ðŸ”§ Test Customer Creation'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_demo_customer',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Add Demo Customer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'populate_demo',
                child: Row(
                  children: [
                    Icon(Icons.group_add),
                    SizedBox(width: 8),
                    Text('Add All Demo Customers'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface
                        : AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                          : AppColors.onSurface.withValues(alpha: 0.7),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.onSurface
                                      .withValues(alpha: 0.7)
                                  : AppColors.onSurface.withValues(alpha: 0.7),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                            : AppColors.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                    filled: true,
                    fillColor: themeProvider.isDarkMode
                        ? DarkAppColors.background
                        : AppColors.background,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),

              // Filter Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                labelColor: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                unselectedLabelColor: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                    : AppColors.onSurface.withValues(alpha: 0.6),
                tabs: const [
                  Tab(text: 'All Customers'),
                  Tab(text: 'Active'),
                  Tab(text: 'Inactive'),
                ],
                onTap: (index) {
                  switch (index) {
                    case 0:
                      setState(() => _selectedFilter = 'All');
                      break;
                    case 1:
                      setState(() => _selectedFilter = 'Active');
                      break;
                    case 2:
                      setState(() => _selectedFilter = 'Inactive');
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Consumer2<CustomerProvider, ThemeProvider>(
        builder: (context, customerProvider, themeProvider, child) {
          if (customerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (customerProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${customerProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCustomers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Get filtered and searched customers
          final filteredCustomers =
              _getFilteredCustomers(customerProvider.customers);

          return Column(
            children: [
              // Statistics Cards
              _buildStatisticsCards(customerProvider, themeProvider),

              // Customer List
              Expanded(
                child: filteredCustomers.isEmpty
                    ? _buildEmptyState(themeProvider)
                    : _buildCustomerList(filteredCustomers, themeProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isShopOwnerOrAdmin) {
            return FloatingActionButton.extended(
              onPressed: () => _showAddCustomerDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Customer'),
              backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
              foregroundColor: Provider.of<ThemeProvider>(context).isDarkMode
                  ? DarkAppColors.onPrimary
                  : AppColors.onPrimary,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<Customer> _getFilteredCustomers(List<Customer> customers) {
    var filtered = customers;

    // Filter by status
    switch (_selectedFilter) {
      case 'Active':
        filtered = filtered.where((customer) => customer.isActive).toList();
        break;
      case 'Inactive':
        filtered = filtered.where((customer) => !customer.isActive).toList();
        break;
      default:
        // All customers
        break;
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((customer) {
        return customer.name.toLowerCase().contains(lowerQuery) ||
            customer.email.toLowerCase().contains(lowerQuery) ||
            customer.phone.contains(lowerQuery);
      }).toList();
    }

    return filtered;
  }

  Widget _buildStatisticsCards(
      CustomerProvider customerProvider, ThemeProvider themeProvider) {
    final stats = _calculateCustomerStats(customerProvider.customers);

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            'Total Customers',
            stats['total'].toString(),
            Icons.people,
            themeProvider,
          ),
          _buildStatCard(
            'Active',
            stats['active'].toString(),
            Icons.check_circle,
            themeProvider,
            color: Colors.green,
          ),
          _buildStatCard(
            'Inactive',
            stats['inactive'].toString(),
            Icons.cancel,
            themeProvider,
            color: Colors.red,
          ),
          _buildStatCard(
            'Total Revenue',
            'â‚¹${stats['totalRevenue'].toStringAsFixed(0)}',
            Icons.attach_money,
            themeProvider,
            color: Colors.purple,
          ),
          _buildStatCard(
            'Avg Order Value',
            'â‚¹${stats['avgOrderValue'].toStringAsFixed(0)}',
            Icons.trending_up,
            themeProvider,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, ThemeProvider themeProvider,
      {Color? color}) {
    final cardColor = color ??
        (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
              : AppColors.onSurface.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.08)
                : AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: cardColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                : AppColors.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No customers found matching "$_searchQuery"'
                : 'No customers found',
            style: TextStyle(
              fontSize: 18,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Add your first customer to get started',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerList(
      List<Customer> customers, ThemeProvider themeProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return _buildCustomerCard(customer, themeProvider);
      },
    );
  }

  void _showQuickCustomerAdd(BuildContext context) async {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final firebaseService = FirebaseService();

    // Simple customer creation for testing
    final now = DateTime.now();
    final customerId = 'quick_customer_${now.millisecondsSinceEpoch}';

    final customerData = {
      'id': customerId,
      'name': 'Quick Test Customer',
      'email': 'quick@customer.com',
      'phone': '+91-9999999999',
      'photoUrl': 'https://via.placeholder.com/150x150?text=QTC',
      'measurements': {},
      'preferences': ['Test Preference'],
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'totalSpent': 1000.0,
      'loyaltyTier': 0,
      'isActive': true,
    };

    try {
      debugdebugPrint('ðŸ§ª Creating quick test customer...');
      await firebaseService.addDocument('customers', customerData);
      debugdebugPrint('âœ… Quick customer created successfully');

      // Refresh the list
      customerProvider.loadAllCustomers();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quick customer added successfully!')));
    } catch (e) {
      debugdebugPrint('âŒ Quick customer creation failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add customer: $e')));
    }
  }

  Widget _buildCustomerCard(Customer customer, ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToCustomerDetail(customer),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Header
              Row(
                children: [
                  UserAvatar(
                    displayName: customer.name,
                    imageUrl: customer.photoUrl,
                    radius: 24.0,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface
                                : AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customer.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                : AppColors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusChip(customer.isActive, themeProvider),
                      const SizedBox(height: 4),
                      _buildLoyaltyChip(
                          customer.loyaltyTier.name, themeProvider),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Customer Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone: ${customer.formattedPhone}',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface
                                : AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total Spent: â‚¹${customer.totalSpent.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.primary
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Joined',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                              : AppColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface
                              : AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Preferences
              if (customer.preferences.isNotEmpty) ...[
                Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                        : AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: customer.topPreferences.map((preference) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.primary.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        preference,
                        style: TextStyle(
                          fontSize: 11,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToCustomerDetail(customer),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showCustomerActions(context, customer),
                    icon: const Icon(Icons.more_vert, size: 16),
                    label: const Text('Actions'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoyaltyChip(String tier, ThemeProvider themeProvider) {
    Color backgroundColor;
    Color textColor;

    switch (tier.toLowerCase()) {
      case 'platinum':
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        break;
      case 'gold':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'silver':
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        break;
      default:
        backgroundColor = Colors.amber.shade100;
        textColor = Colors.amber.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tier,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateCustomerStats(List<Customer> customers) {
    final total = customers.length;
    final active = customers.where((c) => c.isActive).length;
    final inactive = total - active;
    final totalRevenue =
        customers.fold<double>(0, (sum, c) => sum + c.totalSpent);
    final avgOrderValue = total > 0 ? totalRevenue / total : 0;

    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'totalRevenue': totalRevenue,
      'avgOrderValue': avgOrderValue,
    };
  }

  void _navigateToCustomerDetail(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailScreen(customer: customer),
      ),
    );
  }

  // Show detailed customer information
  void _showCustomerDetails(Customer customer) {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', customer.email),
              _buildDetailRow('Phone', customer.formattedPhone),
              _buildDetailRow(
                  'Status', customer.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow(
                  'Loyalty Tier', customer.loyaltyTier.name.toUpperCase()),
              _buildDetailRow(
                  'Total Spent', 'â‚¹${customer.totalSpent.toStringAsFixed(0)}'),
              _buildDetailRow('Member Since',
                  '${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}'),
              const SizedBox(height: 16),
              const Text(
                'Measurements:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...customer.measurements.entries.map((measurement) => _buildDetailRow(
                  measurement.key,
                  '${measurement.value}${measurement.key == 'neck' || measurement.key.contains('height') ? ' inch' : ''}')),
              const SizedBox(height: 16),
              const Text(
                'Preferences:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(customer.preferences.join(', ')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Edit customer basic information
  void _editCustomerDialog(BuildContext context, Customer customer) {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final nameController = TextEditingController(text: customer.name);
    final emailController = TextEditingController(text: customer.email);
    final phoneController = TextEditingController(text: customer.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  title: Text('Updating...'),
                  content: CircularProgressIndicator(),
                ),
              );

              final success = await customerProvider.updateCustomerProfile(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
              );

              if (context.mounted) {
                Navigator.of(context).pop(); // Close loading dialog

                if (success) {
                  customerProvider.loadAllCustomers(); // Refresh list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Customer updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update customer')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Toggle customer active status
  void _toggleCustomerStatus(
      Customer customer, CustomerProvider customerProvider) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Updating Status...'),
        content: CircularProgressIndicator(),
      ),
    );

    try {
      // Update customer active status in database
      await _firebaseService.updateDocument(
        'customers',
        customer.id,
        {
          'isActive': !customer.isActive,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        customerProvider.loadAllCustomers(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Customer ${!customer.isActive ? 'enabled' : 'disabled'} successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  // Edit customer measurements
  void _editMeasurementsDialog(BuildContext context, Customer customer) {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final measurements = customer.measurements;

    // Create controllers for each measurement
    final controllers = <String, TextEditingController>{};
    measurements.forEach((key, value) {
      controllers[key] = TextEditingController(text: value.toString());
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Measurements'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...measurements.keys.map((key) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      controller: controllers[key],
                      decoration: InputDecoration(labelText: '$key (inches)'),
                      keyboardType: TextInputType.number,
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  title: Text('Updating...'),
                  content: CircularProgressIndicator(),
                ),
              );

              // Build updated measurements map
              final updatedMeasurements = <String, dynamic>{};
              controllers.forEach((key, controller) {
                final value = double.tryParse(controller.text);
                if (value != null) {
                  updatedMeasurements[key] = value;
                }
              });

              final success = await customerProvider
                  .updateMeasurements(updatedMeasurements);

              if (context.mounted) {
                Navigator.of(context).pop(); // Close loading dialog

                if (success) {
                  customerProvider.loadAllCustomers(); // Refresh list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Measurements updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to update measurements')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Edit customer preferences
  void _editPreferencesDialog(BuildContext context, Customer customer) {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final preferencesController =
        TextEditingController(text: customer.preferences.join(', '));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Preferences'),
        content: TextField(
          controller: preferencesController,
          decoration: const InputDecoration(
            labelText: 'Preferences (comma-separated)',
            hintText: 'e.g., Cotton, Formal, Business Wear',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  title: Text('Updating...'),
                  content: CircularProgressIndicator(),
                ),
              );

              final preferences = preferencesController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();

              final success = await customerProvider.updateCustomerProfile(
                preferences: preferences,
              );

              if (context.mounted) {
                Navigator.of(context).pop(); // Close loading dialog

                if (success) {
                  customerProvider.loadAllCustomers(); // Refresh list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Preferences updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to update preferences')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _navigateToAnalytics(BuildContext context) {
    // Navigate to customer analytics screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerAnalyticsScreen(),
      ),
    );
  }

  void _showCustomerActions(BuildContext context, Customer customer) {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              'View Details',
              Icons.visibility,
              () {
                Navigator.pop(context);
                _showCustomerDetails(customer);
              },
            ),
            _buildActionButton(
              context,
              'Edit Customer',
              Icons.edit,
              () {
                Navigator.pop(context);
                _editCustomerDialog(context, customer);
              },
            ),
            _buildActionButton(
              context,
              customer.isActive ? 'Disable Customer' : 'Enable Customer',
              customer.isActive ? Icons.person_off : Icons.person,
              () {
                Navigator.pop(context);
                _toggleCustomerStatus(customer, customerProvider);
              },
              isDestructive: !customer.isActive,
            ),
            _buildActionButton(
              context,
              'Update Measurements',
              Icons.straighten,
              () {
                Navigator.pop(context);
                _editMeasurementsDialog(context, customer);
              },
            ),
            _buildActionButton(
              context,
              'Update Preferences',
              Icons.settings,
              () {
                Navigator.pop(context);
                _editPreferencesDialog(context, customer);
              },
            ),
            const SizedBox(height: 10),
            _buildActionButton(
              context,
              'Delete Customer',
              Icons.delete,
              () {
                Navigator.pop(context);
                _showDeleteConfirmation(customer);
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      onTap: onTap,
    );
  }

  // Method is used internally, keep it for now

  // Method removed - functionality integrated into customer detail screen

  void _showDeleteConfirmation(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
            'Are you sure you want to delete ${customer.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCustomer(customer);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteCustomer(Customer customer) async {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final firebaseService = FirebaseService();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
            'Are you sure you want to delete ${customer.name}? This action cannot be undone.\n\nThis will also remove all associated data including measurements and preferences.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Deleting Customer'),
        content: CircularProgressIndicator(),
      ),
    );

    try {
      // Delete customer from database
      await firebaseService.deleteDocument('customers', customer.id);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Refresh the customer list
        customerProvider.loadAllCustomers();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${customer.name} has been deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete ${customer.name}: $e')),
        );
      }
    }
  }

  void _showAddCustomerDialog(BuildContext context) {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerCreateScreen(),
      ),
    ).then((_) {
      // Refresh customer list when returning from create screen
      customerProvider.loadAllCustomers();
    });
  }

  // Test function to add a simple customer for debugging
  void _addTestCustomerEvenIfBroken(BuildContext context) async {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final firebaseService = FirebaseService();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Creating Test Customer'),
          content: CircularProgressIndicator(),
        ),
      );

      // Create a very simple test customer
      final testCustomer = {
        'id': 'test_customer_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Test Customer',
        'email': 'test@customer.com',
        'phone': '+91234567890',
        'photoUrl': '',
        'measurements': {
          'chest': 40.0.toString(),
          'waist': 32.0.toString(),
        },
        'preferences': ['Test Style'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'totalSpent': 5000.0,
        'loyaltyTier': 2, // Silver
        'isActive': true,
      };

      debugdebugPrint('ðŸ”¥ Attempting Firebase write...');
      await firebaseService.addDocument('customers', testCustomer);
      debugdebugPrint('âœ… Firebase write successful!');

      Navigator.of(context).pop(); // Close loading dialog

      // Force refresh
      debugdebugPrint('ðŸ”„ Forcing customer list refresh...');
      customerProvider.loadAllCustomers();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('âœ… Test Customer Created!'),
          content: const Text(
              'Test customer added to database\nRefresh the screen to see it'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugdebugPrint('âŒ Test customer creation failed: $e');
      Navigator.of(context).pop(); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('âŒ Test Failed'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Add specific Demo Customer with detailed information
  void _addDemoCustomer(BuildContext context) async {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);

    // Create comprehensive demo customer data
    final demoData = {
      'userId': 'demo_customer_1',
      'name': 'Demo Customer',
      'email': 'demo.customer@email.com',
      'phone': '+91-9876543210',
      'photoUrl': 'https://via.placeholder.com/150x150?text=Demo+Customer',
      'measurements': {
        'chest': 42.0,
        'waist': 34.0,
        'shoulder': 18.5,
        'neck': 16.0,
        'sleeveLength': 26.0,
        'inseam': 33.0,
        'hips': 40.0,
        'sholder':
            18.5, // Note: using this instead of 'shoulder' for consistency with existing code
      },
      'preferences': [
        'Business Wear',
        'Cotton',
        'Formal Attire',
        'Classic Design',
        'Professional'
      ],
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Creating Demo Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
                'Please wait while we create the Demo Customer with complete profile...'),
          ],
        ),
      ),
    );

    try {
      final success = await customerProvider.createCustomerProfile(
        userId: demoData['userId'] as String,
        name: demoData['name'] as String,
        email: demoData['email'] as String,
        phone: demoData['phone'] as String,
        photoUrl: demoData['photoUrl'] as String,
        initialMeasurements: demoData['measurements'] as Map<String, dynamic>,
        preferences: demoData['preferences'] as List<String>,
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (success) {
          // Refresh the customer list
          customerProvider.loadAllCustomers();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('âœ… Demo Customer Created!'),
              content: const Text(
                  'Demo Customer has been successfully added to the database with:\n\n'
                  'â€¢ Complete profile information\n'
                  'â€¢ Body measurements\n'
                  'â€¢ Customer preferences\n'
                  'â€¢ Contact details\n'
                  'â€¢ Active status\n\n'
                  'You can now edit, update, and manage this customer using the action buttons.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('âŒ Error'),
              content: const Text(
                  'Failed to create Demo Customer. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('âŒ Error'),
            content: Text('Error creating Demo Customer: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _populateDemoCustomers(BuildContext context) async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Demo Customers'),
        content: const Text(
            'This will add 35 demo customers with sample data to your database.\n\n'
            'Features included:\n'
            'â€¢ Diverse customer profiles\n'
            'â€¢ Multiple loyalty tiers\n'
            'â€¢ Body measurements\n'
            'â€¢ Purchase history\n\n'
            'Proceed with adding demo data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Demo Data'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _searchQuery = 'Loading...');

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Adding Demo Customers'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                  'Please wait while we populate the database with 35 demo customers...'),
            ],
          ),
        ),
      );

      // Generate all 35 demo customers with complete sample data using the service's full generation method
      final demoCustomers = ComprehensiveDemoDataService.getAllDemoCustomers();

      // Prepare batch operations for better performance
      final batchOperations = <Map<String, dynamic>>[];
      int successCount = 0;

      for (int i = 0; i < demoCustomers.length; i++) {
        try {
          final customer = demoCustomers[i];
          // Create customer with complete demo data (including totalSpent, loyaltyTier, measurements, etc.)
          final customerData = {
            ...customer.toJson(),
            'id': 'demo_customer_${i + 1}', // Unique demo ID to avoid conflicts
          };

          batchOperations.add({
            'type': 'set',
            'collection': 'customers',
            'docId': customerData['id'],
            'data': customerData,
          });

          successCount++;
        } catch (e) {
          debugdebugPrint('Failed to prepare customer ${demoCustomers[i].name}: $e');
        }
      }

      // Commit all customers in a single batch operation
      await _firebaseService.batchWrite(batchOperations);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        setState(() => _searchQuery = ''); // Clear loading state
        _loadCustomers(); // Refresh the customer list

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('âœ… Demo Data Added Successfully!'),
            content: Text(
                'Successfully added $successCount demo customers to your database!\n\n'
                'Demo customers include:\n'
                'â€¢ Diverse loyalty tiers (Bronze, Silver, Gold, Platinum)\n'
                'â€¢ Realistic contact information\n'
                'â€¢ Body measurements and preferences\n'
                'â€¢ Purchase history and spending patterns\n\n'
                'These customers are now visible in your customer management system!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        setState(() => _searchQuery = ''); // Clear loading state

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('âŒ Error'),
            content: Text('Failed to add demo customers: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}


