import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';

class FlashDealsPage extends StatefulWidget {
  const FlashDealsPage({super.key});
  @override
  State<FlashDealsPage> createState() => _FlashDealsPageState();
}

class _FlashDealsPageState extends State<FlashDealsPage> {
  List<dynamic> _deals = [];
  bool _isLoading = true;
  final Map<int, Duration> _timers = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchDeals();
    _startCountdown();
  }

  Future<void> _fetchDeals() async {
    setState(() => _isLoading = true);
    final response = await Supabase.instance.client
        .from('products')
        .select()
        .eq('is_flash', true);
    setState(() {
      _deals = response;
      _isLoading = false;
      for (var deal in _deals) {
        final end =
            DateTime.tryParse(deal['flash_end'] ?? '') ??
            DateTime.now().add(Duration(hours: 1));
        _timers[deal['id']] = end.difference(DateTime.now());
      }
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        for (var id in _timers.keys) {
          final t = _timers[id]!;
          if (t.inSeconds > 0) {
            _timers[id] = t - const Duration(seconds: 1);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('flash_deals'.tr(), style: GoogleFonts.cairo()),
        backgroundColor: isDark ? Colors.black : Colors.orange,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _deals.length,
              itemBuilder: (context, i) {
                final deal = _deals[i];
                final timer = _timers[deal['id']] ?? Duration.zero;
                return Card(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ListTile(
                    leading: deal['image'] != null
                        ? Image.network(deal['image'], width: 50)
                        : Icon(Icons.image),
                    title: Text(deal['name'] ?? '', style: GoogleFonts.cairo()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${deal['price'] ?? ''} د.ع',
                          style: GoogleFonts.cairo(color: Colors.green),
                        ),
                        Text(
                          'ينتهي خلال: ${_formatDuration(timer)}',
                          style: GoogleFonts.cairo(color: Colors.red),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text('شراء', style: GoogleFonts.cairo()),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/product',
                          arguments: deal,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
