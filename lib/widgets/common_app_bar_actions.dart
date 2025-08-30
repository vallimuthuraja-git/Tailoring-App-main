import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/theme_constants.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/cart/cart_screen.dart';

class CommonAppBarActions extends StatefulWidget {
  final bool showLogout;
  final bool showCart;
  final List<Widget>? additionalActions;

  const CommonAppBarActions({
    super.key,
    this.showLogout = true,
    this.showCart = true,
    this.additionalActions,
  });

  @override
  State<CommonAppBarActions> createState() => _CommonAppBarActionsState();
}

class _CommonAppBarActionsState extends State<CommonAppBarActions> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, CartProvider>(
      builder: (context, themeProvider, cartProvider, child) {
        final iconColor = themeProvider.isDarkMode
            ? DarkAppColors.onSurface
            : AppColors.onSurface;

        final actions = <Widget>[];

        // Add cart icon with badge
        if (widget.showCart) {
          actions.add(
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart, color: iconColor),
                  onPressed: () => _navigateToCart(context),
                  tooltip: 'View Cart',
                ),
                if (cartProvider.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cartProvider.itemCount.toString(),
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
          );
        }

        // Add logout icon
        if (widget.showLogout) {
          actions.add(
            IconButton(
              icon: Icon(Icons.logout, color: iconColor),
              onPressed: () => _showLogoutDialog(context),
              tooltip: 'Logout',
            ),
          );
        }

        // Add any additional actions
        if (widget.additionalActions != null) {
          actions.addAll(widget.additionalActions!);
        }

        return Row(
          children: actions,
        );
      },
    );
  }
}