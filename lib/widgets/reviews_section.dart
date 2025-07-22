import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'review_form.dart';

/// قسم عرض التقييمات لمعرف المنتج المحدد
class ReviewsSection extends StatefulWidget {
  final String productId;
  const ReviewsSection({Key? key, required this.productId}) : super(key: key);

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  bool _loading = true;
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _loading = true);
    try {
      final response = await Supabase.instance.client
          .from('product_reviews')
          .select('rating, comment, created_at')
          .eq('product_id', widget.productId);
      final List data = response as List? ?? [];
      double sum = 0;
      final reviews = data
          .map<Map<String, dynamic>>(
            (e) => {
              'rating': e['rating'],
              'comment': e['comment'],
              'date': (e['created_at'] as String).split('T').first,
            },
          )
          .toList();
      for (var r in reviews) {
        sum += (r['rating'] as int);
      }
      setState(() {
        _reviews = reviews;
        _averageRating = reviews.isNotEmpty ? sum / reviews.length : 0;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التقييمات',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_averageRating > 0)
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < _averageRating.round() ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (_reviews.isEmpty) const Text('لا توجد تقييمات بعد'),
        ..._reviews.map(
          (r) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < (r['rating'] as int) ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
              title: Text(r['comment'] ?? ''),
              subtitle: Text(r['date'] ?? ''),
            ),
          ),
        ),
      ],
    );
  }
}
