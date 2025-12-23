class SaleInvoiceDm {
  final String invNo;
  final String date;
  final double amount;
  final String pName;
  final String pCode;
  final int yearId;

  SaleInvoiceDm({
    required this.invNo,
    required this.date,
    required this.amount,
    required this.pName,
    required this.pCode,
    required this.yearId,
  });

  factory SaleInvoiceDm.fromJson(Map<String, dynamic> json) {
    return SaleInvoiceDm(
      invNo: json['InvNo'] ?? '',
      date: json['Date'] ?? '',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      pName: json['PNAME'] ?? '',
      pCode: json['PCODE'] ?? '',
      yearId: json['YearId'] ?? 0,
    );
  }
}
