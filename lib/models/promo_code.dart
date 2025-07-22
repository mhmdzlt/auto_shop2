class PromoCode {
  final String id;
  final String code;
  final String name;
  final String? description;
  final PromoCodeType discountType;
  final double discountValue;
  final double minOrderAmount;
  final double? maxDiscountAmount;
  final int? usageLimit;
  final int usageCount;
  final int userUsageLimit;
  final DateTime validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final DateTime createdAt;

  const PromoCode({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount = 0,
    this.maxDiscountAmount,
    this.usageLimit,
    this.usageCount = 0,
    this.userUsageLimit = 1,
    required this.validFrom,
    this.validUntil,
    this.isActive = true,
    required this.createdAt,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      discountType: PromoCodeType.fromString(json['discount_type'] as String),
      discountValue: (json['discount_value'] as num).toDouble(),
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0,
      maxDiscountAmount: (json['max_discount_amount'] as num?)?.toDouble(),
      usageLimit: json['usage_limit'] as int?,
      usageCount: json['usage_count'] as int? ?? 0,
      userUsageLimit: json['user_usage_limit'] as int? ?? 1,
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'discount_type': discountType.value,
      'discount_value': discountValue,
      'min_order_amount': minOrderAmount,
      'max_discount_amount': maxDiscountAmount,
      'usage_limit': usageLimit,
      'usage_count': usageCount,
      'user_usage_limit': userUsageLimit,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// حساب قيمة الخصم بناءً على مبلغ الطلب
  double calculateDiscount(double orderAmount) {
    if (orderAmount < minOrderAmount) {
      return 0;
    }

    double discount = 0;
    if (discountType == PromoCodeType.percentage) {
      discount = orderAmount * (discountValue / 100);
      if (maxDiscountAmount != null) {
        discount = discount > maxDiscountAmount!
            ? maxDiscountAmount!
            : discount;
      }
    } else {
      discount = discountValue > orderAmount ? orderAmount : discountValue;
    }

    return discount;
  }

  /// التحقق من أن الكوبون صالح للاستخدام
  bool get isCurrentlyValid {
    final now = DateTime.now();
    return isActive &&
        validFrom.isBefore(now) &&
        (validUntil == null || validUntil!.isAfter(now)) &&
        (usageLimit == null || usageCount < usageLimit!);
  }

  /// الحصول على رسالة الخطأ إذا لم يكن صالحاً
  String? getValidationError(double orderAmount, int userUsageCount) {
    if (!isActive) {
      return 'كود الخصم غير نشط';
    }

    final now = DateTime.now();
    if (validFrom.isAfter(now)) {
      return 'كود الخصم لم يبدأ بعد';
    }

    if (validUntil != null && validUntil!.isBefore(now)) {
      return 'انتهت صلاحية كود الخصم';
    }

    if (orderAmount < minOrderAmount) {
      return 'الحد الأدنى للطلب $minOrderAmount';
    }

    if (usageLimit != null && usageCount >= usageLimit!) {
      return 'تم استنفاد عدد مرات استخدام هذا الكود';
    }

    if (userUsageCount >= userUsageLimit) {
      return 'لقد استخدمت هذا الكود من قبل';
    }

    return null; // صالح
  }

  /// نسخة محدثة من الكوبون
  PromoCode copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    PromoCodeType? discountType,
    double? discountValue,
    double? minOrderAmount,
    double? maxDiscountAmount,
    int? usageLimit,
    int? usageCount,
    int? userUsageLimit,
    DateTime? validFrom,
    DateTime? validUntil,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PromoCode(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      userUsageLimit: userUsageLimit ?? this.userUsageLimit,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum PromoCodeType {
  percentage('percentage'),
  fixedAmount('fixed_amount');

  const PromoCodeType(this.value);
  final String value;

  static PromoCodeType fromString(String value) {
    return PromoCodeType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PromoCodeType.percentage,
    );
  }

  String get displayName {
    switch (this) {
      case PromoCodeType.percentage:
        return 'نسبة مئوية';
      case PromoCodeType.fixedAmount:
        return 'مبلغ ثابت';
    }
  }
}

class PromoCodeUsage {
  final String id;
  final String promoCodeId;
  final String userId;
  final String? orderId;
  final DateTime usedAt;
  final double discountApplied;

  const PromoCodeUsage({
    required this.id,
    required this.promoCodeId,
    required this.userId,
    this.orderId,
    required this.usedAt,
    required this.discountApplied,
  });

  factory PromoCodeUsage.fromJson(Map<String, dynamic> json) {
    return PromoCodeUsage(
      id: json['id'] as String,
      promoCodeId: json['promo_code_id'] as String,
      userId: json['user_id'] as String,
      orderId: json['order_id'] as String?,
      usedAt: DateTime.parse(json['used_at'] as String),
      discountApplied: (json['discount_applied'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promo_code_id': promoCodeId,
      'user_id': userId,
      'order_id': orderId,
      'used_at': usedAt.toIso8601String(),
      'discount_applied': discountApplied,
    };
  }
}

class PromoCodeValidationResult {
  final bool isValid;
  final String? error;
  final PromoCode? promoCode;
  final double? discountAmount;
  final int? userUsageCount;

  const PromoCodeValidationResult({
    required this.isValid,
    this.error,
    this.promoCode,
    this.discountAmount,
    this.userUsageCount,
  });

  factory PromoCodeValidationResult.invalid(String error) {
    return PromoCodeValidationResult(isValid: false, error: error);
  }

  factory PromoCodeValidationResult.valid({
    required PromoCode promoCode,
    required double discountAmount,
    int? userUsageCount,
  }) {
    return PromoCodeValidationResult(
      isValid: true,
      promoCode: promoCode,
      discountAmount: discountAmount,
      userUsageCount: userUsageCount,
    );
  }
}
