import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/common_app_bar_actions.dart';
import '../../utils/responsive_utils.dart';
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
    debugdebugPrint('ðŸ”§ EmployeeManagementHome: Ensuring tabs are setup');
    // Only setup if not already done
    if (_tabs.isEmpty) {
      debugdebugPrint('ðŸ“ EmployeeManagementHome: Tabs are empty, setting up...');
      _setupTabs();
      debugdebugPrint(
          'âœ… EmployeeManagementHome: Setup complete, tabs length: ${_tabs.length}');
    } else {
      debugdebugPrint(
          'ðŸš¦ EmployeeManagementHome: Tabs already setup (${_tabs.length} tabs)');
    }
  }

  void _setupTabs() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      debugdebugPrint(
          'ðŸ” EmployeeManagementHome: Auth provider user: ${authProvider.user?.email}');
      debugdebugPrint(
          'ðŸ‘‘ EmployeeManagementHome: isShopOwnerOrAdmin: ${authProvider.isShopOwnerOrAdmin}');
      debugdebugPrint(
          'ðŸŽ­ EmployeeManagementHome: userRole: ${authProvider.userRole}');

      final isShopOwnerOrAdmin = authProvider.isShopOwnerOrAdmin;

      if (isShopOwnerOrAdmin) {
        debugdebugPrint('ðŸ‘¨â€ðŸ’¼ EmployeeManagementHome: Setting up admin tabs');
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
        debugdebugPrint('ðŸ‘· EmployeeManagementHome: Setting up employee tabs');
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
      debugdebugPrint(
          'ðŸ“± EmployeeManagementHome: Tabs setup complete with ${_tabs.length} tabs');
    } catch (e) {
      debugdebugPrint('âŒ EmployeeManagementHome: Error setting up tabs: $e');

      // Fallback tabs in case of error
      debugdebugPrint('ðŸ”„ EmployeeManagementHome: Using fallback tabs due to error');
      _tabs = [
        const EmployeeListSimple(),
      ];
      _tabTitles = ['Employee List'];
      _tabIcons = [
        Icons.people,
      ];

      setState(() {}); // Trigger rebuild with fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    debugdebugPrint('ðŸ”„ EmployeeManagementHome: Building widget');

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        debugdebugPrint('ðŸ” EmployeeManagementHome build: Checking permissions');
        // Check if user has permission to access employee management
        final hasEmployeeManagementAccess = authProvider.isShopOwnerOrAdmin ||
            authProvider.hasRole(UserRole.employee) ||
            authProvider.hasRole(UserRole.tailor) ||
            authProvider.hasRole(UserRole.cutter) ||
            authProvider.hasRole(UserRole.finisher) ||
            authProvider.hasRole(UserRole.supervisor) ||
            authProvider.hasRole(UserRole.apprentice);

        debugdebugPrint(
            'ðŸ”‘ EmployeeManagementHome: hasEmployeeManagementAccess: $hasEmployeeManagementAccess');

        if (!hasEmployeeManagementAccess) {
          debugdebugPrint('âŒ EmployeeManagementHome: Access denied');
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

        debugdebugPrint(
            'âœ… EmployeeManagementHome: Building main scaffold with ${_tabs.length} tabs');

        return LayoutBuilder(
          builder: (context, constraints) {
            final deviceType =
                ResponsiveUtils.getDeviceType(constraints.maxWidth);

            if (deviceType == DeviceType.desktop) {
              // Desktop layout with side navigation
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Employee Management'),
                  toolbarHeight: kToolbarHeight + 5,
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  actions: const [CommonAppBarActions()],
                ),
                body: Row(
                  children: [
                    // Side Navigation
                    Container(
                      width: 250,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border(
                          right: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Add Employee Button for desktop
                          if (_selectedTab == 0 &&
                              authProvider.isShopOwnerOrAdmin)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final employeeProvider =
                                      Provider.of<EmployeeProvider>(context,
                                          listen: false);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EmployeeCreateScreen(),
                                    ),
                                  ).then((_) async {
                                    if (mounted && _selectedTab == 0) {
                                      await employeeProvider.loadEmployees();
                                    }
                                  });
                                },
                                icon: const Icon(Icons.person_add),
                                label: const Text('Add Employee'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                            ),
                          // Navigation items
                          Expanded(
                            child: ListView.builder(
                              itemCount: _tabs.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Icon(_tabIcons[index]),
                                  title: Text(_tabTitles[index]),
                                  selected: _selectedTab == index,
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = index;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Main Content
                    Expanded(
                      child: (_tabs.isEmpty || _selectedTab >= _tabs.length)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  const Text(
                                      'Setting up employee management...'),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: () {
                                      debugdebugPrint(
                                          'ðŸ”„ EmployeeManagementHome: Manual retry triggered');
                                      _ensureTabsAreSetup();
                                    },
                                    child: const Text('Retry Setup'),
                                  ),
                                ],
                              ),
                            )
                          : _tabs[_selectedTab],
                    ),
                  ],
                ),
              );
            } else {
              // Mobile and tablet layout with bottom navigation
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
                                debugdebugPrint(
                                    'ðŸ”„ EmployeeManagementHome: Manual retry triggered');
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
                floatingActionButton:
                    _selectedTab == 0 && authProvider.isShopOwnerOrAdmin
                        ? FloatingActionButton.extended(
                            onPressed: () {
                              final employeeProvider =
                                  Provider.of<EmployeeProvider>(context,
                                      listen: false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EmployeeCreateScreen(),
                                ),
                              ).then((_) async {
                                if (mounted && _selectedTab == 0) {
                                  await employeeProvider.loadEmployees();
                                }
                              });
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Employee'),
                          )
                        : null,
              );
            }
          },
        );
      },
    );
  }
}


