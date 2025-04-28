import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';

/// Provider for PDF export with language support
final pdfExportProvider = Provider.family<PdfExport, String>((ref, language) {
  return PdfExport();
});

/// Service for exporting data to PDF with simplified rendering
class PdfExport {
  PdfExport();

  /// Exports sales data to PDF with minimal UI elements
  Future<File> exportSalesData(List<Sale> sales, String language) async {
    try {
      debugPrint('Starting simplified PDF export');

      // Generate PDF in a separate isolate to avoid UI blocking
      final pdfBytes = await compute(_generateSimplePdfInIsolate, sales);

      // Save the PDF to a temporary file - back on main thread
      final tempDir = await getTemporaryDirectory();
      final String dateTimeStamp =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String filePath = '${tempDir.path}/sales_report_$dateTimeStamp.pdf';
      final File file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      debugPrint('PDF saved successfully to $filePath');
      return file;
    } catch (e, stackTrace) {
      debugPrint('Error creating PDF: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Static method for running in isolate with simplified layout
  static Future<Uint8List> _generateSimplePdfInIsolate(List<Sale> sales) async {
    // Create PDF document with minimal styling
    final pdf = pw.Document();

    // Calculate totals for summary
    final totalSales =
        sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final totalItems = sales.fold<int>(0, (sum, sale) => sum + sale.quantity);

    // Format currency simply
    final totalSalesFormatted = "Rs. ${totalSales.toStringAsFixed(2)}";
    final avgSaleFormatted =
        "Rs. ${(sales.isEmpty ? 0 : totalSales / sales.length).toStringAsFixed(2)}";

    // Get date formatter
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currentDate = dateFormat.format(DateTime.now());

    // Add title page with minimal styling
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Simple title
              pw.Text(
                "SALES REPORT",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Simple summary
              pw.Text("Report Date: $currentDate",
                  style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Text("Total Sales: $totalSalesFormatted",
                  style: const pw.TextStyle(fontSize: 12)),
              pw.Text("Total Items: $totalItems",
                  style: const pw.TextStyle(fontSize: 12)),
              pw.Text("Average Sale: $avgSaleFormatted",
                  style: const pw.TextStyle(fontSize: 12)),
              pw.Text("Number of Transactions: ${sales.length}",
                  style: const pw.TextStyle(fontSize: 12)),

              pw.SizedBox(height: 30),

              // Simple table headers
              pw.Row(
                children: [
                  pw.Expanded(
                      child: pw.Text("Date",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text("Product",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      child: pw.Text("Qty",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      child: pw.Text("Price",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      child: pw.Text("Total",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),
              pw.Divider(),

              // Simple table rows
              pw.Expanded(
                child: pw.ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return pw.Row(
                      children: [
                        pw.Expanded(
                            child: pw.Text(dateFormat.format(sale.date))),
                        pw.Expanded(flex: 2, child: pw.Text(sale.productId)),
                        pw.Expanded(child: pw.Text(sale.quantity.toString())),
                        pw.Expanded(
                            child: pw.Text(
                                "Rs. ${sale.unitPrice.toStringAsFixed(2)}")),
                        pw.Expanded(
                            child: pw.Text(
                                "Rs. ${sale.totalAmount.toStringAsFixed(2)}")),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    // Return PDF bytes
    return await pdf.save();
  }
}
