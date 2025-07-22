import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/part.dart';
import 'part_details_page.dart';

class DetectPartPage extends StatefulWidget {
  const DetectPartPage({super.key});

  @override
  State<DetectPartPage> createState() => _DetectPartPageState();
}

class _DetectPartPageState extends State<DetectPartPage> {
  String? _result;
  bool _loading = false;

  Future<void> _pickAndIdentify() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() => _loading = true);

    // ✳️ إرسال الصورة إلى خدمة AI خارجية (مثال)
    final bytes = await image.readAsBytes();
    final response = await http.post(
      Uri.parse(
        'https://your-ai-endpoint.com/classify',
      ), // استبدله بـ رابط فعلي
      headers: {
        'Content-Type': 'application/octet-stream',
        'Authorization': 'Bearer your-api-key',
      },
      body: bytes,
    );

    final data = jsonDecode(response.body);
    final label = data['label']; // مثال: "فلتر زيت"

    // 🔎 البحث في Supabase
    final supabase = Supabase.instance.client;
    final partsResponse = await supabase
        .from('parts')
        .select()
        .ilike('name', '%$label%');

    final parts = partsResponse;

    if (parts.isNotEmpty) {
      final foundPart = Part(
        id: parts[0]['id'],
        name: parts[0]['name'],
        imageUrl: parts[0]['image_url'],
        description: parts[0]['description'],
        price: double.parse(parts[0]['price'].toString()),
      );

      setState(() => _loading = false);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PartDetailsPage(part: foundPart)),
        );
      }
    } else {
      setState(() {
        _result = 'لا توجد نتائج مطابقة لـ "$label"';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التعرف على القطعة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('التقط صورة القطعة'),
              onPressed: _loading ? null : _pickAndIdentify,
            ),
            const SizedBox(height: 24),
            if (_loading) const CircularProgressIndicator(),
            if (_result != null)
              Text(_result!, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
