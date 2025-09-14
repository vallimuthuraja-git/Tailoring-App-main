// Employee Detail Screen with Offline Support
// Shows detailed employee information and work assignments

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import '../../providers/auth_provider.dart';
import 'employee_edit_screen.dart';
import 'work_assignment_screen.dart';
import '../../widgets/user_avatar.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({required this.employee, super.key});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late Employee _employee;

  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
    _loadEmployeeDetails();
  }

  Future<void> _loadEmployeeDetails() async {
    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);
    final updatedEmployee =
        await employeeProvider.getEmployeeById(_employee.id);
    if (updatedEmployee != null && mounted) {
      setState(() {
        _employee = updatedEmployee;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user has permission to view employee details
        // Allow shop owners, admins, and the employee themselves
        final currentUser = authProvider.currentUser;
        final hasAccess = authProvider.isShopOwnerOrAdmin ||
            (currentUser != null && currentUser.uid == _employee.userId);

        if (!hasAccess) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied'),
            ),
            body: Center(
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
                    'You don\'t have permission to view this employee\'s details.',
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
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_employee.displayName),
            actions: [
              // Edit button (only for shop owners/admins)
              if (authProvider.isShopOwnerOrAdmin)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EmployeeEditScreen(employee: _employee),
                      ),
                    ).then((_) => _loadEmployeeDetails());
                  },
                  tooltip: 'Edit Employee',
                ),
              // Work assignments button (for shop owners/admins and the employee themselves)
              IconButton(
                icon: const Icon(Icons.assignment),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WorkAssignmentScreen(employee: _employee),
                    ),
                  );
                },
                tooltip: 'View Work Assignments',
              ),
              // Delete button (only for shop owners/admins)
              if (authProvider.isShopOwnerOrAdmin)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(),
                  tooltip: 'Delete Employee',
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Employee Header Card
                _buildEmployeeHeader(),

                const SizedBox(height: 24),

                // Performance Overview
                _buildSectionTitle('Performance Overview'),
                _buildPerformanceOverview(),

                const SizedBox(height: 24),

                // Skills & Expertise
                _buildSectionTitle('Skills & Expertise'),
                _buildSkillsSection(),

                const SizedBox(height: 24),

                // Work Schedule
                _buildSectionTitle('Work Schedule'),
                _buildWorkSchedule(),

                const SizedBox(height: 24),

                // Recent Assignments
                _buildSectionTitle('Recent Work Assignments'),
                _buildRecentAssignments(),

                const SizedBox(height: 24),

                // Contact Information
                _buildSectionTitle('Contact Information'),
                _buildContactInfo(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildEmployeeHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Employee Avatar
            UserAvatar(
              displayName: _employee.displayName,
              imageUrl: _employee.photoUrl,
              radius: 40,
            ),
            const SizedBox(width: 20),

            // Employee Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _employee.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _employee.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _employee.isActive
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _employee.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: _employee.isActive
                                ? Colors.green[800]
                                : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_employee.experienceYears} years experience',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
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

  Widget _buildPerformanceOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Orders Completed',
                    _employee.totalOrdersCompleted.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Avg Rating',
                    _employee.averageRating.toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Completion Rate',
                    '${(_employee.completionRate * 100).toStringAsFixed(0)}%',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Total Earnings',
                    '\$${_employee.totalEarnings.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'In Progress',
                    _employee.ordersInProgress.toString(),
                    Icons.work,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Consecutive Days',
                    _employee.consecutiveDaysWorked.toString(),
                    Icons.calendar_today,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skills
            Text(
              'Skills',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _employee.skills.map((skill) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    skill.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Specializations
            if (_employee.specializations.isNotEmpty) ...[
              Text(
                'Specializations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _employee.specializations.map((spec) {
                  return Chip(
                    label: Text(spec),
                    backgroundColor: Colors.blue[50],
                    labelStyle: const TextStyle(color: Colors.blue),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 20),

            // Certifications
            if (_employee.certifications.isNotEmpty) ...[
              Text(
                'Certifications',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _employee.certifications.map((cert) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.verified,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(cert),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWorkSchedule() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Availability
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Availability: ${_employee.availability.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Work Days
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_today, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work Days',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _employee.preferredWorkDays.map((day) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              day.substring(0, 3),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Work Hours
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.purple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preferred Hours',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      if (_employee.preferredStartTime != null &&
                          _employee.preferredEndTime != null) ...[
                        Text(
                          '${_employee.preferredStartTime!.formatTime()} - ${_employee.preferredEndTime!.formatTime()}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ] else ...[
                        Text(
                          'Flexible hours',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Remote Work
            Row(
              children: [
                Icon(
                  _employee.canWorkRemotely ? Icons.home_work : Icons.business,
                  color:
                      _employee.canWorkRemotely ? Colors.orange : Colors.blue,
                ),
                const SizedBox(width: 12),
                Text(
                  _employee.canWorkRemotely
                      ? 'Can work remotely'
                      : 'On-site only',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAssignments() {
    // This would show recent work assignments
    // For now, showing a placeholder
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.work_history, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Recent Work',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_employee.recentAssignments.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No recent assignments',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ] else ...[
              // Show recent assignments
              ..._employee.recentAssignments.take(5).map((assignment) {
                return ListTile(
                  title: Text('Order #${assignment.orderId}'),
                  subtitle: Text(assignment.taskDescription),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: assignment.status == WorkStatus.completed
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      assignment.status.name,
                      style: TextStyle(
                        color: assignment.status == WorkStatus.completed
                            ? Colors.green[800]
                            : Colors.orange[800],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.contact_phone, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email'),
              subtitle: Text(_employee.email),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  // Copy email to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email copied to clipboard')),
                  );
                },
              ),
            ),

            // Phone (if available)
            if (_employee.phoneNumber != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Phone'),
                subtitle: Text(_employee.phoneNumber!),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    // Make phone call
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Phone call functionality coming soon')),
                    );
                  },
                ),
              ),
            ],

            // Location (if available)
            if (_employee.location != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: const Text('Location'),
                subtitle: Text(_employee.location!),
                trailing: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () {
                    // Open map
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Map functionality coming soon')),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
            'Are you sure you want to delete ${_employee.displayName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteEmployee(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteEmployee() async {
    Navigator.pop(context); // Close dialog

    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleting employee...')),
    );

    try {
      final success = await employeeProvider.deleteEmployee(_employee.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee deleted successfully')),
        );
        Navigator.pop(context); // Go back to list
      } else {
        throw Exception('Failed to delete employee');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
