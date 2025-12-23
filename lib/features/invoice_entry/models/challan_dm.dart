class ChallanDm {
  final String invNo;
  final String date;
  final String iCode;
  final String iName;
  final String vehicleCode;
  final double qty;
  final double itemPack;
  final int caratNos;
  final double amount;
  final double rate;
  final int challanItemSrno;
  final String orderNo;
  final int orderSrNo;
  final int caratQty;
  final double fat;
  final double lrValue;

  ChallanDm({
    required this.invNo,
    required this.date,
    required this.iCode,
    required this.iName,
    required this.vehicleCode,
    required this.qty,
    required this.itemPack,
    required this.caratNos,
    required this.amount,
    required this.rate,
    required this.challanItemSrno,
    required this.orderNo,
    required this.orderSrNo,
    required this.caratQty,
    required this.fat,
    required this.lrValue,
  });

  factory ChallanDm.fromJson(Map<String, dynamic> json) {
    return ChallanDm(
      invNo: json['Invno'] ?? '',
      date: json['Date'] ?? '',
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      vehicleCode: json['VehicleCode'] ?? '',
      qty: (json['Qty'] ?? 0).toDouble(),
      itemPack: (json['ItemPack'] ?? 0).toDouble(),
      caratNos: json['CaratNos'] ?? 0,
      amount: (json['Amount'] ?? 0).toDouble(),
      rate: (json['Rate'] ?? 0).toDouble(),
      challanItemSrno: json['ChallanItemSrno'] ?? 0,
      orderNo: json['OrderNo'] ?? '',
      orderSrNo: json['OrderSrNo'] ?? 0,
      caratQty: json['CaratQty'] ?? 0,
      fat: (json['Fat'] ?? 0).toDouble(),
      lrValue: (json['LRValue'] ?? 0).toDouble(),
    );
  }
}
