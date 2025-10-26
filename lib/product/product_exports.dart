// This file serves as the master export point for all product-related functionality in the app.
// It consolidates components from various product modules for simplified imports.
//
// Usage: `import 'product_exports.dart';` instead of importing multiple files

// =============================================================================
// 🎨 CATALOG WIDGETS (UI Components)
// =============================================================================

// All catalog widgets are now consolidated in products_screen.dart

// =============================================================================
// 📦 PRODUCT MODELS (Data Structures)
// =============================================================================

export 'product_models.dart';
// Search result and variant models are included in product_models.dart

// =============================================================================
// 🧠 STATE MANAGEMENT (BLoC & Providers)
// =============================================================================

export 'product_bloc.dart';
export 'product_events.dart';
export 'product_states.dart';
// Fixed to use correct relative path
export '../providers/product_provider.dart' show ProductProvider;
export '../providers/wishlist_provider.dart' show WishlistProvider;

/// =============================================================================
/// 🏢 BUSINESS LOGIC (Managers & Services)
/// =============================================================================

export 'product_business_manager.dart' show ProductBusinessManager;

/// =============================================================================
/// 💾 REPOSITORIES (Data Access Layer)
/// =============================================================================

export 'product_repository.dart' show IProductRepository, ProductRepository;

// Repository implementations
export 'firebase_product_repository.dart' show FirebaseProductRepository;
// export 'offline_product_repository.dart' show OfflineProductRepository;

/// =============================================================================
/// 📱 SCREENS (User Interfaces)
/// =============================================================================

export 'products_screen.dart'
    show
        ProductsScreen,
        ProductDetailScreen,
        ProductEditScreen,
        UnifiedProductCard; // Now consolidated with ProductsScreen
export 'admin_product_management.dart' show AdminProductManagement;

/// =============================================================================
/// 🛠️ UTILITIES (Shared helpers & constants)
/// =============================================================================

// Core product utilities
export 'product_utils.dart'
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
export '../../utils/responsive_utils.dart'
    show
        DeviceType,
        DeviceCategory,
        ContentDensity,
        GridConfiguration,
        GridSpacing,
        ProductGridDelegate,
        ResponsiveUtils;

// Theme utilities (commonly used with product UI)
export '../utils/theme_constants.dart'
    show AppColors, DarkAppColors, GlassyAppColors, AppThemes, GlassMorphism;

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
