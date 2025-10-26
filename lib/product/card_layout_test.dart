import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../product/products_screen.dart';
import 'product_models.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../product/product_data_access.dart';
import 'package:provider/provider.dart';

// Mock implementation of ProductBloc for testing
class MockProductBloc {
  // Add necessary mocks for testing
}

class MockProductRepository {
  // Add necessary mocks for testing
}

class MockConnectivity {
  // Add necessary mocks for testing
}

// Create a mock product provider for testing
class MockProductProvider with ChangeNotifier {
  List<Product> get products => [];
  bool isProductInWishlist(String productId) => false;
  Future<bool> toggleWishlist(String productId) async => true;
  // Add other required methods if needed
  @override
  void notifyListeners() {} // Override to do nothing for test
}

/// Simple test to validate card layout and overflow detection
void main() {
  group('UnifiedProductCard Layout Tests', () {
    late Product testProduct;

    setUp(() {
      testProduct = Product(
        id: 'test-product',
        name:
            'Test Product with Very Long Name That Should Test Text Overflow Handling',
        basePrice: 99.99,
        originalPrice: 129.99,
        imageUrls: ['https://example.com/image.jpg'],
        description: 'A test product description',
        category: ProductCategory.mensWear,
        stockCount: 10,
        rating: ProductRating(
          averageRating: 4.5,
          reviewCount: 25,
          recentReviews: [],
        ),
        specifications: {},
        availableSizes: ['S', 'M', 'L'],
        availableFabrics: ['Cotton', 'Polyester'],
        customizationOptions: ['Color', 'Size'],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('Card renders without overflow on different screen sizes',
        (WidgetTester tester) async {
      // Test Extra Small screen (320px)
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ChangeNotifierProvider(create: (_) => CartProvider()),
              ChangeNotifierProvider(create: (_) => MockProductProvider()),
            ],
            child: MediaQuery(
              data: const MediaQueryData(size: Size(320, 640)),
              child: Scaffold(
                body: UnifiedProductCard(
                  product: testProduct,
                  index: 0,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify card exists and no overflow errors
      expect(find.byType(UnifiedProductCard), findsOneWidget);

      // Test Small screen (360px)
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ChangeNotifierProvider(create: (_) => CartProvider()),
              ChangeNotifierProvider(create: (_) => MockProductProvider()),
            ],
            child: MediaQuery(
              data: const MediaQueryData(size: Size(360, 640)),
              child: Scaffold(
                body: UnifiedProductCard(
                  product: testProduct,
                  index: 0,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test Medium screen (480px)
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ChangeNotifierProvider(create: (_) => CartProvider()),
              ChangeNotifierProvider(create: (_) => MockProductProvider()),
            ],
            child: MediaQuery(
              data: const MediaQueryData(size: Size(480, 640)),
              child: Scaffold(
                body: UnifiedProductCard(
                  product: testProduct,
                  index: 0,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test Large screen (600px)
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ChangeNotifierProvider(create: (_) => CartProvider()),
              ChangeNotifierProvider(create: (_) => MockProductProvider()),
            ],
            child: MediaQuery(
              data: const MediaQueryData(size: Size(600, 800)),
              child: Scaffold(
                body: UnifiedProductCard(
                  product: testProduct,
                  index: 0,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('Card handles orientation changes correctly',
        (WidgetTester tester) async {
      // Test portrait orientation
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ChangeNotifierProvider(create: (_) => CartProvider()),
              ChangeNotifierProvider(create: (_) => MockProductProvider()),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 640),
              ),
              child: Scaffold(
                body: UnifiedProductCard(
                  product: testProduct,
                  index: 0,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test landscape orientation
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ChangeNotifierProvider(create: (_) => CartProvider()),
              ChangeNotifierProvider(create: (_) => MockProductProvider()),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(640, 360),
              ),
              child: Scaffold(
                body: UnifiedProductCard(
                  product: testProduct,
                  index: 0,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    });
  });
}
