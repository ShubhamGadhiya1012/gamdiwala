class TaxDm {
  final String tCode;
  final String tName;
  final bool igstYn;
  final bool cgstYn;
  final bool sgstYn;

  TaxDm({
    required this.tCode,
    required this.tName,
    required this.igstYn,
    required this.cgstYn,
    required this.sgstYn,
  });

  factory TaxDm.fromJson(Map<String, dynamic> json) {
    return TaxDm(
      tCode: json['TCODE'] ?? '',
      tName: json['TNAME'] ?? '',
      igstYn: json['IGSTYN'] ?? false,
      sgstYn: json['SGSTYN'] ?? false,
      cgstYn: json['CGSTYN'] ?? false,
    );
  }
}
