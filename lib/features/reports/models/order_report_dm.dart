class OrderReportDm {
  final String orderNo;
  final String orderDate;
  final String customer;
  final String item;
  final double nos;
  final double pack;
  final double qty;
  final double dispatchQty;
  final double pendingQty;
  final double rate;
  final double amount;
  final String challanNo;
  final String challanDate;

  OrderReportDm({
    required this.orderNo,
    required this.orderDate,
    required this.customer,
    required this.item,
    required this.nos,
    required this.pack,
    required this.qty,
    required this.dispatchQty,
    required this.pendingQty,
    required this.rate,
    required this.amount,
    required this.challanNo,
    required this.challanDate,
  });

  factory OrderReportDm.fromJson(Map<String, dynamic> json) {
    return OrderReportDm(
      orderNo: json['OrderNo'] ?? '',
      orderDate: json['Order Date'] ?? '',
      customer: json['Customer'] ?? '',
      item: json['Item'] ?? '',
      nos: (json['Nos'] ?? 0).toDouble(),
      pack: (json['Pack'] ?? 0).toDouble(),
      qty: (json['Qty'] ?? 0).toDouble(),
      dispatchQty: (json['DispatchQty'] ?? 0).toDouble(),
      pendingQty: (json['PendingQty'] ?? 0).toDouble(),
      rate: (json['Rate'] ?? 0).toDouble(),
      amount: (json['Amount'] ?? 0).toDouble(),
      challanNo: json['ChallanNo'] ?? '',
      challanDate: json['ChallanDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OrderNo': orderNo,
      'Order Date': orderDate,
      'Customer': customer,
      'Item': item,
      'Nos': nos,
      'Pack': pack,
      'Qty': qty,
      'DispatchQty': dispatchQty,
      'PendingQty': pendingQty,
      'Rate': rate,
      'Amount': amount,
      'ChallanNo': challanNo,
      'ChallanDate': challanDate,
    };
  }
}
