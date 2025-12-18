class CustomerDm {
  final String pCode;
  final String pName;
  final String? terms;
  final int? crDays;

  CustomerDm({
    required this.pCode,
    required this.pName,
    this.terms,
    this.crDays,
  });

  factory CustomerDm.fromJson(Map<String, dynamic> json) {
    return CustomerDm(
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      terms: json['Terms'],
      crDays: json['CrDays'],
    );
  }
}
