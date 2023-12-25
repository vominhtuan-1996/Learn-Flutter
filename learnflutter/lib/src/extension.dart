import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/src/lib/src/utils/utils.dart';

extension Context on BuildContext {
  TextTheme get text => theme.textTheme;

  ThemeData get theme => Theme.of(this);

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

  TextStyle? get s1 => text.titleMedium;
  TextStyle? get s2 => text.titleSmall;
  TextStyle? get s3 => text.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: Palette.gray2,
      );

  TextStyle? get b => text.labelLarge;

  Size get size => MediaQuery.of(this).size;

  double get w => size.width;
  double get h => size.height;
}

extension ExtensionString on String {
  int get toInt => (int.parse(trim()));

  double get toDouble => (double.parse(trim()));

  bool get isNullOrEmpty {
    bool hasSpace = RegExp(r'\s').hasMatch(this);
    return isEmpty || hasSpace;
  }

  String get lastChars {
    String output = "";
    if (length > 0) {
      output = trim()[length - 1];
      print('Last character : $output');
    } else {
      print('Empty string, please check.');
    }
    return output;
  }

  String get firstChars {
    var output = "";
    if (length > 0) {
      output = trim()[0];
      print('First character : $output');
    } else {
      print('Empty string, please check.');
    }
    return output;
  }
}
