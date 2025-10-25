/// File: product_exports.dart
/// Purpose: Master export file that consolidates all product-related components into a single import
/// Functionality: Provides organized exports of product widgets, models, state management, business logic, repositories, screens, and utilities
/// Dependencies: All product-related modules including widgets, models, blocs, providers, managers, repositories, screens, and utilities
/// Usage: Import this single file instead of importing multiple product-related files individually for cleaner code organization
/// 🎯 MASTER PRODUCT MODULE EXPORTS
/// Single entry point for ALL product-related functionality in the app
/// This file provides a clean API surface for product features across the entire app
///
/// Usage: `import 'product_exports.dart';` instead of importing multiple files

/// =============================================================================
/// 🎨 CATALOG WIDGETS (UI Components)
/// =============================================================================

export 'widgets/catalog/catalog_exports.dart';

/// =============================================================================
/// 📦 PRODUCT MODELS (Data Structures)
/// =============================================================================

export 'models/product_models.dart';
// Search result and variant models are included in product_models.dart

/// =============================================================================
/// 🧠 STATE MANAGEMENT (BLoC & Providers)
/// =============================================================================

export 'blocs/product/product_bloc.dart';
export 'blocs/product/product_events.dart';
export 'blocs/product/product_states.dart';
export 'providers/product_provider.dart' show ProductProvider;
export 'providers/wishlist_provider.dart' show WishlistProvider;

/// =============================================================================
/// 🏢 BUSINESS LOGIC (Managers & Services)
/// =============================================================================

export 'managers/product_business_manager.dart' show ProductBusinessManager;

/// =============================================================================
/// 💾 REPOSITORIES (Data Access Layer)
/// =============================================================================

export 'repositories/product/i_product_repository.dart' show IProductRepository;
export 'repositories/product/product_repository.dart' show ProductRepository;
export 'repositories/product/firebase_product_repository.dart'
    show FirebaseProductRepository;
export 'repositories/product/offline_product_repository.dart'
    show OfflineProductRepository;

/// =============================================================================
/// 📱 SCREENS (User Interfaces)
/// =============================================================================

export 'screens/products_screen.dart' show ProductsScreen;
export 'screens/admin_product_management.dart' show AdminProductManagement;
export 'screens/wishlist_screen.dart' show WishlistScreen;
export 'screens/catalog/product_detail_screen.dart' show ProductDetailScreen;
export 'screens/catalog/product_edit_screen.dart' show ProductEditScreen;

/// =============================================================================
/// 🛠️ UTILITIES (Shared helpers & constants)
/// =============================================================================

// Core product utilities
export 'utils/product_utils.dart'
    show
        ProductUtils,
        GridConstants,
        SpacingConstants,
        ProductConstants,
        LegacyProductConstants,
        // Legacy function aliases (backward compatibility)
        getGridCrossAxisCount,
        getCrossAxisCount,
        getResponsivePadding,
        getResponsiveFontSize,
        sortOptions,
        sortOptionLabels,
        productImageHeroTag,
        productCardHeroTag;

// Responsive utilities (commonly used with products)
export 'utils/responsive_utils.dart'
    show
        DeviceType,
        DeviceCategory,
        ContentDensity,
        GridConfiguration,
        GridSpacing,
        ProductGridDelegate,
        ResponsiveUtils;

// Theme utilities (commonly used with product UI)
export 'utils/theme_constants.dart'
    show AppColors, DarkAppColors, ThemeConstants;

/// =============================================================================
/// 📖 PRODUCT MODULE FAQ
/// =============================================================================

/// WHY THIS STRUCTURE?
/// - Single import brings in entire product ecosystem
/// - Eliminates 20+ individual imports across the codebase
/// - Better tree-shaking (Flutter can optimize unused exports)
/// - Centralized exports make it easy to add/remove product features
/// - Clear separation of concerns by functional area

/// HOW TO USE DIFFERENT LAYERS:
/// ```dart
/// // ✅ RECOMMENDED: Import everything at once
/// import 'product_exports.dart';
///
/// // ❌ DISCOURAGED: Importing individual files
/// import 'models/product_models.dart';
/// import 'providers/product_provider.dart';
/// import 'widgets/catalog/product_image.dart';
/// // ... 20 more imports
/// ```

/// ARCHITECTURAL LAYERS:
/// 🎨 UI Layer:     Catalog widgets, screens
/// 🧠 Logic Layer:  BLoC, Providers, Managers
/// 💾 Data Layer:   Repositories, Models
/// 🛠️ Utils Layer:  Helpers, constants, formatting

/// MAINTENANCE NOTES:
/// - Keep exports organized by functional area
/// - Add new components to appropriate sections
/// - Update documentation when adding new exports
/// - Legacy aliases ensure backward compatibility
/// - Always test after changes to ensure nothing breaks

/// LEGACY COMPATIBILITY:
/// Some old imports may still work via global aliases, but new code
/// should always use this consolidated export file for maintainability.
