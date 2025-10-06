import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/formatters.dart';
import '../../features/producer/domain/models/producer_collection_model.dart';

class PdfService {
  static Future<File> generateCollectionReport({
    required List<ProducerCollectionModel> collections,
    required String producerName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final totalLiters = collections.fold(0.0, (sum, c) => sum + c.quantity);
    final approvedLiters = collections
        .where((c) => c.approved)
        .fold(0.0, (sum, c) => sum + c.quantity);
    final rejectedLiters = collections
        .where((c) => !c.approved)
        .fold(0.0, (sum, c) => sum + c.quantity);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(producerName, startDate, endDate),
          pw.SizedBox(height: 20),
          _buildSummary(totalLiters, approvedLiters, rejectedLiters),
          pw.SizedBox(height: 20),
          _buildCollectionsTable(collections),
          pw.SizedBox(height: 30),
          _buildFooter(),
        ],
      ),
    );

    return await _savePdf(
      pdf,
      'relatorio_coletas_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  static pw.Widget _buildHeader(
    String producerName,
    DateTime startDate,
    DateTime endDate,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PuroLácteo',
          style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Relatório de Coletas',
          style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
        ),
        pw.Divider(thickness: 2),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Produtor: $producerName',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Período: ${Formatters.formatDate(startDate)} - ${Formatters.formatDate(endDate)}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Data de emissão:',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  Formatters.formatDateTime(DateTime.now()),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(
    double total,
    double approved,
    double rejected,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Total',
            Formatters.formatLiters(total),
            PdfColors.blue,
          ),
          _buildSummaryItem(
            'Aprovado',
            Formatters.formatLiters(approved),
            PdfColors.green,
          ),
          _buildSummaryItem(
            'Reprovado',
            Formatters.formatLiters(rejected),
            PdfColors.red,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildCollectionsTable(
    List<ProducerCollectionModel> collections,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Data', isHeader: true),
            _buildTableCell('Quantidade', isHeader: true),
            _buildTableCell('Temp.', isHeader: true),
            _buildTableCell('Acidez', isHeader: true),
            _buildTableCell('Status', isHeader: true),
          ],
        ),
        // Rows
        ...collections.map(
          (collection) => pw.TableRow(
            children: [
              _buildTableCell(Formatters.formatDate(collection.date)),
              _buildTableCell(Formatters.formatLiters(collection.quantity)),
              _buildTableCell(
                Formatters.formatTemperature(collection.temperature),
              ),
              _buildTableCell(collection.acidity.toStringAsFixed(1)),
              _buildTableCell(
                collection.quality,
                textColor: collection.approved
                    ? PdfColors.green
                    : PdfColors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    PdfColor? textColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Documento gerado automaticamente pelo sistema PuroLácteo',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              'Assinatura: _____________________',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
      ],
    );
  }

  static Future<File> _savePdf(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> sharePdf(File pdfFile) async {
    await Share.shareXFiles([
      XFile(pdfFile.path),
    ], subject: 'Relatório de Coletas - PuroLácteo');
  }
}
