import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HelpCenterPage extends StatelessWidget {
  final List<Map<String, String>> faqs; // قائمة الأسئلة الشائعة

  const HelpCenterPage({super.key, required this.faqs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'help_center'.tr(),
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
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'faq'.tr(),
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF93838),
            ),
          ),
          const SizedBox(height: 18),
          ...faqs.map(
            (faq) => ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 6,
              ),
              title: Text(
                faq['question'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181111),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                    left: 12,
                    right: 12,
                  ),
                  child: Text(
                    faq['answer'] ?? '',
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF8c5f5f)),
            title: Text('store_policy'.tr()),
            onTap: () {
              showDialog(context: context, builder: (_) => PolicyDialog());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.support_agent, color: Color(0xFF8c5f5f)),
            title: Text('contact_support'.tr()),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/chat',
              ); // تأكد من إضافة صفحة الدردشة للمسارات
            },
          ),
        ],
      ),
    );
  }
}

class PolicyDialog extends StatelessWidget {
  const PolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('store_policy'.tr()),
      content: SingleChildScrollView(child: Text('store_policy_content'.tr())),
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
