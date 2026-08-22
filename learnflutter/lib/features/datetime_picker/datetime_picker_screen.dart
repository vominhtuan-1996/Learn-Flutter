// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learnflutter/core/utils/dialog_utils.dart';

class DatePickerScreen extends StatefulWidget {
  const DatePickerScreen({super.key});

  @override
  State<DatePickerScreen> createState() => _DatePickerScreenState();
}

class _DatePickerScreenState extends State<DatePickerScreen> {
  // ── CupertinoDatePicker values ──
  DateTime _date = DateTime.now();
  DateTime _time = DateTime.now();
  DateTime _dateTime = DateTime.now();

  // ── Inline DateTime Input values ──
  DateTime _inlineDateTime = DateTime.now();
  bool _showCalendar = false;
  bool _showTimePicker = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // helpers
  // ──────────────────────────────────────────────────────────────────────────

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _fmtDateTime(DateTime d) => '${_fmtDate(d)}  ${_fmtTime(d)}';

  void _pickDate() {
    var tmp = _date;
    DialogUtils.showActionSheet(
      context: context,
      content: SizedBox(
        height: 300,
        child: CupertinoDatePicker(
          initialDateTime: _date,
          mode: CupertinoDatePickerMode.date,
          dateOrder: DatePickerDateOrder.dmy,
          minimumYear: DateTime.now().year - 10,
          maximumDate: DateTime.now(),
          use24hFormat: true,
          onDateTimeChanged: (v) => tmp = v,
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            DialogUtils.dismissPopup(context);
            setState(() => _date = tmp);
          },
          child: const Text('Đồng ý'),
        ),
      ],
    );
  }

  void _pickTime() {
    var tmp = _time;
    DialogUtils.showActionSheet(
      context: context,
      content: SizedBox(
        height: 300,
        child: CupertinoDatePicker(
          initialDateTime: _time,
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          onDateTimeChanged: (v) => tmp = v,
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            DialogUtils.dismissPopup(context);
            setState(() => _time = tmp);
          },
          child: const Text('Đồng ý'),
        ),
      ],
    );
  }

  void _pickDateTime() {
    var tmp = _dateTime;
    DialogUtils.showActionSheet(
      context: context,
      content: SizedBox(
        height: 300,
        child: CupertinoDatePicker(
          initialDateTime: _dateTime,
          mode: CupertinoDatePickerMode.dateAndTime,
          use24hFormat: true,
          onDateTimeChanged: (v) => tmp = v,
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            DialogUtils.dismissPopup(context);
            setState(() => _dateTime = tmp);
          },
          child: const Text('Đồng ý'),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // build
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    final dateFmt = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY, tag);
    final timeFmt = DateFormat(DateFormat.HOUR_MINUTE, tag);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('DateTime Picker'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. Date ────────────────────────────────────────────────────────
          _section(
            title: '1. Date Picker (Cupertino)',
            description: 'ActionSheet — chọn ngày kiểu bánh xe cuộn iOS.',
            result: _fmtDate(_date),
            child: _PickerTile(
              label: 'Ngày',
              value: _fmtDate(_date),
              icon: Icons.calendar_today_outlined,
              onTap: _pickDate,
            ),
          ),

          // ── 2. Time ────────────────────────────────────────────────────────
          _section(
            title: '2. Time Picker (Cupertino)',
            description: 'ActionSheet — chọn giờ:phút dạng 24h.',
            result: _fmtTime(_time),
            child: _PickerTile(
              label: 'Giờ',
              value: _fmtTime(_time),
              icon: Icons.access_time_outlined,
              onTap: _pickTime,
            ),
          ),

          // ── 3. DateTime ────────────────────────────────────────────────────
          _section(
            title: '3. DateTime Picker (Cupertino)',
            description: 'ActionSheet — chọn ngày + giờ kết hợp.',
            result: _fmtDateTime(_dateTime),
            child: _PickerTile(
              label: 'Ngày & Giờ',
              value: _fmtDateTime(_dateTime),
              icon: Icons.event_outlined,
              onTap: _pickDateTime,
            ),
          ),

          // ── 4. Inline DateTime Input ───────────────────────────────────────
          _section(
            title: '4. Inline DateTime Input',
            description: 'Tap chip ngày/giờ để mở lịch / bánh xe ngay trong trang.',
            result: _fmtDateTime(_inlineDateTime),
            child: _InlineDateTimeInput(
              dateTime: _inlineDateTime,
              showCalendar: _showCalendar,
              showTimePicker: _showTimePicker,
              dateFmt: dateFmt,
              timeFmt: timeFmt,
              onToggleCalendar: () => setState(() {
                _showCalendar = !_showCalendar;
                if (_showCalendar) _showTimePicker = false;
              }),
              onToggleTime: () => setState(() {
                _showTimePicker = !_showTimePicker;
                if (_showTimePicker) _showCalendar = false;
              }),
              onDateChanged: (d) => setState(() => _inlineDateTime = DateTime(
                    d.year, d.month, d.day,
                    _inlineDateTime.hour, _inlineDateTime.minute,
                  )),
              onTimeChanged: (v) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () {
                  setState(() => _inlineDateTime = DateTime(
                        _inlineDateTime.year, _inlineDateTime.month, _inlineDateTime.day,
                        v.hour, v.minute,
                      ));
                });
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // section wrapper (same pattern as CalendarPickerTestScreen)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _section({
    required String title,
    required String description,
    required Widget child,
    required String result,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          child,
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 6),
                const Text('Kết quả: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Expanded(
                  child: Text(result, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _PickerTile — nút bấm mở ActionSheet
// ────────────────────────────────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFF9FAFB),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6366F1)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _InlineDateTimeInput — calendar + time wheel inline trong section
// ────────────────────────────────────────────────────────────────────────────

class _InlineDateTimeInput extends StatelessWidget {
  const _InlineDateTimeInput({
    required this.dateTime,
    required this.showCalendar,
    required this.showTimePicker,
    required this.dateFmt,
    required this.timeFmt,
    required this.onToggleCalendar,
    required this.onToggleTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  final DateTime dateTime;
  final bool showCalendar;
  final bool showTimePicker;
  final DateFormat dateFmt;
  final DateFormat timeFmt;
  final VoidCallback onToggleCalendar;
  final VoidCallback onToggleTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── chip row ──
        Row(
          children: [
            _Chip(
              label: dateFmt.format(dateTime),
              icon: Icons.calendar_today_outlined,
              active: showCalendar,
              onTap: onToggleCalendar,
            ),
            const SizedBox(width: 8),
            _Chip(
              label: timeFmt.format(dateTime),
              icon: Icons.access_time_outlined,
              active: showTimePicker,
              onTap: onToggleTime,
            ),
          ],
        ),

        // ── inline calendar ──
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: showCalendar
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CalendarDatePicker(
                    firstDate: DateTime(DateTime.now().year - 10),
                    initialDate: dateTime,
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    onDateChanged: onDateChanged,
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ── inline time wheel ──
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: showTimePicker
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 200,
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
                        initialDateTime: dateTime,
                        use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                        onDateTimeChanged: onTimeChanged,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6366F1);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? accent.withOpacity(0.1) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? accent : const Color(0xFFE5E7EB),
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: active ? accent : const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? accent : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
