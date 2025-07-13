import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? ''),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              product['image_url'] ?? '',
              height: 210,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            product['name'] ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            product['description'] ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 22),
          Text(
            "${product['price'] ?? '--'} د.ع",
            style: const TextStyle(fontSize: 21, color: Color(0xFF1978E5), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 26),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF1978E5),
            ),
            onPressed: () async {
              // أضف المنتج للسلة
              // يمكنك إنشاء كلاس سلة متكامل لاحقاً (الآن اختصاراً فقط Alert)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة للسلة')));
            },
            icon: const Icon(Icons.add_shopping_cart_outlined),
            label: const Text('إضافة إلى السلة'),
          ),
        ],
      ),
    );
  }
}
