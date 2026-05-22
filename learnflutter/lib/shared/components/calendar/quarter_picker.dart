import 'package:flutter/material.dart';

/// Đại diện cho một quý trong năm (Q1..Q4) — format hiển thị `Qx/yyyy`.
///
/// Có thể so sánh (`<`, `<=`, `>`, `>=`, `==`) và sort.
class Quarter implements Comparable<Quarter> {
  /// [quarter] phải nằm trong khoảng 1..4.
  Quarter(this.year, this.quarter)
      : assert(quarter >= 1 && quarter <= 4, 'quarter must be 1..4');

  /// Trả về quý chứa [date] (mặc định là hôm nay).
  factory Quarter.fromDate([DateTime? date]) {
    final d = date ?? DateTime.now();
    return Quarter(d.year, ((d.month - 1) ~/ 3) + 1);
  }

  /// Quý hiện tại theo ngày hệ thống.
  static Quarter current() => Quarter.fromDate();

  final int year;
  final int quarter;

  /// Tháng đầu tiên của quý (1, 4, 7, 10).
  int get startMonth => (quarter - 1) * 3 + 1;

  /// Tháng cuối của quý (3, 6, 9, 12).
  int get endMonth => startMonth + 2;

  /// Ngày đầu của quý.
  DateTime get startDate => DateTime(year, startMonth, 1);

  /// Ngày cuối của quý (ngày cuối tháng [endMonth]).
  DateTime get endDate => DateTime(year, endMonth + 1, 0);

  /// Trả về `Qx/yyyy`.
  String format() => 'Q$quarter/$year';

  /// Tổng index dùng để so sánh.
  int get _index => year * 4 + (quarter - 1);

  @override
  int compareTo(Quarter other) => _index.compareTo(other._index);

  bool operator <(Quarter other) => _index < other._index;
  bool operator <=(Quarter other) => _index <= other._index;
  bool operator >(Quarter other) => _index > other._index;
  bool operator >=(Quarter other) => _index >= other._index;

  @override
  bool operator ==(Object other) =>
      other is Quarter && other.year == year && other.quarter == quarter;

  @override
  int get hashCode => Object.hash(year, quarter);

  @override
  String toString() => format();
}

/// Field chọn quý dạng UI Kit. Tap mở bottom sheet với grid 4 quý / năm,
/// có thể chuyển năm trước / sau (giới hạn theo [minQuarter] / [maxQuarter]).
///
/// ```dart
/// Quarter? _q;
/// QuarterPickerField(
///   label: 'Quý báo cáo',
///   value: _q,
///   minQuarter: Quarter(2020, 1),
///   maxQuarter: Quarter.current(),
///   onChanged: (q) => setState(() => _q = q),
/// );
/// ```
class QuarterPickerField extends StatelessWidget {
  const QuarterPickerField({
    super.key,
    required this.onChanged,
    this.value,
    this.label,
    this.hint = 'Chọn quý',
    this.minQuarter,
    this.maxQuarter,
    this.accentColor = const Color(0xFF2563EB),
    this.enabled = true,
    this.title = 'Chọn quý',
  });

  final Quarter? value;
  final ValueChanged<Quarter> onChanged;
  final String? label;
  final String hint;
  final Quarter? minQuarter;
  final Quarter? maxQuarter;
  final Color accentColor;
  final bool enabled;
  final String title;

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
                    final picked = await showQuarterPicker(
                      context: context,
                      initial: value,
                      minQuarter: minQuarter,
                      maxQuarter: maxQuarter,
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
                  Icon(Icons.calendar_view_month_rounded,
                      size: 18, color: accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      value?.format() ?? hint,
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

/// Chế độ chọn quý.
enum QuarterPickerMode {
  /// Chọn 1 quý duy nhất.
  single,

  /// Chọn nhiều quý rời rạc.
  multi,
}

/// Mở bottom sheet chọn 1 quý. Trả về [Quarter] hoặc `null` nếu huỷ.
Future<Quarter?> showQuarterPicker({
  required BuildContext context,
  Quarter? initial,
  Quarter? minQuarter,
  Quarter? maxQuarter,
  Color accentColor = const Color(0xFF2563EB),
  String title = 'Chọn quý',
}) async {
  assert(
    minQuarter == null || maxQuarter == null || minQuarter <= maxQuarter,
    'minQuarter must be <= maxQuarter',
  );
  final result = await showModalBottomSheet<List<Quarter>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuarterPickerSheet(
      mode: QuarterPickerMode.single,
      initial: initial == null ? const [] : [initial],
      minQuarter: minQuarter,
      maxQuarter: maxQuarter,
      accentColor: accentColor,
      title: title,
    ),
  );
  return (result == null || result.isEmpty) ? null : result.first;
}

/// Mở bottom sheet chọn nhiều quý. Trả về danh sách quý (đã sort tăng dần)
/// hoặc `null` nếu huỷ.
Future<List<Quarter>?> showMultiQuarterPicker({
  required BuildContext context,
  List<Quarter> initial = const [],
  Quarter? minQuarter,
  Quarter? maxQuarter,
  Color accentColor = const Color(0xFF2563EB),
  String title = 'Chọn nhiều quý',
}) {
  assert(
    minQuarter == null || maxQuarter == null || minQuarter <= maxQuarter,
    'minQuarter must be <= maxQuarter',
  );
  return showModalBottomSheet<List<Quarter>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuarterPickerSheet(
      mode: QuarterPickerMode.multi,
      initial: initial,
      minQuarter: minQuarter,
      maxQuarter: maxQuarter,
      accentColor: accentColor,
      title: title,
    ),
  );
}

/// Field chọn **nhiều quý**.
///
/// ```dart
/// List<Quarter> _selected = [];
/// QuarterMultiPickerField(
///   label: 'Các quý báo cáo',
///   value: _selected,
///   maxQuarter: Quarter.current(),
///   onChanged: (qs) => setState(() => _selected = qs),
/// );
/// ```
class QuarterMultiPickerField extends StatelessWidget {
  const QuarterMultiPickerField({
    super.key,
    required this.onChanged,
    this.value = const [],
    this.label,
    this.hint = 'Chọn quý',
    this.minQuarter,
    this.maxQuarter,
    this.accentColor = const Color(0xFF2563EB),
    this.enabled = true,
    this.title = 'Chọn nhiều quý',
  });

  final List<Quarter> value;
  final ValueChanged<List<Quarter>> onChanged;
  final String? label;
  final String hint;
  final Quarter? minQuarter;
  final Quarter? maxQuarter;
  final Color accentColor;
  final bool enabled;
  final String title;

  String _displayText() {
    if (value.isEmpty) return hint;
    if (value.length <= 2) return value.map((q) => q.format()).join(', ');
    return '${value.first.format()} +${value.length - 1} quý khác';
  }

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
                    final picked = await showMultiQuarterPicker(
                      context: context,
                      initial: value,
                      minQuarter: minQuarter,
                      maxQuarter: maxQuarter,
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
                  Icon(Icons.calendar_view_month_rounded,
                      size: 18, color: accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _displayText(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: value.isEmpty
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF111827),
                        fontWeight: value.isEmpty
                            ? FontWeight.w400
                            : FontWeight.w600,
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

class _QuarterPickerSheet extends StatefulWidget {
  const _QuarterPickerSheet({
    required this.mode,
    required this.initial,
    required this.minQuarter,
    required this.maxQuarter,
    required this.accentColor,
    required this.title,
  });

  final QuarterPickerMode mode;
  final List<Quarter> initial;
  final Quarter? minQuarter;
  final Quarter? maxQuarter;
  final Color accentColor;
  final String title;

  @override
  State<_QuarterPickerSheet> createState() => _QuarterPickerSheetState();
}

class _QuarterPickerSheetState extends State<_QuarterPickerSheet> {
  late int _viewYear;
  late Set<Quarter> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial
        .where((q) => _isEnabled(q))
        .map(_clamp)
        .toSet();
    _viewYear = _selected.isNotEmpty
        ? _selected.first.year
        : (widget.minQuarter?.year ??
            widget.maxQuarter?.year ??
            Quarter.current().year);
  }

  Quarter _clamp(Quarter q) {
    if (widget.minQuarter != null && q < widget.minQuarter!) {
      return widget.minQuarter!;
    }
    if (widget.maxQuarter != null && q > widget.maxQuarter!) {
      return widget.maxQuarter!;
    }
    return q;
  }

  bool _isEnabled(Quarter q) {
    if (widget.minQuarter != null && q < widget.minQuarter!) return false;
    if (widget.maxQuarter != null && q > widget.maxQuarter!) return false;
    return true;
  }

  bool get _canPrevYear =>
      widget.minQuarter == null || _viewYear - 1 >= widget.minQuarter!.year;
  bool get _canNextYear =>
      widget.maxQuarter == null || _viewYear + 1 <= widget.maxQuarter!.year;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
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
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF6B7280)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            _buildYearSwitcher(),
            _buildQuarterGrid(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              shape: const CircleBorder(),
            ),
            onPressed:
                _canPrevYear ? () => setState(() => _viewYear--) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Năm $_viewYear',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              shape: const CircleBorder(),
            ),
            onPressed:
                _canNextYear ? () => setState(() => _viewYear++) : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildQuarterGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
        children: List.generate(4, (i) {
          final q = Quarter(_viewYear, i + 1);
          final enabled = _isEnabled(q);
          final selected = _selected.contains(q);
          return _QuarterTile(
            quarter: q,
            enabled: enabled,
            selected: selected,
            accentColor: widget.accentColor,
            onTap: () => setState(() {
              if (widget.mode == QuarterPickerMode.single) {
                _selected = {q};
              } else {
                if (selected) {
                  _selected.remove(q);
                } else {
                  _selected.add(q);
                }
              }
            }),
          );
        }),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
              onPressed: () {
                final list = _selected.toList()..sort();
                Navigator.of(context).pop(list);
              },
              child: const Text('Xác nhận',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuarterTile extends StatelessWidget {
  const _QuarterTile({
    required this.quarter,
    required this.enabled,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final Quarter quarter;
  final bool enabled;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? accentColor
        : enabled
            ? Colors.white
            : const Color(0xFFF3F4F6);
    final fg = selected
        ? Colors.white
        : enabled
            ? const Color(0xFF111827)
            : const Color(0xFF9CA3AF);
    final border = selected ? accentColor : const Color(0xFFE5E7EB);

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: selected ? 1.5 : 1),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Q${quarter.quarter}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tháng ${quarter.startMonth}–${quarter.endMonth}',
                style: TextStyle(
                  fontSize: 11,
                  color: fg.withOpacity(selected ? 0.9 : 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
