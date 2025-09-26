import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/extensions/app_size_extensions.dart';
import 'package:gamdiwala/utils/screen_utils/app_paddings.dart';

class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    this.selectedItem,
    required this.hintText,
    this.searchHintText,
    this.fillColor,
    this.showSearchBox,
    required this.onChanged,
    this.validatorText,
    this.enabled,
    this.clearButtonProps,
    this.borderRadius,
  });

  final List<String> items;
  final String? selectedItem;
  final String hintText;
  final String? searchHintText;
  final Color? fillColor;
  final bool? showSearchBox;
  final ValueChanged<String?>? onChanged;
  final String? validatorText;
  final bool? enabled;
  final ClearButtonProps? clearButtonProps;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      selectedItem: selectedItem,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
      items: (filter, infiniteScrollProps) => items,
      enabled: enabled ?? true,
      suffixProps: DropdownSuffixProps(
        clearButtonProps:
            clearButtonProps ?? const ClearButtonProps(isVisible: false),
      ),
      decoratorProps: DropDownDecoratorProps(
        baseStyle: TextStyles.kMediumMontserrat(
          fontSize: FontSizes.k16FontSize,
          color: kColorTextPrimary,
        ),
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
          suffixIconColor: kColorTextPrimary,
        ),
      ),
      popupProps: PopupProps.menu(
        fit: FlexFit.loose,

        constraints: BoxConstraints(maxHeight: 300),
        menuProps: MenuProps(
          backgroundColor: kColorWhite,
          borderRadius: BorderRadius.circular(10),
        ),
        itemBuilder: (context, item, isDisabled, isSelected) => Padding(
          padding: AppPaddings.p10,
          child: Text(
            item,
            style: TextStyles.kRegularMontserrat(
              color: kColorTextPrimary,
              fontSize: FontSizes.k16FontSize,
            ).copyWith(height: 1),
          ),
        ),
        showSearchBox: showSearchBox ?? true,
        searchFieldProps: TextFieldProps(
          style: TextStyles.kRegularMontserrat(
            fontSize: FontSizes.k16FontSize,
            color: kColorTextPrimary,
          ),
          cursorColor: kColorTextPrimary,
          cursorHeight: 20,
          decoration: InputDecoration(
            hintText: searchHintText ?? 'Search',
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
            errorStyle: TextStyles.kMediumMontserrat(
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
            suffixIconColor: kColorPrimary,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder outlineInputBorder({
    required Color borderColor,
    required double borderWidth,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );
  }
}
