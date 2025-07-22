import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class OrderTrackingPage extends StatelessWidget {
  final List<Map<String, dynamic>> orders; // قائمة الطلبات للمستخدم

  const OrderTrackingPage({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'order_tracking'.tr(),
          style: const TextStyle(color: Color(0xFF181111)),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: orders.isEmpty
          ? Center(
              child: Text(
                'no_orders'.tr(),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final order = orders[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF5F0F0),
                      child: Icon(
                        _iconForStatus(order['status']),
                        color: _colorForStatus(order['status']),
                      ),
                    ),
                    title: Text(
                      '${'order'.tr()} #${order['id']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181111),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'status'.tr()}: ${_statusText(context, order['status'])}',
                          style: TextStyle(
                            color: _colorForStatus(order['status']),
                          ),
                        ),
                        if (order['total'] != null)
                          Text(
                            '${'total'.tr()}: ${order['total']} ${'currency'.tr()}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        if (order['date'] != null)
                          Text(
                            '${'date'.tr()}: ${order['date']}',
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => OrderDetailsDialog(order: order),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  // أيقونات لحالة الطلب
  IconData _iconForStatus(String status) {
    switch (status) {
      case 'processing':
        return Icons.access_time;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.shopping_bag;
    }
  }

  // ألوان لحالة الطلب
  Color _colorForStatus(String status) {
    switch (status) {
      case 'processing':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // نص الترجمة لحالة الطلب
  String _statusText(BuildContext context, String status) {
    switch (status) {
      case 'processing':
        return 'processing'.tr();
      case 'delivered':
        return 'delivered'.tr();
      case 'cancelled':
        return 'cancelled'.tr();
      default:
        return status;
    }
  }
}

// نافذة تفاصيل الطلب
class OrderDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final products = order['products'] as List<Map<String, dynamic>>? ?? [];
    return AlertDialog(
      title: Text('${'order'.tr()} #${order['id']}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'status'.tr()}: ${OrderTrackingPage(orders: [],)._statusText(context, order['status'])}',
            ),
            if (order['date'] != null) Text('${'date'.tr()}: ${order['date']}'),
            if (order['total'] != null)
              Text('${'total'.tr()}: ${order['total']} ${'currency'.tr()}'),
            const SizedBox(height: 10),
            Text(
              'products'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...products.map(
              (prod) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('- ${prod['name']} x${prod['qty']}'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('close'.tr()),
        ),
      ],
    );
  }
}

// ويدجت اختيار اللغة
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final locales = [
      {'locale': const Locale('ar'), 'name': 'العربية'},
      {'locale': const Locale('en'), 'name': 'English'},
      {'locale': const Locale('ku'), 'name': 'کوردی'},
    ];
    return DropdownButton<Locale>(
      value: context.locale,
      underline: const SizedBox(),
      icon: const Icon(Icons.language, color: Color(0xFF8c5f5f)),
      onChanged: (locale) {
        context.setLocale(locale!);
      },
      items: locales
          .map(
            (e) => DropdownMenuItem(
              value: e['locale'] as Locale,
              child: Text(e['name'] as String),
            ),
          )
          .toList(),
    );
  }
}
