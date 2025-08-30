import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<CartProvider, AuthProvider, ThemeProvider>(
      builder: (context, cartProvider, authProvider, themeProvider, child) {
        final cartItems = cartProvider.items;
        final isLoggedIn = authProvider.isAuthenticated;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Shopping Cart'),
            backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
            elevation: 0,
            iconTheme: IconThemeData(
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
            titleTextStyle: TextStyle(
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            actions: [
              if (cartItems.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () => _showClearCartDialog(context, cartProvider),
                  tooltip: 'Clear Cart',
                ),
            ],
          ),
          body: cartItems.isEmpty
              ? _buildEmptyCart(themeProvider)
              : _buildCartContent(context, cartProvider, themeProvider, isLoggedIn),
          bottomNavigationBar: cartItems.isEmpty
              ? null
              : _buildBottomBar(context, cartProvider, themeProvider, isLoggedIn),
        );
      },
    );
  }

  Widget _buildEmptyCart(ThemeProvider themeProvider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha: 0.1),
                    (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary).withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary.withValues(alpha: 0.7)
                    : AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add some products to get started!',
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Continue Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartProvider cartProvider, ThemeProvider themeProvider, bool isLoggedIn) {
    return Column(
      children: [
        // Cart items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartProvider.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return _CartItemCard(
                item: item,
                onQuantityChanged: (newQuantity) => _updateQuantity(cartProvider, item.id, newQuantity),
                onRemove: () => _removeItem(cartProvider, item.id),
                themeProvider: themeProvider,
              );
            },
          ),
        ),

        // Cart summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
            border: Border(
              top: BorderSide(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                    : AppColors.onSurface.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: _buildCartSummary(cartProvider, themeProvider),
        ),
      ],
    );
  }

  Widget _buildCartSummary(CartProvider cartProvider, ThemeProvider themeProvider) {
    final summary = cartProvider.getCartSummary();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Items',
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '${summary['totalQuantity']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Advance Payment (30%)',
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '₹${summary['estimatedAdvance'].toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Remaining Amount',
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '₹${summary['estimatedRemaining'].toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
              : AppColors.onSurface.withValues(alpha: 0.1),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Grand Total',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
              ),
            ),
            Text(
              '₹${summary['totalAmount'].toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, CartProvider cartProvider, ThemeProvider themeProvider, bool isLoggedIn) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLoggedIn)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please log in to place an order',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!isLoggedIn) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue Shopping'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: isLoggedIn ? () => _proceedToCheckout(context, cartProvider) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoggedIn
                        ? (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary)
                        : Colors.grey,
                    foregroundColor: isLoggedIn
                        ? (themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary)
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateQuantity(CartProvider cartProvider, String itemId, int newQuantity) {
    cartProvider.updateQuantity(itemId, newQuantity);
  }

  void _removeItem(CartProvider cartProvider, String itemId) {
    cartProvider.removeFromCart(itemId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removed from cart')),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, CartProvider cartProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;
  final ThemeProvider themeProvider;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
              : AppColors.onSurface.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: themeProvider.isDarkMode ? DarkAppColors.background : AppColors.background,
            ),
            child: item.product.imageUrls.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.product.imageUrls.first,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    ),
                  )
                : Icon(
                    Icons.inventory_2,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                        : AppColors.onSurface.withValues(alpha: 0.3),
                  ),
          ),
          const SizedBox(width: 16),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.product.basePrice.toStringAsFixed(0)} each',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                        : AppColors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (item.customizations.isNotEmpty)
                  Text(
                    '${item.customizations.length} customization${item.customizations.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),

          // Quantity and Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Remove button
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 20),
                color: Colors.red.shade400,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              // Quantity controls
              Row(
                children: [
                  IconButton(
                    onPressed: item.quantity > 1 ? () => onQuantityChanged(item.quantity - 1) : null,
                    icon: const Icon(Icons.remove, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      item.quantity.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onQuantityChanged(item.quantity + 1),
                    icon: const Icon(Icons.add, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              // Item total
              Text(
                '₹${item.totalPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
