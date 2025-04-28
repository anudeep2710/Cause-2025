import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  String category;

  @HiveField(5)
  String? description;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? lastUpdated;

  @HiveField(8)
  double? carbonFootprint;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.category,
    this.description,
    required this.createdAt,
    this.lastUpdated,
    this.carbonFootprint,
  });

  Product.create({
    required this.name,
    required this.price,
    required this.quantity,
    required this.category,
    this.description,
    this.carbonFootprint,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now();

  Product copyWith({
    String? name,
    double? price,
    int? quantity,
    String? category,
    String? description,
    DateTime? lastUpdated,
    double? carbonFootprint,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      carbonFootprint: carbonFootprint ?? this.carbonFootprint,
    );
  }
}
