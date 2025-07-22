// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive/hive.dart';

part 'discount.g.dart';

@HiveType(typeId: 4)
class Discount extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String code;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DiscountType type;

  @HiveField(5)
  final double value; // النسبة المئوية أو المبلغ الثابت

  @HiveField(6)
  final double? minimumAmount; // الحد الأدنى للطلب

  @HiveField(7)
  final double? maximumDiscount; // الحد الأقصى للخصم

  @HiveField(8)
  final DateTime startDate;

  @HiveField(9)
  final DateTime endDate;

  @HiveField(10)
  final int? usageLimit; // عدد مرات الاستخدام المسموح

  @HiveField(11)
  final int usedCount; // عدد مرات الاستخدام الحالي

  @HiveField(12)
  final bool isActive;

  @HiveField(13)
  final List<String>? applicableCategories; // الفئات المؤهلة

  @HiveField(14)
  final List<String>? applicableProducts; // المنتجات المؤهلة

  @HiveField(15)
  final bool isFirstTimeOnly; // للمستخدمين الجدد فقط

  @HiveField(16)
  final DateTime createdAt;

  @HiveField(17)
  final DateTime? updatedAt;

  Discount({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.minimumAmount,
    this.maximumDiscount,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
    this.applicableCategories,
    this.applicableProducts,
    this.isFirstTimeOnly = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// التحقق من صحة الكوبون
  bool isValid() {
    final now = DateTime.now();

    // التحقق من التواريخ
    if (now.isBefore(startDate) || now.isAfter(endDate)) {
      return false;
    }

    // التحقق من الحالة النشطة
    if (!isActive) {
      return false;
    }

    // التحقق من عدد مرات الاستخدام
    if (usageLimit != null && usedCount >= usageLimit!) {
      return false;
    }

    return true;
  }

  /// حساب قيمة الخصم
  double calculateDiscount(
    double orderAmount, {
    List<String>? productCategories,
    List<String>? productIds,
  }) {
    if (!isValid()) return 0.0;

    // التحقق من الحد الأدنى للطلب
    if (minimumAmount != null && orderAmount < minimumAmount!) {
      return 0.0;
    }

    // التحقق من الفئات المؤهلة
    if (applicableCategories != null && productCategories != null) {
      bool hasApplicableCategory = applicableCategories!.any(
        (category) => productCategories.contains(category),
      );
      if (!hasApplicableCategory) return 0.0;
    }

    // التحقق من المنتجات المؤهلة
    if (applicableProducts != null && productIds != null) {
      bool hasApplicableProduct = applicableProducts!.any(
        (productId) => productIds.contains(productId),
      );
      if (!hasApplicableProduct) return 0.0;
    }

    double discountAmount = 0.0;

    switch (type) {
      case DiscountType.percentage:
        discountAmount = (orderAmount * value) / 100;
        break;
      case DiscountType.fixedAmount:
        discountAmount = value;
        break;
      case DiscountType.freeShipping:
        // يمكن إرجاع قيمة الشحن هنا
        discountAmount = 0.0; // سيتم التعامل معها بشكل منفصل
        break;
    }

    // تطبيق الحد الأقصى للخصم
    if (maximumDiscount != null && discountAmount > maximumDiscount!) {
      discountAmount = maximumDiscount!;
    }

    // التأكد من عدم تجاوز قيمة الطلب
    if (discountAmount > orderAmount) {
      discountAmount = orderAmount;
    }

    return discountAmount;
  }

  /// نسخ الكوبون مع تحديثات
  Discount copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    DiscountType? type,
    double? value,
    double? minimumAmount,
    double? maximumDiscount,
    DateTime? startDate,
    DateTime? endDate,
    int? usageLimit,
    int? usedCount,
    bool? isActive,
    List<String>? applicableCategories,
    List<String>? applicableProducts,
    bool? isFirstTimeOnly,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Discount(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      minimumAmount: minimumAmount ?? this.minimumAmount,
      maximumDiscount: maximumDiscount ?? this.maximumDiscount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
      applicableCategories: applicableCategories ?? this.applicableCategories,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      isFirstTimeOnly: isFirstTimeOnly ?? this.isFirstTimeOnly,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'value': value,
      'minimum_amount': minimumAmount,
      'maximum_discount': maximumDiscount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'is_active': isActive,
      'applicable_categories': applicableCategories,
      'applicable_products': applicableProducts,
      'is_first_time_only': isFirstTimeOnly,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// إنشاء من JSON
  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: DiscountType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => DiscountType.percentage,
      ),
      value: (json['value'] as num).toDouble(),
      minimumAmount: json['minimum_amount'] != null
          ? (json['minimum_amount'] as num).toDouble()
          : null,
      maximumDiscount: json['maximum_discount'] != null
          ? (json['maximum_discount'] as num).toDouble()
          : null,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      usageLimit: json['usage_limit'] as int?,
      usedCount: json['used_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      applicableCategories: json['applicable_categories'] != null
          ? List<String>.from(json['applicable_categories'] as List)
          : null,
      applicableProducts: json['applicable_products'] != null
          ? List<String>.from(json['applicable_products'] as List)
          : null,
      isFirstTimeOnly: json['is_first_time_only'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'Discount(id: $id, code: $code, title: $title, type: $type, value: $value, isActive: $isActive)';
  }

  @override
  bool operator ==(covariant Discount other) {
    if (identical(this, other)) return true;
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 5)
enum DiscountType {
  @HiveField(0)
  percentage, // خصم بالنسبة المئوية

  @HiveField(1)
  fixedAmount, // خصم بمبلغ ثابت

  @HiveField(2)
  freeShipping, // شحن مجاني
}

/// نموذج لتطبيق الخصم على طلب
class DiscountApplication {
  final Discount discount;
  final double originalAmount;
  final double discountAmount;
  final double finalAmount;
  final DateTime appliedAt;

  DiscountApplication({
    required this.discount,
    required this.originalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.appliedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'discount': discount.toJson(),
      'original_amount': originalAmount,
      'discount_amount': discountAmount,
      'final_amount': finalAmount,
      'applied_at': appliedAt.toIso8601String(),
    };
  }

  factory DiscountApplication.fromJson(Map<String, dynamic> json) {
    return DiscountApplication(
      discount: Discount.fromJson(json['discount']),
      originalAmount: (json['original_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      finalAmount: (json['final_amount'] as num).toDouble(),
      appliedAt: DateTime.parse(json['applied_at']),
    );
  }
}
