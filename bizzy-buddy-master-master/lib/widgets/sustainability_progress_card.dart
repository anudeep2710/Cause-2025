import 'package:flutter/material.dart';
import '../models/sustainability.dart';

class SustainabilityProgressCard extends StatelessWidget {
  final List<GreenBadge> earnedBadges;
  final CarbonFootprint footprint;
  final int totalPoints;
  final int targetPoints;

  const SustainabilityProgressCard({
    super.key,
    required this.earnedBadges,
    required this.footprint,
    required this.totalPoints,
    required this.targetPoints,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalPoints / targetPoints;
    final remainingPoints = targetPoints - totalPoints;

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
              'Sustainability Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalPoints points',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                ),
                Text(
                  '$targetPoints points',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Badges',
                  value: earnedBadges.length.toString(),
                  icon: Icons.eco,
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  title: 'CO₂ Saved',
                  value: '${footprint.totalCarbonSaved.toStringAsFixed(1)} kg',
                  icon: Icons.forest,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (remainingPoints > 0)
              Text(
                'You need $remainingPoints more points to reach your target!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
