import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Mở bottom sheet chọn ngày dạng UI Kit với 2 tab:
/// - **Calendar**: lưới ngày tháng (calendar_date_picker2).
/// - **Wheel**: 3 bánh xe day/month/year (Cupertino).
///
/// Trả về [DateTime] user đã xác nhận, hoặc `null` nếu huỷ.
///
/// Ví dụ:
/// ```dart
/// final picked = await showCalendarBottomSheet(
///   context: context,
///   initialDate: DateTime.now(),
///   accentColor: Colors.indigo,
/// );
/// ```
Future<DateTime?> showCalendarBottomSheet({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  Color accentColor = const Color(0xFF2563EB),
  String title = 'Chọn ngày',
}) {
  final now = DateTime.now();
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CalendarBottomSheet(
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(now.year - 100),
      lastDate: lastDate ?? DateTime(now.year + 10),
      accentColor: accentColor,
      title: title,
    ),
  );
}

/// Field trigger style giống UI Kit. Tap vào sẽ mở bottom sheet picker.
///
/// ```dart
/// CalendarBottomSheetField(
///   label: 'Ngày sinh',
///   value: _picked,
///   onChanged: (d) => setState(() => _picked = d),
/// );
/// ```
class CalendarBottomSheetField extends StatelessWidget {
  const CalendarBottomSheetField({
    super.key,
    required this.onChanged,
    this.value,
    this.label,
    this.hint = 'Chọn ngày',
    this.firstDate,
    this.lastDate,
    this.accentColor = const Color(0xFF2563EB),
    this.enabled = true,
    this.title = 'Chọn ngày',
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? label;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Color accentColor;
  final bool enabled;
  final String title;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
        ],
        Opacity(
          opacity: enabled ? 1 : 0.5,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: enabled
                ? () async {
                    final picked = await showCalendarBottomSheet(
                      context: context,
                      initialDate: value,
                      firstDate: firstDate,
                      lastDate: lastDate,
                      accentColor: accentColor,
                      title: title,
                    );
                    if (picked != null) onChanged(picked);
                  }
                : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_outlined, size: 18, color: accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      value == null ? hint : _fmt(value!),
                      style: TextStyle(
                        fontSize: 13,
                        color: value == null
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF111827),
                        fontWeight:
                            value == null ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarBottomSheet extends StatefulWidget {
  const _CalendarBottomSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.accentColor,
    required this.title,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color accentColor;
  final String title;

  @override
  State<_CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<_CalendarBottomSheet>
    with SingleTickerProviderStateMixin {
  late DateTime _selected;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _selected = _clamp(widget.initialDate);
    _tab = TabController(length: 2, vsync: this);
  }

  DateTime _clamp(DateTime d) {
    if (d.isBefore(widget.firstDate)) return widget.firstDate;
    if (d.isAfter(widget.lastDate)) return widget.lastDate;
    return d;
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              _buildHeader(),
              _buildTabs(),
              SizedBox(
                height: 340,
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _buildCalendarTab(),
                    _buildWheelTab(),
                  ],
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() => Container(
        margin: const EdgeInsets.only(top: 8),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  Widget _buildTabs() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TabBar(
          controller: _tab,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          indicatorPadding: const EdgeInsets.all(4),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: widget.accentColor,
          unselectedLabelColor: const Color(0xFF6B7280),
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Lịch', height: 36),
            Tab(text: 'Bánh xe', height: 36),
          ],
        ),
      );

  Widget _buildCalendarTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CalendarDatePicker2(
        config: CalendarDatePicker2Config(
          calendarType: CalendarDatePicker2Type.single,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectedDayHighlightColor: widget.accentColor,
          weekdayLabelTextStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          controlsTextStyle: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        value: [_selected],
        onValueChanged: (dates) {
          if (dates.isNotEmpty) {
            setState(() => _selected = dates.first);
          }
        },
      ),
    );
  }

  Widget _buildWheelTab() {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          dateTimePickerTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
      ),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: _selected,
        minimumDate: widget.firstDate,
        maximumDate: widget.lastDate,
        onDateTimeChanged: (d) => _selected = d,
      ),
    );
  }

  Widget _buildActions() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: const Color(0xFF374151),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Huỷ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: widget.accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(_selected),
                child: const Text('Xác nhận',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );
}
