import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PaymentPage extends StatefulWidget {
  final int total;

  const PaymentPage({super.key, required this.total});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedAddress = 'Riyadh, Saudi Arabia';
  String selectedPayment = 'card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payment'.tr()),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // عنوان الشحن
          Text(
            'address'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // يمكنك ربط العناوين الحقيقية من قاعدة البيانات أو المستخدم لاحقاً
          ListTile(
            title: Text(selectedAddress),
            leading: const Icon(Icons.location_on, color: Color(0xFF8c5f5f)),
            trailing: TextButton(
              child: Text('change'.tr()),
              onPressed: () {
                // منطق تعديل العنوان لاحقاً
              },
            ),
          ),
          const Divider(height: 32),
          // طرق الدفع
          Text(
            'payment_method'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          RadioListTile(
            value: 'card',
            groupValue: selectedPayment,
            onChanged: (val) => setState(() => selectedPayment = val!),
            title: Text('pay_card'.tr()),
            secondary: const Icon(Icons.credit_card, color: Color(0xFF8c5f5f)),
          ),
          RadioListTile(
            value: 'bank',
            groupValue: selectedPayment,
            onChanged: (val) => setState(() => selectedPayment = val!),
            title: Text('pay_bank'.tr()),
            secondary: const Icon(
              Icons.account_balance,
              color: Color(0xFF8c5f5f),
            ),
          ),
          RadioListTile(
            value: 'cod',
            groupValue: selectedPayment,
            onChanged: (val) => setState(() => selectedPayment = val!),
            title: Text('pay_cod'.tr()),
            secondary: const Icon(Icons.money, color: Color(0xFF8c5f5f)),
          ),
          const Divider(height: 32),
          // السعر الكلي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.total}',
                style: const TextStyle(fontSize: 18, color: Color(0xFF8c5f5f)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // زر تأكيد الطلب
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // منطق تأكيد الطلب
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('order_confirmed'.tr()),
                    content: Text('thank_you'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        child: Text('back_home'.tr()),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF93838),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'confirm_order'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ويدجت اختيار اللغة كما في باقي الصفحات
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final locales = [
      {'locale': Locale('ar'), 'name': 'العربية'},
      {'locale': Locale('en'), 'name': 'English'},
      {'locale': Locale('ku'), 'name': 'کوردی'},
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
