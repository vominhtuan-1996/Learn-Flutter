import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeInputScreen extends StatefulWidget {
  const DateTimeInputScreen({
    super.key,
  });

  @override
  State<DateTimeInputScreen> createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInputScreen> {
  late bool showCalendar;
  late bool showTimePicker;

  late DateTime selectedDateTime;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    showCalendar = false;
    showTimePicker = false;

    selectedDateTime = DateTime.now();

    // context.read<GlucoseFormBloc>().add(DateTimeChanged(dateTime: selectedDateTime.toString()));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // final customColors = theme.extension<CustomColors>()!;

    // final l10n = context.l10n;

    var tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    var dateFormatter = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY, tag);
    var timeFormatter = DateFormat(DateFormat.HOUR_MINUTE, tag);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFFF4F5FF)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCFD4FF).withOpacity(0.06),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 47.0,
                    padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Text(l10n.logsDateTime),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    color: Colors.blue,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    dateFormatter.format(selectedDateTime).toString(),
                                    style: showCalendar
                                        ? theme.textTheme.bodyMedium!.copyWith(color: Colors.red)
                                        : theme.textTheme.bodyMedium,
                                  ),
                                ),
                                onTap: () => showCalendar
                                    ? setState(() => showCalendar = false)
                                    : setState(() {
                                        showCalendar = true;
                                        showTimePicker = false;
                                      }),
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: Colors.blue,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  timeFormatter.format(selectedDateTime).toString(),
                                  style: showTimePicker
                                      ? theme.textTheme.bodyMedium!.copyWith(color: Colors.red)
                                      : theme.textTheme.bodyMedium,
                                ),
                              ),
                              onTap: () => showTimePicker
                                  ? setState(() => showTimePicker = false)
                                  : setState(() {
                                      showCalendar = false;
                                      showTimePicker = true;
                                    }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showCalendar,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: SingleChildScrollView(
                        child: CalendarDatePicker(
                          firstDate: DateTime(DateTime.now().year - 7),
                          initialDate: selectedDateTime,
                          lastDate: DateTime.now(),
                          onDateChanged: (DateTime value) {
                            setState(() {
                              selectedDateTime = DateTime(
                                value.year,
                                value.month,
                                value.day,
                                selectedDateTime.hour,
                                selectedDateTime.minute,
                              );

                              // context.read<GlucoseFormBloc>().add(DateTimeChanged(dateTime: selectedDateTime.toString()));
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: showTimePicker,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: SizedBox(
                        height: 224,
                        child: CupertinoTheme(
                          data: const CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            initialDateTime: selectedDateTime,
                            use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                            onDateTimeChanged: (DateTime value) {
                              if (_debounce?.isActive ?? false) _debounce!.cancel();
                              _debounce = Timer(const Duration(milliseconds: 500), () {
                                setState(() {
                                  selectedDateTime = DateTime(
                                    selectedDateTime.year,
                                    selectedDateTime.month,
                                    selectedDateTime.day,
                                    value.hour,
                                    value.minute,
                                  );
                                  // context.read<GlucoseFormBloc>().add(DateTimeChanged(dateTime: selectedDateTime.toString()));
                                });
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
