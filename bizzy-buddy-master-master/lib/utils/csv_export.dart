import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../models/expense.dart';

final csvExportProvider = Provider((ref) => CSVExport());

class CSVExport {
  /// Exports sales data to a CSV file
  Future<File> exportSalesData(List<Sale> sales) async {
    // Define headers
    final headers = [
      'Date',
      'Product ID',
      'Quantity',
      'Unit Price (₹)',
      'Total Amount (₹)',
      'Customer',
    ];

    // Prepare rows
    final rows = [headers];

    // Add data rows
    for (var sale in sales) {
      // Format date
      final formattedDate = DateFormat('yyyy-MM-dd').format(sale.date);

      rows.add([
        formattedDate,
        sale.productId,
        sale.quantity.toString(),
        sale.unitPrice.toString(),
        sale.totalAmount.toString(),
        sale.customerName ?? '',
      ]);
    }

    // Add summary row
    final totalSales =
        sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    rows.add(['TOTAL', '', '', '', totalSales.toString(), '']);

    // Convert to CSV
    final csv = const ListToCsvConverter().convert(rows);

    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'bizzybuddy_sales_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = File('${tempDir.path}/$fileName');

    // Write file
    await file.writeAsString(csv);
    return file;
  }

  /// Exports products data to a CSV file
  Future<File> exportProductsData(List<Product> products) async {
    // Define headers
    final headers = [
      'ID',
      'Name',
      'Category',
      'Description',
      'Price (₹)',
      'Quantity',
      'Value (₹)',
    ];

    // Prepare rows
    final rows = [headers];

    // Add data rows
    for (var product in products) {
      rows.add([
        product.id,
        product.name,
        product.category,
        product.description ?? '',
        product.price.toString(),
        product.quantity.toString(),
        (product.price * product.quantity).toString(),
      ]);
    }

    // Add summary row
    final totalValue = products.fold<double>(
        0, (sum, product) => sum + (product.price * product.quantity));
    rows.add(['TOTAL', '', '', '', '', '', totalValue.toString()]);

    // Convert to CSV
    final csv = const ListToCsvConverter().convert(rows);

    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'bizzybuddy_products_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = File('${tempDir.path}/$fileName');

    // Write file
    await file.writeAsString(csv);
    return file;
  }

  /// Exports expenses data to a CSV file
  Future<File> exportExpensesData(List<Expense> expenses) async {
    // Define headers
    final headers = [
      'Date',
      'Category',
      'Description',
      'Amount (₹)',
    ];

    // Prepare rows
    final rows = [headers];

    // Add data rows
    for (var expense in expenses) {
      // Format date
      final formattedDate = DateFormat('yyyy-MM-dd').format(expense.date);

      rows.add([
        formattedDate,
        expense.category,
        expense.description ?? '',
        expense.amount.toString(),
      ]);
    }

    // Add summary row
    final totalExpenses =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    rows.add(['TOTAL', '', '', totalExpenses.toString()]);

    // Convert to CSV
    final csv = const ListToCsvConverter().convert(rows);

    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'bizzybuddy_expenses_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = File('${tempDir.path}/$fileName');

    // Write file
    await file.writeAsString(csv);
    return file;
  }
}
