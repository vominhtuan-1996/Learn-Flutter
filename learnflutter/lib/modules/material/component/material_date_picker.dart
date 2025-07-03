import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/tap_builder/tap_animated_button_builder.dart';
import 'package:learnflutter/utils_helper/dialog_utils.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';

class MaterialDatePicker extends StatefulWidget {
  const MaterialDatePicker({super.key, this.restorationId, required this.data});
  final RouterMaterialModel data;

  final String? restorationId;

  @override
  State<MaterialDatePicker> createState() => _MaterialDatePickerState();
}

/// RestorationProperty objects can be used because of RestorationMixin.
class _MaterialDatePickerState extends State<MaterialDatePicker>
    with RestorationMixin {
  // In this example, the restoration ID for the mixin is passed in through
  // the [StatefulWidget]'s constructor.
  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(1970),
          lastDate: DateTime(2050),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            action: SnackBarAction(
              label: 'label',
              onPressed: () {},
            ),
            content: Text(
              '${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}',
              style: context.textTheme.bodyMedium?.copyWith(color: Colors.red),
            )));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialScreenDetail(
      title: widget.data.title,
      description: widget.data.description,
      contentWidget: Column(
        children: [
          OutlinedButton(
            onPressed: () {
              _restorableDatePickerRouteFuture.present();
            },
            child: const Text('Open Date Picker'),
          ),
          AnimatedTapButtonBuilder(
            background: context.colorScheme.primaryContainer,
            child: Text('Open Date Picker '),
            onTap: () {
              DialogUtils.showActionSheet(
                  context: context,
                  title: 'Date Picker',
                  content: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: context.mediaQuery.size.height / 2,
                      child: CupertinoDatePicker(
                        initialDateTime: _selectedDate.value,
                        mode: CupertinoDatePickerMode.date,
                        use24hFormat: true,
                        // This shows day of week alongside day of month
                        showDayOfWeek: false,

                        maximumDate: DateTime.now(),
                        minimumDate: DateTime.now()
                            .subtract(const Duration(days: 365 * 7)),

                        // This is called when the user changes the date.
                        onDateTimeChanged: (DateTime newDate) {
                          _selectedDate.value = newDate;
                        },
                      ),
                    ),
                  ),
                  actions: [
                    CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: const Text('Đồng ý '),
                    ),
                  ]);
              // showCupertinoModalPopup<void>(
              //   context: context,
              //   builder: (BuildContext context) => Container(
              //     height: context.mediaQuery.size.height / 2,
              //     padding: const EdgeInsets.only(top: 6.0),
              //     // The Bottom margin is provided to align the popup above the system
              //     // navigation bar.
              //     margin: EdgeInsets.only(
              //         bottom: MediaQuery.of(context).viewInsets.bottom),
              //     // Provide a background color for the popup.
              //     color: CupertinoColors.systemBackground.resolveFrom(context),
              //     // Use a SafeArea widget to avoid system overlaps.
              //     child: SafeArea(
              //       top: false,
              //       child: CupertinoDatePicker(
              //         initialDateTime: _selectedDate.value,
              //         mode: CupertinoDatePickerMode.date,
              //         use24hFormat: true,
              //         // This shows day of week alongside day of month
              //         showDayOfWeek: false,

              //         maximumDate: DateTime.now(),
              //         minimumDate: DateTime.now()
              //             .subtract(const Duration(days: 365 * 7)),

              //         // This is called when the user changes the date.
              //         onDateTimeChanged: (DateTime newDate) {
              //           setState(() => _selectedDate.value = newDate);
              //         },
              //       ),
              //     ),
              //   ),

              // );
              // Hapit
            },
          ),
          Text(_selectedDate.value.toString()),
        ],
      ),
    );
  }
}
