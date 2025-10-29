class CompanyDm {
  final int cid;
  final String coName;
  final int coCode;

  CompanyDm({required this.cid, required this.coName, required this.coCode});

  factory CompanyDm.fromJson(Map<String, dynamic> json) {
    return CompanyDm(
      cid: json['CID'] ?? 0,
      coName: json['CONAME'] ?? '',
      coCode: json['COCODE'] ?? 0,
    );
  }
}
