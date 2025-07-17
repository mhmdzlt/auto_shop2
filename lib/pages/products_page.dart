import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_details_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'chat_page.dart';
import 'detect_part_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool loading = true;
  bool loadingMore = false;
  bool hasMoreData = true;
  int currentPage = 0;
  final int pageSize = 20;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!loadingMore && hasMoreData && searchQuery.isEmpty) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (reset) {
      setState(() {
        loading = true;
        currentPage = 0;
        products.clear();
        filteredProducts.clear();
        hasMoreData = true;
      });
    }

    try {
      final response = await supabase
          .from('products')
          .select()
          .range(currentPage * pageSize, (currentPage + 1) * pageSize - 1)
          .order('created_at', ascending: false);

      final newProducts = List<Map<String, dynamic>>.from(response);

      setState(() {
        if (reset) {
          products = newProducts;
        } else {
          products.addAll(newProducts);
        }
        filteredProducts = searchQuery.isEmpty
            ? products
            : _filterProducts(searchQuery);
        loading = false;
        loadingMore = false;
        hasMoreData = newProducts.length == pageSize;
        if (!reset) currentPage++;
      });
    } catch (error) {
      setState(() {
        loading = false;
        loadingMore = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل المنتجات: $error')));
    }
  }

  Future<void> _loadMoreProducts() async {
    if (loadingMore || !hasMoreData) return;

    setState(() {
      loadingMore = true;
    });

    currentPage++;
    await fetchProducts();
  }

  List<Map<String, dynamic>> _filterProducts(String query) {
    return products.where((product) {
      final name = (product['name'] ?? '').toLowerCase();
      final description = (product['description'] ?? '').toLowerCase();
      final searchLower = query.toLowerCase();
      return name.contains(searchLower) || description.contains(searchLower);
    }).toList();
  }

  void _search(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts = query.isEmpty ? products : _filterProducts(query);
    });
  }

  int _currentIndex = 0;

  void _onNavTap(int i) {
    if (i == _currentIndex) return;
    if (i == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage()));
    } else if (i == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    } else if (i == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatPage()),
      );
    }
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Auto Parts",
          style: TextStyle(
            color: Color(0xFF111418),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFF111418),
            ),
            onPressed: () => _onNavTap(1),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : filteredProducts.isEmpty && searchQuery.isNotEmpty
          ? const Center(child: Text('لا توجد منتجات متطابقة مع البحث'))
          : filteredProducts.isEmpty
          ? const Center(child: Text('لا توجد منتجات متاحة'))
          : RefreshIndicator(
              onRefresh: () => fetchProducts(reset: true),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera),
                            label: const Text('التعرف على القطعة'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DetectPartPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // شريط البحث
                          Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F2F4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFF637488),
                                ),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'ابحث عن قطعة',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: _search,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // قائمة المنتجات
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.75,
                          ),
                      delegate: SliverChildBuilderDelegate((ctx, i) {
                        final product = filteredProducts[i];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsPage(product: product),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFF0F2F4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(14),
                                  ),
                                  child: Image.network(
                                    product['image_url'] ?? '',
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 60,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? '',
                                        style: const TextStyle(
                                          color: Color(0xFF111418),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product['description'] ?? '',
                                        style: const TextStyle(
                                          color: Color(0xFF637488),
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${product['price'] ?? '--'} د.ع",
                                        style: const TextStyle(
                                          color: Color(0xFF1978E5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: filteredProducts.length),
                    ),
                  ),
                  // Loading indicator for pagination
                  if (loadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  // End of list indicator
                  if (!hasMoreData &&
                      filteredProducts.isNotEmpty &&
                      searchQuery.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'تم تحميل جميع المنتجات',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1978E5),
        unselectedItemColor: const Color(0xFF637488),
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'السلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'الحساب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'الدردشة',
          ),
        ],
      ),
    );
  }
}
