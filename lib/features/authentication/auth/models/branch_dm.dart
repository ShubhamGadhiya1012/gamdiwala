class BranchDm {
  final String prefix;
  final String branchCode;
  final String branchName;

  BranchDm({
    required this.prefix,
    required this.branchCode,
    required this.branchName,
  });

  factory BranchDm.fromJson(Map<String, dynamic> json) {
    return BranchDm(
      prefix: json['Prefix'],
      branchCode: json['BranchCode'],
      branchName: json['BranchName'],
    );
  }
}
