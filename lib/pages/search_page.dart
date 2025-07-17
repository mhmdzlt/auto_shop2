import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../providers/search_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _searchHistory = [];
  bool _showFilter = false;
  String? _selectedCategory;
  double _minPrice = 0;
  double _maxPrice = 10000;
  String _sortBy = 'popularity';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    var box = await Hive.openBox('search_history');
    setState(() {
      _searchHistory = List<String>.from(box.get('history', defaultValue: []));
    });
  }

  Future<void> _addToSearchHistory(String query) async {
    var box = await Hive.openBox('search_history');
    List<String> history = List<String>.from(
      box.get('history', defaultValue: []),
    );
    history.remove(query);
    history.insert(0, query);
    if (history.length > 5) history = history.sublist(0, 5);
    await box.put('history', history);
    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _clearSearchHistory() async {
    var box = await Hive.openBox('search_history');
    await box.put('history', []);
    setState(() {
      _searchHistory = [];
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'فلترة النتائج',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: _selectedCategory,
                hint: Text('اختر الفئة'),
                items: ['إلكترونيات', 'ملابس', 'ألعاب', 'منزلية', 'سيارات']
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
              ),
              const SizedBox(height: 12),
              Text('نطاق السعر', style: GoogleFonts.cairo()),
              RangeSlider(
                min: 0,
                max: 10000,
                values: RangeValues(_minPrice, _maxPrice),
                onChanged: (values) {
                  setState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                },
              ),
              const SizedBox(height: 12),
              Text('ترتيب حسب', style: GoogleFonts.cairo()),
              DropdownButton<String>(
                value: _sortBy,
                items: [
                  DropdownMenuItem(
                    value: 'popularity',
                    child: Text('الأكثر شعبية'),
                  ),
                  DropdownMenuItem(
                    value: 'price_asc',
                    child: Text('السعر: من الأقل'),
                  ),
                  DropdownMenuItem(
                    value: 'price_desc',
                    child: Text('السعر: من الأعلى'),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _sortBy = val ?? 'popularity';
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('تطبيق الفلترة', style: GoogleFonts.cairo()),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('بحث المنتجات', style: GoogleFonts.cairo()),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(icon: Icon(Icons.filter_alt), onPressed: _showFilterSheet),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).setQuery('');
                  },
                ),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).setQuery(val);
              },
              onSubmitted: (val) {
                ref.read(searchQueryProvider.notifier).setQuery(val);
                _addToSearchHistory(val);
              },
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سجل البحث',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _clearSearchHistory,
                  child: Text(
                    'مسح الكل',
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _searchHistory.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final item = _searchHistory[i];
                  return ActionChip(
                    label: Text(item, style: GoogleFonts.cairo()),
                    onPressed: () {
                      _controller.text = item;
                      ref.read(searchQueryProvider.notifier).setQuery(item);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: searchResults.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Text('لا توجد نتائج', style: GoogleFonts.cairo()),
                    );
                  }
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                    children: products.map((product) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/product',
                            arguments: product,
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: product['image'] != null
                                      ? Image.network(
                                          product['image'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : Container(color: Colors.grey[300]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? '',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product['price'] ?? ''} د.ع',
                                      style: GoogleFonts.cairo(
                                        color: Colors.green,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('خطأ في البحث', style: GoogleFonts.cairo()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
