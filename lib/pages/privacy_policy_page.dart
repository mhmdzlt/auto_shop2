import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final TextStyle heading = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  final TextStyle body = const TextStyle(fontSize: 14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سياسة الخصوصية')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('1. جمع المعلومات', style: heading),
            const SizedBox(height: 4),
            Text(
              'نقوم بجمع بيانات المستخدم مثل الاسم، البريد الإلكتروني، وعنوان التوصيل لتسهيل عمليات الطلب والشحن.',
              style: body,
            ),

            const SizedBox(height: 16),
            Text('2. استخدام المعلومات', style: heading),
            const SizedBox(height: 4),
            Text(
              'يتم استخدام البيانات فقط ضمن تطبيقنا لتحسين تجربة المستخدم وتنفيذ الطلبات.',
              style: body,
            ),

            const SizedBox(height: 16),
            Text('3. مشاركة المعلومات', style: heading),
            const SizedBox(height: 4),
            Text(
              'لا نشارك بياناتك مع أي طرف ثالث دون موافقة مسبقة، باستثناء الشحن أو الدفع عند الحاجة.',
              style: body,
            ),

            const SizedBox(height: 16),
            Text('4. حماية البيانات', style: heading),
            const SizedBox(height: 4),
            Text(
              'نستخدم تقنيات التشفير والتخزين الآمن لحماية معلوماتك الشخصية من الوصول غير المصرح به.',
              style: body,
            ),

            const SizedBox(height: 16),
            Text('5. التحديثات', style: heading),
            const SizedBox(height: 4),
            Text(
              'قد يتم تعديل سياسة الخصوصية من وقت لآخر، وسيتم إخطارك بالتغييرات داخل التطبيق.',
              style: body,
            ),

            const SizedBox(height: 24),
            Text(
              'لأي استفسار، يرجى التواصل معنا عبر البريد الإلكتروني أو صفحة الدعم.',
              style: body,
            ),
          ],
        ),
      ),
    );
  }
}
