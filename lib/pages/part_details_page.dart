import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/part.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import 'login_page.dart';
import '../pages/cart_page.dart';

class PartDetailsPage extends StatelessWidget {
  final Part part;
  const PartDetailsPage({super.key, required this.part});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(part.name),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final favorites = ref.watch(favoritesProvider.notifier);
              final isFav = favorites.contains(part.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  if (isFav) {
                    favorites.remove(part.id);
                  } else {
                    favorites.add(part);
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (part.imageUrl != null && part.imageUrl!.isNotEmpty)
              Center(
                child: Image.network(
                  part.imageUrl!,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              part.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              part.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 18),
            Text(
              'السعر: ${part.price} د.ع',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF1978E5),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Consumer(
              builder: (context, ref, _) {
                final isInCart = ref
                    .watch(cartProvider)
                    .any((item) => item.productId == part.id);
                return Column(
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(
                        isInCart
                            ? Icons.shopping_cart
                            : Icons.add_shopping_cart,
                      ),
                      label: Text(isInCart ? 'في السلة' : 'أضف إلى السلة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1978E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        final cart = ref.read(cartProvider.notifier);
                        if (isInCart) {
                          cart.removeProduct(part.id);
                        } else {
                          // إنشاء منتج مؤقت لإضافته للسلة
                          final productData = {
                            'id': part.id,
                            'name': part.name,
                            'price': part.price,
                            'image_url': part.imageUrl ?? '',
                          };
                          cart.addProduct(productData);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1978E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        final user = Supabase.instance.client.auth.currentUser;
                        if (user == null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginPage(
                                onSuccess: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        } else {
                          // أضف هنا الكود الذي تريد تنفيذه إذا كان المستخدم مسجلاً الدخول
                        }
                      },
                      child: const Text(
                        'شراء الآن',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
