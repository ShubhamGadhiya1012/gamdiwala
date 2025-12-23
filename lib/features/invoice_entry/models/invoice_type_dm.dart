class InvoiceTypeDm {
  final String invoiceTypeCode;
  final String invoiceTypeName;

  InvoiceTypeDm({required this.invoiceTypeCode, required this.invoiceTypeName});

  factory InvoiceTypeDm.fromJson(Map<String, dynamic> json) {
    return InvoiceTypeDm(
      invoiceTypeCode: json['INVOICETYPECODE'] ?? '',
      invoiceTypeName: json['INVOICETYPENAME'] ?? '',
    );
  }
}
