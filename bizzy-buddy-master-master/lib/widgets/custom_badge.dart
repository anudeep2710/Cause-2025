import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomBadge extends StatelessWidget {
  final String iconPath;
  final String name;
  final String description;
  final int points;
  final DateTime earnedAt;
  final bool isNew;

  const CustomBadge({
    super.key,
    required this.iconPath,
    required this.name,
    required this.description,
    required this.points,
    required this.earnedAt,
    this.isNew = false,
  });

  IconData _getIconData() {
    switch (iconPath) {
      case 'carbon_saver':
        return Icons.eco;
      case 'clothing_champion':
        return Icons.checkroom;
      case 'food_champion':
        return Icons.restaurant;
      case 'electronics_champion':
        return Icons.electrical_services;
      default:
        return Icons.eco;
    }
  }

  Color _getIconColor() {
    switch (iconPath) {
      case 'carbon_saver':
        return Colors.green;
      case 'clothing_champion':
        return Colors.blue;
      case 'food_champion':
        return Colors.orange;
      case 'electronics_champion':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getIconColor().withOpacity(0.1),
                  ),
                ),
                Icon(
                  _getIconData(),
                  size: 40,
                  color: _getIconColor(),
                ),
                if (isNew)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$points points',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.amber,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: 2.seconds,
          color: _getIconColor().withOpacity(0.3),
        );
  }
}
