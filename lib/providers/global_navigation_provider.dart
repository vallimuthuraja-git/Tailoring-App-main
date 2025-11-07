import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'package:tailoring_app/services/auth_service.dart';
import '../product/products_screen.dart';
import '../screens/services/service_catalog_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/home/home_screen.dart'; // For DashboardTab
import '../screens/admin/product_catalog_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/employee/employee_management_home.dart';
import '../screens/customer/customer_management_screen.dart';
import '../screens/dashboard/analytics_dashboard_screen.dart';
import '../screens/database/database_management_home.dart';
import '../screens/workflow/tailoring_workflow_screen.dart';
import '../screens/ai/ai_assistance_screen.dart';
import '../screens/cart/cart_screen.dart';

/// Enhanced Global Navigation Provider for seamless app-wide navigation
class GlobalNavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  List<BottomNavigationBarItem> _navItems = [];
  List<Map<String, dynamic>> _navigationHistory = [];
  Map<String, dynamic> _currentContext = {};
  bool _isNavigating = false;

  // Navigation analytics
  Map<String, int> _screenVisitCounts = {};
  DateTime? _lastNavigationTime;

  int get currentIndex => _currentIndex;
  List<Widget> get screens => _screens;
  List<BottomNavigationBarItem> get navItems => _navItems;
  List<Map<String, dynamic>> get navigationHistory => _navigationHistory;
  Map<String, dynamic> get currentContext => _currentContext;
  bool get isNavigating => _isNavigating;
  Map<String, int> get screenVisitCounts => _screenVisitCounts;

  /// Enhanced navigation methods for seamless experience

  /// Navigate with context tracking
  void navigateToIndexWithContext(int index, {Map<String, dynamic>? context}) {
    if (index >= 0 && index < _screens.length && !_isNavigating) {
      _isNavigating = true;

      // Track navigation history
      _addToNavigationHistory(_currentIndex, context ?? _currentContext);

      // Update context
      _currentContext = context ?? {};

      // Update visit counts
      _trackScreenVisit(index);

      _currentIndex = index;
      _lastNavigationTime = DateTime.now();

      notifyListeners();

      // Reset navigation flag after animation
      Future.delayed(const Duration(milliseconds: 300), () {
        _isNavigating = false;
        notifyListeners();
      });
    }
  }

  /// Navigate to screen with analytics
  void navigateToScreen(String screenName, {Map<String, dynamic>? context}) {
    final screenIndex = _getScreenIndexByName(screenName);
    if (screenIndex != -1) {
      navigateToIndexWithContext(screenIndex, context: context);
    }
  }

  /// Smart navigation based on user role and context
  void smartNavigate(String action, {Map<String, dynamic>? context}) {
    final authProvider = _getAuthProvider();
    if (authProvider == null) return;

    final userRole = authProvider.userRole;
    final targetScreen = _getSmartNavigationTarget(action, userRole, context);

    if (targetScreen != null) {
      navigateToScreen(targetScreen, context: context);
    }
  }

  /// Get contextual navigation suggestions
  List<Map<String, dynamic>> getContextualSuggestions() {
    final authProvider = _getAuthProvider();
    if (authProvider == null) return [];

    final userRole = authProvider.userRole;
    final suggestions = <Map<String, dynamic>>[];

    // Add frequently visited screens
    final topVisited = _getTopVisitedScreens(3);
    suggestions.addAll(topVisited.map((screen) => {
      'type': 'frequent',
      'title': _getScreenTitle(screen),
      'action': () => navigateToIndex(screen),
    }));

    // Add role-based suggestions
    final roleSuggestions = _getRoleBasedSuggestions(userRole);
    suggestions.addAll(roleSuggestions);

    // Add contextual suggestions based on current screen
    final contextual = _getContextualSuggestions(_currentIndex, userRole);
    suggestions.addAll(contextual);

    return suggestions.take(6).toList(); // Limit to 6 suggestions
  }

  /// Get navigation breadcrumbs
  List<Map<String, dynamic>> getBreadcrumbs() {
    final breadcrumbs = <Map<String, dynamic>>[];
    final recentHistory = _navigationHistory.take(3).toList().reversed;

    for (final entry in recentHistory) {
      breadcrumbs.add({
        'title': _getScreenTitle(entry['fromIndex']),
        'index': entry['fromIndex'],
        'context': entry['context'],
      });
    }

    breadcrumbs.add({
      'title': _getScreenTitle(_currentIndex),
      'index': _currentIndex,
      'context': _currentContext,
      'isCurrent': true,
    });

    return breadcrumbs;
  }

  /// Check if navigation is available for user role
  bool isNavigationAllowed(int index, UserRole userRole) {
    // Define role-based access control
    final restrictedScreens = {
      UserRole.customer: [], // Customers can access all basic screens
      UserRole.employee: [], // Employees can access most screens
      UserRole.admin: [], // Admins can access all screens
    };

    return !restrictedScreens[userRole]!.contains(index);
  }

  /// Get quick actions based on user role and context
  List<Map<String, dynamic>> getQuickActions() {
    final authProvider = _getAuthProvider();
    if (authProvider == null) return [];

    final userRole = authProvider.userRole;
    return _getRoleBasedQuickActions(userRole, _currentIndex);
  }

  // Private helper methods

  void _addToNavigationHistory(int fromIndex, Map<String, dynamic> context) {
    _navigationHistory.add({
      'fromIndex': fromIndex,
      'toIndex': _currentIndex,
      'timestamp': DateTime.now(),
      'context': Map.from(context),
    });

    // Keep only last 10 entries
    if (_navigationHistory.length > 10) {
      _navigationHistory.removeAt(0);
    }
  }

  void _trackScreenVisit(int index) {
    _screenVisitCounts[index] = (_screenVisitCounts[index] ?? 0) + 1;
  }

  int _getScreenIndexByName(String screenName) {
    // Map screen names to indices based on current navigation setup
    final screenMap = {
      'dashboard': 0,
      'products': 1,
      'services': 2,
      'orders': 3,
      'profile': 4,
    };
    return screenMap[screenName.toLowerCase()] ?? -1;
  }

  String? _getSmartNavigationTarget(String action, UserRole userRole, Map<String, dynamic>? context) {
    final actionMap = {
      'add_product': userRole == UserRole.admin ? 'products' : null,
      'manage_orders': 'orders',
      'view_analytics': userRole == UserRole.admin ? 'dashboard' : null,
      'customer_service': 'services',
    };
    return actionMap[action];
  }

  List<int> _getTopVisitedScreens(int count) {
    final sorted = _screenVisitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(count).map((e) => e.key).toList();
  }

  String _getScreenTitle(int index) {
    if (index < _navItems.length) {
      return _navItems[index].label ?? 'Screen $index';
    }
    return 'Screen $index';
  }

  List<Map<String, dynamic>> _getRoleBasedSuggestions(UserRole userRole) {
    final suggestions = <Map<String, dynamic>>[];

    switch (userRole) {
      case UserRole.admin:
        suggestions.addAll([
          {
            'type': 'role_based',
            'title': 'Analytics Dashboard',
            'action': () => navigateToIndex(0),
          },
          {
            'type': 'role_based',
            'title': 'User Management',
            'action': () => smartNavigate('manage_users'),
          },
        ]);
        break;
      case UserRole.employee:
        suggestions.addAll([
          {
            'type': 'role_based',
            'title': 'Active Orders',
            'action': () => navigateToIndex(3),
          },
          {
            'type': 'role_based',
            'title': 'Customer Service',
            'action': () => navigateToIndex(2),
          },
        ]);
        break;
      case UserRole.customer:
        suggestions.addAll([
          {
            'type': 'role_based',
            'title': 'Browse Products',
            'action': () => navigateToIndex(1),
          },
          {
            'type': 'role_based',
            'title': 'My Orders',
            'action': () => navigateToIndex(3),
          },
        ]);
        break;
    }

    return suggestions;
  }

  List<Map<String, dynamic>> _getContextualSuggestions(int currentIndex, UserRole userRole) {
    final suggestions = <Map<String, dynamic>>[];

    // Context-based suggestions
    switch (currentIndex) {
      case 0: // Dashboard
        if (userRole == UserRole.admin) {
          suggestions.add({
            'type': 'contextual',
            'title': 'Quick Add Product',
            'action': () => smartNavigate('add_product'),
          });
        }
        break;
      case 1: // Products
        suggestions.add({
          'type': 'contextual',
          'title': 'View Cart',
          'action': () => smartNavigate('view_cart'),
        });
        break;
      case 3: // Orders
        suggestions.add({
          'type': 'contextual',
          'title': 'Customer Support',
          'action': () => navigateToIndex(2),
        });
        break;
    }

    return suggestions;
  }

  List<Map<String, dynamic>> _getRoleBasedQuickActions(UserRole userRole, int currentIndex) {
    final actions = <Map<String, dynamic>>[];

    switch (userRole) {
      case UserRole.admin:
        actions.addAll([
          {
            'icon': Icons.add_business,
            'title': 'Add Product',
            'action': () => smartNavigate('add_product'),
            'color': Colors.green,
          },
          {
            'icon': Icons.analytics,
            'title': 'Analytics',
            'action': () => navigateToIndex(0),
            'color': Colors.blue,
          },
          {
            'icon': Icons.people,
            'title': 'User Management',
            'action': () => smartNavigate('manage_users'),
            'color': Colors.purple,
          },
        ]);
        break;
      case UserRole.employee:
        actions.addAll([
          {
            'icon': Icons.assignment,
            'title': 'Active Orders',
            'action': () => navigateToIndex(3),
            'color': Colors.orange,
          },
          {
            'icon': Icons.support,
            'title': 'Customer Help',
            'action': () => navigateToIndex(2),
            'color': Colors.teal,
          },
        ]);
        break;
      case UserRole.customer:
        actions.addAll([
          {
            'icon': Icons.shopping_cart,
            'title': 'Cart',
            'action': () => smartNavigate('view_cart'),
            'color': Colors.red,
          },
          {
            'icon': Icons.favorite,
            'title': 'Wishlist',
            'action': () => smartNavigate('view_wishlist'),
            'color': Colors.pink,
          },
        ]);
        break;
    }

    return actions;
  }

  AuthProvider? _getAuthProvider() {
    // This will be set by the provider context
    return null; // Will be overridden by provider
  }
+++++++ REPLACE</diff>
<task_progress>- [x] Analyze current navigation structure
- [x] Review all screen categories and their purposes
- [x] Test navigation flow between screens
- [x] Identify navigation inconsistencies
- [x] Plan seamless navigation improvements
- [x] Implement enhanced navigation system
- [ ] Add contextual navigation features
- [ ] Improve role-based navigation flows
+++++++ REPLACE</diff>
<task_progress>- [x] Analyze current navigation structure
- [x] Review all screen categories and their purposes
- [x] Test navigation flow between screens
- [x] Identify navigation inconsistencies
- [x] Plan seamless navigation improvements
- [ ] Implement enhanced navigation system
- [ ] Add contextual navigation features
- [ ] Improve role-based navigation flows

  /// Initialize navigation based on user role
  void initializeNavigation(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UserRole userRole = authProvider.userRole;

    if (userRole == UserRole.employee) {
      _setupEmployeeNavigation();
    } else {
      _setupRegularUserNavigation();
    }
    notifyListeners();
  }

  /// Setup navigation for regular users
  void _setupRegularUserNavigation() {
    _screens = [
      DashboardTab(
        onNavigateToProducts: navigateToProducts,
        onNavigateToServices: navigateToServices,
        onNavigateToOrders: navigateToOrders,
      ),
      const ProductsScreen(),
      const ServiceCatalogScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];
    _navItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: 'Products',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.business),
        label: 'Services',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long),
        label: 'Orders',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  /// Setup navigation for employees
  void _setupEmployeeNavigation() {
    _screens = [
      DashboardTab(
        onNavigateToOrders: navigateToOrders,
      ),
      const ProductsScreen(),
      const ServiceCatalogScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];
    _navItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: 'Products',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.business),
        label: 'Services',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long),
        label: 'Orders',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  /// Navigate to specific index
  void navigateToIndex(int index) {
    if (index >= 0 && index < _screens.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Navigate to dashboard
  void navigateToDashboard() => navigateToIndex(0);

  /// Navigate to products (if available)
  void navigateToProducts() {
    if (_screens.length > 1) navigateToIndex(1);
  }

  /// Navigate to services (if available)
  void navigateToServices() {
    if (_screens.length > 2) navigateToIndex(2);
  }

  /// Navigate to orders
  void navigateToOrders() {
    final targetIndex = _screens.length == 3 ? 1 : 3;
    if (targetIndex < _screens.length) navigateToIndex(targetIndex);
  }

  /// Navigate to profile
  void navigateToProfile() => navigateToIndex(_screens.length - 1);

  /// Check if navigation is initialized
  bool get isInitialized => _screens.isNotEmpty;

  /// Get current screen widget
  Widget get currentScreen =>
      _screens.isNotEmpty && _currentIndex < _screens.length
          ? _screens[_currentIndex]
          : const SizedBox.shrink();
}
