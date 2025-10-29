import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:get/get.dart';

void showErrorSnackbar(String title, String message) {
  Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: kColorRed,
    duration: const Duration(seconds: 3),
    margin: AppPaddings.p10,
    borderRadius: 15,
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 750),
    titleText: Text(
      title,
      style: TextStyles.kMediumMontserrat(
        color: kColorWhite,
        fontSize: FontSizes.k16FontSize,
      ),
    ),
    messageText: Text(
      message,
      style: TextStyles.kRegularMontserrat(
        fontSize: FontSizes.k14FontSize,
        color: kColorWhite,
      ),
    ),
    mainButton: TextButton(
      onPressed: () {
        Get.back();
      },
      child: Text(
        'OK',
        style: TextStyles.kMediumMontserrat(
          color: kColorWhite,
          fontSize: FontSizes.k24FontSize,
        ),
      ),
    ),
  );
}

void showSuccessSnackbar(String title, String message) {
  Get.snackbar(
    '',
    '',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: kColorGreen,
    duration: const Duration(seconds: 3),
    margin: AppPaddings.p10,
    borderRadius: 15,
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 750),
    titleText: Text(
      title,
      style: TextStyles.kMediumMontserrat(
        color: kColorWhite,
        fontSize: FontSizes.k20FontSize,
      ),
    ),
    messageText: Text(
      message,
      style: TextStyles.kRegularMontserrat(
        fontSize: FontSizes.k16FontSize,
        color: kColorWhite,
      ),
    ),
    mainButton: TextButton(
      onPressed: () {
        Get.back();
      },
      child: Text(
        'OK',
        style: TextStyles.kMediumMontserrat(
          color: kColorWhite,
          fontSize: FontSizes.k20FontSize,
        ),
      ),
    ),
  );
}

void showErrorDialog(String title, String message) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: AppPaddings.p20,
        decoration: BoxDecoration(
          color: kColorWhite,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: kColorBlackWithOpacity,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpaces.v10,
            Text(
              title,
              style: TextStyles.kBoldMontserrat(
                color: kColorRed,
                fontSize: FontSizes.k24FontSize,
              ),
            ),
            AppSpaces.v10,
            Text(
              message,
              style: TextStyles.kRegularMontserrat(
                fontSize: FontSizes.k18FontSize,
                color: kColorTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpaces.v10,
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "OK",
                style: TextStyles.kSemiBoldMontserrat(color: kColorRed),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showSuccessDialog(String title, String message) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: AppPaddings.p20,
        decoration: BoxDecoration(
          color: kColorWhite,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: kColorBlackWithOpacity,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpaces.v10,
            Text(
              title,
              style: TextStyles.kBoldMontserrat(
                color: kColorGreen,
                fontSize: FontSizes.k24FontSize,
              ),
            ),
            AppSpaces.v10,
            Text(
              message,
              style: TextStyles.kRegularMontserrat(
                fontSize: FontSizes.k18FontSize,
                color: kColorTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpaces.v10,
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "OK",
                style: TextStyles.kSemiBoldMontserrat(color: kColorGreen),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
