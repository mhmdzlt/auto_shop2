import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<dynamic> _categories = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final response = await Supabase.instance.client
          .from('categories')
          .select();
      if (response != null && response is List) {
        setState(() {
          _categories = response;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('التصنيفات', style: GoogleFonts.cairo()),
        backgroundColor: isDark ? Colors.black : Colors.orange,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(
              child: Text(
                'حدث خطأ أثناء تحميل التصنيفات',
                style: GoogleFonts.cairo(),
              ),
            )
          : GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: _categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryProductsPage(category: category),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category, size: 40, color: Colors.orange),
                        const SizedBox(height: 12),
                        Text(
                          category['name'] ?? '',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// صفحة المنتجات حسب التصنيف
class CategoryProductsPage extends StatelessWidget {
  final dynamic category;
  const CategoryProductsPage({required this.category, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category['name'] ?? '', style: GoogleFonts.cairo()),
        backgroundColor: Colors.orange,
      ),
      body: CategoryProductsGrid(categoryId: category['id']),
    );
  }
}

class CategoryProductsGrid extends StatefulWidget {
  final int categoryId;
  const CategoryProductsGrid({required this.categoryId, Key? key})
    : super(key: key);

  @override
  State<CategoryProductsGrid> createState() => _CategoryProductsGridState();
}

class _CategoryProductsGridState extends State<CategoryProductsGrid> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .eq('category_id', widget.categoryId);
      if (response != null && response is List) {
        setState(() {
          _products = response;
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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _hasError
        ? Center(child: Text('حدث خطأ أثناء تحميل المنتجات'))
        : GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: _products.map((product) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/product', arguments: product);
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      product['image'] != null
                          ? Image.network(
                              product['image'],
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.image, size: 60, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        product['name'] ?? '',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product['price'] ?? ''} د.ع',
                        style: GoogleFonts.cairo(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
  }
}
