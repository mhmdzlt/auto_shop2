import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/discount.dart';
import '../services/discount_management_service.dart';

/// Widget لإدخال وتطبيق كود الخصم
class DiscountCodeWidget extends StatefulWidget {
  final double orderAmount;
  final List<String>? productCategories;
  final List<String>? productIds;
  final bool isFirstTimeUser;
  final Function(DiscountApplication?) onDiscountApplied;

  const DiscountCodeWidget({
    super.key,
    required this.orderAmount,
    this.productCategories,
    this.productIds,
    this.isFirstTimeUser = false,
    required this.onDiscountApplied,
  });

  @override
  State<DiscountCodeWidget> createState() => _DiscountCodeWidgetState();
}

class _DiscountCodeWidgetState extends State<DiscountCodeWidget> {
  final _discountCodeController = TextEditingController();
  final _discountService = DiscountManagementService();
  DiscountApplication? _appliedDiscount;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _discountService.initialize();
  }

  Future<void> _applyDiscountCode() async {
    if (_discountCodeController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final validation = _discountService.validateDiscountCode(
        _discountCodeController.text,
        widget.orderAmount,
        productCategories: widget.productCategories,
        productIds: widget.productIds,
        isFirstTimeUser: widget.isFirstTimeUser,
      );

      if (validation['isValid']) {
        final application = _discountService.applyDiscount(
          _discountCodeController.text,
          widget.orderAmount,
          productCategories: widget.productCategories,
          productIds: widget.productIds,
          isFirstTimeUser: widget.isFirstTimeUser,
        );

        setState(() {
          _appliedDiscount = application;
          _errorMessage = null;
        });

        widget.onDiscountApplied(application);

        // إظهار رسالة نجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validation['message'] ?? 'تم تطبيق الخصم بنجاح!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = validation['error'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تطبيق الخصم';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeDiscount() {
    setState(() {
      _appliedDiscount = null;
      _errorMessage = null;
      _discountCodeController.clear();
    });
    widget.onDiscountApplied(null);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_offer, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'كود الخصم',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_appliedDiscount == null) ...[
              // إدخال كود الخصم
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _discountCodeController,
                      decoration: InputDecoration(
                        hintText: 'أدخل كود الخصم',
                        border: const OutlineInputBorder(),
                        errorText: _errorMessage,
                        prefixIcon: const Icon(Icons.discount),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: (_) => _applyDiscountCode(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _applyDiscountCode,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('تطبيق'),
                  ),
                ],
              ),
            ] else ...[
              // عرض الخصم المطبق
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تم تطبيق الخصم: ${_appliedDiscount!.discount.code}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _removeDiscount,
                          icon: const Icon(Icons.close),
                          tooltip: 'إزالة الخصم',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _appliedDiscount!.discount.title,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'قيمة الخصم:',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          '-\$${_appliedDiscount!.discountAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // عرض الخصومات المتاحة
            _buildAvailableDiscounts(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableDiscounts() {
    return FutureBuilder<List<Discount>>(
      future: _getAvailableDiscounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final discounts = snapshot.data!.take(3).toList(); // أول 3 خصومات فقط

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'العروض المتاحة:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...discounts.map((discount) => _buildDiscountChip(discount)),
          ],
        );
      },
    );
  }

  Widget _buildDiscountChip(Discount discount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          _discountCodeController.text = discount.code;
          _applyDiscountCode();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                discount.code,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                discount.type == DiscountType.percentage
                    ? '${discount.value.toInt()}% خصم'
                    : '\$${discount.value.toStringAsFixed(0)} خصم',
                style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Discount>> _getAvailableDiscounts() async {
    return _discountService.getActiveDiscounts();
  }

  @override
  void dispose() {
    _discountCodeController.dispose();
    super.dispose();
  }
}
