import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);
  }

  static Future<void> showOrderNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'orders_channel',
          'إشعارات الطلبات',
          channelDescription: 'إشعارات تأكيد ومتابعة الطلبات',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(0, title, body, details);
  }

  static Future<void> showOfflineSyncNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'sync_channel',
          'إشعارات المزامنة',
          channelDescription: 'إشعارات مزامنة الطلبات المحلية',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(1, title, body, details);
  }

  /// إشعار عند تغيير الطلب إلى قيد التوصيل
  static Future<void> notifyOrderInTransit(String orderId) async {
    await showOrderNotification(
      title: '🚚 طلبك في الطريق!',
      body: 'طلبك رقم #$orderId قيد التوصيل الآن.',
    );
  }

  /// إشعار عند استلام الطلب
  static Future<void> notifyOrderDelivered(String orderId) async {
    await showOrderNotification(
      title: '📦 تم توصيل الطلب',
      body: 'رجاءً لا تنسَ تقييم المنتجات التي استلمتها 🙏',
    );
  }

  /// إشعار عروض وخصومات جديدة
  static Future<void> showPromotionNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'promo_channel',
          'إشعارات العروض',
          channelDescription: 'إشعارات الخصومات والعروض الخاصة',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await _plugin.show(2, title, body, details);
  }
}
