// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sized_box_for_whitespace, avoid_print, unused_local_variable, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, unused_import, non_constant_identifier_names, use_full_hex_values_for_flutter_colors, override_on_non_overriding_member, unused_element

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:learnflutter/Helpper/defineConstraint.dart';
import 'package:learnflutter/Helpper/flutter_section_table_view.dart';
import 'package:learnflutter/Https/MBMHttpHelper.dart';
import 'package:learnflutter/Nested/nested_scroll_screen.dart';
import 'package:learnflutter/Nitification_Center/notification_center.dart';
import 'package:learnflutter/TabbarCustom/TabbarMobiMapCustom.dart';
import 'package:learnflutter/app_theme.dart';
import 'package:learnflutter/base_loading_screen/page_loading_screen.dart';
import 'package:learnflutter/bmprogresshud/bmprogresshud_screen.dart';
import 'package:learnflutter/camera/camera_screen.dart';
import 'package:learnflutter/courasel/courasel_screen.dart';
import 'package:learnflutter/date_picker/calender.dart';
import 'package:learnflutter/date_picker/date_picker.dart';
import 'package:learnflutter/date_picker/date_time_input.dart';
import 'package:learnflutter/datetime_picker/datetime_picker_screen.dart';
import 'package:learnflutter/draggbel_scroll/draggel_scroll_screen.dart';
import 'package:learnflutter/hero_animation/hero_animation_screen.dart';
import 'package:learnflutter/hive_demo/model/person.dart';
import 'package:learnflutter/hive_demo/screen/info_screen.dart';
import 'package:learnflutter/interractiveView/intertiveview_screen.dart';
import 'package:learnflutter/isolate/isolate_screen.dart';
import 'package:learnflutter/matix/matix_screen.dart';
import 'package:learnflutter/open_file/open_file_screen.dart';
import 'package:learnflutter/path_provider/path_provider_screen.dart';
import 'package:learnflutter/popover/popover_scren.dart';
import 'package:learnflutter/progress_hub/progress_hud_screen.dart';
import 'package:learnflutter/shimmer/shimmer_widget.dart';
import 'package:learnflutter/snack_bar/snack_bar_screen.dart';
import 'package:learnflutter/src/lib/l10n/tie_picker_localizations.dart';
import 'package:learnflutter/test_screen/test_screen.dart';
import 'package:learnflutter/theme/page_theme_screen.dart';
import 'package:learnflutter/tie_picker/tie_picker_screen.dart';
import 'package:learnflutter/web_browser/web_browser_screen.dart';
import 'package:notification_center/notification_center.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Menu/MenuController.dart';
import 'package:workmanager/workmanager.dart';
import 'package:draggable_fab/draggable_fab.dart';

void main() {
  AppConfig.init(
    () async {
      // Initialize hive
      await Hive.initFlutter();
      // Registering the adapter
      Hive.registerAdapter(PersonAdapter());
      // Opening the box
      await Hive.openBox('peopleBox');
      // Workmanager().registerOneOffTask(
      //   "task-identifier",
      //   simpleTaskKey,
      //   constraints: Constraints(
      //     // connected or metered mark the task as requiring internet
      //     networkType: NetworkType.connected,
      //     // require external power
      //     // requiresCharging: true,
      //   ),
      // );
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
    return MaterialApp(
      theme: AppThemes.primaryTheme,
      locale: Locale('vi'),
      title: 'dasdasdasda',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        TiePickerLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('vi', 'VN'),
        ...TiePickerLocalizations.supportedLocales,
      ],
      initialRoute: '/test_screen',
      // onGenerateRoute: Routes.generateRoute,
      // initialRoute: Routes.splash,
      routes: {
        '/test_screen': (ctx) => TestScreen(),
        '/courasel_screen': (ctx) => CarouselDemoHome(),
        '/nested_scroll_screen': (ctx) => NestedScrollViewExample(),
        '/basic': (ctx) => BasicDemo(),
        '/nocenter': (ctx) => NoCenterDemo(),
        '/image': (ctx) => ImageSliderDemo(),
        '/complicated': (ctx) => ComplicatedImageDemo(),
        '/enlarge': (ctx) => EnlargeStrategyDemo(),
        '/manual': (ctx) => ManuallyControlledSlider(),
        '/noloop': (ctx) => NoonLoopingDemo(),
        '/vertical': (ctx) => VerticalSliderDemo(),
        '/fullscreen': (ctx) => FullscreenSliderDemo(),
        '/ondemand': (ctx) => OnDemandCarouselDemo(),
        '/indicator': (ctx) => CarouselWithIndicatorDemo(),
        '/prefetch': (ctx) => PrefetchImageDemo(),
        '/reason': (ctx) => CarouselChangeReasonDemo(),
        '/position': (ctx) => KeepPageviewPositionDemo(),
        '/multiple': (ctx) => MultipleItemDemo(),
        '/zoom': (ctx) => EnlargeStrategyZoomDemo(),
        '/MenuController': (ctx) => Menu_Controller(),
        '/bmprogresshud_screen': (ctx) => MBProgressHUD(),
        '/intertiveview_screen': (ctx) => InteractiveViewerExample(),
        '/popover_scren': (ctx) => PopoverExample(),
        '/datetime_picker_screen': (ctx) => DatePickerScreen(),
        '/date_picker': (ctx) => DatePickerScreenExample(),
        '/date_time_input': (context) => DateTimeInputScreen(),
        '/calender': (context) => CalenderScreen(title: 'Title'),
        '/tie_picker_screen': (context) => TiePickerScreen(),
        '/progress_hud_screen': (context) => ProgressHubScreenTest(),
        '/shimmer_widget': (context) => ExampleUiLoadingAnimation(),
        '/matix_screen': (context) => MatrixScreen(),
        '/hero_animation_screen': (context) => Page1(),
        '/info_screen': (context) => InfoScreen(),
        '/snack_bar_screen': (ctx) => AweseomSnackBarExample(),
        '/page_loading_screen': (ctx) => PageLoadingScreen(
              message: 'Đang cập nhật dữ liệu...',
            ),
        '/camera_screen': (context) => CameraExampleHome(),
        '/open_file_screen': (context) => OpenFileScreen(),
        '/path_provider_screen': (context) => PathProviderScreen(title: 'PathProviderScreen'),
        '/web_browser_screen': (context) => WebViewExample(),
        '/draggel_scroll_screen': (context) => DraggbleScrollScreen(),
        '/page_theme_screen': (context) => TestThemeScreen()
      },
    );
  }
}
