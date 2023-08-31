import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/src/lib/tie_picker.dart';

class TiePickerScreen extends StatefulWidget {
  const TiePickerScreen({super.key});

  @override
  State<TiePickerScreen> createState() => _TiePickerScreenState();
}

class _TiePickerScreenState extends State<TiePickerScreen> {
  DateTime? date = DateTime(2023, 8, 15);
  void openDatePicker() async {
    date = await ModalPicker.datePicker(
      context: context,
      date: date,
      mode: CalendarMode.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tie picker')),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CupertinoButton(
                onPressed: openDatePicker,
                child: const Text('Open date picker'),
              ),
              CupertinoButton(
                onPressed: openModalPicker,
                child: const Text('Open Modal picker'),
              ),
              CupertinoButton(
                onPressed: openMiniPicker,
                child: const Text('Open Mini picker'),
              ),
              CupertinoButton(
                onPressed: openTimePicker,
                child: const Text('Open time picker'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? item = 0;
  void openModalPicker() async {
    final result = await ModalPicker.modalPick<int>(
      context: context,
      label: 'Modal pick',
      list: List.generate(50, (index) => index),
      item: item,
      toText: (value) => 'Option $value',
    );
    if (result == null) return;
    item = result;
  }

  MyClass? data;

  void openMiniPicker() async {
    final result = await ModalPicker.miniPick<MyClass>(
      context: context,
      label: 'Mini pick',
      list: List.generate(
        50,
        (index) => MyClass(id: index, value: "Option $index"),
      ),
      item: data,
      toText: (value) => 'Option $value',
    );
    if (result == null) return;
    data = result;
  }

  void openTimePicker() async {
    date = await ModalPicker.timePicker(
      context: context,
      date: date,
      use24hFormat: false,
    );
  }
}

class MyClass {
  final int id;
  final String value;

  MyClass({
    required this.id,
    required this.value,
  });

  @override
  bool operator ==(covariant MyClass other) {
    if (identical(this, other)) return true;

    return other.id == id && other.value == value;
  }

  @override
  int get hashCode => id.hashCode ^ value.hashCode;
}
