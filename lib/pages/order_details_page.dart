import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/order.dart';
import 'language_selector.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${'order_number'.tr()} ${order.id.substring(0, 8)}'),
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
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'order_date'.tr()}:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(order.createdAt.toLocal().toString()),
            ],
          ),
          const SizedBox(height: 7),
          ...order.items.map(
            (item) => ListTile(
              title: Text('قطعة: ${item.partId}'),
              subtitle: Text('الكمية: ${item.quantity}'),
              trailing: Text('${item.unitPrice} د.ع'),
            ),
          ),
          const Divider(),
          Text(
            'المجموع الكلي: ${order.totalPrice} د.ع',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
