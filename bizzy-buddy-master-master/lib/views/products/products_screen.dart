import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/product.dart';
import '../../models/sale.dart';
import '../../models/expense.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final String _searchQuery = '';
  final String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        await Permission.storage.request();
      }
    }
  }

  Future<void> _importFromExcel() async {
    try {
      // Check permissions first
      await _checkPermissions();

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecting file...')),
        );
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected')),
          );
        }
        return;
      }

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reading Excel file...')),
        );
      }

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        final file = File(result.files.first.path!);
        final fileBytes = await file.readAsBytes();
        final excelFile = excel.Excel.decodeBytes(fileBytes);
        await _processExcel(excelFile);
      } else {
        final excelFile = excel.Excel.decodeBytes(bytes);
        await _processExcel(excelFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing products: $e')),
        );
      }
      debugPrint('Error importing Excel: $e');
    }
  }

  Future<void> _processExcel(excel.Excel excelFile) async {
    int importedCount = 0;
    debugPrint('Starting Excel import process...');

    for (var table in excelFile.tables.keys) {
      final sheet = excelFile.tables[table]!;
      debugPrint('Processing sheet: $table');
      debugPrint('Number of rows: ${sheet.rows.length}');

      // Skip header row
      for (var row in sheet.rows.skip(1)) {
        if (row.length < 4) {
          debugPrint('Skipping row: Insufficient columns');
          continue;
        }

        final name = row[0]?.value?.toString() ?? '';
        final price = double.tryParse(row[1]?.value?.toString() ?? '0') ?? 0;
        final quantity = int.tryParse(row[2]?.value?.toString() ?? '0') ?? 0;
        final category = row[3]?.value?.toString() ?? 'Uncategorized';

        debugPrint('Processing row:');
        debugPrint('  Name: $name');
        debugPrint('  Price: $price');
        debugPrint('  Quantity: $quantity');
        debugPrint('  Category: $category');

        if (name.isEmpty || price <= 0) {
          debugPrint('Skipping invalid row: Empty name or invalid price');
          continue;
        }

        final product = Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          price: price,
          quantity: quantity,
          category: category,
          description: row.length > 4 ? row[4]?.value?.toString() ?? '' : null,
          createdAt: DateTime.now(),
        );

        await Hive.box<Product>('products').add(product);
        importedCount++;
        debugPrint('Successfully imported product: ${product.name}');
      }
    }

    debugPrint('Import complete. Total products imported: $importedCount');
    debugPrint(
        'Total products in database: ${Hive.box<Product>('products').length}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Successfully imported $importedCount products')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditProductDialog([Product? product]) {
    showDialog(
      context: context,
      builder: (context) => _AddEditProductDialog(product: product),
    );
  }

  void _deleteProduct(Product product) {
    product.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted')),
    );
  }

  void _showMicInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.mic,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Voice Input Instructions'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You can add products using voice commands. Here are some examples:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                'Name & Price:',
                '"Add Red T-shirt, price 499"',
              ),
              _buildInstructionItem(
                'With Category:',
                '"Add Wheat Flour under Groceries"',
              ),
              _buildInstructionItem(
                'With Quantity:',
                '"Add Water Bottle, 50 rupees, 10 pieces"',
              ),
              _buildInstructionItem(
                'With Details:',
                '"Add Shirt, price 799, color blue, size medium"',
              ),
              const SizedBox(height: 16),
              const Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Start with "Add" followed by the product name'),
              const Text('• Mention price with "price" or "₹" or "rupees"'),
              const Text('• Specify category using "under [category]"'),
              const Text('• Mention quantity as "[number] pieces/items"'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String title, String example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            example,
            style: TextStyle(
              color: Colors.blue[800],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importFromExcel,
            tooltip: 'Import from Excel',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
            tooltip: 'Export PDF Report',
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: _exportToExcel,
            tooltip: 'Export CSV Report',
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              _showMicInstructionsDialog();
              context.push('/products/add');
            },
            tooltip: 'Voice Add Product',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showMicInstructionsDialog,
            tooltip: 'Voice Input Help',
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Product>('products').listenable(),
        builder: (context, box, _) {
          final products = box.values.toList();
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first product by tapping the + button',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => _showAddEditProductDialog(product),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (_) => _deleteProduct(product),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${product.price}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          Text(
                            'Qty: ${product.quantity}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: product.quantity > 0
                            ? () => _decreaseQuantity(product)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  onTap: () => _showAddEditProductDialog(product),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/products/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        tooltip: 'Add Product with Voice or Text',
      ),
    );
  }

  Future<void> _decreaseQuantity(Product product) async {
    if (product.quantity <= 0) return;

    final newQuantity = product.quantity - 1;
    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      price: product.price,
      quantity: newQuantity,
      category: product.category,
      description: product.description,
      createdAt: product.createdAt,
    );

    try {
      final box = Hive.box<Product>('products');
      final index = box.values.toList().indexOf(product);
      await box.putAt(index, updatedProduct);

      // Create a new sale record
      final sale = Sale.create(
        productId: product.id,
        quantity: 1,
        unitPrice: product.price,
      );
      await Hive.box<Sale>('sales').add(sale);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} quantity decreased to $newQuantity'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                final originalProduct = Product(
                  id: product.id,
                  name: product.name,
                  price: product.price,
                  quantity: product.quantity,
                  category: product.category,
                  description: product.description,
                  createdAt: product.createdAt,
                );
                await box.putAt(index, originalProduct);
                // Remove the sale record
                final salesBox = Hive.box<Sale>('sales');
                final saleIndex = salesBox.values.toList().indexOf(sale);
                if (saleIndex != -1) {
                  await salesBox.deleteAt(saleIndex);
                }
              },
            ),
          ),
        );
      }

      // Show warning if stock is low
      if (newQuantity <= 5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Low stock alert: ${product.name} (Qty: $newQuantity)'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating quantity: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportData() async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating business report...')),
        );
      }

      // Check storage permission
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      final theme = pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      );

      final pdf = pw.Document(theme: theme);

      final productsBox = Hive.box<Product>('products');
      final salesBox = Hive.box<Sale>('sales');
      final expensesBox = Hive.box<Expense>('expenses');

      // Get all data
      final products = productsBox.values.toList();
      final sales = salesBox.values.toList();
      final expenses = expensesBox.values.toList();

      // Calculate category performance
      final categoryPerformance = <String, double>{};
      for (var sale in sales) {
        final product = products.firstWhere(
          (p) => p.id == sale.productId,
          orElse: () => Product(
            id: 'unknown',
            name: 'Unknown Product',
            price: 0,
            quantity: 0,
            category: 'Uncategorized',
            createdAt: DateTime.now(),
          ),
        );
        final category =
            product.category.isEmpty ? 'Uncategorized' : product.category;
        categoryPerformance[category] =
            (categoryPerformance[category] ?? 0) + sale.totalAmount;
      }

      // Calculate total sales and expenses
      final totalSales =
          sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
      final totalExpenses =
          expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      final profit = totalSales - totalExpenses;

      // Add title page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('BizzyBuddy - Business Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.SizedBox(height: 20),
                  pw.Text(
                      'Generated on ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 16,
                      )),
                  pw.SizedBox(height: 50),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(10)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text('Business Summary',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            )),
                        pw.SizedBox(height: 10),
                        _buildSummaryRow(
                            'Total Products', '${products.length}'),
                        _buildSummaryRow(
                            'Total Sales', '₹${totalSales.toStringAsFixed(2)}'),
                        _buildSummaryRow('Total Expenses',
                            '₹${totalExpenses.toStringAsFixed(2)}'),
                        _buildSummaryRow(
                            'Net Profit', '₹${profit.toStringAsFixed(2)}',
                            isHighlighted: true),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Add products page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Product Inventory',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableHeader('Product Name'),
                        _buildTableHeader('Price'),
                        _buildTableHeader('Qty'),
                        _buildTableHeader('Category'),
                      ],
                    ),
                    ...products.map((product) => pw.TableRow(children: [
                          _buildTableCell(product.name),
                          _buildTableCell(
                              '₹${product.price.toStringAsFixed(2)}'),
                          _buildTableCell('${product.quantity}'),
                          _buildTableCell(product.category),
                        ])),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Add sales summary page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Sales Summary',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableHeader('Date'),
                        _buildTableHeader('Product'),
                        _buildTableHeader('Quantity'),
                        _buildTableHeader('Amount'),
                      ],
                    ),
                    ...sales.take(30).map((sale) {
                      // Limit to last 30 sales for readability
                      final product = products.firstWhere(
                        (p) => p.id == sale.productId,
                        orElse: () => Product(
                          id: 'unknown',
                          name: 'Unknown',
                          price: 0,
                          quantity: 0,
                          category: 'Uncategorized',
                          createdAt: DateTime.now(),
                        ),
                      );
                      return pw.TableRow(children: [
                        _buildTableCell(
                            DateFormat('dd/MM/yyyy').format(sale.date)),
                        _buildTableCell(product.name),
                        _buildTableCell('${sale.quantity}'),
                        _buildTableCell(
                            '₹${sale.totalAmount.toStringAsFixed(2)}'),
                      ]);
                    }),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('Category Performance',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableHeader('Category'),
                        _buildTableHeader('Total Sales'),
                        _buildTableHeader('% of Total'),
                      ],
                    ),
                    ...categoryPerformance.entries.map((entry) => pw.TableRow(
                          children: [
                            _buildTableCell(entry.key),
                            _buildTableCell(
                                '₹${entry.value.toStringAsFixed(2)}'),
                            _buildTableCell(
                                '${((entry.value / totalSales) * 100).toStringAsFixed(1)}%'),
                          ],
                        )),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Add expenses page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Expense Summary',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableHeader('Date'),
                        _buildTableHeader('Description'),
                        _buildTableHeader('Category'),
                        _buildTableHeader('Amount'),
                      ],
                    ),
                    ...expenses
                        .take(30)
                        .map((expense) => pw.TableRow(children: [
                              _buildTableCell(DateFormat('dd/MM/yyyy')
                                  .format(expense.date)),
                              _buildTableCell(expense.description),
                              _buildTableCell(expense.category),
                              _buildTableCell(
                                  '₹${expense.amount.toStringAsFixed(2)}'),
                            ])),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Save the PDF
      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/bizzybuddy_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report generated successfully!'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () {
                Share.shareXFiles([XFile(file.path)],
                    subject: 'BizzyBuddy Business Report');
              },
            ),
          ),
        );
      }

      // Share the file
      await Share.shareXFiles([XFile(file.path)],
          subject: 'BizzyBuddy Business Report');
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
      debugPrint('Error exporting data: $e');
    }
  }

  pw.Widget _buildSummaryRow(String title, String value,
      {bool isHighlighted = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isHighlighted ? pw.FontWeight.bold : null,
              color: isHighlighted ? PdfColors.blue700 : null,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text),
    );
  }

  Future<void> _exportToExcel() async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating CSV spreadsheet...')),
        );
      }

      // Check storage permission
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      final productsBox = Hive.box<Product>('products');
      final salesBox = Hive.box<Sale>('sales');
      final expensesBox = Hive.box<Expense>('expenses');

      // Get all data
      final products = productsBox.values.toList();
      final sales = salesBox.values.toList();
      final expenses = expensesBox.values.toList();

      // Calculate category performance
      final categoryPerformance = <String, double>{};
      for (var sale in sales) {
        final product = products.firstWhere(
          (p) => p.id == sale.productId,
          orElse: () => Product(
            id: 'unknown',
            name: 'Unknown Product',
            price: 0,
            quantity: 0,
            category: 'Uncategorized',
            createdAt: DateTime.now(),
          ),
        );
        final category =
            product.category.isEmpty ? 'Uncategorized' : product.category;
        categoryPerformance[category] =
            (categoryPerformance[category] ?? 0) + sale.totalAmount;
      }

      // Calculate total sales and expenses
      final totalSales =
          sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
      final totalExpenses =
          expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
      final profit = totalSales - totalExpenses;

      // Create multiple CSV files for different data
      final output = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final directory =
          Directory('${output.path}/bizzybuddy_report_$timestamp');
      await directory.create();

      // 1. Business Summary CSV
      final summaryFile = File('${directory.path}/summary.csv');
      final summaryContent = StringBuffer();
      summaryContent.writeln('"BizzyBuddy - Business Summary"');
      summaryContent.writeln(
          '"Date Generated","${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}"');
      summaryContent.writeln('"Business Performance"');
      summaryContent.writeln('"Total Products","${products.length}"');
      summaryContent
          .writeln('"Total Sales","₹${totalSales.toStringAsFixed(2)}"');
      summaryContent
          .writeln('"Total Expenses","₹${totalExpenses.toStringAsFixed(2)}"');
      summaryContent.writeln('"Net Profit","₹${profit.toStringAsFixed(2)}"');
      await summaryFile.writeAsString(summaryContent.toString());

      // 2. Products CSV
      final productsFile = File('${directory.path}/products.csv');
      final productsContent = StringBuffer();
      productsContent.writeln(
          '"Name","Price","Quantity","Category","Description","Created Date"');
      for (var product in products) {
        productsContent.writeln('"${product.name.replaceAll('"', '""')}",' +
            '"₹${product.price.toStringAsFixed(2)}",' +
            '"${product.quantity}",' +
            '"${product.category.replaceAll('"', '""')}",' +
            '"${(product.description ?? "").replaceAll('"', '""')}",' +
            '"${DateFormat('dd/MM/yyyy').format(product.createdAt)}"');
      }
      await productsFile.writeAsString(productsContent.toString());

      // 3. Sales CSV
      final salesFile = File('${directory.path}/sales.csv');
      final salesContent = StringBuffer();
      salesContent
          .writeln('"Date","Product","Quantity","Unit Price","Total Amount"');
      for (var sale in sales) {
        final product = products.firstWhere(
          (p) => p.id == sale.productId,
          orElse: () => Product(
            id: 'unknown',
            name: 'Unknown Product',
            price: 0,
            quantity: 0,
            category: 'Uncategorized',
            createdAt: DateTime.now(),
          ),
        );
        salesContent.writeln(
            '"${DateFormat('dd/MM/yyyy').format(sale.date)}",' +
                '"${product.name.replaceAll('"', '""')}",' +
                '"${sale.quantity}",' +
                '"₹${sale.unitPrice.toStringAsFixed(2)}",' +
                '"₹${sale.totalAmount.toStringAsFixed(2)}"');
      }
      await salesFile.writeAsString(salesContent.toString());

      // 4. Expenses CSV
      final expensesFile = File('${directory.path}/expenses.csv');
      final expensesContent = StringBuffer();
      expensesContent
          .writeln('"Date","Description","Category","Amount","Notes"');
      for (var expense in expenses) {
        expensesContent.writeln(
            '"${DateFormat('dd/MM/yyyy').format(expense.date)}",' +
                '"${expense.description.replaceAll('"', '""')}",' +
                '"${expense.category.replaceAll('"', '""')}",' +
                '"₹${expense.amount.toStringAsFixed(2)}",' +
                '"${(expense.notes ?? "").replaceAll('"', '""')}"');
      }
      await expensesFile.writeAsString(expensesContent.toString());

      // 5. Category Performance CSV
      final categoryFile = File('${directory.path}/category_performance.csv');
      final categoryContent = StringBuffer();
      categoryContent.writeln('"Category","Total Sales","% of Total"');
      for (var entry in categoryPerformance.entries) {
        final percentage =
            totalSales > 0 ? (entry.value / totalSales) * 100 : 0;
        categoryContent.writeln('"${entry.key.replaceAll('"', '""')}",' +
            '"₹${entry.value.toStringAsFixed(2)}",' +
            '"${percentage.toStringAsFixed(1)}%"');
      }
      await categoryFile.writeAsString(categoryContent.toString());

      // Create a README file to explain the data
      final readmeFile = File('${directory.path}/README.txt');
      final readmeContent = '''
BizzyBuddy Business Report
Generated on ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}

This folder contains business data exported from BizzyBuddy:

1. summary.csv - Business performance summary
2. products.csv - Inventory of all products
3. sales.csv - Record of all sales transactions
4. expenses.csv - Record of all expenses
5. category_performance.csv - Analysis of sales by category

Files are in CSV format, which can be opened with Excel, Google Sheets,
or any spreadsheet application.
''';
      await readmeFile.writeAsString(readmeContent);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('CSV spreadsheets generated successfully!'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () async {
                // Create list of CSV files
                final List<XFile> csvFiles = [
                  XFile(summaryFile.path),
                  XFile(productsFile.path),
                  XFile(salesFile.path),
                  XFile(expensesFile.path),
                  XFile(categoryFile.path),
                ];
                await Share.shareXFiles(
                  csvFiles,
                  subject: 'BizzyBuddy Business Report - CSV',
                );
              },
            ),
          ),
        );
      }

      // Share the files
      final List<XFile> csvFiles = [
        XFile(summaryFile.path),
        XFile(productsFile.path),
        XFile(salesFile.path),
        XFile(expensesFile.path),
        XFile(categoryFile.path),
      ];
      await Share.shareXFiles(
        csvFiles,
        subject: 'BizzyBuddy Business Report - CSV',
      );
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating CSV report: $e')),
        );
      }
      debugPrint('Error exporting CSV data: $e');
    }
  }
}

class _AddEditProductDialog extends StatefulWidget {
  final Product? product;

  const _AddEditProductDialog({this.product});

  @override
  State<_AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<_AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _expiryDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _categoryController.text = widget.product!.category;
      _quantityController.text = widget.product!.quantity.toString();
      _priceController.text = widget.product!.price.toString();
      _notesController.text = widget.product!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: widget.product?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        category: _categoryController.text,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        description:
            _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      if (widget.product == null) {
        await Hive.box<Product>('products').add(product);
      } else {
        final box = Hive.box<Product>('products');
        final index = box.values.toList().indexOf(widget.product!);
        await box.putAt(index, product);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit Product',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  label: 'Name',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Category',
                  controller: _categoryController,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Quantity',
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Price',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expiry Date'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _expiryDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (date != null) {
                          setState(() => _expiryDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _expiryDate?.toString().split(' ')[0] ??
                                  'Not set',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _expiryDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365 * 5)),
                                );
                                if (date != null) {
                                  setState(() => _expiryDate = date);
                                }
                              },
                              icon: const Icon(Icons.calendar_today, size: 20),
                              label: const Text('Select Date'),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Notes (Optional)',
                  controller: _notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (keyboardType == TextInputType.number) {
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
