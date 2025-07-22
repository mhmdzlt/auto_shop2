/// خدمة الخصومات المحلية (Promo Code)
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/promo_code.dart';
import '../models/promo_code_usage.dart' as usage_model;

class PromoService {
  // Supabase client
  static final _supabase = Supabase.instance.client;
  static final List<Map<String, dynamic>> _availableCodes = [
    {
      'code': 'WELCOME10',
      'discount': 0.10, // 10%
      'freeShipping': false,
      'expires': DateTime(2025, 12, 31),
    },
    {
      'code': 'FREESHIP',
      'discount': 0.0,
      'freeShipping': true,
      'expires': DateTime(2025, 10, 1),
    },
  ];

  /// تحقق من صحة الكود وتاريخه
  static Map<String, dynamic>? validateCode(String inputCode) {
    final now = DateTime.now();
    final promo = _availableCodes.firstWhere(
      (e) => e['code'] == inputCode.toUpperCase(),
      orElse: () => {},
    );
    if (promo.isEmpty) return null;
    final expires = promo['expires'] as DateTime;
    if (now.isAfter(expires)) return null;
    return Map<String, dynamic>.from(promo);
  }

  /// التحقق من صحة كود الخصم وحساب قيمة الخصم
  static Future<PromoCodeValidationResult> validatePromoCode({
    required String code,
    required double orderAmount,
    String? userId,
  }) async {
    try {
      // البحث عن الكود في قاعدة البيانات
      final response = await Supabase.instance.client
          .from('promo_codes')
          .select()
          .eq('code', code.toUpperCase())
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        return PromoCodeValidationResult.invalid('كود الخصم غير صحيح');
      }

      final promoCode = PromoCode.fromJson(response);

      // التحقق من صحة التواريخ والحدود
      final validationError = promoCode.getValidationError(orderAmount, 0);
      if (validationError != null) {
        return PromoCodeValidationResult.invalid(validationError);
      }

      // التحقق من استخدام المستخدم للكود (إذا كان مسجل دخول)
      int userUsageCount = 0;
      if (userId != null) {
        final usageResponse = await _supabase
            .from('promo_code_usage')
            .select('id')
            .eq('promo_code_id', promoCode.id)
            .eq('user_id', userId);

        userUsageCount = usageResponse.length;

        if (userUsageCount >= promoCode.userUsageLimit) {
          return PromoCodeValidationResult.invalid(
            'لقد استخدمت هذا الكود من قبل',
          );
        }
      }

      // حساب قيمة الخصم
      final discountAmount = promoCode.calculateDiscount(orderAmount);

      return PromoCodeValidationResult.valid(
        promoCode: promoCode,
        discountAmount: discountAmount,
        userUsageCount: userUsageCount,
      );
    } catch (e) {
      debugPrint('Error validating promo code: $e');
      return PromoCodeValidationResult.invalid('حدث خطأ في التحقق من الكود');
    }
  }

  /// استخدام كود الخصم وتسجيل الاستخدام
  static Future<bool> usePromoCode({
    required String promoCodeId,
    required String userId,
    required double discountApplied,
    String? orderId,
  }) async {
    try {
      // تسجيل الاستخدام
      await _supabase.from('promo_code_usage').insert({
        'promo_code_id': promoCodeId,
        'user_id': userId,
        'order_id': orderId,
        'discount_applied': discountApplied,
        'used_at': DateTime.now().toIso8601String(),
      });

      // تحديث عداد الاستخدام في جدول الأكواد
      await _supabase.rpc(
        'increment_promo_code_usage',
        params: {'p_promo_code_id': promoCodeId},
      );

      return true;
    } catch (e) {
      debugPrint('Error using promo code: $e');
      return false;
    }
  }

  /// الحصول على أكواد الخصم المتاحة للمستخدم
  static Future<List<PromoCode>> getAvailablePromoCodes({
    String? userId,
    double? orderAmount,
  }) async {
    try {
      final response = await _supabase
          .from('promo_codes')
          .select()
          .eq('is_active', true)
          .gte('valid_until', DateTime.now().toIso8601String())
          .lte('valid_from', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      List<PromoCode> promoCodes = response
          .map<PromoCode>((json) => PromoCode.fromJson(json))
          .toList();

      // فلترة الأكواد بناءً على الحد الأدنى للطلب
      if (orderAmount != null) {
        promoCodes = promoCodes
            .where((code) => orderAmount >= code.minOrderAmount)
            .toList();
      }

      // فلترة الأكواد بناءً على استخدام المستخدم
      if (userId != null) {
        final usageResponse = await _supabase
            .from('promo_code_usage')
            .select('promo_code_id')
            .eq('user_id', userId);

        promoCodes = promoCodes.where((code) {
          final userUsageCount = usageResponse
              .where((usage) => usage['promo_code_id'] == code.id)
              .length;
          return userUsageCount < code.userUsageLimit;
        }).toList();
      }

      return promoCodes;
    } catch (e) {
      debugPrint('Error getting available promo codes: $e');
      return [];
    }
  }

  /// البحث عن كود خصم بالاسم أو الكود
  static Future<List<PromoCode>> searchPromoCodes(String searchTerm) async {
    try {
      final response = await _supabase
          .from('promo_codes')
          .select()
          .eq('is_active', true)
          .or('code.ilike.%$searchTerm%,name.ilike.%$searchTerm%')
          .order('created_at', ascending: false);

      return response
          .map<PromoCode>((json) => PromoCode.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error searching promo codes: $e');
      return [];
    }
  }

  /// الحصول على تاريخ استخدام المستخدم لأكواد الخصم
  static Future<List<usage_model.PromoCodeUsage>> getUserPromoCodeHistory(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('promo_code_usage')
          .select('*, promo_code:promo_codes(*)')
          .eq('user_id', userId)
          .order('used_at', ascending: false);

      return response
          .map<usage_model.PromoCodeUsage>(
            (json) => usage_model.PromoCodeUsage.fromJson(json),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting user promo code history: $e');
      return [];
    }
  }

  /// حساب إجمالي المدخرات للمستخدم من أكواد الخصم
  static Future<double> getUserTotalSavings(String userId) async {
    try {
      final response = await _supabase
          .from('promo_code_usage')
          .select('discount_applied')
          .eq('user_id', userId);

      return response.fold<double>(
        0.0,
        (total, usage) => total + (usage['discount_applied'] as num).toDouble(),
      );
    } catch (e) {
      debugPrint('Error calculating user total savings: $e');
      return 0.0;
    }
  }

  /// التحقق من صحة كود خصم محدد للطلب
  static Future<PromoCodeValidationResult> validatePromoCodeForOrder({
    required String code,
    required double orderAmount,
    required String userId,
    required List<Map<String, dynamic>> orderItems,
  }) async {
    try {
      // التحقق الأساسي من الكود
      final basicValidation = await validatePromoCode(
        code: code,
        orderAmount: orderAmount,
        userId: userId,
      );

      if (!basicValidation.isValid) {
        return basicValidation;
      }

      // يمكن إضافة تحققات إضافية هنا مثل:
      // - التحقق من فئات المنتجات المؤهلة
      // - التحقق من العلامات التجارية المؤهلة
      // - التحقق من شروط خاصة أخرى

      return basicValidation;
    } catch (e) {
      debugPrint('Error validating promo code for order: $e');
      return PromoCodeValidationResult.invalid('حدث خطأ في التحقق من الكود');
    }
  }

  /// إلغاء استخدام كود خصم (في حالة إلغاء الطلب)
  static Future<bool> cancelPromoCodeUsage({
    required String promoCodeId,
    required String userId,
    String? orderId,
  }) async {
    try {
      // حذف سجل الاستخدام
      await _supabase
          .from('promo_code_usage')
          .delete()
          .eq('promo_code_id', promoCodeId)
          .eq('user_id', userId)
          .eq('order_id', orderId ?? '');

      // تقليل عداد الاستخدام
      await _supabase.rpc(
        'decrement_promo_code_usage',
        params: {'p_promo_code_id': promoCodeId},
      );

      return true;
    } catch (e) {
      debugPrint('Error canceling promo code usage: $e');
      return false;
    }
  }

  /// الحصول على إحصائيات كود خصم محدد
  static Future<Map<String, dynamic>?> getPromoCodeStats(
    String promoCodeId,
  ) async {
    try {
      final response = await _supabase.rpc(
        'get_promo_code_stats',
        params: {'p_promo_code_id': promoCodeId},
      );

      return response as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting promo code stats: $e');
      return null;
    }
  }

  /// تنظيف أكواد الخصم المنتهية الصلاحية
  static Future<void> cleanupExpiredPromoCodes() async {
    try {
      await _supabase
          .from('promo_codes')
          .update({'is_active': false})
          .lt('valid_until', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error cleaning up expired promo codes: $e');
    }
  }
}
