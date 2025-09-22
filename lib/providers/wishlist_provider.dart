// Wishlist Provider for Managing Customer Favorites
// Handles wishlist CRUD operations, offline sync, and user preferences

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart' as auth;

class WishlistProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<String> _wishlistServiceIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<String> get wishlistServiceIds => _wishlistServiceIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check if product is in wishlist
  bool isProductInWishlist(String productId) {
    return _wishlistServiceIds.contains(productId);
  }

  // Backward compatibility
  bool isServiceInWishlist(String serviceId) {
    return isProductInWishlist(serviceId);
  }

  // Get current user ID
  String? get _userId => auth.AuthService().currentUser?.uid;

  // Add service to wishlist
  Future<bool> addToWishlist(String serviceId) async {
    if (_wishlistServiceIds.contains(serviceId)) {
      return true; // Already in wishlist
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add to local list immediately for optimistic update
      _wishlistServiceIds.add(serviceId);
      notifyListeners();

      // Update Firestore - use batch to set/create document
      await _firebaseService.batchWrite([
        {
          'type': 'set',
          'collection': 'wishlists',
          'docId': userId,
          'data': {
            'userId': userId,
            'services': _wishlistServiceIds,
            'createdAt': DateTime.now(),
            'updatedAt': DateTime.now(),
          }
        }
      ]);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Revert optimistic update on error
      _wishlistServiceIds.remove(serviceId);
      _isLoading = false;
      _errorMessage = 'Failed to add to wishlist: $e';
      notifyListeners();
      return false;
    }
  }

  // Remove service from wishlist
  Future<bool> removeFromWishlist(String serviceId) async {
    if (!_wishlistServiceIds.contains(serviceId)) {
      return true; // Not in wishlist
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Remove from local list immediately for optimistic update
      _wishlistServiceIds.remove(serviceId);
      notifyListeners();

      // Update Firestore
      await _firebaseService.updateDocument('wishlists', userId, {
        'services': _wishlistServiceIds,
        'updatedAt': DateTime.now(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Revert optimistic update on error
      _wishlistServiceIds.add(serviceId);
      _isLoading = false;
      _errorMessage = 'Failed to remove from wishlist: $e';
      notifyListeners();
      return false;
    }
  }

  // Toggle service in wishlist
  Future<bool> toggleWishlist(String serviceId) async {
    if (isServiceInWishlist(serviceId)) {
      return await removeFromWishlist(serviceId);
    } else {
      return await addToWishlist(serviceId);
    }
  }

  // Load user's wishlist from Firestore
  Future<void> loadWishlist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = auth.AuthService().currentUser?.uid;
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final docSnapshot =
          await _firebaseService.getDocument('wishlists', userId);
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        _wishlistServiceIds = List<String>.from(data['services'] ?? []);
      } else {
        _wishlistServiceIds = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load wishlist: $e';
      notifyListeners();
    }
  }

  // Clear wishlist
  Future<bool> clearWishlist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = auth.AuthService().currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Clear local list
      _wishlistServiceIds.clear();
      notifyListeners();

      // Update Firestore
      await _firebaseService.updateDocument('wishlists', userId, {
        'services': [],
        'updatedAt': DateTime.now(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Revert local changes
      await loadWishlist();
      _isLoading = false;
      _errorMessage = 'Failed to clear wishlist: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get count of items in wishlist
  int get wishlistCount => _wishlistServiceIds.length;
}
