import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/preferences_provider.dart';
import 'faq_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.help_outline,
                    color: Color(0xFF8c5f5f),
                  ),
                  title: Text('الأسئلة الشائعة'.tr()),
                  subtitle: Text('دعم فني ومساعدة'.tr()),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FAQPage()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF8c5f5f),
                  ),
                  title: const Text('حول التطبيق'),
                  subtitle: const Text('معلومات التطبيق والإصدار'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'AUTO SHOP',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.car_repair,
                        size: 48,
                        color: Color(0xFF8c5f5f),
                      ),
                      children: [
                        const Text(
                          'تطبيق خاص بإدارة الطلبات والقطع الميكانيكية.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: Color(0xFF8c5f5f)),
                  title: const Text('اللغة'),
                  subtitle: Text(_getLanguageName(context.locale.languageCode)),
                  trailing: DropdownButton<String>(
                    value: context.locale.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ku', child: Text('کوردی')),
                    ],
                    onChanged: (code) {
                      if (code != null) {
                        context.setLocale(Locale(code));
                        ref
                            .read(preferencesProvider.notifier)
                            .setLanguage(code);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم تغيير اللغة إلى ${_getLanguageName(code)}',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storage, color: Color(0xFF8c5f5f)),
                  title: const Text('مسح البيانات المحلية'),
                  subtitle: const Text('مسح السلة والمفضلات المحفوظة'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تأكيد المسح'),
                        content: const Text(
                          'هل أنت متأكد من مسح جميع البيانات المحلية؟',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم مسح البيانات المحلية'),
                                ),
                              );
                            },
                            child: const Text(
                              'مسح',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF8c5f5f),
                  ),
                  title: const Text('حول التطبيق'),
                  subtitle: const Text('معلومات التطبيق والإصدار'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'AUTO SHOP',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.car_repair,
                        size: 48,
                        color: Color(0xFF8c5f5f),
                      ),
                      children: [
                        const Text(
                          'تطبيق خاص بإدارة الطلبات والقطع الميكانيكية.',
                        ),
                        const SizedBox(height: 8),
                        const Text('يوفر التطبيق:'),
                        const Text('• إدارة السلة والمفضلات'),
                        const Text('• الطلبات الفورية وغير المتزامنة'),
                        const Text('• إشعارات الطلبات'),
                        const Text('• دعم متعدد اللغات'),
                      ],
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.help_outline,
                    color: Color(0xFF8c5f5f),
                  ),
                  title: const Text('الدعم والمساعدة'),
                  subtitle: const Text('كيفية استخدام التطبيق'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('الدعم والمساعدة'),
                        content: const SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '📱 كيفية استخدام التطبيق:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text('1. تصفح المنتجات من الصفحة الرئيسية'),
                              Text('2. أضف المنتجات إلى السلة أو المفضلات'),
                              Text('3. أتمم الطلب من صفحة السلة'),
                              Text('4. تابع طلباتك من صفحة الطلبات'),
                              SizedBox(height: 12),
                              Text(
                                '🔔 الإشعارات:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text('• ستصلك إشعارات عند تأكيد الطلبات'),
                              Text('• إشعارات مزامنة الطلبات المحلية'),
                              SizedBox(height: 12),
                              Text(
                                '📞 للدعم:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text('تواصل معنا عبر صفحة الحساب'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('فهمت'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'ku':
        return 'کوردی';
      default:
        return 'العربية';
    }
  }
}
