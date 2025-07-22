// import 'dart:typed_data'; // removed unused import
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../models/order.dart'; // removed unused import
import 'invoice_service.dart';

class PaymentInvoiceService {
  final _supabase = Supabase.instance.client;

  /// استمع إلى تحديثات حالة الدفع وقم بإنشاء الفواتير عند الحاجة
  Future<void> setupPaymentListeners() async {
    // إعداد الاستماع لتحديثات المدفوعات
    _supabase
        .channel('public:payment_transactions')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'payment_transactions',
          callback: _handlePaymentUpdate,
        )
        .subscribe();
  }

  /// معالجة تحديثات الدفع
  void _handlePaymentUpdate(PostgresChangePayload payload) async {
    final newRecord = payload.newRecord;

    // تحقق مما إذا تم اكتمال الدفع وليس لديه فاتورة بعد
    if (newRecord['status'] == 'completed' &&
        newRecord['invoice_url'] == null) {
      await _generateAndSaveInvoice(
        newRecord['order_id'] as String,
        newRecord['transaction_id'] as String,
        newRecord['payment_intent_id'] as String,
      );
    }
  }

  /// توليد وحفظ الفاتورة للطلب المكتمل
  Future<String?> _generateAndSaveInvoice(
    String orderId,
    String transactionId,
    String paymentIntentId,
  ) async {
    try {
      // 1. جلب بيانات الطلب
      final orderData = await _fetchOrderData(orderId);
      if (orderData == null) {
        print('لا يمكن العثور على الطلب: $orderId');
        return null;
      }

      // 2. جلب عناصر الطلب
      final orderItems = await _fetchOrderItems(orderId);
      if (orderItems.isEmpty) {
        print('لا توجد عناصر للطلب: $orderId');
        return null;
      }

      // 3. إنشاء الفاتورة PDF
      final pdfData = await InvoiceService.generateInvoice(
        order: {
          'id': orderId,
          'created_at': orderData['created_at'],
          'payment_status': 'succeeded',
          'transaction_id': transactionId,
          'address': orderData['address_details'] ?? 'غير محدد',
          'total': orderData['total_price'],
        },
        orderItems: orderItems,
      );

      // 4. حفظ الفاتورة في Supabase (مؤقتاً معطل)
      // return await InvoiceService.saveInvoiceToSupabase(
      //   pdfData,
      //   orderId,
      //   transactionId,
      // );

      print('Invoice generated with ${pdfData.length} bytes');
      return 'invoice_saved_locally'; // إرجاع مؤقت
    } catch (e) {
      print('خطأ في إنشاء أو حفظ الفاتورة: $e');
      return null;
    }
  }

  /// جلب بيانات الطلب
  Future<Map<String, dynamic>?> _fetchOrderData(String orderId) async {
    final response = await _supabase
        .from('orders')
        .select('''
        *,
        address:address_id (
          address_line,
          city,
          state,
          postal_code,
          country
        )
      ''')
        .eq('id', orderId)
        .single();

    // دمج عنوان التوصيل في سلسلة واحدة
    final address = response['address'];
    if (address != null) {
      final addressDetails =
          '${address['address_line']}, ${address['city']}, ${address['state']}, ${address['postal_code']}, ${address['country']}';
      response['address_details'] = addressDetails;
    }
    return response;
  }

  /// جلب عناصر الطلب
  Future<List<Map<String, dynamic>>> _fetchOrderItems(String orderId) async {
    final response = await _supabase
        .from('order_items')
        .select('''
        *,
        product:part_id (
          name,
          description
        )
      ''')
        .eq('order_id', orderId);

    // تنسيق البيانات للفاتورة
    return List<Map<String, dynamic>>.from(response).map((item) {
      return {
        'product_name': item['product']['name'],
        'quantity': item['quantity'],
        'price': item['unit_price'],
      };
    }).toList();
  }

  /// توليد فاتورة يدويًا لطلب محدد
  Future<String?> generateInvoiceManually(String orderId) async {
    try {
      // جلب بيانات المعاملة
      final transactionData = await _supabase
          .from('payment_transactions')
          .select()
          .eq('order_id', orderId)
          .single();

      // generate invoice assuming transactionData is returned
      return await _generateAndSaveInvoice(
        orderId,
        transactionData['transaction_id'] as String,
        transactionData['payment_intent_id'] as String,
      );
    } catch (e) {
      print('خطأ في توليد الفاتورة يدويًا: $e');
      return null;
    }
  }
}
