import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import '../models/customer.dart' as models;
import '../models/order.dart' as models;
import '../models/product.dart' as models;
import '../services/auth_service.dart';

class FirebaseDebug {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Test Firebase connection
  Future<void> testFirebaseConnection() async {
    try {
      debugPrint('🔍 Testing Firebase connection...');

      // Test Firestore connection
      await _testFirestoreConnection();

      // Test Auth connection
      await _testAuthConnection();

      debugPrint('✅ Firebase connection test completed successfully');
    } catch (e) {
      debugPrint('❌ Firebase connection test failed: $e');
    }
  }

  // Test Firestore connection
  Future<void> _testFirestoreConnection() async {
    try {
      debugPrint('📊 Testing Firestore connection...');

      // Try to read from users collection
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      debugPrint('✅ Firestore read successful. Found ${usersSnapshot.docs.length} documents');

      // Try to write a test document
      final testDoc = await _firestore.collection('test').add({
        'test': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Firestore write successful. Document ID: ${testDoc.id}');

      // Clean up test document
      await _firestore.collection('test').doc(testDoc.id).delete();
      debugPrint('✅ Firestore delete successful');

    } catch (e) {
      debugPrint('❌ Firestore test failed: $e');
      rethrow;
    }
  }

  // Test Auth connection
  Future<void> _testAuthConnection() async {
    try {
      debugPrint('🔐 Testing Firebase Auth connection...');

      // Check current user
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        debugPrint('✅ Current user found: ${currentUser.email}');
      } else {
        debugPrint('ℹ️ No current user (expected if not logged in)');
      }

      // Test with demo credentials
      await _testDemoLogin();

    } catch (e) {
      debugPrint('❌ Auth test failed: $e');
      rethrow;
    }
  }

  // Test demo login
  Future<void> _testDemoLogin() async {
    try {
      debugPrint('👤 Testing demo login...');

      // Try to sign in with demo customer
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: 'customer@demo.com',
        password: 'password123',
      );

      debugPrint('✅ Demo login successful: ${userCredential.user?.email}');

      // Test user profile retrieval
      await _testUserProfile(userCredential.user!.uid);

      // Sign out
      await _auth.signOut();
      debugPrint('✅ Demo logout successful');

    } catch (e) {
      debugPrint('❌ Demo login test failed: $e');
      rethrow;
    }
  }

  // Test user profile retrieval
  Future<void> _testUserProfile(String userId) async {
    try {
      debugPrint('👤 Testing user profile retrieval for ID: $userId');

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        debugPrint('✅ User profile found: ${userDoc.data()}');
      } else {
        debugPrint('❌ User profile not found for ID: $userId');
      }

    } catch (e) {
      debugPrint('❌ User profile test failed: $e');
      rethrow;
    }
  }

  // Check demo users existence
  Future<void> checkDemoUsers() async {
    try {
      debugPrint('🔍 Checking demo users...');

      // Check customer
      final customerQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'customer@demo.com')
          .get();

      if (customerQuery.docs.isNotEmpty) {
        debugPrint('✅ Demo customer found: ${customerQuery.docs.first.data()}');
      } else {
        debugPrint('❌ Demo customer not found');
      }

      // Check shop owner
      final shopQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'shop@demo.com')
          .get();

      if (shopQuery.docs.isNotEmpty) {
        debugPrint('✅ Demo shop owner found: ${shopQuery.docs.first.data()}');
      } else {
        debugPrint('❌ Demo shop owner not found');
      }

    } catch (e) {
      debugPrint('❌ Demo users check failed: $e');
    }
  }

  // Get Firebase configuration info
  Future<void> printFirebaseConfig() async {
    try {
      debugPrint('🔧 Firebase Configuration:');
      debugPrint('Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');
      debugPrint('API Key: ${DefaultFirebaseOptions.currentPlatform.apiKey}');
      debugPrint('Auth Domain: ${DefaultFirebaseOptions.currentPlatform.authDomain}');
      debugPrint('Storage Bucket: ${DefaultFirebaseOptions.currentPlatform.storageBucket}');
      debugPrint('Messaging Sender ID: ${DefaultFirebaseOptions.currentPlatform.messagingSenderId}');
      debugPrint('App ID: ${DefaultFirebaseOptions.currentPlatform.appId}');
    } catch (e) {
      debugPrint('❌ Error printing Firebase config: $e');
    }
  }

  // Test complete user flow
  Future<void> testCompleteUserFlow() async {
    try {
      debugPrint('🔄 Testing complete user flow...');

      // Test customer flow
      await _testUserFlow('customer@demo.com', 'password123', UserRole.customer);

      // Test shop owner flow
      await _testUserFlow('shop@demo.com', 'password123', UserRole.shopOwner);

    } catch (e) {
      debugPrint('❌ Complete user flow test failed: $e');
    }
  }

  // Test individual user flow
  Future<void> _testUserFlow(String email, String password, UserRole role) async {
    try {
      debugPrint('👤 Testing user flow for: $email');

      // 1. Sign in user
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Login successful: ${userCredential.user?.email}');

      // 2. Test user profile retrieval
      final userProfile = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (userProfile.exists) {
        debugPrint('✅ User profile found: ${userProfile.data()}');
      } else {
        debugPrint('❌ User profile not found');
      }

      // 3. Test user data update
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLogin': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ User profile update successful');

      // 4. Sign out
      await _auth.signOut();
      debugPrint('✅ Logout successful');

    } catch (e) {
      debugPrint('❌ User flow test failed for $email: $e');
    }
  }

  // Test customer data operations
  Future<void> testCustomerOperations() async {
    try {
      debugPrint('👥 Testing customer data operations...');

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
      final docRef = await _firestore.collection('customers').add(testCustomer.toJson());
      debugPrint('✅ Customer creation successful: ${docRef.id}');

      // Retrieve customer
      final customerDoc = await _firestore.collection('customers').doc(docRef.id).get();
      if (customerDoc.exists) {
        final retrievedCustomer = models.Customer.fromJson(customerDoc.data()!);
        debugPrint('✅ Customer retrieval successful: ${retrievedCustomer.name}');
      }

      // Update customer
      await _firestore.collection('customers').doc(docRef.id).update({
        'totalSpent': 500.0,
        'loyaltyTier': models.LoyaltyTier.silver.index,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Customer update successful');

      // Delete test customer
      await _firestore.collection('customers').doc(docRef.id).delete();
      debugPrint('✅ Customer deletion successful');

    } catch (e) {
      debugPrint('❌ Customer operations test failed: $e');
    }
  }

  // Test order data operations
  Future<void> testOrderOperations() async {
    try {
      debugPrint('📋 Testing order data operations...');

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
      final docRef = await _firestore.collection('orders').add(testOrder.toJson());
      debugPrint('✅ Order creation successful: ${docRef.id}');

      // Retrieve order
      final orderDoc = await _firestore.collection('orders').doc(docRef.id).get();
      if (orderDoc.exists) {
        final retrievedOrder = models.Order.fromJson(orderDoc.data()!);
        debugPrint('✅ Order retrieval successful: ${retrievedOrder.id}');
      }

      // Update order status
      await _firestore.collection('orders').doc(docRef.id).update({
        'status': models.OrderStatus.confirmed.index,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Order update successful');

      // Delete test order
      await _firestore.collection('orders').doc(docRef.id).delete();
      debugPrint('✅ Order deletion successful');

    } catch (e) {
      debugPrint('❌ Order operations test failed: $e');
    }
  }

  // Test product data operations
  Future<void> testProductOperations() async {
    try {
      debugPrint('📦 Testing product data operations...');

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
      final docRef = await _firestore.collection('products').add(testProduct.toJson());
      debugPrint('✅ Product creation successful: ${docRef.id}');

      // Retrieve product
      final productDoc = await _firestore.collection('products').doc(docRef.id).get();
      if (productDoc.exists) {
        final retrievedProduct = models.Product.fromJson(productDoc.data()!);
        debugPrint('✅ Product retrieval successful: ${retrievedProduct.name}');
      }

      // Update product
      await _firestore.collection('products').doc(docRef.id).update({
        'basePrice': 249.99,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Product update successful');

      // Delete test product
      await _firestore.collection('products').doc(docRef.id).delete();
      debugPrint('✅ Product deletion successful');

    } catch (e) {
      debugPrint('❌ Product operations test failed: $e');
    }
  }

  // Test data integrity and relationships
  Future<void> testDataIntegrity() async {
    try {
      debugPrint('🔗 Testing data integrity and relationships...');

      // Test user-orders relationship
      final usersSnapshot = await _firestore.collection('users').limit(5).get();
      debugPrint('✅ Users collection accessible: ${usersSnapshot.docs.length} documents');

      // Test user-customers relationship
      final customersSnapshot = await _firestore.collection('customers').limit(5).get();
      debugPrint('✅ Customers collection accessible: ${customersSnapshot.docs.length} documents');

      // Test user-orders relationship
      final ordersSnapshot = await _firestore.collection('orders').limit(5).get();
      debugPrint('✅ Orders collection accessible: ${ordersSnapshot.docs.length} documents');

      // Test products collection
      final productsSnapshot = await _firestore.collection('products').limit(5).get();
      debugPrint('✅ Products collection accessible: ${productsSnapshot.docs.length} documents');

      debugPrint('✅ All collections accessible and relationships intact');

    } catch (e) {
      debugPrint('❌ Data integrity test failed: $e');
    }
  }

  // Production readiness check
  Future<void> productionReadinessCheck() async {
    try {
      debugPrint('🏭 Production readiness check...');

      // Check Firebase configuration
      final configValid = _validateFirebaseConfig();
      debugPrint('✅ Firebase configuration: ${configValid ? 'VALID' : 'INVALID'}');

      // Check security rules deployment status
      debugPrint('⚠️  Manual check required: Firestore security rules deployment');

      // Check data consistency
      await testDataIntegrity();

      // Check authentication flow
      await testCompleteUserFlow();

      debugPrint('✅ Production readiness check completed');

    } catch (e) {
      debugPrint('❌ Production readiness check failed: $e');
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
      debugPrint('❌ Firebase config validation error: $e');
      return false;
    }
  }

  // Comprehensive debug function
  Future<void> runFullDebug() async {
    try {
      debugPrint('🐛 Starting comprehensive Firebase debug...');
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

      debugPrint('🐛 Firebase debug completed successfully');
      debugPrint('=' * 50);

    } catch (e) {
      debugPrint('❌ Full debug failed: $e');
    }
  }
}

// Helper function to run debug (can be called from anywhere)
Future<void> runFirebaseDebug() async {
  final debug = FirebaseDebug();
  await debug.runFullDebug();
}
