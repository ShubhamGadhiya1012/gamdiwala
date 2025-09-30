import 'package:flutter/material.dart';

enum HomeMenuCardType { type1, type2 }

class HomeMenuItemDm {
  final String menuName;
  final String count;
  final String subCount;
  final String icon;
  final Widget? screen;
  final VoidCallback? onTap;
  final HomeMenuCardType? type;
  final List<HomeMenuItemDm>? subMenus;

  HomeMenuItemDm({
    required this.menuName,
    required this.count,
    required this.subCount,
    required this.icon,
    this.screen,
    this.onTap,
    this.type,
    this.subMenus,
  });
}
