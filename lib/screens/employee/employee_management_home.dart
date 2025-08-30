import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_app_bar_actions.dart';
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
    // Try to setup tabs immediately, and also after first build as fallback
    if (mounted) {
      _ensureTabsAreSetup();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ensureTabsAreSetup();
      }
    });
  }

  void _ensureTabsAreSetup() {
    debugPrint('🔧 EmployeeManagementHome: Ensuring tabs are setup');
    // Only setup if not already done
    if (_tabs.isEmpty) {
      debugPrint('📝 EmployeeManagementHome: Tabs are empty, setting up...');
      _setupTabs();
      debugPrint('✅ EmployeeManagementHome: Setup complete, tabs length: ${_tabs.length}');
    } else {
      debugPrint('🚦 EmployeeManagementHome: Tabs already setup (${_tabs.length} tabs)');
    }
  }

  void _setupTabs() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      debugPrint('🔐 EmployeeManagementHome: Auth provider user: ${authProvider.user?.email}');
      debugPrint('👑 EmployeeManagementHome: isShopOwnerOrAdmin: ${authProvider.isShopOwnerOrAdmin}');
      debugPrint('🎭 EmployeeManagementHome: userRole: ${authProvider.userRole}');

      final isShopOwnerOrAdmin = authProvider.isShopOwnerOrAdmin;

      if (isShopOwnerOrAdmin) {
        debugPrint('👨‍💼 EmployeeManagementHome: Setting up admin tabs');
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
        debugPrint('👷 EmployeeManagementHome: Setting up employee tabs');
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

      setState(() {}); // Trigger rebuild after setting up tabs
      debugPrint('📱 EmployeeManagementHome: Tabs setup complete with ${_tabs.length} tabs');

    } catch (e) {
      debugPrint('❌ EmployeeManagementHome: Error setting up tabs: $e');

      // Fallback tabs in case of error
      debugPrint('🔄 EmployeeManagementHome: Using fallback tabs due to error');
      _tabs = [
        const EmployeeListSimple(),
      ];
      _tabTitles = [
        'Employee List'
      ];
      _tabIcons = [
        Icons.people,
      ];

      setState(() {}); // Trigger rebuild with fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 EmployeeManagementHome: Building widget');

    // Ensure tabs are setup every build for safety
    _ensureTabsAreSetup();

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        debugPrint('🔐 EmployeeManagementHome build: Checking permissions');
        // Check if user has permission to access employee management
        final hasEmployeeManagementAccess = authProvider.isShopOwnerOrAdmin ||
            authProvider.hasRole(UserRole.employee) ||
            authProvider.hasRole(UserRole.tailor) ||
            authProvider.hasRole(UserRole.cutter) ||
            authProvider.hasRole(UserRole.finisher) ||
            authProvider.hasRole(UserRole.supervisor) ||
            authProvider.hasRole(UserRole.apprentice);

        debugPrint('🔑 EmployeeManagementHome: hasEmployeeManagementAccess: $hasEmployeeManagementAccess');

        if (!hasEmployeeManagementAccess) {
          debugPrint('❌ EmployeeManagementHome: Access denied');
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

        debugPrint('✅ EmployeeManagementHome: Building main scaffold with ${_tabs.length} tabs');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Employee Management'),
            toolbarHeight: kToolbarHeight + 5,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: const [CommonAppBarActions()],
          ),
          body: (_tabs.isEmpty || _selectedTab >= _tabs.length)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Setting up employee management...'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          debugPrint('🔄 EmployeeManagementHome: Manual retry triggered');
                          _ensureTabsAreSetup();
                        },
                        child: const Text('Retry Setup'),
                      ),
                    ],
                  ),
                )
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