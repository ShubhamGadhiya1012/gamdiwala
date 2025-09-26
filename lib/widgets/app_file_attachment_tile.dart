import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';

class AppFileAttachmentTile extends StatelessWidget {
  final String fileName;
  final IconData icon;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const AppFileAttachmentTile({
    super.key,
    required this.fileName,
    required this.icon,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      leading: Icon(icon, color: kColorTextPrimary, size: 20),
      title: Text(
        fileName,
        style: TextStyles.kRegularMontserrat(fontSize: FontSizes.k15FontSize),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: TextStyles.kRegularMontserrat(
          fontSize: FontSizes.k12FontSize,
          color: kColorDarkGrey,
        ),
      ),
      trailing: trailing,
    );
  }
}
