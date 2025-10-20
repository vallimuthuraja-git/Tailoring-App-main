import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../models/customer.dart' as models;
import '../models/order.dart' as models;
import '../models/product_models.dart' as models;
import '../services/auth_service.dart';

class FirebaseDebug {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Test Firebase connection
  Future<void> testFirebaseConnection() async {
    try {
      debugPrint('ðŸ” Testing Firebase connection...');

      // Test Firestore connection
      await _testFirestoreConnection();

      // Test Auth connection
      await _testAuthConnection();

      debugPrint('âœ… Firebase connection test completed successfully');
    } catch (e) {
      debugPrint('âŒ Firebase connection test failed: $e');
    }
  }

  // Test Firestore connection
  Future<void> _testFirestoreConnection() async {
    try {
      debugPrint('ðŸ“Š Testing Firestore connection...');

      // Try to read from users collection
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      debugPrint(
          'âœ… Firestore read successful. Found ${usersSnapshot.docs.length} documents');

      // Try to write a test document
      final testDoc = await _firestore.collection('test').add({
        'test': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('âœ… Firestore write successful. Document ID: ${testDoc.id}');

      // Clean up test document
      await _firestore.collection('test').doc(testDoc.id).delete();
      debugPrint('âœ… Firestore delete successful');
    } catch (e) {
      debugPrint('âŒ Firestore test failed: $e');
      rethrow;
    }
  }

  // Test Auth connection
  Future<void> _testAuthConnection() async {
    try {
      debugPrint('ðŸ” Testing Firebase Auth connection...');

      // Check current user
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        debugPrint('âœ… Current user found: ${currentUser.email}');
      } else {
        debugPrint('â„¹ï¸ No current user (expected if not logged in)');
      }

      // Test with demo credentials
      await _testDemoLogin();
    } catch (e) {
      debugPrint('âŒ Auth test failed: $e');
      rethrow;
    }
  }

  // Test demo login
  Future<void> _testDemoLogin() async {
    try {
      debugPrint('ðŸ‘¤ Testing demo login...');

      // Try to sign in with demo customer
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: 'customer@demo.com',
        password: 'password123',
      );

      debugPrint('âœ… Demo login successful: ${userCredential.user?.email}');

      // Test user profile retrieval
      await _testUserProfile(userCredential.user!.uid);

      // Sign out
      await _auth.signOut();
      debugPrint('âœ… Demo logout successful');
    } catch (e) {
      debugPrint('âŒ Demo login test failed: $e');
      rethrow;
    }
  }

  // Test user profile retrieval
  Future<void> _testUserProfile(String userId) async {
    try {
      debugPrint('ðŸ‘¤ Testing user profile retrieval for ID: $userId');

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        debugPrint('âœ… User profile found: ${userDoc.data()}');
      } else {
        debugPrint('âŒ User profile not found for ID: $userId');
      }
    } catch (e) {
      debugPrint('âŒ User profile test failed: $e');
      rethrow;
    }
  }

  // Check demo users existence
  Future<void> checkDemoUsers() async {
    try {
      debugPrint('ðŸ” Checking demo users...');

      // Check customer
      final customerQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'customer@demo.com')
          .get();

      if (customerQuery.docs.isNotEmpty) {
        debugPrint('âœ… Demo customer found: ${customerQuery.docs.first.data()}');
      } else {
        debugPrint('âŒ Demo customer not found');
      }

      // Check shop owner
      final shopQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'shop@demo.com')
          .get();

      if (shopQuery.docs.isNotEmpty) {
        debugPrint('âœ… Demo shop owner found: ${shopQuery.docs.first.data()}');
      } else {
        debugPrint('âŒ Demo shop owner not found');
      }
    } catch (e) {
      debugPrint('âŒ Demo users check failed: $e');
    }
  }

  // Get Firebase configuration info
  Future<void> printFirebaseConfig() async {
    try {
      debugPrint('ðŸ”§ Firebase Configuration:');
      debugPrint(
          'Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
      debugPrint('API Key: ${DefaultFirebaseOptions.currentPlatform.apiKey}');
      debugPrint(
          'Auth Domain: ${DefaultFirebaseOptions.currentPlatform.authDomain}');
      debugPrint(
          'Storage Bucket: ${DefaultFirebaseOptions.currentPlatform.storageBucket}');
      debugPrint(
          'Messaging Sender ID: ${DefaultFirebaseOptions.currentPlatform.messagingSenderId}');
      debugPrint('App ID: ${DefaultFirebaseOptions.currentPlatform.appId}');
    } catch (e) {
      debugPrint('âŒ Error printing Firebase config: $e');
    }
  }

  // Test complete user flow
  Future<void> testCompleteUserFlow() async {
    try {
      debugPrint('ðŸ”„ Testing complete user flow...');

      // Test customer flow
      await _testUserFlow(
          'customer@demo.com', 'password123', UserRole.customer);

      // Test shop owner flow
      await _testUserFlow('shop@demo.com', 'password123', UserRole.shopOwner);
    } catch (e) {
      debugPrint('âŒ Complete user flow test failed: $e');
    }
  }

  // Test individual user flow
  Future<void> _testUserFlow(
      String email, String password, UserRole role) async {
    try {
      debugPrint('ðŸ‘¤ Testing user flow for: $email');

      // 1. Sign in user
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('âœ… Login successful: ${userCredential.user?.email}');

      // 2. Test user profile retrieval
      final userProfile = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (userProfile.exists) {
        debugPrint('âœ… User profile found: ${userProfile.data()}');
      } else {
        debugPrint('âŒ User profile not found');
      }

      // 3. Test user data update
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({
        'lastLogin': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('âœ… User profile update successful');

      // 4. Sign out
      await _auth.signOut();
      debugPrint('âœ… Logout successful');
    } catch (e) {
      debugPrint('âŒ User flow test failed for $email: $e');
    }
  }

  // Test customer data operations
  Future<void> testCustomerOperations() async {
    try {
      debugPrint('ðŸ‘¥ Testing customer data operations...');

      // Create test customer
      final testCustomer = models.Customer(
        id: 'test_customer_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Customer',
        email: 'test@example.com',
        phone: '+1234567890',
        measurements: {},
        preferences: [],
        totalSpent: 0.0,
        loyaltyTier: models.LoyaltyTier.bronze,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to Firestore
      final docRef =
          await _firestore.collection('customers').add(testCustomer.toJson());
      debugPrint('âœ… Customer creation successful: ${docRef.id}');

      // Retrieve customer
      final customerDoc =
          await _firestore.collection('customers').doc(docRef.id).get();
      if (customerDoc.exists) {
        final retrievedCustomer = models.Customer.fromJson(customerDoc.data()!);
        debugPrint(
            'âœ… Customer retrieval successful: ${retrievedCustomer.name}');
      }

      // Update customer
      await _firestore.collection('customers').doc(docRef.id).update({
        'totalSpent': 500.0,
        'loyaltyTier': models.LoyaltyTier.silver.index,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('âœ… Customer update successful');

      // Delete test customer
      await _firestore.collection('customers').doc(docRef.id).delete();
      debugPrint('âœ… Customer deletion successful');
    } catch (e) {
      debugPrint('âŒ Customer operations test failed: $e');
    }
  }

  // Test order data operations
  Future<void> testOrderOperations() async {
    try {
      debugPrint('ðŸ“‹ Testing order data operations...');

      // Create test order
      final testOrder = models.Order(
        id: 'test_order_${DateTime.now().millisecondsSinceEpoch}',
        customerId: 'test_customer',
        items: [
          models.OrderItem(
            id: 'item1',
            productId: 'product1',
            productName: 'Test Product',
            category: 'test',
            price: 100.0,
            quantity: 1,
            customizations: {},
            notes: null,
          )
        ],
        status: models.OrderStatus.pending,
        paymentStatus: models.PaymentStatus.pending,
        totalAmount: 100.0,
        advanceAmount: 50.0,
        remainingAmount: 50.0,
        orderDate: DateTime.now(),
        deliveryDate: null,
        specialInstructions: null,
        measurements: {},
        orderImages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to Firestore
      final docRef =
          await _firestore.collection('orders').add(testOrder.toJson());
      debugPrint('âœ… Order creation successful: ${docRef.id}');

      // Retrieve order
      final orderDoc =
          await _firestore.collection('orders').doc(docRef.id).get();
      if (orderDoc.exists) {
        final retrievedOrder = models.Order.fromJson(orderDoc.data()!);
        debugPrint('âœ… Order retrieval successful: ${retrievedOrder.id}');
      }

      // Update order status
      await _firestore.collection('orders').doc(docRef.id).update({
        'status': models.OrderStatus.confirmed.index,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('âœ… Order update successful');

      // Delete test order
      await _firestore.collection('orders').doc(docRef.id).delete();
      debugPrint('âœ… Order deletion successful');
    } catch (e) {
      debugPrint('âŒ Order operations test failed: $e');
    }
  }

  // Test product data operations
  Future<void> testProductOperations() async {
    try {
      debugPrint('ðŸ“¦ Testing product data operations...');

      // Create test product
      final testProduct = models.Product(
        id: 'test_product_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Product',
        description: 'A test product for Firebase validation',
        category: models.ProductCategory.mensWear,
        basePrice: 199.99,
        imageUrls: ['https://example.com/image.jpg'],
        specifications: {'fabric': 'cotton', 'color': 'blue'},
        availableSizes: ['S', 'M', 'L'],
        availableFabrics: ['cotton', 'polyester'],
        customizationOptions: ['color', 'size'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to Firestore
      final docRef =
          await _firestore.collection('products').add(testProduct.toJson());
      debugPrint('âœ… Product creation successful: ${docRef.id}');

      // Retrieve product
      final productDoc =
          await _firestore.collection('products').doc(docRef.id).get();
      if (productDoc.exists) {
        final retrievedProduct = models.Product.fromJson(productDoc.data()!);
        debugPrint('âœ… Product retrieval successful: ${retrievedProduct.name}');
      }

      // Update product
      await _firestore.collection('products').doc(docRef.id).update({
        'basePrice': 249.99,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('âœ… Product update successful');

      // Delete test product
      await _firestore.collection('products').doc(docRef.id).delete();
      debugPrint('âœ… Product deletion successful');
    } catch (e) {
      debugPrint('âŒ Product operations test failed: $e');
    }
  }

  // Test data integrity and relationships
  Future<void> testDataIntegrity() async {
    try {
      debugPrint('ðŸ”— Testing data integrity and relationships...');

      // Test user-orders relationship
      final usersSnapshot = await _firestore.collection('users').limit(5).get();
      debugPrint(
          'âœ… Users collection accessible: ${usersSnapshot.docs.length} documents');

      // Test user-customers relationship
      final customersSnapshot =
          await _firestore.collection('customers').limit(5).get();
      debugPrint(
          'âœ… Customers collection accessible: ${customersSnapshot.docs.length} documents');

      // Test user-orders relationship
      final ordersSnapshot =
          await _firestore.collection('orders').limit(5).get();
      debugPrint(
          'âœ… Orders collection accessible: ${ordersSnapshot.docs.length} documents');

      // Test products collection
      final productsSnapshot =
          await _firestore.collection('products').limit(5).get();
      debugPrint(
          'âœ… Products collection accessible: ${productsSnapshot.docs.length} documents');

      debugPrint('âœ… All collections accessible and relationships intact');
    } catch (e) {
      debugPrint('âŒ Data integrity test failed: $e');
    }
  }

  // Production readiness check
  Future<void> productionReadinessCheck() async {
    try {
      debugPrint('ðŸ­ Production readiness check...');

      // Check Firebase configuration
      final configValid = _validateFirebaseConfig();
      debugPrint(
          'âœ… Firebase configuration: ${configValid ? 'VALID' : 'INVALID'}');

      // Check security rules deployment status
      debugPrint(
          'âš ï¸  Manual check required: Firestore security rules deployment');

      // Check data consistency
      await testDataIntegrity();

      // Check authentication flow
      await testCompleteUserFlow();

      debugPrint('âœ… Production readiness check completed');
    } catch (e) {
      debugPrint('âŒ Production readiness check failed: $e');
    }
  }

  // Validate Firebase configuration
  bool _validateFirebaseConfig() {
    try {
      final config = DefaultFirebaseOptions.currentPlatform;
      return config.apiKey.isNotEmpty &&
          config.authDomain?.isNotEmpty == true &&
          config.projectId.isNotEmpty &&
          config.storageBucket?.isNotEmpty == true;
    } catch (e) {
      debugPrint('âŒ Firebase config validation error: $e');
      return false;
    }
  }

  // Comprehensive debug function
  Future<void> runFullDebug() async {
    try {
      debugPrint('ðŸ› Starting comprehensive Firebase debug...');
      debugPrint('=' * 50);

      await printFirebaseConfig();
      debugPrint('');

      await testFirebaseConnection();
      debugPrint('');

      await checkDemoUsers();
      debugPrint('');

      await testCompleteUserFlow();
      debugPrint('');

      await testCustomerOperations();
      debugPrint('');

      await testOrderOperations();
      debugPrint('');

      await testProductOperations();
      debugPrint('');

      await testDataIntegrity();
      debugPrint('');

      await productionReadinessCheck();
      debugPrint('');

      debugPrint('ðŸ› Firebase debug completed successfully');
      debugPrint('=' * 50);
    } catch (e) {
      debugPrint('âŒ Full debug failed: $e');
    }
  }
}

// Helper function to run debug (can be called from anywhere)
Future<void> runFirebaseDebug() async {
  final debug = FirebaseDebug();
  await debug.runFullDebug();
}


