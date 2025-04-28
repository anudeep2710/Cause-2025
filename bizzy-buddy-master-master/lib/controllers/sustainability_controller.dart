import 'package:hive/hive.dart';
import '../models/sustainability.dart';

class SustainabilityController {
  final Box<GreenBadge> _badgesBox;
  final Box<CarbonFootprint> _carbonFootprintBox;
  final Box<LocalSupplier> _suppliersBox;

  SustainabilityController({
    required Box<GreenBadge> badgesBox,
    required Box<CarbonFootprint> carbonFootprintBox,
    required Box<LocalSupplier> suppliersBox,
  })  : _badgesBox = badgesBox,
        _carbonFootprintBox = carbonFootprintBox,
        _suppliersBox = suppliersBox;

  // Badge Management
  Future<void> awardBadge(GreenBadge badge) async {
    await _badgesBox.put(badge.id, badge);
  }

  List<GreenBadge> getEarnedBadges() {
    return _badgesBox.values.toList();
  }

  // Carbon Footprint Management
  Future<void> updateCarbonFootprint(CarbonFootprint footprint) async {
    await _carbonFootprintBox.put(footprint.id, footprint);
  }

  CarbonFootprint? getCurrentCarbonFootprint() {
    if (_carbonFootprintBox.isEmpty) return null;
    return _carbonFootprintBox.values.last;
  }

  // Local Supplier Management
  Future<void> addLocalSupplier(LocalSupplier supplier) async {
    await _suppliersBox.put(supplier.id, supplier);
  }

  List<LocalSupplier> getLocalSuppliers() {
    return _suppliersBox.values.toList();
  }

  List<LocalSupplier> searchLocalSuppliers(String query) {
    return _suppliersBox.values
        .where((supplier) =>
            supplier.name.toLowerCase().contains(query.toLowerCase()) ||
            supplier.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Calculate carbon savings based on business activities
  double calculateCarbonSavings({
    required double transportationDistance,
    required double energyConsumption,
    required double wasteProduced,
  }) {
    // Example calculation (simplified)
    const double transportFactor = 0.2; // kg CO2 per km
    const double energyFactor = 0.5; // kg CO2 per kWh
    const double wasteFactor = 0.1; // kg CO2 per kg waste

    return (transportationDistance * transportFactor) +
        (energyConsumption * energyFactor) +
        (wasteProduced * wasteFactor);
  }
}
