class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  int stock;
  final double rating;
  final int points;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.stock,
    required this.rating,
    required this.points,
    required this.images,
  });
}
