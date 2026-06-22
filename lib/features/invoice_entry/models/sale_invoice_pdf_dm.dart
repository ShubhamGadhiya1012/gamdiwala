class SaleInvoicePdfDm {
  final List<PdfData1Dm> data1;
  final List<PdfData2Dm> data2;
  final List<PdfData3Dm> data3;
  final List<PdfData4Dm> data4;
  final List<PdfData5Dm> data5;

  SaleInvoicePdfDm({
    required this.data1,
    required this.data2,
    required this.data3,
    required this.data4,
    required this.data5,
  });

  factory SaleInvoicePdfDm.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return SaleInvoicePdfDm(
      data1:
          (data['data1'] as List<dynamic>?)
              ?.map((e) => PdfData1Dm.fromJson(e))
              .toList() ??
          [],
      data2:
          (data['data2'] as List<dynamic>?)
              ?.map((e) => PdfData2Dm.fromJson(e))
              .toList() ??
          [],
      data3:
          (data['data3'] as List<dynamic>?)
              ?.map((e) => PdfData3Dm.fromJson(e))
              .toList() ??
          [],
      data4:
          (data['data4'] as List<dynamic>?)
              ?.map((e) => PdfData4Dm.fromJson(e))
              .toList() ??
          [],
      data5:
          (data['data5'] as List<dynamic>?)
              ?.map((e) => PdfData5Dm.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PdfData1Dm {
  final String name;
  final String address1;
  final String address2;
  final String city;
  final String zip;
  final String state;
  final String country;
  final String phone;
  final String email;
  final String pan;
  final String msmeNo;
  final String fssaiNo;
  final String gstNumber;
  final String bankName1;
  final String bankBranch1;
  final String bankAcNo1;
  final String bankIfsc1;
  final String coBankName1;
  final String coBankBranch1;
  final String coBankAcNo1;
  final String coBankIfsc1;

  PdfData1Dm({
    required this.name,
    required this.address1,
    required this.address2,
    required this.city,
    required this.zip,
    required this.state,
    required this.country,
    required this.phone,
    required this.email,
    required this.pan,
    required this.msmeNo,
    required this.fssaiNo,
    required this.gstNumber,
    required this.bankName1,
    required this.bankBranch1,
    required this.bankAcNo1,
    required this.bankIfsc1,
    required this.coBankName1,
    required this.coBankBranch1,
    required this.coBankAcNo1,
    required this.coBankIfsc1,
  });

  factory PdfData1Dm.fromJson(Map<String, dynamic> json) => PdfData1Dm(
    name: json['Name'] ?? '',
    address1: json['Address1'] ?? '',
    address2: json['Address2'] ?? '',
    city: json['City'] ?? '',
    zip: json['Zip'] ?? '',
    state: json['State'] ?? '',
    country: json['Country'] ?? '',
    phone: json['Phone'] ?? '',
    email: json['Email'] ?? '',
    pan: json['PAN'] ?? '',
    msmeNo: json['MSMENo'] ?? '',
    fssaiNo: json['FSSAINo'] ?? '',
    gstNumber: json['GSTNUMBER'] ?? '',
    bankName1: json['BankName1'] ?? '',
    bankBranch1: json['BankBranch1'] ?? '',
    bankAcNo1: json['BankAcNo1'] ?? '',
    bankIfsc1: json['BankIFSC1'] ?? '',
    coBankName1: json['CoBankName1'] ?? '',
    coBankBranch1: json['CoBankBranch1'] ?? '',
    coBankAcNo1: json['CoBankAcNo1'] ?? '',
    coBankIfsc1: json['CoBankIFSC1'] ?? '',
  );
}

class PdfData2Dm {
  final String invNo;
  final String date;
  final double amount;
  final String vehicleCode;
  final String vehicleNo;
  final String driverName;
  final String pCode;
  final String pName;
  final String add1;
  final String add2;
  final String add3;
  final String city;
  final String state;
  final String gstNumber;
  final String phone;
  final String mobile;

  PdfData2Dm({
    required this.invNo,
    required this.date,
    required this.amount,
    required this.vehicleCode,
    required this.vehicleNo,
    required this.driverName,
    required this.pCode,
    required this.pName,
    required this.add1,
    required this.add2,
    required this.add3,
    required this.city,
    required this.state,
    required this.gstNumber,
    required this.phone,
    required this.mobile,
  });

  factory PdfData2Dm.fromJson(Map<String, dynamic> json) => PdfData2Dm(
    invNo: json['INVNO'] ?? '',
    date: json['Date'] ?? '',
    amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
    vehicleCode: json['VehicleCode'] ?? '',
    vehicleNo: json['VehicleNo'] ?? '',
    driverName: json['DriverName'] ?? '',
    pCode: json['PCode'] ?? '',
    pName: json['PName'] ?? '',
    add1: json['Add1'] ?? '',
    add2: json['Add2'] ?? '',
    add3: json['Add3'] ?? '',
    city: json['City'] ?? '',
    state: json['State'] ?? '',
    gstNumber: json['GSTNumber'] ?? '',
    phone: json['Phone'] ?? '',
    mobile: json['Mobile'] ?? '',
  );
}

class PdfData3Dm {
  final String orderNo;
  final String challanNo;
  final String invNo;
  final String iCode;
  final String iName;
  final String igName;
  final double pack;
  final int nos;
  final String hsnNo;
  final double qty;
  final double rate;
  final double valueOfGoods;
  final double igstPerc;
  final double igstAmt;
  final double sgstPerc;
  final double sgstAmt;
  final double cgstPerc;
  final double cgstAmt;

  PdfData3Dm({
    required this.orderNo,
    required this.challanNo,
    required this.invNo,
    required this.iCode,
    required this.iName,
    required this.igName,
    required this.pack,
    required this.nos,
    required this.hsnNo,
    required this.qty,
    required this.rate,
    required this.valueOfGoods,
    required this.igstPerc,
    required this.igstAmt,
    required this.sgstPerc,
    required this.sgstAmt,
    required this.cgstPerc,
    required this.cgstAmt,
  });

  factory PdfData3Dm.fromJson(Map<String, dynamic> json) => PdfData3Dm(
    orderNo: json['OrderNo'] ?? '',
    challanNo: json['ChallanNo'] ?? '',
    invNo: json['InvNo'] ?? '',
    iCode: json['ICode'] ?? '',
    iName: json['INAME'] ?? '',
    igName: json['IGName'] ?? '',
    pack: (json['Pack'] as num?)?.toDouble() ?? 0.0,
    nos: (json['Nos'] as num?)?.toInt() ?? 0,
    hsnNo: json['HSNNO'] ?? '',
    qty: (json['Qty'] as num?)?.toDouble() ?? 0.0,
    rate: (json['Rate'] as num?)?.toDouble() ?? 0.0,
    valueOfGoods: (json['ValueOfGoods'] as num?)?.toDouble() ?? 0.0,
    igstPerc: (json['IGSTPERC'] as num?)?.toDouble() ?? 0.0,
    igstAmt: (json['IGSTAMT'] as num?)?.toDouble() ?? 0.0,
    sgstPerc: (json['SGSTPERC'] as num?)?.toDouble() ?? 0.0,
    sgstAmt: (json['SGSTAMT'] as num?)?.toDouble() ?? 0.0,
    cgstPerc: (json['CGSTPERC'] as num?)?.toDouble() ?? 0.0,
    cgstAmt: (json['CGSTAMT'] as num?)?.toDouble() ?? 0.0,
  );
}

class PdfData4Dm {
  final String hsnNo;
  final double taxableValue;
  final double sgstPerc;
  final double sgstAmt;
  final double cgstPerc;
  final double cgstAmt;

  PdfData4Dm({
    required this.hsnNo,
    required this.taxableValue,
    required this.sgstPerc,
    required this.sgstAmt,
    required this.cgstPerc,
    required this.cgstAmt,
  });

  factory PdfData4Dm.fromJson(Map<String, dynamic> json) => PdfData4Dm(
    hsnNo: json['HSN/SAC No'] ?? '',
    taxableValue: (json['TaxableValue'] as num?)?.toDouble() ?? 0.0,
    sgstPerc: (json['SGST%'] as num?)?.toDouble() ?? 0.0,
    sgstAmt: (json['SGSTAmt'] as num?)?.toDouble() ?? 0.0,
    cgstPerc: (json['CGST%'] as num?)?.toDouble() ?? 0.0,
    cgstAmt: (json['CGSTAmt'] as num?)?.toDouble() ?? 0.0,
  );
}

class PdfData5Dm {
  final int srNo;
  final String termsCondition;

  PdfData5Dm({required this.srNo, required this.termsCondition});

  factory PdfData5Dm.fromJson(Map<String, dynamic> json) => PdfData5Dm(
    srNo: (json['SrNo'] as num?)?.toInt() ?? 0,
    termsCondition: json['TermsCondition'] ?? '',
  );
}
