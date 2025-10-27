import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/theme_constants.dart';

class ServiceBookingWizard extends StatefulWidget {
  final Service service;
  final Map<String, dynamic> selectedCustomizations;
  final double customizationTotalPrice;

  const ServiceBookingWizard(
      {required this.service,
      this.selectedCustomizations = const {},
      this.customizationTotalPrice = 0.0,
      super.key});

  @override
  State<ServiceBookingWizard> createState() => _ServiceBookingWizardState();
}

class _ServiceBookingWizardState extends State<ServiceBookingWizard>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Customer Information
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // Step 2: Measurements (if required)
  final Map<String, TextEditingController> _measurementControllers = {};

  // Step 2: Date/Time Selection
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;
  List<DateTime> _availableDates = [];
  List<String> _availableTimeSlots = [];
  bool _checkingAvailability = false;

  // Step 3: Measurements (if required) - already declared above, keeping reference

  // Step 4: Payment Integration
  String _selectedPaymentMethod = 'card'; // card, upi, netBanking
  bool _agreeToTerms = false;
  bool _processingPayment = false;

  // Additional validation state
  String? _dateError;
  String? _timeSlotError;

  // Step 5: Special Instructions
  final _instructionsController = TextEditingController();

  bool _isLoading = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Always 4 steps: Customer Info, Date/Time, Measurements (if required), Payment
    final length = widget.service.requiresMeasurement ? 4 : 3;
    _tabController = TabController(length: length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentStep = _tabController.index;
      });
    });

    _loadAvailabilityData();

    // Auto-fill with user info if available
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      _customerNameController.text =
          authProvider.currentUser!.displayName ?? '';
      // Assume email and phone from user data if available
    }
  }

  Future<void> _loadAvailabilityData() async {
    setState(() => _checkingAvailability = true);

    try {
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);
      _availableDates =
          await serviceProvider.getAvailableDates(widget.service.id);
      _availableTimeSlots = await serviceProvider.getAvailableTimeSlots(
          widget.service.id, _selectedDate);
    } catch (e) {
      // Use default availability if service call fails
      _availableDates =
          List.generate(30, (i) => DateTime.now().add(Duration(days: i + 1)));
      _availableTimeSlots = [
        '09:00 - 11:00',
        '11:00 - 13:00',
        '14:00 - 16:00',
        '16:00 - 18:00'
      ];
    } finally {
      if (mounted) setState(() => _checkingAvailability = false);
    }
  }

  void _initializeControllers() {
    // Standard measurements for tailoring
    const measurements = [
      'Chest',
      'Waist',
      'Hip',
      'Shoulder',
      'Sleeve Length',
      'Inseam',
      'Length',
      'Neck'
    ];

    if (widget.service.requiresMeasurement) {
      for (final measurement in measurements) {
        _measurementControllers[measurement] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    for (final controller in _measurementControllers.values) {
      controller.dispose();
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book ${widget.service.name}',
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
        ),
        backgroundColor: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        titleTextStyle: TextStyle(
          fontSize: 18,
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface
              : AppColors.onSurface,
        ),
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface
              : AppColors.onSurface,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: _buildStepIndicator(themeProvider),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCustomerInfoStep(themeProvider),
                _buildDateTimeStep(themeProvider),
                if (widget.service.requiresMeasurement)
                  _buildMeasurementsStep(themeProvider),
                _buildPaymentStep(themeProvider),
              ],
            ),
      bottomNavigationBar: _buildBottomNavigation(themeProvider),
    );
  }

  Widget _buildStepIndicator(ThemeProvider themeProvider) {
    final steps = widget.service.requiresMeasurement
        ? ['Customer Info', 'Date/Time', 'Measurements', 'Payment']
        : ['Customer Info', 'Date/Time', 'Payment'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: List.generate(steps.length, (index) {
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
                                fontWeight: FontWeight.w600),
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
                    fontSize: 12,
                  ),
                ),
                if (index < steps.length - 1) ...[
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
              'Please provide your contact information',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Customer Name
            _buildValidatedTextField(
              controller: _customerNameController,
              label: 'Full Name *',
              prefixIcon: Icons.person,
              validator: _validateCustomerName,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 16),

            // Phone Number
            _buildValidatedTextField(
              controller: _phoneController,
              label: 'Phone Number *',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: _validatePhoneNumber,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 16),

            // Email
            _buildValidatedTextField(
              controller: _emailController,
              label: 'Email (Optional)',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 16),

            // Address
            _buildValidatedTextField(
              controller: _addressController,
              label: 'Delivery Address *',
              prefixIcon: Icons.location_on,
              maxLines: 3,
              validator: _validateAddress,
              themeProvider: themeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int? maxLines,
    required String? Function(String?) validator,
    required ThemeProvider themeProvider,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.background,
        errorText: errorText,
      ),
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines ?? 1,
      validator: validator,
      onChanged: (_) {
        if (errorText != null) {
          setState(() {
            // Clear error when user types
            if (validator(_) == null) {
              _clearFieldError(label);
            }
          });
        }
      },
    );
  }

  void _clearFieldError(String label) {
    // Clear field-specific errors
    // Error fields have been simplified for this implementation
    // Additional error handling can be added as needed
  }

  String? _validateCustomerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final RegExp phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      final RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\.\w+$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter delivery address';
    }
    if (value.length < 10) {
      return 'Please provide a complete address';
    }
    return null;
  }

  Widget _buildDateTimeStep(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Your Service',
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
            'Choose your preferred date and time slot',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Date Selection
          Text(
            'Select Date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _checkingAvailability
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableDates.length,
                    itemBuilder: (context, index) {
                      final date = _availableDates[index];
                      final isSelected = date.day == _selectedDate.day &&
                          date.month == _selectedDate.month &&
                          date.year == _selectedDate.year;
                      final isAvailable = date.weekday != DateTime.saturday &&
                          date.weekday != DateTime.sunday;

                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => _selectDate(date),
                          child: Card(
                            color: isSelected
                                ? (themeProvider.isDarkMode
                                    ? DarkAppColors.primary
                                    : AppColors.primary)
                                : (themeProvider.isDarkMode
                                    ? DarkAppColors.surface
                                    : AppColors.surface),
                            elevation: isSelected ? 4 : 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    [
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat',
                                      'Sun'
                                    ][date.weekday - 1],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? (themeProvider.isDarkMode
                                              ? DarkAppColors.onPrimary
                                              : AppColors.onPrimary)
                                          : (themeProvider.isDarkMode
                                              ? DarkAppColors.onSurface
                                              : AppColors.onSurface),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? (themeProvider.isDarkMode
                                              ? DarkAppColors.onPrimary
                                              : AppColors.onPrimary)
                                          : (themeProvider.isDarkMode
                                              ? DarkAppColors.onBackground
                                              : AppColors.onBackground),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (_dateError != null) ...[
            const SizedBox(height: 8),
            Text(
              _dateError!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],

          const SizedBox(height: 32),

          // Time Slot Selection
          Text(
            'Select Time Slot',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _availableTimeSlots.map((slot) {
              final isSelected = _selectedTimeSlot == slot;
              final isAvailable = !_availabilityConflicts.contains(slot);
              debugPrint('Time slot ${slot}: availability = $isAvailable');

              return SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 26,
                child: InkWell(
                  onTap: isAvailable ? () => _selectTimeSlot(slot) : null,
                  child: Card(
                    color: isSelected
                        ? (themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary)
                        : !isAvailable
                            ? Colors.grey.shade300
                            : (themeProvider.isDarkMode
                                ? DarkAppColors.surface
                                : AppColors.surface),
                    elevation: isSelected ? 4 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      child: Column(
                        children: [
                          Text(
                            slot,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? (themeProvider.isDarkMode
                                      ? DarkAppColors.onPrimary
                                      : AppColors.onPrimary)
                                  : !isAvailable
                                      ? Colors.grey
                                      : (themeProvider.isDarkMode
                                          ? DarkAppColors.onSurface
                                          : AppColors.onSurface),
                            ),
                          ),
                          if (!isAvailable) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Unavailable',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (_timeSlotError != null) ...[
            const SizedBox(height: 8),
            Text(
              _timeSlotError!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTimeSlot = null; // Reset time slot when date changes
      _dateError = null;
      _timeSlotError = null;
    });
    _loadTimeSlotsForDate(date);
  }

  void _selectTimeSlot(String slot) {
    setState(() {
      _selectedTimeSlot = slot;
      _timeSlotError = null;
    });
  }

  Future<void> _loadTimeSlotsForDate(DateTime date) async {
    setState(() => _checkingAvailability = true);

    try {
      final serviceProvider =
          Provider.of<ServiceProvider>(context, listen: false);
      _availableTimeSlots =
          await serviceProvider.getAvailableTimeSlots(widget.service.id, date);

      // Mock conflicts for demo
      _availabilityConflicts = date.weekday % 3 == 0 ? ['11:00 - 13:00'] : [];
    } catch (e) {
      // Fallback
      _availableTimeSlots = ['09:00 - 11:00', '11:00 - 13:00', '14:00 - 16:00'];
    } finally {
      if (mounted) setState(() => _checkingAvailability = false);
    }
  }

  List<String> _availabilityConflicts = [];

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
            'Please provide accurate measurements for the best fit',
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
        ],
      ),
    );
  }

  Widget _buildPaymentStep(ThemeProvider themeProvider) {
    final basePrice = widget.service.effectivePrice;
    final customizationPrice = widget.customizationTotalPrice;
    final subtotal = basePrice + customizationPrice;
    final taxRate = 0.08; // 8% tax
    final taxAmount = subtotal * taxRate;
    final totalAmount = subtotal + taxAmount;
    final advanceAmount = totalAmount * 0.3; // 30% advance
    final remainingAmount = totalAmount - advanceAmount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment',
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
            'Complete your service booking by selecting a payment method',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Service & Schedule Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.build, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(widget.service.name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${widget.service.estimatedHours} hours'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.event, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at ${_selectedTimeSlot ?? 'Time not selected'}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (widget.selectedCustomizations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customizations:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...widget.selectedCustomizations.entries
                        .map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Text('${entry.key}: ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  Expanded(child: Text(entry.value.toString())),
                                ],
                              ),
                            )),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Price Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Price Breakdown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildPriceRow(
                      'Service', '\$${basePrice.toStringAsFixed(2)}'),
                  _buildPriceRow('Customizations',
                      '\$${customizationPrice.toStringAsFixed(2)}'),
                  _buildPriceRow(
                      'Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                  const Divider(),
                  _buildPriceRow(
                      'Tax (8%)', '\$${taxAmount.toStringAsFixed(2)}'),
                  _buildPriceRow(
                      'Total Amount', '\$${totalAmount.toStringAsFixed(2)}',
                      isBold: true),
                  const Divider(),
                  _buildPriceRow('Advance Payment (30%)',
                      '\$${advanceAmount.toStringAsFixed(2)}',
                      isHighlighted: true),
                  _buildPriceRow(
                      'Balance Due', '\$${remainingAmount.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Payment Method Selection
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildPaymentMethodOption('card', 'Credit/Debit Card',
                  Icons.credit_card, themeProvider),
              _buildPaymentMethodOption(
                  'upi', 'UPI', Icons.smartphone, themeProvider),
              _buildPaymentMethodOption('netBanking', 'Net Banking',
                  Icons.account_balance, themeProvider),
            ],
          ),

          const SizedBox(height: 24),

          // Terms Acceptance
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                activeColor: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
              ),
              Expanded(
                child: Text(
                  'I agree to the terms and conditions and authorize the advance payment',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface
                        : AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Process Payment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _processingPayment
                  ? null
                  : () {
                      if (!_agreeToTerms) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please accept the terms and conditions')),
                        );
                        return;
                      }

                      if (_selectedPaymentMethod.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select a payment method')),
                        );
                        return;
                      }

                      _processPayment(advanceAmount);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _agreeToTerms
                    ? (themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary)
                    : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _processingPayment
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Processing...'),
                      ],
                    )
                  : const Text(
                      'Pay Advance & Confirm Booking',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount,
      {bool isBold = false, bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.greenAccent
                      : Colors.green[700])
                  : null,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.greenAccent
                      : Colors.green[700])
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
      String method, String label, IconData icon, ThemeProvider themeProvider) {
    final isSelected = _selectedPaymentMethod == method;
    return Card(
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentMethod = method),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? (themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary)
                    : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? (themeProvider.isDarkMode
                            ? DarkAppColors.primary
                            : AppColors.primary)
                        : (themeProvider.isDarkMode
                            ? DarkAppColors.onSurface
                            : AppColors.onSurface),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(double amount) async {
    setState(() => _processingPayment = true);

    try {
      // Mock payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock payment success/failure
      final success = true; // Simulating payment success

      if (success) {
        // Process the booking after successful payment
        await _createServiceOrder();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: $e')),
      );
    } finally {
      if (mounted) setState(() => _processingPayment = false);
    }
  }

  Future<void> _createServiceOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Create service order with scheduling and payment info
      final measurements = <String, dynamic>{};
      _measurementControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          measurements[key.toLowerCase().replaceAll(' ', '_')] =
              controller.text;
        }
      });

      // Add scheduling data to measurements
      measurements['preferred_date'] = _selectedDate.toIso8601String();
      measurements['preferred_time_slot'] = _selectedTimeSlot;
      measurements['payment_method'] = _selectedPaymentMethod;

      final orderItem = OrderItem(
        id: 'service_${widget.service.id}_${DateTime.now().millisecondsSinceEpoch}',
        productId: widget.service.id,
        productName: widget.service.name,
        category: widget.service.category.name,
        price: widget.service.effectivePrice + widget.customizationTotalPrice,
        quantity: 1,
        customizations: widget.selectedCustomizations,
        notes: _instructionsController.text,
      );

      final success = await orderProvider.createOrder(
        customerId: authProvider.currentUser?.uid ??
            'customer_${DateTime.now().millisecondsSinceEpoch}',
        items: [orderItem],
        measurements: measurements,
        specialInstructions: _instructionsController.text,
        orderImages: [],
        preferredDate: _selectedDate.toIso8601String(),
        preferredTimeSlot: _selectedTimeSlot,
        paymentMethod: _selectedPaymentMethod,
        advanceAmount: (orderItem.price * 1.08 * 0.3),
        remainingAmount: (orderItem.price * 1.08 * 0.7),
      );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service booked successfully!')),
        );
        Navigator.of(context).pop(true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to book service. Please try again.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          if (_currentStep > 0) const SizedBox(width: 12),
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
                  : Text(_isLastStep() ? 'Book Service' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    final maxSteps = widget.service.requiresMeasurement ? 4 : 3;

    if (_currentStep < maxSteps - 1) {
      _tabController.animateTo(_currentStep + 1);
      return;
    }

    // If it's the last step (payment), validate and process
    if (_currentStep == maxSteps - 1) {
      if (_selectedTimeSlot == null) {
        setState(() => _timeSlotError = 'Please select a time slot');
        _tabController.animateTo(1); // Go back to date/time step
        return;
      }

      if (_selectedPaymentMethod.isEmpty || !_agreeToTerms) {
        // Stay on payment step for validation
        return;
      }

      _processPayment(
          (widget.service.effectivePrice + widget.customizationTotalPrice) *
              1.08 *
              0.3);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _tabController.animateTo(_currentStep - 1);
    }
  }

  bool _isLastStep() {
    final maxSteps = widget.service.requiresMeasurement ? 4 : 3;
    return _currentStep == maxSteps - 1;
  }
}
