import 'package:flutter/material.dart';

class SustainabilityChallengesCard extends StatelessWidget {
  final List<Map<String, dynamic>> challenges;
  final Function(String) onChallengeCompleted;

  const SustainabilityChallengesCard({
    super.key,
    required this.challenges,
    required this.onChallengeCompleted,
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
                  Icons.flag_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sustainability Challenges',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...challenges.map((challenge) {
              final isCompleted = challenge['isCompleted'] as bool;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted
                          ? Colors.green.shade200
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              challenge['title'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted
                                        ? Colors.green.shade800
                                        : Colors.black,
                                  ),
                            ),
                          ),
                          if (isCompleted)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline),
                              onPressed: () => onChallengeCompleted(
                                  challenge['id'] as String),
                              color: Theme.of(context).primaryColor,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        challenge['description'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              challenge['category'] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: challenge['category'] == 'Energy'
                                ? Colors.orange.shade50
                                : challenge['category'] == 'Waste'
                                    ? Colors.green.shade50
                                    : Colors.blue.shade50,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${challenge['points']} points',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                          ),
                          const Spacer(),
                          if (challenge['deadline'] != null)
                            Text(
                              'Due: ${challenge['deadline']}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
