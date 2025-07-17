import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/addresses_provider.dart';
import '../models/address.dart';
import '../providers/orders_provider.dart';
import '../models/order.dart';
import '../services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final List<OrderItem> cartItems;
  final double totalPrice;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.totalPrice,
  });

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  String selectedPayment = 'cod';
  final _cardController = TextEditingController();
  final _gatewayController = TextEditingController();
  Address? selectedAddress;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(addressesProvider);

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
          // عرض معلومات الطلب
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'order_summary'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${widget.cartItems.length} ${'items'.tr()}'),
                  const SizedBox(height: 4),
                  Text(
                    '${'total'.tr()}: ${widget.totalPrice} ${'currency'.tr()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // اختيار العنوان
          Text(
            'delivery_address'.tr(),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          addressesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('error_loading_addresses'.tr()),
                    ElevatedButton(
                      onPressed: () => ref.refresh(addressesProvider),
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              ),
            ),
            data: (addresses) {
              if (addresses.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.location_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('no_addresses_found'.tr()),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/addresses'),
                          child: Text('add_address'.tr()),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // البحث عن العنوان الافتراضي
              if (selectedAddress == null) {
                selectedAddress = addresses.firstWhere(
                  (addr) => addr.isDefault,
                  orElse: () => addresses.first,
                );
              }

              return Column(
                children: addresses.map((address) {
                  return Card(
                    color: selectedAddress?.id == address.id
                        ? const Color(0xFFF93838).withOpacity(0.1)
                        : null,
                    child: ListTile(
                      title: Text(address.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(address.details),
                          Text('${address.city}, ${address.country}'),
                          if (address.phone?.isNotEmpty == true)
                            Text(address.phone!),
                        ],
                      ),
                      leading: Radio<String>(
                        value: address.id,
                        groupValue: selectedAddress?.id,
                        onChanged: (val) {
                          setState(() {
                            selectedAddress = address;
                          });
                        },
                        activeColor: const Color(0xFFF93838),
                      ),
                      trailing: address.isDefault
                          ? const Icon(Icons.star, color: Colors.amber)
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
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
          if (selectedPayment == 'card') ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بيانات البطاقة البنكية',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cardController,
                      decoration: const InputDecoration(
                        labelText: 'رقم البطاقة',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (selectedPayment == 'bank') ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بوابة الدفع الإلكتروني',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _gatewayController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف أو حساب الدفع',
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
              onPressed: selectedAddress == null || isLoading
                  ? null
                  : () async {
                      if (selectedAddress == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('please_select_address'.tr())),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      String paymentStatus = 'pending';
                      String paymentType = selectedPayment;
                      String? paymentDetails;

                      // محاكاة الدفع الإلكتروني
                      if (selectedPayment == 'card') {
                        // هنا يتم ربط Stripe أو FastPay/ZainCash
                        if (_cardController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('يرجى إدخال رقم البطاقة')),
                          );
                          setState(() => isLoading = false);
                          return;
                        }
                        paymentStatus = 'paid';
                        paymentDetails = _cardController.text;
                      } else if (selectedPayment == 'bank') {
                        if (_gatewayController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('يرجى إدخال حساب الدفع')),
                          );
                          setState(() => isLoading = false);
                          return;
                        }
                        paymentStatus = 'paid';
                        paymentDetails = _gatewayController.text;
                      } else {
                        paymentStatus = 'pending';
                        paymentDetails = null;
                      }

                      try {
                        final userId =
                            Supabase.instance.client.auth.currentUser!.id;
                        final order = Order(
                          id: '',
                          userId: userId,
                          totalPrice: widget.totalPrice,
                          createdAt: DateTime.now(),
                          items: widget.cartItems,
                          status: OrderStatus.pending,
                          addressId: selectedAddress!.id,
                        );

                        await Supabase.instance.client.from('orders').insert({
                          'user_id': userId,
                          'total_price': widget.totalPrice,
                          'status': 'pending',
                          'address_id': selectedAddress!.id,
                          'payment_status': paymentStatus,
                          'payment_type': paymentType,
                          'payment_details': paymentDetails,
                          'order_items': widget.cartItems
                              .map((item) => item.toJson())
                              .toList(),
                        });

                        await ref.read(ordersProvider.notifier).addOrder(order);

                        await NotificationService.showOrderNotification(
                          title: 'تم إرسال طلبك بنجاح',
                          body: 'سيتم مراجعة الطلب قريباً',
                        );

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('order_confirmed'.tr())),
                          );
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName('/home'),
                          );
                        }
                      } catch (error) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('order_failed'.tr())),
                          );
                        }
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
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
