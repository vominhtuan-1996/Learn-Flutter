import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Lớp tiện ích hỗ trợ tải và hiển thị hình ảnh từ tài nguyên (Assets).
/// ImageHelper tự động phân biệt giữa định dạng SVG và các định dạng hình ảnh thông thường (PNG, JPG) để sử dụng đúng Widget hiển thị.
class ImageHelper {
  /// Tải một hình ảnh từ đường dẫn khai báo trong assets.
  /// Hỗ trợ bo góc (radius), thay đổi kích thước (width, height), chế độ hiển thị (fit) và lọc màu (tintColor).
  ///
  /// Cách sử dụng:
  /// ```dart
  /// ImageHelper.loadFromAsset(
  ///   'assets/images/logo.png',
  ///   width: 100,
  ///   height: 100,
  ///   radius: BorderRadius.circular(10),
  ///   fit: BoxFit.cover,
  /// )
  /// ```
  static Widget loadFromAsset(
    String imageFilePath, {
    double? width,
    double? height,
    BorderRadius? radius,
    BoxFit? fit,
    Color? tintColor,
    Alignment? alignment,
  }) {
    if (imageFilePath.toLowerCase().endsWith('svg')) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: SvgPicture.asset(
          imageFilePath,
          width: width,
          height: height,
          fit: fit ?? BoxFit.contain,
          colorFilter: tintColor != null
              ? ColorFilter.mode(tintColor, BlendMode.srcIn)
              : null,
          alignment: alignment ?? Alignment.center,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: Image.asset(
          imageFilePath,
          width: width,
          height: height,
          fit: fit ?? BoxFit.contain,
          color: tintColor,
          alignment: alignment ?? Alignment.center,
        ),
      );
    }
  }
}
