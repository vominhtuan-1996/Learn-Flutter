// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/modules/material/component/metarial_dialog/dialog_utils.dart';

/// Flutter code sample for [CupertinoDatePicker].

class DatePickerScreen extends StatelessWidget {
  const DatePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DatePickerExample();
  }
}

class DatePickerExample extends StatefulWidget {
  const DatePickerExample({super.key});

  @override
  State<DatePickerExample> createState() => _DatePickerExampleState();
}

class _DatePickerExampleState extends State<DatePickerExample> {
  DateTime date = DateTime.now();
  DateTime time = DateTime(2016, 5, 10, 22, 35);
  DateTime dateTime = DateTime(2016, 8, 3, 17, 45);

  // This function displays a CupertinoModalPopup with a reasonable fixed height
  // which hosts CupertinoDatePicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: CupertinoNavigationBar(
        middle: Text('CupertinoDatePicker Sample'),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: 22.0,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _DatePickerItem(
                children: <Widget>[
                  const Text('Date'),
                  CupertinoButton(
                    // Display a CupertinoDatePicker in date picker mode.
                    onPressed: () {
                      DialogUtils.showActionSheet(
                        context: context,
                        // content: IconAnimationWidget(
                        //   isRotate: true,
                        // )
                        content: SizedBox(
                          height: 300,
                          child: CupertinoDatePicker(
                            minimumYear: DateTime.now().year - 7,
                            maximumDate: DateTime.now(),
                            initialDateTime: date,
                            mode: CupertinoDatePickerMode.date,
                            dateOrder: DatePickerDateOrder.dmy,
                            use24hFormat: true,
                            // This shows day of week alongside day of month
                            // This is called when the user changes the date.
                            onDateTimeChanged: (DateTime newDate) {
                              date = newDate;
                            },
                          ),
                        ),
                        actions: [
                          CupertinoActionSheetAction(
                            isDefaultAction: true,
                            onPressed: () {
                              DialogUtils.dismissPopup(context);
                              setState(() {});
                            },
                            child: Text('Đồng ý'),
                          ),
                        ],
                      );
                    },
                    // In this example, the date is formatted manually. You can
                    // use the intl package to format the value based on the
                    // user's locale settings.
                    child: Text(
                      '${date.day} - ${date.month} - ${date.year}',
                      style: context.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              _DatePickerItem(
                children: <Widget>[
                  const Text('Time'),
                  CupertinoButton(
                    // Display a CupertinoDatePicker in time picker mode.
                    onPressed: () {
                      DialogUtils.showActionSheet(
                        context: context,
                        // content: IconAnimationWidget(
                        //   isRotate: true,
                        // )
                        content: SizedBox(
                          height: 300,
                          child: CupertinoDatePicker(
                            minimumYear: DateTime.now().year - 7,
                            maximumDate: DateTime.now(),
                            initialDateTime: time,
                            mode: CupertinoDatePickerMode.time,
                            dateOrder: DatePickerDateOrder.dmy,
                            use24hFormat: true,
                            // This shows day of week alongside day of month
                            // This is called when the user changes the date.
                            onDateTimeChanged: (DateTime newDate) {
                              time = newDate;
                            },
                          ),
                        ),
                        actions: [
                          CupertinoActionSheetAction(
                            isDefaultAction: true,
                            onPressed: () {
                              DialogUtils.dismissPopup(context);
                              setState(() {});
                            },
                            child: Text('Đồng ý'),
                          ),
                        ],
                      );
                    },
                    child: Text(
                      '${time.hour}:${time.minute}',
                      style: const TextStyle(
                        fontSize: 22.0,
                      ),
                    ),
                  ),
                ],
              ),
              _DatePickerItem(
                children: <Widget>[
                  const Text('DateTime'),
                  CupertinoButton(
                    // Display a CupertinoDatePicker in dateTime picker mode.
                    onPressed: () {
                      DialogUtils.showActionSheet(
                        context: context,
                        // content: IconAnimationWidget(
                        //   isRotate: true,
                        // )
                        content: SizedBox(
                          height: 300,
                          child: CupertinoDatePicker(
                            initialDateTime: dateTime,
                            use24hFormat: true,
                            mode: CupertinoDatePickerMode.dateAndTime,
                            // This shows day of week alongside day of month
                            // This is called when the user changes the date.
                            onDateTimeChanged: (DateTime newDate) {
                              dateTime = newDate;
                            },
                          ),
                        ),
                        actions: [
                          CupertinoActionSheetAction(
                            isDefaultAction: true,
                            onPressed: () {
                              DialogUtils.dismissPopup(context);
                              setState(() {});
                            },
                            child: Text('Đồng ý'),
                          ),
                        ],
                      );
                    },
                    child: Text(
                      '${dateTime.month}-${dateTime.day}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}',
                      style: const TextStyle(
                        fontSize: 22.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// This class simply decorates a row of widgets.
class _DatePickerItem extends StatelessWidget {
  const _DatePickerItem({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoColors.inactiveGray,
            width: 0.0,
          ),
          bottom: BorderSide(
            color: CupertinoColors.inactiveGray,
            width: 0.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}
