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

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'].toString(),
        product: Product.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
        variant: json['variant']?.toString() ?? '默认规格',
        quantity: int.tryParse(json['quantity'].toString()) ?? 1,
        selected: json['selected'] != false,
      );
}
