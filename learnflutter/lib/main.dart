import 'dart:async';
import 'dart:io';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:learnflutter/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/helpper/define_constraint.dart';
import 'package:learnflutter/helpper/hive_demo/model/person.dart';
import 'package:learnflutter/core/app_theme.dart';
import 'package:learnflutter/core/routes/route.dart';
import 'package:learnflutter/modules/setting/cubit/setting_cubit.dart';
import 'package:learnflutter/modules/setting/state/setting_state.dart';
import 'package:learnflutter/modules/shimmer/shimmer_utils/shimmer_utils.dart';
import 'package:learnflutter/modules/shimmer/widget/shimmer_widget.dart';
import 'package:learnflutter/test_screen/test_screen.dart';
import 'package:notification_center/notification_center.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  AppConfig.init(
    () async {
      // Initialize hive
      await Hive.initFlutter();
      // Registering the adapter
      Hive.registerAdapter(PersonAdapter());
      // Opening the box
      await Hive.openBox('peopleBox');
      runApp(MyApp());
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
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Shimmer(
      linearGradient: ShimmerUtils.shimmerGradient,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SettingThemeCubit(),
          ),
          BlocProvider(
            create: (context) => BaseLoadingCubit(),
          ),
        ],
        child: BlocBuilder<SettingThemeCubit, SettingThemeState>(
          builder: (context, state) {
            DeviceDimension().initValue(context);
            return MaterialApp(
              theme: AppThemes.primaryTheme(context, state),
              locale: Locale('vi'),
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                // TiePickerLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('vi'),
                Locale('en'),
              ],
              home: FlutterSplashScreen.gif(
                duration: Duration(seconds: 5),
                backgroundColor: Colors.white,
                onInit: () {
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
    );
  }
}
