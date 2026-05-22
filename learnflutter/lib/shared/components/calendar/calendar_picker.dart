import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

/// Mode hiển thị của [CalendarPicker].
enum CalendarPickerMode {
  /// Chọn 1 ngày duy nhất.
  single,

  /// Chọn nhiều ngày rời rạc.
  multi,

  /// Chọn khoảng (range) ngày bắt đầu → kết thúc.
  range,
}

/// Field nhập ngày dạng picker.
///
/// Hiển thị 1 ô bấm vào → mở popup `calendar_date_picker2` theo [mode] (single,
/// multi, range), trả về giá trị đã chọn qua [onChanged].
///
/// Ví dụ sử dụng:
/// ```dart
/// DateTime? _picked;
///
/// CalendarPicker(
///   label: 'Ngày sinh',
///   value: _picked == null ? null : [_picked!],
///   onChanged: (dates) => setState(() => _picked = dates.first),
/// );
/// ```
///
/// Với range:
/// ```dart
/// CalendarPicker(
///   mode: CalendarPickerMode.range,
///   label: 'Khoảng thời gian',
///   value: _range,
///   onChanged: (dates) => setState(() => _range = dates),
/// );
/// ```
class CalendarPicker extends StatelessWidget {
  const CalendarPicker({
    super.key,
    required this.onChanged,
    this.mode = CalendarPickerMode.single,
    this.value,
    this.label,
    this.hint = 'Chọn ngày',
    this.firstDate,
    this.lastDate,
    this.dialogTitle,
    this.accentColor = const Color(0xFF2563EB),
    this.enabled = true,
  });

  /// Mode picker (single / multi / range).
  final CalendarPickerMode mode;

  /// Giá trị hiện tại. Với [CalendarPickerMode.single] truyền `[date]`,
  /// [CalendarPickerMode.range] truyền `[start, end]`, [CalendarPickerMode.multi]
  /// truyền danh sách bất kỳ.
  final List<DateTime?>? value;

  /// Callback khi user xác nhận chọn. Không gọi nếu user cancel.
  final ValueChanged<List<DateTime>> onChanged;

  /// Label hiển thị phía trên field.
  final String? label;

  /// Placeholder khi chưa chọn ngày.
  final String hint;

  /// Giới hạn ngày sớm nhất có thể chọn. Mặc định: 100 năm trước hôm nay.
  final DateTime? firstDate;

  /// Giới hạn ngày muộn nhất có thể chọn. Mặc định: 10 năm sau hôm nay.
  final DateTime? lastDate;

  /// Tiêu đề dialog. Mặc định auto-generate theo [mode].
  final String? dialogTitle;

  /// Màu nhấn cho selected day & nút.
  final Color accentColor;

  /// Cho phép tương tác hay không.
  final bool enabled;

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
            onTap: enabled ? () => _openPicker(context) : null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _displayText(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: _hasValue() ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                        fontWeight: _hasValue() ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  const Icon(Icons.expand_more_rounded,
                      size: 18, color: Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _hasValue() => value != null && value!.any((d) => d != null);

  String _displayText() {
    if (!_hasValue()) return hint;
    final valid = value!.whereType<DateTime>().toList();
    if (mode == CalendarPickerMode.range && valid.length >= 2) {
      return '${_fmt(valid.first)}  →  ${_fmt(valid.last)}';
    }
    if (mode == CalendarPickerMode.multi) {
      if (valid.length <= 2) return valid.map(_fmt).join(', ');
      return '${_fmt(valid.first)} +${valid.length - 1} ngày khác';
    }
    return _fmt(valid.first);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _openPicker(BuildContext context) async {
    final now = DateTime.now();
    final config = CalendarDatePicker2WithActionButtonsConfig(
      calendarType: switch (mode) {
        CalendarPickerMode.single => CalendarDatePicker2Type.single,
        CalendarPickerMode.multi => CalendarDatePicker2Type.multi,
        CalendarPickerMode.range => CalendarDatePicker2Type.range,
      },
      firstDate: firstDate ?? DateTime(now.year - 100),
      lastDate: lastDate ?? DateTime(now.year + 10),
      selectedDayHighlightColor: accentColor,
      cancelButtonTextStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontWeight: FontWeight.w600,
      ),
      okButtonTextStyle: TextStyle(
        color: accentColor,
        fontWeight: FontWeight.w700,
      ),
    );

    final result = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: const Size(325, 400),
      value: value ?? const [],
      borderRadius: BorderRadius.circular(16),
      dialogBackgroundColor: Colors.white,
    );

    if (result == null) return;
    final cleaned = result.whereType<DateTime>().toList();
    if (cleaned.isEmpty) return;
    onChanged(cleaned);
  }
}
