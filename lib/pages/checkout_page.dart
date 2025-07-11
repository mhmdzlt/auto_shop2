import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String address = '';
  String selectedPayment = 'card';

  final addressController = TextEditingController();

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethods = [
      {'id': 'card', 'label': 'pay_by_card'.tr(), 'icon': Icons.credit_card},
      {
        'id': 'bank',
        'label': 'pay_by_bank'.tr(),
        'icon': Icons.account_balance,
      },
      {
        'id': 'cod',
        'label': 'pay_on_delivery'.tr(),
        'icon': Icons.delivery_dining,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'checkout'.tr(),
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
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'address'.tr(),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              hintText: 'enter_address'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: const Color(0xFFF5F0F0),
              filled: true,
            ),
            onChanged: (val) => setState(() => address = val),
          ),
          const SizedBox(height: 24),
          Text(
            'payment_method'.tr(),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...paymentMethods.map(
            (method) => ListTile(
              title: Text(method['label'] as String),
              leading: Icon(
                method['icon'] as IconData,
                color: const Color(0xFF8c5f5f),
              ),
              trailing: Radio<String>(
                value: method['id'] as String,
                groupValue: selectedPayment,
                onChanged: (val) => setState(() => selectedPayment = val!),
                activeColor: const Color(0xFFF93838),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF93838),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: address.trim().isEmpty
                  ? null
                  : () {
                      // هنا ترفع الطلب إلى القاعدة (Supabase) إذا كان جاهز
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('order_confirmed'.tr())),
                      );
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    },
              child: Text(
                'confirm_order'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
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
