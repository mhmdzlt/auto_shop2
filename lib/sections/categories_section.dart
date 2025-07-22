import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'إلكترونيات', 'icon': 'assets/icons/electronics.svg'},
    {'name': 'ملابس', 'icon': 'assets/icons/clothes.svg'},
    {'name': 'ألعاب', 'icon': 'assets/icons/toys.svg'},
    {'name': 'منزلية', 'icon': 'assets/icons/home.svg'},
    {'name': 'سيارات', 'icon': 'assets/icons/car.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/categories',
                arguments: cat['name'],
              );
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  child: Icon(
                    Icons.category,
                    size: 32,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['name'] as String,
                  style: GoogleFonts.cairo(fontSize: 13),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
