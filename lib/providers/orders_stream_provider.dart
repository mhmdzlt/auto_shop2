import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../services/orders_service.dart';

final ordersStreamProvider = StreamProvider.autoDispose<List<Order>>((ref) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser!.id;

  // استرجاع التيار الأساسي
  final initialFetch = OrdersService().fetchOrders(userId);

  // تيار التحديثات الفورية
  final realtime = supabase
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .map((event) {
        // event هو List<Map<String, dynamic>>
        return event.map((json) {
          final items = (json['order_items'] as List)
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
            items: items,
          );
        }).toList();
      });

  // دمج القائمتين: جلب أولي + التحديثات
  return Stream.fromFuture(initialFetch).asyncExpand((initial) async* {
    yield initial;
    yield* realtime;
  });
});
