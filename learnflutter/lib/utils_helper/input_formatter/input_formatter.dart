import 'package:flutter/services.dart';
import 'package:learnflutter/utils_helper/input_formatter/input_date_formatter.dart';
import 'package:learnflutter/utils_helper/input_formatter/input_numerical_range_formatter.dart';
import 'package:learnflutter/utils_helper/input_formatter/text_formatter.dart';
import 'package:learnflutter/utils_helper/regex/regex.dart';

class InputFormattersHelper {
  InputFormattersHelper._();

  static List<TextInputFormatter> inputFormatterNumber({
    required double min,
    required double max,
    required int limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexNumber),
      NumericalRangeFormatter(
        min: min,
        max: max,
        isShowSnackbar: isShowSnackbar ?? false,
        message: message,
      ),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }

  static List<TextInputFormatter> inputFormatterIntegerNumberNotZero({
    int min = 1,
    required int max,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexNumberNotZero),
      NumericalIntegerRangeFormatter(
        min: min,
        max: max,
        isShowSnackbar: isShowSnackbar ?? false,
        message: message,
      ),
    ];
  }

  // số thập phân có 2 số nguyên âm sau dấu ","
  static List<TextInputFormatter> inputFormatterNegativeDecimal({
    required double min,
    required double max,
    required int limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexNegativeDoubleXX),
      NumericalRangeFormatterNegative(
        min: min,
        max: max,
        isShowSnackbar: isShowSnackbar ?? false,
        message: message,
      ),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }

  // số thập phân có 2 số nguyên sau dấu ","
  static List<TextInputFormatter> inputFormatterDecimal({
    required double min,
    required double max,
    required int limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexDoubleXX),
      NumericalRangeFormatter(
        min: min,
        max: max,
        isShowSnackbar: isShowSnackbar ?? false,
        message: message,
      ),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }

  static List<TextInputFormatter> inputFormatterPhoneNumbber() {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexPhoneNumbber),
      PhoneNumbberFormatter(),
    ];
  }

  static List<TextInputFormatter> inputFormatteReplace({
    required String from,
    required String replace,
    required int limitLength,
  }) {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexNegativeDoubleXX),
      TextReplaceFormatter(from, replace),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }

  static List<TextInputFormatter> inputFormatteDate() {
    return [
      DateTextFormatter(),
      LengthLimitingTextInputFormatter(10),
    ];
  }

  static List<TextInputFormatter> inputFormatterText({
    required int limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      TextFormatter(maxLenght: limitLength),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }

  static List<TextInputFormatter> inputFormatterTextValidationEmail({
    int? limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      TextEmailFormatter(),
    ];
  }

  static List<TextInputFormatter> inputFormatterCustom({
    required Pattern regex,
    required double min,
    required double max,
    required int limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      FilteringTextInputFormatter.allow(regex),
      NumericalRangeFormatter(
        min: min,
        max: max,
        isShowSnackbar: isShowSnackbar ?? false,
        message: message,
      ),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }
}
