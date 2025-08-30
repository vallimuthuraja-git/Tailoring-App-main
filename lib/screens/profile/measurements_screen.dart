import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _measurements = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);

    if (authProvider.userProfile?.id != null) {
      setState(() => _isLoading = true);

      await customerProvider.loadCustomerProfile(authProvider.userProfile!.id);

      setState(() {
        _measurements = Map<String, dynamic>.from(
          customerProvider.currentCustomer?.measurements ?? {}
        );
        _isLoading = false;
        _isInitialized = true;
      });
    }
  }

  Future<void> _saveMeasurements() async {
    if (!_isInitialized) return;

    setState(() => _isLoading = true);

    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final success = await customerProvider.updateMeasurements(_measurements);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Measurements saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(customerProvider.errorMessage ?? 'Failed to save measurements'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    if (_isLoading && !_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Measurements'),
          backgroundColor: themeProvider.isDarkMode
              ? DarkAppColors.surface
              : AppColors.surface,
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              themeProvider.isDarkMode ? AppColors.primary : AppColors.primary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurements'),
        backgroundColor: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMeasurements,
            child: const Text('Save'),
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 800 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: themeProvider.isDarkMode
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.8),
                                    AppColors.primaryVariant.withValues(alpha: 0.9),
                                  ],
                                )
                              : const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryVariant,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.straighten,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Body Measurements',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Keep your measurements up to date for perfect fittings',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Measurement Sections
                      ...CustomerProvider.measurementCategories.entries.map(
                        (category) => _buildMeasurementSection(
                          category.key,
                          category.value,
                          CustomerProvider.standardMeasurements[category.key] ?? {},
                          themeProvider,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      if (_hasUnsavedChanges())
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveMeasurements,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Save Measurements',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                      // Guide Section
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Colors.blue.withValues(alpha: 0.1)
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'How to Take Measurements',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '• Take measurements while wearing form-fitting clothing\n'
                              '• Use a flexible tape measure for accuracy\n'
                              '• Keep the tape measure level and tight but not too tight\n'
                              '• Ask someone to help you for better accuracy\n'
                              '• Measurements should be taken on the right side of your body\n'
                              '• Stand straight with good posture when measuring',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade800,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementSection(
    String categoryKey,
    String categoryName,
    Map<String, String> measurements,
    ThemeProvider themeProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeProvider.isDarkMode
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onBackground
                    : AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            ...measurements.entries.map((measurement) => _buildMeasurementField(
              measurement.key,
              measurement.value,
              themeProvider,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementField(
    String measurementKey,
    String description,
    ThemeProvider themeProvider,
  ) {
    final currentValue = _measurements[measurementKey];
    final textController = TextEditingController(
      text: currentValue != null ? currentValue.toString() : '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatMeasurementName(measurementKey),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isDarkMode
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter measurement (inches)',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.grey.shade500,
                      ),
                    ),
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface
                          : AppColors.onSurface,
                    ),
                    onChanged: (value) {
                      final doubleValue = double.tryParse(value);
                      if (doubleValue != null) {
                        _measurements[measurementKey] = doubleValue;
                      } else if (value.isEmpty) {
                        _measurements.remove(measurementKey);
                      }
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Text(
                    'inches',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isDarkMode
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMeasurementName(String key) {
    final words = key.split(RegExp(r'(?=[A-Z])'));
    return words.join(' ').capitalizeFirst();
  }

  bool _hasUnsavedChanges() {
    if (!_isInitialized) return false;

    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final currentMeasurements = customerProvider.currentCustomer?.measurements ?? {};

    // Check if any measurement has changed
    for (final key in _measurements.keys) {
      if (currentMeasurements[key] != _measurements[key]) {
        return true;
      }
    }

    // Check if any measurement was removed
    for (final key in currentMeasurements.keys) {
      if (!_measurements.containsKey(key)) {
        return true;
      }
    }

    return false;
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}