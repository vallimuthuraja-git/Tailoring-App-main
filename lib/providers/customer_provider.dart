import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../services/firebase_service.dart';

class CustomerProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  Customer? _currentCustomer;
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Customer? get currentCustomer => _currentCustomer;
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Customer statistics
  int get totalCustomers => _customers.length;
  int get activeCustomers => _customers.where((c) => c.isActive).length;

  double get averageOrderValue {
    if (_customers.isEmpty) return 0.0;
    double totalRevenue =
        _customers.fold(0.0, (sum, customer) => sum + customer.totalSpent);
    return totalRevenue / _customers.length;
  }

  Map<String, int> get customersByCategory {
    final categories = <String, int>{};
    for (final customer in _customers) {
      // This would be based on customer preferences or order history
      final category = customer.preferences.isNotEmpty
          ? customer.preferences.first
          : 'General';
      categories[category] = (categories[category] ?? 0) + 1;
    }
    return categories;
  }

  // Load customer profile
  Future<void> loadCustomerProfile(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final docSnapshot =
          await _firebaseService.getDocument('customers', customerId);
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id;
        _currentCustomer = Customer.fromJson(data);
      } else {
        _errorMessage = 'Customer profile not found';
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load customer profile: $e';
      notifyListeners();
    }
  }

  // Load all customers (for shop owners)
  Future<void> loadAllCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _firebaseService.getCollection('customers');
      _customers = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Customer.fromJson(data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load customers: $e';
      notifyListeners();
      debugPrint('ERROR: Failed to load customers: $e');
    }
  }

  // Stream customer profile for real-time updates
  Stream<Customer?> getCustomerProfileStream(String customerId) {
    return _firebaseService.documentStream('customers', customerId).map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Customer.fromJson(data);
      }
      return null;
    });
  }

  // Create new customer profile
  Future<bool> createCustomerProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    String? photoUrl,
    Map<String, dynamic>? initialMeasurements,
    List<String>? preferences,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final customer = Customer(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        photoUrl: photoUrl,
        measurements: initialMeasurements ?? {},
        preferences: preferences ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final customerData = customer.toJson();
      await _firebaseService.addDocument('customers', customerData);

      _currentCustomer = customer;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create customer profile: $e';
      notifyListeners();
      return false;
    }
  }

  // Update customer profile
  Future<bool> updateCustomerProfile({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    Map<String, dynamic>? measurements,
    List<String>? preferences,
  }) async {
    if (_currentCustomer == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (measurements != null) updates['measurements'] = measurements;
      if (preferences != null) updates['preferences'] = preferences;

      await _firebaseService.updateDocument(
          'customers', _currentCustomer!.id, updates);

      // Update local customer object
      _currentCustomer = Customer(
        id: _currentCustomer!.id,
        name: name ?? _currentCustomer!.name,
        email: email ?? _currentCustomer!.email,
        phone: phone ?? _currentCustomer!.phone,
        photoUrl: photoUrl ?? _currentCustomer!.photoUrl,
        measurements: measurements ?? _currentCustomer!.measurements,
        preferences: preferences ?? _currentCustomer!.preferences,
        createdAt: _currentCustomer!.createdAt,
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update customer profile: $e';
      notifyListeners();
      return false;
    }
  }

  // Update customer measurements
  Future<bool> updateMeasurements(Map<String, dynamic> newMeasurements) async {
    if (_currentCustomer == null) return false;

    return await updateCustomerProfile(
      measurements: {
        ..._currentCustomer!.measurements,
        ...newMeasurements,
      },
    );
  }

  // Add customer preference
  Future<bool> addCustomerPreference(String preference) async {
    if (_currentCustomer == null) return false;

    final currentPreferences = List<String>.from(_currentCustomer!.preferences);
    if (!currentPreferences.contains(preference)) {
      currentPreferences.add(preference);
      return await updateCustomerProfile(preferences: currentPreferences);
    }
    return true;
  }

  // Remove customer preference
  Future<bool> removeCustomerPreference(String preference) async {
    if (_currentCustomer == null) return false;

    final currentPreferences = List<String>.from(_currentCustomer!.preferences);
    currentPreferences.remove(preference);
    return await updateCustomerProfile(preferences: currentPreferences);
  }

  // Get customers by preference
  List<Customer> getCustomersByPreference(String preference) {
    return _customers
        .where((customer) => customer.preferences.contains(preference))
        .toList();
  }

  // Search customers
  List<Customer> searchCustomers(String query) {
    final lowerQuery = query.toLowerCase();
    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(lowerQuery) ||
          customer.email.toLowerCase().contains(lowerQuery) ||
          customer.phone.contains(lowerQuery);
    }).toList();
  }

  // Get customer order history (would integrate with OrderProvider)
  Future<List<Order>> getCustomerOrderHistory(String customerId) async {
    try {
      final querySnapshot = await _firebaseService.getCollection('orders');
      final orders = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Order.fromJson(data);
          })
          .where((order) => order.customerId == customerId)
          .toList();

      return orders;
    } catch (e) {
      _errorMessage = 'Failed to load customer order history: $e';
      notifyListeners();
      return [];
    }
  }

  // Get customer statistics
  Map<String, dynamic> getCustomerStatistics(String customerId) {
    // This would typically integrate with order data
    // For now, returning mock statistics
    return {
      'totalOrders': 5,
      'totalSpent': 8500.0,
      'averageOrderValue': 1700.0,
      'lastOrderDate': DateTime.now().subtract(const Duration(days: 7)),
      'preferredCategories': ['Men\'s Wear', 'Formal Wear'],
      'loyaltyTier': 'Gold',
    };
  }

  // Standard measurement categories for tailoring
  static const Map<String, String> measurementCategories = {
    'upperBody': 'Upper Body',
    'lowerBody': 'Lower Body',
    'neckAndCollar': 'Neck & Collar',
    'armsAndSleeves': 'Arms & Sleeves',
    'waistAndHips': 'Waist & Hips',
    'lengthAndFit': 'Length & Fit',
  };

  // Standard measurement points
  static const Map<String, Map<String, String>> standardMeasurements = {
    'upperBody': {
      'chest': 'Chest circumference around fullest part',
      'waist': 'Natural waist circumference',
      'shoulder': 'Shoulder seam to shoulder seam',
      'backWidth': 'Back width between armholes',
    },
    'lowerBody': {
      'hip': 'Hip circumference at widest point',
      'inseam': 'Inner leg length from crotch to ankle',
      'outseam': 'Outer leg length from waist to ankle',
      'thigh': 'Thigh circumference',
    },
    'neckAndCollar': {
      'neck': 'Neck circumference',
      'collarLength': 'Collar length around neck',
    },
    'armsAndSleeves': {
      'bicep': 'Bicep circumference',
      'wrist': 'Wrist circumference',
      'sleeveLength': 'Sleeve length from shoulder to wrist',
      'armhole': 'Armhole circumference',
    },
    'waistAndHips': {
      'waist': 'Waist circumference',
      'hip': 'Hip circumference',
      'seat': 'Seat circumference',
    },
    'lengthAndFit': {
      'shirtLength': 'Shirt length from shoulder to bottom',
      'trouserLength': 'Trouser length from waist to ankle',
      'jacketLength': 'Jacket length from shoulder to bottom',
    },
  };

  // Get measurement guide for a specific category
  String getMeasurementGuide(String category) {
    final measurements = standardMeasurements[category];
    if (measurements == null) return '';

    final guide = StringBuffer();
    guide.writeln('${measurementCategories[category]} Measurements:');
    guide.writeln('');

    measurements.forEach((key, description) {
      guide.writeln('ðŸ“ $key: $description');
    });

    return guide.toString();
  }

  // Validate measurement value
  bool isValidMeasurement(String measurement, double value) {
    final ranges = {
      'chest': {'min': 30.0, 'max': 60.0},
      'waist': {'min': 25.0, 'max': 50.0},
      'hip': {'min': 30.0, 'max': 55.0},
      'neck': {'min': 12.0, 'max': 20.0},
      'shoulder': {'min': 14.0, 'max': 24.0},
      'sleeveLength': {'min': 20.0, 'max': 40.0},
      'inseam': {'min': 25.0, 'max': 40.0},
      'outseam': {'min': 30.0, 'max': 50.0},
    };

    final range = ranges[measurement];
    if (range == null) return true; // Unknown measurement, accept any value

    return value >= range['min']! && value <= range['max']!;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Demo customer data
  Future<void> loadDemoCustomerData() async {
    final demoCustomers = [
      Customer(
        id: 'demo-customer-1',
        name: 'Rajesh Kumar',
        email: 'rajesh.kumar@email.com',
        phone: '+91-9876543210',
        measurements: {
          'chest': 40.0,
          'waist': 32.0,
          'shoulder': 18.0,
          'neck': 15.5,
          'sleeveLength': 25.0,
          'inseam': 32.0,
        },
        preferences: ['Men\'s Wear', 'Cotton', 'Business Formal'],
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Customer(
        id: 'demo-customer-2',
        name: 'Priya Sharma',
        email: 'priya.sharma@email.com',
        phone: '+91-9876543211',
        measurements: {
          'chest': 34.0,
          'waist': 28.0,
          'hip': 36.0,
          'shoulder': 14.5,
          'neck': 13.0,
          'sleeveLength': 22.0,
        },
        preferences: ['Women\'s Wear', 'Silk', 'Traditional', 'Party Wear'],
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Customer(
        id: 'demo-customer-3',
        name: 'Amit Patel',
        email: 'amit.patel@email.com',
        phone: '+91-9876543212',
        measurements: {
          'chest': 42.0,
          'waist': 34.0,
          'shoulder': 19.0,
          'neck': 16.0,
          'sleeveLength': 26.0,
          'inseam': 34.0,
        },
        preferences: ['Men\'s Wear', 'Wool', 'Executive', 'Business Casual'],
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
    ];

    for (final customer in demoCustomers) {
      await _firebaseService.addDocument('customers', customer.toJson());
    }

    await loadAllCustomers();
  }
}

// Extension to add computed properties to Customer
extension CustomerExtensions on Customer {
  double get totalSpent {
    // This would be calculated from order history
    // For demo purposes, returning a mock value
    return 5000.0 + (id.hashCode % 10000); // Mock calculation
  }

  bool get isActive {
    // Customer is considered active if updated within last 6 months
    return updatedAt
        .isAfter(DateTime.now().subtract(const Duration(days: 180)));
  }

  String get loyaltyTier {
    final spent = totalSpent;
    if (spent >= 50000) return 'Platinum';
    if (spent >= 25000) return 'Gold';
    if (spent >= 10000) return 'Silver';
    return 'Bronze';
  }

  List<String> get topPreferences {
    // Return top 3 preferences
    return preferences.take(3).toList();
  }

  String get formattedPhone {
    final phone = this.phone;
    if (phone.length == 10) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
    }
    return phone;
  }

  String get displayName {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1].substring(0, 1).toUpperCase()}.';
    }
    return name;
  }
}



