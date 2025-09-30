class UserAccessDm {
  final List<MenuAccessDm> menuAccess;
  final List<LedgerDateDm> ledgerDate;

  UserAccessDm({required this.menuAccess, required this.ledgerDate});

  factory UserAccessDm.fromJson(Map<String, dynamic> json) {
    return UserAccessDm(
      menuAccess: (json['menuAceess'] as List)
          .map((item) => MenuAccessDm.fromJson(item))
          .toList(),
      ledgerDate: (json['ledgerDate'] as List)
          .map((e) => LedgerDateDm.fromJson(e))
          .toList(),
    );
  }
}

class MenuAccessDm {
  final int menuId;
  final String menuName;
  bool access;

  MenuAccessDm({
    required this.menuId,
    required this.menuName,
    required this.access,
  });

  factory MenuAccessDm.fromJson(Map<String, dynamic> json) {
    return MenuAccessDm(
      menuId: json['MENUID'],
      menuName: json['MENUNAME'],
      access: json['Access'],
    );
  }
}

class LedgerDateDm {
  final String ledgerStart;
  final String ledgerEnd;

  LedgerDateDm({required this.ledgerStart, required this.ledgerEnd});

  factory LedgerDateDm.fromJson(Map<String, dynamic> json) {
    return LedgerDateDm(
      ledgerStart: json['LedgerStart'] ?? '',
      ledgerEnd: json['LedgerEnd'] ?? '',
    );
  }
}
