import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gamdiwala/features/reports/models/invoice_report_dm.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

Future<void> generateInvoiceReportPDF(
  List<InvoiceReportDm> data,
  String fromDate,
  String toDate,
) async {
  final pdf = pw.Document();
  final primaryColor = PdfColor.fromHex('#138DB6');
  final blackColor = PdfColor.fromHex('#000000');
  final contrastNavy = PdfColor.fromHex('#1E3A8A');
  final lightGray = PdfColor.fromHex('#F8F9FA');
  final headerColor = PdfColor.fromHex('#138DB6');
  final borderColor = PdfColor.fromHex('#D1D5DB');

  // Load custom fonts
  final fontData = await rootBundle.load('assets/fonts/Montserrat-Regular.ttf');
  final fontBoldData = await rootBundle.load(
    'assets/fonts/Montserrat-Bold.ttf',
  );
  final ttf = pw.Font.ttf(fontData);
  final ttfBold = pw.Font.ttf(fontBoldData);

  // Group data by customer (party-wise)
  Map<String, List<InvoiceReportDm>> groupedData = _groupDataByCustomer(data);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(20),
      theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
      header: (context) => _buildHeaderWidget(fromDate, toDate),
      build: (context) {
        List<pw.Widget> allContent = [];

        // Process each customer group
        groupedData.forEach((customerName, items) {
          String displayName = customerName.isEmpty
              ? 'Unknown Customer'
              : customerName;

          // Add customer header
          allContent.add(
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              margin: const pw.EdgeInsets.only(bottom: 8, top: 8),
              decoration: pw.BoxDecoration(
                color: headerColor,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'Customer: $displayName',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          );

          // Split items into chunks
          const int chunkSize = 20;
          for (int i = 0; i < items.length; i += chunkSize) {
            final chunk = items.sublist(
              i,
              (i + chunkSize > items.length) ? items.length : i + chunkSize,
            );

            allContent.add(
              _buildGroupTable(
                chunk,
                primaryColor,
                blackColor,
                lightGray,
                contrastNavy,
                borderColor,
              ),
            );

            if (i + chunkSize < items.length) {
              allContent.add(pw.SizedBox(height: 4));
            }
          }

          allContent.add(pw.SizedBox(height: 8));
        });

        return allContent;
      },
      footer: (context) => _buildFooter(context),
    ),
  );

  final formattedDateTime = DateFormat(
    'dd-MM-yyyy_HH-mm',
  ).format(DateTime.now());
  final filePath =
      '${(await getTemporaryDirectory()).path}/Invoice_Report_$formattedDateTime.pdf';

  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());
  await OpenFilex.open(file.path);
}

Map<String, List<InvoiceReportDm>> _groupDataByCustomer(
  List<InvoiceReportDm> data,
) {
  Map<String, List<InvoiceReportDm>> groupedData = {};

  for (var item in data) {
    String groupKey = item.customerName ?? '';

    if (!groupedData.containsKey(groupKey)) {
      groupedData[groupKey] = [];
    }
    groupedData[groupKey]!.add(item);
  }

  return groupedData;
}

pw.Widget _buildHeaderWidget(String fromDate, String toDate) {
  final primaryColor = PdfColor.fromHex('#138DB6');
  final formattedDateTime = DateFormat(
    'dd MMM yyyy, hh:mm a',
  ).format(DateTime.now());

  return pw.Column(
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: pw.BoxDecoration(
          color: primaryColor,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE REPORT',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '(Party Wise)',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Generated On',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      formattedDateTime,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'From: $fromDate   To: $toDate',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),
    ],
  );
}

pw.Widget _buildGroupTable(
  List<InvoiceReportDm> items,
  PdfColor primaryColor,
  PdfColor blackColor,
  PdfColor lightGray,
  PdfColor contrastNavy,
  PdfColor borderColor,
) {
  List<pw.TableRow> tableRows = [];

  List<String> headers = [
    'Challan No',
    'Date',
    'Vehicle',
    'Bill Period',
    'Item Name',
    'Carat',
    'Pack',
    'Total Nos',
    'Qty',
    'Invoice No',
    'Invoice Date',
    'Invoice Qty',
    'Pending Qty',
  ];

  Map<int, pw.TableColumnWidth> columnWidths = {
    0: const pw.FlexColumnWidth(1.2),
    1: const pw.FlexColumnWidth(1),
    2: const pw.FlexColumnWidth(0.8),
    3: const pw.FlexColumnWidth(0.8),
    4: const pw.FlexColumnWidth(1.8),
    5: const pw.FlexColumnWidth(0.6),
    6: const pw.FlexColumnWidth(0.6),
    7: const pw.FlexColumnWidth(0.7),
    8: const pw.FlexColumnWidth(0.7),
    9: const pw.FlexColumnWidth(1.2),
    10: const pw.FlexColumnWidth(1),
    11: const pw.FlexColumnWidth(0.8),
    12: const pw.FlexColumnWidth(0.8),
  };

  // Header row
  tableRows.add(
    pw.TableRow(
      decoration: pw.BoxDecoration(color: contrastNavy),
      children: headers.map((header) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(6),
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            header,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        );
      }).toList(),
    ),
  );

  // Data rows
  for (int i = 0; i < items.length; i++) {
    final item = items[i];

    List<pw.Widget> rowCells = [
      _buildCell(item.challanNo, blackColor),
      _buildCell(item.date, blackColor),
      _buildCell(item.vehicle, blackColor),
      _buildCell(item.billPeriod ?? '-', blackColor),
      _buildCell(item.itemName, blackColor),
      _buildCell(item.carat.toString(), blackColor),
      _buildCell(item.pack.toStringAsFixed(2), blackColor),
      _buildCell(item.totalNos.toString(), blackColor),
      _buildCell(item.qty.toStringAsFixed(2), blackColor),
      _buildCell(item.invoiceNo ?? '-', blackColor),
      _buildCell(item.invoiceDate ?? '-', blackColor),
      _buildCell(item.invoiceQty.toStringAsFixed(2), blackColor),
      _buildCell(item.pendingQty.toStringAsFixed(2), blackColor),
    ];

    tableRows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(
          color: (i % 2 == 0) ? PdfColors.white : lightGray,
        ),
        children: rowCells,
      ),
    );
  }

  return pw.Table(
    border: pw.TableBorder.all(color: borderColor, width: 0.5),
    columnWidths: columnWidths,
    children: tableRows,
  );
}

pw.Widget _buildCell(String text, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(5),
    alignment: pw.Alignment.centerLeft,
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 7, color: color),
      maxLines: 2,
      overflow: pw.TextOverflow.clip,
    ),
  );
}

pw.Widget _buildFooter(pw.Context context) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Invoice Report',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
        ),
        pw.Text(
          'Page ${context.pageNumber}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.black),
        ),
      ],
    ),
  );
}
