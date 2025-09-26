class CompanyDm {
  final int cid;
  final String coName;

  CompanyDm({
    required this.cid,
    required this.coName,
  });

  factory CompanyDm.fromJson(Map<String, dynamic> json) {
    return CompanyDm(
      cid: json['CID'],
      coName: json['CONAME'],
    );
  }
}
