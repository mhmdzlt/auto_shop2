import 'package:flutter/material.dart';
import '../services/rating_service.dart';

class ProductCard extends StatelessWidget {
  final String productId;
  final String name;
  final String price;
  final String image;

  const ProductCard({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1a1a1a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (ctx, err, stack) => const Icon(
                    Icons.broken_image,
                    color: Colors.white24,
                    size: 48,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // متوسط التقييم
            FutureBuilder<double>(
              future: RatingService.getAverageRating(productId),
              builder: (context, snapshot) {
                final avg = snapshot.data ?? 0.0;
                if (avg == 0) return const SizedBox.shrink();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < avg.round() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      avg.toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              "$price \$",
              style: const TextStyle(
                color: Colors.indigo,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
