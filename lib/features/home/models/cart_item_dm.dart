class CartItemDm {
  final String date;
  final String pCode;
  final String partyName;
  final String iCode;
  final String itemName;
  final double qty;
  final double rate;
  final double amount;
  final double caratNos;
  final double caratQty;
  final double itemPack;
  final double packQty;
  final double fat;
  final double lr;

  CartItemDm({
    required this.date,
    required this.pCode,
    required this.partyName,
    required this.iCode,
    required this.itemName,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.caratNos,
    required this.caratQty,
    required this.itemPack,
    required this.packQty,
    required this.fat,
    required this.lr,
  });

  factory CartItemDm.fromJson(Map<String, dynamic> json) {
    return CartItemDm(
      date: json['Date'] ?? '',
      pCode: json['PCode'] ?? '',
      partyName: json['PartyName'] ?? '',
      iCode: json['ICode'] ?? '',
      itemName: json['ItemName'] ?? '',
      qty: (json['Qty'] ?? 0).toDouble(),
      rate: (json['Rate'] ?? 0).toDouble(),
      amount: (json['Amount'] ?? 0).toDouble(),
      caratNos: (json['CaratNos'] ?? 0).toDouble(),
      caratQty: (json['CaratQty'] ?? 0).toDouble(),
      itemPack: (json['ItemPack'] ?? 0).toDouble(),
      packQty: (json['PackQty'] ?? 0).toDouble(),
      fat: (json['Fat'] ?? 0).toDouble(),
      lr: (json['LR'] ?? 0).toDouble(),
    );
  }
}
