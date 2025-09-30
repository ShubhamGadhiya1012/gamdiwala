import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';

class ProfileMenuTile extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback? onTap;

  const ProfileMenuTile({
    super.key,
    required this.iconPath,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(kColorPrimary, BlendMode.srcIn),
          ),
          title: Text(
            title,
            style: TextStyles.kRegularMontserrat(
              fontSize: FontSizes.k18FontSize,
              color: kColorPrimary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: kColorPrimary,
          ),
        ),
        const Divider(color: kColorGrey, thickness: 0.5),
      ],
    );
  }
}
