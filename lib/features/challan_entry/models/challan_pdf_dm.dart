class ChallanPdfDm {
  final String name;
  final String address;
  final String msme;
  final String fssai;
  final String gst;
  final String challanNo;
  final String challanDate;
  final String pCode;
  final String pName;
  final String vCode;
  final double amount;
  final double sendCr;
  final double sendCan;
  final double sendBag;
  final double recCr;
  final double recCan;
  final double remCr;
  final double remCan;
  final double remainingAmount;
  final List<ChallanItemDm> challanItems;

  ChallanPdfDm({
    required this.name,
    required this.address,
    required this.msme,
    required this.fssai,
    required this.gst,
    required this.challanNo,
    required this.challanDate,
    required this.pCode,
    required this.pName,
    required this.vCode,
    required this.amount,
    required this.sendCr,
    required this.sendCan,
    required this.sendBag,
    required this.recCr,
    required this.recCan,
    required this.remCr,
    required this.remCan,
    required this.remainingAmount,
    required this.challanItems,
  });

  factory ChallanPdfDm.fromJson(Map<String, dynamic> json) {
    return ChallanPdfDm(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      msme: json['msme'] ?? '',
      fssai: json['fssai'] ?? '',
      gst: json['gst'] ?? '',
      challanNo: json['challanNo'] ?? '',
      challanDate: json['challanDate'] ?? '',
      pCode: json['pCode'] ?? '',
      pName: json['pName'] ?? '',
      vCode: json['vCode'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      sendCr: (json['sendCr'] ?? 0).toDouble(),
      sendCan: (json['sendCan'] ?? 0).toDouble(),
      sendBag: (json['sendBag'] ?? 0).toDouble(),
      recCr: (json['recCr'] ?? 0).toDouble(),
      recCan: (json['recCan'] ?? 0).toDouble(),
      remCr: (json['remCr'] ?? 0).toDouble(),
      remCan: (json['remCan'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      challanItems:
          (json['challanItems'] as List?)
              ?.map((item) => ChallanItemDm.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ChallanItemDm {
  final String iCode;
  final String iName;
  final int carat;
  final int nos;
  final double qty;
  final String unit;
  final String container;

  ChallanItemDm({
    required this.iCode,
    required this.iName,
    required this.carat,
    required this.nos,
    required this.qty,
    required this.unit,
    required this.container,
  });

  factory ChallanItemDm.fromJson(Map<String, dynamic> json) {
    return ChallanItemDm(
      iCode: json['iCode'] ?? '',
      iName: json['iName'] ?? '',
      carat: json['carat'] ?? 0,
      nos: json['nos'] ?? 0,
      qty: (json['qty'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      container: json['container'] ?? '',
    );
  }
}
