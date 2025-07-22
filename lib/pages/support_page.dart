import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم والمساعدة'),
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
                  leading: const Icon(Icons.message, color: Colors.green),
                  title: const Text('الدعم عبر واتساب'),
                  subtitle: const Text(
                    'تواصل معنا عبر واتساب للحصول على المساعدة',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://wa.me/9647700000000?text=مرحباً، أحتاج مساعدة في تطبيق AUTO SHOP',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تعذر فتح واتساب')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email, color: Color(0xFF8c5f5f)),
                  title: const Text('أرسل رسالة إلكترونية'),
                  subtitle: const Text('support@auto-shop.com'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final uri = Uri.parse(
                      'mailto:support@auto-shop.com?subject=طلب دعم - AUTO SHOP&body=مرحباً،%0A%0Aأحتاج مساعدة في:%0A',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تعذر فتح تطبيق البريد الإلكتروني'),
                          ),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFF8c5f5f)),
                  title: const Text('اتصل بنا'),
                  subtitle: const Text('+964 770 000 0000'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final uri = Uri.parse('tel:+9647700000000');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تعذر إجراء المكالمة')),
                        );
                      }
                    }
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
                  leading: const Icon(Icons.help, color: Color(0xFF8c5f5f)),
                  title: const Text('الأسئلة الشائعة'),
                  subtitle: const Text('الحلول للمشاكل الشائعة'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FAQPage()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback, color: Color(0xFF8c5f5f)),
                  title: const Text('تقييم التطبيق'),
                  subtitle: const Text('شاركنا رأيك لتحسين الخدمة'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تقييم التطبيق'),
                        content: const Text(
                          'شكراً لاستخدام AUTO SHOP!\nهل تود تقييم التطبيق في متجر التطبيقات؟',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('لاحقاً'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // فتح متجر التطبيقات للتقييم
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'شكراً لك! سيتم فتح متجر التطبيقات',
                                  ),
                                ),
                              );
                            },
                            child: const Text('تقييم'),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📞 ساعات العمل',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('الأحد - الخميس: 9:00 ص - 6:00 م'),
                  const Text('الجمعة - السبت: 10:00 ص - 4:00 م'),
                  const SizedBox(height: 16),
                  const Text(
                    '🎯 نحن هنا لمساعدتك',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'فريق الدعم الفني متاح لحل جميع استفساراتك ومساعدتك في استخدام التطبيق بأفضل شكل ممكن.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأسئلة الشائعة'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ExpansionTile(
            leading: Icon(Icons.help_outline, color: Color(0xFF8c5f5f)),
            title: Text('كيف أضيف منتجات إلى السلة؟'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'يمكنك إضافة المنتجات إلى السلة من خلال:\n1. تصفح المنتجات في الصفحة الرئيسية\n2. اضغط على المنتج المطلوب\n3. اضغط على زر "إضافة إلى السلة"',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            leading: Icon(Icons.shopping_cart, color: Color(0xFF8c5f5f)),
            title: Text('كيف أتمم عملية الشراء؟'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'لإتمام الشراء:\n1. اذهب إلى صفحة السلة\n2. راجع المنتجات والسعر الإجمالي\n3. اضغط على "إتمام الطلب"\n4. أدخل معلومات التوصيل\n5. أكد الطلب',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            leading: Icon(Icons.favorite, color: Color(0xFF8c5f5f)),
            title: Text('كيف أحفظ المنتجات في المفضلات؟'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'لحفظ منتج في المفضلات:\n1. اذهب إلى صفحة المنتج\n2. اضغط على أيقونة القلب ♡\n3. سيتم حفظ المنتج في قائمة المفضلات',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            leading: Icon(Icons.wifi_off, color: Color(0xFF8c5f5f)),
            title: Text('ماذا يحدث عند انقطاع الإنترنت؟'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'عند انقطاع الإنترنت:\n• سيتم حفظ طلبك محلياً\n• ستظهر رسالة تأكيد الحفظ\n• سيتم إرسال الطلب تلقائياً عند عودة الاتصال',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            leading: Icon(Icons.notifications, color: Color(0xFF8c5f5f)),
            title: Text('كيف أتحكم في الإشعارات؟'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'للتحكم في الإشعارات:\n1. اذهب إلى الإعدادات\n2. اختر "تفعيل الإشعارات"\n3. يمكنك تفعيل أو إيقاف الإشعارات حسب رغبتك',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            leading: Icon(Icons.dark_mode, color: Color(0xFF8c5f5f)),
            title: Text('كيف أغير مظهر التطبيق؟'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'لتغيير المظهر:\n1. اذهب إلى الإعدادات\n2. اختر "الوضع الليلي"\n3. سيتم تطبيق المظهر الداكن فوراً',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
