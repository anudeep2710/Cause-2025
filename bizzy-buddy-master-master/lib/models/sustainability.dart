import 'package:hive/hive.dart';
part 'sustainability.g.dart';

@HiveType(typeId: 10)
class GreenBadge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String iconPath;

  @HiveField(4)
  final int points;

  @HiveField(5)
  final DateTime earnedAt;

  GreenBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.points,
    required this.earnedAt,
  });
}

@HiveType(typeId: 6)
class CarbonFootprint extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double totalCarbonSaved;

  @HiveField(2)
  final Map<String, double> categorySavings;

  @HiveField(3)
  final DateTime lastUpdated;

  CarbonFootprint({
    required this.id,
    required this.totalCarbonSaved,
    required this.categorySavings,
    required this.lastUpdated,
  });
}

@HiveType(typeId: 7)
class LocalSupplier extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final List<String> sustainabilityCertifications;

  @HiveField(6)
  final String description;

  LocalSupplier({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.sustainabilityCertifications,
    required this.description,
  });
}
