// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings, non_constant_identifier_names

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

class IsolateWidget extends StatefulWidget {
  const IsolateWidget({super.key});

  @override
  State<IsolateWidget> createState() => _IsolateWidgetState();

  void isolatesFunction(int num) {
    Timer(const Duration(milliseconds: 100), () {
      int count = 0;
      for (int i = 0; i < num; i++) {
        count++;
        print('isolate ' + count.toString());
      }
    });
  }
}

class _IsolateWidgetState extends State<IsolateWidget> {
  @override
  void initState() {
    Isolate.spawn(
      (message) {
        // print(message);
      },
      widget.isolatesFunction(1000),
    );
    for (int i = 0; i < 1000; i++) {
      print('main theard ' + i.toString());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          child: const Text('Check running isolates'),
          onPressed: () async {
            final isolates = await FlutterIsolate.runningIsolates;
            await showDialog(
                builder: (ctx) {
                  return Center(
                      child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(5),
                          child: Column(
                              children: isolates.map((i) => Text(i)).cast<Widget>().toList() +
                                  [
                                    ElevatedButton(
                                        child: const Text("Close"),
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                        })
                                  ])));
                },
                context: context);
          },
        ),
        ElevatedButton(
          child: const Text('Check running '),
          onPressed: () async {
            Isolate.spawn(
              (message) {
                // print(message);
              },
              widget.isolatesFunction(3000),
            );
          },
        ),
      ],
    );
  }
}
