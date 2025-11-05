import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart'; // Make sure this path is correct for your project
import 'lib/services/firebase_service.dart';

Future<void> main() async {
  try {
    debugPrint('🚀 Adding sample products and services to Firebase...');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized');

    final firebaseService = FirebaseService();

    // Sample Products
    final sampleProducts = [
      {
        'id': 'sample-product-1',
        'name': 'Classic Cotton Shirt',
        'basePrice': 1599.0,
        'category': 0, // Mens Wear
        'categoryName': 'Mens Wear',
        'description': 'Premium cotton shirt perfect for office wear',
        'stockCount': 50,
        'imageUrls': ['https://via.placeholder.com/300x400?text=Cotton+Shirt'],
        'availableSizes': ['S', 'M', 'L', 'XL'],
        'availableFabrics': ['Cotton', 'Cotton Blend'],
        'isActive': true,
        'brand': 'Royal Tailors',
      },
      {
        'id': 'sample-product-2',
        'name': 'Designer Salwar Suit',
        'basePrice': 3499.0,
        'category': 1, // Womens Wear
        'categoryName': 'Womens Wear',
        'description': 'Beautiful embroidered salwar suit with dupatta',
        'stockCount': 25,
        'imageUrls': ['https://via.placeholder.com/300x400?text=Salwar+Suit'],
        'availableSizes': ['M', 'L', 'XL', 'XXL'],
        'availableFabrics': ['Cotton', 'Silk'],
        'isActive': true,
        'brand': 'Royal Tailors',
      },
      {
        'id': 'sample-product-3',
        'name': 'Kids Party Wear',
        'basePrice': 1299.0,
        'category': 2, // Kids Wear
        'categoryName': 'Kids Wear',
        'description': 'Colorful party dress for special occasions',
        'stockCount': 30,
        'imageUrls': ['https://via.placeholder.com/300x400?text=Kids+Wear'],
        'availableSizes': ['XS', 'S', 'M', 'L'],
        'availableFabrics': ['Cotton', 'Mixed Fabric'],
        'isActive': true,
        'brand': 'Royal Tailors',
      },
      {
        'id': 'sample-product-4',
        'name': 'Executive Tuxedo',
        'basePrice': 6999.0,
        'category': 0, // Mens Wear
        'categoryName': 'Mens Wear',
        'description': 'Premium executive tuxedo for formal occasions',
        'stockCount': 10,
        'imageUrls': ['https://via.placeholder.com/300x400?text=Tuxedo'],
        'availableSizes': ['M', 'L', 'XL'],
        'availableFabrics': ['Wool', 'Polyester Blend'],
        'isActive': true,
        'brand': 'Royal Tailors',
      },
      {
        'id': 'sample-product-5',
        'name': 'Custom Wedding Gown',
        'basePrice': 15999.0,
        'category': 3, // Custom
        'categoryName': 'Custom',
        'description': 'Custom designed wedding gown with embroidery',
        'stockCount': 3,
        'imageUrls': ['https://via.placeholder.com/300x400?text=Wedding+Gown'],
        'availableSizes': ['Custom'],
        'availableFabrics': ['Bridal Silk', 'Satin', 'Organza'],
        'isActive': true,
        'brand': 'Royal Tailors',
      },
    ];

    // Sample Services
    final sampleServices = [
      {
        'id': 'service-1',
        'name': 'Tailoring Service',
        'description': 'Complete tailoring service for all types of garments',
        'basePrice': 500.0,
        'category': 'Stitching',
        'duration': '3-7 days',
        'isActive': true,
      },
      {
        'id': 'service-2',
        'name': 'Alteration Service',
        'description': 'Professional garment alteration and modification',
        'basePrice': 300.0,
        'category': 'Alteration',
        'duration': '1-3 days',
        'isActive': true,
      },
      {
        'id': 'service-3',
        'name': 'Custom Design',
        'description': 'Custom garment design service with consultation',
        'basePrice': 2000.0,
        'category': 'Design',
        'duration': '7-14 days',
        'isActive': true,
      },
      {
        'id': 'service-4',
        'name': 'Fabric Consultation',
        'description': 'Expert advice on fabric selection and care',
        'basePrice': 500.0,
        'category': 'Consultation',
        'duration': '1 hour',
        'isActive': true,
      },
      {
        'id': 'service-5',
        'name': 'Measurements & Fitting',
        'description': 'Professional body measurements and fitting services',
        'basePrice': 200.0,
        'category': 'Consultation',
        'duration': '30 minutes',
        'isActive': true,
      },
    ];

    // Add products
    debugPrint('📦 Adding sample products...');
    for (final product in sampleProducts) {
      try {
        await firebaseService.addDocument('products', product);
        debugPrint('✅ Added product: ${product['name']}');
      } catch (e) {
        debugPrint('❌ Failed to add product ${product['name']}: $e');
      }
    }

    // Add services
    debugPrint('🛠️ Adding sample services...');
    for (final service in sampleServices) {
      try {
        await firebaseService.addDocument('services', service);
        debugPrint('✅ Added service: ${service['name']}');
      } catch (e) {
        debugPrint('❌ Failed to add service ${service['name']}: $e');
      }
    }

    debugPrint('\n🎉 Sample data seeding completed!');
    debugPrint('\n📋 Added Products:');
    for (var p in sampleProducts) {
      debugPrint('- ${p['name']}: ₹${p['basePrice']}');
    }

    debugPrint('\n📋 Added Services:');
    for (var s in sampleServices) {
      debugPrint('- ${s['name']}: ₹${s['basePrice']}');
    }
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}
