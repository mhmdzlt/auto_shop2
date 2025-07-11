import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // مثال بيانات الطلبات - لاحقاً تجلبها من Supabase حسب المستخدم
    final List<Map<String, dynamic>> orders = [
      {
        'id': 2201,
        'date': '2024-07-09',
        'total': 115,
        'currency': '\$',
        'status': 'delivered',
        'items': [
          {'name': 'Front Bumper', 'qty': 1},
          {'name': 'Oil Filter', 'qty': 2},
        ],
      },
      {
        'id': 2202,
        'date': '2024-07-07',
        'total': 58,
        'currency': '\$',
        'status': 'pending',
        'items': [
          {'name': 'Brake Pads', 'qty': 1},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('orders'.tr(), style: const TextStyle(color: Color(0xFF181111))),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (context, i) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final order = orders[i];
                final status = order['status'] as String;
                Color statusColor = status == 'delivered'
                    ? const Color(0xFF24B47E)
                    : status == 'pending'
                        ? const Color(0xFFF9B338)
                        : const Color(0xFFF93838);

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      "${'order'.tr()} #${order['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${'date'.tr()}: ${order['date']}",
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          "${'total'.tr()}: ${order['total']} ${order['currency']}",
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        ...order['items'].map<Widget>((item) => Text(
                              "- ${item['name']} × ${item['qty']}",
                              style: const TextStyle(fontSize: 13),
                            )),
                        const SizedBox(height: 6),
                        Text(
                          "${'status'.tr()}: ${status.tr()}",
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

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
