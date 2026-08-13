import '../../../shared/models/product.dart';

class CartItem {
  final String id;
  final Product product;
  final String variant;
  final int quantity;
  final bool selected;

  const CartItem({
    required this.id,
    required this.product,
    required this.variant,
    required this.quantity,
    this.selected = true,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity, bool? selected}) => CartItem(
        id: id,
        product: product,
        variant: variant,
        quantity: quantity ?? this.quantity,
        selected: selected ?? this.selected,
      );
}
