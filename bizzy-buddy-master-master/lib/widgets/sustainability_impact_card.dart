import 'package:flutter/material.dart';

class SustainabilityImpactCard extends StatelessWidget {
  final Map<String, dynamic> impactData;

  const SustainabilityImpactCard({
    super.key,
    required this.impactData,
  });

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Icon(
                  Icons.eco,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Impact',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildImpactItem(
              context,
              title: 'Carbon Footprint Reduction',
              value: '${impactData['carbonReduction']} kg CO₂',
              description:
                  'Equivalent to planting ${impactData['treesEquivalent']} trees',
              icon: Icons.forest,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildImpactItem(
              context,
              title: 'Energy Savings',
              value: '${impactData['energySaved']} kWh',
              description:
                  'Enough to power ${impactData['homesPowered']} homes for a day',
              icon: Icons.bolt,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildImpactItem(
              context,
              title: 'Waste Reduction',
              value: '${impactData['wasteReduced']} kg',
              description:
                  'Equivalent to ${impactData['landfillSpace']} cubic meters of landfill space',
              icon: Icons.delete,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildImpactItem(
              context,
              title: 'Water Conservation',
              value: '${impactData['waterSaved']} liters',
              description:
                  'Enough to fill ${impactData['bottlesEquivalent']} water bottles',
              icon: Icons.water_drop,
              color: Colors.cyan,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Impact Score',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    impactData['totalScore'].toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your business is making a positive impact on the environment!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactItem(
    BuildContext context, {
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
