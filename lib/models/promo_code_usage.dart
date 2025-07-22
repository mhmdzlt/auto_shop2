class PromoCodeUsage {
  final String id;
  final String promoCodeId;
  final String userId;
  final String? orderId;
  final double discountApplied;
  final DateTime usedAt;

  PromoCodeUsage({
    required this.id,
    required this.promoCodeId,
    required this.userId,
    this.orderId,
    required this.discountApplied,
    required this.usedAt,
  });

  factory PromoCodeUsage.fromJson(Map<String, dynamic> json) {
    return PromoCodeUsage(
      id: json['id'],
      promoCodeId: json['promo_code_id'],
      userId: json['user_id'],
      orderId: json['order_id'],
      discountApplied: (json['discount_applied'] as num).toDouble(),
      usedAt: DateTime.parse(json['used_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promo_code_id': promoCodeId,
      'user_id': userId,
      'order_id': orderId,
      'discount_applied': discountApplied,
      'used_at': usedAt.toIso8601String(),
    };
  }
}
