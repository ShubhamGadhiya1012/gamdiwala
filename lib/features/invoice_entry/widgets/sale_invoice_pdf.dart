import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gamdiwala/features/invoice_entry/models/sale_invoice_pdf_dm.dart';
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

late pw.Font _regular;
late pw.Font _bold;

Future<void> _loadFonts() async {
  _regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Montserrat-Regular.ttf'),
  );
  _bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Montserrat-Bold.ttf'),
  );
}

Future<void> generateSaleInvoicePdf({
  required SaleInvoicePdfDm pdfData,
  required String pageSize,
  required String invNo,
}) async {
  await _loadFonts();

  final isHalf = pageSize == 'HALF';
  final pdf = pw.Document();

  if (isHalf) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(12),
        build: (context) => [
          _buildHeader(pdfData.data1.first),
          pw.SizedBox(height: 4),
          _buildInvoiceInfoRow(pdfData.data1.first, pdfData.data2.first),
          pw.SizedBox(height: 4),
          _buildPartyAndInvoiceDetails(pdfData.data2.first, pdfData.data3),
          pw.SizedBox(height: 4),
          _buildItemsTable(pdfData.data3, isHalf: true),
          pw.SizedBox(height: 4),
          _buildHsnAndSummary(pdfData.data3, pdfData.data4, pdfData.data2.first),
          pw.SizedBox(height: 4),
          _buildFooter(pdfData.data1.first, pdfData.data5),
        ],
      ),
    );
  } else {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(12),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(pdfData.data1.first),
            pw.SizedBox(height: 4),
            _buildInvoiceInfoRow(pdfData.data1.first, pdfData.data2.first),
            pw.SizedBox(height: 4),
            _buildPartyAndInvoiceDetails(pdfData.data2.first, pdfData.data3),
            pw.SizedBox(height: 4),
            pw.Expanded(
              child: _buildItemsTable(pdfData.data3, isHalf: false),
            ),
            pw.SizedBox(height: 4),
            _buildHsnAndSummary(pdfData.data3, pdfData.data4, pdfData.data2.first),
          pw.SizedBox(height: 4),
          _buildFooter(pdfData.data1.first, pdfData.data5),
        ],
      ),
    ),
  );
  }

  final bytes = await pdf.save();
  await _savePdfAndOpen(bytes, invNo, pageSize);
}

pw.Widget _buildHeader(PdfData1Dm c) {
  return pw.Column(
    children: [
      pw.Center(
        child: pw.Text(c.name, style: pw.TextStyle(font: _bold, fontSize: 14)),
      ),
      pw.Center(
        child: pw.Text(
          '${c.address1} ${c.address2}',
          style: pw.TextStyle(font: _regular, fontSize: 8),
        ),
      ),
      pw.Center(
        child: pw.Text(
          'Phone : ${c.phone}   Email : ${c.email}',
          style: pw.TextStyle(font: _regular, fontSize: 8),
        ),
      ),
      pw.Center(
        child: pw.Text(
          'FSSAI Licence No : ${c.fssaiNo}',
          style: pw.TextStyle(font: _regular, fontSize: 8),
        ),
      ),
    ],
  );
}

pw.Widget _buildInvoiceInfoRow(PdfData1Dm c, PdfData2Dm inv) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        'MSME No : ${c.msmeNo}',
        style: pw.TextStyle(font: _bold, fontSize: 8),
      ),
      pw.Text('TAX INVOICE', style: pw.TextStyle(font: _bold, fontSize: 12)),
      pw.Text(
        'Duplicate for Transporter',
        style: pw.TextStyle(font: _bold, fontSize: 8),
      ),
    ],
  );
}

pw.Widget _buildPartyAndInvoiceDetails(PdfData2Dm inv, List<PdfData3Dm> items) {
  final challanNo = items.isNotEmpty ? items.first.challanNo : '';

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
    columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(1)},
    children: [
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'To,',
                  style: pw.TextStyle(font: _regular, fontSize: 8),
                ),
                pw.Text(
                  inv.pName,
                  style: pw.TextStyle(font: _bold, fontSize: 10),
                ),
                if (inv.add1.isNotEmpty)
                  pw.Text(
                    inv.add1,
                    style: pw.TextStyle(font: _regular, fontSize: 8),
                  ),
                if (inv.add2.isNotEmpty)
                  pw.Text(
                    inv.add2,
                    style: pw.TextStyle(font: _regular, fontSize: 8),
                  ),
                if (inv.add3.isNotEmpty)
                  pw.Text(
                    inv.add3,
                    style: pw.TextStyle(font: _regular, fontSize: 8),
                  ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '${inv.city}',
                  style: pw.TextStyle(font: _regular, fontSize: 8),
                ),
                pw.Text(
                  'Phone : ${inv.phone}  Mobile : ${inv.mobile}',
                  style: pw.TextStyle(font: _regular, fontSize: 8),
                ),
                pw.Text(
                  'GST No: ${inv.gstNumber}',
                  style: pw.TextStyle(font: _regular, fontSize: 8),
                ),
                pw.Text(
                  'Place of supply: 24-${inv.state}',
                  style: pw.TextStyle(font: _regular, fontSize: 8),
                ),
              ],
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Invoice No. : ${inv.invNo}',
                  style: pw.TextStyle(font: _bold, fontSize: 9),
                ),
                pw.Text(
                  'Invoice Dt. : ${inv.date}',
                  style: pw.TextStyle(font: _bold, fontSize: 9),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Challan No.   : $challanNo',
                  style: pw.TextStyle(font: _regular, fontSize: 8),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Driver Name  : ${inv.driverName}',
                  style: pw.TextStyle(font: _bold, fontSize: 8),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Vehicle No. : ${inv.vehicleNo}',
                  style: pw.TextStyle(font: _bold, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

Map<String, List<PdfData3Dm>> _groupByIgName(List<PdfData3Dm> items) {
  final map = <String, List<PdfData3Dm>>{};
  for (final item in items) {
    map.putIfAbsent(item.igName, () => []).add(item);
  }
  return map;
}

final _itemsTableBorder = pw.TableBorder(
  top: const pw.BorderSide(color: PdfColors.grey700, width: 0.5),
  bottom: const pw.BorderSide(color: PdfColors.grey700, width: 0.5),
  left: const pw.BorderSide(color: PdfColors.grey700, width: 0.5),
  right: const pw.BorderSide(color: PdfColors.grey700, width: 0.5),
  verticalInside: const pw.BorderSide(color: PdfColors.grey700, width: 0.5),
);

pw.Widget _buildItemsTable(List<PdfData3Dm> items, {
  required bool isHalf,
}) {
  final grouped = _groupByIgName(items);
  int srNo = 1;

  final rows = <pw.TableRow>[];

  rows.add(
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        _thCell('Sr\nNo'),
        _thCell('Item Description (HSN No)'),
        _thCell('Qty.'),
        _thCell('Unit'),
        _thCell('Rate'),
        _thCell('GST\n%'),
        _thCell('Amount'),
      ],
    ),
  );

  grouped.forEach((groupName, groupItems) {
    rows.add(
      pw.TableRow(
        children: [
          pw.Container(),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            child: pw.Text(
              groupName,
              style: pw.TextStyle(font: _bold, fontSize: 8),
            ),
          ),
          pw.Container(),
          pw.Container(),
          pw.Container(),
          pw.Container(),
          pw.Container(),
        ],
      ),
    );

    for (final item in groupItems) {
      final gst = item.sgstPerc > 0
          ? '${item.sgstPerc}+${item.cgstPerc}%'
          : '0+0%';
      final effectiveRate = item.qty > 0
          ? item.valueOfGoods / item.qty
          : item.rate;
      final amount =
          item.valueOfGoods + item.sgstAmt + item.cgstAmt + item.igstAmt;

      rows.add(
        pw.TableRow(
          children: [
            _tdCell(srNo.toString()),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 2,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${item.iName}(${item.hsnNo})',
                    style: pw.TextStyle(font: _bold, fontSize: 8),
                  ),
                  pw.Text(
                    '${_formatPack(item.pack)} X ${item.nos}',
                    style: pw.TextStyle(font: _regular, fontSize: 7),
                  ),
                ],
              ),
            ),
            _tdCell(item.qty.toStringAsFixed(2)),
            _tdCell('LTR'),
            _tdCell(effectiveRate.toStringAsFixed(2)),
            _tdCell(gst),
            _tdCell(amount.toStringAsFixed(2)),
          ],
        ),
      );
      srNo++;
    }
  });

  if (!isHalf) {
    const int minFillerRows = 12;
    final int filler = (minFillerRows - items.length).clamp(0, minFillerRows);
    for (int i = 0; i < filler; i++) {
      rows.add(
        pw.TableRow(
          children: List.generate(7, (_) => pw.Container(height: 26)),
        ),
      );
    }
  }

  return pw.Table(
    border: _itemsTableBorder,
    columnWidths: const {
      0: pw.FlexColumnWidth(0.4),
      1: pw.FlexColumnWidth(4),
      2: pw.FlexColumnWidth(1),
      3: pw.FlexColumnWidth(0.8),
      4: pw.FlexColumnWidth(1),
      5: pw.FlexColumnWidth(1),
      6: pw.FlexColumnWidth(1.2),
    },
    children: rows,
  );
}

String _formatPack(double pack) {
  if (pack == pack.truncateToDouble()) {
    return pack.toInt().toString();
  }
  return pack.toString();
}

pw.Widget _buildHsnAndSummary(
  List<PdfData3Dm> items,
  List<PdfData4Dm> data4,
  PdfData2Dm inv,
) {
  double grossTotal = 0, totalSgst = 0, totalCgst = 0;
  for (final item in items) {
    grossTotal += item.valueOfGoods;
    totalSgst += item.sgstAmt;
    totalCgst += item.cgstAmt;
  }
  final netAmount = inv.amount;
  final roundOff = netAmount - (grossTotal + totalSgst + totalCgst);

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
    columnWidths: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(2)},
    children: [
      pw.TableRow(
        children: [
          pw.Table(
            border: pw.TableBorder(
              verticalInside: const pw.BorderSide(
                color: PdfColors.grey700,
                width: 0.5,
              ),
              horizontalInside: const pw.BorderSide(
                color: PdfColors.grey700,
                width: 0.5,
              ),
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.5),
              1: pw.FlexColumnWidth(1.5),
              2: pw.FlexColumnWidth(0.8),
              3: pw.FlexColumnWidth(1),
              4: pw.FlexColumnWidth(0.8),
              5: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _thCell('HSN/SAC No'),
                  _thCell('Taxable Value'),
                  _thCell('SGST%'),
                  _thCell('SGST Amt'),
                  _thCell('CGST%'),
                  _thCell('CGST Amt'),
                ],
              ),
              ...data4.map(
                (h) => pw.TableRow(
                  children: [
                    _tdCell(h.hsnNo),
                    _tdCell(h.taxableValue.toStringAsFixed(2)),
                    _tdCell(h.sgstPerc.toStringAsFixed(2)),
                    _tdCell(h.sgstAmt.toStringAsFixed(2)),
                    _tdCell(h.cgstPerc.toStringAsFixed(2)),
                    _tdCell(h.cgstAmt.toStringAsFixed(2)),
                  ],
                ),
              ),
              pw.TableRow(
                children: [
                  _tdCell('Total(Rs.)', bold: true),
                  _tdCell(
                    data4
                        .fold(0.0, (s, h) => s + h.taxableValue)
                        .toStringAsFixed(2),
                    bold: true,
                  ),
                  _tdCell(''),
                  _tdCell(
                    data4.fold(0.0, (s, h) => s + h.sgstAmt).toStringAsFixed(2),
                    bold: true,
                  ),
                  _tdCell(''),
                  _tdCell(
                    data4.fold(0.0, (s, h) => s + h.cgstAmt).toStringAsFixed(2),
                    bold: true,
                  ),
                ],
              ),
            ],
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _summaryRow(
                  'Gross Total',
                  grossTotal.toStringAsFixed(2),
                  bold: true,
                ),
                _summaryRow('SGST', totalSgst.toStringAsFixed(2)),
                _summaryRow('CGST', totalCgst.toStringAsFixed(2)),
                _summaryRow(
                  'ROUND OFF (+/-)',
                  roundOff.abs().toStringAsFixed(2),
                ),
                pw.Divider(thickness: 0.5),
                _summaryRow(
                  'NET AMOUNT',
                  netAmount.toStringAsFixed(2),
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _summaryRow(String label, String value, {bool bold = false}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          font: bold ? _bold : _regular,
          fontSize: bold ? 9 : 8,
        ),
      ),
      pw.Text(
        value,
        style: pw.TextStyle(
          font: bold ? _bold : _regular,
          fontSize: bold ? 9 : 8,
        ),
      ),
    ],
  );
}

pw.Widget _buildFooter(PdfData1Dm c, List<PdfData5Dm> terms) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
    children: [
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              'Amount of Tax subject to Reverse Charges: 0.00',
              style: pw.TextStyle(font: _bold, fontSize: 8),
            ),
          ),
        ],
      ),
      pw.TableRow(
        children: [
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Terms & Conditions :',
                          style: pw.TextStyle(font: _regular, fontSize: 8),
                        ),
                        ...terms.map(
                          (t) => pw.Text(
                            '${t.srNo}. ${t.termsCondition}',
                            style: pw.TextStyle(font: _regular, fontSize: 7),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'GST No.: ${c.gstNumber}',
                          style: pw.TextStyle(font: _bold, fontSize: 8),
                        ),
                        pw.Text(
                          'PAN No. : ${c.pan}',
                          style: pw.TextStyle(font: _bold, fontSize: 8),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "Company's Bank Details",
                          style: pw.TextStyle(font: _bold, fontSize: 8),
                        ),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Bank Name   : ${c.coBankName1}',
                              style: pw.TextStyle(font: _regular, fontSize: 7),
                            ),
                            pw.SizedBox(width: 12),
                            pw.Text(
                              'Bank Branch : ${c.coBankBranch1}',
                              style: pw.TextStyle(font: _regular, fontSize: 7),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Text(
                              'A/c No.         : ${c.coBankAcNo1}',
                              style: pw.TextStyle(font: _regular, fontSize: 7),
                            ),
                            pw.SizedBox(width: 12),
                            pw.Text(
                              'IFSC Code   : ${c.coBankIfsc1}',
                              style: pw.TextStyle(font: _regular, fontSize: 7),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'For,${c.name}',
                          style: pw.TextStyle(font: _bold, fontSize: 9),
                        ),
                        pw.SizedBox(height: 28),
                        pw.Text(
                          'Authorised Sign.',
                          style: pw.TextStyle(font: _regular, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

pw.Widget _thCell(String text) => pw.Container(
  height: 22,
  padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 1),
  alignment: pw.Alignment.center,
  child: pw.Text(
    text,
    textAlign: pw.TextAlign.center,
    style: pw.TextStyle(font: _bold, fontSize: 7),
  ),
);

pw.Widget _tdCell(String text, {bool bold = false}) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
  child: pw.Text(
    text,
    textAlign: pw.TextAlign.center,
    style: pw.TextStyle(font: bold ? _bold : _regular, fontSize: 8),
  ),
);

Future<void> _savePdfAndOpen(
  List<int> pdfBytes,
  String invNo,
  String pageSize,
) async {
  try {
    final sanitized = invNo.replaceAll(RegExp(r'[^\w\s-]'), '_');
    final fileName = 'Invoice_${sanitized}_$pageSize.pdf';

    final Directory directory;
    if (Platform.isAndroid) {
      directory =
          await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final file = File('${directory.path}/$fileName')
      ..writeAsBytesSync(pdfBytes);

    await Future.delayed(const Duration(milliseconds: 100));

    if (!await file.exists()) {
      showErrorSnackbar('Error', 'PDF file was not created successfully.');
      return;
    }

    await OpenFilex.open(file.path);
  } catch (e) {
    showErrorSnackbar('Error', 'Failed to save PDF: ${e.toString()}');
  }
}
