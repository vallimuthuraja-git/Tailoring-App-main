// Review Provider for Managing Service Reviews and Ratings
// Handles customer feedback, ratings, and reputation building

import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/firebase_service.dart';

class ReviewProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  final Map<String, List<Review>> _reviews = {}; // serviceId -> reviews
  final Map<String, ReviewSummary> _reviewSummaries =
      {}; // serviceId -> summary
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Review> getReviewsForService(String serviceId) {
    return _reviews[serviceId] ?? [];
  }

  ReviewSummary? getReviewSummary(String serviceId) {
    return _reviewSummaries[serviceId];
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load reviews for a specific service
  Future<void> loadReviewsForService(String serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _firebaseService.getCollection('reviews');
      final allReviews = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Review.fromJson(data);
      }).toList();

      // Filter reviews for this service
      final serviceReviews =
          allReviews.where((review) => review.serviceId == serviceId).toList();

      _reviews[serviceId] = serviceReviews;

      // Calculate and cache summary
      _reviewSummaries[serviceId] =
          ReviewSummary.fromReviews(serviceId, serviceReviews);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load reviews: $e';
      notifyListeners();
    }
  }

  // Add a new review
  Future<bool> addReview(Review review) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reviewData = review.toJson();
      reviewData.remove('id'); // Let Firestore generate ID

      final docRef = await _firebaseService.addDocument('reviews', reviewData);

      // Generate ID from Firestore response
      final newReview = review.copyWith(id: docRef.id);

      // Update local cache
      if (!_reviews.containsKey(review.serviceId)) {
        _reviews[review.serviceId] = [];
      }
      _reviews[review.serviceId]!.add(newReview);

      // Recalculate summary
      _reviewSummaries[review.serviceId] = ReviewSummary.fromReviews(
          review.serviceId, _reviews[review.serviceId]!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add review: $e';
      notifyListeners();
      return false;
    }
  }

  // Update existing review
  Future<bool> updateReview(
      String reviewId, Map<String, dynamic> updates) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.updateDocument('reviews', reviewId, updates);

      // Find and update local review
      for (final serviceId in _reviews.keys) {
        final reviewIndex =
            _reviews[serviceId]!.indexWhere((review) => review.id == reviewId);
        if (reviewIndex != -1) {
          final oldReview = _reviews[serviceId]![reviewIndex];
          final updatedReview = oldReview.copyWith(
            title: updates['title'] ?? oldReview.title,
            comment: updates['comment'] ?? oldReview.comment,
            rating: updates['rating']?.toDouble() ?? oldReview.rating,
            updatedAt: DateTime.now(),
          );

          _reviews[serviceId]![reviewIndex] = updatedReview;

          // Recalculate summary
          _reviewSummaries[serviceId] =
              ReviewSummary.fromReviews(serviceId, _reviews[serviceId]!);
          break;
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update review: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete review
  Future<bool> deleteReview(String reviewId, String serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.deleteDocument('reviews', reviewId);

      // Remove from local cache
      _reviews[serviceId]?.removeWhere((review) => review.id == reviewId);

      // Recalculate summary
      if (_reviews[serviceId] != null) {
        _reviewSummaries[serviceId] =
            ReviewSummary.fromReviews(serviceId, _reviews[serviceId]!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete review: $e';
      notifyListeners();
      return false;
    }
  }

  // Check if user has reviewed service
  bool hasUserReviewedService(String serviceId, String userId) {
    final serviceReviews = _reviews[serviceId];
    if (serviceReviews == null) return false;

    return serviceReviews.any((review) => review.userId == userId);
  }

  // Get user's review for a service
  Review? getUserReview(String serviceId, String userId) {
    final serviceReviews = _reviews[serviceId];
    if (serviceReviews == null) return null;

    return serviceReviews.firstWhere(
      (review) => review.userId == userId,
      orElse: () => Review(
        id: '',
        serviceId: serviceId,
        userId: userId,
        userName: '',
        rating: 0.0,
        title: '',
        comment: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  // Bulk load reviews for multiple services
  Future<void> loadReviewsForServices(List<String> serviceIds) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allReviewsPromises = serviceIds.map((serviceId) async {
        await loadReviewsForService(serviceId);
      });

      await Future.wait(allReviewsPromises);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load reviews: $e';
      notifyListeners();
    }
  }

  // Clear all cached data
  void clearCache() {
    _reviews.clear();
    _reviewSummaries.clear();
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get recent reviews across all services (for admin dashboard)
  List<Review> getRecentReviews({int limit = 20}) {
    final allReviews = _reviews.values.expand((reviews) => reviews).toList();

    allReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allReviews.take(limit).toList();
  }

  // Get review analytics
  Map<String, dynamic> getReviewAnalytics() {
    final allReviews = _reviews.values.expand((reviews) => reviews).toList();

    if (allReviews.isEmpty) {
      return {
        'totalReviews': 0,
        'averageRating': 0.0,
        'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        'recentReviews': 0,
        'topServices': [],
      };
    }

    final totalReviews = allReviews.length;
    final averageRating =
        allReviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews;

    final ratingDistribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      ratingDistribution[i] =
          allReviews.where((r) => r.rating.round() == i).length;
    }

    final recentReviews = allReviews.where((r) => r.isRecent).length;

    final serviceRatings = <String, double>{};
    for (final serviceId in _reviews.keys) {
      final summary = _reviewSummaries[serviceId];
      if (summary != null && summary.totalReviews > 0) {
        serviceRatings[serviceId] = summary.averageRating;
      }
    }

    final topServices = serviceRatings.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(5);

    return {
      'totalReviews': totalReviews,
      'averageRating': averageRating,
      'ratingDistribution': ratingDistribution,
      'recentReviews': recentReviews,
      'topServices': topServices,
    };
  }
}
