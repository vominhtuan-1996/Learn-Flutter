import 'package:flutter/services.dart';
import 'package:learnflutter/core/regex/regex.dart';

class TextFormatter extends TextInputFormatter {
  final int maxLenght;
  TextFormatter({
    required this.maxLenght,
  });
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length < maxLenght) {
      return TextEditingValue().copyWith(text: newValue.text);
    } else {
      return TextEditingValue().copyWith(text: oldValue.text);
    }
  }
}

class TextEmailFormatter extends TextInputFormatter {
  final int maxLenght;
  TextEmailFormatter({
    this.maxLenght = 1024,
  });
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length < maxLenght) {
      return const TextEditingValue().copyWith(text: newValue.text);
    } else {
      return const TextEditingValue().copyWith(text: oldValue.text);
    }
  }
}

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
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String result = newValue.text.replaceAll(from, replace);
    if (result.length < maxLenght) {
      return const TextEditingValue().copyWith(text: result);
    } else {
      return const TextEditingValue().copyWith(text: oldValue.text);
    }
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return ConstantsRegex.regexValidationEmail.hasMatch(this);
  }
}
