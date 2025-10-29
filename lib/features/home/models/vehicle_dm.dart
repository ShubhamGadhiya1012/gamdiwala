class VehicleDm {
  final String vCode;
  final String regNo;
  final String vType;

  VehicleDm({required this.vCode, required this.regNo, required this.vType});

  factory VehicleDm.fromJson(Map<String, dynamic> json) {
    return VehicleDm(
      vCode: json['VCODE'] ?? '',
      regNo: json['REGNO'] ?? '',
      vType: json['VType'] ?? '',
    );
  }
}
