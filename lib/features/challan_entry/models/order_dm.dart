class ChallanOrderDm {
  final String invNo;
  final String pCode;
  final String pName;
  final String vCode;
  final String challanNo;
  final List<ChallanOrderItemDm> orderItems;

  ChallanOrderDm({
    required this.invNo,
    required this.pCode,
    required this.pName,
    required this.vCode,
    required this.challanNo,
    required this.orderItems,
  });

  factory ChallanOrderDm.fromJson(Map<String, dynamic> json) {
    return ChallanOrderDm(
      invNo: json['invNo'] ?? '',
      pCode: json['pCode'] ?? '',
      pName: json['pName'] ?? '',
      vCode: json['vCode'] ?? '',
      challanNo: json['challanNo'] ?? '',
      orderItems:
          (json['orderItems'] as List?)
              ?.map((item) => ChallanOrderItemDm.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invNo': invNo,
      'pCode': pCode,
      'pName': pName,
      'vCode': vCode,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }

  double get totalAmount {
    return orderItems.fold(0, (sum, item) => sum + item.amount);
  }
}

class ChallanOrderItemDm {
  final String iCode;
  final String iName;
  final double fat;
  final double lr;
  final double caratQty;
  final double caratNos;
  final double itemPack;
  final double qty;
  final double rate;
  final double amount;

  ChallanOrderItemDm({
    required this.iCode,
    required this.iName,
    required this.fat,
    required this.lr,
    required this.caratQty,
    required this.caratNos,
    required this.itemPack,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  factory ChallanOrderItemDm.fromJson(Map<String, dynamic> json) {
    return ChallanOrderItemDm(
      iCode: json['iCode'] ?? '',
      iName: json['iName'] ?? '',
      fat: (json['fat'] ?? 0).toDouble(),
      lr: (json['lr'] ?? 0).toDouble(),
      caratQty: (json['caratQty'] ?? 0).toDouble(),
      caratNos: (json['caratNos'] ?? 0).toDouble(),
      itemPack: (json['itemPack'] ?? 0).toDouble(),
      qty: (json['qty'] ?? 0).toDouble(),
      rate: (json['rate'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iCode': iCode,
      'iName': iName,
      'fat': fat,
      'lr': lr,
      'caratQty': caratQty,
      'caratNos': caratNos,
      'itemPack': itemPack,
      'qty': qty,
      'rate': rate,
      'amount': amount,
    };
  }
}
