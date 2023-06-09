// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sized_box_for_whitespace, avoid_print, unused_local_variable, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, unused_import, non_constant_identifier_names, use_full_hex_values_for_flutter_colors, override_on_non_overriding_member, unused_element

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/Helpper/defineConstraint.dart';
import 'package:learnflutter/Helpper/flutter_section_table_view.dart';
import 'package:learnflutter/Https/MBMHttpHelper.dart';
import 'package:learnflutter/Nitification_Center/notification_center.dart';
import 'package:learnflutter/TabbarCustom/TabbarMobiMapCustom.dart';
import 'package:notification_center/notification_center.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Menu/MenuController.dart';
import 'package:workmanager/workmanager.dart';
import 'package:draggable_fab/draggable_fab.dart';

void main() {
  AppConfig.init(() {
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
  });
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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter WorkManager Example"),
        ),
        floatingActionButton: DraggableFab(
          child: FloatingActionButton(
            onPressed: () {
              //action after pressing this button
            },
            child: Icon(Icons.add),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
            Container(
              width: 90,
              height: 90,
              color: Colors.green,
            ),
            Draggable(
              onDragEnd: (details) {
                print(details.offset);
              },
              feedback: context.widget,
              child: Container(
                color: Colors.blue,
                width: 60,
                height: 60,
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
