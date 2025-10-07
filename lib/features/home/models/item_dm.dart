class ItemDm {
  final String iCode;
  final String iName;
  final String description;
  final String unit;
  final double rate;
  final String hsnNo;
  final double packQty;
  final double caratNos;
  final double caratQty;
  final double itemPack;
  final double fat;
  final double lr;
  final double qty;
  final double caratCount;
  final int nosCount;

  ItemDm({
    required this.iCode,
    required this.iName,
    required this.description,
    required this.unit,
    required this.rate,
    required this.hsnNo,
    required this.packQty,
    required this.caratNos,
    required this.caratQty,
    required this.itemPack,
    required this.fat,
    required this.lr,
    required this.qty,
    required this.caratCount,
    required this.nosCount,
  });

  factory ItemDm.fromJson(Map<String, dynamic> json) {
    return ItemDm(
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      description: json['Description'] ?? '',
      unit: json['Unit'] ?? '',
      rate: (json['Rate'] ?? 0).toDouble(),
      hsnNo: json['HsnNo'] ?? '',
      packQty: (json['PackQty'] ?? 0).toDouble(),
      caratNos: (json['CaratNos'] ?? 0).toDouble(),
      caratQty: (json['CaratQty'] ?? 0).toDouble(),
      itemPack: (json['ItemPack'] ?? 0).toDouble(),
      fat: (json['FAT'] ?? 0).toDouble(),
      lr: (json['LR'] ?? 0).toDouble(),
      qty: (json['Qty'] ?? 0).toDouble(),
      caratCount: (json['CaratCount'] ?? 0).toDouble(),
      nosCount: (json['NosCount'] ?? 0).toInt(),
    );
  }
}
