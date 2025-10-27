import 'dart:convert';

import 'product_models.dart';
import '../services/firebase_service.dart';

/// Temporary utility to add sample products to Firebase
class SampleProductAdder {
  final FirebaseService _firebaseService;

  SampleProductAdder(this._firebaseService);

  /// Add sample tailoring products to the database
  Future<void> addSampleProducts() async {
    print('🛍️ Adding sample products to Firebase...');

    final products = [
      {
        'id': 'sample_shirt_001',
        'name': 'Classic White Cotton Shirt',
        'description':
            'Premium quality cotton shirt perfect for formal and casual wear. Made with breathable fabric and excellent stitching.',
        'category': 0, // mensWear
        'basePrice': 1299.0,
        'originalPrice': 1599.0,
        'discountPercentage': 18.7,
        'brand': 'FashionTailors',
        'stockCount': 25,
        'soldCount': 8,
        'imageUrls': [
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&h=600&fit=crop'
        ],
        'specifications': {
          'Fabric': '100% Cotton',
          'Fit': 'Regular Fit',
          'Color': 'White',
          'Care': 'Machine Wash'
        },
        'availableSizes': ['S', 'M', 'L', 'XL', 'XXL'],
        'availableFabrics': ['Cotton', 'Cotton Blend'],
        'customizationOptions': ['Monogram', 'Sleeve Length'],
        'badges': {},
        'isActive': true,
        'isPopular': true,
        'isNewArrival': false,
        'isOnSale': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'rating': {'averageRating': 4.5, 'reviewCount': 12, 'recentReviews': []}
      },
      {
        'id': 'sample_suit_002',
        'name': 'Premium Wool Suit - Navy Blue',
        'description':
            'Elegant navy blue wool suit perfect for weddings and formal occasions. Hand-crafted with attention to detail.',
        'category': 3, // formalWear
        'basePrice': 25999.0,
        'originalPrice': 29999.0,
        'discountPercentage': 13.3,
        'brand': 'ElegantWear',
        'stockCount': 5,
        'soldCount': 2,
        'imageUrls': [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=600&fit=crop'
        ],
        'specifications': {
          'Fabric': 'Super 150s Wool',
          'Fit': 'Slim Fit',
          'Color': 'Navy Blue',
          'Includes': 'Jacket, Trousers, Vest'
        },
        'availableSizes': ['38R', '40R', '42R', '44R', '46R'],
        'availableFabrics': ['Wool', 'Wool Blend'],
        'customizationOptions': [
          'Size Adjustment',
          'Color Variation',
          'Monogram'
        ],
        'badges': {},
        'isActive': true,
        'isPopular': true,
        'isNewArrival': true,
        'isOnSale': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'rating': {'averageRating': 4.8, 'reviewCount': 8, 'recentReviews': []}
      },
      {
        'id': 'sample_saree_003',
        'name': 'Designer Silk Saree - Wedding Collection',
        'description':
            'Beautiful silk saree with intricate gold embroidery, perfect for weddings and festive occasions.',
        'category': 5, // traditionalWear
        'basePrice': 18999.0,
        'originalPrice': 24999.0,
        'discountPercentage': 24.0,
        'brand': 'TraditionalArts',
        'stockCount': 8,
        'soldCount': 3,
        'imageUrls': [
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&h=600&fit=crop'
        ],
        'specifications': {
          'Fabric': 'Pure Silk',
          'Work': 'Gold Embroidery',
          'Color': 'Maroon with Gold',
          'Length': '6.3 meters'
        },
        'availableSizes': ['Free Size'],
        'availableFabrics': ['Silk', 'Blended Silk'],
        'customizationOptions': ['Color Choice', 'Additional Blouse'],
        'badges': {},
        'isActive': true,
        'isPopular': false,
        'isNewArrival': true,
        'isOnSale': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'rating': {'averageRating': 4.9, 'reviewCount': 15, 'recentReviews': []}
      }
    ];

    for (final productData in products) {
      try {
        final docId = productData['id'] as String;
        await _firebaseService.updateDocument('products', docId, productData);
        print('✅ Added product: ${productData['name']}');
      } catch (e) {
        print('❌ Failed to add product ${productData['name']}: $e');
      }
    }

    print('🎉 Sample products addition complete!');
  }
}
