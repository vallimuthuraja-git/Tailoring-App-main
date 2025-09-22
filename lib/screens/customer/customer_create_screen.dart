import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';

class CustomerCreateScreen extends StatefulWidget {
  const CustomerCreateScreen({super.key});

  @override
  State<CustomerCreateScreen> createState() => _CustomerCreateScreenState();
}

class _CustomerCreateScreenState extends State<CustomerCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _photoUrlController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // Measurement controllers
  final Map<String, TextEditingController> _measurementControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize measurement controllers
    _initializeMeasurementControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    for (final controller in _measurementControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeMeasurementControllers() {
    final measurementCategories = {
      'chest': 'Chest',
      'waist': 'Waist',
      'shoulder': 'Shoulder',
      'neck': 'Neck',
      'sleeveLength': 'Sleeve Length',
      'inseam': 'Inseam',
      'hip': 'Hip',
      'bicep': 'Bicep',
      'wrist': 'Wrist',
    };

    for (final entry in measurementCategories.entries) {
      _measurementControllers[entry.key] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Customer'),
        backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
        foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: themeProvider.isDarkMode
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        DarkAppColors.background,
                        DarkAppColors.surface,
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.05),
                        AppColors.background,
                      ],
                    ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: themeProvider.isDarkMode ? DarkAppColors.primary.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_add,
                              size: 64,
                              color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Create New Customer Profile',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a new customer to your tailoring shop database',
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Basic Information Section
                      _buildSectionHeader('Basic Information', Icons.person, themeProvider),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter customer full name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                        themeProvider: themeProvider,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Enter email address',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email address';
                          }
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        themeProvider: themeProvider,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter phone number (10 digits)',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          final phoneRegex = RegExp(r'^\d{10}$');
                          if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                        themeProvider: themeProvider,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _photoUrlController,
                        label: 'Photo URL (Optional)',
                        hint: 'Enter photo URL or leave empty',
                        icon: Icons.photo,
                        themeProvider: themeProvider,
                      ),

                      const SizedBox(height: 32),

                      // Measurements Section
                      _buildSectionHeader('Body Measurements', Icons.straighten, themeProvider),
                      const SizedBox(height: 16),
                      _buildMeasurementsGrid(themeProvider),

                      const SizedBox(height: 32),

                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createCustomer,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                                foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Create Customer'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeProvider themeProvider) {
    return Row(
      children: [
        Icon(
          icon,
          color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    required ThemeProvider themeProvider,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.3) : AppColors.onSurface.withValues(alpha: 0.3),
          ),
        ),
        filled: true,
        fillColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
        labelStyle: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
        ),
        hintStyle: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.5) : AppColors.onSurface.withValues(alpha: 0.5),
        ),
      ),
      style: TextStyle(
        color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildMeasurementsGrid(ThemeProvider themeProvider) {
    final measurements = [
      {'key': 'chest', 'label': 'Chest', 'unit': 'inches'},
      {'key': 'waist', 'label': 'Waist', 'unit': 'inches'},
      {'key': 'shoulder', 'label': 'Shoulder', 'unit': 'inches'},
      {'key': 'neck', 'label': 'Neck', 'unit': 'inches'},
      {'key': 'sleeveLength', 'label': 'Sleeve Length', 'unit': 'inches'},
      {'key': 'inseam', 'label': 'Inseam', 'unit': 'inches'},
      {'key': 'hip', 'label': 'Hip', 'unit': 'inches'},
      {'key': 'bicep', 'label': 'Bicep', 'unit': 'inches'},
      {'key': 'wrist', 'label': 'Wrist', 'unit': 'inches'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      itemCount: measurements.length,
      itemBuilder: (context, index) {
        final measurement = measurements[index];
        return _buildMeasurementField(
          measurement['key'] as String,
          measurement['label'] as String,
          measurement['unit'] as String,
          themeProvider,
        );
      },
    );
  }

  Widget _buildMeasurementField(String key, String label, String unit, ThemeProvider themeProvider) {
    return TextFormField(
      controller: _measurementControllers[key],
      decoration: InputDecoration(
        labelText: '$label ($unit)',
        hintText: '0.0',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.3) : AppColors.onSurface.withValues(alpha: 0.3),
          ),
        ),
        filled: true,
        fillColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
        labelStyle: TextStyle(
          fontSize: 12,
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
        ),
        hintStyle: TextStyle(
          fontSize: 12,
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.5) : AppColors.onSurface.withValues(alpha: 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      style: TextStyle(
        fontSize: 14,
        color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final number = double.tryParse(value);
          if (number == null) {
            return 'Invalid number';
          }
          if (number <= 0) {
            return 'Must be positive';
          }
        }
        return null;
      },
    );
  }

  void _createCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);

      // Collect measurements
      final measurements = <String, dynamic>{};
      _measurementControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          final value = double.tryParse(controller.text);
          if (value != null) {
            measurements[key] = value;
          }
        }
      });

      // Create customer
      final success = await customerProvider.createCustomerProfile(
        userId: DateTime.now().millisecondsSinceEpoch.toString(), // Generate unique ID
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        photoUrl: _photoUrlController.text.trim().isEmpty ? null : _photoUrlController.text.trim(),
        initialMeasurements: measurements.isEmpty ? null : measurements,
        preferences: [], // Empty preferences for new customers
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer created successfully!')),
        );
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = customerProvider.errorMessage ?? 'Failed to create customer';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
