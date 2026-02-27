import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/shared/widgets/lib/src/utils/utils.dart';
import 'package:learnflutter/core/utils/extension/recase.dart';

/// Extension cho BuildContext cung cấp các shortcut để truy cập TextStyle theo quy ước đặt tên ngắn gọn.
/// Các getter như h1, h2, s1, s2 giúp code ngắn gọn hơn khi làm việc với typography.
extension Context on BuildContext {
  TextTheme get text => theme.textTheme;

  ThemeData get theme => Theme.of(this);

  /// Các heading styles từ h1 đến h7.
  TextStyle? get h1 => text.displayLarge;
  TextStyle? get h2 => text.displayMedium;
  TextStyle? get h3 => text.displaySmall;
  TextStyle? get h4 => text.headlineMedium;
  TextStyle? get h5 => text.headlineSmall;
  TextStyle? get h6 => text.titleLarge;
  TextStyle? get h7 => text.titleLarge?.copyWith(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      );

  /// Các subtitle styles.
  TextStyle? get s1 => text.titleMedium;
  TextStyle? get s2 => text.titleSmall;
  TextStyle? get s3 => text.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: Palette.gray2,
      );

  /// Body text style.
  TextStyle? get b => text.labelLarge;

  /// Kích thước màn hình.
  Size get size => MediaQuery.of(this).size;

  /// Chiều rộng màn hình.
  double get w => size.width;

  /// Chiều cao màn hình.
  double get h => size.height;
}

/// Extension cho String cung cấp các phương thức chuyển đổi và kiểm tra.
/// Bao gồm parse sang int/double, kiểm tra rỗng, và lấy ký tự đầu/cuối.
extension ExtensionString on String {
  /// Chuyển đổi chuỗi sang int sau khi trim khoảng trắng.
  int get toInt => (int.parse(trim()));

  /// Chuyển đổi chuỗi sang double sau khi trim khoảng trắng.
  double get toDouble => (double.parse(trim()));

  /// Kiểm tra chuỗi có rỗng hoặc chỉ chứa khoảng trắng không.
  bool get isNullOrEmpty {
    bool hasSpace = RegExp(r'\s').hasMatch(this);
    return isEmpty || hasSpace;
  }

  /// Lấy ký tự cuối cùng của chuỗi sau khi trim.
  String get lastChars {
    String output = "";
    if (length > 0) {
      output = trim()[length - 1];
      debugPrint('Last character : $output');
    } else {
      debugPrint('Empty string, please check.');
    }
    return output;
  }

  /// Lấy ký tự đầu tiên của chuỗi sau khi trim.
  String get firstChars {
    var output = "";
    if (length > 0) {
      output = trim()[0];
      debugPrint('First character : $output');
    } else {
      debugPrint('Empty string, please check.');
    }
    return output;
  }
}

extension StringReCase on String {
  // getx has extention string recase
  String get camelCaseChange => ReCase(this).camelCase;

  String get paramCaseChange => ReCase(this).paramCase;

  String get constantCase => ReCase(this).constantCase;

  String get sentenceCase => ReCase(this).sentenceCase;

  String get snakeCase => ReCase(this).snakeCase;

  String get dotCase => ReCase(this).dotCase;

  String get pathCase => ReCase(this).pathCase;

  String get pascalCase => ReCase(this).pascalCase;

  String get headerCase => ReCase(this).headerCase;

  String get headerUnderlinedCase => ReCase(this).headerUnderlinedCase;

  String get titleCase => ReCase(this).titleCase;

  // bỏ dấu tiếng việt
  String get removeAccent => removeDiacritics(this);
}
