# Firebase Service

## Overview
The `firebase_service.dart` file implements a comprehensive Firebase integration layer for the AI-Enabled Tailoring Shop Management System. It provides a centralized, singleton service that manages all Firebase operations including authentication, Firestore database operations, real-time data streams, and error handling.

## Key Features

### Centralized Firebase Management
- **Singleton Pattern**: Single instance across the entire application
- **Unified Interface**: Consistent API for all Firebase operations
- **Error Handling**: Comprehensive error management with user-friendly messages
- **Real-time Updates**: Live data synchronization across the application

### Complete Data Operations
- **CRUD Operations**: Create, read, update, delete for all data types
- **Batch Processing**: Efficient bulk operations for performance
- **Real-time Streams**: Live data updates with automatic UI synchronization
- **Query Optimization**: Advanced querying with filtering and sorting

### Business Data Collections
- **User Management**: Authentication and user profile data
- **Customer Data**: Customer profiles, measurements, and preferences
- **Order Processing**: Complete order lifecycle management
- **Product Catalog**: Product inventory and service offerings

## Architecture Components

### Service Structure

#### FirebaseService Singleton
```dart
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
}
```

#### Core Service Components
```dart
// Authentication
FirebaseAuth get auth => _auth;
User? get currentUser => _auth.currentUser;

// Firestore Collections
CollectionReference get users => _firestore.collection('users');
CollectionReference get customers => _firestore.collection('customers');
CollectionReference get orders => _firestore.collection('orders');
CollectionReference get products => _firestore.collection('products');
CollectionReference get measurements => _firestore.collection('measurements');
CollectionReference get notifications => _firestore.collection('notifications');
```

## Core Functionality

### Firebase Initialization
```dart
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
```

### CRUD Operations

#### Document Management
```dart
// Create new document
Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
  return await _firestore.collection(collection).add(data);
}

// Read single document
Future<DocumentSnapshot> getDocument(String collection, String docId) async {
  return await _firestore.collection(collection).doc(docId).get();
}

// Update document
Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
  await _firestore.collection(collection).doc(docId).update(data);
}

// Delete document
Future<void> deleteDocument(String collection, String docId) async {
  await _firestore.collection(collection).doc(docId).delete();
}
```

#### Collection Operations
```dart
// Read entire collection
Future<QuerySnapshot> getCollection(String collection) async {
  return await _firestore.collection(collection).get();
}
```

### Real-time Data Streams

#### Document Streams
```dart
Stream<DocumentSnapshot> documentStream(String collection, String docId) {
  return _firestore.collection(collection).doc(docId).snapshots();
}
```

#### Collection Streams
```dart
Stream<QuerySnapshot> collectionStream(String collection) {
  return _firestore.collection(collection).snapshots();
}
```

#### User-Specific Streams
```dart
Stream<QuerySnapshot> getUserDocuments(String collection, String userId) {
  return _firestore
      .collection(collection)
      .where('userId', isEqualTo: userId)
      .snapshots();
}
```

### Batch Operations

#### Batch Write Operations
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

### Advanced Querying

#### Query Helpers
```dart
// Equality queries
Query whereEqual(String collection, String field, dynamic value) {
  return _firestore.collection(collection).where(field, isEqualTo: value);
}

// Array membership queries
Query whereIn(String collection, String field, List<dynamic> values) {
  return _firestore.collection(collection).where(field, whereIn: values);
}

// Ordering queries
Query orderBy(String collection, String field, {bool descending = false}) {
  return _firestore.collection(collection).orderBy(field, descending: descending);
}

// Limit queries
Query limit(String collection, int count) {
  return _firestore.collection(collection).limit(count);
}
```

#### Pagination Support
```dart
Future<QuerySnapshot> paginate(String collection, DocumentSnapshot? lastDoc, {int limit = 20}) async {
  Query query = _firestore.collection(collection).limit(limit);
  if (lastDoc != null) {
    query = query.startAfterDocument(lastDoc);
  }
  return await query.get();
}
```

### Error Handling

#### Comprehensive Error Messages
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

## Data Collections

### Core Business Collections
```dart
// User management
CollectionReference get users => _firestore.collection('users');

// Customer relationship management
CollectionReference get customers => _firestore.collection('customers');

// Order processing and tracking
CollectionReference get orders => _firestore.collection('orders');

// Product and service catalog
CollectionReference get products => _firestore.collection('products');

// Measurement data
CollectionReference get measurements => _firestore.collection('measurements');

// Notification system
CollectionReference get notifications => _firestore.collection('notifications');
```

### Chat System
```dart
CollectionReference chatCollection(String conversationId) =>
    _firestore.collection('chat').doc(conversationId).collection('messages');
```

## Usage Examples

### Basic CRUD Operations
```dart
final firebaseService = FirebaseService();

// Create a new customer
final customerData = {
  'name': 'Rajesh Kumar',
  'email': 'rajesh@example.com',
  'phone': '+91-9876543210',
  'createdAt': DateTime.now().toIso8601String(),
};

final docRef = await firebaseService.addDocument('customers', customerData);
print('Created customer with ID: ${docRef.id}');

// Read customer data
final doc = await firebaseService.getDocument('customers', docRef.id);
final customer = doc.data() as Map<String, dynamic>;

// Update customer
await firebaseService.updateDocument('customers', docRef.id, {
  'totalSpent': 5000.0,
  'updatedAt': DateTime.now().toIso8601String(),
});

// Delete customer
await firebaseService.deleteDocument('customers', docRef.id);
```

### Real-time Data Listening
```dart
// Listen to real-time customer updates
final customerStream = firebaseService.documentStream('customers', customerId);
customerStream.listen((doc) {
  if (doc.exists) {
    final data = doc.data() as Map<String, dynamic>;
    print('Customer updated: ${data['name']}');
  }
});

// Listen to collection changes
final customersStream = firebaseService.collectionStream('customers');
customersStream.listen((snapshot) {
  print('Total customers: ${snapshot.docs.length}');
  for (final doc in snapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;
    print('Customer: ${data['name']}');
  }
});
```

### Batch Operations
```dart
final operations = [
  {
    'type': 'set',
    'collection': 'customers',
    'docId': 'customer-1',
    'data': {'name': 'John Doe', 'email': 'john@example.com'},
  },
  {
    'type': 'update',
    'collection': 'customers',
    'docId': 'customer-2',
    'data': {'totalSpent': 10000.0},
  },
  {
    'type': 'delete',
    'collection': 'customers',
    'docId': 'customer-3',
    'data': {},
  },
];

await firebaseService.batchWrite(operations);
```

### Advanced Querying
```dart
// Get active customers
final activeCustomersQuery = firebaseService.whereEqual('customers', 'isActive', true);
final activeCustomers = await activeCustomersQuery.get();

// Get orders by status
final pendingOrdersQuery = firebaseService.whereEqual('orders', 'status', 0); // 0 = pending
final pendingOrders = await pendingOrdersQuery.get();

// Get products sorted by price
final productsByPriceQuery = firebaseService.orderBy('products', 'basePrice', descending: true);
final expensiveProducts = await productsByPriceQuery.limit(10).get();

// Pagination
DocumentSnapshot? lastDoc;
final firstPage = await firebaseService.paginate('products', null, limit: 20);
lastDoc = firstPage.docs.last;
final nextPage = await firebaseService.paginate('products', lastDoc, limit: 20);
```

### User-Specific Queries
```dart
// Get current user's orders
final userId = firebaseService.currentUser?.uid;
if (userId != null) {
  final userOrders = await firebaseService.getUserDocumentsOnce('orders', userId);
  print('User has ${userOrders.docs.length} orders');
}

// Listen to user's real-time order updates
final userOrdersStream = firebaseService.getUserDocuments('orders', userId);
userOrdersStream.listen((snapshot) {
  print('User orders updated: ${snapshot.docs.length} total orders');
});
```

### Error Handling
```dart
try {
  await firebaseService.addDocument('customers', customerData);
} catch (e) {
  final errorMessage = firebaseService.getErrorMessage(e);
  print('Error: $errorMessage');
  // Show error message to user
}
```

## Integration Points

### With All Providers
- **Customer Provider**: Customer CRUD operations and real-time updates
  - Related: [`lib/providers/customer_provider.dart`](../../providers/customer_provider.md)
- **Product Provider**: Product catalog management
  - Related: [`lib/providers/product_provider.dart`](../../providers/product_provider.md)
- **Order Provider**: Order processing and tracking
  - Related: [`lib/providers/order_provider.dart`](../../providers/order_provider.md)

### With Data Models
- **Customer Model**: Firebase serialization and deserialization
  - Related: [`lib/models/customer.dart`](../../models/customer.dart.md)
- **Product Model**: Product data persistence
  - Related: [`lib/models/product.dart`](../../models/product.dart.md)
- **Order Model**: Order lifecycle management
  - Related: [`lib/models/order.dart`](../../models/order.dart.md)

### With Authentication
- **Firebase Auth**: User authentication and session management
- **User Context**: Current user information for data isolation
- **Security**: Firebase security rules integration

## Performance Optimizations

### Query Optimization
- **Indexed Fields**: Proper Firebase index configuration
- **Compound Queries**: Efficient multi-field query design
- **Pagination**: Large dataset handling with cursor-based pagination
- **Stream Management**: Efficient real-time listener management

### Batch Operations
- **Atomic Transactions**: Consistent multi-document updates
- **Performance**: Reduced network requests for bulk operations
- **Error Handling**: Partial failure management in batch operations
- **Rollback**: Automatic rollback on batch operation failure

### Memory Management
- **Stream Disposal**: Proper cleanup of real-time listeners
- **Connection Pooling**: Efficient Firebase connection management
- **Caching Strategy**: Local data caching for improved performance
- **Resource Cleanup**: Automatic resource disposal

## Security Considerations

### Data Access Control
- **Firebase Security Rules**: Collection-level access control
- **User Authentication**: Authenticated access for sensitive operations
- **Data Isolation**: User-specific data access patterns
- **Audit Trail**: Operation logging for security monitoring

### Error Handling
- **Graceful Degradation**: Fallback behavior for service failures
- **User-Friendly Messages**: Clear error communication
- **Retry Logic**: Automatic retry for transient failures
- **Logging**: Comprehensive error logging for debugging

## Future Enhancements

### Advanced Features
- **Offline Support**: Local data caching and sync
- **Multi-region Replication**: Global data distribution
- **Advanced Security**: Row-level security and encryption
- **Analytics Integration**: Firebase Analytics integration

### Performance Improvements
- **Connection Pooling**: Optimized Firebase connections
- **Query Optimization**: Advanced query performance tuning
- **Caching Layer**: Intelligent data caching strategies
- **CDN Integration**: Content delivery network for media files

### Scalability Features
- **Auto-scaling**: Automatic resource scaling
- **Load Balancing**: Distributed load handling
- **Data Sharding**: Large dataset management
- **Backup & Recovery**: Automated data backup systems

---

*This Firebase Service serves as the critical data persistence and real-time synchronization backbone for the tailoring shop management system, providing a robust, scalable, and secure foundation that enables all business operations, user interactions, and real-time features throughout the application.*