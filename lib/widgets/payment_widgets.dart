import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/payment_service.dart';

/// ويدجت لعرض حالة الدفع مع تحسينات بصرية
class PaymentStatusWidget extends ConsumerStatefulWidget {
  final String orderId;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailed;

  const PaymentStatusWidget({
    super.key,
    required this.orderId,
    this.onPaymentSuccess,
    this.onPaymentFailed,
  });

  @override
  ConsumerState<PaymentStatusWidget> createState() =>
      _PaymentStatusWidgetState();
}

class _PaymentStatusWidgetState extends ConsumerState<PaymentStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String? paymentStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _checkPaymentStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final status = await PaymentService.getPaymentStatus(widget.orderId);
      setState(() {
        paymentStatus = status;
        isLoading = false;
      });

      _animationController.forward();

      // استدعاء callbacks حسب الحالة
      if (status == 'succeeded' && widget.onPaymentSuccess != null) {
        widget.onPaymentSuccess!();
      } else if (status == 'failed' && widget.onPaymentFailed != null) {
        widget.onPaymentFailed!();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        paymentStatus = 'error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildStatusCard(),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF93838)),
            ),
            const SizedBox(height: 16),
            Text(
              'checking_payment_status'.tr(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusInfo = _getStatusInfo(paymentStatus);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: statusInfo['gradient'] as List<Color>,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusInfo['icon'] as IconData,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              statusInfo['title'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusInfo['subtitle'] as String,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            if (statusInfo['showRetry'] == true) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  _checkPaymentStatus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: statusInfo['gradient'][0] as Color,
                ),
                child: Text('retry'.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String? status) {
    switch (status) {
      case 'succeeded':
        return {
          'icon': Icons.check_circle,
          'title': 'payment_successful'.tr(),
          'subtitle': 'payment_processed_successfully'.tr(),
          'gradient': [Colors.green, Colors.green.shade400],
          'showRetry': false,
        };
      case 'pending':
        return {
          'icon': Icons.hourglass_empty,
          'title': 'payment_pending'.tr(),
          'subtitle': 'payment_being_processed'.tr(),
          'gradient': [Colors.orange, Colors.orange.shade400],
          'showRetry': true,
        };
      case 'failed':
        return {
          'icon': Icons.error,
          'title': 'payment_failed'.tr(),
          'subtitle': 'payment_could_not_be_processed'.tr(),
          'gradient': [Colors.red, Colors.red.shade400],
          'showRetry': true,
        };
      default:
        return {
          'icon': Icons.help,
          'title': 'payment_status_unknown'.tr(),
          'subtitle': 'unable_to_determine_payment_status'.tr(),
          'gradient': [Colors.grey, Colors.grey.shade400],
          'showRetry': true,
        };
    }
  }
}

/// ويدجت مبسط لإظهار حالة الدفع في مكان صغير
class PaymentStatusBadge extends StatelessWidget {
  final String status;
  final double size;

  const PaymentStatusBadge({super.key, required this.status, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: statusInfo['color'] as Color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        statusInfo['icon'] as IconData,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'succeeded':
        return {'icon': Icons.check, 'color': Colors.green};
      case 'pending':
        return {'icon': Icons.hourglass_empty, 'color': Colors.orange};
      case 'failed':
        return {'icon': Icons.close, 'color': Colors.red};
      default:
        return {'icon': Icons.help, 'color': Colors.grey};
    }
  }
}

/// صندوق حوار تأكيد الدفع
class PaymentConfirmationDialog extends StatelessWidget {
  final double amount;
  final String currency;
  final List<Map<String, dynamic>> items;
  final VoidCallback onConfirm;

  const PaymentConfirmationDialog({
    super.key,
    required this.amount,
    required this.currency,
    required this.items,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // رأس الحوار
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFF93838),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.payment, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),

            Text(
              'confirm_payment'.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // تفاصيل المبلغ
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'total_amount'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$amount $currency',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF93838),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // قائمة المنتجات (المختصرة)
            if (items.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'items'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...items
                  .take(3)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 4, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item['name']} (${item['quantity']}x)',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (items.length > 3)
                Text(
                  '+ ${items.length - 3} ${'more_items'.tr()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              const SizedBox(height: 16),
            ],

            // رسالة الأمان
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'secure_payment_message'.tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('cancel'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF93838),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('confirm'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
