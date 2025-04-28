import 'package:flutter/material.dart';
import '../models/sustainability.dart';

class SupplierListCard extends StatelessWidget {
  final LocalSupplier supplier;
  final VoidCallback? onTap;

  const SupplierListCard({
    super.key,
    required this.supplier,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.store,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      supplier.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                supplier.address,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: supplier.sustainabilityCertifications.map((cert) {
                  return Chip(
                    label: Text(
                      cert,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.green.shade50,
                    labelStyle: TextStyle(
                      color: Colors.green.shade800,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                supplier.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
