class CountDm {
  final int pendingEnquiryCount;
  final int pendingQuotationCount;
  final int orderCount;
  final double dueTodayAmount;
  final double overdueAmount;
  final double notDueAmount;
  final double totalOutstandingAmount;
  final double saleOfMonth;
  final double saleUptoMonth;
  final int pendingToAttend;
  final int pendingToAssign;
  final int followUpCount;

  CountDm({
    required this.pendingEnquiryCount,
    required this.pendingQuotationCount,
    required this.orderCount,
    required this.dueTodayAmount,
    required this.overdueAmount,
    required this.notDueAmount,
    required this.totalOutstandingAmount,
    required this.saleOfMonth,
    required this.saleUptoMonth,
    required this.pendingToAssign,
    required this.pendingToAttend,
    required this.followUpCount,
  });
  factory CountDm.fromJson(Map<String, dynamic> json) {
    return CountDm(
      pendingEnquiryCount: json['PendingEnquiryCount'] ?? 0,
      pendingQuotationCount: json['PendingQuotationCount'] ?? 0,
      orderCount: json['OrderCount'] ?? 0,
      dueTodayAmount: (json['DueTodayAmount'] as num?)?.toDouble() ?? 0.0,
      overdueAmount: (json['OverdueAmount'] as num?)?.toDouble() ?? 0.0,
      notDueAmount: (json['NotDueAmount'] as num?)?.toDouble() ?? 0.0,
      totalOutstandingAmount:
          (json['TotalOutstandingAmount'] as num?)?.toDouble() ?? 0.0,
      saleOfMonth: (json['SaleOfMonth'] as num?)?.toDouble() ?? 0.0,
      saleUptoMonth: (json['SaleUptoMonth'] as num?)?.toDouble() ?? 0.0,
      pendingToAssign: json['PendingToAssign'] ?? 0,
      pendingToAttend: json['PendingToAttend'] ?? 0,
      followUpCount: json['FollowupCount'] ?? 0,
    );
  }
}
