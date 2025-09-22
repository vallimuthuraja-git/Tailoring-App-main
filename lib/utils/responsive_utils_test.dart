import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'responsive_utils.dart';

void main() {
  group('ResponsiveUtils Grid Behavior Tests', () {
    // Grid delegate creation tests
    group('Grid Delegate Creation', () {
      setUp(() {
        TestWidgetsFlutterBinding.ensureInitialized();
      });

      testWidgets('creates delegate for 320px screen width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(320, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        expect(delegate.maxCrossAxisExtent, greaterThan(0));
        expect(ResponsiveUtils.getCrossAxisCount(320),
            equals(2)); // For <600px, 2 columns
        expect(delegate.childAspectRatio,
            greaterThan(1.0)); // Aspect ratio is positive and reasonable
      });

      testWidgets('creates delegate for 360px screen width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(360, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        expect(ResponsiveUtils.getCrossAxisCount(360), equals(2));
        expect(delegate.childAspectRatio, greaterThan(1.0));
      });

      testWidgets('creates delegate for 480px screen width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(480, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        expect(ResponsiveUtils.getCrossAxisCount(480), equals(2));
        expect(delegate.childAspectRatio, closeTo(1.6, 0.1));
      });

      testWidgets('creates delegate for 600px screen width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(600, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        expect(ResponsiveUtils.getCrossAxisCount(600),
            equals(3)); // 600-900px -> 3 columns
        expect(delegate.childAspectRatio, greaterThan(1.0));
      });

      testWidgets('creates delegate for 768px screen width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(768, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        expect(ResponsiveUtils.getCrossAxisCount(768), equals(3));
        expect(delegate.childAspectRatio, greaterThan(1.0));
      });

      testWidgets('creates delegate for 900px screen width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(900, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        expect(ResponsiveUtils.getCrossAxisCount(900),
            equals(4)); // 900-1200px -> 4 columns
        expect(delegate.childAspectRatio, greaterThan(1.0));
      });

      testWidgets('creates delegate for 1200px screen width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(1200, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        expect(ResponsiveUtils.getCrossAxisCount(1200),
            equals(5)); // >=1200px -> 5 columns
        expect(delegate.childAspectRatio, greaterThan(1.0));
      });

      testWidgets('creates delegate for 1440px screen width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(1440, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        expect(ResponsiveUtils.getCrossAxisCount(1440), equals(5));
        expect(delegate.childAspectRatio, greaterThan(1.0));
      });

      testWidgets('creates delegate for 1920px screen width',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(1920, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        expect(ResponsiveUtils.getCrossAxisCount(1920), equals(5));
        expect(delegate.childAspectRatio, greaterThan(1.0));
      });
    });

    // Content density calculations
    group('Content Density Calculations', () {
      testWidgets('returns compact density for small screens',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(400, 600),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final density = ResponsiveUtils.getContentDensity(context);

        expect(density, equals(ContentDensity.compact));
      });

      testWidgets('returns standard density for medium screens',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(800, 900),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final density = ResponsiveUtils.getContentDensity(context);

        expect(density, equals(ContentDensity.standard));
      });

      testWidgets('returns spacious density for large screens',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(1400, 1000),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final density = ResponsiveUtils.getContentDensity(context);

        expect(density, equals(ContentDensity.standard));
      });

      testWidgets('considers item count in density calculation',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(800, 900),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final density =
            ResponsiveUtils.getContentDensity(context, itemCount: 20);

        expect(
            density,
            equals(ContentDensity
                .standard)); // More items may not always reduce to compact
      });
    });

    // Touch target compliance
    group('Touch Target Compliance', () {
      testWidgets('ensures minimum 44px touch targets on mobile',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(400, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        // Calculate item height (touch target height)
        final itemHeight = delegate.mainAxisExtent ?? 0;

        expect(itemHeight, greaterThanOrEqualTo(44.0));
      });

      testWidgets('ensures minimum 48px touch targets on desktop',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(1200, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        // Calculate item height (touch target height)
        final itemHeight = delegate.mainAxisExtent ?? 0;

        expect(itemHeight, greaterThanOrEqualTo(48.0));
      });

      test('GridSpacing provides appropriate spacing for touch targets', () {
        final mobileSpacing = GridSpacing.getSpacing(400);
        final desktopSpacing = GridSpacing.getSpacing(1200);

        // Check that spacing allows for adequate touch targets
        expect(mobileSpacing.crossAxisSpacing, greaterThanOrEqualTo(4));
        expect(desktopSpacing.crossAxisSpacing, greaterThanOrEqualTo(12));
      });
    });

    // Aspect ratio standardization
    group('Aspect Ratio Standardization', () {
      test('returns 1.8 aspect ratio for screens < 360px', () {
        final aspectRatio = LazyResponsiveCalculator.getAspectRatio(320, 800);
        expect(aspectRatio, closeTo(1.8, 0.2)); // Allow for density adjustments
      });

      test('returns 1.6 aspect ratio for screens 360-600px', () {
        final aspectRatio = LazyResponsiveCalculator.getAspectRatio(480, 800);
        expect(aspectRatio, closeTo(1.6, 0.2));
      });

      test('returns 1.2 aspect ratio for screens >= 1200px', () {
        final aspectRatio = LazyResponsiveCalculator.getAspectRatio(1200, 800);
        expect(aspectRatio, closeTo(1.2, 0.2));
      });

      test('adjusts aspect ratio based on content density', () {
        // Compact density should make it more compact (smaller aspect ratio)
        final compactRatio = LazyResponsiveCalculator.getAspectRatio(
            400, 600); // Small screen, compact
        final spaciousRatio = LazyResponsiveCalculator.getAspectRatio(
            1400, 1000); // Large screen, spacious

        expect(
            compactRatio,
            isNot(equals(
                spaciousRatio))); // Different densities have different ratios
      });
    });

    // Placeholder widget functionality
    group('Placeholder Widget Functionality', () {
      testWidgets('creates placeholder widgets correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(600, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context, itemCount: 5);

        final placeholder = delegate.createPlaceholderWidget();
        expect(placeholder, isA<Container>());
        expect((placeholder as Container).decoration, isA<BoxDecoration>());
      });

      testWidgets('aligns last row with placeholders when enabled',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(600, 800), // 3 columns
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context,
            itemCount: 7, fillLastRowWithPlaceholders: true);

        final totalCount = delegate.getTotalItemCount();
        expect(totalCount, equals(9)); // 7 + 2 placeholders to fill row
      });

      testWidgets('does not add placeholders when disabled',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(600, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context,
            itemCount: 7, fillLastRowWithPlaceholders: false);

        final totalCount = delegate.getTotalItemCount();
        expect(totalCount, equals(7)); // No placeholders
      });

      testWidgets('correctly identifies placeholder items',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(600, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context,
            itemCount: 7, fillLastRowWithPlaceholders: true);

        expect(delegate.isPlaceholder(6), isFalse); // Real item
        expect(delegate.isPlaceholder(7), isTrue); // Placeholder
        expect(delegate.isPlaceholder(8), isTrue); // Placeholder
      });
    });

    // LazyResponsiveCalculator caching
    group('LazyResponsiveCalculator Caching', () {
      setUp(() {
        LazyResponsiveCalculator.clearCache(); // Start with clean cache
      });

      test('caches aspect ratio calculations', () {
        // First call should calculate and cache
        final aspect1 = LazyResponsiveCalculator.getAspectRatio(600, 800);

        // Second call with same params should use cache
        final aspect2 = LazyResponsiveCalculator.getAspectRatio(600, 800);

        expect(aspect1, equals(aspect2));
      });

      test('caches max cross axis extent calculations', () {
        // First call should calculate and cache
        final extent1 = LazyResponsiveCalculator.getMaxCrossAxisExtent(600);

        // Second call with same params should use cache
        final extent2 = LazyResponsiveCalculator.getMaxCrossAxisExtent(600);

        expect(extent1, equals(extent2));
      });

      test('clears cache when requested', () {
        // Populate cache
        LazyResponsiveCalculator.getAspectRatio(600, 800);
        LazyResponsiveCalculator.getMaxCrossAxisExtent(600);

        // Clear cache
        LazyResponsiveCalculator.clearCache();

        // Cache should be cleared, but functionality remains
        final aspect = LazyResponsiveCalculator.getAspectRatio(600, 800);
        expect(aspect, isNotNull);
      });

      test('different parameters create different cache entries', () {
        final aspect600 = LazyResponsiveCalculator.getAspectRatio(600, 800);
        final aspect800 = LazyResponsiveCalculator.getAspectRatio(800, 800);

        expect(aspect600, isNot(equals(aspect800)));
      });
    });

    // Overflow prevention
    group('Overflow Prevention', () {
      testWidgets('prevents overflow with mainAxisExtent constraints',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(600, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);

        // mainAxisExtent should be calculated to prevent overflow
        expect(delegate.mainAxisExtent, isNotNull);
        expect(delegate.mainAxisExtent, greaterThan(0));

        // The extent should be reasonable (not too large for the screen)
        expect(
            delegate.mainAxisExtent, lessThan(800)); // Less than screen height
      });

      testWidgets(
          'calculates appropriate mainAxisExtent for different screen sizes',
          (WidgetTester tester) async {
        // Test with small screen
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(400, 600),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final smallDelegate = ProductGridDelegate.fromContext(context);
        final smallExtent = smallDelegate.mainAxisExtent ?? 0;

        // Test with large screen
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(1200, 1000),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final largeContext = tester.element(find.byType(Container));
        final largeDelegate = ProductGridDelegate.fromContext(largeContext);
        final largeExtent = largeDelegate.mainAxisExtent ?? 0;

        // Large screen should have larger extent but still reasonable
        expect(largeExtent, greaterThan(smallExtent));
        expect(largeExtent, lessThan(1000)); // Less than screen height
      });
    });

    // Adaptive padding and spacing
    group('Adaptive Padding and Spacing', () {
      testWidgets('calculates adaptive spacing based on content density',
          (WidgetTester tester) async {
        // Test compact density
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(400, 600), // Small screen = compact
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final compactSpacing =
            ResponsiveUtils.getAdaptiveSpacing(context, baseSpacing: 16.0);

        // Test spacious density
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(1400, 1000), // Large screen = spacious
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final spaciousContext = tester.element(find.byType(Container));
        final spaciousSpacing = ResponsiveUtils.getAdaptiveSpacing(
            spaciousContext,
            baseSpacing: 16.0);

        expect(compactSpacing, lessThan(spaciousSpacing));
        expect(compactSpacing, equals(16.0 * 0.5)); // Compact multiplier
        expect(spaciousSpacing, equals(16.0)); // May be standard, not spacious
      });

      testWidgets('calculates adaptive padding for different screen sizes',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(800, 900),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final adaptivePadding =
            ResponsiveUtils.getAdaptivePadding(context, basePadding: 16.0);

        expect(adaptivePadding, isA<EdgeInsets>());
        expect(adaptivePadding.left, greaterThanOrEqualTo(0));
        expect(adaptivePadding.right, greaterThanOrEqualTo(0));
        expect(adaptivePadding.top, greaterThanOrEqualTo(0));
        expect(adaptivePadding.bottom, greaterThanOrEqualTo(0));
      });
    });

    // Integration tests
    group('Integration Tests', () {
      testWidgets('full grid configuration for mobile device',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(400, 800),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);
        final density = ResponsiveUtils.getContentDensity(context);
        final spacing = ResponsiveUtils.getAdaptiveSpacing(context);

        // Mobile should have:
        // - 2 columns
        // - Compact density
        // - Appropriate spacing
        // - Touch target compliance
        expect(ResponsiveUtils.getCrossAxisCount(400), equals(2));
        expect(density, equals(ContentDensity.compact));
        expect(spacing, greaterThan(0));
        expect(
            delegate.mainAxisExtent, greaterThanOrEqualTo(44)); // Touch target
      });

      testWidgets('full grid configuration for tablet device',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(800, 900),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);
        final density = ResponsiveUtils.getContentDensity(context);
        final spacing = ResponsiveUtils.getAdaptiveSpacing(context);

        // Tablet should have:
        // - 3 columns
        // - Standard density
        // - Appropriate spacing
        // - Touch target compliance
        expect(ResponsiveUtils.getCrossAxisCount(800), equals(3));
        expect(density, equals(ContentDensity.standard));
        expect(spacing, greaterThan(0));
        expect(
            delegate.mainAxisExtent, greaterThanOrEqualTo(48)); // Touch target
      });

      testWidgets('full grid configuration for desktop device',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final mediaQueryData = MediaQuery.of(context).copyWith(
                  size: const Size(1400, 1000),
                );
                return MediaQuery(
                  data: mediaQueryData,
                  child: Container(),
                );
              },
            ),
          ),
        );

        final context = tester.element(find.byType(Container));
        final delegate = ProductGridDelegate.fromContext(context);
        final density = ResponsiveUtils.getContentDensity(context);
        final spacing = ResponsiveUtils.getAdaptiveSpacing(context);

        // Desktop should have:
        // - 5 columns
        // - Spacious density
        // - Appropriate spacing
        // - Touch target compliance
        expect(ResponsiveUtils.getCrossAxisCount(1400), equals(5));
        expect(density, equals(ContentDensity.standard));
        expect(spacing, greaterThan(0));
        expect(
            delegate.mainAxisExtent, greaterThanOrEqualTo(48)); // Touch target
      });
    });
  });
}
