import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:carousel_slider/carousel_slider.dart'; // Removed to avoid import conflict
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailsPage extends StatelessWidget {
  final dynamic product;
  const ProductDetailsPage({required this.product, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          SizedBox(height: 16),
          ReviewsSection(productId: product['id']),
          SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(Icons.add_shopping_cart),
            label: Text(
              'إضافة إلى السلة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              // TODO: إضافة المنتج للسلة
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تمت إضافة المنتج للسلة!')),
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
    Key? key,
    this.categoryId,
    this.price,
    this.excludeId,
  }) : super(key: key);
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
    setState(() => loading = true);
    final response = await Supabase.instance.client
        .from('products')
        .select()
        .eq('category_id', widget.categoryId.toString())
        .neq('id', widget.excludeId.toString())
        .limit(6);
    setState(() {
      products = response;
      loading = false;
    });
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

class ReviewsSection extends StatefulWidget {
  final int productId;
  const ReviewsSection({Key? key, required this.productId}) : super(key: key);
  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  List<dynamic> reviews = [];
  bool loading = true;
  int rating = 5;
  final TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => loading = true);
    final response = await Supabase.instance.client
        .from('reviews')
        .select()
        .eq('product_id', widget.productId);
    setState(() {
      reviews = response;
      loading = false;
    });
  }

  Future<void> _addReview() async {
    if (reviewController.text.isEmpty) return;
    await Supabase.instance.client.from('reviews').insert({
      'product_id': widget.productId,
      'user': 'مستخدم', // يمكن ربطه بالمستخدم الحالي
      'comment': reviewController.text,
      'rating': rating,
    });
    reviewController.clear();
    rating = 5;
    _fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المراجعات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: reviews
                    .map(
                      (r) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < (r['rating'] ?? 0)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                          ),
                          title: Text(
                            r['user'] ?? 'مستخدم',
                            style: GoogleFonts.cairo(),
                          ),
                          subtitle: Text(
                            r['comment'] ?? '',
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
        const SizedBox(height: 12),
        Text(
          'أضف مراجعتك:',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        Row(
          children: List.generate(
            5,
            (i) => IconButton(
              icon: Icon(
                i < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => setState(() => rating = i + 1),
            ),
          ),
        ),
        TextField(
          controller: reviewController,
          decoration: InputDecoration(hintText: 'اكتب مراجعتك هنا...'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: _addReview,
          child: Text('إرسال', style: GoogleFonts.cairo()),
        ),
      ],
    );
  }
}

// ...existing code...
