import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mobile_camsme_sana_project/core/models/order_model.dart';

class PdfInvoiceGenerator {
  static Future<void> generateInvoice(Order order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => _buildInvoiceContent(order),
      ),
    );

    // Print the document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generateAndPrintInvoice(Order order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => _buildInvoiceContent(order),
      ),
    );

    // Print the document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<Uint8List> generateInvoicePdf(Order order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => _buildInvoiceContent(order),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInvoiceContent(Order order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Order #${order.orderNumber}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: _getStatusColor(order.status)),
              ),
              child: pw.Text(
                order.status.label.toUpperCase(),
                style: pw.TextStyle(
                  color: _getStatusColor(order.status),
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 24),

        // Order Info
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Order Date:', _formatDate(order.createdAt)),
              pw.SizedBox(height: 8),
              if (order.warehouse != null)
                _buildInfoRow('Warehouse:', order.warehouse!.name),
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                _buildInfoRow('Notes:', order.notes!),
              ],
            ],
          ),
        ),
        pw.SizedBox(height: 24),

        // Items Table
        pw.Text(
          'Order Items',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
          },
                    children: [
            // Table Header
            pw.TableRow(
              children: [
                _buildTableCell('Product', isHeader: true),
                _buildTableCell('Qty', isHeader: true),
                _buildTableCell('Price', isHeader: true),
                _buildTableCell('Total', isHeader: true),
              ],
            ),
            // Table Rows
            ...order.items.map((item) => pw.TableRow(
              children: [
                _buildTableCell(item.product?.name ?? item.productName ?? 'Product'),
                _buildTableCell(item.quantity.toString()),
                _buildTableCell('\$${item.price.toStringAsFixed(2)}'),
                _buildTableCell('\$${item.subtotal.toStringAsFixed(2)}'),
              ],
            )),
          ],
        ),
        pw.SizedBox(height: 24),

        // Summary
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _buildSummaryRow('Subtotal:', order.subtotal),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              _buildSummaryRow(
                'Total:',
                order.total,
                isBold: true,
                fontSize: 16,
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 32),

        // Footer
        pw.Center(
          child: pw.Text(
            'Thank you for your order!',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(value),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 12 : 10,
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(String label, double amount, {bool isBold = false, double fontSize = 12}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
        pw.Text(
          '\$${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }

  static PdfColor _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return PdfColors.orange800;
      case OrderStatus.processing:
        return PdfColors.blue800;
      case OrderStatus.completed:
        return PdfColors.green800;
      case OrderStatus.cancelled:
        return PdfColors.red800;
    }
  }

  static String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
