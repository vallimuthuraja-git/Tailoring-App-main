import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_models.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';

class RatingStars extends StatelessWidget {
  final Product product;

  const RatingStars({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Data validation: Check for valid rating data
    if (product.rating.averageRating <= 0 ||
        product.rating.averageRating.isNaN ||
        product.rating.reviewCount < 0) {
      return const SizedBox.shrink();
    }

    // Clamp rating to valid range (0-5)
    final clampedRating = product.rating.averageRating.clamp(0.0, 5.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          5,
          (index) => Icon(
            index < clampedRating.floor()
                ? Icons.star
                : index < clampedRating
                    ? Icons.star_half
                    : Icons.star_border,
            size: 10,
            color: Colors.amber[600],
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '${clampedRating.toStringAsFixed(1)} (${product.rating.reviewCount})',
          style: TextStyle(
            fontSize: 8,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                : AppColors.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
