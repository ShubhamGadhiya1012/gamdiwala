import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    required this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.elevation,
  });

  final Color? color;
  final Color? borderColor;
  final double? borderRadius;
  final Widget child;
  final VoidCallback onTap;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: elevation ?? 5,
        margin: AppPaddings.custom(bottom: 10),
        color: color ?? kColorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          side: BorderSide(color: borderColor ?? kColorTextPrimary),
        ),
        child: Padding(padding: AppPaddings.p10, child: child),
      ),
    );
  }
}
