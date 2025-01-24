import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/main.dart';
import 'package:notification_center/notification_center.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundServiceScreen extends StatefulWidget {
  const BackgroundServiceScreen({super.key});

  @override
  State<BackgroundServiceScreen> createState() => _BackgroundServiceScreenState();
}

class _BackgroundServiceScreenState extends State<BackgroundServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              child: const Text("notification Center"),
              onPressed: () {
                print("1");
                NotificationCenter().notify('updateCounter');
              },
            ),
            Text(
              "Plugin initialization",
              style: context.textTheme.bodyMedium,
            ),
            ElevatedButton(
              child: const Text("Start the Flutter background service"),
              onPressed: () {
                Workmanager().initialize(
                  callbackDispatcher,
                  isInDebugMode: true,
                );
              },
            ),
            const SizedBox(height: 16),

            //This task runs once.
            //Most likely this will trigger immediately
            ElevatedButton(
              child: const Text("Register OneOff Task"),
              onPressed: () {
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
            ),
            ElevatedButton(
              child: const Text("Register rescheduled Task"),
              onPressed: () {
                Workmanager().registerOneOffTask(
                  rescheduledTaskKey,
                  rescheduledTaskKey,
                  inputData: <String, dynamic>{
                    'key': Random().nextInt(64000),
                  },
                );
              },
            ),
            ElevatedButton(
              child: const Text("Register failed Task"),
              onPressed: () {
                Workmanager().registerOneOffTask(
                  failedTaskKey,
                  failedTaskKey,
                );
              },
            ),
            //This task runs once
            //This wait at least 10 seconds before running
            ElevatedButton(
                child: const Text("Register Delayed OneOff Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    simpleDelayedTask,
                    simpleDelayedTask,
                    initialDelay: const Duration(seconds: 10),
                  );
                }),
            const SizedBox(height: 8),
            //This task runs periodically
            //It will wait at least 10 seconds before its first launch
            //Since we have not provided a frequency it will be the default 15 minutes
            ElevatedButton(
                onPressed: Platform.isAndroid
                    ? () {
                        Workmanager().registerPeriodicTask(
                          simplePeriodicTask,
                          simplePeriodicTask,
                          initialDelay: const Duration(seconds: 10),
                        );
                      }
                    : null,
                child: const Text("Register Periodic Task (Android)")),
            //This task runs periodically
            //It will run about every hour
            ElevatedButton(
                onPressed: Platform.isAndroid
                    ? () {
                        Workmanager().registerPeriodicTask(
                          simplePeriodicTask,
                          simplePeriodic1HourTask,
                          frequency: const Duration(hours: 1),
                        );
                      }
                    : null,
                child: const Text("Register 1 hour Periodic Task (Android)")),
            const SizedBox(height: 16),
            Text(
              "Task cancellation",
              style: context.textTheme.bodyMedium,
            ),
            ElevatedButton(
              child: const Text("Cancel All"),
              onPressed: () async {
                await Workmanager().cancelAll();
                print('Cancel all tasks completed');
              },
            ),
          ],
        ),
      ),
    );
  }
}
