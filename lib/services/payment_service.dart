import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  static const String _publishableKey = 'pk_test_51...'; // ضع مفتاحك هنا
  static final supabase = Supabase.instance.client;

  static Future<void> init() async {
    Stripe.publishableKey = _publishableKey;
  }

  /// إنشاء Payment Intent عبر Supabase Edge Function
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    required String orderId,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'create-payment-intent',
        body: {
          'amount': (amount * 100).round(), // المبلغ بالسنت
          'currency': currency.toLowerCase(),
          'order_id': orderId,
        },
      );

      if (response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
    }
    return null;
  }

  /// تنفيذ عملية الدفع مع معالجة الأخطاء المحسّنة
  static Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required String orderId,
    required String customerEmail,
  }) async {
    try {
      // التحقق من صحة المبلغ
      if (amount <= 0) {
        await _logPaymentAttempt(
          orderId: orderId,
          status: 'failed',
          errorCode: 'invalid_amount',
          errorMessage: 'المبلغ غير صحيح',
        );
        return PaymentResult(success: false, error: 'المبلغ غير صحيح');
      }

      // التحقق من الاتصال بالإنترنت
      if (!await _checkInternetConnection()) {
        return PaymentResult(
          success: false,
          error: 'يرجى التحقق من الاتصال بالإنترنت',
        );
      }

      // 1. إنشاء Payment Intent
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        currency: currency,
        orderId: orderId,
      );

      if (paymentIntentData == null) {
        return PaymentResult(
          success: false,
          error: 'فشل في إنشاء عملية الدفع. يرجى المحاولة مرة أخرى.',
        );
      }

      // 2. إعداد Payment Sheet مع إعدادات محسّنة
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Auto Shop',
          customerEphemeralKeySecret: paymentIntentData['ephemeral_key'],
          customerId: paymentIntentData['customer'],
          style: ThemeMode.light,
          billingDetails: BillingDetails(
            email: customerEmail,
            name: paymentIntentData['customer_name'],
          ),
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'US'),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true, // تغيير إلى false في الإنتاج
          ),
          allowsDelayedPaymentMethods: true,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFFF93838),
            ),
            shapes: PaymentSheetShape(borderRadius: 12),
          ),
        ),
      );

      // 3. عرض Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. التحقق من نجاح العملية
      final paymentStatus = await _verifyPaymentIntent(paymentIntentData['id']);

      if (paymentStatus == 'succeeded') {
        // 5. حفظ معلومات الدفع في قاعدة البيانات
        await _savePaymentTransaction(
          orderId: orderId,
          paymentIntentId: paymentIntentData['id'],
          amount: amount,
          currency: currency,
          status: 'succeeded',
        );

        // تسجيل نجاح العملية
        await _logPaymentAttempt(orderId: orderId, status: 'succeeded');

        return PaymentResult(
          success: true,
          transactionId: paymentIntentData['id'],
        );
      } else {
        await _logPaymentAttempt(
          orderId: orderId,
          status: 'failed',
          errorCode: 'verification_failed',
          errorMessage: 'فشل في التحقق من عملية الدفع',
        );
        return PaymentResult(
          success: false,
          error: 'فشل في التحقق من عملية الدفع',
        );
      }
    } on StripeException catch (e) {
      // استخدام دالة تحليل الأخطاء المحسّنة
      final errorMessage = _analyzeStripeError(e);

      // تسجيل تفاصيل الخطأ
      await _logPaymentAttempt(
        orderId: orderId,
        status: 'failed',
        errorCode: e.error.code.toString(),
        errorMessage: e.error.message,
      );

      debugPrint('Stripe Error: ${e.error.message}');
      debugPrint('Error Type: ${e.error.type}');
      debugPrint('Decline Code: ${e.error.declineCode}');

      return PaymentResult(success: false, error: errorMessage);
    } catch (e) {
      debugPrint('Unexpected payment error: $e');
      return PaymentResult(
        success: false,
        error: 'حدث خطأ غير متوقع في عملية الدفع. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  /// معالجة دفع Stripe مع try-catch محسّن ومعالجة شاملة للأخطاء
  static Future<bool> processStripePayment(String clientSecret) async {
    try {
      // التحقق من صحة clientSecret
      if (clientSecret.isEmpty) {
        _showToast("خطأ في بيانات الدفع", type: ToastType.error);
        return false;
      }

      // محاولة تأكيد الدفع
      final result = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      // معالجة النتائج المختلفة
      switch (result.status) {
        case PaymentIntentsStatus.Succeeded:
          _showToast("تم الدفع بنجاح", type: ToastType.success);
          return true;

        case PaymentIntentsStatus.Canceled:
          _showToast("تم إلغاء عملية الدفع", type: ToastType.warning);
          return false;

        case PaymentIntentsStatus.RequiresAction:
          _showToast("يتطلب تأكيد إضافي من البنك", type: ToastType.info);
          // يمكن هنا استدعاء handle3DSecure
          return false;

        case PaymentIntentsStatus.RequiresPaymentMethod:
          _showToast("يرجى اختيار طريقة دفع صالحة", type: ToastType.error);
          return false;

        case PaymentIntentsStatus.Processing:
          _showToast("جاري معالجة الدفع...", type: ToastType.info);
          return false;

        default:
          _showToast("فشل الدفع: ${result.status}", type: ToastType.error);
          return false;
      }
    } on StripeException catch (e) {
      debugPrint("Stripe Error Details:");
      debugPrint("  Code: ${e.error.code}");
      debugPrint("  Type: ${e.error.type}");
      debugPrint("  Message: ${e.error.message}");
      debugPrint("  Decline Code: ${e.error.declineCode}");

      // استخدام دالة تحليل الأخطاء المحسّنة
      final errorMessage = _analyzeStripeError(e);
      _showToast(errorMessage, type: ToastType.error);
      return false;
    } catch (e) {
      debugPrint("Unexpected Payment Error: $e");
      _showToast("فشل الدفع: حدث خطأ غير متوقع", type: ToastType.error);
      return false;
    }
  }

  /// التحقق من حالة Payment Intent
  static Future<String?> _verifyPaymentIntent(String paymentIntentId) async {
    try {
      final response = await supabase.functions.invoke(
        'verify-payment-intent',
        body: {'payment_intent_id': paymentIntentId},
      );

      return response.data?['status'];
    } catch (e) {
      debugPrint('Error verifying payment intent: $e');
      return null;
    }
  }

  /// التحقق من الاتصال بالإنترنت
  static Future<bool> _checkInternetConnection() async {
    try {
      final response = await supabase.functions.invoke('ping');
      return response.data != null;
    } catch (e) {
      return false;
    }
  }

  /// حفظ معلومات المعاملة
  static Future<void> _savePaymentTransaction({
    required String orderId,
    required String paymentIntentId,
    required double amount,
    required String currency,
    required String status,
  }) async {
    await supabase.from('payment_transactions').insert({
      'order_id': orderId,
      'payment_intent_id': paymentIntentId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
    });

    // تحديث حالة الطلب
    await supabase
        .from('orders')
        .update({'payment_status': status, 'transaction_id': paymentIntentId})
        .eq('id', orderId);
  }

  /// التحقق من حالة الدفع مع إعادة المحاولة
  static Future<String?> getPaymentStatus(String orderId) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await supabase
            .from('orders')
            .select('payment_status')
            .eq('id', orderId)
            .single();
        return response['payment_status'];
      } catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: retryCount));
        }
      }
    }
    return null;
  }

  /// استرداد مبلغ الدفع
  static Future<PaymentResult> refundPayment({
    required String paymentIntentId,
    required double amount,
    String? reason,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'create-refund',
        body: {
          'payment_intent': paymentIntentId,
          'amount': (amount * 100).round(), // المبلغ بالسنت
          'reason': reason ?? 'requested_by_customer',
        },
      );

      if (response.data != null && response.data['success'] == true) {
        return PaymentResult(
          success: true,
          transactionId: response.data['refund_id'],
        );
      } else {
        return PaymentResult(success: false, error: 'فشل في عملية الاسترداد');
      }
    } catch (e) {
      debugPrint('Refund error: $e');
      return PaymentResult(
        success: false,
        error: 'حدث خطأ أثناء عملية الاسترداد',
      );
    }
  }

  /// حفظ طريقة الدفع للاستخدام المستقبلي
  static Future<bool> savePaymentMethod({
    required String customerId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'attach-payment-method',
        body: {'customer_id': customerId, 'payment_method_id': paymentMethodId},
      );

      return response.data?['success'] == true;
    } catch (e) {
      debugPrint('Error saving payment method: $e');
      return false;
    }
  }

  /// إعداد 3D Secure للمدفوعات
  static Future<PaymentResult> handle3DSecure({
    required String paymentIntentId,
    required String returnUrl,
  }) async {
    try {
      final result = await Stripe.instance.handleNextAction(paymentIntentId);

      if (result.status == PaymentIntentsStatus.Succeeded) {
        return PaymentResult(success: true, transactionId: paymentIntentId);
      } else if (result.status == PaymentIntentsStatus.RequiresAction) {
        return PaymentResult(
          success: false,
          error: 'يتطلب تأكيد إضافي من البنك',
        );
      } else {
        return PaymentResult(success: false, error: 'فشل في التحقق الإضافي');
      }
    } catch (e) {
      debugPrint('3D Secure error: $e');
      return PaymentResult(success: false, error: 'خطأ في التحقق الأمني');
    }
  }

  /// تحليل أخطاء Stripe وإرجاع رسالة مناسبة
  static String _analyzeStripeError(StripeException e) {
    final errorType = e.error.type;
    final declineCode = e.error.declineCode;

    // معالجة أخطاء البطاقة
    if (errorType == 'card_error') {
      switch (declineCode) {
        case 'insufficient_funds':
          return 'الرصيد غير كافي في البطاقة';
        case 'card_declined':
          return 'تم رفض البطاقة من قبل البنك. يرجى التواصل مع البنك';
        case 'expired_card':
          return 'البطاقة منتهية الصلاحية';
        case 'incorrect_cvc':
          return 'رمز الأمان (CVC) غير صحيح';
        case 'incorrect_number':
          return 'رقم البطاقة غير صحيح';
        case 'processing_error':
          return 'خطأ في معالجة البطاقة. يرجى المحاولة مرة أخرى';
        case 'lost_card':
          return 'البطاقة مفقودة. يرجى التواصل مع البنك';
        case 'stolen_card':
          return 'البطاقة مسروقة. يرجى التواصل مع البنك';
        default:
          return 'خطأ في بيانات البطاقة: ${e.error.localizedMessage}';
      }
    }

    // معالجة أخطاء الشبكة
    if (errorType == 'api_connection_error') {
      return 'مشكلة في الاتصال. يرجى التحقق من الإنترنت والمحاولة مرة أخرى';
    }

    // معالجة أخطاء API
    if (errorType == 'api_error') {
      return 'خطأ في الخدمة. يرجى المحاولة بعد قليل';
    }

    // معالجة أخطاء التوثيق
    if (errorType == 'authentication_error') {
      return 'خطأ في التوثيق. يرجى التواصل مع الدعم الفني';
    }

    // معالجة أخطاء التحقق
    if (errorType == 'invalid_request_error') {
      return 'طلب غير صالح. يرجى التحقق من البيانات';
    }

    // رسالة افتراضية
    return e.error.localizedMessage ?? 'حدث خطأ في عملية الدفع';
  }

  /// إضافة مؤشر تحميل أثناء عملية الدفع
  static Future<PaymentResult> processPaymentWithLoading({
    required double amount,
    required String currency,
    required String orderId,
    required String customerEmail,
    required BuildContext context,
  }) async {
    // إظهار مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF93838)),
              ),
              SizedBox(height: 16),
              Text('جاري معالجة عملية الدفع...'),
            ],
          ),
        );
      },
    );

    try {
      final result = await processPayment(
        amount: amount,
        currency: currency,
        orderId: orderId,
        customerEmail: customerEmail,
      );

      // إخفاء مؤشر التحميل
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      return result;
    } catch (e) {
      // إخفاء مؤشر التحميل في حالة الخطأ
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return PaymentResult(success: false, error: 'حدث خطأ أثناء معالجة الدفع');
    }
  }

  /// معاينة تفاصيل الدفع قبل التأكيد
  static Future<bool> showPaymentPreview({
    required BuildContext context,
    required double amount,
    required String currency,
    required List<Map<String, dynamic>> items,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('تأكيد عملية الدفع'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المبلغ الإجمالي: $amount $currency'),
                  const SizedBox(height: 8),
                  const Text('المنتجات:'),
                  const SizedBox(height: 4),
                  ...items
                      .take(3)
                      .map(
                        (item) =>
                            Text('• ${item['name']} (${item['quantity']}x)'),
                      ),
                  if (items.length > 3)
                    Text('... و ${items.length - 3} منتجات أخرى'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.security, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'عملية دفع آمنة ومحمية بتقنية Stripe',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF93838),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('تأكيد الدفع'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// تسجيل محاولات الدفع للتحليل
  static Future<void> _logPaymentAttempt({
    required String orderId,
    required String status,
    String? errorCode,
    String? errorMessage,
  }) async {
    try {
      await supabase.from('payment_logs').insert({
        'order_id': orderId,
        'status': status,
        'error_code': errorCode,
        'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
        'user_agent': 'Flutter App',
      });
    } catch (e) {
      debugPrint('Error logging payment attempt: $e');
    }
  }

  /// إظهار رسالة Toast للمستخدم مع تصنيف الرسائل
  static void _showToast(String message, {ToastType type = ToastType.info}) {
    // في بيئة التطوير، استخدم debugPrint مع تصنيف
    String prefix = '';
    switch (type) {
      case ToastType.success:
        prefix = '✅ SUCCESS';
        break;
      case ToastType.error:
        prefix = '❌ ERROR';
        break;
      case ToastType.warning:
        prefix = '⚠️ WARNING';
        break;
      case ToastType.info:
        prefix = 'ℹ️ INFO';
        break;
    }

    debugPrint('$prefix Toast: $message');
    // يمكن استبدال هذا بمكتبة Toast مثل fluttertoast عند الحاجة
    // مثال:
    // Fluttertoast.showToast(
    //   msg: message,
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.BOTTOM,
    //   backgroundColor: _getToastColor(type),
    // );
  }

  /// إرجاع لون Toast حسب النوع
  static Color _getToastColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
        return Colors.blue;
    }
  }
}

/// أنواع رسائل Toast
enum ToastType { success, error, warning, info }

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? error;

  PaymentResult({required this.success, this.transactionId, this.error});
}
