import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sustainability.dart';

class CarbonFootprintCard extends StatelessWidget {
  final CarbonFootprint footprint;
  final double targetReduction;

  const CarbonFootprintCard({
    super.key,
    required this.footprint,
    this.targetReduction = 0.2, // 20% reduction target
  });

  @override
  Widget build(BuildContext context) {
    final totalSavings = footprint.totalCarbonSaved;
    final targetSavings = totalSavings * (1 + targetReduction);
    final progress = totalSavings / targetSavings;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carbon Footprint',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: totalSavings,
                          title: '${totalSavings.toStringAsFixed(1)} kg',
                          radius: 50,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.grey.shade300,
                          value: targetSavings - totalSavings,
                          title:
                              '${(targetSavings - totalSavings).toStringAsFixed(1)} kg',
                          radius: 50,
                          titleStyle: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Text(
                          'of target',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...footprint.categorySavings.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(1)} kg CO₂',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
