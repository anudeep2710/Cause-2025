import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sustainability.dart';
import 'sustainability_controller.dart';

final badgesBoxProvider = FutureProvider<Box<GreenBadge>>((ref) async {
  return Hive.openBox<GreenBadge>('badges');
});

final carbonFootprintBoxProvider =
    FutureProvider<Box<CarbonFootprint>>((ref) async {
  return Hive.openBox<CarbonFootprint>('carbon_footprint');
});

final localSuppliersBoxProvider =
    FutureProvider<Box<LocalSupplier>>((ref) async {
  return Hive.openBox<LocalSupplier>('local_suppliers');
});

final sustainabilityControllerProvider =
    Provider<SustainabilityController>((ref) {
  final badgesBox = ref.watch(badgesBoxProvider).value;
  final carbonFootprintBox = ref.watch(carbonFootprintBoxProvider).value;
  final suppliersBox = ref.watch(localSuppliersBoxProvider).value;

  if (badgesBox == null || carbonFootprintBox == null || suppliersBox == null) {
    throw Exception('Hive boxes not initialized');
  }

  return SustainabilityController(
    badgesBox: badgesBox,
    carbonFootprintBox: carbonFootprintBox,
    suppliersBox: suppliersBox,
  );
});
