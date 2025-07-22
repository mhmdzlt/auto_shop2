import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  static const String _sendGridApiKey =
      'YOUR_SENDGRID_API_KEY'; // ضع مفتاح SendGrid هنا
  static const String _fromEmail = 'noreply@autoshop.com';
  static const String _fromName = 'Auto Shop';

  /// إرسال فاتورة PDF عبر البريد الإلكتروني
  static Future<bool> sendInvoiceByEmail({
    required String toEmail,
    required String orderId,
    required Uint8List pdfBytes,
    String? customerName,
  }) async {
    try {
      // تحويل PDF إلى base64
      final pdfBase64 = base64Encode(pdfBytes);

      // إعداد محتوى البريد الإلكتروني
      final emailData = {
        'personalizations': [
          {
            'to': [
              {'email': toEmail, 'name': customerName ?? 'Valued Customer'},
            ],
            'subject': 'Invoice for Order #$orderId - Auto Shop',
          },
        ],
        'from': {'email': _fromEmail, 'name': _fromName},
        'content': [
          {
            'type': 'text/html',
            'value': _buildEmailTemplate(orderId, customerName),
          },
        ],
        'attachments': [
          {
            'content': pdfBase64,
            'filename': 'invoice_$orderId.pdf',
            'type': 'application/pdf',
            'disposition': 'attachment',
          },
        ],
      };

      // إرسال البريد الإلكتروني عبر SendGrid
      final response = await http.post(
        Uri.parse('https://api.sendgrid.com/v3/mail/send'),
        headers: {
          'Authorization': 'Bearer $_sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(emailData),
      );

      if (response.statusCode == 202) {
        debugPrint('Invoice email sent successfully to $toEmail');
        return true;
      } else {
        debugPrint(
          'Failed to send email: ${response.statusCode} ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error sending invoice email: $e');
      return false;
    }
  }

  /// إرسال فاتورة باستخدام Supabase Edge Function
  static Future<bool> sendInvoiceViaSupabase({
    required String toEmail,
    required String orderId,
    required Uint8List pdfBytes,
    String? customerName,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      // تحويل PDF إلى base64
      final pdfBase64 = base64Encode(pdfBytes);

      final response = await supabase.functions.invoke(
        'send-invoice-email',
        body: {
          'to_email': toEmail,
          'customer_name': customerName ?? 'Valued Customer',
          'order_id': orderId,
          'pdf_content': pdfBase64,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        debugPrint('Invoice email sent successfully via Supabase to $toEmail');
        return true;
      } else {
        debugPrint('Failed to send email via Supabase: ${response.data}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending invoice via Supabase: $e');
      return false;
    }
  }

  /// إرسال إشعار تأكيد الطلب
  static Future<bool> sendOrderConfirmationEmail({
    required String toEmail,
    required String orderId,
    required double totalAmount,
    String? customerName,
  }) async {
    try {
      final emailData = {
        'personalizations': [
          {
            'to': [
              {'email': toEmail, 'name': customerName ?? 'Valued Customer'},
            ],
            'subject': 'Order Confirmation #$orderId - Auto Shop',
          },
        ],
        'from': {'email': _fromEmail, 'name': _fromName},
        'content': [
          {
            'type': 'text/html',
            'value': _buildOrderConfirmationTemplate(
              orderId,
              totalAmount,
              customerName,
            ),
          },
        ],
      };

      final response = await http.post(
        Uri.parse('https://api.sendgrid.com/v3/mail/send'),
        headers: {
          'Authorization': 'Bearer $_sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(emailData),
      );

      return response.statusCode == 202;
    } catch (e) {
      debugPrint('Error sending order confirmation email: $e');
      return false;
    }
  }

  /// قالب البريد الإلكتروني للفاتورة
  static String _buildEmailTemplate(String orderId, String? customerName) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Invoice - Auto Shop</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .header { background-color: #F93838; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; }
        .footer { background-color: #f4f4f4; padding: 15px; text-align: center; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Auto Shop</h1>
        <p>Your trusted car parts store</p>
    </div>
    <div class="content">
        <h2>Dear ${customerName ?? 'Valued Customer'},</h2>
        <p>Thank you for your recent purchase with Auto Shop!</p>
        <p>Please find attached your invoice for order <strong>#$orderId</strong>.</p>
        <p>We appreciate your business and look forward to serving you again.</p>
        <p>If you have any questions about your order, please don't hesitate to contact us.</p>
        <br>
        <p>Best regards,<br>The Auto Shop Team</p>
    </div>
    <div class="footer">
        <p>&copy; 2025 Auto Shop. All rights reserved.</p>
        <p>This is an automated email. Please do not reply to this message.</p>
    </div>
</body>
</html>
    ''';
  }

  /// قالب البريد الإلكتروني لتأكيد الطلب
  static String _buildOrderConfirmationTemplate(
    String orderId,
    double totalAmount,
    String? customerName,
  ) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order Confirmation - Auto Shop</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .header { background-color: #F93838; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; }
        .order-details { background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .footer { background-color: #f4f4f4; padding: 15px; text-align: center; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Auto Shop</h1>
        <p>Order Confirmation</p>
    </div>
    <div class="content">
        <h2>Hello ${customerName ?? 'Valued Customer'},</h2>
        <p>Thank you for your order! We're excited to confirm that we've received your order and it's being processed.</p>
        
        <div class="order-details">
            <h3>Order Details:</h3>
            <p><strong>Order Number:</strong> #$orderId</p>
            <p><strong>Total Amount:</strong> \$${totalAmount.toStringAsFixed(2)}</p>
            <p><strong>Order Date:</strong> ${DateTime.now().toString().split(' ')[0]}</p>
        </div>
        
        <p>You will receive a shipping confirmation email with tracking information once your order has been dispatched.</p>
        <p>Thank you for choosing Auto Shop!</p>
        
        <br>
        <p>Best regards,<br>The Auto Shop Team</p>
    </div>
    <div class="footer">
        <p>&copy; 2025 Auto Shop. All rights reserved.</p>
        <p>Questions? Contact us at support@autoshop.com</p>
    </div>
</body>
</html>
    ''';
  }
}
