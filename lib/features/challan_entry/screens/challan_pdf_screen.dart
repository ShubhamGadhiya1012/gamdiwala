import 'dart:io';
import 'package:gamdiwala/features/challan_entry/models/challan_pdf_dm.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:gamdiwala/utils/dialogs/app_dialogs.dart';

class ChallanPdfScreen {
  static Future<void> generateChallanPdf({
    required Map<String, dynamic> challanData,
  }) async {
    try {
      final data = ChallanPdfDm.fromJson(challanData);

      final pdf = pw.Document();

      final blackColor = PdfColors.black;
      final greyColor = PdfColor.fromHex('#666666');

      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(20),
          header: (context) => _buildHeader(data, blackColor, greyColor),
          footer: (context) => _buildFooter(data, blackColor, greyColor),
          build: (context) => [
            pw.SizedBox(height: 20),
            _buildItemsTable(data, blackColor, greyColor),
          ],
        ),
      );

      await _savePdf(pdf, data.challanNo);
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to generate Challan PDF: $e');
      print(e);
    }
  }

  static pw.Widget _buildHeader(
    ChallanPdfDm data,
    PdfColor blackColor,
    PdfColor greyColor,
  ) {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            data.name,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: blackColor,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            data.address,
            style: pw.TextStyle(fontSize: 9, color: greyColor),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 8),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'MSME No.: ${data.msme}',
              style: pw.TextStyle(fontSize: 9, color: blackColor),
            ),
            pw.Text(
              'FSSAI Licence No : ${data.fssai}',
              style: pw.TextStyle(fontSize: 9, color: blackColor),
            ),
          ],
        ),
        pw.SizedBox(height: 8),

        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: blackColor, width: 1),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide(color: blackColor)),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'DELIVERY CHALLAN/RETAIL INVOICE',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Center(
                    child: pw.Text(
                      'GST No. : ${data.gst}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 0),

        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: blackColor, width: 1),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(right: pw.BorderSide(color: blackColor)),
                  ),
                  child: pw.Center(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'To,${data.pName}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Center(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'Challan No : ${data.challanNo}',
                          style: pw.TextStyle(fontSize: 9),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Challan Date : ${data.challanDate}',
                          style: pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildItemsTable(
    ChallanPdfDm data,
    PdfColor blackColor,
    PdfColor greyColor,
  ) {
    int totalNos = 0;
    double totalQty = 0;

    for (var item in data.challanItems) {
      totalNos += item.nos;
      totalQty += item.qty;
    }

    String unit = data.challanItems.isNotEmpty ? data.challanItems[0].unit : '';

    return pw.Table(
      border: pw.TableBorder.all(color: blackColor, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Product', blackColor, isHeader: true),
            _buildTableCell('Container', blackColor, isHeader: true),
            _buildTableCell('Qty', blackColor, isHeader: true, center: true),
            _buildTableCell(unit, blackColor, isHeader: true, center: true),
          ],
        ),

        ...data.challanItems.map(
          (item) => pw.TableRow(
            children: [
              _buildTableCell(item.iName, blackColor),
              _buildTableCell(
                item.carat > 0 ? item.carat.toString() : '',
                blackColor,
              ),
              _buildTableCell(
                item.nos > 0 ? item.nos.toString() : '',
                blackColor,
                center: true,
              ),
              _buildTableCell(
                item.qty.toStringAsFixed(3),
                blackColor,
                center: true,
              ),
            ],
          ),
        ),

        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('', blackColor),
            _buildTableCell('Total', blackColor, isHeader: true),
            _buildTableCell(
              totalNos > 0 ? totalNos.toString() : '0',
              blackColor,
              center: true,
              isHeader: true,
            ),
            _buildTableCell(
              totalQty.toStringAsFixed(3),
              blackColor,
              center: true,
              isHeader: true,
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(
    ChallanPdfDm data,
    PdfColor blackColor,
    PdfColor greyColor,
  ) {
    int totalNos = 0;
    double totalQty = 0;

    for (var item in data.challanItems) {
      totalNos += item.nos;
      totalQty += item.qty;
    }

    String amountInWords = _convertAmountToWords(data.amount);

    double srAmt = data.remainingAmount;

    return pw.Column(
      children: [
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: blackColor, width: 1)),
          ),
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 100,
                          child: pw.Text(
                            'Truck No. : ${data.vCode}',
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Text(
                          'User: Admin',
                          style: pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Amount In Word : $amountInWords',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        _buildAmountField('Bill Amt', data.amount, blackColor),
                        pw.SizedBox(width: 20),
                        _buildAmountField('Revd. Amt', 0.00, blackColor),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        _buildField('Send Cr', data.sendCr, blackColor),
                        pw.SizedBox(width: 20),
                        _buildField('Send Can', data.sendCan, blackColor),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        _buildField('Send Bag', data.sendBag, blackColor),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        _buildField('Rec Cr', data.recCr, blackColor),
                        pw.SizedBox(width: 20),
                        _buildField('Rec Can', data.recCan, blackColor),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        _buildField('Rem Cr', data.remCr, blackColor),
                        pw.SizedBox(width: 20),
                        _buildField('Rem Can', data.remCan, blackColor),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Remaining Amount: ${data.remainingAmount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          totalNos > 0 ? totalNos.toString() : '0',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          totalQty.toStringAsFixed(3),
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('S.R.Amt:', style: pw.TextStyle(fontSize: 9)),
                        pw.Text(
                          srAmt.toStringAsFixed(2),
                          style: pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      height: 40,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: blackColor),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'Customer\'s Sign',
                          style: pw.TextStyle(fontSize: 9),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'For, G.M.P.',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text,
    PdfColor color, {
    bool isHeader = false,
    bool center = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _buildAmountField(
    String label,
    double value,
    PdfColor color,
  ) {
    return pw.Row(
      children: [
        pw.Text(
          '$label  : ',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          value.toStringAsFixed(2),
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildField(String label, double value, PdfColor color) {
    return pw.Row(
      children: [
        pw.Text('$label  : ', style: pw.TextStyle(fontSize: 9)),
        pw.Text(value.toStringAsFixed(2), style: pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  static String _convertAmountToWords(double amount) {
    if (amount == 0) return 'Zero Only';

    final ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
    ];
    final teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    String convertTwoDigit(int num) {
      if (num < 10) return ones[num];
      if (num < 20) return teens[num - 10];
      return tens[num ~/ 10] + (num % 10 > 0 ? ' ${ones[num % 10]}' : '');
    }

    String convertThreeDigit(int num) {
      if (num == 0) return '';
      if (num < 100) return convertTwoDigit(num);
      return '${ones[num ~/ 100]} Hundred${num % 100 > 0 ? ' ${convertTwoDigit(num % 100)}' : ''}';
    }

    int intAmount = amount.toInt();
    String result = '';

    if (intAmount >= 10000000) {
      int crores = intAmount ~/ 10000000;
      result += '${convertThreeDigit(crores)} Crore ';
      intAmount %= 10000000;
    }

    if (intAmount >= 100000) {
      int lakhs = intAmount ~/ 100000;
      result += '${convertThreeDigit(lakhs)} Lakh ';
      intAmount %= 100000;
    }

    if (intAmount >= 1000) {
      int thousands = intAmount ~/ 1000;
      result += '${convertThreeDigit(thousands)} Thousand ';
      intAmount %= 1000;
    }

    if (intAmount >= 100) {
      int hundreds = intAmount ~/ 100;
      result += '${ones[hundreds]} Hundred ';
      intAmount %= 100;
    }

    if (intAmount > 0) {
      result += convertTwoDigit(intAmount);
    }

    return result.trim() + ' Only';
  }

  static Future<void> _savePdf(pw.Document pdf, String challanNo) async {
    try {
      final bytes = await pdf.save();
      final dir = await getTemporaryDirectory();

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final cleanChallanNo = challanNo
          .replaceAll('/', '_')
          .replaceAll('\\', '_');

      final file = File('${dir.path}/Challan_${cleanChallanNo}_$timestamp.pdf');

      await file.writeAsBytes(bytes);

      if (await file.exists()) {
        await OpenFilex.open(file.path);
      } else {
        throw Exception('PDF file was not created successfully');
      }
    } catch (e) {
      showErrorSnackbar('Error', 'Failed to save PDF: $e');
      rethrow;
    }
  }
}
