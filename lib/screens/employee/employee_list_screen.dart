// Employee List Screen with Offline Support
// Displays all employees with filtering, search, and sync status

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/employee.dart' as emp;
import '../../providers/employee_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/user_avatar.dart';
import 'employee_detail_screen.dart';
import 'employee_create_screen.dart';
import 'employee_performance_dashboard.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  emp.EmployeeSkill? _selectedSkillFilter;
  emp.EmployeeAvailability? _selectedAvailabilityFilter;
  bool? _activeStatusFilter;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);
    await employeeProvider.loadEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user has permission to view employee list
        // Allow shop owners, admins, and employees (employees can view their own profile)
        final currentUser = authProvider.currentUser;
        final hasAccess = authProvider.isShopOwnerOrAdmin ||
            (currentUser !=
                null); // Employees can view the list but with limited actions

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
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Employee Management'),
            toolbarHeight: kToolbarHeight + 5,
            actions: [
              // Offline sync indicator
              Consumer<EmployeeProvider>(
                builder: (context, provider, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: IconButton(
                      icon: Icon(
                        Icons.sync,
                        color:
                            provider.isLoading ? Colors.orange : Colors.green,
                      ),
                      onPressed: provider.isLoading ? null : _loadEmployees,
                      tooltip: 'Sync with server',
                    ),
                  );
                },
              ),
              // Performance Dashboard button (only for shop owners/admins)
              if (authProvider.isShopOwnerOrAdmin)
                IconButton(
                  icon: const Icon(Icons.analytics),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const EmployeePerformanceDashboard(),
                      ),
                    );
                  },
                  tooltip: 'Performance Dashboard',
                ),

              // Add employee button (only for shop owners/admins)
              if (authProvider.isShopOwnerOrAdmin)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmployeeCreateScreen(),
                      ),
                    );
                  },
                  tooltip: 'Add Employee',
                ),
            ],
          ),
          body: Column(
            children: [
              // Search and Filter Section
              _buildSearchAndFilters(),

              // Employee List
              Expanded(
                child: Consumer<EmployeeProvider>(
                  builder: (context, employeeProvider, child) {
                    if (employeeProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (employeeProvider.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading employees',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              employeeProvider.errorMessage!,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadEmployees,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final employees = employeeProvider.employees;

                    if (employees.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No employees found',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add your first employee to get started',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final deviceType =
                            ResponsiveUtils.getDeviceType(constraints.maxWidth);
                        final isDesktop = deviceType == DeviceType.desktop;

                        if (isDesktop) {
                          // Desktop: Grid layout
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  ResponsiveUtils.getResponsiveGridColumns(
                                      context),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: employees.length,
                            itemBuilder: (context, index) {
                              final employee = employees[index];
                              return _buildEmployeeCard(employee,
                                  isDesktop: true);
                            },
                          );
                        } else {
                          // Mobile/Tablet: List layout
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: employees.length,
                            itemBuilder: (context, index) {
                              final employee = employees[index];
                              return _buildEmployeeCard(employee,
                                  isDesktop: false);
                            },
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: authProvider.isShopOwnerOrAdmin
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmployeeCreateScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Employee'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceType(constraints.maxWidth);
        final isDesktop = deviceType == DeviceType.desktop;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search employees...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                onChanged: (value) {
                  final employeeProvider =
                      Provider.of<EmployeeProvider>(context, listen: false);
                  employeeProvider.searchEmployees(value);
                },
              ),
              const SizedBox(height: 12),

              // Filters
              if (isDesktop)
                // Desktop: Wrap layout
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Skill Filter
                    _buildFilterChip(
                      label: 'Skill',
                      value: _selectedSkillFilter?.name ?? 'All',
                      onTap: () => _showSkillFilterDialog(),
                    ),

                    // Availability Filter
                    _buildFilterChip(
                      label: 'Availability',
                      value: _selectedAvailabilityFilter?.name ?? 'All',
                      onTap: () => _showAvailabilityFilterDialog(),
                    ),

                    // Status Filter
                    _buildFilterChip(
                      label: 'Status',
                      value: _activeStatusFilter == null
                          ? 'All'
                          : _activeStatusFilter!
                              ? 'Active'
                              : 'Inactive',
                      onTap: () => _showStatusFilterDialog(),
                    ),

                    // Clear Filters
                    ActionChip(
                      label: const Text('Clear'),
                      onPressed: _clearFilters,
                      avatar: const Icon(Icons.clear, size: 16),
                    ),
                  ],
                )
              else
                // Mobile/Tablet: Horizontal scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Skill Filter
                      _buildFilterChip(
                        label: 'Skill',
                        value: _selectedSkillFilter?.name ?? 'All',
                        onTap: () => _showSkillFilterDialog(),
                      ),
                      const SizedBox(width: 8),

                      // Availability Filter
                      _buildFilterChip(
                        label: 'Availability',
                        value: _selectedAvailabilityFilter?.name ?? 'All',
                        onTap: () => _showAvailabilityFilterDialog(),
                      ),
                      const SizedBox(width: 8),

                      // Status Filter
                      _buildFilterChip(
                        label: 'Status',
                        value: _activeStatusFilter == null
                            ? 'All'
                            : _activeStatusFilter!
                                ? 'Active'
                                : 'Inactive',
                        onTap: () => _showStatusFilterDialog(),
                      ),

                      const SizedBox(width: 8),

                      // Clear Filters
                      ActionChip(
                        label: const Text('Clear'),
                        onPressed: _clearFilters,
                        avatar: const Icon(Icons.clear, size: 16),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
      {required String label,
      required String value,
      required VoidCallback onTap}) {
    return FilterChip(
      label: Text('$label: $value'),
      selected: false,
      onSelected: (_) => onTap(),
      avatar: Icon(
        label == 'Skill'
            ? Icons.build
            : label == 'Availability'
                ? Icons.schedule
                : Icons.toggle_on,
        size: 16,
      ),
    );
  }

  Widget _buildEmployeeCard(emp.Employee employee, {bool isDesktop = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeDetailScreen(employee: employee),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Employee Avatar
                  UserAvatar(
                    displayName: employee.displayName,
                    imageUrl: employee.photoUrl,
                    radius: 24,
                  ),
                  const SizedBox(width: 12),

                  // Employee Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.displayName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          employee.email,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${employee.experienceYears} years experience',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Status Indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: employee.isActive
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      employee.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: employee.isActive
                            ? Colors.green[800]
                            : Colors.red[800],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: employee.skills.take(3).map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
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
                        if (employee.skills.length > 3)
                          Text(
                            '+${employee.skills.length - 3} more',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
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
                            const Icon(Icons.check_circle,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              '${employee.totalOrdersCompleted}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Completed',
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
            ],
          ),
        ),
      ),
    );
  }

  void _showSkillFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: emp.EmployeeSkill.values.map((skill) {
            return ListTile(
              title: Text(skill.name),
              leading: Icon(
                skill == _selectedSkillFilter
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () {
                setState(() {
                  _selectedSkillFilter = skill;
                });
                final employeeProvider =
                    Provider.of<EmployeeProvider>(context, listen: false);
                employeeProvider.filterBySkill(skill);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedSkillFilter = null;
              });
              final employeeProvider =
                  Provider.of<EmployeeProvider>(context, listen: false);
              employeeProvider.filterBySkill(null);
              Navigator.pop(context);
            },
            child: const Text('Clear Filter'),
          ),
        ],
      ),
    );
  }

  void _showAvailabilityFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Availability'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: emp.EmployeeAvailability.values.map((availability) {
            return ListTile(
              title: Text(availability.name),
              leading: Icon(
                availability == _selectedAvailabilityFilter
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () {
                setState(() {
                  _selectedAvailabilityFilter = availability;
                });
                final employeeProvider =
                    Provider.of<EmployeeProvider>(context, listen: false);
                employeeProvider.filterByAvailability(availability);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedAvailabilityFilter = null;
              });
              final employeeProvider =
                  Provider.of<EmployeeProvider>(context, listen: false);
              employeeProvider.filterByAvailability(null);
              Navigator.pop(context);
            },
            child: const Text('Clear Filter'),
          ),
        ],
      ),
    );
  }

  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              leading: Icon(
                _activeStatusFilter == null
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () {
                setState(() {
                  _activeStatusFilter = null;
                });
                final employeeProvider =
                    Provider.of<EmployeeProvider>(context, listen: false);
                employeeProvider.filterByActiveStatus(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Active'),
              leading: Icon(
                _activeStatusFilter == true
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () {
                setState(() {
                  _activeStatusFilter = true;
                });
                final employeeProvider =
                    Provider.of<EmployeeProvider>(context, listen: false);
                employeeProvider.filterByActiveStatus(true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Inactive'),
              leading: Icon(
                _activeStatusFilter == false
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () {
                setState(() {
                  _activeStatusFilter = false;
                });
                final employeeProvider =
                    Provider.of<EmployeeProvider>(context, listen: false);
                employeeProvider.filterByActiveStatus(false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedSkillFilter = null;
      _selectedAvailabilityFilter = null;
      _activeStatusFilter = null;
    });

    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);
    employeeProvider.searchEmployees('');
    employeeProvider.filterBySkill(null);
    employeeProvider.filterByAvailability(null);
    employeeProvider.filterByActiveStatus(null);
  }
}
