import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_models.dart';

/// Product caching service for offline storage and performance optimization
class ProductCacheService {
  static const String _cacheKey = 'product_cache';
  static const String _cacheStatsKey = 'product_cache_stats';
  static const Duration _defaultCacheDuration = Duration(hours: 24);

  SharedPreferences? _prefs;
  final Map<String, _CacheEntry> _memoryCache = {};
  final Map<String, DateTime> _accessTimes = {};

  /// Initialize the cache service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromDisk();
    _cleanupExpiredEntries();
  }

  /// Cache a product with optional duration
  Future<void> cacheProduct(Product product, {Duration? duration}) async {
    final entry = _CacheEntry(
      product: product,
      expiryTime: DateTime.now().add(duration ?? _defaultCacheDuration),
      lastAccessed: DateTime.now(),
    );

    _memoryCache[product.id] = entry;
    _accessTimes[product.id] = DateTime.now();
    await _saveToDisk();
  }

  /// Get cached product by ID
  Product? getCachedProduct(String productId) {
    final entry = _memoryCache[productId];
    if (entry == null || entry.isExpired) {
      return null;
    }

    // Update access time
    entry.lastAccessed = DateTime.now();
    _accessTimes[productId] = DateTime.now();

    return entry.product;
  }

  /// Check if product is cached and not expired
  bool isProductCached(String productId) {
    final entry = _memoryCache[productId];
    return entry != null && !entry.isExpired;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    _memoryCache.clear();
    _accessTimes.clear();
    await _prefs?.remove(_cacheKey);
    await _prefs?.remove(_cacheStatsKey);
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    final expiredCount =
        _memoryCache.values.where((entry) => entry.isExpired).length;
    final validCount = _memoryCache.length - expiredCount;

    return {
      'total_entries': _memoryCache.length,
      'valid_entries': validCount,
      'expired_entries': expiredCount,
      'memory_usage_kb': _calculateMemoryUsage(),
      'hit_rate': _calculateHitRate(),
      'oldest_entry': _findOldestEntry(),
      'newest_entry': _findNewestEntry(),
    };
  }

  /// Preload popular products (placeholder for future implementation)
  Future<void> preloadPopularProducts(List<String> productIds) async {
    // Implementation would fetch and cache popular products
    // For now, this is a placeholder
  }

  /// Clean up expired entries from cache
  void _cleanupExpiredEntries() {
    final expiredKeys = _memoryCache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _accessTimes.remove(key);
    }
  }

  /// Calculate approximate memory usage in KB
  int _calculateMemoryUsage() {
    // Rough estimation: each product ~2KB
    return _memoryCache.length * 2;
  }

  /// Calculate cache hit rate (simplified)
  double _calculateHitRate() {
    if (_accessTimes.isEmpty) return 0.0;

    final recentAccesses = _accessTimes.values
        .where((time) =>
            time.isAfter(DateTime.now().subtract(const Duration(hours: 1))))
        .length;

    return recentAccesses / _accessTimes.length;
  }

  /// Find oldest cache entry
  DateTime? _findOldestEntry() {
    if (_memoryCache.isEmpty) return null;

    DateTime? oldest;
    for (final entry in _memoryCache.values) {
      if (oldest == null || entry.lastAccessed.isBefore(oldest)) {
        oldest = entry.lastAccessed;
      }
    }
    return oldest;
  }

  /// Find newest cache entry
  DateTime? _findNewestEntry() {
    if (_memoryCache.isEmpty) return null;

    DateTime? newest;
    for (final entry in _memoryCache.values) {
      if (newest == null || entry.lastAccessed.isAfter(newest)) {
        newest = entry.lastAccessed;
      }
    }
    return newest;
  }

  /// Load cache from disk
  Future<void> _loadFromDisk() async {
    try {
      final cacheData = _prefs?.getString(_cacheKey);
      if (cacheData != null) {
        final decoded = jsonDecode(cacheData) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final entryData = entry.value as Map<String, dynamic>;
          final productData = entryData['product'] as Map<String, dynamic>;
          final expiryTime = DateTime.parse(entryData['expiryTime']);
          final lastAccessed = DateTime.parse(entryData['lastAccessed']);

          if (DateTime.now().isBefore(expiryTime)) {
            final product = Product.fromJson(productData);
            _memoryCache[entry.key] = _CacheEntry(
              product: product,
              expiryTime: expiryTime,
              lastAccessed: lastAccessed,
            );
            _accessTimes[entry.key] = lastAccessed;
          }
        }
      }
    } catch (e) {
      // If loading fails, start with empty cache
      _memoryCache.clear();
      _accessTimes.clear();
    }
  }

  /// Save cache to disk
  Future<void> _saveToDisk() async {
    try {
      final cacheData = <String, dynamic>{};
      for (final entry in _memoryCache.entries) {
        if (!entry.value.isExpired) {
          cacheData[entry.key] = {
            'product': entry.value.product.toJson(),
            'expiryTime': entry.value.expiryTime.toIso8601String(),
            'lastAccessed': entry.value.lastAccessed.toIso8601String(),
          };
        }
      }
      await _prefs?.setString(_cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // If saving fails, continue without persisting
    }
  }
}

/// Internal cache entry class
class _CacheEntry {
  final Product product;
  final DateTime expiryTime;
  DateTime lastAccessed;

  _CacheEntry({
    required this.product,
    required this.expiryTime,
    required this.lastAccessed,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}
