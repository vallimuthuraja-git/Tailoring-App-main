import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_models.dart';
import '../../services/firebase_service.dart';
import 'i_product_repository.dart';

/// Firebase implementation of product repository
class FirebaseProductRepository implements IProductRepository {
  final FirebaseService _firebaseService;

  FirebaseProductRepository(this._firebaseService);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final querySnapshot = await _firebaseService.getCollection('products');
      final products = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();

      return products;
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final docSnapshot = await _firebaseService.getDocument('products', id);
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id;
        final product = Product.fromJson(data);
        return product;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    try {
      final productData = product.toJson();
      productData.remove('id'); // Remove ID for new products
      productData['createdAt'] = FieldValue.serverTimestamp();
      productData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef =
          await _firebaseService.addDocument('products', productData);
      final newProduct = Product(
        id: docRef.id,
        name: product.name,
        description: product.description,
        category: product.category,
        basePrice: product.basePrice,
        originalPrice: product.originalPrice,
        discountPercentage: product.discountPercentage,
        rating: product.rating,
        stockCount: product.stockCount,
        soldCount: product.soldCount,
        imageUrls: product.imageUrls,
        specifications: product.specifications,
        availableSizes: product.availableSizes,
        availableFabrics: product.availableFabrics,
        customizationOptions: product.customizationOptions,
        badges: product.badges,
        isActive: product.isActive,
        isPopular: product.isPopular,
        isNewArrival: product.isNewArrival,
        isOnSale: product.isOnSale,
        brand: product.brand,
        createdAt: product.createdAt,
        updatedAt: DateTime.now(),
      );

      return newProduct;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final productData = product.toJson();
      productData.remove('id'); // Remove ID from data
      productData['updatedAt'] = FieldValue.serverTimestamp();

      await _firebaseService.updateDocument(
          'products', product.id, productData);
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        description: product.description,
        category: product.category,
        basePrice: product.basePrice,
        originalPrice: product.originalPrice,
        discountPercentage: product.discountPercentage,
        rating: product.rating,
        stockCount: product.stockCount,
        soldCount: product.soldCount,
        imageUrls: product.imageUrls,
        specifications: product.specifications,
        availableSizes: product.availableSizes,
        availableFabrics: product.availableFabrics,
        customizationOptions: product.customizationOptions,
        badges: product.badges,
        isActive: product.isActive,
        isPopular: product.isPopular,
        isNewArrival: product.isNewArrival,
        isOnSale: product.isOnSale,
        brand: product.brand,
        createdAt: product.createdAt,
        updatedAt: DateTime.now(),
      );

      return updatedProduct;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _firebaseService.deleteDocument('products', id);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      // Firebase doesn't support full-text search natively
      // For now, we'll fetch all products and filter locally
      final allProducts = await getProducts();
      final filteredProducts = allProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()) ||
            product.brand.toLowerCase().contains(query.toLowerCase());
      }).toList();

      return filteredProducts;
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    try {
      final allProducts = await getProducts();
      final filteredProducts =
          allProducts.where((product) => product.category == category).toList();

      return filteredProducts;
    } catch (e) {
      throw Exception('Failed to load products by category: $e');
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final allProducts = await getProducts();
      final featuredProducts = allProducts
          .where((product) =>
              product.isPopular || product.isNewArrival || product.isOnSale)
          .toList();

      return featuredProducts;
    } catch (e) {
      throw Exception('Failed to load featured products: $e');
    }
  }

  @override
  Stream<List<Product>> getProductsStream() {
    return _firebaseService.collectionStream('products').map((snapshot) {
      final products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
      return products;
    });
  }

  @override
  Stream<Product?> getProductStream(String id) {
    return _firebaseService.documentStream('products', id).map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }
      return null;
    });
  }

  @override
  Future<void> bulkUpdateProducts(List<Product> products) async {
    try {
      final batchOperations = products.map((product) {
        final productData = product.toJson();
        productData.remove('id');
        productData['updatedAt'] = FieldValue.serverTimestamp();
        return {
          'type': 'update',
          'collection': 'products',
          'docId': product.id,
          'data': productData,
        };
      }).toList();

      await _firebaseService.batchWrite(batchOperations);
    } catch (e) {
      throw Exception('Failed to bulk update products: $e');
    }
  }

  @override
  Future<void> bulkDeleteProducts(List<String> ids) async {
    try {
      final batchOperations = ids.map((id) {
        return {
          'type': 'delete',
          'collection': 'products',
          'docId': id,
        };
      }).toList();

      await _firebaseService.batchWrite(batchOperations);
    } catch (e) {
      throw Exception('Failed to bulk delete products: $e');
    }
  }

  @override
  Future<Map<String, int>> getProductAnalytics() async {
    try {
      final products = await getProducts();
      final analytics = <String, int>{};

      analytics['total_products'] = products.length;
      analytics['active_products'] = products.where((p) => p.isActive).length;
      analytics['inactive_products'] =
          products.where((p) => !p.isActive).length;
      analytics['featured_products'] =
          products.where((p) => p.isPopular || p.isNewArrival).length;
      analytics['out_of_stock'] =
          products.where((p) => p.stockCount == 0).length;

      return analytics;
    } catch (e) {
      throw Exception('Failed to load product analytics: $e');
    }
  }

  @override
  Future<List<Product>> getTopSellingProducts(int limit) async {
    try {
      final products = await getProducts();
      final sortedProducts = products.where((p) => p.isActive).toList()
        ..sort((a, b) => b.soldCount.compareTo(a.soldCount));

      final topProducts = sortedProducts.take(limit).toList();
      return topProducts;
    } catch (e) {
      throw Exception('Failed to load top selling products: $e');
    }
  }
}
