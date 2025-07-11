import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  XFile? pickedImage;
  bool loading = false;
  String? error;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => pickedImage = img);
    }
  }

  Future<String?> uploadImage(XFile img) async {
    final bytes = await img.readAsBytes();
    final filename =
        'products/${DateTime.now().millisecondsSinceEpoch}_${img.name}';
    final response = await Supabase.instance.client.storage
        .from('product-images')
        .uploadBinary(
          filename,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    if (response.isEmpty) return null;
    return Supabase.instance.client.storage
        .from('product-images')
        .getPublicUrl(filename);
  }

  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });

    String? imageUrl;
    if (pickedImage != null) {
      imageUrl = await uploadImage(pickedImage!);
      if (imageUrl == null) {
        setState(() {
          error = 'image_upload_error'.tr();
          loading = false;
        });
        return;
      }
    }

    final result = await Supabase.instance.client.from('products').insert({
      'name': nameCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'price': double.tryParse(priceCtrl.text.trim()) ?? 0,
      'image_url': imageUrl,
      // أضف brand_id, section_id إذا تريد حسب التصميم
    });

    setState(() => loading = false);
    if (result == null || (result is List && result.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('product_added'.tr())));
      Navigator.pop(context);
    } else {
      setState(() => error = 'unexpected_error'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_product'.tr()),
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            InkWell(
              onTap: pickImage,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0F0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: pickedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(pickedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_a_photo,
                              color: Color(0xFF8c5f5f),
                              size: 32,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'choose_image'.tr(),
                              style: const TextStyle(color: Color(0xFF8c5f5f)),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'product_name'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'required_field'.tr() : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'product_desc'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'required_field'.tr() : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'product_price'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffix: Text('currency'.tr()),
              ),
              validator: (v) => v!.isEmpty ? 'required_field'.tr() : null,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: loading ? null : addProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF93838),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'add'.tr(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ويدجت اختيار اللغة
class LanguageSelector extends StatelessWidget {
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
