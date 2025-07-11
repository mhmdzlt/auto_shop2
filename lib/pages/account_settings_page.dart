import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AccountSettingsPage extends StatelessWidget {
  final String? username;
  final String? email;

  const AccountSettingsPage({super.key, this.username, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'account_settings'.tr(),
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
        padding: const EdgeInsets.all(22),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFF5F0F0),
                child: Icon(Icons.person, size: 34, color: Color(0xFF8c5f5f)),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username ?? 'username'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    email ?? 'email'.tr(),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 36),

          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF8c5f5f)),
            title: Text('change_name'.tr()),
            onTap: () {
              // استدعِ صفحة تغيير الاسم
              showDialog(
                context: context,
                builder: (_) => ChangeNameDialog(username: username ?? ''),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Color(0xFF8c5f5f)),
            title: Text('change_password'.tr()),
            onTap: () {
              // استدعِ صفحة تغيير كلمة السر
              showDialog(
                context: context,
                builder: (_) => ChangePasswordDialog(),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF8c5f5f)),
            title: Text('language'.tr()),
            trailing: LanguageSelector(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF8c5f5f)),
            title: Text('logout'.tr()),
            onTap: () {
              // أضف كود تسجيل الخروج هنا
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          const SizedBox(height: 50),
          Center(
            child: TextButton(
              onPressed: () {
                // كود حذف الحساب
                showDialog(
                  context: context,
                  builder: (_) => DeleteAccountDialog(),
                );
              },
              child: Text(
                'delete_account'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// نافذة تغيير الاسم
class ChangeNameDialog extends StatelessWidget {
  final String username;
  const ChangeNameDialog({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: username);
    return AlertDialog(
      title: Text('change_name'.tr()),
      content: TextField(
        controller: ctrl,
        decoration: InputDecoration(hintText: 'username'.tr()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            // أضف هنا كود تحديث الاسم في قاعدة البيانات أو Supabase
            Navigator.pop(context);
          },
          child: Text('save'.tr()),
        ),
      ],
    );
  }
}

// نافذة تغيير كلمة المرور
class ChangePasswordDialog extends StatelessWidget {
  const ChangePasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();
    return AlertDialog(
      title: Text('change_password'.tr()),
      content: TextField(
        controller: ctrl,
        obscureText: true,
        decoration: InputDecoration(hintText: 'new_password'.tr()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            // كود تحديث كلمة المرور
            Navigator.pop(context);
          },
          child: Text('save'.tr()),
        ),
      ],
    );
  }
}

// نافذة حذف الحساب
class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('delete_account'.tr()),
      content: Text('delete_account_confirm'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            // كود حذف الحساب هنا
            Navigator.pop(context);
          },
          child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
        ),
      ],
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
