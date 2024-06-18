import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageHelper {
  ///
  /// use: ImageHelper.loadFromAsset(image, height: 400, fit: BoxFit.fill)
  /// ImageHelper.loadFromAsset(
  ///       image,
  ///       width: 400,
  ///       radius: BorderRadius.circular(10),
  ///       tintColor: Colors.blue,
  ///       height: 400,
  ///       fit: BoxFit.fill),
  /// )
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
          color: tintColor,
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
