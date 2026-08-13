class ShippingAddress {
  final String id, receiverName, phone, addressLine, city, state, postalCode;
  final bool isDefault;
  const ShippingAddress({required this.id, required this.receiverName, required this.phone, required this.addressLine, required this.city, required this.state, required this.postalCode, required this.isDefault});
  String get fullAddress => '$addressLine, $postalCode $city, $state';
  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(id: json['id'].toString(), receiverName: json['receiverName'].toString(), phone: json['phone'].toString(), addressLine: json['addressLine'].toString(), city: json['city'].toString(), state: json['state'].toString(), postalCode: json['postalCode'].toString(), isDefault: json['isDefault'] == true);
}
