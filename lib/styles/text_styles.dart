import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'fonts.dart';

class TextStyles {
  static TextStyle kThinMontserrat({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorTextPrimary,
    FontWeight fontWeight = FontWeight.w100,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.montserratThin,
    );
  }

  static TextStyle kExtraLightMontserrat({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorTextPrimary,
    FontWeight fontWeight = FontWeight.w200,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.montserratExtraLight,
    );
  }

  static TextStyle kLightMontserrat({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorTextPrimary,
    FontWeight fontWeight = FontWeight.w300,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.montserratLight,
    );
  }

  static TextStyle kRegularMontserrat({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorTextPrimary,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.montserratRegular,
    );
  }

  static TextStyle kMediumMontserrat({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorTextPrimary,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.montserratMedium,
    );
  }

  static TextStyle kSemiBoldMontserrat({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorTextPrimary,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.montserratSemiBold,
    );
  }

  static TextStyle kBoldMontserrat({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorTextPrimary,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.montserratBold,
    );
  }

  static TextStyle kExtraBoldMontserrat({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorTextPrimary,
    FontWeight fontWeight = FontWeight.w800,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.montserratExtraBold,
    );
  }

  static TextStyle kBlackMontserrat({
    double fontSize = FontSizes.k20FontSize,
    Color color = kColorTextPrimary,
    FontWeight fontWeight = FontWeight.w900,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: Fonts.montserratBlack,
    );
  }
}
