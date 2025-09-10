import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  OrderStatus? _selectedStatusFilter;
  String _searchQuery = '';

  // Getters
  List<Order> get orders => _searchQuery.isEmpty && _selectedStatusFilter == null
      ? _orders
      : _filteredOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Order> get pendingOrders => _orders.where((order) => order.status == OrderStatus.pending).toList();
  List<Order> get inProgressOrders => _orders.where((order) => order.status == OrderStatus.inProgress).toList();
  List<Order> get completedOrders => _orders.where((order) => order.status == OrderStatus.completed).toList();

  // Calculate statistics
  int get totalOrders => _orders.length;
  int get pendingOrdersCount => pendingOrders.length;
  int get inProgressOrdersCount => inProgressOrders.length;
  int get completedOrdersCount => completedOrders.length;

  double get totalRevenue => _orders
      .where((order) => order.paymentStatus == PaymentStatus.paid)
      .fold(0.0, (sum, order) => sum + order.totalAmount);

  double get pendingPayments => _orders
      .where((order) => order.paymentStatus == PaymentStatus.pending)
      .fold(0.0, (sum, order) => sum + order.remainingAmount);

  // Search and filter
  void searchOrders(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterByStatus(OrderStatus? status) {
    _selectedStatusFilter = status;
    _applyFilters();
  }

  void _applyFilters() {
    List<Order> filtered = _orders;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        return order.id.toLowerCase().contains(_searchQuery) ||
               order.customerId.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply status filter
    if (_selectedStatusFilter != null) {
      filtered = filtered.where((order) => order.status == _selectedStatusFilter).toList();
    }

    _filteredOrders = filtered;
    notifyListeners();
  }

  // Load orders from Firestore
  Future<void> loadOrders({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _firebaseService.getCollection('orders');
      final orders = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();

      // Filter by user if specified (for customers)
      if (userId != null) {
        _orders = orders.where((order) => order.customerId == userId).toList();
      } else {
        _orders = orders;
      }

      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load orders: $e';
      notifyListeners();
    }
  }

  // Stream orders for real-time updates
  Stream<List<Order>> getOrdersStream({String? userId}) {
    return _firebaseService.collectionStream('orders').map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();

      if (userId != null) {
        return orders.where((order) => order.customerId == userId).toList();
      }
      return orders;
    });
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final docSnapshot = await _firebaseService.getDocument('orders', orderId);
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id;
        return Order.fromJson(data);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to load order: $e';
      notifyListeners();
      return null;
    }
  }

  // Stream single order
  Stream<Order?> getOrderStream(String orderId) {
    return _firebaseService.documentStream('orders', orderId).map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Order.fromJson(data);
      }
      return null;
    });
  }

  // Create new order with enhanced parameters
  Future<bool> createOrder({
    required String customerId,
    required List<OrderItem> items,
    required Map<String, dynamic> measurements,
    required String? specialInstructions,
    required List<String> orderImages,
    String? preferredDate,
    String? preferredTimeSlot,
    String? paymentMethod,
    double? advanceAmount,
    double? remainingAmount,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Calculate totals
      double totalAmount = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

      // Use provided advance amounts or calculate default (30% advance)
      double orderAdvanceAmount = advanceAmount ?? (totalAmount * 0.3);
      double orderRemainingAmount = remainingAmount ?? (totalAmount - orderAdvanceAmount);

      // Handle scheduling data from measurements if available
      String? finalPreferredDate = preferredDate ?? measurements['preferred_date'];
      String? finalPreferredTimeSlot = preferredTimeSlot ?? measurements['preferred_time_slot'];
      String? finalPaymentMethod = paymentMethod ?? measurements['payment_method'];

      // Store scheduling data in measurements if not already present
      final enhancedMeasurements = Map<String, dynamic>.from(measurements);
      if (finalPreferredDate != null && !enhancedMeasurements.containsKey('preferred_date')) {
        enhancedMeasurements['preferred_date'] = finalPreferredDate;
      }
      if (finalPreferredTimeSlot != null && !enhancedMeasurements.containsKey('preferred_time_slot')) {
        enhancedMeasurements['preferred_time_slot'] = finalPreferredTimeSlot;
      }
      if (finalPaymentMethod != null && !enhancedMeasurements.containsKey('payment_method')) {
        enhancedMeasurements['payment_method'] = finalPaymentMethod;
      }

      final order = Order(
        id: '',
        customerId: customerId,
        items: items,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        totalAmount: totalAmount,
        advanceAmount: orderAdvanceAmount,
        remainingAmount: orderRemainingAmount,
        orderDate: DateTime.now(),
        deliveryDate: DateTime.now().add(const Duration(days: 7)), // Default 7 days
        specialInstructions: specialInstructions,
        measurements: enhancedMeasurements,
        orderImages: orderImages,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final orderData = order.toJson();
      orderData.remove('id'); // Remove ID for new orders

      await _firebaseService.addDocument('orders', orderData);

      // Reload orders
      await loadOrders(userId: customerId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create order: $e';
      notifyListeners();
      return false;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.updateDocument('orders', orderId, {
        'status': newStatus.index,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Reload orders
      await loadOrders();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update order status: $e';
      notifyListeners();
      return false;
    }
  }

  // Update payment status
  Future<bool> updatePaymentStatus(String orderId, PaymentStatus newStatus, {double? paidAmount}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final order = _orders.firstWhere((o) => o.id == orderId);
      final updates = {
        'paymentStatus': newStatus.index,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (paidAmount != null) {
        if (newStatus == PaymentStatus.paid) {
          updates['advanceAmount'] = paidAmount;
          updates['remainingAmount'] = order.totalAmount - paidAmount;
        }
      }

      await _firebaseService.updateDocument('orders', orderId, updates);

      // Reload orders
      await loadOrders();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update payment status: $e';
      notifyListeners();
      return false;
    }
  }

  // Update delivery date
  Future<bool> updateDeliveryDate(String orderId, DateTime newDate) async {
    try {
      await _firebaseService.updateDocument('orders', orderId, {
        'deliveryDate': newDate.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Reload orders
      await loadOrders();

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update delivery date: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete order
  Future<bool> deleteOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.deleteDocument('orders', orderId);

      // Reload orders
      await loadOrders();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete order: $e';
      notifyListeners();
      return false;
    }
  }

  // Get order statistics
  Map<String, dynamic> getOrderStatistics() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    final thisMonthOrders = _orders.where((order) => order.createdAt.isAfter(thisMonth)).toList();
    final lastMonthOrders = _orders.where((order) =>
        order.createdAt.isAfter(lastMonth) && order.createdAt.isBefore(thisMonth)).toList();

    return {
      'totalOrders': _orders.length,
      'thisMonthOrders': thisMonthOrders.length,
      'lastMonthOrders': lastMonthOrders.length,
      'pendingOrders': pendingOrders.length,
      'completedOrders': completedOrders.length,
      'totalRevenue': totalRevenue,
      'pendingPayments': pendingPayments,
      'averageOrderValue': _orders.isEmpty ? 0.0 : totalRevenue / _orders.length,
      'completionRate': _orders.isEmpty ? 0.0 : (completedOrders.length / _orders.length) * 100,
    };
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedStatusFilter = null;
    _filteredOrders = [];
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Demo order creation
  Future<void> createDemoOrder(String customerId, Product product) async {
    final orderItem = OrderItem(
      id: 'demo-item-${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      productName: product.name,
      category: product.category.toString().split('.').last,
      price: product.basePrice,
      quantity: 1,
      customizations: {},
      notes: 'Demo order',
    );

    await createOrder(
      customerId: customerId,
      items: [orderItem],
      measurements: {
        'chest': '40',
        'waist': '32',
        'length': '28',
      },
      specialInstructions: 'Demo order for testing',
      orderImages: [],
    );
  }
}
