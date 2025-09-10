// Review Model for Customer Service Reviews and Ratings
// Handles user feedback, ratings, and service quality assessment

import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String serviceId;
  final String userId;
  final String userName;
  final double rating; // 1-5 stars
  final String title;
  final String comment;
  final List<String> photos; // Optional photo URLs
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, bool> aspects; // Quality aspects rated (fit, fabric, timeliness, etc.)
  final bool verified; // Whether the reviewer used the service
  final Map<String, dynamic> additionalData;

  const Review({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.title,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
    this.aspects = const {},
    this.verified = false,
    this.additionalData = const {},
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      aspects: Map<String, bool>.from(json['aspects'] ?? {}),
      verified: json['verified'] ?? false,
      additionalData: Map<String, dynamic>.from(json['additionalData'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'title': title,
      'comment': comment,
      'photos': photos,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'aspects': aspects,
      'verified': verified,
      'additionalData': additionalData,
    };
  }

  Review copyWith({
    String? id,
    String? serviceId,
    String? userId,
    String? userName,
    double? rating,
    String? title,
    String? comment,
    List<String>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, bool>? aspects,
    bool? verified,
    Map<String, dynamic>? additionalData,
  }) {
    return Review(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      aspects: aspects ?? this.aspects,
      verified: verified ?? this.verified,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Helper methods
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  bool get isRecent => DateTime.now().difference(createdAt).inDays < 7;
  bool get isHelpful => rating >= 4.0;
}

class ReviewSummary {
  final String serviceId;
  final double averageRating;
  final int totalReviews;
  final Map<String, double> aspectRatings; // Average ratings for different aspects
  final Map<int, int> ratingDistribution; // Count of reviews by rating (1-5 stars)
  final List<Review> recentReviews;

  const ReviewSummary({
    required this.serviceId,
    required this.averageRating,
    required this.totalReviews,
    required this.aspectRatings,
    required this.ratingDistribution,
    required this.recentReviews,
  });

  factory ReviewSummary.fromReviews(String serviceId, List<Review> reviews) {
    if (reviews.isEmpty) {
      return ReviewSummary(
        serviceId: serviceId,
        averageRating: 0.0,
        totalReviews: 0,
        aspectRatings: {},
        ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        recentReviews: [],
      );
    }

    // Calculate average rating
    final totalRating = reviews.map((r) => r.rating).reduce((a, b) => a + b);
    final averageRating = totalRating / reviews.length;

    // Calculate rating distribution
    final ratingDistribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      ratingDistribution[i] = reviews.where((r) => r.rating.round() == i).length;
    }

    // Calculate aspect ratings (sample implementation)
    final aspectRatings = <String, double>{};
    final aspects = ['quality', 'timeliness', 'communication', 'value', 'fit'];
    for (final aspect in aspects) {
      final aspectReviews = reviews.where((r) => r.aspects.containsKey(aspect));
      if (aspectReviews.isNotEmpty) {
        final total = aspectReviews.map((r) => r.rating).reduce((a, b) => a + b);
        aspectRatings[aspect] = total / aspectReviews.length;
      }
    }

    // Get recent reviews (last 10, sorted by date)
    final sortedReviews = reviews.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentReviews = sortedReviews.take(10).toList();

    return ReviewSummary(
      serviceId: serviceId,
      averageRating: averageRating,
      totalReviews: reviews.length,
      aspectRatings: aspectRatings,
      ratingDistribution: ratingDistribution,
      recentReviews: recentReviews,
    );
  }

  String get averageRatingString => averageRating.toStringAsFixed(1);
  String get totalReviewsString => '$totalReviews review${totalReviews != 1 ? 's' : ''}';

  // Get percentage of reviews that are positive (4+ stars)
  double get positiveReviewPercentage {
    if (totalReviews == 0) return 0.0;
    final positiveReviews = ratingDistribution[4]! + ratingDistribution[5]!;
    return (positiveReviews / totalReviews) * 100;
  }

  // Get the most common rating
  int get mostCommonRating {
    return ratingDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}