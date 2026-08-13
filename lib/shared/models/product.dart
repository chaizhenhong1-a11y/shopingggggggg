class Product {
  final String id;
  final String sellerName;
  final String sellerLocation;
  final String category;
  final String name;
  final String subtitle;
  final String description;
  final double price;
  final double oldPrice;
  final double rating;
  final int sold;
  final List<String> images;
  final List<String> variants;
  final bool favorite;

  const Product({
    required this.id,
    required this.sellerName,
    required this.sellerLocation,
    required this.category,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.sold,
    required this.images,
    required this.variants,
    this.favorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final rawVariants = json['variants'];
    final images = rawImages is List
        ? rawImages.map((item) => item.toString()).where((item) => item.isNotEmpty).toList()
        : <String>[];
    final variants = rawVariants is List
        ? rawVariants.map((item) {
            if (item is Map) return item['name']?.toString() ?? '';
            return item.toString();
          }).where((item) => item.isNotEmpty).toList()
        : <String>[];
    final price = _toDouble(json['price']);
    final originalPrice = _toDouble(json['originalPrice'], fallback: price);

    return Product(
      id: json['id']?.toString() ?? '',
      sellerName: json['sellerName']?.toString() ?? 'Mall Go Store',
      sellerLocation: json['sellerLocation']?.toString() ?? 'Malaysia',
      category: json['category']?.toString() ?? '其他',
      name: json['name']?.toString() ?? '未命名商品',
      subtitle: json['subtitle']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: price,
      oldPrice: originalPrice <= 0 ? price : originalPrice,
      rating: _toDouble(json['rating']),
      sold: _toInt(json['soldCount'] ?? json['sold']),
      images: images.isEmpty
          ? const ['https://placehold.co/800x800/png?text=Mall+Go']
          : images,
      variants: variants.isEmpty ? const ['默认规格'] : variants,
    );
  }

  int get discount {
    if (oldPrice <= 0 || oldPrice <= price) return 0;
    return ((oldPrice - price) / oldPrice * 100).round();
  }

  Product copyWith({bool? favorite}) => Product(
        id: id,
        sellerName: sellerName,
        sellerLocation: sellerLocation,
        category: category,
        name: name,
        subtitle: subtitle,
        description: description,
        price: price,
        oldPrice: oldPrice,
        rating: rating,
        sold: sold,
        images: images,
        variants: variants,
        favorite: favorite ?? this.favorite,
      );

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
