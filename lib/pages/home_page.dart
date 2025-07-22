import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import '../pages/about_page.dart';
import '../pages/orders_page.dart';
import '../sections/flash_deals_section.dart';
import '../sections/new_arrivals_section.dart';
import '../sections/recommended_section.dart';
import '../sections/categories_section.dart';
import '../sections/promotional_banner_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _products = [];
  bool _isLoading = false;
  bool _hasError = false;
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialProducts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitialProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      var box = await Hive.openBox('products_cache');
      List<dynamic> cached = box.get('products', defaultValue: []);
      if (cached.isNotEmpty) {
        _products.addAll(cached);
        _offset = _products.length;
        setState(() {
          _isLoading = false;
        });
      } else {
        await _fetchProducts();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProducts() async {
    if (!_hasMore) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .range(_offset, _offset + _limit - 1);
      if (response.isNotEmpty) {
        if (response.length < _limit) _hasMore = false;
        _products.addAll(response);
        _offset = _products.length;
        var box = await Hive.openBox('products_cache');
        box.put('products', _products);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Widget> get _pages => [
    CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          title: Text(
            'Auto Shop',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ProductSearchDelegate(
                    onResult: (query) {
                      Navigator.pushNamed(
                        context,
                        '/search_results',
                        arguments: query,
                      );
                    },
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _SearchBar(
                onSubmitted: (query) {
                  Navigator.pushNamed(
                    context,
                    '/search_results',
                    arguments: query,
                  );
                },
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: PromotionalBannerSection(
            promotions: [
              Promotion(
                title: 'عرض خاص',
                imageUrl: 'https://example.com/banner1.png',
                link: 'https://example.com',
              ),
              Promotion(
                title: 'تخفيضات الصيف',
                imageUrl: 'https://example.com/banner2.png',
                link: 'https://example.com',
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: FlashDealsSection()),
        const SliverToBoxAdapter(child: NewArrivalsSection()),
        const SliverToBoxAdapter(child: CategoriesSection()),
        const SliverToBoxAdapter(child: RecommendedSection()),
        _isLoading && _products.isEmpty
            ? const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            : _hasError
            ? SliverFillRemaining(
                child: Center(
                  child: Text(
                    'حدث خطأ أثناء تحميل المنتجات',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              )
            : SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= _products.length) return null;
                  final product = _products[index];
                  return ProductGridItem(product: product);
                }, childCount: _products.length),
              ),
        if (_isLoading && _products.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    ),
    const OrdersPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'الطلبات'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'السلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'الحساب',
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final void Function(String)? onSubmitted;
  const _SearchBar({this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      readOnly: false,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'ابحث عن منتج أو قسم...',
        prefixIcon: Icon(
          Icons.search,
          color: isDark ? Colors.white : Colors.black,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      style: GoogleFonts.cairo(),
    );
  }
}

class ProductGridItem extends StatelessWidget {
  final dynamic product;
  const ProductGridItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product', arguments: product);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDark ? Colors.grey[850] : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
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
                    style: GoogleFonts.cairo(color: Colors.green, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'] ?? '',
                    style: GoogleFonts.cairo(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  final void Function(String)? onResult;
  ProductSearchDelegate({this.onResult});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (onResult != null) onResult!(query);
    return Center(child: Text('نتائج البحث: "$query"'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(child: Text('اقتراحات البحث: "$query"'));
  }
}
