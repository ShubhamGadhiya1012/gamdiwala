class ItemDm {
  final String iCode;
  final String iName;

  ItemDm({required this.iCode, required this.iName});

  factory ItemDm.fromJson(Map<String, dynamic> json) {
    return ItemDm(iCode: json['ICode'] ?? '', iName: json['IName'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'ICode': iCode, 'IName': iName};
  }
}
