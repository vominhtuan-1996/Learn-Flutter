import 'dart:async';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/modules/home/home_aniamtion.dart';
import 'package:learnflutter/app/intro_splash.dart';
import 'package:learnflutter/modules/setting/cubit/setting_cubit.dart';
import 'package:learnflutter/modules/setting/state/setting_state.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

/// Strings Define for AppRoot Widget
class AppRootStrings {
  /// Debug log message khi splash screen khởi tạo
  static const String splashInitialized = 'Splash Screen Initialized';

  /// Debug log message khi khởi tạo hoàn tất
  static const String initializationComplete = 'Initialization Complete';

  /// Debug log message khi animation splash kết thúc
  static const String splashAnimationEnded = 'Splash animation ended, waiting init...';

  /// Debug log message khi sẵn sàng navigate
  static const String initDoneReadyNavigate = 'Init done, ready to navigate';

  /// Asset path cho background image
  static const String backgroundImage = 'assets/images/background_mobi.png';

  /// Asset path cho splash GIF animation
  static const String splashGifPath = 'assets/images/launch_tcss_v7.gif';

  /// Splash animation duration (seconds)
  static const int splashDurationSeconds = 14;
}

/// AppRoot - Main Application Navigation Widget
///
/// AppRoot là StatelessWidget chính quản lý app navigation flow.
/// Nó đóng vai trò chính trong Presentation Layer - Navigation Root:
/// 1. Hiển thị splash screen animation (14 giây)
/// 2. Lắng nghe theme changes từ SettingThemeCubit
/// 3. Quản lý app initialization timing via Completer
/// 4. Navigate tới HomeAnimationPage khi initialization xong
/// 5. Cấu hình safe area để tránh notch/status bar
///
/// Architecture Role: Presentation Layer - Root Navigation.
/// AppRoot là layer điều hướng chính sau MyApp.
/// MyApp cấu hình app-level (theme, localization, global cubits).
/// AppRoot quản lý screen navigation (splash → home → pages).
///
/// Widget Tree:
/// AppRoot (navigation root)
///   ├── SafeArea (avoid notch/status bar)
///   └── BlocBuilder<SettingThemeCubit> (listen theme changes)
///       └── FlutterSplashScreen.gif (splash animation + home screen)
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // Completer để đồng bộ hóa splash animation timing với app initialization.
    // onInit() sẽ delay 14 giây (lúc splash GIF chạy).
    // onEnd() sẽ await Completer để chắc chắn initialization xong mới navigate.
    // Điều này tránh trường hợp navigate trước khi app sẵn sàng.
    final Completer<void> initCompleter = Completer<void>();

    return SafeArea(
      // SafeArea với bottom: false, top: false để cho splash GIF fullscreen.
      // Tránh padding từ notch (top) hoặc bottom navigation (bottom).
      // Splash GIF sẽ chiếm toàn bộ screen ngoại trừ safe areas nếu cần.
      bottom: false,
      top: false,
      // BlocBuilder lắng nghe SettingThemeCubit state changes.
      // Khi user thay đổi theme (dark/light), AppRoot rebuild.
      // DeviceDimension().initValue() được gọi mỗi lần build để update screen size.
      child: BlocBuilder<SettingThemeCubit, SettingThemeState>(
        builder: (context, state) {
          // Khởi tạo device dimension (screen width, height, dpi).
          // Sử dụng giá trị này trong widgets để responsive design.
          // Gọi mỗi lần build vì screen size có thể thay đổi (device rotation).
          DeviceDimension().initValue(context);

          // FlutterSplashScreen.gif - Hiển thị splash screen với GIF animation.
          // Splash screen là first UI user nhìn thấy sau MyApp initialization.
          // Nó delay app navigation trong 14 giây cho phép app load data.
          return FlutterSplashScreen.gif(
            // backgroundImage - Background được hiển thị phía sau GIF.
            // Nếu GIF load chậm, user vẫn thấy background hình ảnh.
            // Điều này tạo smooth UX transition.
            backgroundImage: Image.asset(AppRootStrings.backgroundImage),
            // onInit() - Callback gọi khi splash screen khởi tạo.
            // Đây là lúc app bắt đầu loading resources cần thiết.
            // Future.delayed(14 giây) đợi GIF animation chạy xong.
            // initCompleter.complete() báo hiệu app initialization hoàn tất.
            onInit: () async {
              print(AppRootStrings.splashInitialized);

              // Delay 14 giây để GIF animation chạy hết.
              // Thời gian này dùng để app load background data (database, preferences).
              // Nếu data load xong sớm, Completer được complete trước delay hết.
              await Future.delayed(
                const Duration(seconds: AppRootStrings.splashDurationSeconds),
              );

              print(AppRootStrings.initializationComplete);
              // Complete Completer để onEnd() biết app đã sẵn sàng navigate.
              initCompleter.complete();
            },

            // onEnd() - Callback gọi khi splash animation kết thúc.
            // Được gọi khi GIF animation chạy xong (độc lập với data loading).
            // Nó await Completer.future để chắc chắn data loading xong trước khi navigate.
            // Điều này tránh flash/jank khi navigate nếu data loading chậm.
            onEnd: () async {
              print(AppRootStrings.splashAnimationEnded);
              // Await Completer.future để đồng bộ initialization timing.
              // Nếu data loading chậm hơn GIF duration, sẽ chờ data loading xong.
              // Nếu data loading nhanh hơn, Completer đã complete, sẽ return ngay.
              // Kết quả: navigate chỉ khi vừa animation xong vừa data ready.
              await initCompleter.future;

              print(AppRootStrings.initDoneReadyNavigate);
            },
            // nextScreen - Screen được navigate tới sau splash animation.
            // HomeAnimationPage là main home screen của app.
            // FlutterSplashScreen sẽ replace AppRoot with HomeAnimationPage.
            // Navigation này xảy ra sau onEnd() hoàn tất.
            nextScreen: const IntroSplash(),
            // gifPath - Asset path của splash screen GIF animation.
            // GIF được hiển thị từ lúc app launch cho tới onEnd() callback.
            // App load resources trong background ngal khi GIF hiển thị.
            gifPath: AppRootStrings.splashGifPath,
            // gifWidth, gifHeight - Kích thước GIF bằng screen size.
            // context.mediaQuery.size lấy device screen width/height.
            // GIF sẽ scaled fullscreen (minus safe areas).
            gifWidth: context.mediaQuery.size.width,
            gifHeight: context.mediaQuery.size.height,
          );
        },
      ),
    );
  }
}
