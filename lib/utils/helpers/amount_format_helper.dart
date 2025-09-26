import 'package:intl/intl.dart';

String formatIndianCurrency(dynamic amount) {
  try {
    final number = double.tryParse(amount.toString()) ?? 0.0;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(number);
  } catch (e) {
    return '₹0.00';
  }
}

String formatIndianCurrencyInWords(dynamic amount) {
  try {
    final number = double.tryParse(amount.toString()) ?? 0.0;

    if (number >= 10000000) {
      double crore = number / 10000000;
      return '${crore.toStringAsFixed(crore.truncateToDouble() == crore ? 0 : 2)} cr';
    } else if (number >= 100000) {
      double lakh = number / 100000;
      return '${lakh.toStringAsFixed(lakh.truncateToDouble() == lakh ? 0 : 2)} lakh';
    } else if (number >= 1000) {
      double thousand = number / 1000;
      return '${thousand.toStringAsFixed(thousand.truncateToDouble() == thousand ? 0 : 2)}K';
    } else {
      return number.toStringAsFixed(2);
    }
  } catch (e) {
    return '0';
  }
}
