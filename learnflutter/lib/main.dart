// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:learnflutter/app/app_local_translate.dart';
import 'package:learnflutter/component/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/component/search_bar/cubit/search_bar_cubit.dart';
import 'package:learnflutter/db/hive_demo/model/person.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/constraint/define_constraint.dart';
import 'package:learnflutter/app/app_theme.dart';
import 'package:learnflutter/component/routes/route.dart';
import 'package:learnflutter/modules/setting/cubit/setting_cubit.dart';
import 'package:learnflutter/modules/setting/state/setting_state.dart';
import 'package:learnflutter/component/shimmer/shimmer_utils/shimmer_utils.dart';
import 'package:learnflutter/component/shimmer/widget/shimmer_widget.dart';
import 'package:learnflutter/modules/test_screen/test_screen.dart';
import 'package:notification_center/notification_center.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
// import 'package:shorebird/shorebird.dart';

void main() {
  AppConfig.init(
    () async {
      // Initialize hive
      await Hive.initFlutter();
      // Registering the adapte
      Hive.registerAdapter(PersonAdapter());
      // Opening the box
      await Hive.openBox('peopleBox');
      // await ShorebirdSdk.initialize(
      //   appId: 'YOUR_APP_ID', // Thay thế bằng App ID của bạn
      // );
      runApp(const MyApp());
    },
  );
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   MyApp setState() => MyApp();
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       // home: MenuController(),
//       home: TabbarMobiMapCustom(),
//     );
//   }
// }

const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask = "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const simplePeriodic1HourTask = "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";

@pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     switch (task) {
//       case Workmanager.iOSBackgroundTask:
//         stderr.writeln("The iOS background fetch was triggered");
//         break;
//     }
//     bool success = true;
//     return Future.value(success);
//   });
// }
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        print("$simpleTaskKey was executed. inputData = $inputData");
        NotificationCenter().notify('updateCounter');
        break;
      case rescheduledTaskKey:
        final key = inputData!['key']!;
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('unique-$key')) {
          print('has been running before, task is successful');
          return true;
        } else {
          await prefs.setBool('unique-$key', true);
          print('reschedule task');
          return false;
        }
      case failedTaskKey:
        print('failed task');
        return Future.error('failed');
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed");
        break;
      case simplePeriodic1HourTask:
        print("$simplePeriodic1HourTask was executed");
        break;
      case Workmanager.iOSBackgroundTask:
        stderr.writeln("The iOS background fetch was triggered");
        // Directory? tempDir = await getTemporaryDirectory();
        // String? tempPath = tempDir.path;
        // print("You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath");
        break;
    }
    bool success = true;
    return Future.value(true);
  });
}

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     switch (task) {
//       case Workmanager.iOSBackgroundTask:
//         stderr.writeln("The iOS background fetch was triggered");
//         break;
//     }
//     bool success = true;
//     return Future.value(success);
//   });
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final updater = ShorebirdCodePush();
  final FlutterLocalization _localization = FlutterLocalization.instance;
  @override
  @override
  void initState() {
    _localization.init(
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
      initLanguageCode: 'en',
    );
    _localization.onTranslatedLanguage = _onTranslatedLanguage;
    super.initState();
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Shimmer(
        linearGradient: ShimmerUtils.shimmerGradient,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => SettingThemeCubit(),
            ),
            BlocProvider(
              create: (context) => BaseLoadingCubit(),
            ),
            BlocProvider(
              create: (context) => SearchCubit(),
            ),
          ],
          child: BlocBuilder<SettingThemeCubit, SettingThemeState>(
            builder: (context, state) {
              DeviceDimension().initValue(context);
              return MaterialApp(
                supportedLocales: _localization.supportedLocales,
                localizationsDelegates: _localization.localizationsDelegates,
                theme: AppThemes.primaryTheme(context, state),
                // locale: const Locale('vi'),
                debugShowCheckedModeBanner: false,
                home: FlutterSplashScreen.gif(
                  duration: const Duration(seconds: 8),
                  backgroundColor: Colors.white,
                  onInit: () async {
                    debugPrint("On Init");
                  },
                  onEnd: () {
                    debugPrint("On End");
                  },
                  gifPath: 'assets/images/laucher_mobimap_rii_2.gif',
                  nextScreen: const TestScreen(),
                  gifWidth: context.mediaQuery.size.width,
                  gifHeight: context.mediaQuery.size.height,
                ),
                // supportedLocales: [
                //   Locale('vi', 'VN'),
                //   ...TiePickerLocalizations.supportedLocales,
                // ],
                onGenerateRoute: Routes.generateRoute,
                // initialRoute: Routes.testScreen,
              );
            },
          ),
        ),
      ),
    );
  }
}
