import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import 'notification_service.dart';

class OrdersService {
  final _client = Supabase.instance.client;

  Future<String?> createOrder({
    required String userId,
    required double totalPrice,
    required List<OrderItem> items,
    String? addressId,
    OrderStatus status = OrderStatus.pending,
  }) async {
    final response = await _client
        .from('orders')
        .insert({
          'user_id': userId,
          'total_price': totalPrice,
          'status': status.name,
          'address_id': addressId,
        })
        .select('id')
        .single();

    final orderId = response['id'] as String?;
    if (orderId == null) return null;

    final batchItems = items
        .map(
          (item) => {
            'order_id': orderId,
            'part_id': item.partId,
            'quantity': item.quantity,
            'unit_price': item.unitPrice,
          },
        )
        .toList();

    await _client.from('order_items').insert(batchItems);
    return orderId;
  }

  // طريقة جديدة لإنشاء طلب من كائن Order
  Future<String?> createOrderFromObject(Order order) async {
    return await createOrder(
      userId: order.userId,
      totalPrice: order.totalPrice,
      items: order.items,
      addressId: order.addressId,
      status: order.status,
    );
  }

  Future<List<Order>> fetchOrders(String userId) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((json) {
      final itemsJson = (json['order_items'] as List);
      final items = itemsJson
          .map(
            (i) => OrderItem(
              partId: i['part_id'],
              quantity: i['quantity'],
              unitPrice: double.parse(i['unit_price'].toString()),
            ),
          )
          .toList();

      return Order(
        id: json['id'],
        userId: json['user_id'],
        totalPrice: double.parse(json['total_price'].toString()),
        createdAt: DateTime.parse(json['created_at']),
        status: OrderStatus.values.firstWhere(
          (e) => e.name == (json['status'] ?? 'pending'),
          orElse: () => OrderStatus.pending,
        ),
        addressId: json['address_id'],
        items: items,
      );
    }).toList();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _client
        .from('orders')
        .update({'status': status.name})
        .eq('id', orderId);
    // إرسال إشعارات ذكية عند تغيير حالة الطلب
    if (status == OrderStatus.shipped) {
      await NotificationService.notifyOrderInTransit(orderId);
    } else if (status == OrderStatus.delivered) {
      await NotificationService.notifyOrderDelivered(orderId);
    }
  }
}
