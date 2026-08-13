class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final double rating;
  final int soldCount;
  final bool isFavorite;

  const ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.rating,
    required this.soldCount,
    this.isFavorite = false,
  });

  int get discountPercentage {
    if (originalPrice <= 0 || originalPrice <= price) {
      return 0;
    }

    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  ProductModel copyWith({
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id,
      sellerId: sellerId,
      sellerName: sellerName,
      name: name,
      description: description,
      price: price,
      originalPrice: originalPrice,
      imageUrl: imageUrl,
      rating: rating,
      soldCount: soldCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}