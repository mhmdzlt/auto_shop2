import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'privacy_policy_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('معلومات عن التطبيق'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AUTO SHOP',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'الإصدار: 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'تطبيق احترافي لإدارة وشراء قطع السيارات والطلبات أونلاين. هدفنا تقديم تجربة تسوق سهلة وآمنة مع دعم فني متكامل ورؤية مستقبلية لتطوير التجارة الإلكترونية في المنطقة.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.blue),
              title: Text('سياسة الخصوصية'.tr()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PrivacyPolicyPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.green),
              title: Text('دعم المطورين والتواصل'.tr()),
              subtitle: Text('auto.shop.support@gmail.com'),
              onTap: () {
                // فتح البريد الإلكتروني
              },
            ),
          ],
        ),
      ),
    );
  }
}
