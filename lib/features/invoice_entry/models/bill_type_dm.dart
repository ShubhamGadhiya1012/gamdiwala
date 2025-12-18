class BillTypeDm {
  final String billCode;
  final String billName;

  BillTypeDm({required this.billCode, required this.billName});

  factory BillTypeDm.fromJson(Map<String, dynamic> json) {
    return BillTypeDm(
      billCode: json['BILLCODE'] ?? '',
      billName: json['BILLNAME'] ?? '',
    );
  }
}
