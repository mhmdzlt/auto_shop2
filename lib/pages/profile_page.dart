import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends StatelessWidget {
  final String? userId; // <-- لاحظ علامة الاستفهام
  const ProfilePage({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    // مثال بيانات مستخدم (لاحقاً تجلب من قاعدة البيانات أو الجلسة)
    final user = {
      'name': 'محمد أحمد',
      'email': 'mohammed@sample.com',
      'phone': '+9647700000000',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'account'.tr(),
          style: const TextStyle(color: Color(0xFF181111)),
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 38,
                backgroundColor: const Color(0xFFF5F0F0),
                child: Icon(Icons.person, size: 48, color: Color(0xFF8c5f5f)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user['name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181111),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              user['email'] ?? '',
              style: const TextStyle(fontSize: 16, color: Color(0xFF8c5f5f)),
            ),
            const SizedBox(height: 7),
            Text(
              user['phone'] ?? '',
              style: const TextStyle(fontSize: 16, color: Color(0xFF8c5f5f)),
            ),
            const SizedBox(height: 22),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: Color(0xFFF93838)),
              title: Text(
                'logout'.tr(),
                style: const TextStyle(
                  color: Color(0xFFF93838),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // هنا تضع كود تسجيل الخروج الحقيقي
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (r) => false,
                );
              },
            ),
          ],
        ),
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
