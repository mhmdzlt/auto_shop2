import 'package:hive/hive.dart';
part 'order.g.dart';

enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  shipped,
  delivered,
  cancelled,
}

@HiveType(typeId: 4)
class OrderItem extends HiveObject {
  @HiveField(0)
  String partId;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double unitPrice;

  OrderItem({
    required this.partId,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() {
    return {'part_id': partId, 'quantity': quantity, 'unit_price': unitPrice};
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      partId: json['part_id'],
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
    );
  }
}

@HiveType(typeId: 1)
class Order extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  double totalPrice;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  List<OrderItem> items;

  @HiveField(5)
  OrderStatus status;

  @HiveField(6)
  String? addressId;

  Order({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
    this.status = OrderStatus.pending,
    this.addressId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'address_id': addressId,
      'order_items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      totalPrice: double.parse(json['total_price'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      addressId: json['address_id'],
      items: (json['order_items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}
