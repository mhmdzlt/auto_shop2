import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart'; // غيّر اسم المسار إذا كان مختلف عندك

class PartDetailsPage extends StatelessWidget {
  const PartDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل القطعة')),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1978E5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          ),
          onPressed: () async {
            final user = Supabase.instance.client.auth.currentUser;
            if (user == null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginPage(onSuccess: () {
                  // Add your logic here for what should happen after successful login
                  Navigator.pop(context); // Example: pop back to details page
                })),
              );
            } else {
              // أضف هنا الكود الذي تريد تنفيذه إذا كان المستخدم مسجلاً الدخول
            }
          },
          child: const Text('عرض تفاصيل القطعة'),
        ),
      ),
    );
  }
}
