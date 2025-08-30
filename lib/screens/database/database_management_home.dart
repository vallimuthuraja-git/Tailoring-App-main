import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import 'collection_list_screen.dart';
import 'database_statistics_screen.dart';
import 'bulk_operations_screen.dart';

class DatabaseManagementHome extends StatefulWidget {
  const DatabaseManagementHome({super.key});

  @override
  State<DatabaseManagementHome> createState() => _DatabaseManagementHomeState();
}

class _DatabaseManagementHomeState extends State<DatabaseManagementHome> {
  int _selectedTab = 0;
  late List<Widget> _tabs;
  late List<String> _tabTitles;
  late List<IconData> _tabIcons;

  @override
  void initState() {
    super.initState();
    _initializeTabs();
  }

  void _initializeTabs() {
    _tabs = [
      const CollectionListScreen(),
      const DatabaseStatisticsScreen(),
      const BulkOperationsScreen(),
    ];
    _tabTitles = [
      'Collections',
      'Statistics',
      'Operations',
    ];
    _tabIcons = [
      Icons.storage,
      Icons.analytics,
      Icons.settings,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Only allow shop owners and admins to access database management
        final hasDatabaseAccess = authProvider.isShopOwnerOrAdmin;

        if (!hasDatabaseAccess) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied'),
              backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
              foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 64,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                        : AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You don\'t have permission to access database management.',
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                      foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                    ),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Database Management'),
            toolbarHeight: kToolbarHeight + 5,
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
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
                tooltip: 'Refresh Data',
                onPressed: () {
                  // Refresh current tab data
                  setState(() {});
                },
              ),
            ],
          ),
          body: _tabs[_selectedTab],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedTab,
            onTap: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
            selectedItemColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
            unselectedItemColor: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                : AppColors.onSurface.withValues(alpha: 0.6),
            items: List.generate(
              _tabs.length,
              (index) => BottomNavigationBarItem(
                icon: Icon(_tabIcons[index]),
                label: _tabTitles[index],
              ),
            ),
          ),
        );
      },
    );
  }
}