import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class InvoiceService {
  /// توليد فاتورة PDF للطلب
  static Future<Uint8List> generateInvoice({
    required Map<String, dynamic> order,
    required List<Map<String, dynamic>> orderItems,
  }) async {
    final pdf = pw.Document();

    // تحميل خط يدعم العربية
    final arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
    final arabicBoldFont = await PdfGoogleFonts.notoSansArabicBold();

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(arabicBoldFont),
              pw.SizedBox(height: 20),
              // معلومات الطلب
              _buildOrderInfo(order, arabicFont, arabicBoldFont),
              pw.SizedBox(height: 20),
              // جدول المنتجات
              _buildItemsTable(orderItems, arabicFont, arabicBoldFont),
              pw.SizedBox(height: 20),
              // المجموع النهائي
              _buildTotal(order, arabicFont, arabicBoldFont),
              pw.SizedBox(height: 30),
              // Footer
              _buildFooter(arabicFont),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// توليد فاتورة PDF محسّنة للطلب
  static Future<Uint8List> generateInvoicePdf({
    required String orderId,
    required Map<String, dynamic> orderDetails,
  }) async {
    final pdf = pw.Document();

    // تحميل خط يدعم العربية
    final arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
    final arabicBoldFont = await PdfGoogleFonts.notoSansArabicBold();

    pdf.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // رأس الفاتورة
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F93838'),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Auto Shop Invoice',
                      style: pw.TextStyle(
                        font: arabicBoldFont,
                        fontSize: 24,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'فاتورة شراء قطع غيار السيارات',
                      style: pw.TextStyle(
                        font: arabicBoldFont,
                        fontSize: 16,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // معلومات الطلب
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Order ID: $orderId',
                      style: pw.TextStyle(font: arabicBoldFont, fontSize: 14),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Customer: ${orderDetails['user_name'] ?? 'Guest'}',
                      style: pw.TextStyle(font: arabicFont, fontSize: 12),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Date: ${orderDetails['date'] ?? DateTime.now().toString().split(' ')[0]}',
                      style: pw.TextStyle(font: arabicFont, fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // جدول المنتجات
              pw.Text(
                'Items:',
                style: pw.TextStyle(font: arabicBoldFont, fontSize: 16),
              ),
              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      _buildTableCell(
                        'Product',
                        arabicBoldFont,
                        isHeader: true,
                      ),
                      _buildTableCell('Qty', arabicBoldFont, isHeader: true),
                      _buildTableCell('Price', arabicBoldFont, isHeader: true),
                      _buildTableCell('Total', arabicBoldFont, isHeader: true),
                    ],
                  ),
                  // Items
                  ...((orderDetails['items'] as List?) ?? []).map((item) {
                    final quantity = item['quantity'] ?? 1;
                    final price =
                        double.tryParse(item['price']?.toString() ?? '0') ?? 0;
                    final total = quantity * price;
                    return pw.TableRow(
                      children: [
                        _buildTableCell(
                          '${item['name'] ?? 'Unknown Item'}',
                          arabicFont,
                        ),
                        _buildTableCell('x$quantity', arabicFont),
                        _buildTableCell(
                          '\$${price.toStringAsFixed(2)}',
                          arabicFont,
                        ),
                        _buildTableCell(
                          '\$${total.toStringAsFixed(2)}',
                          arabicFont,
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),

              // المجموع النهائي
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total:',
                      style: pw.TextStyle(font: arabicBoldFont, fontSize: 18),
                    ),
                    pw.Text(
                      '\$${orderDetails['total'] ?? '0.00'}',
                      style: pw.TextStyle(font: arabicBoldFont, fontSize: 18),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// حفظ الفاتورة محلياً
  static Future<String?> saveInvoiceLocally(
    Uint8List pdfBytes,
    String orderId,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/invoice_$orderId.pdf');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving invoice: $e');
      return null;
    }
  }

  /// رأس الفاتورة
  static pw.Widget _buildHeader(pw.Font boldFont) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F93838'),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Auto Shop',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 24,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'فاتورة شراء قطع غيار السيارات',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// معلومات الطلب
  static pw.Widget _buildOrderInfo(
    Map<String, dynamic> order,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'رقم الطلب: ${order['id'] ?? 'غير محدد'}',
                    style: pw.TextStyle(font: boldFont, fontSize: 12),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'تاريخ الطلب: ${_formatDate(order['created_at'])}',
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'حالة الدفع: ${_getPaymentStatusArabic(order['payment_status'])}',
                    style: pw.TextStyle(font: boldFont, fontSize: 12),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'رقم المعاملة: ${order['transaction_id'] ?? 'غير محدد'}',
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            'عنوان التوصيل: ${order['address'] ?? 'غير محدد'}',
            style: pw.TextStyle(font: font, fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// جدول المنتجات
  static pw.Widget _buildItemsTable(
    List<Map<String, dynamic>> items,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('اسم المنتج', boldFont, isHeader: true),
            _buildTableCell('الكمية', boldFont, isHeader: true),
            _buildTableCell('السعر', boldFont, isHeader: true),
            _buildTableCell('المجموع', boldFont, isHeader: true),
          ],
        ),
        // Items
        ...items.map((item) {
          final quantity = item['quantity'] ?? 1;
          final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
          final total = quantity * price;
          return pw.TableRow(
            children: [
              _buildTableCell(item['product_name'] ?? 'منتج غير محدد', font),
              _buildTableCell(quantity.toString(), font),
              _buildTableCell('\$${price.toStringAsFixed(2)}', font),
              _buildTableCell('\$${total.toStringAsFixed(2)}', font),
            ],
          );
        }).toList(),
      ],
    );
  }

  /// المجموع النهائي
  static pw.Widget _buildTotal(
    Map<String, dynamic> order,
    pw.Font font,
    pw.Font boldFont,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'المجموع الكلي:',
            style: pw.TextStyle(font: boldFont, fontSize: 16),
          ),
          pw.Text(
            '\$${order['total_price']?.toStringAsFixed(2) ?? '0.00'}',
            style: pw.TextStyle(font: boldFont, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// ذيل الفاتورة
  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            'شكراً لتسوقكم معنا',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Center(
          child: pw.Text(
            'Auto Shop - Your trusted car parts store',
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ],
    );
  }

  /// خلية الجدول
  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// تنسيق التاريخ
  static String _formatDate(String? dateStr) {
    if (dateStr == null) return 'غير محدد';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'غير محدد';
    }
  }

  /// ترجمة حالة الدفع للعربية
  static String _getPaymentStatusArabic(String? status) {
    switch (status) {
      case 'succeeded':
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
