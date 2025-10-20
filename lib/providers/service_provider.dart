import 'package:flutter/foundation.dart';
// Service Provider for Managing Tailoring Services
// Handles CRUD operations, offline sync, and service analytics

import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Service> _services = [];
  List<Service> _filteredServices = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Computed properties for search state
  bool get hasSearchQuery => _searchQuery.isNotEmpty;
  bool get hasSearchResults => hasSearchQuery && services.isNotEmpty;
  String get searchQuery => _searchQuery; // Add getter for public access
  ServiceCategory? _selectedCategoryFilter;
  ServiceType? _selectedTypeFilter;
  bool? _activeStatusFilter;

  // Analytics
  Map<ServiceCategory, int> _categoryStats = {};
  Map<ServiceType, int> _typeStats = {};
  double _totalRevenue = 0.0;
  int _totalBookings = 0;

  // Getters
  List<Service> get services => _searchQuery.isEmpty &&
          _selectedCategoryFilter == null &&
          _selectedTypeFilter == null &&
          _activeStatusFilter == null
      ? _services
      : _filteredServices;

  List<Service> get activeServices =>
      _services.where((service) => service.isActive).toList();
  List<Service> get popularServices =>
      _services.where((service) => service.isPopular).toList();
  List<Service> get sareeServices => _services
      .where((service) => service.category == ServiceCategory.sareeServices)
      .toList();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Analytics Getters
  Map<ServiceCategory, int> get categoryStats => _categoryStats;
  Map<ServiceType, int> get typeStats => _typeStats;
  double get totalRevenue => _totalRevenue;
  int get totalBookings => _totalBookings;

  double get averageServicePrice {
    if (_services.isEmpty) return 0.0;
    return _services.map((s) => s.effectivePrice).reduce((a, b) => a + b) /
        _services.length;
  }

  List<Service> getServicesByCategory(ServiceCategory category) {
    return _services.where((service) => service.category == category).toList();
  }

  List<Service> getServicesByType(ServiceType type) {
    return _services.where((service) => service.type == type).toList();
  }

  // Load services from Firestore
  Future<void> loadServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _firebaseService.getCollection('services');
      _services = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Service.fromJson(data);
      }).toList();

      debugPrint('loadServices: Found ${_services.length} existing services');

      // Initialize sample services if none exist
      if (_services.isEmpty) {
        debugPrint(
            'loadServices: No services found, initializing sample services');
        await initializeSampleServices();
      } else {
        debugPrint('loadServices: Using existing services, calculating stats');
        _calculateStats();
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('loadServices: Error - $e');
      _isLoading = false;
      _errorMessage = 'Failed to load services: $e';
      notifyListeners();
    }
  }

  // Stream services for real-time updates
  Stream<List<Service>> getServicesStream() {
    return _firebaseService.collectionStream('services').map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Service.fromJson(data);
      }).toList();
    });
  }

  // Get service by ID
  Future<Service?> getServiceById(String serviceId) async {
    try {
      final docSnapshot =
          await _firebaseService.getDocument('services', serviceId);
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id;
        return Service.fromJson(data);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to load service: $e';
      notifyListeners();
      return null;
    }
  }

  // Create new service
  Future<bool> createService(Service service,
      {bool reloadAfterCreate = true}) async {
    debugPrint(
        'createService called with service: ${service.name}, category: ${service.category}, price: ${service.basePrice}');
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('createService: converting to json');
      final serviceData = service.toJson();
      serviceData.remove('id');
      serviceData['createdAt'] = Timestamp.fromDate(DateTime.now());
      serviceData['updatedAt'] = Timestamp.fromDate(DateTime.now());

      debugPrint('createService: serviceData: $serviceData');
      await _firebaseService.addDocument('services', serviceData);

      if (reloadAfterCreate) {
        debugPrint('createService: calling loadServices');
        await loadServices();
      }
      debugPrint('createService: success');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('createService: error $e');
      _isLoading = false;
      _errorMessage = 'Failed to create service: $e';
      notifyListeners();
      return false;
    }
  }

  // Update service
  Future<bool> updateService(
      String serviceId, Map<String, dynamic> updates) async {
    debugPrint('updateService called for $serviceId with updates: $updates');
    _isLoading = true;
    notifyListeners();

    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

      debugPrint('updateService: calling firebase update');
      await _firebaseService.updateDocument('services', serviceId, updates);

      // Update local data
      debugPrint('updateService: updating local data');
      final index = _services.indexWhere((service) => service.id == serviceId);
      if (index != -1) {
        final updatedService = _services[index].copyWith(
          name: updates['name'],
          description: updates['description'],
          shortDescription: updates['shortDescription'],
          basePrice: updates['basePrice']?.toDouble(),
          isActive: updates['isActive'],
          updatedAt: DateTime.now(),
        );
        _services[index] = updatedService;
        _calculateStats();
        _applyFilters();
      }

      debugPrint('updateService: success');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('updateService: error $e');
      _isLoading = false;
      _errorMessage = 'Failed to update service: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete service
  Future<bool> deleteService(String serviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.deleteDocument('services', serviceId);

      // Remove from local data
      _services.removeWhere((service) => service.id == serviceId);
      _calculateStats();
      _applyFilters();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete service: $e';
      notifyListeners();
      return false;
    }
  }

  // Filter methods
  void searchServices(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterByCategory(ServiceCategory? category) {
    _selectedCategoryFilter = category;
    _applyFilters();
  }

  void filterByType(ServiceType? type) {
    _selectedTypeFilter = type;
    _applyFilters();
  }

  void filterByActiveStatus(bool? isActive) {
    _activeStatusFilter = isActive;
    _applyFilters();
  }

  void _applyFilters() {
    List<Service> filtered = _services;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((service) {
        return service.name.toLowerCase().contains(_searchQuery) ||
            service.description.toLowerCase().contains(_searchQuery) ||
            service.shortDescription.toLowerCase().contains(_searchQuery) ||
            service.categoryName.toLowerCase().contains(_searchQuery) ||
            service.typeName.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategoryFilter != null) {
      filtered = filtered
          .where((service) => service.category == _selectedCategoryFilter)
          .toList();
    }

    // Apply type filter
    if (_selectedTypeFilter != null) {
      filtered = filtered
          .where((service) => service.type == _selectedTypeFilter)
          .toList();
    }

    // Apply active status filter
    if (_activeStatusFilter != null) {
      filtered = filtered
          .where((service) => service.isActive == _activeStatusFilter)
          .toList();
    }

    _filteredServices = filtered;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryFilter = null;
    _selectedTypeFilter = null;
    _activeStatusFilter = null;
    _filteredServices = [];
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Force reload services (useful for debugging)
  Future<void> forceReloadServices() async {
    debugPrint('forceReloadServices: Forcing reload of services');
    await loadServices();
  }

  // Get current service count for debugging
  int get currentServiceCount => _services.length;

  // Calculate statistics
  void _calculateStats() {
    _categoryStats = {};
    _typeStats = {};
    _totalRevenue = 0.0;
    _totalBookings = 0;

    for (final service in _services) {
      // Category stats
      _categoryStats[service.category] =
          (_categoryStats[service.category] ?? 0) + 1;

      // Type stats
      _typeStats[service.type] = (_typeStats[service.type] ?? 0) + 1;

      // Revenue calculation (simplified)
      _totalRevenue += service.effectivePrice * service.totalBookings;
      _totalBookings += service.totalBookings;
    }
  }

  // Service Analytics
  Map<String, dynamic> getServiceAnalytics(String serviceId) {
    final service = _services.firstWhere((s) => s.id == serviceId);

    return {
      'service': service,
      'popularityRank': _getPopularityRank(service),
      'revenueGenerated': service.effectivePrice * service.totalBookings,
      'averageRating': service.averageRating,
      'bookingTrend': _calculateBookingTrend(service),
      'similarServices': _findSimilarServices(service),
    };
  }

  int _getPopularityRank(Service service) {
    final sortedServices = _services.where((s) => s.isActive).toList()
      ..sort((a, b) => b.popularityScore.compareTo(a.popularityScore));

    return sortedServices.indexWhere((s) => s.id == service.id) + 1;
  }

  Map<String, dynamic> _calculateBookingTrend(Service service) {
    // Simplified trend calculation
    final recentBookings = service.totalBookings;
    final averageBookings =
        _services.map((s) => s.totalBookings).reduce((a, b) => a + b) /
            _services.length;

    return {
      'currentBookings': recentBookings,
      'averageBookings': averageBookings,
      'trend': recentBookings > averageBookings ? 'up' : 'down',
      'percentage': averageBookings > 0
          ? ((recentBookings - averageBookings) / averageBookings * 100).round()
          : 0,
    };
  }

  List<Service> _findSimilarServices(Service service) {
    return _services
        .where((s) {
          return s.id != service.id &&
              (s.category == service.category || s.type == service.type) &&
              s.isActive;
        })
        .take(3)
        .toList();
  }

  // Category Analytics
  Map<String, dynamic> getCategoryAnalytics(ServiceCategory category) {
    final categoryServices =
        _services.where((s) => s.category == category).toList();

    if (categoryServices.isEmpty) {
      return {};
    }

    final totalRevenue = categoryServices
        .map((s) => s.effectivePrice * s.totalBookings)
        .reduce((a, b) => a + b);
    final totalBookings =
        categoryServices.map((s) => s.totalBookings).reduce((a, b) => a + b);
    final averageRating =
        categoryServices.map((s) => s.averageRating).reduce((a, b) => a + b) /
            categoryServices.length;

    return {
      'totalServices': categoryServices.length,
      'activeServices': categoryServices.where((s) => s.isActive).length,
      'totalRevenue': totalRevenue,
      'totalBookings': totalBookings,
      'averageRating': averageRating,
      'popularServices':
          categoryServices.where((s) => s.isPopular).take(5).toList(),
      'topRatedServices':
          categoryServices.where((s) => s.isHighlyRated).take(5).toList(),
    };
  }

  // Revenue Analytics
  Map<String, dynamic> getRevenueAnalytics() {
    final activeServices = _services.where((s) => s.isActive).toList();

    return {
      'totalServices': activeServices.length,
      'totalRevenue': _totalRevenue,
      'totalBookings': _totalBookings,
      'averageServicePrice': averageServicePrice,
      'topRevenueServices': activeServices
          .map((s) =>
              {'service': s, 'revenue': s.effectivePrice * s.totalBookings})
          .toList()
        ..sort((a, b) =>
            (b['revenue'] as double).compareTo(a['revenue'] as double))
        ..take(10),
      'categoryRevenue': ServiceCategory.values.map((category) {
        final categoryServices =
            activeServices.where((s) => s.category == category).toList();
        final revenue = categoryServices
            .map((s) => s.effectivePrice * s.totalBookings)
            .fold(0.0, (a, b) => a + b);
        return {'category': category, 'revenue': revenue};
      }).toList(),
    };
  }

  // Service Recommendations
  List<Service> getRecommendedServices(
      {String? forServiceId, ServiceCategory? category, double? budget}) {
    var recommended = _services.where((s) => s.isActive).toList();

    // Exclude current service if specified
    if (forServiceId != null) {
      recommended = recommended.where((s) => s.id != forServiceId).toList();
    }

    // Filter by category if specified
    if (category != null) {
      recommended = recommended.where((s) => s.category == category).toList();
    }

    // Filter by budget if specified
    if (budget != null) {
      recommended =
          recommended.where((s) => s.effectivePrice <= budget).toList();
    }

    // Sort by popularity and rating
    recommended.sort((a, b) {
      final aScore = (a.popularityScore * 0.7) + (a.averageRating * 20);
      final bScore = (b.popularityScore * 0.7) + (b.averageRating * 20);
      return bScore.compareTo(aScore);
    });

    return recommended.take(6).toList();
  }

  // Bulk operations
  Future<bool> bulkUpdateServices(
      List<String> serviceIds, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();

    try {
      for (final serviceId in serviceIds) {
        await updateService(serviceId, updates);
      }

      await loadServices();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to bulk update services: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> activateService(String serviceId) async {
    return await updateService(serviceId, {'isActive': true});
  }

  Future<bool> deactivateService(String serviceId) async {
    return await updateService(serviceId, {'isActive': false});
  }

  // Initialize with sample data
  Future<void> initializeSampleServices() async {
    if (_services.isEmpty) {
      debugPrint(
          'initializeSampleServices: Starting initialization of ${ServiceTemplates.allServices.length} sample services');
      int createdCount = 0;
      for (final service in ServiceTemplates.allServices) {
        await createService(service, reloadAfterCreate: false);
        createdCount++;
        debugPrint(
            'initializeSampleServices: Created service $createdCount/${ServiceTemplates.allServices.length}: ${service.name}');
      }
      debugPrint(
          'initializeSampleServices: All services created, reloading...');
      // Reload services after all have been created
      await loadServices();
    } else {
      debugPrint(
          'initializeSampleServices: Services already exist, skipping initialization');
    }
  }

  // Availability checking for service booking
  Future<List<DateTime>> getAvailableDates(String serviceId,
      {DateTime? startDate, int daysAhead = 30}) async {
    final start = startDate ?? DateTime.now();
    final end = start.add(Duration(days: daysAhead));
    final availableDates = <DateTime>[];

    // Mock availability logic - can be replaced with real API call
    for (int i = 0; i <= daysAhead; i++) {
      final date = start.add(Duration(days: i));
      // Skip weekends for demo
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        availableDates.add(date);
      }
    }

    return availableDates;
  }

  Future<List<String>> getAvailableTimeSlots(
      String serviceId, DateTime date) async {
    final slots = [
      '09:00 - 11:00', // Morning
      '11:00 - 13:00', // Morning
      '14:00 - 16:00', // Afternoon
      '16:00 - 18:00', // Afternoon
      '18:00 - 20:00', // Evening
    ];

    // Mock availability check - assume some slots are unavailable
    final unavailableSlots = {
      // Random unavailable slots for demo
      date.weekday % 3 == 0 ? ['11:00 - 13:00'] : [],
      date.weekday % 4 == 0 ? ['16:00 - 18:00'] : [],
    }.expand((e) => e).toList();

    return slots.where((slot) => !unavailableSlots.contains(slot)).toList();
  }

  Future<bool> checkSlotAvailability(
      String serviceId, DateTime date, String timeSlot) async {
    final availableSlots = await getAvailableTimeSlots(serviceId, date);
    return availableSlots.contains(timeSlot);
  }

  Future<Map<String, dynamic>> checkBusinessHours() async {
    // Mock business hours - customizable
    return {
      'weekdays': {
        'start': '09:00',
        'end': '20:00',
      },
      'weekends': {
        'start': '10:00',
        'end': '18:00',
      },
      'holidays': [] // List of holiday dates
    };
  }
}



