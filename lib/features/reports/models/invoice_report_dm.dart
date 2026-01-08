class InvoiceReportDm {
  final String challanNo;
  final String date;
  final String vehicle;
  final String? customerName;
  final String? billPeriod;
  final String itemName;
  final int carat;
  final double extra;
  final double pack;
  final int totalNos;
  final double qty;
  final String? invoiceNo;
  final String? invoiceDate;
  final double invoiceQty;
  final double pendingQty;

  InvoiceReportDm({
    required this.challanNo,
    required this.date,
    required this.vehicle,
    this.customerName,
    this.billPeriod,
    required this.itemName,
    required this.carat,
    required this.extra,
    required this.pack,
    required this.totalNos,
    required this.qty,
    this.invoiceNo,
    this.invoiceDate,
    required this.invoiceQty,
    required this.pendingQty,
  });

  factory InvoiceReportDm.fromJson(Map<String, dynamic> json) {
    return InvoiceReportDm(
      challanNo: json['Challan No'] ?? '',
      date: json['Date'] ?? '',
      vehicle: json['Vehicle'] ?? '',
      customerName: json['Customer Name'],
      billPeriod: json['Bill Period'],
      itemName: json['Item Name'] ?? '',
      carat: json['Carat'] ?? 0,
      extra: (json['Extra'] ?? 0).toDouble(),
      pack: (json['Pack'] ?? 0).toDouble(),
      totalNos: json['Total Nos'] ?? 0,
      qty: (json['Qty'] ?? 0).toDouble(),
      invoiceNo: json['Invoice No'],
      invoiceDate: json['Invoice Date'],
      invoiceQty: (json['Invoice Qty'] ?? 0).toDouble(),
      pendingQty: (json['Pending Qty'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Challan No': challanNo,
      'Date': date,
      'Vehicle': vehicle,
      'Customer Name': customerName,
      'Bill Period': billPeriod,
      'Item Name': itemName,
      'Carat': carat,
      'Extra': extra,
      'Pack': pack,
      'Total Nos': totalNos,
      'Qty': qty,
      'Invoice No': invoiceNo,
      'Invoice Date': invoiceDate,
      'Invoice Qty': invoiceQty,
      'Pending Qty': pendingQty,
    };
  }
}
