import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/product_screen_constants.dart';

/// Skeleton loading widget for product cards
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    // Get the exact aspect ratio from the grid delegate
    double gridAspectRatio;
    if (screenWidth < 480) {
      gridAspectRatio = 0.55;
    } else if (screenWidth < 768) {
      gridAspectRatio = 0.5;
    } else if (screenWidth < 1024) {
      gridAspectRatio = 0.55;
    } else {
      gridAspectRatio = 0.5;
    }

    final cardPadding = ResponsiveUtils.getAdaptiveSpacing(
      context,
      baseSpacing: isSmall
          ? 8.0
          : isTablet
              ? 12.0
              : 16.0,
      hasRichContent: true,
      itemCount: 1,
      isGridView: true,
    );

    return AspectRatio(
      aspectRatio: gridAspectRatio,
      child: Card(
        elevation: ProductScreenConstants.cardElevation,
        margin: EdgeInsets.all(isSmall ? 4.0 : 6.0),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ProductScreenConstants.borderRadiusMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.surface.withValues(alpha: 0.3)
                      : AppColors.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        ProductScreenConstants.borderRadiusMedium),
                    topRight: Radius.circular(
                        ProductScreenConstants.borderRadiusMedium),
                  ),
                ),
                child: _SkeletonAnimation(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.surface.withValues(alpha: 0.5)
                          : AppColors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),

            // Content skeleton
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand skeleton
                    Container(
                      height: 8,
                      width: 60,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.surface.withValues(alpha: 0.3)
                            : AppColors.surface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _SkeletonAnimation(
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.surface.withValues(alpha: 0.5)
                                : AppColors.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Title skeleton
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.surface.withValues(alpha: 0.3)
                            : AppColors.surface.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _SkeletonAnimation(
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.surface.withOpacity(0.5)
                                : AppColors.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Second title line skeleton
                    Container(
                      height: 12,
                      width: screenWidth * 0.6,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.surface.withValues(alpha: 77)
                            : AppColors.surface.withValues(alpha: 77),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _SkeletonAnimation(
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.surface.withOpacity(0.5)
                                : AppColors.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Price skeleton
                    Container(
                      height: 14,
                      width: 80,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.surface.withOpacity(0.3)
                            : AppColors.surface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _SkeletonAnimation(
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.surface.withOpacity(0.5)
                                : AppColors.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Button skeleton
                    Container(
                      height: 32,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.surface.withOpacity(0.3)
                            : AppColors.surface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(
                            ProductScreenConstants.borderRadiusMedium),
                      ),
                      child: _SkeletonAnimation(
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.surface.withOpacity(0.5)
                                : AppColors.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(
                                ProductScreenConstants.borderRadiusMedium),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading widget for list items
class ProductListItemSkeleton extends StatelessWidget {
  const ProductListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: ProductScreenConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(ProductScreenConstants.borderRadiusMedium),
      ),
      child: Padding(
        padding: ResponsiveUtils.getAdaptivePadding(
          context,
          basePadding: ProductScreenConstants.getResponsivePadding(screenWidth),
          hasRichContent: true,
          itemCount: 1,
          isGridView: false,
        ),
        child: Row(
          children: [
            // Image skeleton
            Container(
              width: ProductScreenConstants.listItemHeight,
              height: ProductScreenConstants.listItemHeight,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.surface.withOpacity(0.3)
                    : AppColors.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(
                    ProductScreenConstants.borderRadiusSmall),
              ),
              child: _SkeletonAnimation(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.surface.withOpacity(0.5)
                        : AppColors.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            SizedBox(width: ProductScreenConstants.componentSpacing),

            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand skeleton
                  Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.surface.withOpacity(0.3)
                          : AppColors.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _SkeletonAnimation(
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.surface.withOpacity(0.5)
                              : AppColors.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Title skeleton
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.surface.withOpacity(0.3)
                          : AppColors.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _SkeletonAnimation(
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.surface.withOpacity(0.5)
                              : AppColors.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Description skeleton
                  Container(
                    height: 12,
                    width: screenWidth * 0.7,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.surface.withOpacity(0.3)
                          : AppColors.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _SkeletonAnimation(
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.surface.withOpacity(0.5)
                              : AppColors.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Rating and stock skeleton
                  Row(
                    children: [
                      Container(
                        height: 12,
                        width: 60,
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.surface.withOpacity(0.3)
                              : AppColors.surface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _SkeletonAnimation(
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.surface.withOpacity(0.5)
                                  : AppColors.surface.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ProductScreenConstants.componentSpacing),
                      Container(
                        height: 12,
                        width: 50,
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.surface.withOpacity(0.3)
                              : AppColors.surface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _SkeletonAnimation(
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.surface.withOpacity(0.5)
                                  : AppColors.surface.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: ProductScreenConstants.componentSpacing),

            // Price skeleton
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 16,
                  width: 70,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.surface.withOpacity(0.3)
                        : AppColors.surface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _SkeletonAnimation(
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.surface.withOpacity(0.5)
                            : AppColors.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated skeleton loading effect
class _SkeletonAnimation extends StatefulWidget {
  final Widget child;

  const _SkeletonAnimation({required this.child});

  @override
  _SkeletonAnimationState createState() => _SkeletonAnimationState();
}

class _SkeletonAnimationState extends State<_SkeletonAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_animation.value * 0.4),
          child: widget.child,
        );
      },
    );
  }
}

/// Grid skeleton loader
class ProductGridSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductGridSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: ResponsiveUtils.getOverflowSafeProductGridDelegate(context),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const ProductCardSkeleton(),
        childCount: itemCount,
      ),
    );
  }
}

/// List skeleton loader
class ProductListSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductListSkeleton({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          margin:
              EdgeInsets.only(bottom: ProductScreenConstants.componentSpacing),
          child: const ProductListItemSkeleton(),
        ),
        childCount: itemCount,
      ),
    );
  }
}

/// Progressive loading indicator with smooth animations
class ProgressiveLoadingIndicator extends StatefulWidget {
  final bool isLoadingMore;
  final String? loadingMessage;

  const ProgressiveLoadingIndicator({
    super.key,
    required this.isLoadingMore,
    this.loadingMessage,
  });

  @override
  State<ProgressiveLoadingIndicator> createState() =>
      _ProgressiveLoadingIndicatorState();
}

class _ProgressiveLoadingIndicatorState
    extends State<ProgressiveLoadingIndicator> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    if (widget.isLoadingMore) {
      _fadeController.forward();
      _scaleController.forward();
    }
  }

  @override
  void didUpdateWidget(ProgressiveLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoadingMore != oldWidget.isLoadingMore) {
      if (widget.isLoadingMore) {
        _fadeController.forward();
        _scaleController.forward();
      } else {
        _fadeController.reverse();
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        if (!widget.isLoadingMore && _fadeAnimation.value == 0.0) {
          return const SizedBox.shrink();
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  // Animated dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _scaleController,
                        builder: (context, child) {
                          final delay = index * 0.2;
                          final animation = Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: _scaleController,
                            curve: Interval(delay, delay + 0.6,
                                curve: Curves.easeInOut),
                          ));

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.primary
                                      .withOpacity(animation.value)
                                  : AppColors.primary
                                      .withOpacity(animation.value),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.loadingMessage ?? 'Loading more products...',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withOpacity(0.7)
                          : AppColors.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Enhanced loading shimmer effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Gradient gradient;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.gradient = const LinearGradient(
      colors: [
        Color(0xFFEBEBF4),
        Color(0xFFF4F4F4),
        Color(0xFFEBEBF4),
      ],
      stops: [0.1, 0.3, 0.4],
      begin: Alignment(-1.0, -0.3),
      end: Alignment(1.0, 0.3),
    ),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return widget.gradient.createShader(
              Rect.fromLTWH(
                bounds.width * _animation.value,
                0,
                bounds.width,
                bounds.height,
              ),
            );
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Smooth content transition between loading and loaded states
class SmoothContentTransition extends StatefulWidget {
  final Widget loadingWidget;
  final Widget contentWidget;
  final bool isLoading;
  final Duration transitionDuration;

  const SmoothContentTransition({
    super.key,
    required this.loadingWidget,
    required this.contentWidget,
    required this.isLoading,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SmoothContentTransition> createState() =>
      _SmoothContentTransitionState();
}

class _SmoothContentTransitionState extends State<SmoothContentTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    if (!widget.isLoading) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SmoothContentTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final contentOpacity = _fadeAnimation.value;
        final loadingOpacity = 1.0 - _fadeAnimation.value;

        return Stack(
          children: [
            // Loading widget
            if (loadingOpacity > 0)
              Opacity(
                opacity: loadingOpacity,
                child: widget.loadingWidget,
              ),

            // Content widget
            if (contentOpacity > 0)
              Opacity(
                opacity: contentOpacity,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: widget.contentWidget,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Animated fade-in for content appearance
class FadeInContent extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeInContent({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
  });

  @override
  State<FadeInContent> createState() => _FadeInContentState();
}

class _FadeInContentState extends State<FadeInContent>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Staggered animation for list items
class StaggeredFadeIn extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDelay;

  const StaggeredFadeIn({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return FadeInContent(
          key: ValueKey('staggered_item_$index'),
          duration: itemDuration,
          delay: staggerDelay * index,
          child: child,
        );
      }).toList(),
    );
  }
}
