import 'package:flutter/services.dart';

class TitleCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String capitalized = newValue.text
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join(' ');

    return newValue.copyWith(text: capitalized, selection: newValue.selection);
  }
}

class MobileNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String sanitizedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (sanitizedText.length > 10) {
      sanitizedText = sanitizedText.substring(0, 10);
    }

    final cursorPosition = sanitizedText.length;

    return TextEditingValue(
      text: sanitizedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
