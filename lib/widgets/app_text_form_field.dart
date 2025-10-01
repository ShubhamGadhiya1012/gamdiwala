import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/extensions/app_size_extensions.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.controller,
    this.enabled,
    this.maxLines,
    this.minLines,
    this.onChanged,
    this.validator,
    required this.hintText,
    this.keyboardType,
    this.fillColor,
    this.suffixIcon,
    this.isObscure = false,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.fontSize,
    this.fontWeight,
    this.showClearIcon = false,
  });

  final TextEditingController controller;
  final bool? enabled;
  final int? maxLines;
  final int? minLines;
  final void Function(String value)? onChanged;
  final String? Function(String? value)? validator;
  final String hintText;
  final TextInputType? keyboardType;
  final Color? fillColor;
  final Widget? suffixIcon;
  final bool? isObscure;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onFieldSubmitted;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool showClearIcon;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return TextFormField(
          controller: controller,
          cursorColor: kColorTextPrimary,
          cursorHeight: 20,
          inputFormatters: inputFormatters,
          enabled: enabled ?? true,
          maxLines: maxLines ?? 1,
          minLines: minLines ?? 1,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType ?? TextInputType.text,
          style: TextStyles.kMediumMontserrat(
            fontSize: fontSize ?? FontSizes.k16FontSize,
            color: kColorTextPrimary,
          ).copyWith(fontWeight: fontWeight ?? FontWeight.w400),
          obscureText: isObscure!,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyles.kRegularMontserrat(
              fontSize: FontSizes.k16FontSize,
              color: kColorDarkGrey,
            ),
            labelText: hintText,
            labelStyle: TextStyles.kRegularMontserrat(
              fontSize: FontSizes.k16FontSize,
              color: kColorDarkGrey,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            floatingLabelStyle: TextStyles.kMediumMontserrat(
              fontSize: FontSizes.k18FontSize,
              color: kColorPrimary,
            ),
            errorStyle: TextStyles.kRegularMontserrat(
              fontSize: FontSizes.k16FontSize,
              color: kColorRed,
            ),
            border: outlineInputBorder(
              borderColor: kColorDarkGrey,
              borderWidth: 1,
            ),
            enabledBorder: outlineInputBorder(
              borderColor: kColorDarkGrey,
              borderWidth: 1,
            ),
            disabledBorder: outlineInputBorder(
              borderColor: kColorDarkGrey,
              borderWidth: 1,
            ),
            focusedBorder: outlineInputBorder(
              borderColor: kColorPrimary,
              borderWidth: 1,
            ),
            errorBorder: outlineInputBorder(
              borderColor: kColorRed,
              borderWidth: 1,
            ),
            contentPadding: AppPaddings.combined(
              horizontal: 16.appWidth,
              vertical: 8.appHeight,
            ),
            filled: true,
            fillColor: fillColor ?? kColorWhite,
            suffixIcon: showClearIcon && value.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: kColorDarkGrey),
                    onPressed: () {
                      controller.clear();
                      if (onChanged != null) {
                        onChanged!('');
                      }
                    },
                  )
                : suffixIcon,
            suffixIconColor: kColorPrimary,
          ),
        );
      },
    );
  }

  OutlineInputBorder outlineInputBorder({
    required Color borderColor,
    required double borderWidth,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );
  }
}
