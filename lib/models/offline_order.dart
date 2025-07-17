import 'package:hive/hive.dart';
import 'order.dart';

part 'offline_order.g.dart';

@HiveType(typeId: 1)
class OfflineOrder extends HiveObject {
  @HiveField(0)
  final Order order;

  @HiveField(1)
  bool synced;

  OfflineOrder({required this.order, this.synced = false});
}
