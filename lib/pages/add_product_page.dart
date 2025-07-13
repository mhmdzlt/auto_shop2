import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final supabase = Supabase.instance.client;
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final imageController = TextEditingController();

  Future<void> addProduct() async {
    await supabase.from('products').insert({
      'name': nameController.text,
      'description': descController.text,
      'price': double.tryParse(priceController.text) ?? 0,
      'image': imageController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إضافة المنتج!')),
    );
    nameController.clear();
    descController.clear();
    priceController.clear();
    imageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة منتج')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم المنتج')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'الوصف')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
            TextField(controller: imageController, decoration: const InputDecoration(labelText: 'رابط الصورة')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addProduct,
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}
