class CustomiseVoucherDm {
  final int srNo;
  final String description;
  final int defaultValue;
  final String formula;
  final bool visible;
  final String round;
  final String pr;
  final String pCode;
  final String nt;
  final int tax;
  final String bookCode;
  final String dbc;
  final int coCode;
  final int yearId;
  final int addLess;

  CustomiseVoucherDm({
    required this.srNo,
    required this.description,
    required this.defaultValue,
    required this.formula,
    required this.visible,
    required this.round,
    required this.pr,
    required this.pCode,
    required this.nt,
    required this.tax,
    required this.bookCode,
    required this.dbc,
    required this.coCode,
    required this.yearId,
    required this.addLess,
  });

  factory CustomiseVoucherDm.fromJson(Map<String, dynamic> json) {
    return CustomiseVoucherDm(
      srNo: json['SRNO'],
      description: json['Description'],
      defaultValue: json['DefaultValue'],
      formula: json['Formula'],
      visible: json['Visible'],
      round: json['Round'],
      pr: json['P_R'],
      pCode: json['PCode'],
      nt: json['NT'],
      tax: json['Tax'],
      bookCode: json['BookCode'],
      dbc: json['DBC'],
      coCode: json['CoCode'],
      yearId: json['YearID'],
      addLess: json['AddLess'],
    );
  }
}
