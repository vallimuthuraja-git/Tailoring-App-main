import 'dart:async';
import '../../models/product_models.dart';
import '../../repositories/product/i_product_repository.dart';

/// Product search service for advanced search functionality
class ProductSearchService {
  final IProductRepository _productRepository;
  final List<String> _searchHistory = [];
  final Map<String, List<String>> _autocompleteCache = {};

  ProductSearchService({
    required IProductRepository productRepository,
  }) : _productRepository = productRepository;

  /// Initialize the search service
  Future<void> initialize() async {
    // Load search history from storage if needed
    // For now, this is a placeholder
  }

  /// Perform advanced product search with filters
  Future<List<ProductSearchResult>> searchProducts(
      SearchOptions options) async {
    try {
      // Get all products from repository
      final allProducts = await _productRepository.getProducts();

      // Apply search filters
      final filteredProducts = _filterProducts(allProducts, options);

      // Sort results
      final sortedProducts = _sortProducts(filteredProducts, options);

      // Convert to search results with relevance scoring
      final searchResults = sortedProducts.map((product) {
        final relevanceScore = _calculateRelevanceScore(product, options);
        return ProductSearchResult(
          productId: product.id,
          productName: product.name,
          productDescription: product.description ?? '',
          brand: product.brand,
          imageUrls: product.imageUrls,
          price: product.basePrice,
          originalPrice: product.originalPrice,
          isActive: product.isActive,
          isOnSale: product.originalPrice != null &&
              product.originalPrice! > product.basePrice,
          relevanceScore: relevanceScore,
          highlights: <String, dynamic>{},
          matchedFields: [],
        );
      }).toList();

      // Add to search history
      if (options.query.isNotEmpty) {
        _addToSearchHistory(options.query);
      }

      return searchResults;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  /// Get autocomplete suggestions for search queries
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    if (query.isEmpty) {
      return _searchHistory.take(5).toList();
    }

    // Check cache first
    if (_autocompleteCache.containsKey(query)) {
      return _autocompleteCache[query]!;
    }

    try {
      final allProducts = await _productRepository.getProducts();
      final suggestions = <String>[];

      // Get product names that start with the query
      final nameMatches = allProducts
          .where((product) =>
              product.name.toLowerCase().startsWith(query.toLowerCase()))
          .map((product) => product.name)
          .toSet()
          .take(3);

      suggestions.addAll(nameMatches);

      // Get category matches
      final categoryMatches = allProducts
          .where((product) =>
              product.category.name.toLowerCase().contains(query.toLowerCase()))
          .map((product) => product.category.name)
          .toSet()
          .take(2);

      suggestions.addAll(categoryMatches);

      // Cache the results
      _autocompleteCache[query] = suggestions;

      return suggestions;
    } catch (e) {
      // Return search history as fallback
      return _searchHistory
          .where((history) =>
              history.toLowerCase().startsWith(query.toLowerCase()))
          .take(5)
          .toList();
    }
  }

  /// Clear search cache
  void clearCache() {
    _autocompleteCache.clear();
  }

  /// Get search statistics
  Map<String, dynamic> getSearchStats() {
    return {
      'total_searches': _searchHistory.length,
      'unique_queries': _searchHistory.toSet().length,
      'cache_size': _autocompleteCache.length,
    };
  }

  /// Filter products based on search options
  List<Product> _filterProducts(List<Product> products, SearchOptions options) {
    return products.where((product) {
      // Text query filter
      if (options.query.isNotEmpty) {
        final query = options.query.toLowerCase();
        final matchesName = product.name.toLowerCase().contains(query);
        final matchesDescription =
            (product.description ?? '').toLowerCase().contains(query);
        final matchesCategory =
            product.category.name.toLowerCase().contains(query);
        final matchesBrand = product.brand.toLowerCase().contains(query);

        if (!matchesName &&
            !matchesDescription &&
            !matchesCategory &&
            !matchesBrand) {
          return false;
        }
      }

      // Category filter
      if (options.categories.isNotEmpty) {
        if (!options.categories.contains(product.category.name)) {
          return false;
        }
      }

      // Price range filter
      if (options.priceRange != null) {
        final price = product.basePrice;
        final minPrice = options.priceRange!.start;
        final maxPrice = options.priceRange!.end;

        if (price < minPrice || price > maxPrice) {
          return false;
        }
      }

      // Active status filter (if applicable)
      // Additional filters can be added here

      return true;
    }).toList();
  }

  /// Sort products based on search options
  List<Product> _sortProducts(List<Product> products, SearchOptions options) {
    final sortedProducts = List<Product>.from(products);

    switch (options.sortBy) {
      case 'name':
        sortedProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_asc':
        sortedProducts.sort((a, b) => a.basePrice.compareTo(b.basePrice));
        break;
      case 'price_desc':
        sortedProducts.sort((a, b) => b.basePrice.compareTo(a.basePrice));
        break;
      case 'relevance':
      default:
        // For relevance sorting, products are already scored during conversion
        // Keep original order for now, relevance scoring happens later
        break;
    }

    return sortedProducts;
  }

  /// Calculate relevance score for a product based on search query
  double _calculateRelevanceScore(Product product, SearchOptions options) {
    if (options.query.isEmpty) return 1.0;

    final query = options.query.toLowerCase();
    double score = 0.0;

    // Exact name match gets highest score
    if (product.name.toLowerCase() == query) {
      score += 1.0;
    }
    // Name starts with query
    else if (product.name.toLowerCase().startsWith(query)) {
      score += 0.8;
    }
    // Name contains query
    else if (product.name.toLowerCase().contains(query)) {
      score += 0.6;
    }

    // Description match
    if (product.description.toLowerCase().contains(query) ?? false) {
      score += 0.3;
    }

    // Brand match
    if (product.brand.toLowerCase().contains(query)) {
      score += 0.2;
    }

    // Category match
    if (product.category.name.toLowerCase().contains(query)) {
      score += 0.4;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Add query to search history
  void _addToSearchHistory(String query) {
    _searchHistory.remove(query); // Remove if already exists
    _searchHistory.insert(0, query); // Add to beginning

    // Keep only last 50 searches
    if (_searchHistory.length > 50) {
      _searchHistory.removeRange(50, _searchHistory.length);
    }
  }
}
