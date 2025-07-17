import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../pages/payment_history_page.dart';
import '../pages/cart_page.dart';
import '../pages/profile_page.dart';
import '../pages/about_page.dart';
import '../pages/orders_page.dart';
import '../pages/faq_page.dart';
import '../sections/flash_deals_section.dart';
import '../sections/new_arrivals_section.dart';
import '../sections/recommended_section.dart';
import '../sections/categories_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
      // جلب المنتجات من Hive أولاً
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
      if (response != null && response is List) {
        if (response.length < _limit) _hasMore = false;
        _products.addAll(response);
        _offset = _products.length;
        // حفظ في Hive
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
        !_isLoading && _hasMore) {
      _fetchProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;
  final List<Widget> _pages = [
    CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
          title: Text(
            'AliShop',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ProductSearchDelegate(
                    onResult: (query) {
                      Navigator.pushNamed(context, '/search_results', arguments: query);
                    },
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.info_outline, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AboutPage()));
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _SearchBar(
                onSubmitted: (query) {
                  Navigator.pushNamed(context, '/search_results', arguments: query);
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
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
        SliverToBoxAdapter(child: FlashDealsSection()),
        SliverToBoxAdapter(child: NewArrivalsSection()),
        SliverToBoxAdapter(child: CategoriesSection()),
        SliverToBoxAdapter(child: RecommendedSection()),
        _isLoading && _products.isEmpty
            ? SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            : _hasError
                ? SliverFillRemaining(
                    child: Center(
                      child: Text('حدث خطأ أثناء تحميل المنتجات', style: GoogleFonts.cairo()),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _products.length) return null;
                        final product = _products[index];
                        return ProductGridItem(product: product);
                      },
                      childCount: _products.length,
                    ),
                  ),
        if (_isLoading && _products.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    ),
    OrdersPage(),
    CartPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
          body: _pages[_selectedIndex],
                  ),
                ),
            ],
          ),
          OrdersPage(),
          CartPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              // الرئيسية
              break;
            case 1:
              // الطلبات
              break;
            case 2:
              // السلة
              break;
            case 3:
              // الملف الشخصي
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedIndex == 0
                  ? const Icon(Icons.home_filled)
                  : const Icon(Icons.home_outlined),
            ),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedIndex == 1
                  ? const Icon(Icons.receipt_long)
                  : const Icon(Icons.receipt),
            ),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedIndex == 2
                  ? const Icon(Icons.shopping_cart)
                  : const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'السلة',
          ),
          BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedIndex == 3
                  ? const Icon(Icons.person)
                  : const Icon(Icons.person_outline),
            ),
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
        prefixIcon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
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

class BannersSection extends StatelessWidget {
  final List<String> banners = [
    // صور محلية أو روابط مؤقتة
    'assets/icons/banner1.png',
    'assets/icons/banner2.png',
    'assets/icons/banner3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 140,
          autoPlay: true,
          enlargeCenterPage: true,
        ),
        items: banners.map((img) {
          return Builder(
            builder: (context) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(img),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'إلكترونيات', 'icon': 'assets/icons/electronics.svg'},
    {'name': 'ملابس', 'icon': 'assets/icons/clothes.svg'},
    {'name': 'ألعاب', 'icon': 'assets/icons/toys.svg'},
    {'name': 'منزلية', 'icon': 'assets/icons/home.svg'},
    {'name': 'سيارات', 'icon': 'assets/icons/car.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/categories', arguments: cat['name']);
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  child: SvgPicture.asset(cat['icon'], width: 32, height: 32),
                ),
                const SizedBox(height: 6),
                Text(cat['name'], style: GoogleFonts.cairo(fontSize: 13)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProductGridItem extends StatelessWidget {
  final dynamic product;
  const ProductGridItem({required this.product});

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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: product['image'] != null
                    ? Image.network(product['image'], fit: BoxFit.cover, width: double.infinity)
                    : Container(color: Colors.grey[300]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('${product['price'] ?? ''} د.ع', style: GoogleFonts.cairo(color: Colors.green, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(product['description'] ?? '', style: GoogleFonts.cairo(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// بحث المنتجات
class ProductSearchDelegate extends SearchDelegate {
  final void Function(String)? onResult;
  ProductSearchDelegate({this.onResult});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));
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
}import 'package:flutter/material.dart';
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
