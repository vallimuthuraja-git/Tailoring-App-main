import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'package:tailoring_app/services/auth_service.dart';
import '../product/products_screen.dart';
import '../screens/services/service_catalog_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/home/home_screen.dart'; // For DashboardTab

/// Global Navigation Provider for app-wide bottom navigation management
class GlobalNavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  List<BottomNavigationBarItem> _navItems = [];

  int get currentIndex => _currentIndex;

  List<Widget> get screens => _screens;

  List<BottomNavigationBarItem> get navItems => _navItems;

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
