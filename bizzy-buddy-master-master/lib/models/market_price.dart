import 'package:hive/hive.dart';

part 'market_price.g.dart';

@HiveType(typeId: 4)
class MarketPrice {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final Map<String, double> prices;

  MarketPrice({
    required this.id,
    required this.timestamp,
    required this.prices,
  });
}
