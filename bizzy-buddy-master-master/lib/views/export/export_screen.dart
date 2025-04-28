import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../models/product.dart';
import '../../models/sale.dart';
import '../../models/expense.dart';
import '../../utils/csv_export.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String? _error;
  String? _successMessage;
  bool _isLoading = false;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final String _defaultExportFolder = 'BizzyBuddy/Exports';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export Options',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildExportOption(
                      icon: Icons.inventory_2_outlined,
                      title: 'Export Products',
                      description: 'Export your product catalog as CSV',
                      onTap: () => _exportData('products'),
                    ),
                    const Divider(),
                    _buildExportOption(
                      icon: Icons.point_of_sale,
                      title: 'Export Sales',
                      description: 'Export your sales history as CSV',
                      onTap: () => _exportData('sales'),
                    ),
                    const Divider(),
                    _buildExportOption(
                      icon: Icons.receipt_long,
                      title: 'Export Expenses',
                      description: 'Export your expense records as CSV',
                      onTap: () => _exportData('expenses'),
                    ),
                    const Divider(),
                    _buildExportOption(
                      icon: Icons.download,
                      title: 'Export All Data',
                      description: 'Export all business data',
                      onTap: () => _exportData('all'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox(),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green),
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

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(title),
      subtitle: Text(description),
      onTap: _isLoading ? null : onTap,
    );
  }

  Future<void> _exportData(String type) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        setState(() {
          _error = 'Storage permission is required for exporting data';
          _isLoading = false;
        });
        return;
      }

      // Get app directory for export
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        setState(() {
          _error = 'Could not access storage for export';
          _isLoading = false;
        });
        return;
      }

      // Create export directory if it doesn't exist
      final exportDir = Directory('${directory.path}/$_defaultExportFolder');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      List<File> exportedFiles = [];

      switch (type) {
        case 'products':
          final file = await _exportProducts(exportDir, timestamp);
          exportedFiles.add(file);
          break;
        case 'sales':
          final file = await _exportSales(exportDir, timestamp);
          exportedFiles.add(file);
          break;
        case 'expenses':
          final file = await _exportExpenses(exportDir, timestamp);
          exportedFiles.add(file);
          break;
        case 'all':
          exportedFiles.add(await _exportProducts(exportDir, timestamp));
          exportedFiles.add(await _exportSales(exportDir, timestamp));
          exportedFiles.add(await _exportExpenses(exportDir, timestamp));
          break;
      }

      if (exportedFiles.isEmpty) {
        throw Exception('No files were exported');
      }

      // Share the exported files
      await Share.shareXFiles(
        exportedFiles.map((file) => XFile(file.path)).toList(),
        subject: 'BizzyBuddy Exported Data',
      );

      if (mounted) {
        setState(() {
          _successMessage = 'Data exported successfully!';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Export failed: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<File> _exportProducts(Directory dir, int timestamp) async {
    final productsBox = await Hive.openBox<Product>('products');
    final products = productsBox.values.toList();

    // Use the CSV export utility
    final csvExport = CSVExport();
    final tempFile = await csvExport.exportProductsData(products);

    // Copy to the desired export directory
    final fileName = 'bizzybuddy_products_$timestamp.csv';
    final destFile = File('${dir.path}/$fileName');

    // Copy the temp file to the destination
    await tempFile.copy(destFile.path);

    return destFile;
  }

  Future<File> _exportSales(Directory dir, int timestamp) async {
    final salesBox = await Hive.openBox<Sale>('sales');
    final sales = salesBox.values.toList();

    // Use the CSV export utility
    final csvExport = CSVExport();
    final tempFile = await csvExport.exportSalesData(sales);

    // Copy to the desired export directory
    final fileName = 'bizzybuddy_sales_$timestamp.csv';
    final destFile = File('${dir.path}/$fileName');

    // Copy the temp file to the destination
    await tempFile.copy(destFile.path);

    return destFile;
  }

  Future<File> _exportExpenses(Directory dir, int timestamp) async {
    final expensesBox = await Hive.openBox<Expense>('expenses');
    final expenses = expensesBox.values.toList();

    // Use the CSV export utility
    final csvExport = CSVExport();
    final tempFile = await csvExport.exportExpensesData(expenses);

    // Copy to the desired export directory
    final fileName = 'bizzybuddy_expenses_$timestamp.csv';
    final destFile = File('${dir.path}/$fileName');

    // Copy the temp file to the destination
    await tempFile.copy(destFile.path);

    return destFile;
  }
}
