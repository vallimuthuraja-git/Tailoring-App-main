import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/customer.dart';
import '../../utils/theme_constants.dart';
import '../../services/firebase_service.dart';
import '../../widgets/user_avatar.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  final bool editable;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
    this.editable = true,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Customer customer;

  @override
  void initState() {
    super.initState();
    customer = widget.customer;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        backgroundColor: isDark ? DarkAppColors.surface : AppColors.surface,
        foregroundColor: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: widget.editable
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToEdit(),
                  tooltip: 'Edit Customer',
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showMoreOptions(),
                  tooltip: 'More Options',
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Header
            _buildCustomerHeader(isDark),

            const SizedBox(height: 24),

            // Customer Statistics
            _buildStatisticsCard(isDark),

            const SizedBox(height: 24),

            // Basic Information
            _buildSection(
              title: 'Basic Information',
              icon: Icons.person,
              children: [
                _buildInfoRow('Name', customer.name),
                _buildInfoRow('Email', customer.email),
                _buildInfoRow('Phone', customer.formattedPhone),
                _buildInfoRow('Member Since',
                    '${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}'),
                _buildInfoRow(
                    'Status', customer.isActive ? 'Active' : 'Inactive',
                    valueColor: customer.isActive ? Colors.green : Colors.red),
                _buildInfoRow(
                    'Loyalty Tier', customer.loyaltyTier.name.capitalize()),
              ],
            ),

            // Measurements
            if (customer.measurements.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSection(
                title: 'Body Measurements',
                icon: Icons.straighten,
                children: customer.measurements.entries.map((entry) {
                  return _buildMeasurementRow(entry.key, entry.value);
                }).toList(),
              ),
            ],

            // Preferences
            if (customer.preferences.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSection(
                title: 'Fashion Preferences',
                icon: Icons.style,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: customer.preferences.map((preference) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? DarkAppColors.primary
                                  : AppColors.primary)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (isDark
                                    ? DarkAppColors.primary
                                    : AppColors.primary)
                                .withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          preference,
                          style: TextStyle(
                            color: isDark
                                ? DarkAppColors.primary
                                : AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],

            // Action Buttons
            if (widget.editable) ...[
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? DarkAppColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? DarkAppColors.onSurface.withOpacity(0.1)
              : AppColors.onSurface.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          UserAvatar(
            displayName: customer.name,
            imageUrl: customer.photoUrl,
            radius: 50,
          ),
          const SizedBox(height: 16),
          Text(
            customer.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: customer.isActive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              customer.isActive ? 'Active Customer' : 'Inactive Customer',
              style: TextStyle(
                color: customer.isActive
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(bool isDark) {
    final stats = [
      {
        'label': 'Total Spent',
        'value': '₹${customer.totalSpent.toStringAsFixed(0)}'
      },
      {
        'label': 'Loyalty Tier',
        'value': customer.loyaltyTier.name.capitalize()
      },
      {
        'label': 'Measurements',
        'value': customer.measurements.length.toString()
      },
      {'label': 'Preferences', 'value': customer.preferences.length.toString()},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkAppColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? DarkAppColors.onSurface.withOpacity(0.1)
              : AppColors.onSurface.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: stats
                .map((stat) => Expanded(
                      child: _buildStatItem(
                          stat['label']!, stat['value']!, isDark),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? DarkAppColors.primary : AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? DarkAppColors.onSurface.withOpacity(0.7)
                : AppColors.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkAppColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? DarkAppColors.onSurface.withOpacity(0.1)
              : AppColors.onSurface.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? DarkAppColors.primary : AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? DarkAppColors.onSurface : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final defaultColor = isDark ? DarkAppColors.onSurface : AppColors.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: defaultColor.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? defaultColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementRow(String measurement, dynamic value) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // Convert measurement name to readable format
    final readableName = measurement
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .capitalize();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              readableName,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? DarkAppColors.onSurface : AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? DarkAppColors.primary : AppColors.primary)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toStringAsFixed(1)} inch',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? DarkAppColors.primary : AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToEdit(),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? DarkAppColors.primary : AppColors.primary,
                  foregroundColor:
                      isDark ? DarkAppColors.onPrimary : AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showMoreOptions(),
                icon: const Icon(Icons.more_vert),
                label: const Text('More'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? DarkAppColors.primary : AppColors.primary,
                  ),
                  foregroundColor:
                      isDark ? DarkAppColors.primary : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToEdit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit customer ${customer.name} - Coming soon!')),
    );
  }

  void _showMoreOptions() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? DarkAppColors.surface : AppColors.surface,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit,
                color: isDark ? DarkAppColors.primary : AppColors.primary),
            title: const Text('Edit Customer'),
            onTap: () {
              Navigator.pop(context);
              _navigateToEdit();
            },
          ),
          ListTile(
            leading: Icon(
              customer.isActive ? Icons.person_off : Icons.person,
              color: customer.isActive ? Colors.red : Colors.green,
            ),
            title:
                Text(customer.isActive ? 'Mark as Inactive' : 'Mark as Active'),
            onTap: () {
              Navigator.pop(context);
              _toggleCustomerStatus();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Customer'),
            textColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              _confirmDelete();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _toggleCustomerStatus() async {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final firebaseService = FirebaseService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Updating Status'),
        content: CircularProgressIndicator(),
      ),
    );

    try {
      await firebaseService.updateDocument('customers', customer.id, {
        'isActive': !customer.isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        setState(() {
          customer = Customer(
            id: customer.id,
            name: customer.name,
            email: customer.email,
            phone: customer.phone,
            photoUrl: customer.photoUrl,
            measurements: customer.measurements,
            preferences: customer.preferences,
            createdAt: customer.createdAt,
            updatedAt: DateTime.now(),
            totalSpent: customer.totalSpent,
            loyaltyTier: customer.loyaltyTier,
            isActive: !customer.isActive,
          );
        });
        customerProvider.loadAllCustomers();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Customer ${customer.isActive ? 'activated' : 'deactivated'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
            'Are you sure you want to delete ${customer.name}? This action cannot be undone.'),
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

    if (confirmed == true) {
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      final firebaseService = FirebaseService();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Deleting Customer'),
          content: CircularProgressIndicator(),
        ),
      );

      try {
        await firebaseService.deleteDocument('customers', customer.id);

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          Navigator.of(context).pop(); // Close detail screen
          customerProvider.loadAllCustomers();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${customer.name} has been deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete customer: $e')),
          );
        }
      }
    }
  }
}

// Extension for string capitalization
extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
