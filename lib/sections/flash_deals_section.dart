import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlashDealsSection extends StatefulWidget {
  const FlashDealsSection({super.key});

  @override
  State<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends State<FlashDealsSection> {
  List<dynamic> deals = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    setState(() => loading = true);
    final now = DateTime.now().toIso8601String();
    final response = await Supabase.instance.client
        .from('flash_deals')
        .select('*,product:products(*)')
        .gt('expires_at', now)
        .order('expires_at', ascending: true);
    setState(() {
      deals = response;
      loading = false;
    });
  }

  String _countdown(String expiresAt) {
    final end = DateTime.parse(expiresAt);
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return 'انتهى العرض';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    final s = diff.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (deals.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عروض خاصة لفترة محدودة',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: deals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final d = deals[i];
              final p = d['product'] ?? {};
              final discounted =
                  (p['price'] ?? 0) *
                  (1 - (d['discount_percentage'] ?? 0) / 100);
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/product', arguments: p),
                    child: Container(
                      width: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                            child: p['image'] != null
                                ? Image.network(
                                    p['image'],
                                    height: 100,
                                    width: 160,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 100,
                                    color: Colors.grey[300],
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'قبل: ${p['price']} د.ع',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  'الآن: ${discounted.toInt()} د.ع',
                                  style: const TextStyle(color: Colors.green),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ينتهي خلال: ${_countdown(d['expires_at'])}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'عرض خاص',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
