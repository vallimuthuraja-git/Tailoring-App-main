import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/employee.dart' as emp;
import '../../providers/employee_provider.dart';

class SimpleEmployeeListScreen extends StatefulWidget {
  const SimpleEmployeeListScreen({super.key});

  @override
  State<SimpleEmployeeListScreen> createState() => _SimpleEmployeeListScreenState();
}

class _SimpleEmployeeListScreenState extends State<SimpleEmployeeListScreen> {
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    // Load employees when screen opens
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isInitializing = true;
      _initError = null;
    });

    try {
      debugPrint('🚀 Initializing employee data...');

      // First, ensure Firebase is properly initialized
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

      // Add a small delay to ensure context is fully ready
      await Future.delayed(const Duration(milliseconds: 200));

      // Try to load employees with timeout
      await employeeProvider.loadEmployees().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⚠️ Employee load timed out');
          throw Exception('Loading timed out. Please check your internet connection.');
        },
      );

      debugPrint('✅ Employee data loaded successfully');
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      debugPrint('❌ Failed to initialize employee data: $e');
      setState(() {
        _isInitializing = false;
        _initError = e.toString();
      });
    }
  }

  Future<void> _loadEmployees() async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    try {
      await employeeProvider.loadEmployees().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Loading timed out. Please try again.');
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to reload employees: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee List'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isInitializing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadEmployees,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isInitializing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing employee data...'),
                  SizedBox(height: 8),
                  Text(
                    'Please wait while we connect to the database',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : _initError != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to initialize',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _initError!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _initializeData,
                            child: const Text('Retry'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Consumer<EmployeeProvider>(
                  builder: (context, employeeProvider, child) {
                    // Show loading indicator
                    if (employeeProvider.isLoading) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading employees...'),
                          ],
                        ),
                      );
                    }

          // Show error message if there's an error
          if (employeeProvider.errorMessage != null) {
            return Center(
              child: Column(
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
                    onPressed: _loadEmployees,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final employees = employeeProvider.employees;

          // Show empty state
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No employees found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The database appears to be empty.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Show employee list
          return Column(
            children: [
              // Summary header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Total', employees.length.toString(), Icons.people),
                    _buildSummaryItem('Active', employees.where((e) => e.isActive).length.toString(), Icons.person, color: Colors.green),
                    _buildSummaryItem('Avg Rating', employeeProvider.averageRating.toStringAsFixed(1), Icons.star, color: Colors.amber),
                  ],
                ),
              ),

              // Employee list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Employee header
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Text(
                                    employee.displayName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
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
                                      Text(
                                        employee.email,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Status indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: employee.isActive ? Colors.green[100] : Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    employee.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: employee.isActive ? Colors.green[800] : Colors.red[800],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Employee details
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
                                        children: employee.skills.take(3).map((skill) {
                                          return Chip(
                                            label: Text(
                                              skill.name,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),

                                // Stats
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
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
                                    const SizedBox(height: 4),
                                    Text(
                                      '${employee.totalOrdersCompleted} orders',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Additional info
                            Row(
                              children: [
                                Icon(Icons.work, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${employee.experienceYears} years experience',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.attach_money, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '₹${employee.baseRatePerHour}/hr',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, {Color? color}) {
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
}
