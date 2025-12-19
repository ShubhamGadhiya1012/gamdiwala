// customer_account_dm.dart
class CustomerAccountDm {
  final String pCode;
  final String pName;

  CustomerAccountDm({required this.pCode, required this.pName});

  factory CustomerAccountDm.fromJson(Map<String, dynamic> json) {
    return CustomerAccountDm(
      pCode: json['PCODE'] ?? '',
      pName: json['PNAME'] ?? '',
    );
  }
}