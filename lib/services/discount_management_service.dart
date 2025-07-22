import 'package:hive/hive.dart';
import '../models/discount.dart';

/// خدمة إدارة الخصومات والعروض الترويجية
class DiscountManagementService {
  static const String _boxName = 'discounts';
  late Box<Discount> _discountBox;

  /// تهيئة الخدمة
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _discountBox = await Hive.openBox<Discount>(_boxName);
    } else {
      _discountBox = Hive.box<Discount>(_boxName);
    }
  }

  /// إضافة خصم جديد
  Future<void> addDiscount(Discount discount) async {
    await _discountBox.put(discount.id, discount);
  }

  /// الحصول على جميع الخصومات
  List<Discount> getAllDiscounts() {
    return _discountBox.values.toList();
  }

  /// الحصول على الخصومات النشطة فقط
  List<Discount> getActiveDiscounts() {
    return _discountBox.values.where((discount) => discount.isValid()).toList();
  }

  /// البحث عن خصم بالكود
  Discount? getDiscountByCode(String code) {
    try {
      return _discountBox.values.firstWhere(
        (discount) => discount.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// تحديث خصم موجود
  Future<void> updateDiscount(Discount discount) async {
    await _discountBox.put(discount.id, discount);
  }

  /// حذف خصم
  Future<void> deleteDiscount(String discountId) async {
    await _discountBox.delete(discountId);
  }

  /// تطبيق خصم على طلب
  DiscountApplication? applyDiscount(
    String discountCode,
    double orderAmount, {
    List<String>? productCategories,
    List<String>? productIds,
    bool isFirstTimeUser = false,
  }) {
    final discount = getDiscountByCode(discountCode);

    if (discount == null) {
      return null; // كود خاطئ
    }

    if (!discount.isValid()) {
      return null; // خصم منتهي الصلاحية أو غير نشط
    }

    // التحقق من شرط المستخدمين الجدد
    if (discount.isFirstTimeOnly && !isFirstTimeUser) {
      return null;
    }

    final discountAmount = discount.calculateDiscount(
      orderAmount,
      productCategories: productCategories,
      productIds: productIds,
    );

    if (discountAmount <= 0) {
      return null; // لا يوجد خصم مطبق
    }

    // تحديث عداد الاستخدام
    final updatedDiscount = discount.copyWith(
      usedCount: discount.usedCount + 1,
      updatedAt: DateTime.now(),
    );
    updateDiscount(updatedDiscount);

    return DiscountApplication(
      discount: discount,
      originalAmount: orderAmount,
      discountAmount: discountAmount,
      finalAmount: orderAmount - discountAmount,
      appliedAt: DateTime.now(),
    );
  }

  /// التحقق من صحة كود الخصم قبل التطبيق
  Map<String, dynamic> validateDiscountCode(
    String discountCode,
    double orderAmount, {
    List<String>? productCategories,
    List<String>? productIds,
    bool isFirstTimeUser = false,
  }) {
    final discount = getDiscountByCode(discountCode);

    if (discount == null) {
      return {
        'isValid': false,
        'error': 'كود الخصم غير صحيح',
        'errorCode': 'INVALID_CODE',
      };
    }

    if (!discount.isActive) {
      return {
        'isValid': false,
        'error': 'كود الخصم غير نشط',
        'errorCode': 'INACTIVE_DISCOUNT',
      };
    }

    final now = DateTime.now();
    if (now.isBefore(discount.startDate)) {
      return {
        'isValid': false,
        'error': 'كود الخصم لم يصبح ساري المفعول بعد',
        'errorCode': 'NOT_STARTED',
      };
    }

    if (now.isAfter(discount.endDate)) {
      return {
        'isValid': false,
        'error': 'انتهت صلاحية كود الخصم',
        'errorCode': 'EXPIRED',
      };
    }

    if (discount.usageLimit != null &&
        discount.usedCount >= discount.usageLimit!) {
      return {
        'isValid': false,
        'error': 'تم استنفاد عدد مرات استخدام هذا الكود',
        'errorCode': 'USAGE_LIMIT_EXCEEDED',
      };
    }

    if (discount.isFirstTimeOnly && !isFirstTimeUser) {
      return {
        'isValid': false,
        'error': 'هذا الكود متاح للمستخدمين الجدد فقط',
        'errorCode': 'FIRST_TIME_ONLY',
      };
    }

    if (discount.minimumAmount != null &&
        orderAmount < discount.minimumAmount!) {
      return {
        'isValid': false,
        'error':
            'قيمة الطلب أقل من الحد الأدنى المطلوب (${discount.minimumAmount} \$)',
        'errorCode': 'MINIMUM_AMOUNT_NOT_MET',
      };
    }

    // التحقق من الفئات المؤهلة
    if (discount.applicableCategories != null && productCategories != null) {
      bool hasApplicableCategory = discount.applicableCategories!.any(
        (category) => productCategories.contains(category),
      );
      if (!hasApplicableCategory) {
        return {
          'isValid': false,
          'error': 'هذا الكود غير مطبق على المنتجات في سلة التسوق',
          'errorCode': 'CATEGORY_NOT_APPLICABLE',
        };
      }
    }

    // التحقق من المنتجات المؤهلة
    if (discount.applicableProducts != null && productIds != null) {
      bool hasApplicableProduct = discount.applicableProducts!.any(
        (productId) => productIds.contains(productId),
      );
      if (!hasApplicableProduct) {
        return {
          'isValid': false,
          'error': 'هذا الكود غير مطبق على المنتجات في سلة التسوق',
          'errorCode': 'PRODUCT_NOT_APPLICABLE',
        };
      }
    }

    final discountAmount = discount.calculateDiscount(
      orderAmount,
      productCategories: productCategories,
      productIds: productIds,
    );

    return {
      'isValid': true,
      'discount': discount,
      'discountAmount': discountAmount,
      'finalAmount': orderAmount - discountAmount,
      'message': 'كود الخصم صحيح! وفر ${discountAmount.toStringAsFixed(2)} \$',
    };
  }

  /// الحصول على الخصومات حسب النوع
  List<Discount> getDiscountsByType(DiscountType type) {
    return _discountBox.values
        .where((discount) => discount.type == type)
        .toList();
  }

  /// الحصول على إحصائيات الخصومات
  Map<String, dynamic> getDiscountStatistics() {
    final allDiscounts = getAllDiscounts();
    final activeDiscounts = getActiveDiscounts();

    int totalUsage = allDiscounts.fold(
      0,
      (sum, discount) => sum + discount.usedCount,
    );
    double totalSavings = 0.0;

    // يمكن إضافة حساب أكثر تفصيلاً للمدخرات الإجمالية هنا

    return {
      'totalDiscounts': allDiscounts.length,
      'activeDiscounts': activeDiscounts.length,
      'expiredDiscounts': allDiscounts.length - activeDiscounts.length,
      'totalUsage': totalUsage,
      'totalSavings': totalSavings,
      'averageUsagePerDiscount': allDiscounts.isNotEmpty
          ? totalUsage / allDiscounts.length
          : 0,
    };
  }

  /// تنظيف الخصومات المنتهية الصلاحية
  Future<int> cleanupExpiredDiscounts() async {
    final expiredDiscounts = _discountBox.values
        .where((discount) => DateTime.now().isAfter(discount.endDate))
        .toList();

    for (final discount in expiredDiscounts) {
      await _discountBox.delete(discount.id);
    }

    return expiredDiscounts.length;
  }

  /// إغلاق الخدمة
  Future<void> dispose() async {
    if (_discountBox.isOpen) {
      await _discountBox.close();
    }
  }
}
