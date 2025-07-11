import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class ProductDetailsPage extends StatefulWidget {
  final int partId;
  const ProductDetailsPage({super.key, required this.partId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? part;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPart();
  }

  Future<void> fetchPart() async {
    setState(() => loading = true);
    final response = await supabase
        .from('parts')
        .select()
        .eq('id', widget.partId)
        .maybeSingle();

    setState(() {
      part = response;
      loading = false;
    });
  }

  void addToCart() {
    // منطق إضافة للسلة هنا
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('added_to_cart'.tr())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(part?['name'] ?? ''),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : part == null
          ? Center(child: Text('not_found'.tr()))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (part!['image_url'] != null)
                  Container(
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: const Color(0xFFF5F0F0),
                      image: DecorationImage(
                        image: NetworkImage(part!['image_url']),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                Text(
                  part!['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Color(0xFF181111),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  part!['description'] ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'price'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181111),
                      ),
                    ),
                    Text(
                      '${part!['price']} \$',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFF93838),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF93838),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    'add_to_cart'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
