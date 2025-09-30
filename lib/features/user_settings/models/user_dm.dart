class UserDm {
  final int userId;
  final String fullName;
  final bool appAccess;
  final String mobileNo;
  final int userType;
  final String seCodes;
  final String pCodes;
  final String eCodes;

  UserDm({
    required this.userId,
    required this.fullName,
    required this.appAccess,
    required this.mobileNo,
    required this.userType,
    required this.seCodes,
    required this.pCodes,
    required this.eCodes,
  });

  factory UserDm.fromJson(Map<String, dynamic> json) {
    return UserDm(
      userId: json['UserId'],
      fullName: json['FULLNAME'],
      appAccess: json['AppAccess'],
      mobileNo: json['MOBILENO'],
      userType: json['USERTYPE'],
      seCodes: json['SECODEs'],
      pCodes: json['PCODEs'],
      eCodes: json['ECODEs'],
    );
  }
}
