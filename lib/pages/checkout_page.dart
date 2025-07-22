import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/addresses_provider.dart';
import '../models/address.dart';
import '../providers/orders_provider.dart';
import '../models/order.dart';
import '../services/notification_service.dart';
import '../services/payment_service.dart';
import 'package:auto_shop/services/invoice_service.dart';
import 'package:auto_shop/services/email_service.dart';
import '../widgets/payment_widgets.dart';
import '../services/promo_service.dart'; // إضافة خدمة الكوبونات

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
  final _gatewayController = TextEditingController();
  Address? selectedAddress;
  bool isLoading = false;
  String promoInput = '';
  double discountPercentage = 0.0;
  double discountAmount = 0.0;
  bool freeShipping = false;

  /// تطبيق كود الخصم
  void _applyPromoCode() {
    final promo = PromoService.validateCode(promoInput.trim());
    if (promo != null) {
      setState(() {
        discountPercentage = promo['discount'] ?? 0.0;
        freeShipping = promo['freeShipping'] ?? false;
        discountAmount = discountPercentage * widget.totalPrice;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ تم تطبيق الكود بنجاح')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ كود الخصم غير صالح أو منتهي')),
      );
    }
  }

  Future<void> _processOrder() async {
    final double finalAmount = (widget.totalPrice - discountAmount).clamp(
      0.0,
      double.infinity,
    );
    if (selectedAddress == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('please_select_address'.tr())));
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final user = Supabase.instance.client.auth.currentUser;
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final amountToPay = finalAmount;

      String paymentStatus = 'pending';
      String? transactionId;

      // معالجة الدفع حسب النوع المختار
      if (selectedPayment == 'stripe') {
        // عرض معاينة الدفع قبل التأكيد
        final shouldProceed = await PaymentService.showPaymentPreview(
          context: context,
          amount: amountToPay,
          currency: 'USD',
          items: widget.cartItems
              .map((item) => {'name': item.partId, 'quantity': item.quantity})
              .toList(),
        );

        if (!shouldProceed) {
          setState(() => isLoading = false);
          return;
        }

        // الدفع عبر Stripe
        final paymentResult = await PaymentService.processPaymentWithLoading(
          amount: amountToPay,
          currency: 'USD',
          orderId: orderId,
          customerEmail: user?.email ?? 'guest@autoshop.com',
          context: context,
        );

        if (!paymentResult.success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(paymentResult.error ?? 'payment_failed'.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        paymentStatus = 'succeeded';
        transactionId = paymentResult.transactionId;
      } else if (selectedPayment == 'bank') {
        if (_gatewayController.text.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('يرجى إدخال حساب الدفع')));
          }
          return;
        }
        paymentStatus = 'paid';
        transactionId = 'bank_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        // الدفع عند الاستلام
        paymentStatus = 'pending';
        transactionId = null;
      }

      // حفظ الطلب في قاعدة البيانات
      final orderData = {
        'id': orderId,
        'user_id': userId,
        'total_price': finalAmount,
        'status': 'pending',
        'address_id': selectedAddress!.id,
        'payment_status': paymentStatus,
        'payment_type': selectedPayment,
        'transaction_id': transactionId,
        'order_items': widget.cartItems.map((item) => item.toJson()).toList(),
        'created_at': DateTime.now().toIso8601String(),
        'discount_percentage': discountPercentage,
        'discount_amount': discountAmount,
        'free_shipping': freeShipping,
      };

      await Supabase.instance.client.from('orders').insert(orderData);

      // إنشاء نموذج الطلب للتطبيق
      final order = Order(
        id: orderId,
        userId: userId,
        totalPrice: widget.totalPrice,
        createdAt: DateTime.now(),
        items: widget.cartItems,
        status: OrderStatus.pending,
        addressId: selectedAddress!.id,
      );

      await ref.read(ordersProvider.notifier).addOrder(order);

      // إرسال إشعار
      await NotificationService.showOrderNotification(
        title: 'order_confirmed'.tr(),
        body: paymentStatus == 'succeeded'
            ? 'order_paid_successfully'.tr()
            : 'order_processing'.tr(),
      );

      // توليد الفاتورة إذا تم الدفع بنجاح
      if (paymentStatus == 'succeeded') {
        await _generateInvoice(orderData);
      }

      if (mounted) {
        // عرض حالة الدفع إذا تم بنجاح
        if (paymentStatus == 'succeeded') {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => PaymentStatusWidget(
              orderId: orderId,
              onPaymentSuccess: () {
                Navigator.of(context).pop();
              },
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('order_confirmed'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil(ModalRoute.withName('/home'));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('order_failed'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// توليد الفاتورة للطلب
  Future<void> _generateInvoice(Map<String, dynamic> orderData) async {
    try {
      final orderDetails = {
        'user_name':
            Supabase
                .instance
                .client
                .auth
                .currentUser
                ?.userMetadata?['full_name'] ??
            'Customer',
        'date': orderData['created_at'],
        'items': widget.cartItems
            .map(
              (item) => {
                'name': item.partId,
                'quantity': item.quantity,
                'price': item.unitPrice.toStringAsFixed(2),
              },
            )
            .toList(),
        'total': orderData['total_price'].toStringAsFixed(2),
      };

      final pdfBytes = await InvoiceService.generateInvoicePdf(
        orderId: orderData['id'],
        orderDetails: orderDetails,
      );

      // حفظ الفاتورة محلياً
      final savedPath = await InvoiceService.saveInvoiceLocally(
        pdfBytes,
        orderData['id'],
      );

      if (savedPath != null) {
        debugPrint('Invoice saved at: $savedPath');
      }

      // إرسال الفاتورة عبر البريد الإلكتروني (اختياري)
      final user = Supabase.instance.client.auth.currentUser;
      if (user?.email != null) {
        final emailSent = await EmailService.sendInvoiceViaSupabase(
          toEmail: user!.email!,
          orderId: orderData['id'],
          pdfBytes: pdfBytes,
          customerName: orderDetails['user_name'] as String?,
        );

        if (emailSent) {
          debugPrint('Invoice email sent successfully');
        }
      }

      // حفظ مسار الفاتورة في قاعدة البيانات (اختياري)
      await Supabase.instance.client
          .from('orders')
          .update({
            'invoice_generated': true,
            'invoice_generated_at': DateTime.now().toIso8601String(),
            'invoice_path': savedPath,
          })
          .eq('id', orderData['id']);
    } catch (e) {
      debugPrint('Error generating invoice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(addressesProvider);

    final paymentMethods = [
      {
        'id': 'stripe',
        'label': 'stripe_payment'.tr(),
        'icon': Icons.credit_card,
      },
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
                    '${'total'.tr()}: ${widget.totalPrice.toStringAsFixed(2)} ${'currency'.tr()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // إدخال كود الخصم
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Promo Code',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) => promoInput = val,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _applyPromoCode,
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  if (discountPercentage > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discount: -${(discountPercentage * 100).toStringAsFixed(0)}%',
                          ),
                          Text(
                            'Discount Amount: -${discountAmount.toStringAsFixed(2)} ${'currency'.tr()}',
                          ),
                        ],
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
              selectedAddress ??= addresses.firstWhere(
                (addr) => addr.isDefault,
                orElse: () => addresses.first,
              );

              return Column(
                children: addresses.map((address) {
                  return Card(
                    color: selectedAddress?.id == address.id
                        ? const Color(0xFFF93838).withValues(alpha: 0.1)
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
          if (selectedPayment == 'stripe') ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'stripe_secure_payment'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'stripe_payment_info'.tr(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'stripe_test_card'.tr(),
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
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
                      await _processOrder();
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
