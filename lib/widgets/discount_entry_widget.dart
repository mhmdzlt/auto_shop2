import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_shop/services/discount_service.dart';
import 'package:auto_shop/models/discount.dart';

final discountServiceProvider = Provider((ref) => DiscountService());

final activeDiscountsProvider = FutureProvider<List<Discount>>((ref) async {
  return ref.watch(discountServiceProvider).getActiveDiscounts();
});

class DiscountEntryWidget extends ConsumerStatefulWidget {
  final Function(Discount) onDiscountApplied;

  const DiscountEntryWidget({super.key, required this.onDiscountApplied});

  @override
  _DiscountEntryWidgetState createState() => _DiscountEntryWidgetState();
}

class _DiscountEntryWidgetState extends ConsumerState<DiscountEntryWidget> {
  final TextEditingController _controller = TextEditingController();

  void _applyDiscount() async {
    final discount = await ref
        .read(discountServiceProvider)
        .getDiscountByCode(_controller.text);
    if (discount != null && discount.isValid()) {
      widget.onDiscountApplied(discount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Discount "${discount.title}" applied!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or expired discount code.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Discount Code',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _applyDiscount, child: const Text('Apply')),
        ],
      ),
    );
  }
}
