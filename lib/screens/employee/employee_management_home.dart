import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../services/auth_service.dart';
import 'employee_list_simple.dart';
import 'employee_performance_dashboard.dart';
import 'employee_dashboard_screen.dart';
import 'employee_create_screen.dart';

class EmployeeManagementHome extends StatefulWidget {
  const EmployeeManagementHome({super.key});

  @override
  State<EmployeeManagementHome> createState() => _EmployeeManagementHomeState();
}

class _EmployeeManagementHomeState extends State<EmployeeManagementHome> {
  int _selectedTab = 0;
  late List<Widget> _tabs;
  late List<String> _tabTitles;
  late List<IconData> _tabIcons;

  @override
  void initState() {
    super.initState();
    // Initialize with default tabs first
    _tabs = [];
    _tabTitles = [];
    _tabIcons = [];
    _initializeTabs();
  }

  void _initializeTabs() {
    // This will be called after the first build when we have access to the AuthProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setupTabs();
      }
    });
  }

  void _setupTabs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isShopOwnerOrAdmin = authProvider.isShopOwnerOrAdmin;

    if (isShopOwnerOrAdmin) {
      // Shop owner/admin tabs
      _tabs = [
        const EmployeeListSimple(),
        const EmployeePerformanceDashboard(),
      ];
      _tabTitles = [
        'Employee List',
        'Performance Dashboard',
      ];
      _tabIcons = [
        Icons.people,
        Icons.analytics,
      ];
    } else {
      // Employee tabs
      _tabs = [
        const EmployeeDashboardScreen(),
        const EmployeePerformanceDashboard(),
      ];
      _tabTitles = [
        'My Dashboard',
        'Performance',
      ];
      _tabIcons = [
        Icons.dashboard,
        Icons.analytics,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user has permission to access employee management
        final hasEmployeeManagementAccess = authProvider.isShopOwnerOrAdmin ||
            authProvider.hasRole(UserRole.employee) ||
            authProvider.hasRole(UserRole.tailor) ||
            authProvider.hasRole(UserRole.cutter) ||
            authProvider.hasRole(UserRole.finisher) ||
            authProvider.hasRole(UserRole.supervisor) ||
            authProvider.hasRole(UserRole.apprentice);

        if (!hasEmployeeManagementAccess) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
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
                    'You don\'t have permission to access employee management.',
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
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: _tabs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _tabs[_selectedTab],
          bottomNavigationBar: _tabs.isEmpty
              ? null
              : BottomNavigationBar(
                  currentIndex: _selectedTab,
                  onTap: (index) {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                  items: List.generate(
                    _tabs.length,
                    (index) => BottomNavigationBarItem(
                      icon: Icon(_tabIcons[index]),
                      label: _tabTitles[index],
                    ),
                  ),
                ),
          floatingActionButton: _selectedTab == 0 && authProvider.isShopOwnerOrAdmin
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // Capture the provider before the async operation
                    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

                    // Navigate to add employee screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmployeeCreateScreen(),
                      ),
                    ).then((_) async {
                      // Refresh data when returning from create screen
                      if (mounted && _selectedTab == 0) {
                        // If we're on the list tab, refresh the provider
                        await employeeProvider.loadEmployees();
                      }
                    });
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Employee'),
                )
              : null,
        );
      },
    );
  }
}