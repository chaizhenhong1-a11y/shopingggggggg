import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/product.dart';
import '../domain/cart_item.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(Product product, String variant, int quantity) {
    final id = '${product.id}::$variant';
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) {
      state = [
        ...state,
        CartItem(id: id, product: product, variant: variant, quantity: quantity),
      ];
      return;
    }
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(quantity: item.quantity + quantity)
        else
          item,
    ];
  }

  void increase(String id) => _changeQuantity(id, 1);

  void decrease(String id) => _changeQuantity(id, -1);

  void _changeQuantity(String id, int change) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(quantity: (item.quantity + change).clamp(1, 99) as int)
        else
          item,
    ];
  }

  void toggle(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(selected: !item.selected) else item,
    ];
  }

  void toggleAll() {
    final selectAll = !state.isNotEmpty || !state.every((item) => item.selected);
    state = [for (final item in state) item.copyWith(selected: selectAll)];
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void removeSelected() {
    state = state.where((item) => !item.selected).toList();
  }
}

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity);
});

final selectedCartTotalProvider = Provider<double>((ref) {
  return ref
      .watch(cartProvider)
      .where((item) => item.selected)
      .fold(0, (sum, item) => sum + item.subtotal);
});
