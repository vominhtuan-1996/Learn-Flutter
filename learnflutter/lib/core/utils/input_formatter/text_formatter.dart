import 'package:flutter/services.dart';
import 'package:learnflutter/core/constants/regex.dart';

/// TextFormatter giới hạn độ dài text người dùng có thể nhập vào TextField.
/// Khi đạt đến giới hạn maxLength, formatter sẽ giữ nguyên giá trị cũ thay vì cho phép nhập thêm.
class TextFormatter extends TextInputFormatter {
  final int maxLenght;
  TextFormatter({
    required this.maxLenght,
  });
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length < maxLenght) {
      return const TextEditingValue().copyWith(text: newValue.text);
    } else {
      return const TextEditingValue().copyWith(text: oldValue.text);
    }
  }
}

/// TextEmailFormatter giới hạn độ dài email người dùng có thể nhập.
/// Mặc định cho phép tối đa 1024 ký tự, phù hợp với độ dài email tiêu chuẩn.
class TextEmailFormatter extends TextInputFormatter {
  final int maxLenght;
  TextEmailFormatter({
    this.maxLenght = 1024,
  });
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length < maxLenght) {
      return const TextEditingValue().copyWith(text: newValue.text);
    } else {
      return const TextEditingValue().copyWith(text: oldValue.text);
    }
  }
}

/// TextReplaceFormatter tự động thay thế ký tự trong quá trình nhập liệu.
/// Hữu ích để chuẩn hóa input, ví dụ: thay dấu chấm bằng dấu phẩy cho số thập phân.
class TextReplaceFormatter extends TextInputFormatter {
  final String from;
  final String replace;
  final int maxLenght;
  TextReplaceFormatter(
    this.from,
    this.replace, {
    this.maxLenght = 1024,
  });
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String result = newValue.text.replaceAll(from, replace);
    if (result.length < maxLenght) {
      return const TextEditingValue().copyWith(text: result);
    } else {
      return const TextEditingValue().copyWith(text: oldValue.text);
    }
  }
}

/// Extension cho String để validate định dạng email.
/// Sử dụng regex để kiểm tra email có đúng format chuẩn hay không.
extension EmailValidator on String {
  bool isValidEmail() {
    return ConstantsRegex.regexValidationEmail.hasMatch(this);
  }
}
