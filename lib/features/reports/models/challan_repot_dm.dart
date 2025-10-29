class ChallanReportDm {
  final String challanNo;
  final String date;
  final String customer;
  final String item;
  final double nos;
  final double pack;
  final double qty;
  final double rate;
  final double amount;

  ChallanReportDm({
    required this.challanNo,
    required this.date,
    required this.customer,
    required this.item,
    required this.nos,
    required this.pack,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory ChallanReportDm.fromJson(Map<String, dynamic> json) {
    return ChallanReportDm(
      challanNo: json['ChallanNo'] ?? '',
      date: json['Date'] ?? '',
      customer: json['Customer'] ?? '',
      item: json['Item'] ?? '',
      nos: (json['Nos'] ?? 0).toDouble(),
      pack: (json['Pack'] ?? 0).toDouble(),
      qty: (json['Qty'] ?? 0).toDouble(),
      rate: (json['Rate'] ?? 0).toDouble(),
      amount: (json['Amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ChallanNo': challanNo,
      'Date': date,
      'Customer': customer,
      'Item': item,
      'Nos': nos,
      'Pack': pack,
      'Qty': qty,
      'Rate': rate,
      'Amount': amount,
    };
  }
}
