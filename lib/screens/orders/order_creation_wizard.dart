import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../product/product_models.dart';
import '../../models/order.dart';
import '../../product/product_data_access.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import 'package:intl/intl.dart';

// Using beautiful theme-level opacity extensions
// No more deprecated withValues(alpha:) calls - everything uses withValues() internally
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

class OrderCreationWizard extends StatefulWidget {
  const OrderCreationWizard({super.key});

  @override
  State<OrderCreationWizard> createState() => _OrderCreationWizardState();
}

class _OrderCreationWizardState extends State<OrderCreationWizard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Customer Information
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerAddressController = TextEditingController();

  // Step 2: Product Selection
  final List<OrderItem> _selectedItems = [];
  final Map<String, int> _itemQuantities = {};

  // Step 3: Measurements
  final Map<String, TextEditingController> _measurementControllers = {};

  // Step 4: Customizations & Images
  final _specialInstructionsController = TextEditingController();
  final List<String> _orderImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize measurement controllers
    _initializeMeasurementControllers();
  }

  void _initializeMeasurementControllers() {
    final standardMeasurements = [
      'Chest',
      'Waist',
      'Hip',
      'Shoulder',
      'Sleeve Length',
      'Inseam',
      'Length',
      'Neck',
      'Armhole',
      'Bicep'
    ];

    for (final measurement in standardMeasurements) {
      _measurementControllers[measurement] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _customerAddressController.dispose();
    _specialInstructionsController.dispose();
    for (final controller in _measurementControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Order'),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: _buildStepIndicator(themeProvider),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildCustomerInfoStep(themeProvider),
          _buildProductSelectionStep(themeProvider),
          _buildMeasurementsStep(themeProvider),
          _buildCustomizationsStep(themeProvider),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(themeProvider),
    );
  }

  Widget _buildStepIndicator(ThemeProvider themeProvider) {
    final steps = ['Customer', 'Products', 'Measurements', 'Review'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Colors.green
                        : isActive
                            ? (themeProvider.isDarkMode
                                ? DarkAppColors.primary
                                : AppColors.primary)
                            : (themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                : AppColors.onSurface.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  steps[index],
                  style: TextStyle(
                    color: isActive
                        ? (themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary)
                        : (themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                            : AppColors.onSurface.withValues(alpha: 0.6)),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (index < 3) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                          : AppColors.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCustomerInfoStep(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onBackground
                    : AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter customer details for this order',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Customer Name
            TextFormField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Customer Name *',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: themeProvider.isDarkMode
                    ? DarkAppColors.surface
                    : AppColors.background,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Customer name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _customerPhoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: themeProvider.isDarkMode
                    ? DarkAppColors.surface
                    : AppColors.background,
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email (Optional)
            TextFormField(
              controller: _customerEmailController,
              decoration: InputDecoration(
                labelText: 'Email (Optional)',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: themeProvider.isDarkMode
                    ? DarkAppColors.surface
                    : AppColors.background,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _customerAddressController,
              decoration: InputDecoration(
                labelText: 'Delivery Address *',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: themeProvider.isDarkMode
                    ? DarkAppColors.surface
                    : AppColors.background,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Delivery address is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelectionStep(ThemeProvider themeProvider) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.products;

        return Column(
          children: [
            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.surface
                    : AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                        : AppColors.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: themeProvider.isDarkMode
                            ? DarkAppColors.background
                            : AppColors.background,
                      ),
                      onChanged: productProvider.searchProducts,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedItems.length} selected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid
            Expanded(
              child: productProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                      ? const Center(child: Text('No products found'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return _buildProductCard(product, themeProvider);
                          },
                        ),
            ),

            // Cart Summary
            if (_selectedItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.surface
                      : AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                          : AppColors.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedItems.length} item${_selectedItems.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.onSurface
                                  : AppColors.onSurface,
                            ),
                          ),
                          Text(
                            '₹${_calculateTotal().toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.primary
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCartDialog(),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('View Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary,
                        foregroundColor: themeProvider.isDarkMode
                            ? DarkAppColors.onPrimary
                            : AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Product product, ThemeProvider themeProvider) {
    final isSelected =
        _selectedItems.any((item) => item.productId == product.id);
    final quantity = _itemQuantities[product.id] ?? 0;

    return GestureDetector(
      onTap: () => _toggleProductSelection(product),
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? DarkAppColors.surface
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary)
                : (themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                    : AppColors.onSurface.withValues(alpha: 0.1)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary)
                        .withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.background
                      : AppColors.background,
                ),
                child: product.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : const Icon(Icons.inventory_2, size: 48),
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface
                            : AppColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product.basePrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected && quantity > 0) ...[
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                _updateQuantity(product, quantity - 1),
                            icon: const Icon(Icons.remove, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              quantity.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.onSurface
                                    : AppColors.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _updateQuantity(product, quantity + 1),
                            icon: const Icon(Icons.add, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ] else if (isSelected) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Added to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsStep(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Measurements',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter customer measurements for accurate fitting',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          ..._measurementControllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: entry.value,
                decoration: InputDecoration(
                  labelText: '${entry.key} (inches)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: themeProvider.isDarkMode
                      ? DarkAppColors.surface
                      : AppColors.background,
                ),
                keyboardType: TextInputType.number,
              ),
            );
          }),

          const SizedBox(height: 24),

          // Quick measurement templates
          Text(
            'Quick Templates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            children: [
              _buildMeasurementTemplate(
                  'Standard Male',
                  {
                    'Chest': '40',
                    'Waist': '32',
                    'Hip': '38',
                    'Shoulder': '18',
                    'Sleeve Length': '25',
                  },
                  themeProvider),
              _buildMeasurementTemplate(
                  'Standard Female',
                  {
                    'Chest': '36',
                    'Waist': '28',
                    'Hip': '38',
                    'Shoulder': '16',
                    'Sleeve Length': '23',
                  },
                  themeProvider),
              _buildMeasurementTemplate('Clear All', {}, themeProvider,
                  isClear: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementTemplate(String name,
      Map<String, String> measurements, ThemeProvider themeProvider,
      {bool isClear = false}) {
    return ElevatedButton(
      onPressed: () {
        if (isClear) {
          _measurementControllers.forEach((key, controller) {
            controller.clear();
          });
        } else {
          measurements.forEach((key, value) {
            if (_measurementControllers.containsKey(key)) {
              _measurementControllers[key]!.text = value;
            }
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isClear
            ? Colors.red.shade100
            : (themeProvider.isDarkMode
                ? DarkAppColors.primary
                : AppColors.primary),
        foregroundColor: isClear
            ? Colors.red.shade800
            : (themeProvider.isDarkMode
                ? DarkAppColors.onPrimary
                : AppColors.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(name),
    );
  }

  Widget _buildCustomizationsStep(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Finalize',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 24),

          // Order Summary
          Container(
            padding: const EdgeInsets.all(20),
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface
                        : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // Customer Info
                _buildSummaryRow(
                    'Customer', _customerNameController.text, themeProvider),
                _buildSummaryRow(
                    'Phone', _customerPhoneController.text, themeProvider),
                if (_customerEmailController.text.isNotEmpty)
                  _buildSummaryRow(
                      'Email', _customerEmailController.text, themeProvider),

                const SizedBox(height: 16),

                // Products
                Text(
                  'Products (${_selectedItems.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface
                        : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ..._selectedItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${item.productName} x${item.quantity} - ₹${(item.price * item.quantity).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.8)
                              : AppColors.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    )),

                const SizedBox(height: 16),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface
                            : AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '₹${_calculateTotal().toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Advance Payment
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Advance (30%)',
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.8)
                            : AppColors.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '₹${(_calculateTotal() * 0.3).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Special Instructions
          TextFormField(
            controller: _specialInstructionsController,
            decoration: InputDecoration(
              labelText: 'Special Instructions (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: themeProvider.isDarkMode
                  ? DarkAppColors.surface
                  : AppColors.background,
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 24),

          // Delivery Date
          InkWell(
            onTap: () => _selectDeliveryDate(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                      : AppColors.onSurface.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
                color: themeProvider.isDarkMode
                    ? DarkAppColors.surface
                    : AppColors.background,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 12),
                  Text(
                    'Delivery Date: ${_formatDeliveryDate()}',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface
                          : AppColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface
                        : AppColors.onSurface,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
      String label, String value, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.8)
                    : AppColors.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                : AppColors.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0 && _currentStep < 3) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                foregroundColor: themeProvider.isDarkMode
                    ? DarkAppColors.onPrimary
                    : AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_currentStep == 3 ? 'Create Order' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() async {
    if (_currentStep < 3) {
      if (_currentStep == 0) {
        if (_formKey.currentState?.validate() ?? false) {
          setState(() => _currentStep++);
          _tabController.animateTo(_currentStep);
        }
      } else if (_currentStep == 1) {
        if (_selectedItems.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one product')),
          );
          return;
        }
        setState(() => _currentStep++);
        _tabController.animateTo(_currentStep);
      } else {
        setState(() => _currentStep++);
        _tabController.animateTo(_currentStep);
      }
    } else {
      await _createOrder();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _tabController.animateTo(_currentStep);
    }
  }

  void _toggleProductSelection(Product product) {
    setState(() {
      final existingIndex =
          _selectedItems.indexWhere((item) => item.productId == product.id);

      if (existingIndex >= 0) {
        _selectedItems.removeAt(existingIndex);
        _itemQuantities.remove(product.id);
      } else {
        final orderItem = OrderItem(
          id: 'item_${DateTime.now().millisecondsSinceEpoch}',
          productId: product.id,
          productName: product.name,
          category: product.category.toString().split('.').last,
          price: product.basePrice,
          quantity: 1,
          customizations: {},
        );
        _selectedItems.add(orderItem);
        _itemQuantities[product.id] = 1;
      }
    });
  }

  void _updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      _toggleProductSelection(product);
      return;
    }

    setState(() {
      _itemQuantities[product.id] = quantity;

      final existingIndex =
          _selectedItems.indexWhere((item) => item.productId == product.id);
      if (existingIndex >= 0) {
        final updatedItem = OrderItem(
          id: _selectedItems[existingIndex].id,
          productId: product.id,
          productName: product.name,
          category: product.category.toString().split('.').last,
          price: product.basePrice,
          quantity: quantity,
          customizations: _selectedItems[existingIndex].customizations,
        );
        _selectedItems[existingIndex] = updatedItem;
      }
    });
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Cart'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _selectedItems.map((item) {
              return ListTile(
                title: Text(item.productName),
                subtitle: Text(
                    '₹${item.price.toStringAsFixed(0)} x ${item.quantity}'),
                trailing:
                    Text('₹${(item.price * item.quantity).toStringAsFixed(0)}'),
              );
            }).toList(),
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

  double _calculateTotal() {
    return _selectedItems.fold(
        0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _selectDeliveryDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      // Store the selected date for order creation
      setState(() {
        // _selectedDeliveryDate = picked;
      });
    }
  }

  String _formatDeliveryDate() {
    // Return formatted delivery date
    return DateFormat('MMM dd, yyyy')
        .format(DateTime.now().add(const Duration(days: 7)));
  }

  Future<void> _createOrder() async {
    setState(() => _isLoading = true);

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Create measurements map
      final measurements = <String, dynamic>{};
      _measurementControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          measurements[key.toLowerCase().replaceAll(' ', '_')] =
              controller.text;
        }
      });

      final success = await orderProvider.createOrder(
        customerId: authProvider.user?.uid ??
            'customer_${DateTime.now().millisecondsSinceEpoch}',
        items: _selectedItems,
        measurements: measurements,
        specialInstructions: _specialInstructionsController.text,
        orderImages: _orderImages,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully!')),
        );
        Navigator.of(context).pop(true); // Return to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to create order. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
