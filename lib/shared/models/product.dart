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

  int get discount => ((oldPrice - price) / oldPrice * 100).round();

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
}
