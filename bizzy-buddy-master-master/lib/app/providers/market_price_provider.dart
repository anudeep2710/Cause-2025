import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/market_price_service.dart';
import '../../models/market_price.dart';

final marketPriceBoxProvider = Provider<Box<MarketPrice>>((ref) {
  return Hive.box<MarketPrice>('market_prices');
});

final marketPriceServiceProvider = Provider((ref) {
  final box = ref.watch(marketPriceBoxProvider);
  return MarketPriceService(marketPriceBox: box);
});
