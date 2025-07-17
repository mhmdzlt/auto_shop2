import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';

class CartItem {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  OrderItem toOrderItem() {
    return OrderItem(partId: productId, quantity: quantity, unitPrice: price);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(Map<String, dynamic> product) {
    final existingIndex = state.indexWhere(
      (item) => item.productId == product['id'],
    );

    if (existingIndex >= 0) {
      // زيادة الكمية إذا كان المنتج موجود
      final updatedList = [...state];
      updatedList[existingIndex].quantity++;
      state = updatedList;
    } else {
      // إضافة منتج جديد
      final cartItem = CartItem(
        productId: product['id'],
        name: product['name'] ?? '',
        price: double.tryParse(product['price']?.toString() ?? '0') ?? 0,
        imageUrl: product['image_url'] ?? '',
      );
      state = [...state, cartItem];
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }

    final updatedList = state.map((item) {
      if (item.productId == productId) {
        return CartItem(
          productId: item.productId,
          name: item.name,
          price: item.price,
          imageUrl: item.imageUrl,
          quantity: quantity,
        );
      }
      return item;
    }).toList();

    state = updatedList;
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void clear() {
    state = [];
  }

  double get totalPrice => state.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);

  List<OrderItem> get orderItems =>
      state.map((item) => item.toOrderItem()).toList();
}
