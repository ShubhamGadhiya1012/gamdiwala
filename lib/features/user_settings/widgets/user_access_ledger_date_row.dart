import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/extensions/app_size_extensions.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';
import 'package:gamdiwala/widgets/app_date_picker_text_form_field.dart';

class UserAccessLedgerDateRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;

  const UserAccessLedgerDateRow({
    super.key,
    required this.label,
    required this.controller,
    required this.onClear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyles.kMediumMontserrat(
            fontSize: FontSizes.k18FontSize,
            color: kColorTextPrimary,
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: 0.45.screenWidth,
              child: AppDatePickerTextFormField(
                dateController: controller,
                hintText: label,
                onChanged: onChanged,
              ),
            ),
            AppSpaces.h10,
            InkWell(
              onTap: onClear,
              child: Icon(Icons.clear, color: kColorRed, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}
