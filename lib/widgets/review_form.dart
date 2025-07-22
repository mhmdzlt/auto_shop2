import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewForm extends StatefulWidget {
  final String productId;
  const ReviewForm({Key? key, required this.productId}) : super(key: key);

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;

  Future<void> submitReview() async {
    setState(() => _submitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تسجيل الدخول لتقييم المنتج')),
        );
        return;
      }
      await Supabase.instance.client.from('product_reviews').insert({
        'user_id': user.id,
        'product_id': widget.productId,
        'rating': _rating,
        'comment': _commentController.text,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم إرسال التقييم بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ خطأ أثناء إرسال التقييم')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("قيّم المنتج"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("اختر تقييمك:"),
          DropdownButton<int>(
            value: _rating,
            items: List.generate(5, (i) => i + 1)
                .map((e) => DropdownMenuItem(value: e, child: Text('$e نجوم')))
                .toList(),
            onChanged: (val) => setState(() => _rating = val ?? 5),
          ),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: "تعليق (اختياري)"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : submitReview,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("إرسال"),
        ),
      ],
    );
  }
}
