import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import 'brand_sections_page.dart'; // استورد صفحة BrandSectionsPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> brands = [];
  List<Map<String, dynamic>> filteredBrands = [];
  bool loading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    setState(() => loading = true);
    final response = await supabase.from('brands').select();
    brands = List<Map<String, dynamic>>.from(response);
    filteredBrands = brands;
    setState(() => loading = false);
  }

  void filterBrands(String query) {
    searchQuery = query;
    if (query.isEmpty) {
      filteredBrands = brands;
    } else {
      filteredBrands = brands
          .where((b) =>
              (b['name'] ?? '').toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('car_brands'.tr()),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextField(
                    onChanged: filterBrands,
                    decoration: InputDecoration(
                      hintText: 'search_brand'.tr(),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F0F0),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredBrands.isEmpty
                      ? Center(
                          child: Text(
                            'no_brands_found'.tr(),
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                          itemCount: filteredBrands.length,
                          itemBuilder: (context, index) {
                            final brand = filteredBrands[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BrandSectionsPage(
                                      brandId: brand['id'],
                                      brandName: brand['name'],
                                      brandLogo: brand['logo_url'],
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (brand['logo_url'] != null)
                                      CircleAvatar(
                                        radius: 36,
                                        backgroundColor: const Color(0xFFF5F0F0),
                                        backgroundImage: NetworkImage(brand['logo_url']),
                                      ),
                                    const SizedBox(height: 10),
                                    Text(
                                      brand['name'] ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFF181111),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

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
