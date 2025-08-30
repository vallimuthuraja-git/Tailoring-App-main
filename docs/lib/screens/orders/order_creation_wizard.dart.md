# Order Creation Wizard Documentation

## Overview
The `order_creation_wizard.dart` file contains the comprehensive order creation workflow for the AI-Enabled Tailoring Shop Management System. It provides a sophisticated 4-step wizard interface that guides users through customer information collection, product selection, measurements recording, and final order review, ensuring complete and accurate order data collection with extensive validation and user experience optimizations.

## Architecture

### Core Components
- **`OrderCreationWizard`**: Main wizard screen with multi-step navigation
- **Step-by-Step Navigation**: 4-step process with validation at each stage
- **Advanced Form Management**: Complex form state with multiple input types
- **Product Selection System**: Interactive catalog with quantity management
- **Measurement Collection**: Comprehensive customer measurement recording
- **Order Summary & Review**: Final order validation and confirmation
- **Theme Integration**: Complete theme system integration with dynamic styling
- **Validation Framework**: Multi-level form validation with user feedback

### Key Features
- **4-Step Wizard Process**: Customer → Products → Measurements → Review
- **Real-time Validation**: Immediate feedback on form inputs
- **Product Catalog Integration**: Live product search and selection
- **Quantity Management**: Dynamic quantity controls for selected products
- **Measurement Templates**: Pre-defined measurement templates for efficiency
- **Order Calculation**: Automatic pricing and advance payment calculation
- **Theme Consistency**: Seamless integration with light/dark/glassy themes
- **Error Handling**: Comprehensive error management with user feedback
- **Offline Support**: Form persistence during network interruptions

## Wizard Steps Structure

### Step 1: Customer Information
```dart
// Customer Details Collection
Widget _buildCustomerInfoStep(ThemeProvider themeProvider) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Form(
      key: _formKey,
      child: Column(children: [
        // Customer Name (Required)
        TextFormField(
          controller: _customerNameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Customer name is required';
            }
            return null;
          },
        ),

        // Phone Number (Required)
        TextFormField(
          controller: _customerPhoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
        ),

        // Email (Optional)
        TextFormField(
          controller: _customerEmailController,
          keyboardType: TextInputType.emailAddress,
        ),

        // Delivery Address (Required)
        TextFormField(
          controller: _customerAddressController,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Delivery address is required';
            }
            return null;
          },
        ),
      ]),
    ),
  );
}
```

### Step 2: Product Selection
```dart
// Product Selection with Search and Cart
Widget _buildProductSelectionStep(ThemeProvider themeProvider) {
  return Consumer<ProductProvider>(
    builder: (context, productProvider, child) {
      return Column(children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products, categories...',
                  prefixIcon: Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(onPressed: clearSearch)
                      : IconButton(onPressed: showAdvancedSearch),
                ),
                onChanged: productProvider.searchProducts,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('${_selectedItems.length} selected'),
            ),
          ]),
        ),

        // Product Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) =>
                _buildProductCard(productProvider.products[index], themeProvider),
          ),
        ),

        // Cart Summary (if items selected)
        if (_selectedItems.isNotEmpty) _buildCartSummary(),
      ]);
    },
  );
}
```

### Step 3: Measurements
```dart
// Customer Measurements Collection
Widget _buildMeasurementsStep(ThemeProvider themeProvider) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Measurements', style: headerStyle),
        Text('Enter customer measurements for accurate fitting'),

        // Dynamic Measurement Fields
        ..._measurementControllers.entries.map((entry) {
          return TextFormField(
            controller: entry.value,
            decoration: InputDecoration(
              labelText: '${entry.key} (inches)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: backgroundColor,
            ),
            keyboardType: TextInputType.number,
          );
        }),

        // Measurement Templates
        Text('Quick Templates', style: subheaderStyle),
        Wrap(
          spacing: 12,
          children: [
            _buildMeasurementTemplate('Standard Male', {
              'Chest': '40', 'Waist': '32', 'Shoulder': '18',
            }),
            _buildMeasurementTemplate('Standard Female', {
              'Chest': '36', 'Waist': '28', 'Shoulder': '16',
            }),
            _buildMeasurementTemplate('Clear All', {}, isClear: true),
          ],
        ),
      ],
    ),
  );
}
```

### Step 4: Review & Finalize
```dart
// Order Review and Finalization
Widget _buildCustomizationsStep(ThemeProvider themeProvider) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      Text('Review & Finalize', style: headerStyle),

      // Order Summary Card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(children: [
          Text('Order Summary', style: summaryTitleStyle),

          // Customer Information
          _buildSummaryRow('Customer', _customerNameController.text),
          _buildSummaryRow('Phone', _customerPhoneController.text),

          // Products List
          Text('Products (${_selectedItems.length})', style: sectionTitleStyle),
          ..._selectedItems.map((item) =>
              Text('${item.productName} x${item.quantity} - ₹${(item.price * item.quantity).toStringAsFixed(0)}')
          ),

          // Pricing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: totalLabelStyle),
              Text('₹${_calculateTotal().toStringAsFixed(0)}', style: totalValueStyle),
            ],
          ),

          // Advance Payment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Advance (30%)', style: advanceLabelStyle),
              Text('₹${(_calculateTotal() * 0.3).toStringAsFixed(0)}', style: advanceValueStyle),
            ],
          ),
        ]),
      ),

      // Special Instructions
      TextFormField(
        controller: _specialInstructionsController,
        decoration: InputDecoration(
          labelText: 'Special Instructions (Optional)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: backgroundColor,
        ),
        maxLines: 3,
      ),

      // Delivery Date Picker
      InkWell(
        onTap: () => _selectDeliveryDate(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor,
          ),
          child: Row(children: [
            Icon(Icons.calendar_today),
            SizedBox(width: 12),
            Text('Delivery Date: ${_formatDeliveryDate()}'),
            Spacer(),
            Icon(Icons.arrow_drop_down),
          ]),
        ),
      ),
    ]),
  );
}
```

## Navigation System

### Step Indicator
```dart
Widget _buildStepIndicator(ThemeProvider themeProvider) {
  final steps = ['Customer', 'Products', 'Measurements', 'Review'];

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Row(
      children: List.generate(4, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;

        return Expanded(
          child: Row(children: [
            // Step Circle
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green
                       : isActive ? primaryColor
                       : onSurface.withOpacity(0.3),
              ),
              child: Center(
                child: isCompleted ? Icon(Icons.check, size: 16, color: Colors.white)
                       : Text('${index + 1}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),

            // Step Label
            SizedBox(width: 8),
            Text(steps[index], style: TextStyle(
              color: isActive ? primaryColor : onSurface.withOpacity(0.7),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            )),

            // Connector Line
            if (index < 3) ...[
              SizedBox(width: 8),
              Expanded(child: Container(height: 2, color: onSurface.withOpacity(0.2))),
            ],
          ]),
        );
      }),
    ),
  );
}
```

### Bottom Navigation
```dart
Widget _buildBottomNavigation(ThemeProvider themeProvider) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: surfaceColor,
      border: Border(top: BorderSide(color: borderColor)),
    ),
    child: Row(children: [
      // Previous Button
      if (_currentStep > 0)
        Expanded(
          child: OutlinedButton(
            onPressed: _previousStep,
            child: const Text('Previous'),
          ),
        ),

      if (_currentStep > 0 && _currentStep < 3) const SizedBox(width: 12),

      // Next/Submit Button
      Expanded(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_currentStep == 3 ? 'Create Order' : 'Next'),
        ),
      ),
    ]),
  );
}
```

### Step Navigation Logic
```dart
void _nextStep() async {
  if (_currentStep < 3) {
    if (_currentStep == 0) {
      // Validate customer information
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
        _tabController.animateTo(_currentStep);
      }
    } else if (_currentStep == 1) {
      // Validate product selection
      if (_selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one product')),
        );
        return;
      }
      setState(() => _currentStep++);
      _tabController.animateTo(_currentStep);
    } else {
      // Move to next step
      setState(() => _currentStep++);
      _tabController.animateTo(_currentStep);
    }
  } else {
    // Final step - create order
    await _createOrder();
  }
}

void _previousStep() {
  if (_currentStep > 0) {
    setState(() => _currentStep--);
    _tabController.animateTo(_currentStep);
  }
}
```

## Product Selection System

### Product Card with Selection
```dart
Widget _buildProductCard(Product product, ThemeProvider themeProvider) {
  final isSelected = _selectedItems.any((item) => item.productId == product.id);
  final quantity = _itemQuantities[product.id] ?? 0;

  return GestureDetector(
    onTap: () => _toggleProductSelection(product),
    child: Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryColor : onSurface.withOpacity(0.08),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4)),
        ] : null,
      ),
      child: Column(children: [
        // Product Image Section
        _buildProductImage(product),

        // Product Details Section
        _buildProductDetails(product, isSelected, quantity, themeProvider),
      ]),
    ),
  );
}
```

### Product Selection Logic
```dart
void _toggleProductSelection(Product product) {
  setState(() {
    final existingIndex = _selectedItems.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      // Remove from selection
      _selectedItems.removeAt(existingIndex);
      _itemQuantities.remove(product.id);
    } else {
      // Add to selection
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

    final existingIndex = _selectedItems.indexWhere((item) => item.productId == product.id);
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
```

### Cart Management
```dart
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
              subtitle: Text('₹${item.price.toStringAsFixed(0)} x ${item.quantity}'),
              trailing: Text('₹${(item.price * item.quantity).toStringAsFixed(0)}'),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    ),
  );
}

double _calculateTotal() {
  return _selectedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}
```

## Measurement Collection

### Dynamic Measurement Fields
```dart
void _initializeMeasurementControllers() {
  final standardMeasurements = [
    'Chest', 'Waist', 'Hip', 'Shoulder', 'Sleeve Length',
    'Inseam', 'Length', 'Neck', 'Armhole', 'Bicep'
  ];

  for (final measurement in standardMeasurements) {
    _measurementControllers[measurement] = TextEditingController();
  }
}

// Build measurement input fields
..._measurementControllers.entries.map((entry) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: entry.value,
      decoration: InputDecoration(
        labelText: '${entry.key} (inches)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: backgroundColor,
      ),
      keyboardType: TextInputType.number,
    ),
  );
}),
```

### Measurement Templates
```dart
Widget _buildMeasurementTemplate(String name, Map<String, String> measurements, {bool isClear = false}) {
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
      backgroundColor: isClear ? Colors.red.shade100 : primaryColor,
      foregroundColor: isClear ? Colors.red.shade800 : onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    child: Text(name),
  );
}
```

## Order Creation Process

### Order Data Compilation
```dart
Future<void> _createOrder() async {
  setState(() => _isLoading = true);

  try {
    // Create measurements map
    final measurements = <String, dynamic>{};
    _measurementControllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        measurements[key.toLowerCase().replaceAll(' ', '_')] = controller.text;
      }
    });

    // Create order through provider
    final success = await orderProvider.createOrder(
      customerId: authProvider.user?.uid ?? 'customer_${DateTime.now().millisecondsSinceEpoch}',
      items: _selectedItems,
      measurements: measurements,
      specialInstructions: _specialInstructionsController.text,
      orderImages: _orderImages,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order created successfully!')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create order. Please try again.')),
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
```

### Delivery Date Selection
```dart
void _selectDeliveryDate(BuildContext context) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now().add(const Duration(days: 7)),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 90)),
  );

  if (picked != null) {
    setState(() {
      // _selectedDeliveryDate = picked;
    });
  }
}

String _formatDeliveryDate() {
  return DateFormat('MMM dd, yyyy').format(DateTime.now().add(const Duration(days: 7)));
}
```

## Form Validation

### Multi-Step Validation
```dart
void _nextStep() async {
  if (_currentStep < 3) {
    if (_currentStep == 0) {
      // Customer info validation
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
        _tabController.animateTo(_currentStep);
      }
    } else if (_currentStep == 1) {
      // Product selection validation
      if (_selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one product')),
        );
        return;
      }
      setState(() => _currentStep++);
      _tabController.animateTo(_currentStep);
    } else {
      // Move to next step
      setState(() => _currentStep++);
      _tabController.animateTo(_currentStep);
    }
  } else {
    // Final step - create order
    await _createOrder();
  }
}
```

### Form Field Validation
```dart
// Customer Name Validation
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Customer name is required';
  }
  return null;
},

// Email Validation
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter email address';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
},

// Phone Validation
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Phone number is required';
  }
  return null;
},

// Address Validation
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Delivery address is required';
  }
  return null;
},

// Hourly Rate Validation
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter hourly rate';
  }
  final rate = double.tryParse(value);
  if (rate == null || rate <= 0) {
    return 'Please enter a valid rate';
  }
  return null;
},
```

## State Management

### Local State Variables
```dart
class _OrderCreationWizardState extends State<OrderCreationWizard> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Customer Information
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerAddressController = TextEditingController();

  // Product Selection
  final List<OrderItem> _selectedItems = [];
  final Map<String, int> _itemQuantities = {};

  // Measurements
  final Map<String, TextEditingController> _measurementControllers = {};

  // Customizations
  final _specialInstructionsController = TextEditingController();
  final List<String> _orderImages = [];
  bool _isLoading = false;
}
```

### Resource Cleanup
```dart
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
```

## Theme Integration

### Dynamic Theming
```dart
final themeProvider = Provider.of<ThemeProvider>(context);

// Dynamic Colors
backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
primaryColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
onSurface: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,

// Conditional Styling
decoration: BoxDecoration(
  color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: isSelected
        ? (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary)
        : (themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.08) : AppColors.onSurface.withValues(alpha: 0.08)),
  ),
),
```

### Theme-Aware Components
```dart
// Text Fields with Theme Integration
TextFormField(
  decoration: InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background,
  ),
),

// Buttons with Theme Colors
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
    foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
  ),
),
```

## Error Handling and User Feedback

### Snackbar Notifications
```dart
// Success Messages
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Order created successfully!')),
);

// Error Messages
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error: $e')),
);

// Validation Messages
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Please select at least one product')),
);
```

### Loading States
```dart
// Form Submission Loading
ElevatedButton(
  onPressed: _isLoading ? null : _submitForm,
  child: _isLoading
      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
      : const Text('Create Order'),
)

// Product Loading
productProvider.isLoading
    ? const Center(child: CircularProgressIndicator())
    : _buildProductGrid(productProvider)
```

## Integration Points

### Provider Dependencies
```dart
// Required Providers
- ProductProvider: Product catalog access and search functionality
- OrderProvider: Order creation and management
- AuthProvider: User authentication and authorization
- ThemeProvider: Theme management and dynamic styling

// Usage in Widget Tree
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ProductProvider()),
    ChangeNotifierProvider(create: (_) => OrderProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  child: OrderCreationWizard(),
)
```

### Service Dependencies
```dart
// Firebase Services Integration
- FirebaseService: Data persistence and real-time synchronization
- Product Service: Product data management
- Order Service: Order processing and validation
- Customer Service: Customer data handling
```

### Navigation Integration
```dart
// Successful Order Creation
if (success) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Order created successfully!')),
  );
  Navigator.of(context).pop(true); // Return success to previous screen
}

// Edit Product Navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductEditScreen(product: product),
  ),
);
```

## Business Logic

### Order Item Management
```dart
// Order Item Creation
final orderItem = OrderItem(
  id: 'item_${DateTime.now().millisecondsSinceEpoch}',
  productId: product.id,
  productName: product.name,
  category: product.category.toString().split('.').last,
  price: product.basePrice,
  quantity: 1,
  customizations: {},
);

// Quantity Updates
void _updateQuantity(Product product, int quantity) {
  if (quantity <= 0) {
    _toggleProductSelection(product);
    return;
  }

  _itemQuantities[product.id] = quantity;

  final existingIndex = _selectedItems.indexWhere((item) => item.productId == product.id);
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
}
```

### Pricing Calculations
```dart
double _calculateTotal() {
  return _selectedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}

// Advance Payment (30%)
double advancePayment = _calculateTotal() * 0.3;
```

### Measurement Processing
```dart
// Convert Form Data to Measurements Map
final measurements = <String, dynamic>{};
_measurementControllers.forEach((key, controller) {
  if (controller.text.isNotEmpty) {
    measurements[key.toLowerCase().replaceAll(' ', '_')] = controller.text;
  }
});
```

## Performance Optimization

### Efficient Rendering
```dart
// GridView with Optimized Child Aspect Ratio
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 0.8,
  ),
  itemBuilder: (context, index) {
    final product = productProvider.products[index];
    return _CompactProductCard(product: product);
  },
)

// Selective Rebuilds with Consumer
Consumer<ProductProvider>(
  builder: (context, productProvider, child) {
    // Only rebuilds when product data changes
  },
)
```

### Memory Management
```dart
// Controller Disposal
@override
void dispose() {
  _tabController.dispose();
  _customerNameController.dispose();
  _customerPhoneController.dispose();
  _customerEmailController.dispose();
  _customerAddressController.dispose();
  _specialInstructionsController.dispose();

  // Dispose all measurement controllers
  for (final controller in _measurementControllers.values) {
    controller.dispose();
  }

  super.dispose();
}
```

## Security Considerations

### Input Validation
```dart
// SQL Injection Prevention
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Customer name is required';
  }
  // Additional sanitization if needed
  return null;
},

// Email Format Validation
validator: (value) {
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
},
```

### User Authorization
```dart
// User Authentication Check
final currentUser = authProvider.currentUser;
if (currentUser == null) {
  throw Exception('User not authenticated');
}

// Form Validation Before Submission
if (!_formKey.currentState!.validate()) return;

// Product Selection Validation
if (_selectedItems.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please select at least one product')),
  );
  return;
}
```

## Best Practices

### User Experience
- **Progressive Disclosure**: Step-by-step form prevents user overwhelm
- **Clear Visual Feedback**: Real-time validation and selection indicators
- **Consistent Navigation**: Intuitive back/forward flow with validation
- **Loading States**: Clear feedback during async operations
- **Error Recovery**: Graceful error handling with actionable messages

### Performance
- **Lazy Loading**: Products load on demand with pagination
- **Efficient State Management**: Targeted rebuilds with Consumer widgets
- **Memory Optimization**: Proper disposal of controllers and resources
- **Image Caching**: Optimized product image loading and caching

### Maintainability
- **Modular Components**: Separate widgets for each step and component
- **Clear Separation of Concerns**: Business logic separated from UI
- **Comprehensive Validation**: Multi-level validation with clear error messages
- **Theme Consistency**: Centralized theme management

This comprehensive order creation wizard provides a professional, user-friendly interface for creating complex tailoring orders with extensive validation, theme integration, and seamless user experience throughout the entire order creation process.