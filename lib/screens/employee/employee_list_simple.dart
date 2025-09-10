import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/employee.dart' as emp;
import '../../models/user_role.dart';
import '../../services/firebase_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import 'employee_create_screen.dart';
import 'employee_detail_screen.dart';
import 'employee_edit_screen.dart';
import 'employee_performance_dashboard.dart';
import 'employee_dashboard_screen.dart';
import 'work_assignment_screen.dart';
import 'employee_analytics_screen.dart';
import 'employee_management_home.dart';

class EmployeeManagementHelper {
  // Use regular instance, not const
  static final FirebaseService _firebaseService = FirebaseService();

  static Future<void> populateDemoEmployees(BuildContext context, {bool silent = false}) async {
    try {
      if (!silent) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            title: Text('Adding Demo Employees'),
            content: CircularProgressIndicator(),
          ),
        );
      }

      // Create demo employees
      final demoEmployees = _createDemoEmployees();

      // Use Firebase operations through FirebaseService
      for (final employee in demoEmployees) {
        final employeeData = employee.toJson();
        // Don't include id in Firebase document data
        employeeData.remove('id');
        await _firebaseService.addDocument('employees', employeeData);
      }

      if (!silent) {
        Navigator.of(context).pop(); // Close loading dialog

        // Show success message
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Success!'),
            content: const Text('Added 5 demo employees to the database!\n\nEmployees added:\n• Esther (Owner)\n• Rajesh Kumar (Tailor)\n• Priya Sharma (Designer)\n• Amit Patel (Cutter)\n• Sneha Gupta (Finisher)'),
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
      if (!silent && context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (!silent) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Error'),
            content: Text('Failed to add demo employees: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Log error silently
        debugPrint('Failed to silently populate demo employees: $e');
      }
    }
  }

  // Check if any employees exist and auto-populate if needed
  static Future<bool> checkAndPopulateIfEmpty(BuildContext context) async {
    try {
      final querySnapshot = await _firebaseService.getCollection('employees');
      if (querySnapshot.docs.isEmpty) {
        debugPrint('No employees found. Auto-populating demo data...');
        await populateDemoEmployees(context, silent: true);
        return true; // Data was populated
      }
      return false; // Data already exists
    } catch (e) {
      debugPrint('Error checking for employees: $e');
      return false;
    }
  }

  // Force refresh employees
  static Future<void> forceRefreshEmployees(BuildContext context, Function onRefresh) async {
    await onRefresh();
  }

  static List<emp.Employee> _createDemoEmployees() {
    return [
      // Esther as the shop owner (first employee)
      emp.Employee(
        id: 'demo_owner',
        userId: 'demo_user_owner',
        displayName: 'Esther',
        email: 'shop@demo.com',
        phoneNumber: '+91-9876543210',
        role: UserRole.shopOwner,
        skills: [emp.EmployeeSkill.qualityCheck, emp.EmployeeSkill.alterations],
        specializations: ['Shop Management', 'Quality Assurance', 'Customer Service', 'Business Operations'],
        experienceYears: 8,
        certifications: ['Certified Master Tailor'],
        availability: emp.EmployeeAvailability.fullTime,
        preferredWorkDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        preferredStartTime: const emp.TimeOfDay(hour: 9, minute: 0),
        preferredEndTime: const emp.TimeOfDay(hour: 18, minute: 0),
        canWorkRemotely: false,
        location: 'Main Shop',
        totalOrdersCompleted: 0,
        ordersInProgress: 0,
        averageRating: 0.0,
        completionRate: 0.0,
        strengths: [],
        areasForImprovement: [],
        baseRatePerHour: 150.0,
        performanceBonusRate: 25.0,
        paymentTerms: 'Monthly',
        totalEarnings: 0.0,
        recentAssignments: [],
        consecutiveDaysWorked: 0,
        isActive: true,
        joinedDate: DateTime.now(),
        additionalInfo: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      emp.Employee(
        id: 'demo_emp_2',
        userId: 'demo_user_2',
        displayName: 'Priya Sharma',
        email: 'priya@designer.com',
        phoneNumber: '+91-9876543211',
        skills: [emp.EmployeeSkill.patternMaking, emp.EmployeeSkill.embroidery],
        specializations: ['Design Consultation', 'Bespoke Patterns', 'Traditional Embroidery'],
        experienceYears: 12,
        certifications: ['Fashion Design Diploma', 'Master Embroidery Artist'],
        availability: emp.EmployeeAvailability.fullTime,
        preferredWorkDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        preferredStartTime: const emp.TimeOfDay(hour: 9, minute: 0),
        preferredEndTime: const emp.TimeOfDay(hour: 17, minute: 0),
        canWorkRemotely: true,
        location: 'Design Studio',
        totalOrdersCompleted: 0,
        ordersInProgress: 0,
        averageRating: 0.0,
        completionRate: 0.0,
        strengths: [],
        areasForImprovement: [],
        baseRatePerHour: 200.0,
        performanceBonusRate: 45.0,
        paymentTerms: 'Monthly',
        totalEarnings: 0.0,
        recentAssignments: [],
        consecutiveDaysWorked: 0,
        isActive: true,
        joinedDate: DateTime.now(),
        additionalInfo: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      emp.Employee(
        id: 'demo_emp_3',
        userId: 'demo_user_3',
        displayName: 'Amit Patel',
        email: 'amit@cutter.com',
        phoneNumber: '+91-9876543212',
        skills: [emp.EmployeeSkill.cutting, emp.EmployeeSkill.qualityCheck],
        specializations: ['Fabric Cutting', 'Material Optimization', 'Quality Inspection'],
        experienceYears: 6,
        certifications: ['Precision Cutting Specialist'],
        availability: emp.EmployeeAvailability.partTime,
        preferredWorkDays: ['Tuesday', 'Wednesday', 'Friday', 'Saturday'],
        preferredStartTime: const emp.TimeOfDay(hour: 10, minute: 0),
        preferredEndTime: const emp.TimeOfDay(hour: 16, minute: 0),
        canWorkRemotely: false,
        location: 'Cutting Department',
        totalOrdersCompleted: 0,
        ordersInProgress: 0,
        averageRating: 0.0,
        completionRate: 0.0,
        strengths: [],
        areasForImprovement: [],
        baseRatePerHour: 120.0,
        performanceBonusRate: 20.0,
        paymentTerms: 'Monthly',
        totalEarnings: 0.0,
        recentAssignments: [],
        consecutiveDaysWorked: 0,
        isActive: true,
        joinedDate: DateTime.now(),
        additionalInfo: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      emp.Employee(
        id: 'demo_emp_4',
        userId: 'demo_user_4',
        displayName: 'Sneha Gupta',
        email: 'sneha@finisher.com',
        phoneNumber: '+91-9876543213',
        skills: [emp.EmployeeSkill.finishing],
        specializations: ['Final Inspection', 'Button Attachment', 'Hem Finishing', 'Pressing'],
        experienceYears: 5,
        certifications: ['Finishing Expert Certification'],
        availability: emp.EmployeeAvailability.fullTime,
        preferredWorkDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        preferredStartTime: const emp.TimeOfDay(hour: 9, minute: 0),
        preferredEndTime: const emp.TimeOfDay(hour: 17, minute: 0),
        canWorkRemotely: false,
        location: 'Finishing Department',
        totalOrdersCompleted: 0,
        ordersInProgress: 0,
        averageRating: 0.0,
        completionRate: 0.0,
        strengths: [],
        areasForImprovement: [],
        baseRatePerHour: 110.0,
        performanceBonusRate: 15.0,
        paymentTerms: 'Monthly',
        totalEarnings: 0.0,
        recentAssignments: [],
        consecutiveDaysWorked: 0,
        isActive: true,
        joinedDate: DateTime.now(),
        additionalInfo: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

class EmployeeListSimple extends StatefulWidget {
  const EmployeeListSimple({super.key});

  @override
  State<EmployeeListSimple> createState() => _EmployeeListSimpleState();
}

class _EmployeeListSimpleState extends State<EmployeeListSimple> {
  bool? _selectedStatusFilter;
  bool _initComplete = false;
  String? _initError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('🏗️ EmployeeListSimple initState - starting initialization');
    // Start with a simple loading state
    _loading = true;
    _initComplete = false;

    // Use a simple delayed initialization to avoid complex async issues
    Future.delayed(const Duration(milliseconds: 500), () {
      debugPrint('⏰ EmployeeListSimple delayed initialization triggered');
      if (mounted) {
        _initializeSimple();
      } else {
        debugPrint('⚠️ EmployeeListSimple not mounted during delayed initialization');
      }
    });
  }

  void _initializeSimple() {
    debugPrint('🚀 EmployeeListSimple _initializeSimple - starting simple initialization');
    // Simple synchronous initialization first
    setState(() {
      _loading = false;
      _initComplete = true;
    });
    debugPrint('✅ EmployeeListSimple simple initialization complete, now loading data');

    // Then try to load data asynchronously
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    try {
      debugPrint('🚀 EmployeeListSimple _loadEmployeeData - starting data load');
      debugPrint('📦 Checking EmployeeProvider availability');
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      debugPrint('✅ EmployeeProvider obtained successfully');

      // Simple load with timeout
      await employeeProvider.loadEmployees().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⚠️ Employee load timed out');
          throw Exception('Loading timed out - please check your connection');
        },
      );

      debugPrint('✅ EmployeeListSimple data loaded successfully');
      debugPrint('📈 Found ${employeeProvider.employees.length} employees');

      if (mounted) {
        debugPrint('🔄 EmployeeListSimple - clearing error and updating state');
        setState(() {
          _initError = null;
        });
      } else {
        debugPrint('⚠️ EmployeeListSimple not mounted when setting success state');
      }
    } catch (e) {
      debugPrint('❌ EmployeeListSimple failed to load employee data: $e');
      if (mounted) {
        debugPrint('🔄 EmployeeListSimple - setting error state');
        setState(() {
          _initError = 'Failed to load employees: $e';
        });
      } else {
        debugPrint('⚠️ EmployeeListSimple not mounted when setting error state');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 EmployeeListSimple build - rebuilding widget');
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        debugPrint('🔐 EmployeeListSimple checking authentication for user: ${authProvider.user?.email ?? "null"}');
        debugPrint('👑 isShopOwnerOrAdmin: ${authProvider.isShopOwnerOrAdmin}');
        // Check if user has permission to view employee list
        if (!authProvider.isShopOwnerOrAdmin) {
          debugPrint('❌ EmployeeListSimple access denied - user is not shop owner or admin');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'You don\'t have permission to view employee management.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

  debugPrint('✅ EmployeeListSimple access granted - building main content');
  return Expanded(
    child: Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, child) {
        debugPrint('📊 EmployeeListSimple building with provider state:');
        debugPrint('  - _initComplete: $_initComplete');
        debugPrint('  - employeeProvider.isLoading: ${employeeProvider.isLoading}');
        debugPrint('  - _initError: $_initError');
        debugPrint('  - employeeProvider.errorMessage: ${employeeProvider.errorMessage}');
        debugPrint('  - employeeProvider.employees.length: ${employeeProvider.employees.length}');

        // Show loading if initialization is incomplete OR provider is loading
        if (!_initComplete || employeeProvider.isLoading) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                !_initComplete ? 'Initializing employee management...' : 'Loading employees...',
                style: const TextStyle(fontSize: 16),
              ),
              if (!_initComplete) ...[
                const SizedBox(height: 8),
                const Text(
                  'If this takes too long, please check your internet connection',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Emergency bypass button
                ElevatedButton.icon(
                  onPressed: () async {
                    debugPrint('🚨 Emergency bypass activated');
                    try {
                      await EmployeeManagementHelper.populateDemoEmployees(context, silent: true);
                      await employeeProvider.loadEmployees();
                      setState(() {
                        _loading = false;
                        _initComplete = true;
                        _initError = null;
                      });
                    } catch (e) {
                      debugPrint('❌ Emergency bypass failed: $e');
                      setState(() {
                        _initError = 'Emergency bypass failed: $e';
                        _loading = false;
                        _initComplete = true;
                      });
                    }
                  },
                  icon: const Icon(Icons.warning),
                  label: const Text('Emergency: Load Demo Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If loading is stuck, click above to bypass',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );
        }

        // Show initialization error if any
        if (_initError != null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Initialization failed: $_initError',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initComplete = false;
                        _initError = null;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        await employeeProvider.loadEmployees();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => EmployeeManagementHelper.forceRefreshEmployees(context, employeeProvider.loadEmployees),
                    child: const Text('Force Refresh'),
                  ),
                ],
              ),
            ],
          );
        }

        // Show provider error if any
        if (employeeProvider.errorMessage != null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: ${employeeProvider.errorMessage}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => employeeProvider.loadEmployees(),
                child: const Text('Retry'),
              ),
            ],
          );
        }

        final employees = employeeProvider.employees;

        return Column(
          children: [
            // Employee Management Statistics
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Total', employeeProvider.totalEmployees.toString(), Icons.people),
                  _buildStatCard('Active', employeeProvider.activeEmployees.length.toString(), Icons.person, color: Colors.green),
                  _buildStatCard('Owners', employees.where((e) => e.role == UserRole.shopOwner).length.toString(), Icons.star, color: Colors.purple),
                  _buildStatCard('Avg Rating', employeeProvider.averageRating.toStringAsFixed(1), Icons.star_rate, color: Colors.amber),
                ],
              ),
            ),

            // Employee List
            Expanded(
              child: employees.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                                // Quick Setup Options
                                Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '🚀 Get Started',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Choose one of the following options:',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(height: 20),
   
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () => EmployeeManagementHelper.populateDemoEmployees(context),
                                                icon: const Icon(Icons.auto_awesome),
                                                label: const Text('Load Demo Data'),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                                  backgroundColor: Colors.blue,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () => _showAddEmployeeDialog(context),
                                                icon: const Icon(Icons.person_add),
                                                label: const Text('Add First Employee'),
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // Additional Direct Setup Button
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              try {
                                                await showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) => const AlertDialog(
                                                    title: Text('Setting up demo employees...'),
                                                    content: CircularProgressIndicator(),
                                                  ),
                                                );
                                                // Call direct employee setup from Firebase directly
                                                final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
                                                await employeeProvider.loadEmployees();
                                                if (context.mounted) {
                                                  Navigator.of(context).pop(); // Close loading
                                                  await employeeProvider.loadEmployees();
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  Navigator.of(context).pop(); // Close loading
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Failed to setup employees: $e')),
                                                  );
                                                }
                                              }
                                            },
                                            icon: Icon(Icons.bolt),
                                            label: const Text('Direct Employee Setup'),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              backgroundColor: Colors.green,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () async {
                                                  debugPrint('🔄 Force refreshing employee data...');
                                                  setState(() {
                                                    _initComplete = false;
                                                    _initError = null;
                                                  });
                                                  final populated = await EmployeeManagementHelper.checkAndPopulateIfEmpty(context);
                                                  await EmployeeManagementHelper.forceRefreshEmployees(context, () async {
                                                    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
                                                    await employeeProvider.loadEmployees();
                                                  });
                                                  setState(() {
                                                    _initComplete = true;
                                                  });
                                                },
                                                icon: const Icon(Icons.refresh),
                                                label: const Text('Force Refresh'),
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () => _showDebugInfo(context),
                                                icon: const Icon(Icons.bug_report),
                                                label: const Text('Debug Info'),
                                                style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            '💡 Demo data includes:\n• Esther (Owner) with management privileges\n• Rajesh Kumar (Tailor) for customization work\n• Priya Sharma (Designer) for creative tasks\n• Amit Patel (Cutter) for fabric preparation\n• Sneha Gupta (Finisher) for final touches\n• Manual employee addition available',
                                            style: TextStyle(fontSize: 12, color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Database Status
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 32),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Column(
                                    children: [
                                      Icon(Icons.info, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        'Database Connection: Active',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Firebase Firestore is ready for data operations',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: employees.length,
                            itemBuilder: (context, index) {
                              final employee = employees[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _showEmployeeDetails(context, employee),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundImage: employee.photoUrl != null
                                                  ? NetworkImage(employee.photoUrl!)
                                                  : null,
                                              child: employee.photoUrl == null
                                                  ? Text(
                                                      employee.displayName[0].toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    employee.displayName,
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    employee.email,
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Role and Status Row
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                if (employee.role == UserRole.shopOwner)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.purple[100],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Text(
                                                      'Owner',
                                                      style: TextStyle(
                                                        color: Colors.purple,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: employee.isActive
                                                        ? Colors.green[100]
                                                        : Colors.red[100],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    employee.isActive ? 'Active' : 'Inactive',
                                                    style: TextStyle(
                                                      color: employee.isActive
                                                          ? Colors.green[800]
                                                          : Colors.red[800],
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        // Skills and Stats Row
                                        Row(
                                          children: [
                                            // Skills
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Skills',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Wrap(
                                                    spacing: 4,
                                                    children: employee.skills.take(2).map((skill) {
                                                      return Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          skill.name,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Theme.of(context).colorScheme.primary,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Stats
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      const Icon(Icons.star, size: 16, color: Colors.amber),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        employee.averageRating.toStringAsFixed(1),
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${employee.totalOrdersCompleted} orders',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        // Action Buttons
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            // Edit Button - Available for all employees
                                            TextButton.icon(
                                              onPressed: () => _showEditEmployeeDialog(context, employee),
                                              icon: const Icon(Icons.edit, size: 16),
                                              label: const Text('Edit'),
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              ),
                                            ),

                                            const SizedBox(width: 8),

                                            // Deactivate/Reactivate Button - Restricted for owner
                                            if (employee.role != UserRole.shopOwner)
                                              TextButton.icon(
                                                onPressed: () => _toggleEmployeeStatus(context, employee),
                                                icon: Icon(
                                                  employee.isActive ? Icons.person_off : Icons.person,
                                                  size: 16,
                                                  color: employee.isActive ? Colors.orange : Colors.green,
                                                ),
                                                label: Text(employee.isActive ? 'Deactivate' : 'Activate'),
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  foregroundColor: employee.isActive ? Colors.orange : Colors.green,
                                                ),
                                              )
                                            else
                                              const Text(
                                                'Protected',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),

                                            const SizedBox(width: 8),

                                            // Delete Button - Restricted for owner
                                            if (employee.role != UserRole.shopOwner)
                                              TextButton.icon(
                                                onPressed: () => _showDeleteEmployeeDialog(context, employee),
                                                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                                label: const Text('Delete'),
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  foregroundColor: Colors.red,
                                                ),
                                              )
                                            else
                                              const Icon(
                                                Icons.shield,
                                                color: Colors.purple,
                                                size: 20,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          // Removed floating action button - parent screen handles this
        );
      },
    );
  }

  void _showEmployeeDetails(BuildContext context, emp.Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    // Capture the provider before the async operation
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmployeeCreateScreen(),
      ),
    ).then((_) async {
      // Refresh employee list when returning from create screen
      if (mounted) {
        await employeeProvider.loadEmployees();
      }
    });
  }

  void _showEditEmployeeDialog(BuildContext context, emp.Employee employee) {
    // For now, show a simple dialog for editing basic employee info
    // In a full implementation, this would navigate to a detailed edit screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Employee'),
        content: Text('Edit functionality for ${employee.displayName} goes here. '
                    'This would allow updating employee details, skills, availability, etc.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement actual edit functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit functionality coming soon!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleEmployeeStatus(BuildContext context, emp.Employee employee) async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

    final newStatus = !employee.isActive;
    final action = newStatus ? 'activate' : 'deactivate';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action Employee'),
        content: Text('Are you sure you want to $action ${employee.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.orange,
            ),
            child: Text(action.substring(0, 1).toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await employeeProvider.toggleEmployeeStatus(employee.id, newStatus);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${employee.displayName} has been ${newStatus ? 'activated' : 'deactivated'}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Widget _buildStatCard(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color ?? Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showDebugInfo(BuildContext context) async {
    final FirebaseService firebaseService = FirebaseService();

    try {
      debugPrint('🎯 Debug Info: Starting database check...');
      // Check Firebase auth state
      final currentUser = firebaseService.currentUser;
      debugPrint('🔐 Auth state: ${currentUser?.email ?? "Not logged in"}');

      // Try to fetch employees collection
      final querySnapshot = await firebaseService.getCollection('employees');
      final employeeCount = querySnapshot.docs.length;
      debugPrint('💾 Database: $employeeCount employees in collection');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🔍 Database Debug Info'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔐 Authentication:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('User: ${currentUser?.email ?? "Not logged in"}', style: const TextStyle(fontSize: 12)),
                  Text('UID: ${currentUser?.uid ?? "N/A"}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 16),
                  const Text('💾 Database Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Employees in database: $employeeCount'),
                  Text('Collection: employees'),
                  if (employeeCount == 0) const Text('⚠️ No employees found - database is empty', style: TextStyle(color: Colors.orange, fontSize: 12)),
                  const SizedBox(height: 16),
                  const Text('🔧 Troubleshooting Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await EmployeeManagementHelper.populateDemoEmployees(context);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demo data populated!')),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Populate Demo Data'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      // Try to manually refresh
                      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
                      await EmployeeManagementHelper.forceRefreshEmployees(context, () async {
                        await employeeProvider.loadEmployees();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Refreshed!')),
                        );
                      });
                    },
                    icon: const Icon(Icons.sync),
                    label: const Text('Force Sync'),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployeePerformanceDashboard(),
                    ),
                  );
                },
                tooltip: 'Performance Dashboard',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
                  employeeProvider.loadEmployees();
                },
                tooltip: 'Refresh Employees',
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Debug check failed: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🤔 Debug Error'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Error: $e', style: const TextStyle(color: Colors.red, fontSize: 12)),
                  const SizedBox(height: 16),
                  const Text('This might indicate:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('• Firebase connection issues', style: TextStyle(fontSize: 12)),
                  const Text('• Internet connectivity problems', style: TextStyle(fontSize: 12)),
                  const Text('• Firebase configuration issues', style: TextStyle(fontSize: 12)),
                  const Text('• "Cannot send Null" debug service errors interfering', style: TextStyle(fontSize: 12, color: Colors.orange)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showDebugInfo(context), // Try again
                          child: const Text('Retry Debug'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  void _showDeleteEmployeeDialog(BuildContext context, emp.Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to permanently delete ${employee.displayName}? '
                    'This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
        await employeeProvider.deleteEmployee(employee.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${employee.displayName} has been deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting employee: ${e.toString()}')),
          );
        }
      }
    }
  }
}
