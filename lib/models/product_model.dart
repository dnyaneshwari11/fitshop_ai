class Product {
  final String id;
  final String name;
  final String goal;
  final double price;
  final int calories;
  final int protein;
  final String? imageUrl; // ✅ Added image support

  Product({
    required this.id,
    required this.name,
    required this.goal,
    required this.price,
    required this.calories,
    required this.protein,
    this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      goal: map['goal'] ?? '',
      price: (map['price'] as num).toDouble(),
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
      imageUrl: map['image_url'], // ✅ Fetches 'image_url' from Supabase
    );
  }
}