import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:carousel_slider/carousel_slider.dart'; // Removed to avoid import conflict
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/cart_provider.dart';
import '../widgets/reviews_section.dart';

class ProductDetailsPage extends ConsumerWidget {
  final dynamic product;
  const ProductDetailsPage({required this.product, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> images = product['images'] ?? [product['image']];
    final specs = product['specs'] ?? {};
    // سيتم تحميل المراجعات من Supabase
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? '', style: GoogleFonts.cairo()),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                final img = images[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    img,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Text(
            product['name'] ?? '',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          SizedBox(height: 8),
          Text(
            '${product['price'] ?? ''} د.ع',
            style: GoogleFonts.cairo(color: Colors.green, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            product['description'] ?? '',
            style: GoogleFonts.cairo(fontSize: 15),
          ),
          SizedBox(height: 16),
          Text(
            'المواصفات',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          ...specs.entries.map(
            (e) => ListTile(
              title: Text(e.key, style: GoogleFonts.cairo()),
              subtitle: Text(e.value.toString(), style: GoogleFonts.cairo()),
            ),
          ),
          const SizedBox(height: 16),
          ReviewForm(productId: product['id']?.toString() ?? ''),
          const SizedBox(height: 16),
          ReviewsSection(productId: product['id']?.toString() ?? ''),
          SizedBox(height: 24),
          Consumer(
            builder: (context, ref, child) {
              final cartItems = ref.watch(cartProvider);
              final isInCart = cartItems.any(
                (item) => item.productId == product['id']?.toString(),
              );

              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? Colors.green : Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                icon: Icon(
                  isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                ),
                label: Text(
                  isInCart ? 'موجود في السلة' : 'إضافة إلى السلة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (isInCart) {
                    // الانتقال إلى صفحة السلة
                    Navigator.pushNamed(context, '/cart');
                  } else {
                    // إضافة المنتج للسلة
                    final cartNotifier = ref.read(cartProvider.notifier);
                    final productData = {
                      'id': product['id']?.toString() ?? '',
                      'name': product['name'] ?? '',
                      'price': product['price']?.toString() ?? '0',
                      'image_url':
                          (product['images'] != null &&
                              product['images'].isNotEmpty)
                          ? product['images'][0]
                          : product['image'] ?? '',
                    };

                    cartNotifier.addProduct(productData);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تمت إضافة ${product['name']} إلى السلة!',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 32),
          SimilarProductsSection(
            categoryId: product['category_id'],
            price: product['price'],
            excludeId: product['id'],
          ),
        ],
      ),
    );
  }
}

class SimilarProductsSection extends StatefulWidget {
  final Object? categoryId;
  final double? price;
  final Object? excludeId;
  const SimilarProductsSection({
    super.key,
    this.categoryId,
    this.price,
    this.excludeId,
  });
  @override
  State<SimilarProductsSection> createState() => _SimilarProductsSectionState();
}

class _SimilarProductsSectionState extends State<SimilarProductsSection> {
  List<dynamic> products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSimilar();
  }

  Future<void> _fetchSimilar() async {
    if (mounted) {
      setState(() => loading = true);
    }

    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .eq('category_id', widget.categoryId.toString())
          .neq('id', widget.excludeId.toString())
          .limit(6);

      if (mounted) {
        setState(() {
          products = response;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          products = [];
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || products.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'منتجات مشابهة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final p = products[i];
              return GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/product', arguments: p),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: p['image'] != null
                            ? Image.network(
                                p['image'],
                                height: 80,
                                width: 120,
                                fit: BoxFit.cover,
                              )
                            : Container(height: 80, color: Colors.grey[300]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] ?? '',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${p['price'] ?? ''} د.ع',
                              style: GoogleFonts.cairo(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ReviewForm extends StatefulWidget {
  final String productId;
  const ReviewForm({super.key, required this.productId});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final TextEditingController _controller = TextEditingController();
  double _rating = 0;

  void _submitReview() async {
    if (_controller.text.isEmpty || _rating == 0) return;

    try {
      await Supabase.instance.client.from('reviews').insert({
        'product_id': widget.productId,
        'user': 'مستخدم', // يمكن ربطه بالمستخدم الحالي
        'comment': _controller.text,
        'rating': _rating,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة مراجعتك!'),
          backgroundColor: Colors.green,
        ),
      );

      _controller.clear();
      setState(() {
        _rating = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء إضافة المراجعة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أضف مراجعتك',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'اكتب مراجعتك هنا...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('تقييمك:', style: GoogleFonts.cairo()),
            const SizedBox(width: 8),
            ...List.generate(
              5,
              (index) => IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border_outlined,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1.toDouble();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'إرسال المراجعة',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
