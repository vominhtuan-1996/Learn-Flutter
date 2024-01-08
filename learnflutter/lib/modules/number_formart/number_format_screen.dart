import 'dart:math';

import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/src/extension.dart';

class NumberFormatterScreen extends StatefulWidget {
  const NumberFormatterScreen({super.key});
  @override
  State<NumberFormatterScreen> createState() => NumberFormatterScreenState();
}

class NumberFormatterScreenState extends State<NumberFormatterScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  dynamic customRound(number, place) {
    var valueForPlace = pow(1, place);
    return (number * valueForPlace).round() / valueForPlace;
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
        appBar: AppBar(
          title: Text('Number Formatter'),
        ),
        isLoading: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  print(customRound(value.toDouble, 2));
                },
                inputFormatters: [],
              ),
              ElevatedButton(onPressed: () {}, child: Text('data')),
            ],
          ),
        ));
  }
}
