class InvoicePartyDm {
  final String pCode;
  final String pName;

  InvoicePartyDm({required this.pCode, required this.pName});

  factory InvoicePartyDm.fromJson(Map<String, dynamic> json) {
    return InvoicePartyDm(
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'PCode': pCode, 'PName': pName};
  }
}
