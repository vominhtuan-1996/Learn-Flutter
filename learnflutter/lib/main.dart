// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sized_box_for_whitespace, avoid_print, unused_local_variable, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, unused_import, non_constant_identifier_names, use_full_hex_values_for_flutter_colors, override_on_non_overriding_member, unused_element

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/core/global/var_global.dart';
import 'package:learnflutter/helpper/define_constraint.dart';
import 'package:learnflutter/core/https/MBMHttpHelper.dart';
import 'package:learnflutter/helpper/hive_demo/model/person.dart';
import 'package:learnflutter/modules/nested/nested_scroll_screen.dart';
import 'package:learnflutter/core/notification_center/notification_center.dart';
import 'package:learnflutter/helpper/tabbar_custom/tabbar_custom.dart';
import 'package:learnflutter/core/app_theme.dart';
import 'package:learnflutter/base_loading_screen/page_loading_screen.dart';
import 'package:learnflutter/modules/bmprogresshud/bmprogresshud_screen.dart';
import 'package:learnflutter/modules/camera/camera_screen.dart';
import 'package:learnflutter/core/routes/route.dart';
import 'package:learnflutter/modules/courasel/courasel_screen.dart';
import 'package:learnflutter/modules/date_picker/calender.dart';
import 'package:learnflutter/modules/date_picker/date_picker.dart';
import 'package:learnflutter/modules/date_picker/date_time_input.dart';
import 'package:learnflutter/modules/datetime_picker/datetime_picker_screen.dart';
import 'package:learnflutter/modules/draggbel_scroll/draggel_scroll_screen.dart';
import 'package:learnflutter/helpper/hero_animation/hero_animation_screen.dart';
import 'package:learnflutter/modules/interractive_view/intertiveview_screen.dart';
import 'package:learnflutter/modules/isolate/isolate_screen.dart';
import 'package:learnflutter/modules/matix/matix_screen.dart';
import 'package:learnflutter/modules/open_file/open_file_screen.dart';
import 'package:learnflutter/modules/path_provider/path_provider_screen.dart';
import 'package:learnflutter/modules/popover/popover_scren.dart';
import 'package:learnflutter/modules/progress_hub/progress_hud_screen.dart';
import 'package:learnflutter/modules/setting/cubit/setting_cubit.dart';
import 'package:learnflutter/modules/setting/state/setting_state.dart';
import 'package:learnflutter/modules/shimmer/shimmer_widget.dart';
import 'package:learnflutter/helpper/snack_bar/snack_bar_screen.dart';
import 'package:learnflutter/src/lib/l10n/tie_picker_localizations.dart';
import 'package:learnflutter/test_screen/test_screen.dart';
import 'package:learnflutter/theme/page_theme_screen.dart';
import 'package:learnflutter/modules/tie_picker/tie_picker_screen.dart';
import 'package:learnflutter/modules/web_browser/web_browser_screen.dart';
import 'package:notification_center/notification_center.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'modules/menu/menu_controller.dart';
import 'package:workmanager/workmanager.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/foundation.dart';

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
    // textScale = context.textScale;
    return BlocProvider(
      create: (context) => SettingThemeCubit(),
      child: BlocBuilder<SettingThemeCubit, SettingThemeState>(
        builder: (context, state) {
          DeviceDimension().initValue(context);
          return MaterialApp(
            theme: AppThemes.primaryTheme(context, state),
            locale: Locale('vi'),
            title: 'dasdasdasda',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              // TiePickerLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('vi'),
              Locale('en'),
            ],

            // supportedLocales: [
            //   Locale('vi', 'VN'),
            //   ...TiePickerLocalizations.supportedLocales,
            // ],
            onGenerateRoute: Routes.generateRoute,
            initialRoute: Routes.testScreen,
          );
        },
      ),
    );
  }
}
