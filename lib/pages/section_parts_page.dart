import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import 'product_details_page.dart';

class SectionPartsPage extends StatefulWidget {
  final int sectionId;
  final String sectionName;
  final String? sectionImage;

  const SectionPartsPage({
    super.key,
    required this.sectionId,
    required this.sectionName,
    this.sectionImage,
  });

  @override
  State<SectionPartsPage> createState() => _SectionPartsPageState();
}

class _SectionPartsPageState extends State<SectionPartsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> parts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchParts();
  }

  Future<void> fetchParts() async {
    setState(() => loading = true);
    final response = await supabase
        .from('parts')
        .select()
        .eq('section_id', widget.sectionId);

    setState(() {
      parts = List<Map<String, dynamic>>.from(response);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sectionName),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : parts.isEmpty
          ? Center(
              child: Text(
                'no_parts_found'.tr(),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: parts.length,
              itemBuilder: (context, index) {
                final part = parts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(product: part),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (part['image_url'] != null)
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xFFF5F0F0),
                            backgroundImage: NetworkImage(part['image_url']),
                          ),
                        const SizedBox(height: 10),
                        Text(
                          part['name'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF181111),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${part['price'] ?? '--'} \$',
                          style: const TextStyle(
                            color: Color(0xFF8c5f5f),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
