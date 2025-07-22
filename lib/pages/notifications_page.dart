import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationsPage extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  const NotificationsPage({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'notifications'.tr(),
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
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'no_notifications'.tr(),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final notif = notifications[i];
                return ListTile(
                  leading: Icon(
                    _iconForType(notif['type']),
                    color: const Color(0xFFF93838),
                  ),
                  title: Text(
                    notif['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF181111),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif['body'] ?? '',
                        style: const TextStyle(fontSize: 13),
                      ),
                      if (notif['time'] != null)
                        Text(
                          notif['time'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'order':
        return Icons.local_shipping;
      case 'offer':
        return Icons.local_offer;
      case 'support':
        return Icons.support_agent;
      default:
        return Icons.notifications;
    }
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
