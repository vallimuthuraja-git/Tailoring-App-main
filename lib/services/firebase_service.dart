import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connection status
  bool _isConnected = false;
  String? _connectionError;

  // Getters for connection status
  bool get isConnected => _isConnected;
  String? get connectionError => _connectionError;

  // Firebase Auth getters
  FirebaseAuth get auth => _auth;
  User? get currentUser => _auth.currentUser;

  // Firestore collections
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get customers => _firestore.collection('customers');
  CollectionReference get orders => _firestore.collection('orders');
  CollectionReference get products => _firestore.collection('products');
  CollectionReference get measurements => _firestore.collection('measurements');
  CollectionReference get notifications => _firestore.collection('notifications');

  // Chat collections
  CollectionReference chatCollection(String conversationId) =>
      _firestore.collection('chat').doc(conversationId).collection('messages');

  // Initialize Firebase with connection testing
  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Test connection after initialization
      await _testConnection();
    } catch (e) {
      _isConnected = false;
      _connectionError = 'Firebase initialization failed: $e';
      debugdebugPrint('âŒ Firebase initialization failed: $e');
      rethrow;
    }
  }

  // Test Firebase connection
  Future<void> _testConnection() async {
    try {
      debugdebugPrint('ðŸ” Testing Firebase connection...');
      // Test basic firestore connectivity
      await _firestore.collection('test').limit(1).get();
      _isConnected = true;
      _connectionError = null;
      debugdebugPrint('âœ… Firebase connection successful');
    } catch (e) {
      _isConnected = false;
      _connectionError = 'Firebase connection failed: $e';
      debugdebugPrint('âŒ Firebase connection failed: $e');
    }
  }

  // Get connection status
  Future<Map<String, dynamic>> getConnectionStatus() async {
    await _testConnection();
    return {
      'connected': _isConnected,
      'error': _connectionError,
      'authUser': _auth.currentUser?.email ?? 'No user',
      'firebaseInitialized': Firebase.apps.isNotEmpty,
    };
  }

  // Generic CRUD operations with enhanced error handling
  Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data, {int maxRetries = 2}) async {
    debugdebugPrint('ðŸ’¾ Adding document to collection: $collection');
    debugdebugPrint('ðŸ“„ Data keys: ${data.keys.toList()}');

    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        if (!_isConnected) {
          await _testConnection();
        }

        final docRef = await _firestore.collection(collection).add(data).timeout(
          const Duration(seconds: 10),
        );

        // Verify the document was created
        final docSnapshot = await docRef.get();
        if (!docSnapshot.exists) {
          throw Exception('Document not created successfully');
        }

        debugdebugPrint('âœ… Document added successfully to $collection with ID: ${docRef.id}');
        return docRef;

      } catch (e) {
        retryCount++;
        debugdebugPrint('âŒ Failed attempt $retryCount to add document to $collection: $e');

        if (retryCount == maxRetries) {
          debugdebugPrint('ðŸš« Giving up after $maxRetries attempts');
          rethrow;
        }

        await Future.delayed(Duration(seconds: retryCount));
      }
    }
    throw Exception('Failed to add document after $maxRetries attempts');
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

 Future<QuerySnapshot> getCollection(String collection, {int maxRetries = 3}) async {
   debugdebugPrint('ðŸ” Fetching collection: $collection');
   debugdebugPrint('ðŸ‘¤ Auth state: ${FirebaseAuth.instance.currentUser?.email ?? 'No authenticated user'}');

   int retryCount = 0;
   while (retryCount < maxRetries) {
     try {
       final result = await _firestore.collection(collection).get().timeout(
         const Duration(seconds: 15),
       );
       debugdebugPrint('âœ… Successfully fetched ${result.docs.length} documents from $collection');
       return result;
     } catch (e) {
       retryCount++;
       debugdebugPrint('âŒ Failed attempt $retryCount to fetch $collection: $e');

       if (retryCount == maxRetries) {
         debugdebugPrint('ðŸš« Giving up after $maxRetries attempts for collection: $collection');
         rethrow;
       }

       // Wait before retrying
       await Future.delayed(Duration(seconds: retryCount));
     }
   }
   throw Exception('Failed to fetch collection after $maxRetries attempts');
 }

  // Real-time listeners
  Stream<DocumentSnapshot> documentStream(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  Stream<QuerySnapshot> collectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Note: File storage operations require firebase_storage package
  // Future<String> uploadFile(String path, String fileName, dynamic file) async {
  //   final ref = _storage.ref().child('$path/$fileName');
  //   final uploadTask = ref.putFile(file);
  //   final snapshot = await uploadTask.whenComplete(() => null);
  //   return await snapshot.ref.getDownloadURL();
  // }

  // Future<void> deleteFile(String url) async {
  //   await _storage.refFromURL(url).delete();
  // }

  // Batch operations
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

  // Query helpers
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

  // Pagination
  Future<QuerySnapshot> paginate(String collection, DocumentSnapshot? lastDoc, {int limit = 20}) async {
    Query query = _firestore.collection(collection).limit(limit);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }
    return await query.get();
  }

  // User-specific queries
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

  // Error handling
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
}

