// ignore_for_file: prefer_interpolation_to_compose_strings, unused_import, prefer_const_constructors, unnecessary_null_comparison, constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/https/MBMHttpHelper.dart';
import 'package:learnflutter/modules/menu/model/model_menu.dart';
import 'package:learnflutter/core/notification_center/notification_center.dart';
import 'package:learnflutter/main.dart';
import 'package:notification_center/notification_center.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

Size size = WidgetsBinding.instance.window.physicalSize;
double widthScreen = size.width;
double heightScreen = size.height;
const String keysaveCache_childMenus = 'childMenus';

enum TypeImage { png, jpg, jpeg }

enum IconTabbarMoBiMap {
  ic_tabbar_tool_selected,
  ic_tabbar_tool_unselected,
  ic_tabbar_search_selected,
  ic_tabbar_search_unselected,
  ic_tabbar_map_selected,
  ic_tabbar_map_unselected,
  ic_tabbar_user_selected,
  ic_tabbar_user_unselected,
  ic_tabbar_scanQRCode
}

String loadImageWithImageName(String imageName, TypeImage typeImage) {
  return 'assets/images/' + imageName + '.' + typeImage.name.toString();
}

void dismissKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

TextStyle textStyleManrope(Color color, double fontSize, FontWeight fontWe) {
  return TextStyle(
    fontFamily: GoogleFonts.manrope().fontFamily,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWe,
  );
}

class AppConfig {
  static Future init(VoidCallback callback) async {
    WidgetsFlutterBinding.ensureInitialized();
    await SharedPreferenceUtils.init();
    NotificationCenter().subscribe("updateCounter", _updateCounter);
    Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: true, // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
    callback();
  }
}

void _updateCounter() {
  NotificationService().showNotification(title: 'Sample title', body: DateTime.now().toString());
  postdataTelegram('updateCounter_${DateTime.now().toString()}');
  // Timer.periodic(const Duration(minutes: 1), (timer) {
  //   print(DateTime.now().toString());
  //   NotificationCenter().notify('updateCounter');
  // });
  Timer(
    Duration(minutes: 5),
    () {
      // print(DateTime.now().toString());
      // NotificationCenter().notify('updateCounter');
      Workmanager().registerOneOffTask(
        simpleTaskKey,
        simpleTaskKey,
        inputData: <String, dynamic>{
          'int': 1,
          'bool': true,
          'double': 1.0,
          'string': 'string',
          'array': [1, 2, 3],
        },
      );
    },
  );
}

class SharedPreferenceUtils {
  static late SharedPreferences prefs;

  static init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<Future<bool>?> putObjectList(String key, List<Object> list) async {
    if (prefs == null) return null;
    List<String> _dataList = list.map((value) {
      return json.encode(value);
    }).toList();
    return prefs.setStringList(key, _dataList);
  }

  static List<T>? getObjList<T>(String key, T f(Map v), {List<T> defValue = const []}) {
    if (prefs == null) return null;
    List<Map>? dataList = getObjectList(key);
    List<T> list = dataList!.map((value) {
      return f(value);
    }).toList();
    return list;
  }

  static List<Map>? getObjectList(String key) {
    if (prefs == null) return null;
    List<String>? dataList = prefs.getStringList(key);
    if (dataList == null) {
      return [];
    }
    return dataList?.map((value) {
      Map _dataMap = json.decode(value);
      return _dataMap;
    }).toList();
  }
}

class TimeUtils {
  TimeUtils._();

  /// dateTime == null get Timestamp current
  static int timestamp({DateTime? dateTime}) {
    dateTime ??= DateTime.now();
    return (dateTime.millisecondsSinceEpoch / 1000).round();
  }
}
