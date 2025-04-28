import 'package:flutter/material.dart';

class SustainabilityTipsCard extends StatelessWidget {
  final List<Map<String, dynamic>> tips;

  const SustainabilityTipsCard({
    super.key,
    required this.tips,
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
                  Icons.lightbulb_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sustainability Tips',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: tip['category'] == 'Energy'
                            ? Colors.orange.shade50
                            : tip['category'] == 'Waste'
                                ? Colors.green.shade50
                                : Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tip['category'] == 'Energy'
                            ? Icons.bolt
                            : tip['category'] == 'Waste'
                                ? Icons.delete
                                : Icons.local_shipping,
                        color: tip['category'] == 'Energy'
                            ? Colors.orange
                            : tip['category'] == 'Waste'
                                ? Colors.green
                                : Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['title'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip['description'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  tip['category'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: tip['category'] == 'Energy'
                                        ? Colors.orange
                                        : tip['category'] == 'Waste'
                                            ? Colors.green
                                            : Colors.blue,
                                  ),
                                ),
                                backgroundColor: tip['category'] == 'Energy'
                                    ? Colors.orange.shade50
                                    : tip['category'] == 'Waste'
                                        ? Colors.green.shade50
                                        : Colors.blue.shade50,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${tip['points']} points',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ],
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
