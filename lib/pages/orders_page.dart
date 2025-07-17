import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/orders_stream_provider.dart';
import '../models/order.dart';
import 'order_details_page.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  OrderStatus? _selectedStatus;

  final List<OrderStatus?> _statusFilters = [
    null, // All orders
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.inProgress,
    OrderStatus.shipped,
    OrderStatus.delivered,
    OrderStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'my_orders'.tr(),
          style: const TextStyle(color: Color(0xFF181111)),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF181111)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFFF93838),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFF93838),
          onTap: (index) {
            setState(() {
              _selectedStatus = _statusFilters[index];
            });
          },
          tabs: [
            Tab(text: 'all_orders'.tr()),
            Tab(text: 'pending_orders'.tr()),
            Tab(text: 'confirmed_orders'.tr()),
            Tab(text: 'in_progress_orders'.tr()),
            Tab(text: 'shipped_orders'.tr()),
            Tab(text: 'delivered_orders'.tr()),
            Tab(text: 'cancelled_orders'.tr()),
          ],
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('error_loading_orders'.tr()),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(ordersStreamProvider),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
        data: (orders) {
          // Filter orders based on selected status
          final filteredOrders = _selectedStatus == null
              ? orders
              : orders
                    .where((order) => order.status == _selectedStatus)
                    .toList();

          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedStatus == null
                        ? Icons.shopping_bag_outlined
                        : Icons.filter_list,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedStatus == null
                        ? 'no_orders'.tr()
                        : 'no_orders_status'.tr(),
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            itemBuilder: (ctx, i) {
              final order = filteredOrders[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(order.status),
                    child: Icon(
                      _getStatusIcon(order.status),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${'order'.tr()} #${order.id.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(order.createdAt.toLocal()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                order.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(order.status),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(order.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${order.totalPrice} ${'currency'.tr()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF93838),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsPage(order: order),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.inProgress:
        return Colors.indigo;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.inProgress:
        return Icons.settings;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending_orders'.tr();
      case OrderStatus.confirmed:
        return 'confirmed_orders'.tr();
      case OrderStatus.inProgress:
        return 'in_progress_orders'.tr();
      case OrderStatus.shipped:
        return 'shipped_orders'.tr();
      case OrderStatus.delivered:
        return 'delivered_orders'.tr();
      case OrderStatus.cancelled:
        return 'cancelled_orders'.tr();
    }
  }
}
