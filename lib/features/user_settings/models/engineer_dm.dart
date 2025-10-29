class EngineerDm {
  final String eCode;
  final String eName;

  EngineerDm({required this.eCode, required this.eName});

  factory EngineerDm.fromJson(Map<String, dynamic> json) {
    return EngineerDm(eCode: json['ECODE'], eName: json['ENAME']);
  }
}
