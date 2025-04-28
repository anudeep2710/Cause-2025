import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  Expense.create({
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now();

  Expense copyWith({
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
  }) {
    return Expense(
      id: id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
