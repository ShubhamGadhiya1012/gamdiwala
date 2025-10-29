class YearDm {
  final int yearId;
  final String finYear;

  YearDm({required this.yearId, required this.finYear});

  factory YearDm.fromJson(Map<String, dynamic> json) {
    return YearDm(yearId: json['YearId'], finYear: json['FINYEAR']);
  }
}
