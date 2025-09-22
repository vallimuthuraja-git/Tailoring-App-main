import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../utils/responsive_utils.dart';

class CategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Function(Map<String, dynamic>) onCategoryTap;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final deviceType = ResponsiveUtils.getDeviceTypeFromContext(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsiveFontSize(double baseSize) {
      if (screenWidth >= 1200) return baseSize * 1.1;
      if (screenWidth >= 900) return baseSize * 1.05;
      if (screenWidth >= 600) return baseSize * 0.95;
      return baseSize * 0.9;
    }

    int getCrossAxisCount() {
      switch (deviceType) {
        case DeviceType.mobile:
          return 2;
        case DeviceType.tablet:
          return 3;
        case DeviceType.desktop:
          return 4;
      }
    }

    double getChildAspectRatio() {
      switch (deviceType) {
        case DeviceType.mobile:
          return 1.0;
        case DeviceType.tablet:
          return 1.1;
        case DeviceType.desktop:
          return 1.2;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(20),
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onBackground
                      : AppColors.onBackground,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all categories
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary,
                    fontSize: getResponsiveFontSize(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),

          // Category Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: getCrossAxisCount(),
              crossAxisSpacing:
                  ResponsiveUtils.getResponsiveSpacing(context, 12.0),
              mainAxisSpacing:
                  ResponsiveUtils.getResponsiveSpacing(context, 12.0),
              childAspectRatio: getChildAspectRatio(),
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryCard(
                category: category,
                onTap: () => onCategoryTap(category),
              );
            },
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24.0)),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsiveFontSize(double baseSize) {
      if (screenWidth >= 1200) return baseSize * 1.1;
      if (screenWidth >= 900) return baseSize * 1.05;
      if (screenWidth >= 600) return baseSize * 0.95;
      return baseSize * 0.9;
    }

    final category = widget.category;
    final icon = category['icon'] as IconData?;
    final title = category['name'] as String?;
    final count = category['count'] as int?;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getCategoryColor(title ?? '').withValues(alpha: 0.8),
                    _getCategoryColor(title ?? '').withValues(alpha: 0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        _getCategoryColor(title ?? '').withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon ?? Icons.category,
                        size: getResponsiveFontSize(28),
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      title ?? 'Category',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getResponsiveFontSize(14),
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Count
                    if (count != null && count > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$count items',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: getResponsiveFontSize(10),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'products':
        return Colors.blue;
      case 'services':
        return Colors.green;
      case 'customers':
        return Colors.purple;
      case 'orders':
        return Colors.orange;
      case 'employees':
        return Colors.teal;
      case 'analytics':
        return Colors.pink;
      case 'shirts':
        return Colors.indigo;
      case 'pants':
        return Colors.brown;
      case 'suits':
        return Colors.deepPurple;
      case 'dresses':
        return Colors.pinkAccent;
      case 'accessories':
        return Colors.amber;
      case 'alterations':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
