import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestSupabase extends StatefulWidget {
  const TestSupabase({super.key});

  @override
  State<TestSupabase> createState() => _TestSupabaseState();
}

class _TestSupabaseState extends State<TestSupabase> {
  List products = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await Supabase.instance.client
        .from('products') // اسم الجدول بالضبط
        .select();

    setState(() {
      products = response;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Products Test")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (ctx, i) => ListTile(
          title: Text(products[i]['name'] ?? 'no name'),
          subtitle: Text(products[i]['price'].toString()),
        ),
      ),
    );
  }
}
