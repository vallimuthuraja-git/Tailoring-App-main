import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CartProvider, AuthProvider, ThemeProvider>(
      builder: (context, cartProvider, authProvider, themeProvider, child) {
        final cartItems = cartProvider.items;
        final user = authProvider.userProfile;
        final isLoggedIn = authProvider.isAuthenticated;

        // Pre-fill user information if logged in
        _nameController.text = user?.displayName ?? '';
        _emailController.text = user?.email ?? '';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Checkout'),
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
          ),
          body: cartItems.isEmpty
              ? _buildEmptyCart(themeProvider)
              : _buildCheckoutContent(context, cartProvider, themeProvider, isLoggedIn),
          bottomNavigationBar: cartItems.isEmpty
              ? null
              : _buildBottomBar(context, cartProvider, themeProvider, isLoggedIn),
        );
      },
    );
  }

  Widget _buildEmptyCart(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                : AppColors.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some items to proceed to checkout',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutContent(BuildContext context, CartProvider cartProvider, ThemeProvider themeProvider, bool isLoggedIn) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Card
          _buildOrderSummaryCard(cartProvider, themeProvider),

          const SizedBox(height: 20),

          // Customer Information Card
          _buildCustomerInfoCard(themeProvider, isLoggedIn),

          const SizedBox(height: 20),

          // Payment Summary Card
          _buildPaymentSummary(cartProvider, themeProvider),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(CartProvider cartProvider, ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${cartProvider.itemCount} items',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                      : AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Cart items
          ...cartProvider.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Product Image
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: themeProvider.isDarkMode ? DarkAppColors.background : AppColors.background,
                      ),
                      child: item.product.imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrls.first,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              ),
                            )
                          : Icon(
                              Icons.inventory_2,
                              size: 20,
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                                  : AppColors.onSurface.withValues(alpha: 0.3),
                            ),
                    ),
                    const SizedBox(width: 12),

                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${item.quantity}x ₹${item.product.basePrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                                  : AppColors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Item Total
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 16),
          const Divider(),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
              ),
              Text(
                '₹${cartProvider.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
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

  Widget _buildCustomerInfoCard(ThemeProvider themeProvider, bool isLoggedIn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Customer Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Full Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: themeProvider.isDarkMode ? DarkAppColors.background : AppColors.background,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: themeProvider.isDarkMode ? DarkAppColors.background : AppColors.background,
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Email (Optional)
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: themeProvider.isDarkMode ? DarkAppColors.background : AppColors.background,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            // Delivery Address
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Delivery Address *',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: themeProvider.isDarkMode ? DarkAppColors.background : AppColors.background,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter delivery address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(CartProvider cartProvider, ThemeProvider themeProvider) {
    final summary = cartProvider.getCartSummary();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment,
                color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                      : AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '₹${summary['totalAmount'].toStringAsFixed(0)}',
                style: TextStyle(
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
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                      : AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '₹${summary['estimatedAdvance'].toStringAsFixed(0)}',
                style: TextStyle(
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
                'Remaining Balance',
                style: TextStyle(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                      : AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '₹${summary['estimatedRemaining'].toStringAsFixed(0)}',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total to Pay Now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                ),
              ),
              Text(
                '₹${summary['estimatedAdvance'].toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
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

  Widget _buildBottomBar(BuildContext context, CartProvider cartProvider, ThemeProvider themeProvider, bool isLoggedIn) {
    final summary = cartProvider.getCartSummary();

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
          // Total Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advance Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
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
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back to Cart'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isPlacingOrder ? null : () => _placeOrder(context, cartProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                    foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
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

  Future<void> _placeOrder(BuildContext context, CartProvider cartProvider) async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Convert cart items to order items
      final orderItems = cartProvider.items.map((cartItem) {
        return OrderItem.fromJson(cartItem.toOrderItemData());
      }).toList();

      final success = await cartProvider.placeOrderFromCart(
        context: context,
        customerId: authProvider.user?.uid ?? 'customer_${DateTime.now().millisecondsSinceEpoch}',
        orderProvider: orderProvider,
        measurements: {}, // Can be extended for measurements
        specialInstructions: null, // Can be added in future
        orderImages: [], // Can be added in future
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.of(context).pop(); // Go back to home or orders page
        Navigator.of(context).pop(); // Go back to cart
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cartProvider.errorMessage ?? 'Failed to place order')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    } finally {
      setState(() => _isPlacingOrder = false);
    }
  }
}