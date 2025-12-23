class ItemTaxDm {
  final String iCode;
  final String iName;
  final String hsnNo;
  final double igst;
  final double cgst;
  final double sgst;

  ItemTaxDm({
    required this.iCode,
    required this.iName,
    required this.hsnNo,
    required this.igst,
    required this.cgst,
    required this.sgst,
  });

  factory ItemTaxDm.fromJson(Map<String, dynamic> json) {
    return ItemTaxDm(
      iCode: json['ICODE'] ?? '',
      iName: json['INAME'] ?? '',
      hsnNo: json['HSNNO'] ?? '',
      igst: (json['IGST'] ?? 0).toDouble(),
      cgst: (json['CGST'] ?? 0).toDouble(),
      sgst: (json['SGST'] ?? 0).toDouble(),
    );
  }
}
