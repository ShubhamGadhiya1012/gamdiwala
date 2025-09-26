import 'package:flutter/material.dart';
import 'package:gamdiwala/constants/color_constants.dart';
import 'package:gamdiwala/styles/font_sizes.dart';
import 'package:gamdiwala/styles/text_styles.dart';
import 'package:gamdiwala/utils/screen_utils/app_spacings.dart';

class RadioOption<T> {
  final T value;
  final String label;

  RadioOption({required this.value, required this.label});
}

class AppRadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final List<RadioOption<T>> options;
  final Function(T value) onChanged;

  const AppRadioGroup({
    super.key,
    required this.groupValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((option) {
        return Row(
          children: [
            Radio<T>(
              activeColor: kColorPrimary,
              value: option.value,
              groupValue: groupValue,
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
            GestureDetector(
              onTap: () {
                onChanged(option.value);
              },
              child: Text(
                option.label,
                style: TextStyles.kMediumMontserrat(
                  fontSize: FontSizes.k16FontSize,
                ),
              ),
            ),
            AppSpaces.h20,
          ],
        );
      }).toList(),
    );
  }
}
