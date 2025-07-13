import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('cart')
        .select()
        .order('id', ascending: false); // عدل حسب الحاجة

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السلة', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('السلة فارغة حالياً'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['product_name'] ?? 'بدون اسم'),
                subtitle: Text('السعر: ${item['price'] ?? 'غير متوفر'}'),
              );
            },
          );
        },
      ),
    );
  }
}
