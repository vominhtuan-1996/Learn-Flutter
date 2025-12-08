import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_text_style.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/constraint/define_constraint.dart';
import 'package:learnflutter/core/app/app_box_decoration.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';

class SnackBarPosition {
  final int value;

  const SnackBarPosition._(this.value);

  static const SnackBarPosition top = SnackBarPosition._(0);
  static const SnackBarPosition bottom = SnackBarPosition._(1);
}

class SnackBarType {
  final String icon;
  final Color color;

  const SnackBarType._(this.icon, this.color);

  static const SnackBarType help = SnackBarType._(AssetNameImageSvg.ic_file, Color(0xff0083E4));
  static const SnackBarType failure = SnackBarType._(AssetNameImageSvg.ic_file, Color(0xffD84452));
  static const SnackBarType success = SnackBarType._(AssetNameImageSvg.ic_file, Color(0xff008254));
  static const SnackBarType warning = SnackBarType._(AssetNameImageSvg.ic_file, Color(0xffF7A046));
}

class CustomSnackBar {
  final SnackBarType contentType;
  final SnackBarPosition position;
  final SnackBarBehavior behavior;

  /// [behavior] just work with snack bar
  const CustomSnackBar({required this.contentType, this.behavior = SnackBarBehavior.fixed, this.position = SnackBarPosition.bottom});

  static const CustomSnackBar bottomFixedHelp = CustomSnackBar(contentType: SnackBarType.help);
  static const CustomSnackBar bottomFixedFailure = CustomSnackBar(contentType: SnackBarType.failure);
  static const CustomSnackBar bottomFixedSuccess = CustomSnackBar(contentType: SnackBarType.success);
  static const CustomSnackBar bottomFixedWarning = CustomSnackBar(contentType: SnackBarType.warning);

  static const CustomSnackBar bottomFloatingHelp = CustomSnackBar(behavior: SnackBarBehavior.floating, contentType: SnackBarType.help);
  static const CustomSnackBar bottomFloatingFailure = CustomSnackBar(behavior: SnackBarBehavior.floating, contentType: SnackBarType.failure);
  static const CustomSnackBar bottomFloatingSuccess = CustomSnackBar(behavior: SnackBarBehavior.floating, contentType: SnackBarType.success);
  static const CustomSnackBar bottomFloatingWarning = CustomSnackBar(behavior: SnackBarBehavior.floating, contentType: SnackBarType.warning);

  static const CustomSnackBar topHelp = CustomSnackBar(position: SnackBarPosition.top, contentType: SnackBarType.help);
  static const CustomSnackBar topFailure = CustomSnackBar(position: SnackBarPosition.top, contentType: SnackBarType.failure);
  static const CustomSnackBar topSuccess = CustomSnackBar(position: SnackBarPosition.top, contentType: SnackBarType.success);
  static const CustomSnackBar topWarning = CustomSnackBar(position: SnackBarPosition.top, contentType: SnackBarType.warning);

  void show({
    String title = 'Thông báo',
    required String message,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    VoidCallback? onTap,
    Color? snackBarColor,
    Duration? duration,
  }) {
    double sizeSnackbarContent = 160;
    double textHeight = UtilsHelper.getTextHeight(text: message, textStyle: messageStyle ?? AppTextStyles.themeBodyMedium, maxWidthOfWidget: DeviceDimension.screenWidth);
    if (position == SnackBarPosition.bottom) {
      final content = SnackBar(
        elevation: 0,
        duration: duration ?? const Duration(milliseconds: 10000),
        behavior: behavior,
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.all(DeviceDimension.padding),
        content: SnackBarContent(
          title: title,
          message: message,
          titleStyle: titleStyle,
          messageStyle: messageStyle,
          contentType: contentType,
          color: snackBarColor,
          onTap: onTap,
          onClose: ScaffoldMessenger.of(UtilsHelper.navigatorKey.currentContext!).hideCurrentSnackBar,
        ),
      );
      ScaffoldMessenger.of(UtilsHelper.navigatorKey.currentContext!)
        ..hideCurrentSnackBar()
        ..showSnackBar(content);
    } else {
      final content = SnackBar(
        elevation: 0,
        duration: duration ?? const Duration(seconds: 2),
        backgroundColor: Colors.transparent,
        dismissDirection: DismissDirection.up,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(UtilsHelper.navigatorKey.currentContext!).size.height - textHeight - sizeSnackbarContent,
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SnackBarContent(
              title: title,
              message: message,
              titleStyle: titleStyle,
              messageStyle: messageStyle,
              contentType: contentType,
              color: snackBarColor,
              onTap: onTap,
              onClose: ScaffoldMessenger.of(UtilsHelper.navigatorKey.currentContext!).hideCurrentSnackBar,
            ),
            const SizedBox.shrink(),
          ],
        ),
      );
      ScaffoldMessenger.of(UtilsHelper.navigatorKey.currentContext!)
        ..hideCurrentSnackBar()
        ..showSnackBar(content);
    }
  }

  void hide() {
    if (position == SnackBarPosition.bottom) {
      ScaffoldMessenger.of(UtilsHelper.navigatorKey.currentContext!).hideCurrentSnackBar();
    } else {
      ScaffoldMessenger.of(UtilsHelper.navigatorKey.currentContext!).hideCurrentMaterialBanner();
    }
  }
}

class SnackBarContent extends StatelessWidget {
  /// title is the header String that will show on top
  final String title;

  /// message String is the body message which shows only 2 lines at max
  final String message;

  /// `optional` color of the SnackBar/MaterialBanner body
  final Color? color;

  /// contentType will reflect the overall theme of SnackBar/MaterialBanner: failure, success, help, warning
  final SnackBarType contentType;

  /// if you want to customize the font size of the title
  final TextStyle? titleStyle;

  /// if you want to customize the font size of the message
  final TextStyle? messageStyle;

  /// on tap x icon (close icon)
  final VoidCallback? onClose;

  /// on tap to this snack bar
  final VoidCallback? onTap;

  const SnackBarContent({
    super.key,
    required this.title,
    required this.message,
    this.color,
    required this.contentType,
    this.titleStyle,
    this.messageStyle,
    this.onClose,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final minHeight = DeviceDimension.verticalSize(120);
    final iconBackgroundSize = DeviceDimension.horizontalSize(80);
    final iconCloseSize = DeviceDimension.defaultSize(25);
    final borderRadius = DeviceDimension.defaultSize(15);

    final iconTypeBackgroundSize = DeviceDimension.screenHeight * 0.06;
    final leftSpace = DeviceDimension.screenWidth * 0.12;

    final colorLight = color ?? contentType.color;
    // final color = colorLight.darker;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppBoxDecoration.boxDecorationRadius(borderRadius, colorLight),
        constraints: BoxConstraints(minHeight: minHeight),
        child: const Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Container(
            //   alignment: Alignment.bottomLeft,
            //   clipBehavior: Clip.hardEdge,
            //   decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(borderRadius))),
            //   child: ImageHelper.loadFromAsset(Assets.icSnackBarContainerBubbles, height: iconBackgroundSize, width: iconBackgroundSize, tintColor: color),
            // ),
            // Row(
            //   children: [
            //     SpaceHorizontal(width: iconBackgroundSize + DeviceDimension.padding / 2),
            //     Expanded(
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           SpaceVertical(height: DeviceDimension.padding / 2),
            //           Text(title, style: titleStyle ?? AppTextStyles.titleMediumW700.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
            //           SpaceVertical(height: DeviceDimension.padding / 5),
            //           Text(message, style: titleStyle ?? AppTextStyles.bodyMediumW400.copyWith(color: Colors.white), maxLines: null, overflow: TextOverflow.visible),
            //           SpaceVertical(height: DeviceDimension.padding / 2),
            //         ],
            //       ),
            //     ),
            //     SpaceHorizontal(width: DeviceDimension.padding / 2),
            //   ],
            // ),
            // Positioned(
            //   top: 0,
            //   right: 0,
            //   child: MbTap(
            //     onTap: onClose,
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: ImageHelper.loadFromAsset(Assets.icClose, width: iconCloseSize, height: iconCloseSize, tintColor: Colors.white),
            //     ),
            //   ),
            // ),
            // Positioned(
            //   top: -DeviceDimension.screenHeight * 0.02,
            //   left: leftSpace - DeviceDimension.screenWidth * 0.075,
            //   child: Stack(
            //     alignment: Alignment.center,
            //     children: [
            //       ImageHelper.loadFromAsset(
            //         Assets.icSnackBarIconTypeBackground,
            //         height: iconTypeBackgroundSize,
            //         tintColor: color,
            //       ),
            //       Positioned(
            //         top: DeviceDimension.screenHeight * 0.015,
            //         child: ImageHelper.loadFromAsset(
            //           contentType.icon,
            //           height: DeviceDimension.screenHeight * 0.022,
            //         ),
            //       )
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
