import 'package:flutter/services.dart';
import 'package:learnflutter/core/constants/regex.dart';
import 'package:learnflutter/shared/widgets/custom_snackbar.dart';

/// NumericalRangeFormatter kiểm tra và giới hạn giá trị số (double) trong phạm vi min-max.
/// Khi giá trị nhỏ hơn min, formatter tự động set về min. Khi lớn hơn max, giữ nguyên giá trị cũ và có thể hiển thị snackbar cảnh báo nếu được cấu hình.
class NumericalRangeFormatter extends TextInputFormatter {
  final double min;
  final double max;
  final bool isShowSnackbar;
  final String? message;
  NumericalRangeFormatter(
      {required this.min,
      required this.max,
      this.isShowSnackbar = false,
      this.message});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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

/// NumericalRangeFormatterNegative tương tự NumericalRangeFormatter nhưng hỗ trợ số âm.
/// Cho phép nhập giá trị âm và kiểm tra phạm vi, phù hợp cho các trường như nhiệt độ, tọa độ.
class NumericalRangeFormatterNegative extends TextInputFormatter {
  final double min;
  final double max;
  final bool isShowSnackbar;
  final String? message;
  NumericalRangeFormatterNegative(
      {required this.min,
      required this.max,
      this.isShowSnackbar = false,
      this.message});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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

/// NumericalIntegerRangeFormatter kiểm tra và giới hạn giá trị số nguyên (int) trong phạm vi min-max.
/// Tương tự NumericalRangeFormatter nhưng chỉ làm việc với số nguyên, không hỗ trợ số thập phân.
class NumericalIntegerRangeFormatter extends TextInputFormatter {
  final int min;
  final int max;
  final bool isShowSnackbar;
  final String? message;
  NumericalIntegerRangeFormatter(
      {required this.min,
      required this.max,
      this.isShowSnackbar = false,
      this.message});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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

/// PhoneNumbberFormatter validate số điện thoại theo regex được định nghĩa trong ConstantsRegex.
/// Chỉ cho phép nhập số điện thoại hợp lệ, reject các ký tự không phù hợp.
class PhoneNumbberFormatter extends TextInputFormatter {
  PhoneNumbberFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (ConstantsRegex.regexPhoneNumbber.hasMatch(newValue.text)) {
      return const TextEditingValue().copyWith(text: newValue.text.toString());
    } else {
      return const TextEditingValue().copyWith(text: oldValue.text.toString());
    }
  }
}
