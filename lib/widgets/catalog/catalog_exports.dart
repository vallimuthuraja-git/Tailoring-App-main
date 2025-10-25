/// 🚀 CONSOLIDATED CATALOG MODULE EXPORTS
/// Single entry point for ALL product catalog widgets, components, and utilities
/// This file eliminates redundant imports and provides a clean API surface

/// =============================================================================
/// 🎨 PRODUCT DISPLAY COMPONENTS (Core widgets for showing products)
/// =============================================================================

export 'product_image.dart' show ProductImage;
export 'unified_product_card.dart' show UnifiedProductCard;
export 'rating_stars.dart' show RatingStars;
export 'price_display.dart' show PriceDisplay;

/// =============================================================================
/// 📱 LAYOUT & NAVIGATION COMPONENTS
/// =============================================================================

export 'product_grid_view.dart' show ProductGridView;
export 'product_cards.dart' show ProductCardUtils, CardDimensions;
export 'catalog_components.dart'
    show
        ProductStatsOverview,
        CatalogCategoryTab,
        CatalogHeroBanner,
        CatalogQuickActions,
        CatalogEmptyState,
        ActionButton;

/// =============================================================================
/// 🔧 UI & INTERACTION COMPONENTS
/// =============================================================================

export 'catalog_app_bars.dart' show CatalogAppBar;
export 'catalog_bottom_sheets.dart'
    show
        CatalogFilterBottomSheet,
        CatalogSortBottomSheet,
        CatalogFilterOptions,
        CatalogSortOptions;
export 'enhanced_empty_state.dart' show EnhancedEmptyState, EmptyStateType;
export 'expandable_search_bar.dart' show ExpandableSearchBar;
export 'product_screen_action_bar.dart'
    show ProductScreenActionBar, FilterChips;
export 'product_screen_content.dart' show ProductScreenContent, ProductListItem;
export 'product_screen_filters_bar.dart' show ProductScreenFiltersBar;
export 'skeleton_loading_widgets.dart'
    show ProductGridSkeleton, ProductListItemSkeleton;

/// =============================================================================
/// ⚙️ CONFIGURATION & TYPES
/// =============================================================================

export 'product_card_config.dart'
    show
        ProductCardConfig,
        CardDisplayMode,
        ActionButtonMode,
        BadgeDisplayMode,
        ContentDisplayConfig,
        ActionButtonConfig,
        LayoutConfig;

/// =============================================================================
/// 🔧 UTILITY RE-EXPORTS (For convenience in catalog-related files)
/// =============================================================================

// Core responsive utilities
export '../../utils/responsive_utils.dart'
    show
        DeviceType,
        DeviceCategory,
        ContentDensity,
        GridConfiguration,
        GridSpacing,
        ProductGridDelegate,
        ResponsiveUtils;

// Core product utilities (constants, formatting, validation)
export '../../utils/product_utils.dart'
    show
        ProductUtils,
        GridConstants,
        SpacingConstants,
        ProductConstants,
        // Legacy aliases for backward compatibility
        sortOptions,
        sortOptionLabels,
        productImageHeroTag,
        productCardHeroTag;

/// =============================================================================
/// 📂 SUB-MODULE EXPORT FAQ
/// =============================================================================

/// WHY THIS STRUCTURE?
/// - Eliminates repetitive imports across catalog files
/// - Single source of truth for widget exports
/// - Cleaner imports: `import '../../../widgets/catalog.dart';`
/// - Better tree-shaking and compilation performance
/// - Easy to find all catalog components in one place

/// HOW TO USE:
/// ```dart
/// // Before (verbose imports):
/// import 'catalog/product_image.dart';
/// import 'catalog/unified_product_card.dart';
/// import 'catalog/rating_stars.dart';
///
/// // After (clean single import):
/// import 'catalog.dart';
/// // All components available directly
/// ```

/// MAINTENANCE NOTES:
/// - Always keep this file updated when adding new catalog widgets
/// - Sort exports alphabetically within sections for easy scanning
/// - Add brief documentation comments above each export group
/// - Test imports after any changes to ensure nothing breaks
