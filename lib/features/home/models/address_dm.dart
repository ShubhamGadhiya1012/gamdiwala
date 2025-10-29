class AddressDm {
  final String address1;
  final String address2;
  final String address3;
  final String city;
  final String state;
  final String pinCode;
  final String phone;
  final String mobile;

  AddressDm({
    required this.address1,
    required this.address2,
    required this.address3,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.phone,
    required this.mobile,
  });

  factory AddressDm.fromJson(Map<String, dynamic> json) {
    return AddressDm(
      address1: json['Address1'] ?? '',
      address2: json['Address2'] ?? '',
      address3: json['Address3'] ?? '',
      city: json['City'] ?? '',
      state: json['State'] ?? '',
      pinCode: json['PinCode'] ?? '',
      phone: json['Phone'] ?? '',
      mobile: json['Mobile'] ?? '',
    );
  }

  String get fullAddress {
    List<String> parts = [];
    if (address1.isNotEmpty) parts.add(address1);
    if (address2.isNotEmpty) parts.add(address2);
    if (address3.isNotEmpty) parts.add(address3);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (pinCode.isNotEmpty) parts.add(pinCode);
    return parts.join(', ');
  }
}
