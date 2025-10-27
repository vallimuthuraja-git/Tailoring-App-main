import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await testFirestoreConnectivity();
}

Future<void> testFirestoreConnectivity() async {
  print('🔍 Testing Flutter/Firebase Firestore connectivity...');

  try {
    // Test basic connection
    final firestore = FirebaseFirestore.instance;
    print('✅ Firebase instance initialized');

    // Query products collection directly
    print('📦 Fetching products collection...');
    final productsQuery = await firestore.collection('products').get();

    print('📊 Query result: ${productsQuery.docs.length} documents found');

    if (productsQuery.docs.isNotEmpty) {
      print('📋 First 3 products:');
      productsQuery.docs.take(3).forEach((doc) {
        final data = doc.data();
        print('  🆔 ${doc.id}');
        print('  📦 Name: ${data['name'] ?? 'No name'}');
        print('  💰 Price: ₹${data['basePrice']?.toString() ?? 'No price'}');
        print(
            '  📝 Description: ${data['description']?.toString().substring(0, 50) ?? 'No description'}...');
        print('');
      });
    } else {
      print('❌ No products found in the collection!');
    }

    // Test users collection too
    final usersQuery = await firestore.collection('users').get();
    print('👥 Users collection: ${usersQuery.docs.length} documents');
  } catch (e, stackTrace) {
    print('❌ Firestore connectivity test failed:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
}
