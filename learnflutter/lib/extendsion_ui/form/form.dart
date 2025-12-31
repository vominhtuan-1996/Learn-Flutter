import 'package:flutter/material.dart';

/// FormValidator - Tầng Business Logic cho form validation
///
/// Lớp này cung cấp các phương thức static để validate các loại dữ liệu khác nhau.
/// Mỗi validator trả về thông báo lỗi nếu dữ liệu không hợp lệ, ngược lại trả về null.
/// Sử dụng regex patterns được định nghĩa sẵn để xác minh định dạng dữ liệu.
class FormValidator {
  // Regex patterns cho các loại validation khác nhau
  static const String _emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String _phonePattern = r'^[0-9]{10,11}$';
  static const String _urlPattern =
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  static const String _namePattern = r'^[a-zA-Z\s]{2,50}$';
  static const String _passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    if (!RegExp(_emailPattern).hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Password validation (min 8 chars, 1 uppercase, 1 lowercase, 1 digit, 1 special char)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (!RegExp(_passwordPattern).hasMatch(value)) {
      return 'Mật khẩu phải chứa chữ hoa, chữ thường, số và ký tự đặc biệt';
    }
    return null;
  }

  /// Phone number validation (10-11 digits)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(_phonePattern).hasMatch(cleaned)) {
      return 'Số điện thoại không hợp lệ (10-11 chữ số)';
    }
    return null;
  }

  /// Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tên không được để trống';
    }
    if (value.length < 2) {
      return 'Tên phải có ít nhất 2 ký tự';
    }
    if (!RegExp(_namePattern).hasMatch(value)) {
      return 'Tên chỉ được chứa chữ cái và khoảng trắng';
    }
    return null;
  }

  /// URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL không được để trống';
    }
    if (!RegExp(_urlPattern).hasMatch(value)) {
      return 'URL không hợp lệ';
    }
    return null;
  }

  /// Empty field validation
  static String? validateRequired(String? value, {String fieldName = 'Trường'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  /// Confirm password validation
  static String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (password != confirmPassword) {
      return 'Mật khẩu không trùng khớp';
    }
    return null;
  }

  /// Min length validation
  static String? validateMinLength(
    String? value, {
    required int minLength,
    String fieldName = 'Trường',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }
    if (value.length < minLength) {
      return '$fieldName phải có ít nhất $minLength ký tự';
    }
    return null;
  }

  /// Max length validation
  static String? validateMaxLength(
    String? value, {
    required int maxLength,
    String fieldName = 'Trường',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }
    if (value.length > maxLength) {
      return '$fieldName không được vượt quá $maxLength ký tự';
    }
    return null;
  }

  /// Custom regex validation
  static String? validateRegex(
    String? value,
    String pattern, {
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return 'Trường này không được để trống';
    }
    if (!RegExp(pattern).hasMatch(value)) {
      return errorMessage ?? 'Định dạng không hợp lệ';
    }
    return null;
  }

  /// Number validation
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số không được để trống';
    }
    if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(value)) {
      return 'Vui lòng nhập số hợp lệ';
    }
    return null;
  }

  /// Username validation (alphanumeric and underscore, 3-20 chars)
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username không được để trống';
    }
    if (value.length < 3 || value.length > 20) {
      return 'Username phải có từ 3 đến 20 ký tự';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username chỉ được chứa chữ cái, số và dấu gạch dưới';
    }
    return null;
  }

  /// Integer validation
  static String? validateInteger(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số nguyên không được để trống';
    }
    if (!RegExp(r'^-?\d+$').hasMatch(value)) {
      return 'Vui lòng nhập số nguyên hợp lệ';
    }
    return null;
  }

  /// Age validation (18+)
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tuổi không được để trống';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Vui lòng nhập tuổi hợp lệ';
    }
    if (age < 18) {
      return 'Bạn phải từ 18 tuổi trở lên';
    }
    return null;
  }

  /// Credit card validation (basic)
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số thẻ tín dụng không được để trống';
    }
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'Số thẻ tín dụng không hợp lệ';
    }
    return null;
  }

  /// Password strength checker
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 6) return PasswordStrength.weak;

    int score = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[@$!%*?&]').hasMatch(password)) score++;

    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    if (score <= 1) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}

/// Password strength enum
enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

/// Password strength extension với label và màu sắc
extension PasswordStrengthX on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.empty:
        return 'Trống';
      case PasswordStrength.weak:
        return 'Yếu';
      case PasswordStrength.medium:
        return 'Vừa';
      case PasswordStrength.strong:
        return 'Mạnh';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.empty:
        return Colors.grey;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }
}
