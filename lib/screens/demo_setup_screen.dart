import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/setup_demo_employees.dart';
import '../services/demo_work_assignments_service.dart';
import '../services/setup_demo_orders.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../utils/theme_constants.dart';

class DemoSetupScreen extends StatefulWidget {
  const DemoSetupScreen({super.key});

  @override
  State<DemoSetupScreen> createState() => _DemoSetupScreenState();
}

class _DemoSetupScreenState extends State<DemoSetupScreen> {
  bool _isLoading = false;
  String? _statusMessage;
  bool _setupComplete = false;

  final SetupDemoEmployees _setupService = SetupDemoEmployees();
  final DemoWorkAssignmentsService _workAssignmentsService = DemoWorkAssignmentsService();
  final SetupDemoOrders _demoOrdersSetup = SetupDemoOrders();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Demo Setup'),
            backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
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
          body: Container(
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
                        AppColors.primary.withOpacity(0.05),
                        AppColors.background,
                      ],
                    ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
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
                          color: themeProvider.isDarkMode ? DarkAppColors.primary.withOpacity(0.3) : AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.build,
                            size: 64,
                            color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Demo Employee Setup',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create demo employee accounts for testing the employee management system',
                            style: TextStyle(
                              fontSize: 16,
                              color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withOpacity(0.7) : AppColors.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Demo Accounts Info
                    Text(
                      'Demo Employee Accounts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildDemoAccountCard(
                      'General Employee',
                      'employee@demo.com',
                      'General employee with basic tailoring skills',
                      Icons.work,
                      themeProvider,
                    ),
                    const SizedBox(height: 12),

                    _buildDemoAccountCard(
                      'Master Tailor',
                      'tailor@demo.com',
                      'Experienced tailor with advanced skills',
                      Icons.content_cut,
                      themeProvider,
                    ),
                    const SizedBox(height: 12),

                    _buildDemoAccountCard(
                      'Fabric Cutter',
                      'cutter@demo.com',
                      'Specialist in fabric cutting and patterns',
                      Icons.cut,
                      themeProvider,
                    ),
                    const SizedBox(height: 12),

                    _buildDemoAccountCard(
                      'Finisher',
                      'finisher@demo.com',
                      'Specialist in final touches and quality control',
                      Icons.check_circle,
                      themeProvider,
                    ),

                    const SizedBox(height: 32),

                    // Status Message
                    if (_statusMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _setupComplete
                              ? Colors.green.shade50
                              : themeProvider.isDarkMode
                                  ? DarkAppColors.surface
                                  : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _setupComplete ? Colors.green : Colors.blue,
                          ),
                        ),
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(
                            color: _setupComplete ? Colors.green.shade700 : null,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Setup Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _setupDemoEmployees,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(_isLoading ? 'Setting up...' : 'Setup Demo Employees'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                          foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cleanup Button
                    if (_setupComplete)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _cleanupDemoEmployees,
                          icon: const Icon(Icons.delete),
                          label: const Text('Cleanup Demo Employees'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: themeProvider.isDarkMode ? DarkAppColors.error : AppColors.error,
                            ),
                            foregroundColor: themeProvider.isDarkMode ? DarkAppColors.error : AppColors.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Demo Orders Section
                    Text(
                      'Demo Orders Setup',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withOpacity(0.3) : AppColors.onSurface.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            size: 48,
                            color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Create demo orders and customers',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Set up realistic customer profiles, orders, and work assignments for testing',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withOpacity(0.7) : AppColors.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _setupDemoOrders,
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('Setup Demo Orders'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                                foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Instructions
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withOpacity(0.3) : AppColors.onSurface.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Instructions:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '1. Click "Setup Demo Employees" to create demo accounts\n'
                            '2. Go back to login screen\n'
                            '3. Click "Demo Partner" button\n'
                            '4. Choose an employee role to login\n'
                            '5. Use password: password123 for all accounts',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withOpacity(0.7) : AppColors.onSurface.withOpacity(0.7),
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
        );
      },
    );
  }

  Widget _buildDemoAccountCard(String role, String email, String description, IconData icon, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withOpacity(0.3) : AppColors.onSurface.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? DarkAppColors.primary.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withOpacity(0.7) : AppColors.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withOpacity(0.6) : AppColors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setupDemoEmployees() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Setting up demo employees...';
    });

    try {
      // First setup the employee accounts
      await _setupService.setupAllDemoEmployees();

      setState(() {
        _statusMessage = 'Setting up work assignments...';
      });

      // Then create work assignments for each employee
      await _workAssignmentsService.createDemoWorkAssignments();

      setState(() {
        _statusMessage = 'Setting up demo orders...';
      });

      // Setup demo orders using the loaded data
      // For this demo setup, we need to provide providers
      // Since we don't have context in this method, we'll note that orders setup
      // can be done separately or integrated in the main app
      print('Note: Demo orders can be set up using SetupDemoOrders with ProductProvider and OrderProvider');

      setState(() {
        _isLoading = false;
        _setupComplete = true;
        _statusMessage = '✅ Demo setup complete!\n\nEmployees, work assignments, and notes on orders setup.\nYou can now login using the demo employee accounts.\n\nTo setup demo orders, use the order setup functionality separately.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error setting up demo: $e';
      });
    }
  }

  Future<void> _cleanupDemoEmployees() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Cleaning up demo data...';
    });

    try {
      // Clean up work assignments first
      await _workAssignmentsService.cleanupDemoAssignments();

      // Then clean up employees
      await _setupService.cleanupDemoEmployees();

      setState(() {
        _isLoading = false;
        _setupComplete = false;
        _statusMessage = '✅ Demo data cleaned up successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error cleaning up demo data: $e';
      });
    }
  }

  Future<void> _setupDemoOrders() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Setting up demo orders...';
    });

    try {
      // Create instance of providers if needed, but use context
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      await _demoOrdersSetup.initializeDemoOrdersIfNeeded(
        productProvider: productProvider,
        orderProvider: orderProvider,
      );

      setState(() {
        _isLoading = false;
        _statusMessage = '✅ Demo orders setup complete!\nCustomers and orders have been created.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error setting up demo orders: $e';
      });
    }
  }
}