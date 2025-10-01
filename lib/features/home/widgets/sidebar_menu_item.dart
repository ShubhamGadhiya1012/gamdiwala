// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/features/home/models/home_menu_item_dm.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';

class SidebarMenuItem extends StatelessWidget {
  const SidebarMenuItem({
    super.key,
    required this.menu,
    required this.isSelected,
    required this.onTap,
    this.isExpanded = false,
    this.hasSubMenus = false,
  });

  final HomeMenuItemDm menu;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isExpanded;
  final bool hasSubMenus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.combined(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: AppPaddings.combined(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border(
                bottom: BorderSide(
                  color: kColorDarkGrey.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(menu.icon, height: 28, width: 24),
                AppSpaces.h14,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.menuName,
                        style: TextStyles.kSemiBoldMontserrat(
                          fontSize: FontSizes.k15FontSize,
                          color: kColorTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (hasSubMenus)
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: kColorDarkGrey,
                      size: 22,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: kColorDarkGrey.withOpacity(0.4),
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubMenuItem extends StatelessWidget {
  const SubMenuItem({super.key, required this.menu, required this.onTap});

  final HomeMenuItemDm menu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 8, top: 1, bottom: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              color: kColorPrimary.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: kColorPrimary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpaces.h12,
                SvgPicture.asset(menu.icon, height: 20, width: 20),
                AppSpaces.h12,
                Expanded(
                  child: Text(
                    menu.menuName,
                    style: TextStyles.kMediumMontserrat(
                      fontSize: FontSizes.k14FontSize,
                      color: kColorTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: kColorDarkGrey.withOpacity(0.3),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompactSidebarMenuItem extends StatelessWidget {
  const CompactSidebarMenuItem({
    super.key,
    required this.menu,
    required this.isSelected,
    required this.onTap,
  });

  final HomeMenuItemDm menu;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        kColorPrimary.withOpacity(0.15),
                        kColorPrimary.withOpacity(0.05),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? kColorPrimary.withOpacity(0.4)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  menu.icon,
                  height: 22,
                  width: 22,
                  colorFilter: ColorFilter.mode(
                    isSelected ? kColorPrimary : kColorDarkGrey,
                    BlendMode.srcIn,
                  ),
                ),
                AppSpaces.h12,
                Expanded(
                  child: Text(
                    menu.menuName,
                    style: TextStyles.kSemiBoldMontserrat(
                      fontSize: FontSizes.k14FontSize,
                      color: isSelected ? kColorPrimary : kColorTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedSidebarMenuItem extends StatefulWidget {
  const AnimatedSidebarMenuItem({
    super.key,
    required this.menu,
    required this.isSelected,
    required this.onTap,
  });

  final HomeMenuItemDm menu;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<AnimatedSidebarMenuItem> createState() =>
      _AnimatedSidebarMenuItemState();
}

class _AnimatedSidebarMenuItemState extends State<AnimatedSidebarMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.combined(horizontal: 12, vertical: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: AppPaddings.p14,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? kColorPrimary
                    : _isHovered
                    ? kColorDarkGrey.withOpacity(0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: kColorPrimary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: AppPaddings.p10,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? kColorWhite.withOpacity(0.2)
                          : kColorDarkGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      widget.menu.icon,
                      height: 20,
                      width: 20,
                      colorFilter: ColorFilter.mode(
                        widget.isSelected ? kColorWhite : kColorDarkGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  AppSpaces.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.menu.menuName,
                          style: TextStyles.kSemiBoldMontserrat(
                            fontSize: FontSizes.k14FontSize,
                            color: widget.isSelected
                                ? kColorWhite
                                : kColorTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
