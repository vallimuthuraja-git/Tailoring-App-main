/// File: product_exports.dart
/// Purpose: Master export file that consolidates all product-related components into a single import
/// Functionality: Provides organized exports of product widgets, models, state management, business logic, repositories, screens, and utilities
/// Dependencies: All product-related modules including widgets, models, blocs, providers, managers, repositories, screens, and utilities
/// Usage: Import this single file instead of importing multiple product-related files individually for cleaner code organization
/// 🎯 MASTER PRODUCT MODULE EXPORTS
/// Single entry point for ALL product-related functionality in the app
/// This file provides a clean API surface for product features across the entire app
///
/// Usage: `import 'package:tailoring_app/product/product_exports.dart';` instead of importing multiple files
//////
// Product Module Structure (Flat):
//
// lib/product/
// ├── product_exports.dart                # Main export file (this file)
// ├── README.md                           # Documentation
// ├──
// ├── Core Screens & UI Components:
// ├── products_screen.dart                # Main products screen (includes all catalog widgets)
// ├── admin_product_management.dart       # Admin management screen
// ├── wishlist_screen.dart               # Wishlist screen
// ├──
// ├── Data Models & Access:
// ├── product_models.dart                 # Core product models
// ├── product_search_result.dart          # Search result models
// ├── product_variant.dart               # Product variant models
// ├── product_data_access.dart           # Data access functions
// ├──
// ├── State Management (BLoC & Providers):
// ├── product_bloc.dart                   # Main product BLoC
// ├── product_events.dart                # Product events
// ├── product_states.dart                # Product states
// ├── product_provider.dart              # Product provider
// ├── wishlist_provider.dart             # Wishlist provider
// ├── product_business_manager.dart      # Business logic manager
// ├──
// ├── Data Access Layer:
// ├── i_product_repository.dart          # Repository interface
// ├── product_repository.dart            # Repository implementation
// ├──
// ├── Services:
// ├── product_analytics_service.dart     # Analytics service
// ├── product_cache_service.dart         # Caching service
// ├── product_search_service.dart        # Search service
// ├──
// ├── Utilities & Helpers:
// ├── product_utils.dart                 # Product utilities
// ├── product_screen_constants.dart      # Screen constants
// ├── responsive_utils.dart              # Responsive utilities
// ├── theme_constants.dart               # Theme constants
// └── card_layout_test.dart             # Card layout tests

/// =============================================================================
/// 🎨 CATALOG WIDGETS (UI Components)
/// =============================================================================
library;

// All catalog widgets are now consolidated in products_screen.dart

/// =============================================================================
/// 📦 PRODUCT MODELS (Data Structures)
/// =============================================================================

export 'product_models.dart';
export 'product_data_access.dart'; // Data access functions
// ProductSearchResult and ProductVariant classes are included in product_models.dart

/// =============================================================================
/// 🧠 STATE MANAGEMENT (BLoC & Providers)
/// =============================================================================

export 'product_bloc.dart';
export 'product_events.dart';
export 'product_states.dart';
export '../providers/product_provider.dart' show ProductProvider;
export '../providers/wishlist_provider.dart' show WishlistProvider;

/// =============================================================================
/// 🏢 BUSINESS LOGIC (Managers & Services)
/// =============================================================================

export 'product_business_manager.dart' show ProductBusinessManager;

/// =============================================================================
/// 💾 REPOSITORIES (Data Access Layer)
/// =============================================================================

export 'product_repository.dart' show IProductRepository;
export 'product_repository.dart' show ProductRepository;

/// =============================================================================
/// 🛠️ SERVICES (Background Processes)
/// =============================================================================

export 'product_analytics_service.dart';
export 'product_cache_service.dart';
export 'product_search_service.dart';

/// =============================================================================
/// 📱 SCREENS (User Interfaces)
/// =============================================================================

export 'products_screen.dart'
    show
        ProductsScreen,
        ProductDetailScreen,
        ProductEditScreen; // Now consolidated with ProductsScreen
export 'admin_product_management.dart' show AdminProductManagement;
export 'wishlist_screen.dart' show WishlistScreen;

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

// Screen-specific constants
export 'product_screen_constants.dart';

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
export '../../utils/theme_constants.dart'
    show AppColors, DarkAppColors, GlassyAppColors, AppThemes, GlassMorphism;

// Test utilities
export 'card_layout_test.dart'; // Layout testing utilities

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
