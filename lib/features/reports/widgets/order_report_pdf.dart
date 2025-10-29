import 'dart:io';
import 'package:gamdiwala/features/reports/models/order_report_dm.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

Future<void> generateOrderReportPDF(
  List<OrderReportDm> data,
  String fromDate,
  String toDate,
  String status,
  String type,
) async {
  final pdf = pw.Document();
  final primaryColor = PdfColor.fromHex('#138DB6');
  final blackColor = PdfColor.fromHex('#000000');
  final contrastNavy = PdfColor.fromHex('#1E3A8A');
  final lightGray = PdfColor.fromHex('#F8F9FA');
  final headerColor = PdfColor.fromHex('#138DB6');
  final totalRowColor = PdfColor.fromHex('#B2F2C2');

  late Map<String, List<OrderReportDm>> groupedData;

  if (type == 'SUMMARY') {
    groupedData = {'All Orders': data};
  } else {
    groupedData = {'All Orders': data};
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: type == 'WITHCHALLAN'
          ? PdfPageFormat.a4.landscape
          : PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      header: (context) => pw.Column(
        children: [
          _buildHeader(fromDate, toDate, status, type),
          pw.SizedBox(height: 20),
          _buildTableHeader(type, contrastNavy),
          pw.SizedBox(height: 0),
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
        type,
      ),
      footer: (context) => _buildFooter(context),
    ),
  );

  final formattedDateTime = DateFormat(
    'dd-MM-yyyy_HH-mm',
  ).format(DateTime.now());
  final filePath =
      '${(await getTemporaryDirectory()).path}/Order_Report_${type}_$formattedDateTime.pdf';

  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());
  await OpenFilex.open(file.path);
}

pw.Widget _buildHeader(
  String fromDate,
  String toDate,
  String status,
  String type,
) {
  final primaryColor = PdfColor.fromHex('#138DB6');
  final formattedDateTime = DateFormat(
    'dd MMM yyyy, hh:mm a',
  ).format(DateTime.now());

  String reportTitle = 'ORDER REPORT';
  if (type == 'WITH CHALLAN') {
    reportTitle = 'ORDER REPORT (Detail with Challan)';
  } else if (type == 'SUMMARY') {
    reportTitle = 'ORDER REPORT (Summary)';
  } else {
    reportTitle = 'ORDER REPORT (Detail)';
  }

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
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    reportTitle,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Status: $status',
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.white),
                  ),
                ],
              ),
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

pw.Widget _buildTableHeader(String type, PdfColor contrastNavy) {
  final borderColor = PdfColor.fromHex('#D1D5DB');
  List<String> headers;
  Map<int, pw.TableColumnWidth> columnWidths;

  if (type == 'DETAIL') {
    headers = [
      'Order',
      'Date',
      'Customer',
      'Item',
      'Nos',
      'Pack',
      'Qty',
      'Dispatch Qty',
      'Pending Qty',
      'Rate',
      'Amount',
    ];
    columnWidths = {
      0: const pw.FlexColumnWidth(1),
      1: const pw.FlexColumnWidth(1),
      2: const pw.FlexColumnWidth(1.5),
      3: const pw.FlexColumnWidth(1.8),
      4: const pw.FlexColumnWidth(0.6),
      5: const pw.FlexColumnWidth(0.7),
      6: const pw.FlexColumnWidth(0.7),
      7: const pw.FlexColumnWidth(0.9),
      8: const pw.FlexColumnWidth(0.9),
      9: const pw.FlexColumnWidth(0.8),
      10: const pw.FlexColumnWidth(0.9),
    };
  } else if (type == 'WITH CHALLAN') {
    headers = [
      'Order',
      'Date',
      'Customer',
      'Item',
      'Nos',
      'Pack',
      'Qty',
      'Dispatch Qty',
      'Pending Qty',
      'Rate',
      'Amount',
      'Challan',
      'Date',
    ];
    columnWidths = {
      0: const pw.FlexColumnWidth(0.9),
      1: const pw.FlexColumnWidth(0.9),
      2: const pw.FlexColumnWidth(1.3),
      3: const pw.FlexColumnWidth(1.5),
      4: const pw.FlexColumnWidth(0.5),
      5: const pw.FlexColumnWidth(0.6),
      6: const pw.FlexColumnWidth(0.6),
      7: const pw.FlexColumnWidth(0.8),
      8: const pw.FlexColumnWidth(0.8),
      9: const pw.FlexColumnWidth(0.7),
      10: const pw.FlexColumnWidth(0.8),
      11: const pw.FlexColumnWidth(0.9),
      12: const pw.FlexColumnWidth(0.9),
    };
  } else {
    headers = [
      'Customer',
      'Item',
      'Nos',
      'Pack',
      'Order Qty',
      'Dispatch Qty',
      'Pending Qty',
    ];
    columnWidths = {
      0: const pw.FlexColumnWidth(2),
      1: const pw.FlexColumnWidth(2.5),
      2: const pw.FlexColumnWidth(1),
      3: const pw.FlexColumnWidth(1),
      4: const pw.FlexColumnWidth(1.2),
      5: const pw.FlexColumnWidth(1.2),
      6: const pw.FlexColumnWidth(1.2),
    };
  }

  return pw.Table(
    border: pw.TableBorder.all(color: borderColor, width: 0.5),
    columnWidths: columnWidths,
    children: [
      pw.TableRow(
        decoration: pw.BoxDecoration(color: contrastNavy),
        children: headers
            .asMap()
            .entries
            .map(
              (entry) => pw.Container(
                padding: const pw.EdgeInsets.all(8),
                alignment: (entry.value == 'Rate' || entry.value == 'Amount')
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
              ),
            )
            .toList(),
      ),
    ],
  );
}

List<pw.Widget> _buildContent(
  Map<String, List<OrderReportDm>> groupedData,
  PdfColor primaryColor,
  PdfColor blackColor,
  PdfColor lightGray,
  PdfColor headerColor,
  PdfColor totalRowColor,
  PdfColor contrastNavy,
  String type,
) {
  List<pw.Widget> content = [];

  content.add(
    _buildGroupTable(
      groupedData.values.first,
      primaryColor,
      blackColor,
      lightGray,
      totalRowColor,
      contrastNavy,
      type,
    ),
  );

  final grandTotal = groupedData.values
      .expand((items) => items)
      .fold<double>(0, (sum, item) => sum + item.amount);

  if (type != 'SUMMARY') {
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
  }

  return content;
}

pw.Widget _buildGroupTable(
  List<OrderReportDm> items,
  PdfColor primaryColor,
  PdfColor blackColor,
  PdfColor lightGray,
  PdfColor totalRowColor,
  PdfColor contrastNavy,
  String type,
) {
  final borderColor = PdfColor.fromHex('#D1D5DB');
  List<pw.TableRow> tableRows = [];

  Map<int, pw.TableColumnWidth> columnWidths;

  if (type == 'DETAIL') {
    columnWidths = {
      0: const pw.FlexColumnWidth(1),
      1: const pw.FlexColumnWidth(1),
      2: const pw.FlexColumnWidth(1.5),
      3: const pw.FlexColumnWidth(1.8),
      4: const pw.FlexColumnWidth(0.6),
      5: const pw.FlexColumnWidth(0.7),
      6: const pw.FlexColumnWidth(0.7),
      7: const pw.FlexColumnWidth(0.9),
      8: const pw.FlexColumnWidth(0.9),
      9: const pw.FlexColumnWidth(0.8),
      10: const pw.FlexColumnWidth(0.9),
    };
  } else if (type == 'WITH CHALLAN') {
    columnWidths = {
      0: const pw.FlexColumnWidth(0.9),
      1: const pw.FlexColumnWidth(0.9),
      2: const pw.FlexColumnWidth(1.3),
      3: const pw.FlexColumnWidth(1.5),
      4: const pw.FlexColumnWidth(0.5),
      5: const pw.FlexColumnWidth(0.6),
      6: const pw.FlexColumnWidth(0.6),
      7: const pw.FlexColumnWidth(0.8),
      8: const pw.FlexColumnWidth(0.8),
      9: const pw.FlexColumnWidth(0.7),
      10: const pw.FlexColumnWidth(0.8),
      11: const pw.FlexColumnWidth(0.9),
      12: const pw.FlexColumnWidth(0.9),
    };
  } else {
    columnWidths = {
      0: const pw.FlexColumnWidth(2),
      1: const pw.FlexColumnWidth(2.5),
      2: const pw.FlexColumnWidth(1),
      3: const pw.FlexColumnWidth(1),
      4: const pw.FlexColumnWidth(1.2),
      5: const pw.FlexColumnWidth(1.2),
      6: const pw.FlexColumnWidth(1.2),
    };
  }

  if (type == 'SUMMARY') {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      List<pw.Widget> rowCells = [
        _buildCell(item.customer, blackColor),
        _buildCell(item.item, blackColor),
        _buildCell(item.nos.toStringAsFixed(0), blackColor),
        _buildCell(item.pack.toStringAsFixed(2), blackColor),
        _buildCell(item.qty.toStringAsFixed(2), blackColor),
        _buildCell(item.dispatchQty.toStringAsFixed(2), blackColor),
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
  } else {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      List<pw.Widget> rowCells;

      if (type == 'DETAIL') {
        rowCells = [
          _buildCell(item.orderNo, blackColor),
          _buildCell(item.orderDate, blackColor),
          _buildCell(item.customer, blackColor),
          _buildCell(item.item, blackColor),
          _buildCell(item.nos.toString(), blackColor),
          _buildCell(item.pack.toStringAsFixed(2), blackColor),
          _buildCell(item.qty.toStringAsFixed(2), blackColor),
          _buildCell(item.dispatchQty.toStringAsFixed(2), blackColor),
          _buildCell(item.pendingQty.toStringAsFixed(2), blackColor),
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
          _buildCell(item.orderNo, blackColor),
          _buildCell(item.orderDate, blackColor),
          _buildCell(item.customer, blackColor),
          _buildCell(item.item, blackColor),
          _buildCell(item.nos.toString(), blackColor),
          _buildCell(item.pack.toStringAsFixed(2), blackColor),
          _buildCell(item.qty.toStringAsFixed(2), blackColor),
          _buildCell(item.dispatchQty.toStringAsFixed(2), blackColor),
          _buildCell(item.pendingQty.toStringAsFixed(2), blackColor),
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
          _buildCell(item.challanNo, blackColor),
          _buildCell(item.challanDate, blackColor),
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
  }

  return pw.Table(
    border: pw.TableBorder.all(color: borderColor, width: 0.5),
    columnWidths: columnWidths,
    children: tableRows,
  );
}

pw.Widget _buildCell(
  String text,
  PdfColor color, {
  String? type,
  bool isRightAlign = false,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(6),
    alignment: isRightAlign
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: type == 'WITHCHALLAN' ? 7 : 9,
        color: color,
      ),
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
          'Order Report',
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
