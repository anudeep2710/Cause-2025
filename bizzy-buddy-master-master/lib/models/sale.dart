import 'package:hive/hive.dart';
part 'sale.g.dart';

@HiveType(typeId: 2)
class Sale extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double unitPrice;

  @HiveField(4)
  double totalAmount;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? customerName;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  DateTime createdAt;

  Sale({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.date,
    this.customerName,
    this.notes,
    required this.createdAt,
  });

  Sale.create({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.customerName,
    this.notes,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString(),
        totalAmount = quantity * unitPrice,
        date = DateTime.now(),
        createdAt = DateTime.now();

  Sale copyWith({
    int? quantity,
    double? unitPrice,
    String? customerName,
    String? notes,
  }) {
    return Sale(
      id: id,
      productId: productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: (quantity ?? this.quantity) * (unitPrice ?? this.unitPrice),
      date: date,
      customerName: customerName ?? this.customerName,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
