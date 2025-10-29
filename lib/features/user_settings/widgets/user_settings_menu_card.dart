// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';

class UserSettingsMenuCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const UserSettingsMenuCard({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: AppPaddings.p10,
        decoration: BoxDecoration(
          color: kColorPrimary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, height: 50, width: 50),
            AppSpaces.v10,
            Text(
              label,
              style: TextStyles.kMediumMontserrat(
                fontSize: FontSizes.k14FontSize,
                color: kColorTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
