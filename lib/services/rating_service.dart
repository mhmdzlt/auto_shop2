import 'package:supabase_flutter/supabase_flutter.dart';

/// خدمة لحساب متوسط تقييم المنتج
class RatingService {
  /// جلب متوسط تقييم المنتج من Supabase
  static Future<double> getAverageRating(String productId) async {
    final response = await Supabase.instance.client
        .from('product_reviews')
        .select('rating')
        .eq('product_id', productId);

    final data = response as List<dynamic>?;
    if (data == null || data.isEmpty) return 0.0;

    // استخراج التقييمات وحساب المتوسط
    final ratings = data.map<int>((e) => e['rating'] as int).toList();
    final sum = ratings.reduce((a, b) => a + b);
    final avg = sum / ratings.length;
    return double.parse(avg.toStringAsFixed(1));
  }
}
