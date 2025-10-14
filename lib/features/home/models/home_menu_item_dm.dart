import 'package:flutter/material.dart';

enum HomeMenuCardType { type1, type2 }

class HomeMenuItemDm {
  final String menuName;
  final IconData icon; // Changed from String to IconData
  final Widget? screen;
  final VoidCallback? onTap;
  final HomeMenuCardType? type;
  final List<HomeMenuItemDm>? subMenus;

  HomeMenuItemDm({
    required this.menuName,
    required this.icon,
    this.screen,
    this.onTap,
    this.type,
    this.subMenus,
  });
}
