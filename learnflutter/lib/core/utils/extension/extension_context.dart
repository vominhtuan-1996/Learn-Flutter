import 'package:flutter/material.dart';

/// Extension cho BuildContext cung cấp các phương thức truy cập nhanh đến Theme và MediaQuery.
/// Giúp rút ngắn code khi cần lấy thông tin về theme, text style, hoặc kích thước màn hình.
extension ExtensionBuildContext on BuildContext {
  /// Lấy TextStyle bodyMedium từ theme hiện tại với màu onPrimary.
  TextStyle get textStyleBodyMedium {
    return Theme.of(this).textTheme.bodyMedium!.copyWith(
          color: Theme.of(this).colorScheme.onPrimary,
        );
  }

  /// Truy cập ThemeData của context hiện tại.
  ThemeData get theme {
    return Theme.of(this);
  }

  /// Truy cập TextTheme từ theme hiện tại.
  TextTheme get textTheme {
    return Theme.of(this).textTheme;
  }

  /// Truy cập SearchBarThemeData từ theme hiện tại.
  SearchBarThemeData get searchBarTheme {
    return Theme.of(this).searchBarTheme;
  }

  /// Truy cập BottomSheetThemeData từ theme hiện tại.
  BottomSheetThemeData get bottomSheetTheme {
    return Theme.of(this).bottomSheetTheme;
  }

  /// Truy cập ChipThemeData từ theme hiện tại.
  ChipThemeData get chipTheme {
    return Theme.of(this).chipTheme;
  }

  /// Truy cập MediaQueryData để lấy thông tin về kích thước màn hình và các thuộc tính khác.
  MediaQueryData get mediaQuery {
    return MediaQuery.of(this);
  }

  /// Lấy hệ số scale của text từ MediaQuery.
  double get textScale {
    return MediaQuery.of(this).textScaleFactor;
  }

  /// Truy cập ColorScheme từ theme hiện tại.
  ColorScheme get colorScheme {
    return Theme.of(this).colorScheme;
  }

  /// Hiển thị SnackBar với thông báo tùy chỉnh.
  /// Tự động xóa SnackBar hiện tại trước khi hiển thị SnackBar mới.
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).removeCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
