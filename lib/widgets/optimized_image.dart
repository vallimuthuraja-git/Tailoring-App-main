import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Optimized image widget with advanced caching and performance features
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableFadeIn;
  final Duration fadeInDuration;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final FilterQuality filterQuality;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.enableFadeIn = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.memCacheWidth,
    this.memCacheHeight,
    this.filterQuality = FilterQuality.medium,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      filterQuality: filterQuality,
      fadeInDuration: enableFadeIn ? fadeInDuration : Duration.zero,
      placeholder: (context, url) => placeholder ?? _buildShimmerPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
    );

    // Apply border radius if specified
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius as BorderRadius,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      color: Colors.grey[200],
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}

/// Preloading image manager for better scrolling performance
class ImagePreloader {
  static final Set<String> _preloadedImages = {};

  /// Preload images that are likely to be viewed soon
  static void preloadImages(List<String> imageUrls, {int maxConcurrent = 3}) {
    final urlsToPreload =
        imageUrls.where((url) => !_preloadedImages.contains(url)).toList();

    if (urlsToPreload.isEmpty) return;

    // Preload images with controlled concurrency
    for (int i = 0; i < urlsToPreload.length && i < maxConcurrent; i++) {
      final url = urlsToPreload[i];
      CachedNetworkImageProvider(url).resolve(ImageConfiguration.empty);
      _preloadedImages.add(url);
    }
  }

  /// Clear preload cache (useful for memory management)
  static void clearPreloadCache() {
    _preloadedImages.clear();
  }
}

/// Optimized image widget specifically for product cards
class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius,
      memCacheWidth: width.isFinite ? width.toInt() : null,
      memCacheHeight: height.isFinite ? height.toInt() : null,
      filterQuality: FilterQuality.medium,
    );
  }
}
