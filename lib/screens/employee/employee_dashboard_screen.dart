import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/employee.dart' as emp;
import '../../utils/responsive_utils.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await employeeProvider.loadEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        toolbarHeight: kToolbarHeight + 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployeeData,
          ),
        ],
      ),
      body: Consumer2<AuthProvider, EmployeeProvider>(
        builder: (context, authProvider, employeeProvider, child) {
          if (employeeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (employeeProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${employeeProvider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadEmployeeData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Find current employee's data
          final currentUser = authProvider.currentUser;
          final employees = employeeProvider.employees;
          final currentEmployee = employees
              .where((emp) => emp.userId == currentUser?.uid)
              .cast<emp.Employee?>()
              .firstWhere(
                (element) => true,
                orElse: () => null,
              );

          if (currentEmployee == null) {
            return const Center(
              child: Text(
                  'Employee profile not found. Please contact your administrator.'),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final deviceType =
                  ResponsiveUtils.getDeviceType(constraints.maxWidth);
              final isDesktop = deviceType == DeviceType.desktop;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee Profile Card
                    _buildProfileCard(currentEmployee, isDesktop: isDesktop),

                    const SizedBox(height: 24),

                    // Quick Stats
                    _buildQuickStats(currentEmployee, isDesktop: isDesktop),

                    const SizedBox(height: 24),

                    // Current Work Assignments and Performance Overview
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildCurrentAssignments(currentEmployee,
                                isDesktop: true),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildPerformanceOverview(currentEmployee,
                                isDesktop: true),
                          ),
                        ],
                      )
                    else ...[
                      _buildCurrentAssignments(currentEmployee,
                          isDesktop: false),
                      const SizedBox(height: 24),
                      _buildPerformanceOverview(currentEmployee,
                          isDesktop: false),
                    ],

                    const SizedBox(height: 24),

                    // Recent Activity
                    _buildRecentActivity(currentEmployee, isDesktop: isDesktop),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(emp.Employee employee, {bool isDesktop = false}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: employee.photoUrl != null
                  ? NetworkImage(employee.photoUrl!)
                  : null,
              child: employee.photoUrl == null
                  ? Text(employee.displayName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.displayName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    employee.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        employee.isActive
                            ? Icons.check_circle
                            : Icons.pause_circle,
                        color: employee.isActive ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        employee.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color:
                              employee.isActive ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        employee.canWorkRemotely
                            ? Icons.home_work
                            : Icons.business,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        employee.canWorkRemotely
                            ? 'Remote Available'
                            : 'On-site Only',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(emp.Employee employee, {bool isDesktop = false}) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Orders Completed',
            employee.totalOrdersCompleted.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'In Progress',
            employee.ordersInProgress.toString(),
            Icons.work,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg Rating',
            employee.averageRating.toStringAsFixed(1),
            Icons.star,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAssignments(emp.Employee employee,
      {bool isDesktop = false}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Assignments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (employee.ordersInProgress > 0) ...[
              Text(
                  'You have ${employee.ordersInProgress} assignments in progress'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: employee.totalOrdersCompleted > 0
                    ? employee.totalOrdersCompleted /
                        (employee.totalOrdersCompleted +
                            employee.ordersInProgress)
                    : 0,
              ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_turned_in,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No current assignments'),
                      Text('You\'ll be notified when new work is assigned'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview(emp.Employee employee,
      {bool isDesktop = false}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildPerformanceMetric(
              'Completion Rate',
              '${(employee.completionRate * 100).toStringAsFixed(1)}%',
              employee.completionRate >= 0.9
                  ? Colors.green
                  : employee.completionRate >= 0.7
                      ? Colors.orange
                      : Colors.red,
            ),
            const SizedBox(height: 12),
            _buildPerformanceMetric(
              'Experience',
              '${employee.experienceYears} years',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildPerformanceMetric(
              'Total Earnings',
              '\$${employee.totalEarnings.toStringAsFixed(2)}',
              Colors.green,
            ),
            const SizedBox(height: 16),
            if (employee.strengths.isNotEmpty) ...[
              Text(
                'Strengths',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: employee.strengths.map((strength) {
                  return Chip(
                    label: Text(strength),
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(emp.Employee employee, {bool isDesktop = false}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (employee.recentAssignments.isNotEmpty) ...[
              ...employee.recentAssignments.take(3).map((assignment) {
                return ListTile(
                  leading: Icon(
                    assignment.status == emp.WorkStatus.completed
                        ? Icons.check_circle
                        : assignment.status == emp.WorkStatus.inProgress
                            ? Icons.work
                            : Icons.schedule,
                    color: assignment.status == emp.WorkStatus.completed
                        ? Colors.green
                        : assignment.status == emp.WorkStatus.inProgress
                            ? Colors.blue
                            : Colors.orange,
                  ),
                  title: Text(assignment.taskDescription),
                  subtitle: Text(
                      'Assigned: ${assignment.assignedAt.toString().split(' ')[0]}'),
                  trailing: assignment.qualityRating != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            Text(assignment.qualityRating!.toStringAsFixed(1)),
                          ],
                        )
                      : null,
                );
              }),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No recent activity'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
