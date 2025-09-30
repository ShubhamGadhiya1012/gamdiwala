class UnauthUserDm {
  final int userId;
  final String mobileNo;
  final String fullName;

  UnauthUserDm({
    required this.userId,
    required this.mobileNo,
    required this.fullName,
  });

  factory UnauthUserDm.fromJson(Map<String, dynamic> json) {
    return UnauthUserDm(
      userId: json['UserId'],
      mobileNo: json['MobileNO'],
      fullName: json['FULLNAME'],
    );
  }
}
