import 'package:hive/hive.dart';
import '../models/offline_order.dart';
import 'orders_service.dart';
import 'notification_service.dart'; // 🔔 خدمة الإشعارات

class OfflineOrdersService {
  final _box = Hive.box<OfflineOrder>('offline_orders');

  Future<void> addOfflineOrder(OfflineOrder o) async {
    await _box.add(o);
  }

  Future<List<OfflineOrder>> pendingOrders() async {
    return _box.values.where((o) => !o.synced).toList();
  }

  Future<void> markSynced(OfflineOrder o) async {
    o.synced = true;
    await o.save();
  }

  Future<void> syncAll() async {
    final pendings = await pendingOrders();
    int syncedCount = 0;

    for (var o in pendings) {
      final id = await OrdersService().createOrder(
        userId: o.order.userId,
        totalPrice: o.order.totalPrice,
        items: o.order.items,
      );
      if (id != null) {
        await markSynced(o);
        syncedCount++;
      }
    }

    // 🔔 إشعار المزامنة إذا تم مزامنة طلبات
    if (syncedCount > 0) {
      await NotificationService.showOfflineSyncNotification(
        title: '📶 تم إرسال الطلبات المحلية',
        body: 'تمت مزامنة $syncedCount طلب بنجاح',
      );
    }
  }
}
