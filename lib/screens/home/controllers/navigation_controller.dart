import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../models/product_models.dart';
import '../../../models/service.dart';
import '../../services/service_catalog_screen.dart';
import '../../orders/order_history_screen.dart';
import '../../cart/cart_screen.dart';
import '../../ai/ai_assistance_screen.dart';

class NavigationController {
  void navigateToProducts(BuildContext context) {
    debugdebugPrint('[DEBUG] NavigationController: Navigating to products');
    try {
      debugdebugPrint(
          '[DEBUG] NavigationController: Would navigate to ModernProductCatalogScreen, but class import failed');
      Navigator.pushNamed(context, '/catalog');
      debugdebugPrint(
          '[DEBUG] NavigationController: Successfully navigated to products');
    } catch (e) {
      debugdebugPrint(
          '[DEBUG] NavigationController: Error navigating to products: $e');
    }
  }

  void navigateToServices(BuildContext context) {
    debugdebugPrint('[DEBUG] NavigationController: Navigating to services');
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ServiceCatalogScreen()),
      );
      debugdebugPrint(
          '[DEBUG] NavigationController: Successfully navigated to services');
    } catch (e) {
      debugdebugPrint(
          '[DEBUG] NavigationController: Error navigating to services: $e');
    }
  }

  void navigateToOrders(BuildContext context) {
    debugdebugPrint('[DEBUG] NavigationController: Navigating to orders');
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
      );
      debugdebugPrint(
          '[DEBUG] NavigationController: Successfully navigated to orders');
    } catch (e) {
      debugdebugPrint(
          '[DEBUG] NavigationController: Error navigating to orders: $e');
    }
  }

  void navigateToCart(BuildContext context) {
    debugdebugPrint('[DEBUG] NavigationController: Navigating to cart');
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
      debugdebugPrint(
          '[DEBUG] NavigationController: Successfully navigated to cart');
    } catch (e) {
      debugdebugPrint('[DEBUG] NavigationController: Error navigating to cart: $e');
    }
  }

  void navigateToWishlist(BuildContext context) {
    debugdebugPrint(
        '[DEBUG] NavigationController: Navigating to wishlist via named route /wishlist');
    try {
      Navigator.pushNamed(context, '/wishlist');
      debugdebugPrint(
          '[DEBUG] NavigationController: Successfully navigated to wishlist');
    } catch (e) {
      debugdebugPrint(
          '[DEBUG] NavigationController: Error navigating to wishlist: $e');
    }
  }

  void navigateToAIAssistant(BuildContext context) {
    debugdebugPrint('[DEBUG] NavigationController: Navigating to AI assistant');
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AIAssistanceScreen()),
      );
      debugdebugPrint(
          '[DEBUG] NavigationController: Successfully navigated to AI assistant');
    } catch (e) {
      debugdebugPrint(
          '[DEBUG] NavigationController: Error navigating to AI assistant: $e');
    }
  }

  void navigateToCategory(BuildContext context, Map<String, dynamic> category) {
    // Navigate based on category type
    switch (category['name']) {
      case 'Products':
        navigateToProducts(context);
        break;
      case 'Services':
        navigateToServices(context);
        break;
      case 'Orders':
        navigateToOrders(context);
        break;
      default:
        // Navigate to filtered catalog
        debugdebugPrint(
            '[DEBUG] NavigationController: Navigating to category ${category['name']}');
        try {
          debugdebugPrint(
              '[DEBUG] NavigationController: Would navigate to ModernProductCatalogScreen for category ${category['name']}, but class import failed');
          Navigator.pushNamed(context, '/catalog');
          debugdebugPrint(
              '[DEBUG] NavigationController: Successfully navigated to category ${category['name']}');
        } catch (e) {
          debugdebugPrint(
              '[DEBUG] NavigationController: Error navigating to category: $e');
        }
    }
  }

  void navigateToProduct(BuildContext context, Product product) {
    // Navigate to product detail screen
    Navigator.pushNamed(context, '/product/${product.id}');
  }

  void navigateToService(BuildContext context, Service service) {
    // Navigate to service detail screen
    Navigator.pushNamed(context, '/service/${service.id}');
  }

  void navigateToActivity(BuildContext context, Map<String, dynamic> activity) {
    // Navigate based on activity type
    switch (activity['type']) {
      case 'order':
        navigateToOrders(context);
        break;
      case 'review':
        // Navigate to reviews
        break;
      case 'product':
        navigateToProducts(context);
        break;
      default:
        break;
    }
  }

  void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  void dispose() {
    // No resources to dispose for now
  }
}


