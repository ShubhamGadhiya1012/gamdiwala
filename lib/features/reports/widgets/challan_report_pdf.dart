import 'dart:io';
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

  final primaryColor = PdfColor.fromHex('#007BFF');
  final blackColor = PdfColor.fromHex('#000000');
  final contrastNavy = PdfColor.fromHex('#1E3A8A');
  final lightGray = PdfColor.fromHex('#F8F9FA');
  final headerColor = PdfColor.fromHex('#4A90E2');
  final totalRowColor = PdfColor.fromHex('#B2F2C2');

  late Map<String, List<ChallanReportDm>> groupedData;

  if (reportType == 'Date Wise') {
    groupedData = _groupDataByChallanNo(data);
  } else if (reportType == 'Customer Wise') {
    groupedData = _groupDataByCustomer(data);
  } else {
    groupedData = _groupDataByItem(data);
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      header: (context) => pw.Column(
        children: [
          _buildHeader(fromDate, toDate, reportType),
          pw.SizedBox(height: 20),
        ],
      ),
      build: (context) => _buildContent(
        groupedData,
        primaryColor,
        blackColor,
        lightGray,
        headerColor,
        totalRowColor,
        contrastNavy,
        reportType,
      ),
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

pw.Widget _buildHeader(String fromDate, String toDate, String reportType) {
  final primaryColor = PdfColor.fromHex('#007BFF');
  final formattedDateTime = DateFormat(
    'dd MMM yyyy, hh:mm a',
  ).format(DateTime.now());

  return pw.Container(
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
            pw.Column(
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
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.white),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Generated On',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.white),
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
          style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    ),
  );
}

List<pw.Widget> _buildContent(
  Map<String, List<ChallanReportDm>> groupedData,
  PdfColor primaryColor,
  PdfColor blackColor,
  PdfColor lightGray,
  PdfColor headerColor,
  PdfColor totalRowColor,
  PdfColor contrastNavy,
  String reportType,
) {
  List<pw.Widget> content = [];

  groupedData.forEach((groupKey, items) {
    // Add group heading outside table
    String groupLabel;
    if (reportType == 'Date Wise') {
      groupLabel = 'Date: $groupKey';
    } else if (reportType == 'Customer Wise') {
      groupLabel = 'Customer: $groupKey';
    } else {
      groupLabel = 'Item: $groupKey';
    }

    content.add(
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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

    // Add table with header and data
    content.add(
      _buildGroupTable(
        items,
        primaryColor,
        blackColor,
        lightGray,
        totalRowColor,
        contrastNavy,
        reportType,
      ),
    );

    content.add(pw.SizedBox(height: 4));
  });

  // Add grand total
  final grandTotal = groupedData.values
      .expand((items) => items)
      .fold<double>(0, (sum, item) => sum + item.amount);

  content.add(
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
          ),
        ],
      ),
    ),
  );

  return content;
}

pw.Widget _buildGroupTable(
  List<ChallanReportDm> items,
  PdfColor primaryColor,
  PdfColor blackColor,
  PdfColor lightGray,
  PdfColor totalRowColor,
  PdfColor contrastNavy,
  String reportType,
) {
  final borderColor = PdfColor.fromHex('#D1D5DB');
  List<pw.TableRow> tableRows = [];

  // Determine headers and column widths based on report type
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

  // Add header row
  tableRows.add(
    pw.TableRow(
      decoration: pw.BoxDecoration(color: contrastNavy),
      children: headers
          .map(
            (header) => pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          )
          .toList(),
    ),
  );

  // Add data rows
  double groupTotal = 0;
  for (int i = 0; i < items.length; i++) {
    final item = items[i];
    groupTotal += item.amount;

    List<pw.Widget> rowCells;

    if (reportType == 'Date Wise') {
      rowCells = [
        _buildCell(item.challanNo, blackColor),
        _buildCell(item.customer, blackColor),
        _buildCell(item.item, blackColor),
        _buildCell(item.nos.toString(), blackColor),
        _buildCell(item.pack.toStringAsFixed(2), blackColor),
        _buildCell(item.qty.toStringAsFixed(2), blackColor),
        _buildCell(item.rate.toStringAsFixed(4), blackColor),
        _buildCell(item.amount.toStringAsFixed(2), blackColor),
      ];
    } else if (reportType == 'Customer Wise') {
      rowCells = [
        _buildCell(item.challanNo, blackColor),
        _buildCell(item.date, blackColor),
        _buildCell(item.item, blackColor),
        _buildCell(item.nos.toString(), blackColor),
        _buildCell(item.pack.toStringAsFixed(2), blackColor),
        _buildCell(item.qty.toStringAsFixed(2), blackColor),
        _buildCell(item.rate.toStringAsFixed(4), blackColor),
        _buildCell(item.amount.toStringAsFixed(2), blackColor),
      ];
    } else {
      rowCells = [
        _buildCell(item.challanNo, blackColor),
        _buildCell(item.date, blackColor),
        _buildCell(item.customer, blackColor),
        _buildCell(item.nos.toString(), blackColor),
        _buildCell(item.pack.toStringAsFixed(2), blackColor),
        _buildCell(item.qty.toStringAsFixed(2), blackColor),
        _buildCell(item.rate.toStringAsFixed(4), blackColor),
        _buildCell(item.amount.toStringAsFixed(2), blackColor),
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

  // Add group total row
  List<pw.Widget> totalCells = List.generate(
    headers.length - 1,
    (index) => pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(color: totalRowColor),
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

  return pw.Table(
    border: pw.TableBorder.all(color: borderColor, width: 0.5),
    columnWidths: columnWidths,
    children: tableRows,
  );
}

pw.Widget _buildCell(String text, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(6),
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
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black),
        ),
        pw.Text(
          'Page ${context.pageNumber}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.black),
        ),
      ],
    ),
  );
}
