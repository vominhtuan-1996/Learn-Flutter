import 'package:flutter/material.dart';
import 'package:learnflutter/utils_helper/datetime_utils.dart';
import 'droplet_refresh_control.dart';

void main() async {
  final tamperDetector = ClockTamperDetector()..startMonitoring();

// Sau vài phút, check:
  if (tamperDetector.isTamperedOffline()) {
    print("⚠️ Phát hiện người dùng chỉnh giờ thủ công!");
  }

// Hoặc check online:
  final onlineTampered = await tamperDetector.isTamperedOnline();
  if (onlineTampered) {
    print("⚠️ Giờ hệ thống lệch nhiều so với NTP!");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Droplet Refresh Control',
        home: Scaffold(
          body: WaterDropRefresh(
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 2));
            },
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: 30,
              itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
            ),
          ),
        ));
  }
}
