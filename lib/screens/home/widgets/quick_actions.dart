import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../utils/responsive_utils.dart';

class QuickActions extends StatelessWidget {
  final bool isShopOwner;
  final int cartItemCount;
  final VoidCallback onCartTap;
  final VoidCallback onWishlistTap;
  final VoidCallback onOrdersTap;

  const QuickActions({
    super.key,
    required this.isShopOwner,
    required this.cartItemCount,
    required this.onCartTap,
    required this.onWishlistTap,
    required this.onOrdersTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final deviceType = ResponsiveUtils.getDeviceTypeFromContext(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionsGrid(context, deviceType),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, DeviceType deviceType) {
    final actions =
        isShopOwner ? _getShopOwnerActions() : _getCustomerActions();

    final crossAxisCount = deviceType == DeviceType.mobile ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionCard(
          icon: action['icon'],
          title: action['title'],
          color: action['color'],
          badgeCount: action['badgeCount'],
          onTap: action['onTap'],
        );
      },
    );
  }

  List<Map<String, dynamic>> _getShopOwnerActions() {
    return [
      {
        'icon': Icons.add_business,
        'title': 'Add Product',
        'color': Colors.blue,
        'badgeCount': 0,
        'onTap': () {
          // Navigate to add product
        },
      },
      {
        'icon': Icons.inventory,
        'title': 'Manage Stock',
        'color': Colors.orange,
        'badgeCount': 0,
        'onTap': () {
          // Navigate to inventory
        },
      },
      {
        'icon': Icons.people,
        'title': 'Customers',
        'color': Colors.teal,
        'badgeCount': 0,
        'onTap': () {
          // Navigate to customers
        },
      },
      {
        'icon': Icons.analytics,
        'title': 'Reports',
        'color': Colors.purple,
        'badgeCount': 0,
        'onTap': () {
          // Navigate to reports
        },
      },
      {
        'icon': Icons.receipt_long,
        'title': 'Orders',
        'color': Colors.indigo,
        'badgeCount': 5, // Mock data
        'onTap': onOrdersTap,
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'color': Colors.grey,
        'badgeCount': 0,
        'onTap': () {
          // Navigate to settings
        },
      },
    ];
  }

  List<Map<String, dynamic>> _getCustomerActions() {
    return [
      {
        'icon': Icons.shopping_bag,
        'title': 'Browse',
        'color': Colors.blue,
        'badgeCount': 0,
        'onTap': () {
          // Navigate to products
        },
      },
      {
        'icon': Icons.receipt_long,
        'title': 'My Orders',
        'color': Colors.green,
        'badgeCount': 2, // Mock data
        'onTap': onOrdersTap,
      },
      {
        'icon': Icons.favorite,
        'title': 'Wishlist',
        'color': Colors.red,
        'badgeCount': 3, // Mock data
        'onTap': onWishlistTap,
      },
      {
        'icon': Icons.chat,
        'title': 'AI Assistant',
        'color': Colors.purple,
        'badgeCount': 0,
        'onTap': () {
          // Navigate to AI assistant
        },
      },
      {
        'icon': Icons.shopping_cart,
        'title': 'Cart',
        'color': Colors.orange,
        'badgeCount': cartItemCount,
        'onTap': onCartTap,
      },
      {
        'icon': Icons.support,
        'title': 'Support',
        'color': Colors.teal,
        'badgeCount': 0,
        'onTap': () {
          // Navigate to support
        },
      },
    ];
  }
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final int badgeCount;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.surface
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                      : AppColors.onSurface.withValues(alpha: 0.2),
                ),
                boxShadow: themeProvider.isGlassyMode
                    ? null
                    : [
                        BoxShadow(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                              : AppColors.onSurface.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: 28,
                        color: widget.color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface
                              : AppColors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // Badge
                  if (widget.badgeCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          widget.badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
