import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});
  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    final response = await Supabase.instance.client.from('products').select();
    setState(() {
      _products = response;
      _isLoading = false;
    });
  }

  Future<void> _deleteProduct(int id) async {
    await Supabase.instance.client.from('products').delete().eq('id', id);
    _fetchProducts();
  }

  void _showProductForm([dynamic product]) {
    showDialog(
      context: context,
      builder: (context) =>
          ProductFormDialog(product: product, onSaved: _fetchProducts),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة المنتجات', style: GoogleFonts.cairo())),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
        onPressed: () => _showProductForm(),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, i) {
                final p = _products[i];
                return ListTile(
                  leading: p['image'] != null
                      ? Image.network(p['image'], width: 40)
                      : Icon(Icons.image),
                  title: Text(p['name'] ?? '', style: GoogleFonts.cairo()),
                  subtitle: Text(
                    '${p['price'] ?? ''} د.ع',
                    style: GoogleFonts.cairo(color: Colors.green),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showProductForm(p),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(p['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class ProductFormDialog extends StatefulWidget {
  final dynamic product;
  final VoidCallback onSaved;
  const ProductFormDialog({super.key, this.product, required this.onSaved});
  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descController;
  late TextEditingController imageController;
  late TextEditingController categoryController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product?['name'] ?? '');
    priceController = TextEditingController(
      text: widget.product?['price']?.toString() ?? '',
    );
    descController = TextEditingController(
      text: widget.product?['description'] ?? '',
    );
    imageController = TextEditingController(
      text: widget.product?['image'] ?? '',
    );
    categoryController = TextEditingController(
      text: widget.product?['category_id']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descController.dispose();
    imageController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': nameController.text,
      'price': double.tryParse(priceController.text) ?? 0,
      'description': descController.text,
      'image': imageController.text,
      'category_id': int.tryParse(categoryController.text),
    };
    if (widget.product == null) {
      await Supabase.instance.client.from('products').insert(data);
    } else {
      await Supabase.instance.client
          .from('products')
          .update(data)
          .eq('id', widget.product['id']);
    }
    widget.onSaved();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.product == null ? 'إضافة منتج' : 'تعديل المنتج',
        style: GoogleFonts.cairo(),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'اسم المنتج'),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'السعر'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(labelText: 'الوصف'),
              ),
              TextFormField(
                controller: imageController,
                decoration: InputDecoration(labelText: 'رابط الصورة'),
              ),
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'معرّف التصنيف'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: GoogleFonts.cairo()),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: _saveProduct,
          child: Text('حفظ', style: GoogleFonts.cairo()),
        ),
      ],
    );
  }
}
