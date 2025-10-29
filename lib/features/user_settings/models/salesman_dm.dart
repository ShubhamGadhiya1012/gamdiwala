class SalesmanDm {
  final String seCode;
  final String seName;

  SalesmanDm({required this.seCode, required this.seName});

  factory SalesmanDm.fromJson(Map<String, dynamic> json) {
    return SalesmanDm(seCode: json['SECODE'], seName: json['SENAME']);
  }
}
