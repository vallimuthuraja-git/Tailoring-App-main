/// File: injection_container.dart
/// Purpose: Dependency injection container for managing application-wide services and repositories
/// Functionality: Initializes and provides access to Firebase services, repositories, BLoCs, and other dependencies in a singleton pattern
/// Dependencies: Firebase service, connectivity package, product data access components, ProductBloc
/// Usage: Used throughout the app to access shared instances of services and repositories instead of creating new instances
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../product_data_access.dart' as data_access;
import '../blocs/product/product_bloc.dart';
import '../services/product/product_analytics_service.dart';
import '../services/firebase_service.dart';

/// Simple dependency injection container
class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Services
  late final FirebaseService _firebaseService;
  late final Connectivity _connectivity;

  // Repositories
  late final data_access.FirebaseProductRepository _firebaseProductRepository;
  late final data_access.OfflineProductRepository _offlineProductRepository;
  late final data_access.ProductRepository _productRepository;

  // Services
  late final data_access.ProductSearchService _productSearchService;
  late final data_access.ProductCacheService _productCacheService;
  late final ProductAnalyticsService _productAnalyticsService;

  // BLoC
  late final ProductBloc _productBloc;

  /// Initialize all dependencies
  Future<void> initialize() async {
    // Initialize base services
    _firebaseService = FirebaseService();
    _connectivity = Connectivity();

    await _firebaseService.initializeFirebase();

    // Initialize repositories
    _firebaseProductRepository =
        data_access.FirebaseProductRepository(_firebaseService);
    _offlineProductRepository = data_access.OfflineProductRepository();

    _productRepository = data_access.ProductRepository(
      _firebaseProductRepository,
      _offlineProductRepository,
      _connectivity,
    );

    // Initialize services
    _productSearchService =
        data_access.ProductSearchService(productRepository: _productRepository);
    _productCacheService = data_access.ProductCacheService();
    _productAnalyticsService = ProductAnalyticsService(_productRepository);

    // Initialize services that need async setup
    // await Future.wait([
    //   _productCacheService.initialize(),
    //   _productAnalyticsService.initialize(),
    // ]);

    // Initialize BLoC
    _productBloc = ProductBloc(
      productRepository: _productRepository,
      connectivity: _connectivity,
    );

    debugPrint('âœ… All dependencies initialized');
  }

  // Getters for accessing dependencies

  FirebaseService get firebaseService => _firebaseService;
  Connectivity get connectivity => _connectivity;

  // Repositories
  data_access.FirebaseProductRepository get firebaseProductRepository =>
      _firebaseProductRepository;
  data_access.OfflineProductRepository get offlineProductRepository =>
      _offlineProductRepository;
  data_access.ProductRepository get productRepository => _productRepository;

  // Services
  data_access.ProductSearchService get productSearchService =>
      _productSearchService;
  data_access.ProductCacheService get productCacheService =>
      _productCacheService;
  ProductAnalyticsService get productAnalyticsService =>
      _productAnalyticsService;

  // BLoC
  ProductBloc get productBloc => _productBloc;

  /// Create a new ProductBloc instance (useful for scoped BLoCs)
  ProductBloc createProductBloc() {
    return ProductBloc(
      productRepository: _productRepository,
      connectivity: _connectivity,
    );
  }

  /// Dispose of all resources
  Future<void> dispose() async {
    await _productBloc.close();
    debugPrint('âœ… Dependencies disposed');
  }

  /// Reset all dependencies (useful for testing)
  Future<void> reset() async {
    await dispose();
    await initialize();
  }
}

/// Global instance for easy access
final injectionContainer = InjectionContainer();
