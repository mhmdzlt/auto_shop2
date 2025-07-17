import 'package:hive/hive.dart';

part 'part.g.dart';

@HiveType(typeId: 0)
class Part extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String? imageUrl;

  Part({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });
}
