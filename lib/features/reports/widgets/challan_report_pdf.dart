import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gamdiwala/features/reports/models/challan_repot_dm.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

Future<void> generateChallanReportPDF(
  List<ChallanReportDm> data,
  String fromDate,
  String toDate,
  String reportType,
) async {
  final pdf = pw.Document();
  final primaryColor = PdfColor.fromHex('#138DB6');
  final blackColor = PdfColor.fromHex('#000000');
  final contrastNavy = PdfColor.fromHex('#1E3A8A');
  final lightGray = PdfColor.fromHex('#F8F9FA');
  final headerColor = PdfColor.fromHex('#138DB6');
  final totalRowColor = PdfColor.fromHex('#B2F2C2');
  final borderColor = PdfColor.fromHex('#D1D5DB');

  // Load custom fonts
  final fontData = await rootBundle.load('assets/fonts/Montserrat-Regular.ttf');
  final fontBoldData = await rootBundle.load(
    'assets/fonts/Montserrat-Bold.ttf',
  );
  final ttf = pw.Font.ttf(fontData);
  final ttfBold = pw.Font.ttf(fontBoldData);

  late Map<String, List<ChallanReportDm>> groupedData;

  if (reportType == 'Date Wise') {
    groupedData = _groupDataByChallanNo(data);
  } else if (reportType == 'Customer Wise') {
    groupedData = _groupDataByCustomer(data);
  } else {
    groupedData = _groupDataByItem(data);
  }

  // Calculate grand total
  final grandTotal = data.fold<double>(0, (sum, item) => sum + item.amount);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
      header: (context) => _buildHeaderWidget(fromDate, toDate, reportType),
      build: (context) {
        List<pw.Widget> allContent = [];

        // Process each group
        groupedData.forEach((groupKey, items) {
          String groupLabel;
          if (reportType == 'Date Wise') {
            groupLabel = 'Date: $groupKey';
          } else if (reportType == 'Customer Wise') {
            groupLabel = 'Customer: $groupKey';
          } else {
            groupLabel = 'Item: $groupKey';
          }

          // Add group header
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
                groupLabel,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          );

          // Split items into chunks to avoid too many rows in a single table
          const int chunkSize = 25; // Adjust this based on your needs
          for (int i = 0; i < items.length; i += chunkSize) {
            final chunk = items.sublist(
              i,
              (i + chunkSize > items.length) ? items.length : i + chunkSize,
            );

            final isLastChunk = (i + chunkSize >= items.length);

            allContent.add(
              _buildGroupTable(
                chunk,
                primaryColor,
                blackColor,
                lightGray,
                totalRowColor,
                contrastNavy,
                reportType,
                borderColor,
                showGroupTotal: isLastChunk,
                groupTotal: isLastChunk
                    ? items.fold<double>(0, (sum, item) => sum + item.amount)
                    : 0,
              ),
            );

            if (!isLastChunk) {
              allContent.add(pw.SizedBox(height: 4));
            }
          }

          allContent.add(pw.SizedBox(height: 4));
        });

        // Add grand total at the end
        allContent.add(
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            margin: const pw.EdgeInsets.only(top: 8),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'GRAND TOTAL',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  grandTotal.toStringAsFixed(2),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ],
            ),
          ),
        );

        return allContent;
      },
      footer: (context) => _buildFooter(context),
    ),
  );

  final formattedDateTime = DateFormat(
    'dd-MM-yyyy_HH-mm',
  ).format(DateTime.now());
  final filePath =
      '${(await getTemporaryDirectory()).path}/Challan_Report_${reportType.replaceAll(' ', '_')}_$formattedDateTime.pdf';

  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());
  await OpenFilex.open(file.path);
}

Map<String, List<ChallanReportDm>> _groupDataByChallanNo(
  List<ChallanReportDm> data,
) {
  Map<String, List<ChallanReportDm>> groupedData = {};

  for (var item in data) {
    String groupKey = item.date;

    if (!groupedData.containsKey(groupKey)) {
      groupedData[groupKey] = [];
    }
    groupedData[groupKey]!.add(item);
  }

  return groupedData;
}

Map<String, List<ChallanReportDm>> _groupDataByCustomer(
  List<ChallanReportDm> data,
) {
  Map<String, List<ChallanReportDm>> groupedData = {};

  for (var item in data) {
    String groupKey = item.customer;

    if (!groupedData.containsKey(groupKey)) {
      groupedData[groupKey] = [];
    }
    groupedData[groupKey]!.add(item);
  }

  return groupedData;
}

Map<String, List<ChallanReportDm>> _groupDataByItem(
  List<ChallanReportDm> data,
) {
  Map<String, List<ChallanReportDm>> groupedData = {};

  for (var item in data) {
    String groupKey = item.item;

    if (!groupedData.containsKey(groupKey)) {
      groupedData[groupKey] = [];
    }
    groupedData[groupKey]!.add(item);
  }

  return groupedData;
}

pw.Widget _buildHeaderWidget(
  String fromDate,
  String toDate,
  String reportType,
) {
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
                        'CHALLAN REPORT',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '($reportType)',
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
  List<ChallanReportDm> items,
  PdfColor primaryColor,
  PdfColor blackColor,
  PdfColor lightGray,
  PdfColor totalRowColor,
  PdfColor contrastNavy,
  String reportType,
  PdfColor borderColor, {
  bool showGroupTotal = true,
  double groupTotal = 0,
}) {
  List<pw.TableRow> tableRows = [];

  List<String> headers;
  Map<int, pw.TableColumnWidth> columnWidths;

  if (reportType == 'Date Wise') {
    headers = [
      'Challan No',
      'Customer',
      'Item',
      'Nos',
      'Pack',
      'Qty',
      'Rate',
      'Amount',
    ];
    columnWidths = {
      0: const pw.FlexColumnWidth(1),
      1: const pw.FlexColumnWidth(1.5),
      2: const pw.FlexColumnWidth(1.8),
      3: const pw.FlexColumnWidth(0.7),
      4: const pw.FlexColumnWidth(0.7),
      5: const pw.FlexColumnWidth(0.7),
      6: const pw.FlexColumnWidth(0.9),
      7: const pw.FlexColumnWidth(1),
    };
  } else if (reportType == 'Customer Wise') {
    headers = [
      'Challan No',
      'Date',
      'Item',
      'Nos',
      'Pack',
      'Qty',
      'Rate',
      'Amount',
    ];
    columnWidths = {
      0: const pw.FlexColumnWidth(1),
      1: const pw.FlexColumnWidth(1),
      2: const pw.FlexColumnWidth(1.8),
      3: const pw.FlexColumnWidth(0.7),
      4: const pw.FlexColumnWidth(0.7),
      5: const pw.FlexColumnWidth(0.7),
      6: const pw.FlexColumnWidth(0.9),
      7: const pw.FlexColumnWidth(1),
    };
  } else {
    headers = [
      'Challan No',
      'Date',
      'Customer',
      'Nos',
      'Pack',
      'Qty',
      'Rate',
      'Amount',
    ];
    columnWidths = {
      0: const pw.FlexColumnWidth(1),
      1: const pw.FlexColumnWidth(1),
      2: const pw.FlexColumnWidth(1.8),
      3: const pw.FlexColumnWidth(0.7),
      4: const pw.FlexColumnWidth(0.7),
      5: const pw.FlexColumnWidth(0.7),
      6: const pw.FlexColumnWidth(0.9),
      7: const pw.FlexColumnWidth(1),
    };
  }

  tableRows.add(
    pw.TableRow(
      decoration: pw.BoxDecoration(color: contrastNavy),
      children: headers.asMap().entries.map((entry) {
        final isRightAlign = entry.value == 'Rate' || entry.value == 'Amount';
        return pw.Container(
          padding: const pw.EdgeInsets.all(8),
          alignment: isRightAlign
              ? pw.Alignment.centerRight
              : pw.Alignment.centerLeft,
          child: pw.Text(
            entry.value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        );
      }).toList(),
    ),
  );

  for (int i = 0; i < items.length; i++) {
    final item = items[i];

    List<pw.Widget> rowCells;

    if (reportType == 'Date Wise') {
      rowCells = [
        _buildCell(item.challanNo, blackColor),
        _buildCell(item.customer, blackColor),
        _buildCell(item.item, blackColor),
        _buildCell(item.nos.toString(), blackColor),
        _buildCell(item.pack.toStringAsFixed(2), blackColor),
        _buildCell(item.qty.toStringAsFixed(2), blackColor),
        _buildCell(
          item.rate.toStringAsFixed(4),
          blackColor,
          isRightAlign: true,
        ),
        _buildCell(
          item.amount.toStringAsFixed(2),
          blackColor,
          isRightAlign: true,
        ),
      ];
    } else if (reportType == 'Customer Wise') {
      rowCells = [
        _buildCell(item.challanNo, blackColor),
        _buildCell(item.date, blackColor),
        _buildCell(item.item, blackColor),
        _buildCell(item.nos.toString(), blackColor),
        _buildCell(item.pack.toStringAsFixed(2), blackColor),
        _buildCell(item.qty.toStringAsFixed(2), blackColor),
        _buildCell(
          item.rate.toStringAsFixed(4),
          blackColor,
          isRightAlign: true,
        ),
        _buildCell(
          item.amount.toStringAsFixed(2),
          blackColor,
          isRightAlign: true,
        ),
      ];
    } else {
      rowCells = [
        _buildCell(item.challanNo, blackColor),
        _buildCell(item.date, blackColor),
        _buildCell(item.customer, blackColor),
        _buildCell(item.nos.toString(), blackColor),
        _buildCell(item.pack.toStringAsFixed(2), blackColor),
        _buildCell(item.qty.toStringAsFixed(2), blackColor),
        _buildCell(
          item.rate.toStringAsFixed(4),
          blackColor,
          isRightAlign: true,
        ),
        _buildCell(
          item.amount.toStringAsFixed(2),
          blackColor,
          isRightAlign: true,
        ),
      ];
    }

    tableRows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(
          color: (i % 2 == 0) ? PdfColors.white : lightGray,
        ),
        children: rowCells,
      ),
    );
  }

  if (showGroupTotal) {
    List<pw.Widget> totalCells = List.generate(
      headers.length - 1,
      (index) => pw.Container(
        padding: const pw.EdgeInsets.all(8),
        alignment: pw.Alignment.centerLeft,
        child: pw.Text(
          index == 0 ? 'Group Total' : '',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: blackColor,
          ),
        ),
      ),
    );

    totalCells.add(
      pw.Container(
        padding: const pw.EdgeInsets.all(8),
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          groupTotal.toStringAsFixed(2),
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: blackColor,
          ),
        ),
      ),
    );

    tableRows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: totalRowColor),
        children: totalCells,
      ),
    );
  }

  return pw.Table(
    border: pw.TableBorder.all(color: borderColor, width: 0.5),
    columnWidths: columnWidths,
    children: tableRows,
  );
}

pw.Widget _buildCell(String text, PdfColor color, {bool isRightAlign = false}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(6),
    alignment: isRightAlign
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft,
    child: pw.Text(text, style: pw.TextStyle(fontSize: 9, color: color)),
  );
}

pw.Widget _buildFooter(pw.Context context) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Challan Report',
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
