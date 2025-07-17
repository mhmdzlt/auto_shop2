import 'package:hive/hive.dart';
part 'address.g.dart';

@HiveType(typeId: 3)
class Address extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String details;

  @HiveField(3)
  bool isDefault;

  @HiveField(4)
  String userId;

  @HiveField(5)
  String? phone;

  @HiveField(6)
  String? city;

  @HiveField(7)
  String? country;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  Address({
    required this.id,
    required this.title,
    required this.details,
    required this.userId,
    this.isDefault = false,
    this.phone,
    this.city,
    this.country,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'is_default': isDefault,
      'user_id': userId,
      'phone': phone,
      'city': city,
      'country': country,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      title: json['title'],
      details: json['details'],
      userId: json['user_id'],
      isDefault: json['is_default'] ?? false,
      phone: json['phone'],
      city: json['city'],
      country: json['country'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}
