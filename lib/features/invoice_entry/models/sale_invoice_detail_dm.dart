class SaleInvoiceDetailDm {
  final List<SaleInvoiceData1Dm> data1;
  final List<SaleInvoiceData2Dm> data2;
  final List<SaleInvoiceData3Dm> data3;

  SaleInvoiceDetailDm({
    required this.data1,
    required this.data2,
    required this.data3,
  });

  factory SaleInvoiceDetailDm.fromJson(Map<String, dynamic> json) {
    return SaleInvoiceDetailDm(
      data1:
          (json['data1'] as List<dynamic>?)
              ?.map((e) => SaleInvoiceData1Dm.fromJson(e))
              .toList() ??
          [],
      data2:
          (json['data2'] as List<dynamic>?)
              ?.map((e) => SaleInvoiceData2Dm.fromJson(e))
              .toList() ??
          [],
      data3:
          (json['data3'] as List<dynamic>?)
              ?.map((e) => SaleInvoiceData3Dm.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SaleInvoiceData1Dm {
  final String invNo;
  final String dbc;
  final String bookCode;
  final String date;
  final double amount;
  final String pCode;
  final String pCodeC;
  final int gstBillType;
  final String remarks;
  final String terms;
  final int days;
  final String dueDate;
  final String tCode;
  final String typeOfInvoice;
  final String vehicleCode;

  SaleInvoiceData1Dm({
    required this.invNo,
    required this.dbc,
    required this.bookCode,
    required this.date,
    required this.amount,
    required this.pCode,
    required this.pCodeC,
    required this.gstBillType,
    required this.remarks,
    required this.terms,
    required this.days,
    required this.dueDate,
    required this.tCode,
    required this.typeOfInvoice,
    required this.vehicleCode,
  });

  factory SaleInvoiceData1Dm.fromJson(Map<String, dynamic> json) {
    return SaleInvoiceData1Dm(
      invNo: json['InvNo'] ?? '',
      dbc: json['Dbc'] ?? '',
      bookCode: json['BookCode'] ?? '',
      date: json['Date'] ?? '',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      pCode: json['PCode'] ?? '',
      pCodeC: json['PCodeC'] ?? '',
      gstBillType: json['GSTBillType'] ?? 0,
      remarks: json['Remarks'] ?? '',
      terms: json['Terms'] ?? '',
      days: json['Days'] ?? 0,
      dueDate: json['DueDate'] ?? '',
      tCode: json['TCode'] ?? '',
      typeOfInvoice: json['TypeofInvoice'] ?? '',
      vehicleCode: json['VehicleCode'] ?? '',
    );
  }
}

class SaleInvoiceData2Dm {
  final int srNo;
  final String salesInvNo;
  final String date;
  final String iCode;
  final String iName;
  final String description;
  final double itemPack;
  final int caratNos;
  final double qty;
  final double rate;
  final double amount;
  final double lrValue;
  final double fat;
  final int caratQty;
  final String hsnNo;
  final double igstPerc;
  final double sgstPerc;
  final double cgstPerc;
  final int orderSrNo;
  final String orderNo;
  final int? challanItemSrNo;
  final String challanNo;

  SaleInvoiceData2Dm({
    required this.srNo,
    required this.salesInvNo,
    required this.date,
    required this.iCode,
    required this.iName,
    required this.description,
    required this.itemPack,
    required this.caratNos,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.lrValue,
    required this.fat,
    required this.caratQty,
    required this.hsnNo,
    required this.igstPerc,
    required this.sgstPerc,
    required this.cgstPerc,
    required this.orderSrNo,
    required this.orderNo,
    this.challanItemSrNo,
    required this.challanNo,
  });

  factory SaleInvoiceData2Dm.fromJson(Map<String, dynamic> json) {
    return SaleInvoiceData2Dm(
      srNo: json['SrNo'] ?? 0,
      salesInvNo: json['SalesInvno'] ?? '',
      date: json['Date'] ?? '',
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      description: json['Dessciption'] ?? '',
      itemPack: (json['ItemPack'] as num?)?.toDouble() ?? 0.0,
      caratNos: json['CaratNos'] ?? 0,
      qty: (json['Qty'] as num?)?.toDouble() ?? 0.0,
      rate: (json['Rate'] as num?)?.toDouble() ?? 0.0,
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      lrValue: (json['LRValue'] as num?)?.toDouble() ?? 0.0,
      fat: (json['Fat'] as num?)?.toDouble() ?? 0.0,
      caratQty: json['CaratQty'] ?? 0,
      hsnNo: json['HSNNO'] ?? '',
      igstPerc: (json['IGSTPerc'] as num?)?.toDouble() ?? 0.0,
      sgstPerc: (json['SGSTPerc'] as num?)?.toDouble() ?? 0.0,
      cgstPerc: (json['CGSTPerc'] as num?)?.toDouble() ?? 0.0,
      orderSrNo: json['OrderSrNo'] ?? 0,
      orderNo: json['OrderNo'] ?? '',
      challanItemSrNo: json['ChallanItemSrNo'],
      challanNo: json['ChallanNo'] ?? '',
    );
  }
}

class SaleInvoiceData3Dm {
  final int srNo;
  final double perc;
  final double amount;
  final String nt;
  final String pCode;
  final String description;
  final String pr;
  final String formula;

  SaleInvoiceData3Dm({
    required this.srNo,
    required this.perc,
    required this.amount,
    required this.nt,
    required this.pCode,
    required this.description,
    required this.pr,
    required this.formula,
  });

  factory SaleInvoiceData3Dm.fromJson(Map<String, dynamic> json) {
    return SaleInvoiceData3Dm(
      srNo: json['SrNo'] ?? 0,
      perc: (json['PERC'] as num?)?.toDouble() ?? 0.0,
      amount: (json['AMOUNT'] as num?)?.toDouble() ?? 0.0,
      nt: json['NT'] ?? '',
      pCode: json['PCODE'] ?? '',
      description: json['Description'] ?? '',
      pr: json['P_R'] ?? '',
      formula: json['Formula'] ?? '',
    );
  }
}
