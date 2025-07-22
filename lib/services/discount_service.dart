import 'package:auto_shop/models/discount.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscountService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Discount>> getActiveDiscounts() async {
    final response = await _supabase
        .from('discounts')
        .select()
        .eq('is_active', true)
        .lte('start_date', DateTime.now().toIso8601String())
        .gte('end_date', DateTime.now().toIso8601String())
        .execute();

    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    final data = response.data as List<dynamic>;
    return data.map((json) => Discount.fromJson(json)).toList();
  }

  Future<Discount?> getDiscountByCode(String code) async {
    final response = await _supabase
        .from('discounts')
        .select()
        .eq('code', code)
        .single()
        .execute();

    if (response.error != null) {
      return null;
    }

    return Discount.fromJson(response.data);
  }
}
