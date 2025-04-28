import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../models/expense.dart';

final excelExportProvider = Provider((ref) => ExcelExport());

class ExcelExport {
  /// Exports sales data to an Excel file
  Future<File> exportSalesData(List<Sale> sales) async {
    // Create a new Excel workbook
    final excel = Excel.createExcel();
    final sheet = excel['Sales Report'];

    // Define headers
    final headers = [
      'Date',
      'Product ID',
      'Quantity',
      'Unit Price (₹)',
      'Total Amount (₹)',
      'Customer',
    ];

    // Add headers to sheet
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
    }

    // Add data rows
    for (var i = 0; i < sales.length; i++) {
      final sale = sales[i];
      final rowIndex = i + 1;

      // Format date
      final formattedDate = DateFormat('yyyy-MM-dd').format(sale.date);

      // Add cells
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(formattedDate);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(sale.productId);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = IntCellValue(sale.quantity);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = DoubleCellValue(sale.unitPrice);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = DoubleCellValue(sale.totalAmount);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = TextCellValue(sale.customerName ?? '');
    }

    // Add summary row
    final summaryRowIndex = sales.length + 2;
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRowIndex))
      ..value = TextCellValue('TOTAL')
      ..cellStyle = CellStyle(bold: true);

    // Calculate total sales
    final totalSales =
        sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);

    // Add total sales
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: summaryRowIndex))
      ..value = DoubleCellValue(totalSales)
      ..cellStyle = CellStyle(bold: true);

    // Set column widths
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 10);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 15);
    sheet.setColumnWidth(5, 20);

    // Save the Excel file
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');

    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'bizzybuddy_sales_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final file = File('${tempDir.path}/$fileName');

    // Write file
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Exports products data to an Excel file
  Future<File> exportProductsData(List<Product> products) async {
    // Create a new Excel workbook
    final excel = Excel.createExcel();
    final sheet = excel['Products Report'];

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

    // Add headers to sheet
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
    }

    // Add data rows
    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      final rowIndex = i + 1;

      // Add cells
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(product.id);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(product.name);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(product.category);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(product.description ?? '');

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = DoubleCellValue(product.price);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = IntCellValue(product.quantity);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = DoubleCellValue(product.price * product.quantity);
    }

    // Add summary row
    final summaryRowIndex = products.length + 2;
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRowIndex))
      ..value = TextCellValue('TOTAL')
      ..cellStyle = CellStyle(bold: true);

    // Calculate total inventory value
    final totalValue = products.fold<double>(
        0, (sum, product) => sum + (product.price * product.quantity));

    // Add total value
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: summaryRowIndex))
      ..value = DoubleCellValue(totalValue)
      ..cellStyle = CellStyle(bold: true);

    // Set column widths
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 30);
    sheet.setColumnWidth(4, 15);
    sheet.setColumnWidth(5, 10);
    sheet.setColumnWidth(6, 15);

    // Save the Excel file
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');

    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'bizzybuddy_products_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final file = File('${tempDir.path}/$fileName');

    // Write file
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Exports expenses data to an Excel file
  Future<File> exportExpensesData(List<Expense> expenses) async {
    // Create a new Excel workbook
    final excel = Excel.createExcel();
    final sheet = excel['Expenses Report'];

    // Define headers
    final headers = [
      'Date',
      'Category',
      'Description',
      'Amount (₹)',
    ];

    // Add headers to sheet
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
    }

    // Add data rows
    for (var i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      final rowIndex = i + 1;

      // Format date
      final formattedDate = DateFormat('yyyy-MM-dd').format(expense.date);

      // Add cells
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(formattedDate);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(expense.category);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(expense.description);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = DoubleCellValue(expense.amount);
    }

    // Add summary row
    final summaryRowIndex = expenses.length + 2;
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRowIndex))
      ..value = TextCellValue('TOTAL')
      ..cellStyle = CellStyle(bold: true);

    // Calculate total expenses
    final totalExpenses =
        expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

    // Add total expenses
    sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: summaryRowIndex))
      ..value = DoubleCellValue(totalExpenses)
      ..cellStyle = CellStyle(bold: true);

    // Set column widths
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 40);
    sheet.setColumnWidth(3, 15);

    // Save the Excel file
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');

    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'bizzybuddy_expenses_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final file = File('${tempDir.path}/$fileName');

    // Write file
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Exports all business data (sales, products, expenses) to a single Excel file
  Future<File> exportAllData({
    required List<Sale> sales,
    required List<Product> products,
    required List<Expense> expenses,
  }) async {
    // Create a new Excel workbook
    final excel = Excel.createExcel();

    // Remove default sheet
    excel.delete('Sheet1');

    // Add sales sheet
    final salesSheet = excel['Sales'];
    _addSalesDataToSheet(salesSheet, sales);

    // Add products sheet
    final productsSheet = excel['Products'];
    _addProductsDataToSheet(productsSheet, products);

    // Add expenses sheet
    final expensesSheet = excel['Expenses'];
    _addExpensesDataToSheet(expensesSheet, expenses);

    // Save the Excel file
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');

    // Get temp directory
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'bizzybuddy_all_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final file = File('${tempDir.path}/$fileName');

    // Write file
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Helper method to add sales data to a sheet
  void _addSalesDataToSheet(Sheet sheet, List<Sale> sales) {
    // Define headers
    final headers = [
      'Date',
      'Product ID',
      'Quantity',
      'Unit Price (₹)',
      'Total Amount (₹)',
      'Customer',
    ];

    // Add headers to sheet
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
    }

    // Add data rows
    for (var i = 0; i < sales.length; i++) {
      final sale = sales[i];
      final rowIndex = i + 1;

      // Format date
      final formattedDate = DateFormat('yyyy-MM-dd').format(sale.date);

      // Add cells
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(formattedDate);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(sale.productId);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = IntCellValue(sale.quantity);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = DoubleCellValue(sale.unitPrice);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = DoubleCellValue(sale.totalAmount);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = TextCellValue(sale.customerName ?? '');
    }

    // Set column widths
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 10);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 15);
    sheet.setColumnWidth(5, 20);
  }

  /// Helper method to add products data to a sheet
  void _addProductsDataToSheet(Sheet sheet, List<Product> products) {
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

    // Add headers to sheet
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
    }

    // Add data rows
    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      final rowIndex = i + 1;

      // Add cells
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(product.id);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(product.name);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(product.category);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(product.description ?? '');

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = DoubleCellValue(product.price);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = IntCellValue(product.quantity);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = DoubleCellValue(product.price * product.quantity);
    }

    // Set column widths
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 30);
    sheet.setColumnWidth(4, 15);
    sheet.setColumnWidth(5, 10);
    sheet.setColumnWidth(6, 15);
  }

  /// Helper method to add expenses data to a sheet
  void _addExpensesDataToSheet(Sheet sheet, List<Expense> expenses) {
    // Define headers
    final headers = [
      'Date',
      'Category',
      'Description',
      'Amount (₹)',
    ];

    // Add headers to sheet
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
    }

    // Add data rows
    for (var i = 0; i < expenses.length; i++) {
      final expense = expenses[i];
      final rowIndex = i + 1;

      // Format date
      final formattedDate = DateFormat('yyyy-MM-dd').format(expense.date);

      // Add cells
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(formattedDate);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(expense.category);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(expense.description);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = DoubleCellValue(expense.amount);
    }

    // Set column widths
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 20);
    sheet.setColumnWidth(2, 40);
    sheet.setColumnWidth(3, 15);
  }
}
