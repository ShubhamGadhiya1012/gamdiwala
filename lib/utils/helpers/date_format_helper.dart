import 'package:intl/intl.dart';

// 'dd-MM-yyyy' => 'yyyy-MM-dd'
String convertToApiDateFormat(String inputDate) {
  return DateFormat(
    'yyyy-MM-dd',
  ).format(DateFormat('dd-MM-yyyy').parse(inputDate));
}

String convertddMMMyyyyToddMMyyyy(String inputDate) {
  return DateFormat(
    'dd-MM-yyyy',
  ).format(DateFormat('dd-MMM-yyyy').parse(inputDate));
}

String convertddMMMyyyyToyyyyMMdd(String inputDate) {
  return DateFormat(
    'yyyy-MM-dd',
  ).format(DateFormat('dd-MMM-yyyy').parse(inputDate));
}
