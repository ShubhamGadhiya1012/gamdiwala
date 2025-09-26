import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonColor,
    this.borderColor,
    required this.title,
    this.titleSize,
    this.titleColor,
    required this.onPressed,
    this.isLoading = false,
    this.loadingIndicatorColor,
  });

  final double? buttonHeight;
  final double? buttonWidth;
  final Color? buttonColor;
  final String title;
  final double? titleSize;
  final Color? titleColor;
  final Color? borderColor;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? loadingIndicatorColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight ?? 45,
      width: buttonWidth ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: AppPaddings.p2,
          backgroundColor: buttonColor ?? kColorPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: borderColor ?? (buttonColor ?? kColorPrimary),
            ),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: loadingIndicatorColor ?? kColorWhite,
                  strokeWidth: 2,
                ),
              )
            : Text(
                title,
                style: TextStyles.kMediumMontserrat(
                  fontSize: titleSize ?? FontSizes.k20FontSize,
                  color: titleColor ?? kColorWhite,
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
