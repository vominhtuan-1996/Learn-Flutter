import 'package:flutter/material.dart';

/// Provide the width, height and some static size
class DeviceDimension {
  static final DeviceDimension _instance = DeviceDimension._internal();

  factory DeviceDimension() => _instance;

  DeviceDimension._internal();

  bool _isInit = true;

  // this is the screen size use for the design in Figma
  static const Size rootSize = Size(414, 896);

  static late final double screenWidth;
  static late final double screenHeight;

  static late final double _widthScale;
  static late final double _heightScale;
  static late final double _defaultScale;
  static double? _keyBoard;

  static double get textScale => _heightScale >= 1.5
      ? 1.5
      : _heightScale <= 1
          ? 1
          : _heightScale;

  static double get padding => screenWidth * 0.05;

  static double get keyBoard => _keyBoard ?? 0;
  // static bool get isKeyBoardSizeInitialized => (_keyBoard ?? 0.0) != 0.0;
  static bool isKeyBoardSizeInitialized = false;

  static double get appBar => verticalSize(70);

  static double get radius6 => horizontalSize(6);
  static double get radius8 => horizontalSize(8);

  static double get icon15 => horizontalSize(15);
  static double get icon25 => horizontalSize(25);
  static double get icon45 => horizontalSize(45);

  static double get h45 => verticalSize(45);
  static double get h50 => verticalSize(50);
  static double get h55 => verticalSize(55);
  static double get h60 => verticalSize(60);

  static double get backArrow => defaultSize(22);
  static double get scrollbarIndicator => defaultSize(4.5);

  /// This must be run first to use
  void initValue(BuildContext context) {
    if (!_isInit) return;
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    _widthScale = screenWidth / rootSize.width;
    _heightScale = screenHeight / rootSize.height;
    _defaultScale = (_widthScale + _heightScale) / 2;

    _isInit = false;
  }

  void setKeyBoardSize(double? size) {
    final isSizeChange = size != null && _keyBoard != size;
    // if (!isKeyBoardSizeInitialized && isSizeChange) {
    if (isSizeChange) {
      _keyBoard = size;
      // SharePref.put(SharePrefKey.KEYBOARD_HEIGHT, size);
    }
  }

  /// get a size for a fixed number
  /// num: number you want to scale
  /// follow: [num] will scale with [follow] value (0 is width, 1 is height)
  static double normalize(double num, [int follow = 0]) {
    if (follow == 0) {
      return num * _widthScale;
    }
    return num * _heightScale;
  }

  /// follow screen width
  static double horizontalSize(double num) {
    return normalize(num);
  }

  /// follow screen height
  static double verticalSize(double num) {
    return normalize(num, 1);
  }

  /// follow screen height
  static double defaultSize(double num) {
    return _defaultScale * num;
  }

  /// get window padding
  /// top: status bar (for android) and safe area in top (for ios)
  /// bottom: safe area bottom, or when keyboard up
  /// left, right: didn't see any case
  static EdgeInsets viewInsets(BuildContext context) {
    return MediaQuery.of(context).viewPadding;
  }

  /// get the current view height, that will can be use, when screen has a app bar
  static double possibleViewHeight(BuildContext context, [bool hasAppbar = true]) {
    if (!hasAppbar) return DeviceDimension.screenHeight - statusBarHeight(context);
    return DeviceDimension.screenHeight - DeviceDimension.appBar - statusBarHeight(context);
  }

  /// status bar height
  static double statusBarHeight(BuildContext context) {
    return DeviceDimension.viewInsets(context).top;
  }

  static Size getSizeView(GlobalKey key) {
    final RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
    return renderBox.size;
  }

  static Offset getOffsetView(GlobalKey key) {
    final RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(Offset.zero);
  }
}
