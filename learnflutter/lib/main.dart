// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:learnflutter/app/app_root.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/component/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/search_bar/cubit/search_bar_cubit.dart';
import 'package:learnflutter/core/keyboard/global_nokeyboard_rebuild.dart';
import 'package:learnflutter/core/keyboard/keyboard_service.dart';
import 'package:learnflutter/db/hive_demo/model/person.dart';
import 'package:learnflutter/constraint/define_constraint.dart';
import 'package:learnflutter/core/app/app_theme.dart';
import 'package:learnflutter/component/routes/route.dart';
import 'package:learnflutter/modules/setting/cubit/setting_cubit.dart';
import 'package:learnflutter/modules/setting/state/setting_state.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';
import 'package:notification_center/notification_center.dart';
import 'package:learnflutter/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
// import 'package:shorebird/shorebird.dart';

/// main - Entry point của ứng dụng Flutter
///
/// Phương thức main được gọi khi app khởi động. Nó chịu trách nhiệm:
/// 1. Khởi tạo Flutter engine (WidgetsFlutterBinding.ensureInitialized)
/// 2. Khởi động core services (KeyboardService, database, localization)
/// 3. Khởi tạo local cache (Hive)
/// 4. Chạy app (runApp)
///
/// Theo Clean Architecture, main chỉ orchestrate initialization, không chứa business logic.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi động keyboard listener service toàn cục
  KeyboardService.instance.start();

  // Khởi tạo app configuration và dependencies
  AppConfig.init(
    () async {
      // Khởi tạo Hive local database
      await Hive.initFlutter();
      // Đăng ký adapter cho model serialization
      Hive.registerAdapter(PersonAdapter());
      // Mở hive box để lưu trữ local data
      await Hive.openBox('peopleBox');

      // Initialize ApiClient with base URL and optional token refresh handler
      ApiClient.instance.init(
        baseUrl: 'https://api.petsocial.example',
        tokenRefreshHandler: () async {
          try {
            // Example refresh flow: read refresh token from SharedPreferences, call refresh endpoint
            final refreshToken = SharedPreferenceUtils.prefs.getString('refresh_token');
            if (refreshToken == null) return null;
            final resp = await ApiClient.instance
                .post('/auth/refresh', data: {'refreshToken': refreshToken});
            final newToken = resp['accessToken'] ?? resp['token'];
            if (newToken != null && newToken is String) {
              ApiClient.instance.setAuthToken(newToken);
              return newToken;
            }
          } catch (_) {}
          return null;
        },
      );

      // Chạy app với GlobalNoKeyboardRebuild wrapper
      // Wrapper này ngăn rebuild UI khi keyboard hiển thị/ẩn
      runApp(GlobalNoKeyboardRebuild(
        addBottomPadding: true,
        animationDurationMs: 200,
        child: MyApp(),
      ));
    },
  );
}

/// Background Task Constants
///
/// Các hằng số này định nghĩa các tasks khác nhau cho WorkManager.
/// WorkManager cho phép app chạy background tasks ngay cả khi app bị close.
/// Các tasks này được define theo platform và scheduled time.
const String simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const String rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const String failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const String simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const String simplePeriodicTask = "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const String simplePeriodic1HourTask = "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";

/// callbackDispatcher - Entry point cho background tasks
///
/// Phương thức này được gọi khi WorkManager trigger một scheduled task.
/// Nó xử lý logic cho từng loại task khác nhau (dựa vào task key).
/// Phương thức phải được annotate với @pragma('vm:entry-point') để flutter không optimize nó.
///
/// Các task types:
/// - Simple tasks: Chạy một lần
/// - Periodic tasks: Chạy theo lịch định kỳ
/// - iOS background: Chạy khi iOS trigger background fetch
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        // Chạy simple task: in log và gửi notification
        print("$simpleTaskKey was executed. inputData = $inputData");
        NotificationCenter().notify('updateCounter');
        break;
      case rescheduledTaskKey:
        // Check xem task đã chạy trước đó không
        final key = inputData!['key']!;
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('unique-$key')) {
          print('has been running before, task is successful');
          return true;
        } else {
          // Lần đầu chạy, reschedule task
          await prefs.setBool('unique-$key', true);
          print('reschedule task');
          return false;
        }
      case failedTaskKey:
        // Task này luôn fail để test error handling
        print('failed task');
        return Future.error('failed');
      case simpleDelayedTask:
        // Delayed task: Chạy sau một delay nào đó
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        // Periodic task: Chạy theo interval định kỳ
        print("$simplePeriodicTask was executed");
        break;
      case simplePeriodic1HourTask:
        // Periodic task chạy mỗi giờ
        print("$simplePeriodic1HourTask was executed");
        break;
      case Workmanager.iOSBackgroundTask:
        // iOS background fetch: Gọi khi iOS trigger background refresh
        stderr.writeln("The iOS background fetch was triggered");
        break;
    }
    return Future.value(true);
  });
}

/// MyApp - Root Widget của ứng dụng Flutter
///
/// MyApp là StatefulWidget root entry point khi app khởi động.
/// Nó đóng vai trò chính trong Presentation Layer - Root Level:
/// 1. Cung cấp tất cả global Cubits cho toàn app (SettingThemeCubit, BaseLoadingCubit, SearchCubit)
/// 2. Cấu hình dynamic theme dựa trên user preferences từ SharedPreferences
/// 3. Thiết lập routing system cho navigation
/// 4. Xử lý localization (đa ngôn ngữ support: EN, KM, JA, VI)
/// 5. Bắt sự kiện keyboard show/hide từ KeyboardService
///
/// Architecture Role: Kết nối giữa Core services (KeyboardService, AppThemes)
/// với Business Logic (Cubits) và Presentation (Screens).
/// Tuân theo Clean Architecture - không có business logic trong MyApp,
/// chỉ orchestrate app-level configuration và state management.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// _MyAppState - State class quản lý app-level state
///
/// Tương trách:
/// 1. Khởi tạo FlutterLocalization để support đa ngôn ngữ
/// 2. Cấu hình các MapLocale cho từng language (English, Khmer, Japanese, Vietnamese)
/// 3. Listen vào language changes để rebuild UI khi user thay đổi language
/// 4. Tổng hợp tất cả Cubits và cấu hình MaterialApp
class _MyAppState extends State<MyApp> {
  /// FlutterLocalization instance để handle đa ngôn ngữ
  /// Core Layer service cung cấp localization functionality
  final FlutterLocalization _localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();
    // Khởi tạo localization system
    // Định nghĩa tất cả supported languages và locales
    _localization.init(
      // Danh sách các mapLocales định nghĩa từng language
      // Mỗi MapLocale bao gồm language code, translations, country code, và font
      mapLocales: [
        const MapLocale(
          'en',
          AppLocaleTranslate.EN,
          countryCode: 'US',
          fontFamily: 'Font EN',
        ),
        const MapLocale(
          'km',
          AppLocaleTranslate.KM,
          countryCode: 'KH',
          fontFamily: 'Font KM',
        ),
        const MapLocale(
          'ja',
          AppLocaleTranslate.JA,
          countryCode: 'JP',
          fontFamily: 'Font JA',
        ),
        const MapLocale(
          'vi',
          AppLocaleTranslate.VI,
          countryCode: 'VI',
          fontFamily: 'Font JA',
        ),
      ],
      // Default language khi app khởi động
      initLanguageCode: 'en',
    );
    // Listener khi user thay đổi language
    // Gọi _onTranslatedLanguage để rebuild UI với translations mới
    _localization.onTranslatedLanguage = _onTranslatedLanguage;
  }

  /// _onTranslatedLanguage - Callback khi language thay đổi
  ///
  /// Phương thức này được gọi khi user chọn language khác.
  /// setState() sẽ trigger rebuild toàn bộ MyApp widget tree,
  /// dẫn tới tất cả text string được dịch sang language mới.
  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector wrapper bắt tap event để dismiss keyboard
    // Khi user tap bất kỳ nơi nào ngoài TextField, keyboard sẽ ẩn
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard khi tap
        FocusScope.of(context).unfocus();
      },
      // MultiBlocProvider cung cấp tất cả global Cubits
      // Các Cubits này accessible từ bất kỳ widget nào trong subtree
      child: MultiBlocProvider(
        providers: [
          // SettingThemeCubit - Quản lý theme setting (dark/light mode)
          // Đọc từ SharedPreferences, cho phép user switch theme
          BlocProvider(
            create: (context) => SettingThemeCubit(),
          ),
          // BaseLoadingCubit - Global loading state
          // Khi true, hiển thị loading overlay trên top của app
          BlocProvider(
            create: (context) => BaseLoadingCubit(),
          ),
          // SearchCubit - Global search functionality
          // Cho phép search feature từ bất kỳ screen nào
          BlocProvider(
            create: (context) => SearchCubit(),
          ),
        ],
        // BlocBuilder lắng nghe SettingThemeCubit state changes
        // Rebuild MaterialApp khi user thay đổi theme (dark/light mode)
        child: BlocBuilder<SettingThemeCubit, SettingThemeState>(
          builder: (context, state) {
            // Khởi tạo device dimension (screen size, dpi, etc.)
            // Sử dụng này trong AppThemes để responsive design
            DeviceDimension().initValue(context);

            // MaterialApp - root của Flutter widget tree
            // Cấu hình tất cả app-level settings
            return MaterialApp(
              // navigatorKey cho phép navigation từ bất kỳ nơi nào trong app
              // (thậm chí từ background services)
              navigatorKey: UtilsHelper.navigatorKey,
              // Áp dụng theme light dựa trên SettingThemeCubit state
              // Khi state thay đổi, MaterialApp rebuild với theme mới
              theme: AppThemes.primaryTheme(context, state),
              // Áp dụng theme dark
              darkTheme: AppThemes.primaryTheme(context, state),
              // Ẩn debug banner trên góc phải
              debugShowCheckedModeBanner: false,
              // Home screen - Stack 2 layers:
              // 1. AppRoot (main app structure)
              // 2. Keyboard visibility overlay (darken screen khi keyboard show)
              home: AppRoot(),
              // Route generator - cấu hình tất cả named routes
              // Khi navigate(routeName), Routes.generateRoute sẽ return đúng screen
              onGenerateRoute: Routes.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
