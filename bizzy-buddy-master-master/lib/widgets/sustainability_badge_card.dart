import 'package:flutter/material.dart';
import '../models/sustainability.dart';

class SustainabilityBadgeCard extends StatelessWidget {
  final GreenBadge badge;
  final bool isEarned;

  const SustainabilityBadgeCard({
    super.key,
    required this.badge,
    this.isEarned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isEarned
                ? [Colors.green.shade300, Colors.green.shade600]
                : [Colors.grey.shade300, Colors.grey.shade600],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 48,
              color: isEarned ? Colors.white : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: isEarned ? Colors.amber : Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${badge.points} points',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
