import 'package:flutter/material.dart';

class HomeController with ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  List<Map<String, dynamic>> notifications = [];
  bool _showNotificationPanel = false;

  bool get showNotificationPanel => _showNotificationPanel;

  int get unreadNotificationCount =>
      notifications.where((n) => !n['read']).length;

  HomeController() {
    _loadNotifications();
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
  }

  void handleSearch(String query, BuildContext context) {
    if (query.isEmpty) return;
    // Navigate to search results
    // Implementation depends on existing search functionality
    print('Searching for: $query');
  }

  void handleVoiceSearch(BuildContext context) {
    // Implement voice search
    print('Voice search activated');
  }

  List<Map<String, dynamic>> getCategories(bool isShopOwner) {
    if (isShopOwner) {
      return [
        {'name': 'Products', 'icon': Icons.shopping_bag, 'count': 150},
        {'name': 'Services', 'icon': Icons.business, 'count': 25},
        {'name': 'Customers', 'icon': Icons.people, 'count': 89},
        {'name': 'Orders', 'icon': Icons.receipt_long, 'count': 45},
        {'name': 'Employees', 'icon': Icons.group, 'count': 12},
        {'name': 'Analytics', 'icon': Icons.analytics, 'count': 0},
      ];
    } else {
      return [
        {'name': 'Shirts', 'icon': Icons.checkroom, 'count': 45},
        {'name': 'Pants', 'icon': Icons.accessibility, 'count': 32},
        {'name': 'Suits', 'icon': Icons.business_center, 'count': 18},
        {'name': 'Dresses', 'icon': Icons.woman, 'count': 28},
        {'name': 'Accessories', 'icon': Icons.watch, 'count': 67},
        {'name': 'Alterations', 'icon': Icons.design_services, 'count': 12},
      ];
    }
  }

  List<Map<String, dynamic>> getRecentActivities(String? userId) {
    // Mock data - in real implementation, fetch from Firebase
    return [
      {
        'type': 'order',
        'title': 'Order #1234 completed',
        'subtitle': 'Custom suit tailoring',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'type': 'review',
        'title': 'New review received',
        'subtitle': '5 stars for wedding dress',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'icon': Icons.star,
        'color': Colors.amber,
      },
      {
        'type': 'product',
        'title': 'Product viewed',
        'subtitle': 'Premium cotton shirts',
        'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
        'icon': Icons.visibility,
        'color': Colors.blue,
      },
    ];
  }

  void toggleNotificationPanel() {
    _showNotificationPanel = !_showNotificationPanel;
    notifyListeners();
  }

  void handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read and handle navigation
    notification['read'] = true;
    _loadNotifications(); // Refresh
    // Navigate based on notification type
  }

  void _loadNotifications() {
    // Mock notifications - in real implementation, fetch from Firebase
    notifications = [
      {
        'id': '1',
        'title': 'Order Update',
        'message': 'Your custom suit is ready for pickup',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'read': false,
        'type': 'order',
      },
      {
        'id': '2',
        'title': 'New Promotion',
        'message': '20% off on all tailoring services',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'read': true,
        'type': 'promotion',
      },
    ];
    notifyListeners();
  }
}
