import 'package:flutter/material.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/modules/material/material_screen.dart';
import 'package:learnflutter/modules/material/material_screen_detail.dart';

class MaterialDatePicker extends StatefulWidget {
  const MaterialDatePicker({super.key, this.restorationId, required this.data});
  final RoouterMaterialModel data;

  final String? restorationId;

  @override
  State<MaterialDatePicker> createState() => _MaterialDatePickerState();
}

/// RestorationProperty objects can be used because of RestorationMixin.
class _MaterialDatePickerState extends State<MaterialDatePicker> with RestorationMixin {
  // In this example, the restoration ID for the mixin is passed in through
  // the [StatefulWidget]'s constructor.
  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
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
    registerForRestoration(_restorableDatePickerRouteFuture, 'date_picker_route_future');
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
      contentWidget: OutlinedButton(
        onPressed: () {
          _restorableDatePickerRouteFuture.present();
        },
        child: const Text('Open Date Picker'),
      ),
    );
  }
}
