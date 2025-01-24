import 'package:flutter/services.dart';
import 'package:learnflutter/utils_helper/regex/regex.dart';
import 'package:learnflutter/custom_widget/custom_snackbar.dart';

class NumericalRangeFormatter extends TextInputFormatter {
  final double min;
  final double max;
  final bool isShowSnackbar;
  final String? message;
  NumericalRangeFormatter({required this.min, required this.max, this.isShowSnackbar = false, this.message});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newString = newValue.text.replaceAll(',', '.');
    if (newValue.text == '' || newValue.text == '-') {
      return newValue;
    } else if (double.parse(newString) < min) {
      return const TextEditingValue().copyWith(text: min.toStringAsFixed(1));
    } else {
      if (isShowSnackbar && double.parse(newString) > max) {
        CustomSnackBar.topWarning.show(message: message ?? "");
      }
      return double.parse(newString) > max ? oldValue : newValue;
    }
  }
}

class NumericalRangeFormatterNegative extends TextInputFormatter {
  final double min;
  final double max;
  final bool isShowSnackbar;
  final String? message;
  NumericalRangeFormatterNegative({required this.min, required this.max, this.isShowSnackbar = false, this.message});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newString = newValue.text.replaceAll(',', '.');
    if (newValue.text == '' || newValue.text == '-') {
      return newValue;
    } else if (double.parse(newString) < min) {
      return const TextEditingValue().copyWith(text: oldValue.text.toString());
    } else {
      if (isShowSnackbar && double.parse(newString) > max) {
        CustomSnackBar.topWarning.show(message: message ?? "");
      }
      return double.parse(newString) > max ? oldValue : newValue;
    }
  }
}

class NumericalIntegerRangeFormatter extends TextInputFormatter {
  final int min;
  final int max;
  final bool isShowSnackbar;
  final String? message;
  NumericalIntegerRangeFormatter({required this.min, required this.max, this.isShowSnackbar = false, this.message});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newString = newValue.text;
    if (newValue.text == '' || newValue.text == '-') {
      return newValue;
    } else if (int.parse(newString) < min) {
      return const TextEditingValue().copyWith(text: min.toString());
    } else {
      if (isShowSnackbar && int.parse(newString) > max) {
        CustomSnackBar.topWarning.show(message: message ?? "");
      }
      return int.parse(newString) > max ? oldValue : newValue;
    }
  }
}

class PhoneNumbberFormatter extends TextInputFormatter {
  PhoneNumbberFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (ConstantsRegex.regexPhoneNumbber.hasMatch(newValue.text)) {
      return const TextEditingValue().copyWith(text: newValue.text.toString());
    } else {
      return const TextEditingValue().copyWith(text: oldValue.text.toString());
    }
  }
}
