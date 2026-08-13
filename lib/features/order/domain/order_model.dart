import '../../cart/domain/cart_item.dart';

enum OrderStatus { pendingPayment, processing, shipping, completed, cancelled }

class OrderModel {
  final String id;
  final DateTime createdAt;
  final List<CartItem> items;
  final OrderStatus status;
  final String receiverName;
  final String phone;
  final String address;
  final String deliveryMethod;
  final String paymentMethod;
  final double merchandiseTotal;
  final double shippingFee;
  final double discount;
  final double total;

  const OrderModel({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.status,
    required this.receiverName,
    required this.phone,
    required this.address,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.merchandiseTotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
  });

  int get productCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get statusText => switch (status) {
        OrderStatus.pendingPayment => '待付款',
        OrderStatus.processing => '待发货',
        OrderStatus.shipping => '待收货',
        OrderStatus.completed => '已完成',
        OrderStatus.cancelled => '已取消',
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double number(String key) => double.tryParse(json[key].toString()) ?? 0;
    final rawStatus = json['status']?.toString() ?? '';
    final status = switch (rawStatus) { 'PENDING_PAYMENT' => OrderStatus.pendingPayment, 'PROCESSING' => OrderStatus.processing, 'SHIPPING' => OrderStatus.shipping, 'COMPLETED' => OrderStatus.completed, _ => OrderStatus.cancelled };
    return OrderModel(id: json['id'].toString(), createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(), items: (json['items'] as List).map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map))).toList(), status: status, receiverName: json['receiverName'].toString(), phone: json['phone'].toString(), address: json['address'].toString(), deliveryMethod: json['deliveryMethod'].toString(), paymentMethod: json['paymentMethod'].toString(), merchandiseTotal: number('merchandiseTotal'), shippingFee: number('shippingFee'), discount: number('discount'), total: number('total'));
  }
}
