const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('../../config/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${serviceAccount.project_id}-default-rtdb.firebaseio.com`
});

const firestore = admin.firestore();

// Combined sample data from both Dart files
const sampleProducts = [
  // From add_sample_data.dart (5 products)
  {
    'id': 'sample-product-1',
    'name': 'Classic Cotton Shirt',
    'basePrice': 1599.0,
    'category': 0,
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
    'category': 1,
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
    'category': 2,
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
    'category': 0,
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
    'category': 3,
    'categoryName': 'Custom',
    'description': 'Custom designed wedding gown with embroidery',
    'stockCount': 3,
    'imageUrls': ['https://via.placeholder.com/300x400?text=Wedding+Gown'],
    'availableSizes': ['Custom'],
    'availableFabrics': ['Bridal Silk', 'Satin', 'Organza'],
    'isActive': true,
    'brand': 'Royal Tailors',
  },

  // From sample_product_adder.dart (14 detailed products)
  {
    'id': 'mens_cotton_shirt_001',
    'name': 'Premium Cotton Formal Shirt',
    'description': 'Luxurious 100% cotton formal shirt with perfect fit and excellent breathability. Ideal for office wear and formal occasions.',
    'shortDescription': 'Premium cotton formal shirt',
    'category': 0,
    'basePrice': 1299.0,
    'originalPrice': 1599.0,
    'discountPercentage': 18.7,
    'brand': 'Royal Tailors',
    'stockCount': 25,
    'soldCount': 8,
    'imageUrls': ['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': '100% Egyptian Cotton',
      'Fit': 'Slim Fit',
      'Color': 'White',
      'Care': 'Machine Wash Cold',
      'Sleeve': 'Full Sleeve'
    },
    'availableSizes': ['S', 'M', 'L', 'XL', 'XXL'],
    'availableFabrics': ['Cotton', 'Cotton Blend'],
    'customizationOptions': ['Monogram', 'Sleeve Length', 'Collar Style'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': false,
    'isOnSale': true,
    'createdAt': admin.firestore.Timestamp.now(),
    'updatedAt': admin.firestore.Timestamp.now(),
    'rating': {'averageRating': 4.5, 'reviewCount': 12, 'recentReviews': []}
  },
  {
    'id': 'mens_casual_shirt_002',
    'name': 'Casual Linen Shirt - Sky Blue',
    'description': 'Comfortable linen shirt perfect for casual outings and summer wear. Lightweight and breathable fabric.',
    'shortDescription': 'Casual linen shirt for summer',
    'category': 0,
    'basePrice': 899.0,
    'originalPrice': null,
    'discountPercentage': 0.0,
    'brand': 'Comfort Wear',
    'stockCount': 30,
    'soldCount': 15,
    'imageUrls': ['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': 'Pure Linen',
      'Fit': 'Regular Fit',
      'Color': 'Sky Blue',
      'Care': 'Hand Wash',
      'Sleeve': 'Half Sleeve'
    },
    'availableSizes': ['S', 'M', 'L', 'XL', 'XXL'],
    'availableFabrics': ['Linen', 'Linen Blend'],
    'customizationOptions': ['Pocket Style', 'Button Color'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': true,
    'isOnSale': false,
    'createdAt': admin.firestore.Timestamp.now(),
    'updatedAt': admin.firestore.Timestamp.now(),
    'rating': {'averageRating': 4.3, 'reviewCount': 8, 'recentReviews': []}
  },
  {
    'id': 'mens_jeans_003',
    'name': 'Premium Denim Jeans',
    'description': 'High-quality denim jeans with perfect fit and durability. Made from premium cotton blend for comfort and style.',
    'shortDescription': 'Premium denim jeans',
    'category': 0,
    'basePrice': 2499.0,
    'originalPrice': 2999.0,
    'discountPercentage': 16.7,
    'brand': 'Denim Masters',
    'stockCount': 20,
    'soldCount': 12,
    'imageUrls': ['https://images.unsplash.com/photo-1542272604-787c3835535d?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': '98% Cotton, 2% Elastane',
      'Fit': 'Slim Fit',
      'Color': 'Dark Blue',
      'Wash': 'Dark Wash',
      'Rise': 'Mid Rise'
    },
    'availableSizes': ['28', '30', '32', '34', '36', '38'],
    'availableFabrics': ['Denim', 'Cotton Blend'],
    'customizationOptions': ['Length Adjustment', 'Wash Type'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': false,
    'isOnSale': true,
    'createdAt': admin.firestore.Timestamp.now(),
    'updatedAt': admin.firestore.Timestamp.now(),
    'rating': {'averageRating': 4.6, 'reviewCount': 20, 'recentReviews': []}
  },
  {
    'id': 'womens_kurti_004',
    'name': 'Designer Cotton Kurti',
    'description': 'Elegant cotton kurti with intricate embroidery work. Perfect for traditional and semi-formal occasions.',
    'shortDescription': 'Designer cotton kurti with embroidery',
    'category': 1,
    'basePrice': 1899.0,
    'originalPrice': 2299.0,
    'discountPercentage': 17.4,
    'brand': 'Ethnic Elegance',
    'stockCount': 15,
    'soldCount': 6,
    'imageUrls': ['https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': 'Pure Cotton',
      'Work': 'Machine Embroidery',
      'Color': 'Maroon',
      'Length': '46 inches',
      'Sleeve': '3/4 Sleeve'
    },
    'availableSizes': ['S', 'M', 'L', 'XL', 'XXL'],
    'availableFabrics': ['Cotton', 'Cotton Silk'],
    'customizationOptions': ['Length Adjustment', 'Color Choice'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': true,
    'isOnSale': true,
    'createdAt': new Date().toISOString(),
    'updatedAt': new Date().toISOString(),
    'rating': {'averageRating': 4.7, 'reviewCount': 14, 'recentReviews': []}
  },
  {
    'id': 'womens_suit_005',
    'name': 'Salwar Kameez Set - Festive Collection',
    'description': 'Beautiful salwar kameez set with dupatta. Perfect for weddings and festive occasions with rich embroidery.',
    'shortDescription': 'Festive salwar kameez set',
    'category': 1,
    'basePrice': 4599.0,
    'originalPrice': 5999.0,
    'discountPercentage': 23.3,
    'brand': 'Festive Wear',
    'stockCount': 8,
    'soldCount': 3,
    'imageUrls': ['https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': 'Georgette with Silk',
      'Work': 'Heavy Embroidery',
      'Color': 'Gold and Red',
      'Includes': 'Kameez, Salwar, Dupatta',
      'Stitching': 'Fully Stitched'
    },
    'availableSizes': ['S', 'M', 'L', 'XL'],
    'availableFabrics': ['Georgette', 'Silk', 'Chiffon'],
    'customizationOptions': ['Size Adjustment', 'Length Modification'],
    'badges': {},
    'isActive': true,
    'isPopular': false,
    'isNewArrival': true,
    'isOnSale': true,
    'createdAt': new Date().toISOString(),
    'updatedAt': new Date().toISOString(),
    'rating': {'averageRating': 4.9, 'reviewCount': 9, 'recentReviews': []}
  },
  {
    'id': 'womens_dress_006',
    'name': 'Evening Gown - Black Elegance',
    'description': 'Stunning black evening gown perfect for parties and special occasions. Made with premium fabric and expert tailoring.',
    'shortDescription': 'Black evening gown',
    'category': 1,
    'basePrice': 8999.0,
    'originalPrice': null,
    'discountPercentage': 0.0,
    'brand': 'Evening Wear',
    'stockCount': 5,
    'soldCount': 1,
    'imageUrls': ['https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': 'Satin with Lace',
      'Style': 'A-Line',
      'Color': 'Black',
      'Length': 'Floor Length',
      'Neckline': 'V-Neck'
    },
    'availableSizes': ['XS', 'S', 'M', 'L', 'XL'],
    'availableFabrics': ['Satin', 'Silk', 'Chiffon'],
    'customizationOptions': ['Length Adjustment', 'Neckline Style'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': true,
    'isOnSale': false,
    'createdAt': new Date().toISOString(),
    'updatedAt': new Date().toISOString(),
    'rating': {'averageRating': 4.8, 'reviewCount': 6, 'recentReviews': []}
  },
  {
    'id': 'kids_party_wear_007',
    'name': 'Kids Party Suit - Navy Blue',
    'description': 'Adorable navy blue suit for kids perfect for parties and special occasions. Made with comfortable fabric.',
    'shortDescription': 'Kids party suit',
    'category': 2,
    'basePrice': 3499.0,
    'originalPrice': 3999.0,
    'discountPercentage': 12.5,
    'brand': 'Kids Fashion',
    'stockCount': 12,
    'soldCount': 4,
    'imageUrls': ['https://images.unsplash.com/photo-1503944168849-e43ed6e97e27?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': 'Cotton Blend',
      'Fit': 'Regular Fit',
      'Color': 'Navy Blue',
      'Age Group': '5-12 years',
      'Includes': 'Shirt, Trousers, Vest'
    },
    'availableSizes': ['5-6Y', '7-8Y', '9-10Y', '11-12Y'],
    'availableFabrics': ['Cotton', 'Cotton Blend'],
    'customizationOptions': ['Size Adjustment', 'Color Choice'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': false,
    'isOnSale': true,
    'createdAt': new Date().toISOString(),
    'updatedAt': new Date().toISOString(),
    'rating': {'averageRating': 4.4, 'reviewCount': 11, 'recentReviews': []}
  },
  {
    'id': 'kids_school_uniform_008',
    'name': 'School Uniform Set',
    'description': 'Complete school uniform set with shirt, trousers, and tie. Durable fabric perfect for daily school wear.',
    'shortDescription': 'School uniform set',
    'category': 2,
    'basePrice': 1299.0,
    'originalPrice': null,
    'discountPercentage': 0.0,
    'brand': 'School Wear',
    'stockCount': 25,
    'soldCount': 18,
    'imageUrls': ['https://images.unsplash.com/photo-1503944168849-e43ed6e97e27?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': 'Poly Cotton',
      'Color': 'Navy Blue with White',
      'Age Group': '6-14 years',
      'Includes': 'Shirt, Trousers, Tie',
      'Care': 'Machine Wash'
    },
    'availableSizes': ['22', '24', '26', '28', '30', '32'],
    'availableFabrics': ['Poly Cotton', 'Cotton Blend'],
    'customizationOptions': ['School Logo', 'Size Adjustment'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': false,
    'isOnSale': false,
    'createdAt': new Date().toISOString(),
    'updatedAt': new Date().toISOString(),
    'rating': {'averageRating': 4.2, 'reviewCount': 25, 'recentReviews': []}
  },
  {
    'id': 'formal_suit_009',
    'name': 'Executive Wool Suit - Charcoal Grey',
    'description': 'Premium wool suit perfect for business meetings and formal occasions. Expert tailoring with Italian wool fabric.',
    'shortDescription': 'Executive wool suit',
    'category': 3,
    'basePrice': 25999.0,
    'originalPrice': 29999.0,
    'discountPercentage': 13.3,
    'brand': 'Executive Wear',
    'stockCount': 5,
    'soldCount': 2,
    'imageUrls': ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': 'Super 150s Wool',
      'Fit': 'Slim Fit',
      'Color': 'Charcoal Grey',
      'Includes': 'Jacket, Trousers',
      'Lining': 'Full Lining'
    },
    'availableSizes': ['38R', '40R', '42R', '44R', '46R'],
    'availableFabrics': ['Wool', 'Wool Blend'],
    'customizationOptions': ['Monogram', 'Button Style', 'Lapel Type'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': true,
    'isOnSale': false,
    'createdAt': new Date().toISOString(),
    'updatedAt': new Date().toISOString(),
    'rating': {'averageRating': 4.8, 'reviewCount': 8, 'recentReviews': []}
  },
  {
    'id': 'formal_blazer_010',
    'name': 'Single Breasted Blazer - Black',
    'description': 'Elegant black blazer that can be worn for both formal and semi-formal occasions. Perfect for office wear.',
    'shortDescription': 'Single breasted blazer',
    'category': 3,
    'basePrice': 12999.0,
    'originalPrice': 14999.0,
    'discountPercentage': 13.3,
    'brand': 'Formal Collection',
    'stockCount': 8,
    'soldCount': 3,
    'imageUrls': ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': 'Wool Blend',
      'Style': 'Single Breasted',
      'Color': 'Black',
      'Buttons': '2 Buttons',
      'Vents': 'Single Vent'
    },
    'availableSizes': ['38', '40', '42', '44', '46'],
    'availableFabrics': ['Wool Blend', 'Poly Wool'],
    'customizationOptions': ['Button Style', 'Pocket Type'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': false,
    'isOnSale': true,
    'createdAt': new Date().toISOString(),
    'updatedAt': new Date().toISOString(),
    'rating': {'averageRating': 4.6, 'reviewCount': 12, 'recentReviews': []}
  },
  {
    'id': 'traditional_saree_011',
    'name': 'Banarasi Silk Saree - Wedding Collection',
    'description': 'Exquisite Banarasi silk saree with intricate gold zari work. Perfect for weddings and traditional ceremonies.',
    'shortDescription': 'Banarasi silk saree',
    'category': 5,
    'basePrice': 18999.0,
    'originalPrice': 24999.0,
    'discountPercentage': 24.0,
    'brand': 'Banarasi Heritage',
    'stockCount': 8,
    'soldCount': 3,
    'imageUrls': ['https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': 'Pure Banarasi Silk',
      'Work': 'Gold Zari',
      'Color': 'Maroon with Gold',
      'Length': '6.3 meters',
      'Blouse': 'Separate Blouse Piece'
    },
    'availableSizes': ['Free Size'],
    'availableFabrics': ['Silk', 'Blended Silk'],
    'customizationOptions': ['Color Choice', 'Additional Blouse Stitching'],
    'badges': {},
    'isActive': true,
    'isPopular': false,
    'isNewArrival': true,
    'isOnSale': true,
    'createdAt': new Date().toISOString(),
    'updatedAt': new Date().toISOString(),
    'rating': {'averageRating': 4.9, 'reviewCount': 15, 'recentReviews': []}
  },
  {
    'id': 'traditional_sherwani_012',
    'name': 'Embroidered Sherwani - Cream',
    'description': 'Beautiful cream sherwani with intricate embroidery work. Perfect for weddings and festive occasions.',
    'shortDescription': 'Embroidered sherwani',
    'category': 5,
    'basePrice': 35999.0,
    'originalPrice': null,
    'discountPercentage': 0.0,
    'brand': 'Royal Attire',
    'stockCount': 3,
    'soldCount': 1,
    'imageUrls': ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=600&fit=crop'],
    'specifications': {
      'Fabric': 'Silk with Brocade',
      'Work': 'Heavy Embroidery',
      'Color': 'Cream with Gold',
      'Includes': 'Sherwani, Churidar',
      'Style': 'Traditional'
    },
    'availableSizes': ['38', '40', '42', '44', '46'],
    'availableFabrics': ['Silk', 'Brocade'],
    'customizationOptions': ['Size Adjustment', 'Embroidery Pattern'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': true,
    'isOnSale': false,
    'createdAt': new Date().toISOString(),
    'updatedAt': new Date().toISOString(),
    'rating': {'averageRating': 4.9, 'reviewCount': 7, 'recentReviews': []}
  },
  {
    'id': 'custom_dress_013',
    'name': 'Bespoke Wedding Dress',
    'description': 'Custom designed wedding dress made to your specifications. Expert consultation and multiple fittings included.',
    'shortDescription': 'Bespoke wedding dress',
    'category': 4,
    'basePrice': 49999.0,
    'originalPrice': null,
    'discountPercentage': 0.0,
    'brand': 'Bespoke Designs',
    'stockCount': 0,
    'soldCount': 5,
    'imageUrls': ['https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600&h=600&fit=crop'],
    'specifications': {
      'Type': 'Made to Order',
      'Consultations': '3 Design Sessions',
      'Fittings': 'Multiple Fittings',
      'Timeline': '6-8 weeks',
      'Alterations': 'Included'
    },
    'availableSizes': ['Custom'],
    'availableFabrics': ['Any Fabric'],
    'customizationOptions': ['Full Customization', 'Fabric Choice', 'Design Style'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': false,
    'isOnSale': false,
    'createdAt': new Date().toISOString(),
    'updatedAt': new Date().toISOString(),
    'rating': {'averageRating': 5.0, 'reviewCount': 5, 'recentReviews': []}
  },
  {
    'id': 'uniform_corporate_014',
    'name': 'Corporate Uniform Set',
    'description': 'Complete corporate uniform set for offices and organizations. Includes shirt, trousers, and blazer with company logo.',
    'shortDescription': 'Corporate uniform set',
    'category': 4,
    'basePrice': 8999.0,
    'originalPrice': null,
    'discountPercentage': 0.0,
    'brand': 'Corporate Wear',
    'stockCount': 0,
    'soldCount': 12,
    'imageUrls': ['https://images.unsplash.com/photo-1503944168849-e43ed6e97e27?w=600&h=600&fit=crop'],
    'specifications': {
      'Type': 'Bulk Order',
      'Minimum Order': '10 sets',
      'Includes': 'Shirt, Trousers, Blazer',
      'Logo': 'Embroidery Available',
      'Timeline': '2-3 weeks'
    },
    'availableSizes': ['S', 'M', 'L', 'XL', 'XXL'],
    'availableFabrics': ['Cotton', 'Poly Cotton', 'Wool Blend'],
    'customizationOptions': ['Company Logo', 'Color Choice', 'Fabric Selection'],
    'badges': {},
    'isActive': true,
    'isPopular': true,
    'isNewArrival': false,
    'isOnSale': false,
    'createdAt': new Date().toISOString(),
    'updatedAt': new Date().toISOString(),
    'rating': {'averageRating': 4.5, 'reviewCount': 18, 'recentReviews': []}
  }
];

const sampleServices = [
  {
    'id': 'service-1',
    'name': 'Tailoring Service',
    'description': 'Complete tailoring service for all types of garments',
    'basePrice': 500.0,
    'category': 1, // garmentServices
    'type': 6, // dressmaking
    'duration': 1, // standard
    'complexity': 1, // moderate
    'features': ['Custom stitching', 'Professional finish', 'Quality materials'],
    'isActive': true,
    'createdAt': admin.firestore.Timestamp.now(),
    'updatedAt': admin.firestore.Timestamp.now(),
  },
  {
    'id': 'service-2',
    'name': 'Alteration Service',
    'description': 'Professional garment alteration and modification',
    'basePrice': 300.0,
    'category': 2, // alterationServices
    'type': 22, // hemming
    'duration': 0, // quick
    'complexity': 0, // simple
    'features': ['Precise measurements', 'Quick turnaround', 'Professional finish'],
    'isActive': true,
    'createdAt': admin.firestore.Timestamp.now(),
    'updatedAt': admin.firestore.Timestamp.now(),
  },
  {
    'id': 'service-3',
    'name': 'Custom Design',
    'description': 'Custom garment design service with consultation',
    'basePrice': 2000.0,
    'category': 3, // customDesign
    'type': 16, // bespokeDesign
    'duration': 2, // extended
    'complexity': 2, // complex
    'features': ['Custom design consultation', 'Pattern making', 'Professional stitching'],
    'isActive': true,
    'createdAt': admin.firestore.Timestamp.now(),
    'updatedAt': admin.firestore.Timestamp.now(),
  },
  {
    'id': 'service-4',
    'name': 'Fabric Consultation',
    'description': 'Expert advice on fabric selection and care',
    'basePrice': 500.0,
    'category': 4, // consultation
    'type': 26, // styleConsultation
    'duration': 0, // quick
    'complexity': 0, // simple
    'features': ['Fabric selection advice', 'Care instructions', 'Quality assessment'],
    'isActive': true,
    'createdAt': admin.firestore.Timestamp.now(),
    'updatedAt': admin.firestore.Timestamp.now(),
  },
  {
    'id': 'service-5',
    'name': 'Measurements & Fitting',
    'description': 'Professional body measurements and fitting services',
    'basePrice': 200.0,
    'category': 5, // measurements
    'type': 27, // bodyMeasurement
    'duration': 0, // quick
    'complexity': 0, // simple
    'features': ['Precise measurements', 'Body type assessment', 'Fitting recommendations'],
    'isActive': true,
    'createdAt': admin.firestore.Timestamp.now(),
    'updatedAt': admin.firestore.Timestamp.now(),
  },
];

async function createCombinedSampleData() {
  console.log('🚀 Starting combined sample data setup...');

  try {
    // Add products
    console.log('📦 Adding sample products...');
    for (const product of sampleProducts) {
      try {
        await firestore.collection('products').doc(product.id).set(product);
        console.log(`✅ Added product: ${product.name}`);
      } catch (e) {
        console.log(`❌ Failed to add product ${product.name}: ${e.message}`);
      }
    }

    // Add services
    console.log('🛠️ Adding sample services...');
    for (const service of sampleServices) {
      try {
        await firestore.collection('services').doc(service.id).set(service);
        console.log(`✅ Added service: ${service.name}`);
      } catch (e) {
        console.log(`❌ Failed to add service ${service.name}: ${e.message}`);
      }
    }

    console.log('\n🎉 Combined sample data setup completed!');
    console.log(`📦 Added ${sampleProducts.length} products`);
    console.log(`🛠️ Added ${sampleServices.length} services`);

  } catch (error) {
    console.error('❌ Error in combined data setup:', error.message);
    throw error;
  }
}

// Main execution
async function main() {
  try {
    await createCombinedSampleData();
  } catch (e) {
    console.error('❌ Setup failed:', e.message);
    process.exit(1);
  } finally {
    admin.app().delete();
  }
}

module.exports = { createCombinedSampleData };

if (require.main === module) {
  main();
}
