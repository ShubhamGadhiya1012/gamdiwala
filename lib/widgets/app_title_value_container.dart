// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';

class AppTitleValueContainer extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;
  final Color? titleColor;
  final VoidCallback? onTap;
  final bool? showIndicator;
  final CrossAxisAlignment? crossAxisAlignment;
  final AlignmentGeometry? alignment;

  const AppTitleValueContainer({
    super.key,
    required this.title,
    required this.value,
    this.color,
    this.titleColor,
    this.onTap,
    this.showIndicator,
    this.crossAxisAlignment,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        alignment: alignment ?? Alignment.centerLeft,
        width: double.infinity,
        padding: AppPaddings.p10,
        decoration: BoxDecoration(
          color: color ?? kColorTextPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    crossAxisAlignment ?? CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.kBoldMontserrat(
                      fontSize: FontSizes.k16FontSize,
                      color: titleColor ?? kColorTextPrimary,
                    ).copyWith(height: 1),
                  ),
                  AppSpaces.v4,
                  Text(
                    value,
                    style: TextStyles.kRegularMontserrat(
                      fontSize: FontSizes.k14FontSize,
                      color: titleColor ?? kColorTextPrimary,
                    ).copyWith(height: 1),
                  ),
                ],
              ),
            ),
            if (showIndicator ?? false)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: CircleAvatar(
                  backgroundColor: kColorWhite.withOpacity(0.60),
                  radius: 12,
                  child: Icon(
                    Icons.north_east,
                    size: 14,
                    color: kColorTextPrimary.withOpacity(0.75),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
