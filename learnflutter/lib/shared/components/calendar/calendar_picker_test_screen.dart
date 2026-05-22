import 'package:flutter/material.dart';
import 'package:learnflutter/shared/components/calendar/calendar_bottom_sheet_picker.dart';
import 'package:learnflutter/shared/components/calendar/calendar_picker.dart';
import 'package:learnflutter/shared/components/calendar/quarter_picker.dart';

/// Màn hình kiểm thử [CalendarPicker] với đầy đủ các case sử dụng:
/// - Single / Multi / Range
/// - Có / chưa có giá trị mặc định
/// - Giới hạn `firstDate` & `lastDate`
/// - Trạng thái `disabled`
/// - Custom màu nhấn
class CalendarPickerTestScreen extends StatefulWidget {
  const CalendarPickerTestScreen({super.key});

  @override
  State<CalendarPickerTestScreen> createState() => _CalendarPickerTestScreenState();
}

class _CalendarPickerTestScreenState extends State<CalendarPickerTestScreen> {
  DateTime? _singleDate;
  DateTime? _singleDateWithDefault = DateTime.now();

  List<DateTime> _multiDates = [];
  List<DateTime> _multiDatesWithDefault = [
    DateTime.now(),
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 5)),
  ];

  List<DateTime> _rangeDates = [];
  List<DateTime> _rangeDatesWithDefault = [
    DateTime.now(),
    DateTime.now().add(const Duration(days: 7)),
  ];

  DateTime? _limitedDate;
  DateTime? _customColorDate;
  final DateTime _disabledDate = DateTime(2024, 1, 1);

  DateTime? _bottomSheetDate;
  DateTime? _bottomSheetDateWithDefault = DateTime.now();

  Quarter? _quarter;
  Quarter _quarterWithDefault = Quarter.current();
  Quarter? _quarterLimited;
  List<Quarter> _multiQuarters = [];
  List<Quarter> _multiQuartersWithDefault = [
    Quarter.current(),
    Quarter(Quarter.current().year, 1),
  ];

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('CalendarPicker — Test cases'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            title: '1. Single — chưa có giá trị',
            description: 'Mode mặc định, không truyền value.',
            child: CalendarPicker(
              label: 'Ngày sinh',
              hint: 'Chưa chọn',
              value: _singleDate == null ? null : [_singleDate],
              onChanged: (dates) => setState(() => _singleDate = dates.first),
            ),
            result: _singleDate == null ? '(chưa chọn)' : _fmt(_singleDate!),
          ),
          _section(
            title: '2. Single — có giá trị mặc định',
            description: 'Truyền sẵn `value` là ngày hôm nay.',
            child: CalendarPicker(
              label: 'Ngày khám',
              value: _singleDateWithDefault == null ? null : [_singleDateWithDefault],
              onChanged: (dates) => setState(() => _singleDateWithDefault = dates.first),
            ),
            result: _singleDateWithDefault == null ? '(chưa chọn)' : _fmt(_singleDateWithDefault!),
          ),
          _section(
            title: '3. Multi — chưa có giá trị',
            description: 'Chọn nhiều ngày rời rạc.',
            child: CalendarPicker(
              mode: CalendarPickerMode.multi,
              label: 'Ngày nghỉ phép',
              value: _multiDates.isEmpty ? null : _multiDates,
              onChanged: (dates) => setState(() => _multiDates = dates),
            ),
            result: _multiDates.isEmpty
                ? '(chưa chọn)'
                : _multiDates.map(_fmt).join(', '),
          ),
          _section(
            title: '4. Multi — có giá trị mặc định',
            description: 'Truyền 3 ngày sẵn.',
            child: CalendarPicker(
              mode: CalendarPickerMode.multi,
              label: 'Ngày training',
              value: _multiDatesWithDefault,
              onChanged: (dates) => setState(() => _multiDatesWithDefault = dates),
            ),
            result: _multiDatesWithDefault.map(_fmt).join(', '),
          ),
          _section(
            title: '5. Range — chưa có giá trị',
            description: 'Chọn khoảng (start → end).',
            child: CalendarPicker(
              mode: CalendarPickerMode.range,
              label: 'Khoảng thời gian',
              value: _rangeDates.isEmpty ? null : _rangeDates,
              onChanged: (dates) => setState(() => _rangeDates = dates),
            ),
            result: _rangeDates.length < 2
                ? '(chưa đủ start & end)'
                : '${_fmt(_rangeDates.first)} → ${_fmt(_rangeDates.last)}',
          ),
          _section(
            title: '6. Range — có giá trị mặc định',
            description: 'Mặc định hôm nay → +7 ngày.',
            child: CalendarPicker(
              mode: CalendarPickerMode.range,
              label: 'Kỳ nghỉ',
              value: _rangeDatesWithDefault,
              onChanged: (dates) => setState(() => _rangeDatesWithDefault = dates),
            ),
            result:
                '${_fmt(_rangeDatesWithDefault.first)} → ${_fmt(_rangeDatesWithDefault.last)}',
          ),
          _section(
            title: '7. Giới hạn firstDate / lastDate',
            description: 'Chỉ cho chọn trong năm hiện tại.',
            child: CalendarPicker(
              label: 'Trong năm ${DateTime.now().year}',
              firstDate: DateTime(DateTime.now().year, 1, 1),
              lastDate: DateTime(DateTime.now().year, 12, 31),
              value: _limitedDate == null ? null : [_limitedDate],
              onChanged: (dates) => setState(() => _limitedDate = dates.first),
            ),
            result: _limitedDate == null ? '(chưa chọn)' : _fmt(_limitedDate!),
          ),
          _section(
            title: '8. Custom accentColor',
            description: 'Đổi màu nhấn sang cam.',
            child: CalendarPicker(
              label: 'Ngày sự kiện',
              accentColor: const Color(0xFFEA580C),
              value: _customColorDate == null ? null : [_customColorDate],
              onChanged: (dates) => setState(() => _customColorDate = dates.first),
            ),
            result: _customColorDate == null ? '(chưa chọn)' : _fmt(_customColorDate!),
          ),
          _section(
            title: '9. Disabled',
            description: 'Không thể tương tác, hiển thị mờ.',
            child: CalendarPicker(
              label: 'Ngày khóa',
              enabled: false,
              value: [_disabledDate],
              onChanged: (_) {},
            ),
            result: _fmt(_disabledDate),
          ),
          _section(
            title: '10. BottomSheet picker — chưa có giá trị',
            description:
                'Mở bottom sheet style UI Kit, 2 tab: Lịch & Bánh xe.',
            child: CalendarBottomSheetField(
              label: 'Ngày hẹn',
              value: _bottomSheetDate,
              onChanged: (d) => setState(() => _bottomSheetDate = d),
            ),
            result:
                _bottomSheetDate == null ? '(chưa chọn)' : _fmt(_bottomSheetDate!),
          ),
          _section(
            title: '11. BottomSheet picker — có default + accent cam',
            description: 'Truyền sẵn ngày hôm nay, đổi accentColor.',
            child: CalendarBottomSheetField(
              label: 'Ngày sự kiện',
              accentColor: const Color(0xFFEA580C),
              value: _bottomSheetDateWithDefault,
              onChanged: (d) =>
                  setState(() => _bottomSheetDateWithDefault = d),
            ),
            result: _bottomSheetDateWithDefault == null
                ? '(chưa chọn)'
                : _fmt(_bottomSheetDateWithDefault!),
          ),
          _section(
            title: '12. QuarterPicker — chưa có giá trị',
            description:
                'Chọn quý dạng Qx/yyyy. Mặc định mở ở năm hiện tại.',
            child: QuarterPickerField(
              label: 'Quý',
              value: _quarter,
              onChanged: (q) => setState(() => _quarter = q),
            ),
            result: _quarter?.format() ?? '(chưa chọn)',
          ),
          _section(
            title: '13. QuarterPicker — default = quý hiện tại',
            description:
                'Khởi tạo bằng `Quarter.current()` (tính từ DateTime.now()).',
            child: QuarterPickerField(
              label: 'Quý báo cáo',
              value: _quarterWithDefault,
              onChanged: (q) => setState(() => _quarterWithDefault = q),
            ),
            result: _quarterWithDefault.format(),
          ),
          _section(
            title: '14. QuarterPicker — min/max validation',
            description:
                'min = Q1/2023, max = quý hiện tại. Các quý ngoài range bị disable.',
            child: QuarterPickerField(
              label: 'Quý hợp lệ',
              accentColor: const Color(0xFFEA580C),
              value: _quarterLimited,
              minQuarter: Quarter(2023, 1),
              maxQuarter: Quarter.current(),
              onChanged: (q) => setState(() => _quarterLimited = q),
            ),
            result: _quarterLimited?.format() ?? '(chưa chọn)',
          ),
          _section(
            title: '15. QuarterPicker — multi (chưa có giá trị)',
            description:
                'Mode chọn nhiều quý rời rạc, tap vào tile để toggle.',
            child: QuarterMultiPickerField(
              label: 'Các quý',
              value: _multiQuarters,
              onChanged: (qs) => setState(() => _multiQuarters = qs),
            ),
            result: _multiQuarters.isEmpty
                ? '(chưa chọn)'
                : _multiQuarters.map((q) => q.format()).join(', '),
          ),
          _section(
            title: '16. QuarterPicker — multi (có default + min/max)',
            description:
                'Default 2 quý, giới hạn min Q1/2022 → max quý hiện tại.',
            child: QuarterMultiPickerField(
              label: 'Quý báo cáo',
              accentColor: const Color(0xFF7C3AED),
              value: _multiQuartersWithDefault,
              minQuarter: Quarter(2022, 1),
              maxQuarter: Quarter.current(),
              onChanged: (qs) =>
                  setState(() => _multiQuartersWithDefault = qs),
            ),
            result: _multiQuartersWithDefault.isEmpty
                ? '(chưa chọn)'
                : _multiQuartersWithDefault
                    .map((q) => q.format())
                    .join(', '),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

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
                const Icon(Icons.check_circle_outline,
                    size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 6),
                const Text(
                  'Kết quả: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    result,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF374151)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
