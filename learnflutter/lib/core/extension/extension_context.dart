import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension ExtensionBuildContext on BuildContext {
  TextStyle get textStyleBodyMedium {
    return Theme.of(this).textTheme.bodyMedium!.copyWith(
          color: Theme.of(this).colorScheme.onPrimary,
        );
  }

  ThemeData get theme {
    return Theme.of(this);
  }

  TextTheme get textTheme {
    return Theme.of(this).textTheme;
  }

  SearchBarThemeData get searchBarTheme {
    return Theme.of(this).searchBarTheme;
  }

  DialogTheme get dialogTheme {
    return Theme.of(this).dialogTheme;
  }

  BottomSheetThemeData get bottomSheetTheme {
    return Theme.of(this).bottomSheetTheme;
  }

  ChipThemeData get chipTheme {
    return Theme.of(this).chipTheme;
  }

  MediaQueryData get mediaQuery {
    return MediaQuery.of(this);
  }

  double get textScale {
    return MediaQuery.of(this).textScaleFactor;
  }

  ColorScheme get colorScheme {
    return Theme.of(this).colorScheme;
  }
}
