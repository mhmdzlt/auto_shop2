import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PromotionalBannerSection extends StatelessWidget {
  final List<Promotion> promotions;

  const PromotionalBannerSection({super.key, required this.promotions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: promotions.length,
      itemBuilder: (_, i) {
        final promo = promotions[i];
        return GestureDetector(
          onTap: () => launchUrl(Uri.parse(promo.link)),
          child: Image.network(promo.imageUrl),
        );
      },
    );
  }
}

class Promotion {
  final String title;
  final String imageUrl;
  final String link;

  const Promotion({
    required this.title,
    required this.imageUrl,
    required this.link,
  });
}
