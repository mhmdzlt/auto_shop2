import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/orders_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final ordersLoadingProvider = StateProvider<bool>((_) => false);

// Provider للفلتر المحدد
final selectedOrderStatusProvider = StateProvider<OrderStatus?>((_) => null);

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>(
      (ref) => OrdersNotifier(ref),
    );

// Provider للطلبات المفلترة
final filteredOrdersProvider = Provider<AsyncValue<List<Order>>>((ref) {
  final ordersAsync = ref.watch(ordersProvider);
  final selectedStatus = ref.watch(selectedOrderStatusProvider);

  return ordersAsync.when(
    data: (orders) {
      if (selectedStatus == null) {
        return AsyncValue.data(orders);
      }
      final filtered = orders
          .where((order) => order.status == selectedStatus)
          .toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final Ref ref;
  OrdersNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    try {
      state = const AsyncValue.loading();
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final list = await OrdersService().fetchOrders(userId);
      state = AsyncValue.data(list);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addOrder(Order order) async {
    try {
      await OrdersService().createOrderFromObject(order);
      await fetch(); // إعادة تحميل القائمة
    } catch (error) {
      rethrow;
    }
  }
}
