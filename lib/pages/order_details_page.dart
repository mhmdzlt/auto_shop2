import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'package:auto_shop/services/invoice_service.dart';
import 'language_selector.dart';
import 'review_form.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool loadingInvoice = false;
  bool invoiceGenerated = false;
  String? paymentStatus;
  String? invoiceUrl;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  Future<bool> _isValidPdfUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200 &&
          response.headers['content-type']?.contains('pdf') == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('file_open_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkPaymentStatus() async {
    try {
      // Check order payment status
      final orderResponse = await Supabase.instance.client
          .from('orders')
          .select('payment_status, invoice_generated')
          .eq('id', widget.order.id)
          .single();

      // Check for invoice URL in payment_transactions
      final transactionResponse = await Supabase.instance.client
          .from('payment_transactions')
          .select('invoice_url, status')
          .eq('order_id', widget.order.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          paymentStatus = orderResponse['payment_status'];
          invoiceGenerated = orderResponse['invoice_generated'] ?? false;

          // Get invoice URL from transaction if available
          if (transactionResponse != null &&
              transactionResponse['invoice_url'] != null) {
            invoiceUrl = transactionResponse['invoice_url'] as String;
            invoiceGenerated = true;
          }
        });
      }
    } catch (e) {
      debugPrint('Error checking payment status: $e');
    }
  }

  Future<void> _downloadInvoice() async {
    setState(() => loadingInvoice = true);

    try {
      // إذا كانت الفاتورة موجودة في Supabase، قم بفتحها
      if (invoiceUrl != null && await _isValidPdfUrl(invoiceUrl!)) {
        // Open the URL (using url_launcher)
        final url = Uri.parse(invoiceUrl!);
        await _launchUrl(url);
      } else {
        // جلب بيانات الطلب الكاملة من قاعدة البيانات
        final orderData = await Supabase.instance.client
            .from('orders')
            .select('*')
            .eq('id', widget.order.id)
            .single();

        final orderItems = List<Map<String, dynamic>>.from(
          orderData['order_items'] ?? [],
        );

        // توليد الفاتورة
        final pdfData = await InvoiceService.generateInvoice(
          order: orderData,
          orderItems: orderItems,
        );

        // طباعة أو حفظ الفاتورة
        await InvoiceService.printOrSaveInvoice(pdfData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('invoice_downloaded'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('invoice_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loadingInvoice = false);
      }
    }
  }

  Future<void> _shareInvoice() async {
    setState(() => loadingInvoice = true);

    try {
      if (invoiceUrl != null) {
        // Share the URL directly if available
        final url = Uri.parse(invoiceUrl!);
        await Share.share('فاتورة الطلب: $url', subject: 'Auto Shop Invoice');
      } else {
        final orderData = await Supabase.instance.client
            .from('orders')
            .select('*')
            .eq('id', widget.order.id)
            .single();

        final orderItems = List<Map<String, dynamic>>.from(
          orderData['order_items'] ?? [],
        );

        final pdfData = await InvoiceService.generateInvoice(
          order: orderData,
          orderItems: orderItems,
        );

        await InvoiceService.shareInvoice(pdfData, widget.order.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('invoice_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loadingInvoice = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${'order_number'.tr()} ${widget.order.id.substring(0, 8)}',
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          // معلومات الفاتورة
          if (paymentStatus == 'completed' || invoiceGenerated)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'invoice'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: loadingInvoice ? null : _downloadInvoice,
                          icon: loadingInvoice
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text('download_invoice'.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF93838),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: loadingInvoice ? null : _shareInvoice,
                          icon: const Icon(Icons.share),
                          tooltip: 'share_invoice'.tr(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          // معلومات الطلب
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'order_info'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${'order_date'.tr()}:',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(widget.order.createdAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (paymentStatus != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'payment_status'.tr()}:',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPaymentStatusColor(paymentStatus!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getPaymentStatusText(paymentStatus!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // قائمة المنتجات
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'order_items'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...widget.order.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'قطعة: ${item.partId}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'الكمية: ${item.quantity}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${item.unitPrice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF93838),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 20),
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
                        '\$${widget.order.totalPrice}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF93838),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // أزرار الفاتورة
          if (paymentStatus == 'succeeded' || paymentStatus == 'paid') ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: loadingInvoice ? null : _downloadInvoice,
                    icon: loadingInvoice
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.download),
                    label: Text('download_invoice'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF93838),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: loadingInvoice ? null : _shareInvoice,
                    icon: const Icon(Icons.share),
                    label: Text('share_invoice'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'invoice_available_after_payment'.tr(),
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
      case 'paid':
        return 'مدفوع';
      case 'pending':
        return 'في الانتظار';
      case 'failed':
        return 'فشل';
      default:
        return 'غير محدد';
    }
  }
}
