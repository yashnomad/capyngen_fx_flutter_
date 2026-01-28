import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../view/account/buy_sell_trade/model/trade_model.dart';

class TradePdfService {
  static Future<String> saveTradeHistoryPdf({
    required List<TradeModel> trades,
    required String accountId,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          _buildHeader(accountId, trades.length),
          pw.SizedBox(height: 20),
          _buildTradeTable(trades),
        ],
      ),
    );

    Directory directory;

    if (Platform.isAndroid) {
      directory = (await getExternalStorageDirectory())!;
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final downloadDir = Directory('${directory.path}/Download');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final timestamp =
    DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${downloadDir.path}/TradeReport_$timestamp.pdf';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }


  static pw.Widget _buildHeader(String accountId, int count) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Trade History Report",
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text("Account ID: $accountId"),
        pw.Text("Total Records: $count"),
        pw.Text(
            "Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}"),
      ],
    );
  }

  static pw.Widget _buildTradeTable(List<TradeModel> trades) {
    final headers = ['Ticket', 'Symbol', 'Type', 'Vol', 'Open', 'Close', 'P/L'];

    final data = trades
        .map((t) => [
              t.transactionId ?? t.id.substring(0, 6),
              t.symbol ?? '-',
              t.bs ?? '-',
              t.lot?.toString() ?? '0',
              t.avg?.toStringAsFixed(5) ?? '0.0',
              t.exit?.toStringAsFixed(5) ?? '0.0',
              t.profitLossAmount?.toStringAsFixed(2) ?? '0.0',
            ])
        .toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
      headerDecoration:
          const pw.BoxDecoration(color: PdfColor.fromInt(0xFF2962FF)),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
      },
    );
  }
}
