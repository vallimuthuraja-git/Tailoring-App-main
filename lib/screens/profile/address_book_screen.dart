import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  List<Address> addresses = [];
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    // For demo purposes, using demo addresses
    // In a real app, these would be loaded from your backend
    setState(() {
      addresses = List.from(demoAddresses);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Book'),
        backgroundColor: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAddressDialog(context, themeProvider),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.isDarkMode
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DarkAppColors.background,
                    DarkAppColors.surface.withValues(alpha: 0.8),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.05),
                    AppColors.background,
                  ],
                ),
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    themeProvider.isDarkMode ? AppColors.primary : AppColors.primary,
                  ),
                ),
              )
            : addresses.isEmpty
                ? _buildEmptyState(themeProvider, isLargeScreen)
                : _buildAddressList(themeProvider),
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider, bool isLargeScreen) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off,
                size: 64,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No addresses yet',
              style: TextStyle(
                fontSize: isLargeScreen ? 24 : 20,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onBackground
                    : AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your delivery addresses to make checkout faster and easier',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddAddressDialog(context, themeProvider),
              icon: const Icon(Icons.add),
              label: const Text('Add First Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(ThemeProvider themeProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: addresses.length,
      itemBuilder: (context, index) => _buildAddressCard(
        addresses[index],
        themeProvider,
        index,
      ),
    );
  }

  Widget _buildAddressCard(Address address, ThemeProvider themeProvider, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: themeProvider.isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.shade200,
          ),
        ),
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface.withValues(alpha: 0.95)
            : AppColors.surface.withValues(alpha: 0.95),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: address.isDefault
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : themeProvider.isDarkMode
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getLabelIcon(address.label),
                          size: 16,
                          color: address.isDefault
                              ? AppColors.primary
                              : themeProvider.isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          address.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: address.isDefault
                                ? AppColors.primary
                                : themeProvider.isDarkMode
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleAddressAction(value, address, index),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      if (!address.isDefault)
                        const PopupMenuItem(
                          value: 'set_default',
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 20),
                              SizedBox(width: 8),
                              Text('Set as Default'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                address.displayTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                address.formattedAddress,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                address.phoneNumber,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }

  void _handleAddressAction(String action, Address address, int index) {
    switch (action) {
      case 'edit':
        _showEditAddressDialog(context, address, index);
        break;
      case 'set_default':
        _setAsDefault(index);
        break;
      case 'delete':
        _showDeleteConfirmation(context, address, index);
        break;
    }
  }

  void _showAddAddressDialog(BuildContext context, ThemeProvider themeProvider) {
    // This would typically open a dialog to add a new address
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add address functionality would be implemented here')),
    );
  }

  void _showEditAddressDialog(BuildContext context, Address address, int index) {
    // This would typically open a dialog to edit the address
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit address "${address.label}" functionality would be implemented here')),
    );
  }

  void _setAsDefault(int index) {
    setState(() {
      // Unset all other defaults
      for (int i = 0; i < addresses.length; i++) {
        addresses[i] = addresses[i].copyWith(isDefault: i == index);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address set as default')),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Address address, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete the ${address.label} address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                addresses.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${address.label} address deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}