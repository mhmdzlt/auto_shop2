import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';

class AdminPromoPage extends StatefulWidget {
  const AdminPromoPage({super.key});

  @override
  State<AdminPromoPage> createState() => _AdminPromoPageState();
}

class _AdminPromoPageState extends State<AdminPromoPage> {
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  bool _loading = false;
  String? _message;

  Future<void> _submitPromo() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    final code = _codeController.text.trim().toUpperCase();
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    try {
      await Supabase.instance.client.from('promo_codes').insert({
        'code': code,
        'discount': discount,
        'expires': _expiryDate.toIso8601String(),
      });
      setState(() {
        _message = "✅ تم إنشاء كود الخصم";
      });
    } catch (e) {
      setState(() {
        _message = "❌ فشل إنشاء الكود: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _sendPromoNotification() async {
    final code = _codeController.text.trim().toUpperCase();
    try {
      await NotificationService.showPromotionNotification(
        title: "🎉 كود خصم جديد!",
        body: "استخدم $code واحصل على خصم خاص!",
      );
      setState(() {
        _message = "✅ تم إرسال الإشعار";
      });
    } catch (e) {
      setState(() {
        _message = "❌ فشل إرسال الإشعار: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة العروض")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: "كود الخصم"),
            ),
            TextField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "نسبة الخصم %"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("تاريخ الانتهاء: "),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _expiryDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _expiryDate = picked);
                  },
                  child: Text(
                    "${_expiryDate.year}/${_expiryDate.month}/${_expiryDate.day}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_message != null) ...[
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.startsWith('✅') ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitPromo,
                    child: const Text("إنشاء كود"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _sendPromoNotification,
                    child: const Text("إرسال إشعار"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
