# Firebase Service Documentation

## Overview
The `firebase_service.dart` file contains the comprehensive Firebase integration layer for the AI-Enabled Tailoring Shop Management System. It provides a centralized, well-structured interface for Firebase Authentication, Firestore database operations, and real-time data synchronization, serving as the foundation for all Firebase interactions throughout the application.

## Architecture

### Core Components
- **`FirebaseService`**: Singleton service providing unified Firebase access
- **Firebase Auth Integration**: User authentication and session management
- **Firestore Operations**: Complete database CRUD operations
- **Real-time Listeners**: Live data synchronization capabilities
- **Batch Operations**: Efficient bulk data operations
- **Query Builders**: Flexible data querying and filtering
- **Error Handling**: Comprehensive Firebase error management

### Key Features
- **Singleton Pattern**: Single instance ensuring consistent Firebase access
- **Type Safety**: Strong typing for all Firebase operations
- **Error Resilience**: Robust error handling with user-friendly messages
- **Performance Optimization**: Efficient batch operations and pagination
- **Real-time Capabilities**: Live data synchronization across the application
- **Security Integration**: Firebase Auth integration with secure operations

## Singleton Implementation

### Service Initialization
```dart
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
}
```

### Firebase Initialization
```dart
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
```

## Authentication Integration

### Auth Properties
```dart
// Firebase Auth getters
FirebaseAuth get auth => _auth;
User? get currentUser => _auth.currentUser;
```

### Auth Usage
```dart
class AuthManager {
  final FirebaseService _firebase = FirebaseService();

  Future<void> signIn(String email, String password) async {
    try {
      await _firebase.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print(_firebase.getErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    await _firebase.auth.signOut();
  }

  Stream<User?> get authStateChanges => _firebase.auth.authStateChanges();
}
```

## Firestore Collections

### Pre-defined Collections
```dart
// Core business collections
CollectionReference get users => _firestore.collection('users');
CollectionReference get customers => _firestore.collection('customers');
CollectionReference get orders => _firestore.collection('orders');
CollectionReference get products => _firestore.collection('products');
CollectionReference get measurements => _firestore.collection('measurements');
CollectionReference get notifications => _firestore.collection('notifications');
```

### Chat Collections
```dart
CollectionReference chatCollection(String conversationId) =>
    _firestore.collection('chat').doc(conversationId).collection('messages');
```

### Collection Usage
```dart
class DataManager {
  final FirebaseService _firebase = FirebaseService();

  Future<void> addCustomer(Map<String, dynamic> customerData) async {
    await _firebase.customers.add(customerData);
  }

  Future<void> updateOrder(String orderId, Map<String, dynamic> orderData) async {
    await _firebase.orders.doc(orderId).update(orderData);
  }

  Stream<QuerySnapshot> getCustomers() {
    return _firebase.customers.snapshots();
  }

  Future<void> sendMessage(String conversationId, Map<String, dynamic> message) async {
    await _firebase.chatCollection(conversationId).add(message);
  }
}
```

## CRUD Operations

### Generic CRUD Methods
```dart
Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
  return await _firestore.collection(collection).add(data);
}

Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
  await _firestore.collection(collection).doc(docId).update(data);
}

Future<void> deleteDocument(String collection, String docId) async {
  await _firestore.collection(collection).doc(docId).delete();
}

Future<DocumentSnapshot> getDocument(String collection, String docId) async {
  return await _firestore.collection(collection).doc(docId).get();
}

Future<QuerySnapshot> getCollection(String collection) async {
  return await _firestore.collection(collection).get();
}
```

### CRUD Usage Examples
```dart
class ProductManager {
  final FirebaseService _firebase = FirebaseService();

  Future<String> createProduct(Map<String, dynamic> productData) async {
    final docRef = await _firebase.addDocument('products', productData);
    return docRef.id;
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    await _firebase.updateDocument('products', productId, updates);
  }

  Future<void> deleteProduct(String productId) async {
    await _firebase.deleteDocument('products', productId);
  }

  Future<Map<String, dynamic>?> getProduct(String productId) async {
    final doc = await _firebase.getDocument('products', productId);
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final snapshot = await _firebase.getCollection('products');
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
```

## Real-time Data Synchronization

### Stream Methods
```dart
Stream<DocumentSnapshot> documentStream(String collection, String docId) {
  return _firestore.collection(collection).doc(docId).snapshots();
}

Stream<QuerySnapshot> collectionStream(String collection) {
  return _firestore.collection(collection).snapshots();
}
```

### Real-time Usage
```dart
class OrderMonitor extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  void startMonitoringOrders() {
    _ordersSubscription = _firebase.collectionStream('orders').listen((snapshot) {
      final orders = snapshot.docs.map((doc) => Order.fromJson(doc.data())).toList();
      // Update UI with real-time order changes
      notifyListeners();
    });
  }

  void stopMonitoring() {
    _ordersSubscription?.cancel();
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
```

## Batch Operations

### Batch Write Implementation
```dart
Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
  final batch = _firestore.batch();

  for (final operation in operations) {
    final type = operation['type'];
    final collection = operation['collection'];
    final docId = operation['docId'];
    final data = operation['data'];

    switch (type) {
      case 'set':
        batch.set(_firestore.collection(collection).doc(docId), data);
        break;
      case 'update':
        batch.update(_firestore.collection(collection).doc(docId), data);
        break;
      case 'delete':
        batch.delete(_firestore.collection(collection).doc(docId));
        break;
    }
  }

  await batch.commit();
}
```

### Batch Operations Usage
```dart
class BulkDataManager {
  final FirebaseService _firebase = FirebaseService();

  Future<void> bulkUpdateProducts(List<Map<String, dynamic>> updates) async {
    final operations = updates.map((update) => {
      'type': 'update',
      'collection': 'products',
      'docId': update['id'],
      'data': update['data'],
    }).toList();

    await _firebase.batchWrite(operations);
  }

  Future<void> createMultipleCustomers(List<Map<String, dynamic>> customers) async {
    final operations = customers.map((customer) => {
      'type': 'set',
      'collection': 'customers',
      'docId': customer['id'],
      'data': customer,
    }).toList();

    await _firebase.batchWrite(operations);
  }

  Future<void> bulkDeleteOrders(List<String> orderIds) async {
    final operations = orderIds.map((id) => {
      'type': 'delete',
      'collection': 'orders',
      'docId': id,
      'data': null,
    }).toList();

    await _firebase.batchWrite(operations);
  }
}
```

## Query Builders

### Query Helper Methods
```dart
Query whereEqual(String collection, String field, dynamic value) {
  return _firestore.collection(collection).where(field, isEqualTo: value);
}

Query whereIn(String collection, String field, List<dynamic> values) {
  return _firestore.collection(collection).where(field, whereIn: values);
}

Query orderBy(String collection, String field, {bool descending = false}) {
  return _firestore.collection(collection).orderBy(field, descending: descending);
}

Query limit(String collection, int count) {
  return _firestore.collection(collection).limit(count);
}
```

### Query Builder Usage
```dart
class OrderQueries {
  final FirebaseService _firebase = FirebaseService();

  Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) async {
    final query = _firebase.whereEqual('orders', 'status', status);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getOrdersByCustomer(String customerId) async {
    final query = _firebase.whereEqual('orders', 'customerId', customerId);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentOrders(int limit) async {
    final query = _firebase.orderBy('orders', 'createdAt', descending: true);
    final limitedQuery = query.limit(limit);
    final snapshot = await limitedQuery.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getOrdersInStatuses(List<String> statuses) async {
    final query = _firebase.whereIn('orders', 'status', statuses);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
```

## Pagination Support

### Pagination Implementation
```dart
Future<QuerySnapshot> paginate(String collection, DocumentSnapshot? lastDoc, {int limit = 20}) async {
  Query query = _firestore.collection(collection).limit(limit);
  if (lastDoc != null) {
    query = query.startAfterDocument(lastDoc);
  }
  return await query.get();
}
```

### Pagination Usage
```dart
class PaginatedDataLoader {
  final FirebaseService _firebase = FirebaseService();
  DocumentSnapshot? _lastDocument;

  Future<List<Map<String, dynamic>>> loadMoreProducts() async {
    final snapshot = await _firebase.paginate('products', _lastDocument, limit: 20);

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
    }

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  void resetPagination() {
    _lastDocument = null;
  }
}
```

## User-Specific Operations

### User-Scoped Methods
```dart
Stream<QuerySnapshot> getUserDocuments(String collection, String userId) {
  return _firestore
      .collection(collection)
      .where('userId', isEqualTo: userId)
      .snapshots();
}

Future<QuerySnapshot> getUserDocumentsOnce(String collection, String userId) {
  return _firestore
      .collection(collection)
      .where('userId', isEqualTo: userId)
      .get();
}
```

### User-Specific Usage
```dart
class UserDataManager {
  final FirebaseService _firebase = FirebaseService();

  Stream<List<Map<String, dynamic>>> getUserOrders(String userId) {
    return _firebase.getUserDocuments('orders', userId).map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Future<List<Map<String, dynamic>>> getUserMeasurementsOnce(String userId) async {
    final snapshot = await _firebase.getUserDocumentsOnce('measurements', userId);
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    final snapshot = await _firebase.getUserDocumentsOnce('notifications', userId);
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
```

## Error Handling

### Firebase Error Management
```dart
String getErrorMessage(dynamic error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'Access denied. Please check your permissions.';
      case 'not-found':
        return 'Document not found.';
      case 'already-exists':
        return 'Document already exists.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'cancelled':
        return 'Operation cancelled.';
      default:
        return 'An error occurred: ${error.message}';
    }
  }
  return 'An unexpected error occurred.';
}
```

### Error Handling Usage
```dart
class ErrorHandler {
  final FirebaseService _firebase = FirebaseService();

  Future<bool> safeOperation(Function operation) async {
    try {
      await operation();
      return true;
    } catch (e) {
      final errorMessage = _firebase.getErrorMessage(e);
      print('Firebase Error: $errorMessage');
      // Show user-friendly error message
      showErrorDialog(errorMessage);
      return false;
    }
  }

  void showErrorDialog(String message) {
    // Implementation for showing error dialog to user
  }
}
```

## Advanced Usage Examples

### Transaction Management
```dart
class TransactionManager {
  final FirebaseService _firebase = FirebaseService();

  Future<void> updateOrderWithPayment(String orderId, Map<String, dynamic> orderUpdates, Map<String, dynamic> paymentData) async {
    await _firestore.runTransaction((transaction) async {
      // Update order
      final orderRef = _firebase.orders.doc(orderId);
      transaction.update(orderRef, orderUpdates);

      // Add payment record
      final paymentRef = _firebase._firestore.collection('payments').doc();
      transaction.set(paymentRef, paymentData);
    });
  }
}
```

### Complex Queries
```dart
class AdvancedQueries {
  final FirebaseService _firebase = FirebaseService();

  Future<List<Map<String, dynamic>>> getHighValueOrders() async {
    // Orders above ₹10,000 with status 'completed' or 'delivered'
    final query = _firebase._firestore
        .collection('orders')
        .where('totalAmount', isGreaterThan: 10000)
        .where('status', whereIn: ['completed', 'delivered'])
        .orderBy('totalAmount', descending: true)
        .limit(50);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentCustomerActivity(String customerId) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final query = _firebase._firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .where('createdAt', isGreaterThan: thirtyDaysAgo)
        .orderBy('createdAt', descending: true);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
```

### Real-time Dashboard
```dart
class DashboardManager extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();

  Map<String, StreamSubscription> _subscriptions = {};

  void initializeDashboard() {
    // Monitor order count
    _subscriptions['orders'] = _firebase.collectionStream('orders').listen((snapshot) {
      _orderCount = snapshot.docs.length;
      notifyListeners();
    });

    // Monitor customer count
    _subscriptions['customers'] = _firebase.collectionStream('customers').listen((snapshot) {
      _customerCount = snapshot.docs.length;
      notifyListeners();
    });

    // Monitor revenue
    _subscriptions['revenue'] = _firebase.collectionStream('orders').listen((snapshot) {
      _totalRevenue = snapshot.docs
          .where((doc) => doc['status'] == 'completed')
          .fold<double>(0, (sum, doc) => sum + (doc['totalAmount'] ?? 0));
      notifyListeners();
    });
  }

  void dispose() {
    _subscriptions.values.forEach((subscription) => subscription.cancel());
    super.dispose();
  }
}
```

### Offline Support
```dart
class OfflineManager {
  final FirebaseService _firebase = FirebaseService();

  Future<void> enableOfflinePersistence() async {
    // Enable offline persistence
    await _firestore.settings = const Settings(persistenceEnabled: true);

    // Configure cache size (optional)
    await _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Future<void> syncPendingChanges() async {
    // Force sync pending writes
    await _firestore.waitForPendingWrites();

    // Clear local cache if needed
    await _firestore.clearPersistence();
  }
}
```

## Security Considerations

### Access Control
- **Firebase Security Rules**: Implement proper security rules for all collections
- **User Authentication**: Always verify user authentication before operations
- **Data Validation**: Validate data before writing to Firestore
- **Rate Limiting**: Implement rate limiting for sensitive operations

### Best Practices
```dart
class SecureFirebaseOperations {
  final FirebaseService _firebase = FirebaseService();

  Future<void> secureUpdateOrder(String orderId, Map<String, dynamic> updates) async {
    // Verify user authentication
    final user = _firebase.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated');
    }

    // Validate data
    if (!_isValidOrderUpdate(updates)) {
      throw Exception('Invalid order update data');
    }

    // Check user permissions
    if (!await _hasOrderPermission(orderId, user.uid)) {
      throw Exception('Insufficient permissions');
    }

    await _firebase.updateDocument('orders', orderId, updates);
  }

  bool _isValidOrderUpdate(Map<String, dynamic> updates) {
    // Implement validation logic
    return true; // Placeholder
  }

  Future<bool> _hasOrderPermission(String orderId, String userId) async {
    // Check if user owns the order or has admin privileges
    return true; // Placeholder
  }
}
```

## Performance Optimization

### Query Optimization
- **Use Appropriate Indexes**: Create Firestore indexes for frequently queried fields
- **Limit Result Sets**: Use limit() for large collections
- **Pagination**: Implement pagination for large datasets
- **Real-time vs One-time**: Choose appropriate data fetching strategy

### Caching Strategy
```dart
class CacheManager {
  final FirebaseService _firebase = FirebaseService();
  final Map<String, dynamic> _cache = {};

  Future<T> getCachedDocument<T>(String collection, String docId, T Function(Map<String, dynamic>) fromJson) async {
    final cacheKey = '$collection/$docId';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    final doc = await _firebase.getDocument(collection, docId);
    final data = fromJson(doc.data() as Map<String, dynamic>);

    _cache[cacheKey] = data;
    return data;
  }

  void invalidateCache(String collection, String docId) {
    final cacheKey = '$collection/$docId';
    _cache.remove(cacheKey);
  }
}
```

## Integration Points

### Provider Integration
```dart
class FirebaseProvider extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();

  Future<void> initialize() async {
    await _firebase.initializeFirebase();
    // Additional initialization logic
  }

  // Expose Firebase operations through provider
  Future<void> addCustomer(Map<String, dynamic> customerData) async {
    await _firebase.customers.add(customerData);
    notifyListeners();
  }

  Stream<QuerySnapshot> getCustomers() {
    return _firebase.customers.snapshots();
  }
}
```

### Service Dependencies
- **Auth Service**: Uses Firebase Auth for user management
- **All Data Services**: Use Firestore for data persistence
- **Real-time Services**: Depend on Firebase streams for live updates
- **Notification Service**: Uses Firebase for notification storage

This comprehensive Firebase service provides the robust foundation for all data operations in the tailoring shop management system, offering efficient, secure, and scalable Firebase integration with excellent developer experience and performance optimizations.