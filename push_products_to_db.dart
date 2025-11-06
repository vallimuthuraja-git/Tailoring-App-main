import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'lib/product/product_repository.dart';
import 'lib/product/product_models.dart';

/// Script to push sample products to the Firebase database
/// Run this script to populate the database with sample tailoring products
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('✅ Firebase initialized successfully');

    // Create product repository
    final productRepository = ProductRepository();

    // Add sample products
    await addSampleProducts(productRepository);

    debugPrint('🎉 All sample products added successfully!');
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}

/// Add comprehensive sample products to the database
Future<void> addSampleProducts(ProductRepository repository) async {
  debugPrint('🛍️ Adding comprehensive sample products to Firebase...');

  final sampleProducts = [
    // Men's Wear Section
    Product(
      id: 'mens_cotton_shirt_001',
      name: 'Premium Cotton Formal Shirt',
      description:
          'Luxurious 100% cotton formal shirt with perfect fit and excellent breathability. Ideal for office wear and formal occasions.',
      category: ProductCategory.mensWear,
      basePrice: 1299.0,
      originalPrice: 1599.0,
      discountPercentage: 18.7,
      brand: 'Royal Tailors',
      stockCount: 25,
      soldCount: 8,
      imageUrls: [
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': '100% Egyptian Cotton',
        'Fit': 'Slim Fit',
        'Color': 'White',
        'Care': 'Machine Wash Cold',
        'Sleeve': 'Full Sleeve'
      },
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      availableFabrics: ['Cotton', 'Cotton Blend'],
      customizationOptions: ['Monogram', 'Sleeve Length', 'Collar Style'],
      isActive: true,
      isPopular: true,
      isNewArrival: false,
      isOnSale: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.5, reviewCount: 12, recentReviews: []),
    ),

    Product(
      id: 'mens_casual_shirt_002',
      name: 'Casual Linen Shirt - Sky Blue',
      description:
          'Comfortable linen shirt perfect for casual outings and summer wear. Lightweight and breathable fabric.',
      category: ProductCategory.mensWear,
      basePrice: 899.0,
      brand: 'Comfort Wear',
      stockCount: 30,
      soldCount: 15,
      imageUrls: [
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Pure Linen',
        'Fit': 'Regular Fit',
        'Color': 'Sky Blue',
        'Care': 'Hand Wash',
        'Sleeve': 'Half Sleeve'
      },
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      availableFabrics: ['Linen', 'Linen Blend'],
      customizationOptions: ['Pocket Style', 'Button Color'],
      isActive: true,
      isPopular: true,
      isNewArrival: true,
      isOnSale: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.3, reviewCount: 8, recentReviews: []),
    ),

    Product(
      id: 'mens_jeans_003',
      name: 'Premium Denim Jeans',
      description:
          'High-quality denim jeans with perfect fit and durability. Made from premium cotton blend for comfort and style.',
      category: ProductCategory.mensWear,
      basePrice: 2499.0,
      originalPrice: 2999.0,
      discountPercentage: 16.7,
      brand: 'Denim Masters',
      stockCount: 20,
      soldCount: 12,
      imageUrls: [
        'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': '98% Cotton, 2% Elastane',
        'Fit': 'Slim Fit',
        'Color': 'Dark Blue',
        'Wash': 'Dark Wash',
        'Rise': 'Mid Rise'
      },
      availableSizes: ['28', '30', '32', '34', '36', '38'],
      availableFabrics: ['Denim', 'Cotton Blend'],
      customizationOptions: ['Length Adjustment', 'Wash Type'],
      isActive: true,
      isPopular: true,
      isNewArrival: false,
      isOnSale: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.6, reviewCount: 20, recentReviews: []),
    ),

    // Women's Wear Section
    Product(
      id: 'womens_kurti_004',
      name: 'Designer Cotton Kurti',
      description:
          'Elegant cotton kurti with intricate embroidery work. Perfect for traditional and semi-formal occasions.',
      category: ProductCategory.womensWear,
      basePrice: 1899.0,
      originalPrice: 2299.0,
      discountPercentage: 17.4,
      brand: 'Ethnic Elegance',
      stockCount: 15,
      soldCount: 6,
      imageUrls: [
        'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Pure Cotton',
        'Work': 'Machine Embroidery',
        'Color': 'Maroon',
        'Length': '46 inches',
        'Sleeve': '3/4 Sleeve'
      },
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      availableFabrics: ['Cotton', 'Cotton Silk'],
      customizationOptions: ['Length Adjustment', 'Color Choice'],
      isActive: true,
      isPopular: true,
      isNewArrival: true,
      isOnSale: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.7, reviewCount: 14, recentReviews: []),
    ),

    Product(
      id: 'womens_suit_005',
      name: 'Salwar Kameez Set - Festive Collection',
      description:
          'Beautiful salwar kameez set with dupatta. Perfect for weddings and festive occasions with rich embroidery.',
      category: ProductCategory.womensWear,
      basePrice: 4599.0,
      originalPrice: 5999.0,
      discountPercentage: 23.3,
      brand: 'Festive Wear',
      stockCount: 8,
      soldCount: 3,
      imageUrls: [
        'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Georgette with Silk',
        'Work': 'Heavy Embroidery',
        'Color': 'Gold and Red',
        'Includes': 'Kameez, Salwar, Dupatta',
        'Stitching': 'Fully Stitched'
      },
      availableSizes: ['S', 'M', 'L', 'XL'],
      availableFabrics: ['Georgette', 'Silk', 'Chiffon'],
      customizationOptions: ['Size Adjustment', 'Length Modification'],
      isActive: true,
      isPopular: false,
      isNewArrival: true,
      isOnSale: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.9, reviewCount: 9, recentReviews: []),
    ),

    Product(
      id: 'womens_dress_006',
      name: 'Evening Gown - Black Elegance',
      description:
          'Stunning black evening gown perfect for parties and special occasions. Made with premium fabric and expert tailoring.',
      category: ProductCategory.womensWear,
      basePrice: 8999.0,
      brand: 'Evening Wear',
      stockCount: 5,
      soldCount: 1,
      imageUrls: [
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Satin with Lace',
        'Style': 'A-Line',
        'Color': 'Black',
        'Length': 'Floor Length',
        'Neckline': 'V-Neck'
      },
      availableSizes: ['XS', 'S', 'M', 'L', 'XL'],
      availableFabrics: ['Satin', 'Silk', 'Chiffon'],
      customizationOptions: ['Length Adjustment', 'Neckline Style'],
      isActive: true,
      isPopular: true,
      isNewArrival: true,
      isOnSale: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.8, reviewCount: 6, recentReviews: []),
    ),

    // Kids Wear Section
    Product(
      id: 'kids_party_wear_007',
      name: 'Kids Party Suit - Navy Blue',
      description:
          'Adorable navy blue suit for kids perfect for parties and special occasions. Made with comfortable fabric.',
      category: ProductCategory.kidsWear,
      basePrice: 3499.0,
      originalPrice: 3999.0,
      discountPercentage: 12.5,
      brand: 'Kids Fashion',
      stockCount: 12,
      soldCount: 4,
      imageUrls: [
        'https://images.unsplash.com/photo-1503944168849-e43ed6e97e27?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Cotton Blend',
        'Fit': 'Regular Fit',
        'Color': 'Navy Blue',
        'Age Group': '5-12 years',
        'Includes': 'Shirt, Trousers, Vest'
      },
      availableSizes: ['5-6Y', '7-8Y', '9-10Y', '11-12Y'],
      availableFabrics: ['Cotton', 'Cotton Blend'],
      customizationOptions: ['Size Adjustment', 'Color Choice'],
      isActive: true,
      isPopular: true,
      isNewArrival: false,
      isOnSale: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.4, reviewCount: 11, recentReviews: []),
    ),

    Product(
      id: 'kids_school_uniform_008',
      name: 'School Uniform Set',
      description:
          'Complete school uniform set with shirt, trousers, and tie. Durable fabric perfect for daily school wear.',
      category: ProductCategory.kidsWear,
      basePrice: 1299.0,
      brand: 'School Wear',
      stockCount: 25,
      soldCount: 18,
      imageUrls: [
        'https://images.unsplash.com/photo-1503944168849-e43ed6e97e27?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Poly Cotton',
        'Color': 'Navy Blue with White',
        'Age Group': '6-14 years',
        'Includes': 'Shirt, Trousers, Tie',
        'Care': 'Machine Wash'
      },
      availableSizes: ['22', '24', '26', '28', '30', '32'],
      availableFabrics: ['Poly Cotton', 'Cotton Blend'],
      customizationOptions: ['School Logo', 'Size Adjustment'],
      isActive: true,
      isPopular: true,
      isNewArrival: false,
      isOnSale: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.2, reviewCount: 25, recentReviews: []),
    ),

    // Formal Wear Section
    Product(
      id: 'formal_suit_009',
      name: 'Executive Wool Suit - Charcoal Grey',
      description:
          'Premium wool suit perfect for business meetings and formal occasions. Expert tailoring with Italian wool fabric.',
      category: ProductCategory.formalWear,
      basePrice: 25999.0,
      originalPrice: 29999.0,
      discountPercentage: 13.3,
      brand: 'Executive Wear',
      stockCount: 5,
      soldCount: 2,
      imageUrls: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Super 150s Wool',
        'Fit': 'Slim Fit',
        'Color': 'Charcoal Grey',
        'Includes': 'Jacket, Trousers',
        'Lining': 'Full Lining'
      },
      availableSizes: ['38R', '40R', '42R', '44R', '46R'],
      availableFabrics: ['Wool', 'Wool Blend'],
      customizationOptions: ['Monogram', 'Button Style', 'Lapel Type'],
      isActive: true,
      isPopular: true,
      isNewArrival: true,
      isOnSale: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.8, reviewCount: 8, recentReviews: []),
    ),

    Product(
      id: 'formal_blazer_010',
      name: 'Single Breasted Blazer - Black',
      description:
          'Elegant black blazer that can be worn for both formal and semi-formal occasions. Perfect for office wear.',
      category: ProductCategory.formalWear,
      basePrice: 12999.0,
      originalPrice: 14999.0,
      discountPercentage: 13.3,
      brand: 'Formal Collection',
      stockCount: 8,
      soldCount: 3,
      imageUrls: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Wool Blend',
        'Style': 'Single Breasted',
        'Color': 'Black',
        'Buttons': '2 Buttons',
        'Vents': 'Single Vent'
      },
      availableSizes: ['38', '40', '42', '44', '46'],
      availableFabrics: ['Wool Blend', 'Poly Wool'],
      customizationOptions: ['Button Style', 'Pocket Type'],
      isActive: true,
      isPopular: true,
      isNewArrival: false,
      isOnSale: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.6, reviewCount: 12, recentReviews: []),
    ),

    // Traditional Wear Section
    Product(
      id: 'traditional_saree_011',
      name: 'Banarasi Silk Saree - Wedding Collection',
      description:
          'Exquisite Banarasi silk saree with intricate gold zari work. Perfect for weddings and traditional ceremonies.',
      category: ProductCategory.traditionalWear,
      basePrice: 18999.0,
      originalPrice: 24999.0,
      discountPercentage: 24.0,
      brand: 'Banarasi Heritage',
      stockCount: 8,
      soldCount: 3,
      imageUrls: [
        'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Pure Banarasi Silk',
        'Work': 'Gold Zari',
        'Color': 'Maroon with Gold',
        'Length': '6.3 meters',
        'Blouse': 'Separate Blouse Piece'
      },
      availableSizes: ['Free Size'],
      availableFabrics: ['Silk', 'Blended Silk'],
      customizationOptions: ['Color Choice', 'Additional Blouse Stitching'],
      isActive: true,
      isPopular: false,
      isNewArrival: true,
      isOnSale: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.9, reviewCount: 15, recentReviews: []),
    ),

    Product(
      id: 'traditional_sherwani_012',
      name: 'Embroidered Sherwani - Cream',
      description:
          'Beautiful cream sherwani with intricate embroidery work. Perfect for weddings and festive occasions.',
      category: ProductCategory.traditionalWear,
      basePrice: 35999.0,
      brand: 'Royal Attire',
      stockCount: 3,
      soldCount: 1,
      imageUrls: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Fabric': 'Silk with Brocade',
        'Work': 'Heavy Embroidery',
        'Color': 'Cream with Gold',
        'Includes': 'Sherwani, Churidar',
        'Style': 'Traditional'
      },
      availableSizes: ['38', '40', '42', '44', '46'],
      availableFabrics: ['Silk', 'Brocade'],
      customizationOptions: ['Size Adjustment', 'Embroidery Pattern'],
      isActive: true,
      isPopular: true,
      isNewArrival: true,
      isOnSale: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.9, reviewCount: 7, recentReviews: []),
    ),

    // Custom Wear Section
    Product(
      id: 'custom_dress_013',
      name: 'Bespoke Wedding Dress',
      description:
          'Custom designed wedding dress made to your specifications. Expert consultation and multiple fittings included.',
      category: ProductCategory.customDesign,
      basePrice: 49999.0,
      brand: 'Bespoke Designs',
      stockCount: 0, // Made to order
      soldCount: 5,
      imageUrls: [
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Type': 'Made to Order',
        'Consultations': '3 Design Sessions',
        'Fittings': 'Multiple Fittings',
        'Timeline': '6-8 weeks',
        'Alterations': 'Included'
      },
      availableSizes: ['Custom'],
      availableFabrics: ['Any Fabric'],
      customizationOptions: [
        'Full Customization',
        'Fabric Choice',
        'Design Style'
      ],
      isActive: true,
      isPopular: true,
      isNewArrival: false,
      isOnSale: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 5.0, reviewCount: 5, recentReviews: []),
    ),

    Product(
      id: 'uniform_corporate_014',
      name: 'Corporate Uniform Set',
      description:
          'Complete corporate uniform set for offices and organizations. Includes shirt, trousers, and blazer with company logo.',
      category: ProductCategory.customDesign,
      basePrice: 8999.0,
      brand: 'Corporate Wear',
      stockCount: 0, // Made to order
      soldCount: 12,
      imageUrls: [
        'https://images.unsplash.com/photo-1503944168849-e43ed6e97e27?w=600&h=600&fit=crop'
      ],
      specifications: {
        'Type': 'Bulk Order',
        'Minimum Order': '10 sets',
        'Includes': 'Shirt, Trousers, Blazer',
        'Logo': 'Embroidery Available',
        'Timeline': '2-3 weeks'
      },
      availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
      availableFabrics: ['Cotton', 'Poly Cotton', 'Wool Blend'],
      customizationOptions: [
        'Company Logo',
        'Color Choice',
        'Fabric Selection'
      ],
      isActive: true,
      isPopular: true,
      isNewArrival: false,
      isOnSale: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      rating:
          ProductRating(averageRating: 4.5, reviewCount: 18, recentReviews: []),
    ),
  ];

  int successCount = 0;
  int failureCount = 0;

  for (final product in sampleProducts) {
    try {
      await repository.addProduct(product);
      debugPrint('✅ Added product: ${product.name}');
      successCount++;
    } catch (e) {
      debugPrint('❌ Failed to add product ${product.name}: $e');
      failureCount++;
    }
  }

  debugPrint('🎉 Sample products addition complete!');
  debugPrint('📊 Summary: $successCount successful, $failureCount failed');
}
