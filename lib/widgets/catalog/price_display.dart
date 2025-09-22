import 'package:flutter/material.dart';
import '../../../models/product_models.dart';

class PriceDisplay extends StatelessWidget {
  final Product product;

  const PriceDisplay({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price - Bounded text
        Expanded(
          child: Text(
            product.formattedPrice,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Stock indicator - Fixed small size
        if (product.stockCount <= 5 && product.stockCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '${product.stockCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
