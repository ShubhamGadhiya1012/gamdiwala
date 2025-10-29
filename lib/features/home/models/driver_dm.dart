class DriverDm {
  final String dCode;
  final String driverName;

  DriverDm({required this.dCode, required this.driverName});

  factory DriverDm.fromJson(Map<String, dynamic> json) {
    return DriverDm(
      dCode: json['DCODE'] ?? '',
      driverName: json['DRIVERNAME'] ?? '',
    );
  }
}
