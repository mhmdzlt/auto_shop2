import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('${'order_number'.tr()} ${order['id'] ?? ''}'),
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
              Text(order['date'] ?? ''),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'status'.tr()}:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                order['status'] ?? '',
                style: const TextStyle(color: Color(0xFF8c5f5f)),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'address'.tr()}:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: Text(
                  order['address'] ?? '',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            'order_items'.tr(),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => ListTile(
              leading: item['image_url'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                        item['image_url'],
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.car_repair,
                      size: 38,
                      color: Color(0xFF8c5f5f),
                    ),
              title: Text(
                item['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${item['price']} ${'currency'.tr()} × ${item['quantity'] ?? 1}",
              ),
            ),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total'.tr(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${order['total']} ${'currency'.tr()}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8c5f5f),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ويدجت اختيار اللغة
class LanguageSelector extends StatelessWidget {
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
