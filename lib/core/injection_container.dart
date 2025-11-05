/// File: injection_container.dart
/// Purpose: Dependency injection container for managing application-wide services and repositories
/// Functionality: Initializes and provides access to Firebase services and other core dependencies in a singleton pattern
/// Dependencies: Firebase service, connectivity package
/// Usage: Used throughout the app to access shared instances of core services
/// NOTE: Product-related dependencies are temporarily commented out due to export issues
library;

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../product/product_repository.dart';
import '../product/firebase_product_repository.dart';
import '../product/product_bloc.dart';
import '../product/product_analytics_service.dart';

/// Simple dependency injection container
class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Core Services
  late final FirebaseService _firebaseService;
  late final Connectivity _connectivity;

  // Product-related dependencies
  late final ProductBloc _productBloc;
  late final IProductRepository _productRepository;
  late final ProductAnalyticsService _productAnalyticsService;

  /// Initialize all dependencies
  Future<void> initialize() async {
    debugPrint('🔧 InjectionContainer: Starting initialization...');

    try {
      // Initialize base services
      debugPrint('🔧 InjectionContainer: Initializing base services...');
      _firebaseService = FirebaseService();
      _connectivity = Connectivity();

      await _firebaseService.initializeFirebase();

      // Initialize repositories
      debugPrint('🔧 InjectionContainer: Initializing repositories...');
      _productRepository = FirebaseProductRepository(_firebaseService);

      // Initialize analytics service
      debugPrint('🔧 InjectionContainer: Initializing analytics service...');
      _productAnalyticsService = ProductAnalyticsService(_productRepository);

      // Initialize BLoC
      debugPrint('🔧 InjectionContainer: Initializing BLoC...');
      _productBloc = ProductBloc(
        productRepository: _productRepository,
        connectivity: _connectivity,
      );

      debugPrint(
          '✅ InjectionContainer: Core dependencies initialized successfully');
      debugPrint(
          '✅ InjectionContainer: ProductBloc created: ${_productBloc != null ? 'YES' : 'NO'}');
    } catch (e, stackTrace) {
      debugPrint('❌ InjectionContainer: Error during initialization: $e');
      debugPrint('❌ InjectionContainer: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Getters for accessing dependencies

  FirebaseService get firebaseService => _firebaseService;
  Connectivity get connectivity => _connectivity;

  // Product dependencies
  ProductBloc get productBloc => _productBloc;
  IProductRepository get productRepository => _productRepository;
  ProductAnalyticsService get productAnalyticsService =>
      _productAnalyticsService;

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
    debugPrint('✅ Core dependencies disposed');
  }

  /// Reset all dependencies (useful for testing)
  Future<void> reset() async {
    await dispose();
    await initialize();
  }
}

/// Global instance for easy access
final injectionContainer = InjectionContainer();
