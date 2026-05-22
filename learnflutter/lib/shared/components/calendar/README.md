# CalendarPicker Component

`CalendarPicker` là một component hỗ trợ việc chọn ngày tháng với 3 chế độ khác nhau: single (chọn 1 ngày), multi (chọn nhiều ngày rời rạc), và range (chọn khoảng thời gian). Component này hiển thị dưới dạng một field nhập liệu, khi nhấn vào sẽ mở một dialog chọn ngày đẹp mắt dựa trên thư viện `calendar_date_picker2`.

## Import

```dart
import 'package:learnflutter/shared/components/calendar/calendar_picker.dart';
```

## Các chế độ (CalendarPickerMode)

- `CalendarPickerMode.single`: Chọn 1 ngày duy nhất.
- `CalendarPickerMode.multi`: Chọn nhiều ngày riêng lẻ.
- `CalendarPickerMode.range`: Chọn một khoảng thời gian (ngày bắt đầu và ngày kết thúc).

## Cách sử dụng

### 1. Chọn 1 ngày (Single)

```dart
DateTime? _pickedDate;

CalendarPicker(
  mode: CalendarPickerMode.single,
  label: 'Ngày sinh',
  hint: 'Chọn ngày sinh',
  value: _pickedDate != null ? [_pickedDate!] : null,
  onChanged: (dates) {
    if (dates.isNotEmpty) {
      setState(() => _pickedDate = dates.first);
    }
  },
);
```

### 2. Chọn nhiều ngày (Multi)

```dart
List<DateTime>? _multiDates;

CalendarPicker(
  mode: CalendarPickerMode.multi,
  label: 'Ngày nghỉ phép',
  hint: 'Chọn các ngày nghỉ',
  value: _multiDates,
  onChanged: (dates) {
    setState(() => _multiDates = dates);
  },
);
```

### 3. Chọn khoảng thời gian (Range)

```dart
List<DateTime>? _rangeDates; // Thường chứa [startDate, endDate]

CalendarPicker(
  mode: CalendarPickerMode.range,
  label: 'Thời gian diễn ra sự kiện',
  hint: 'Từ ngày - Đến ngày',
  value: _rangeDates,
  onChanged: (dates) {
    setState(() => _rangeDates = dates);
  },
);
```

### 4. Vô hiệu hóa (Disabled)

Để khóa không cho chọn, bạn có thể truyền `enabled: false`. Component sẽ mờ đi và không phản hồi khi bấm vào.

```dart
CalendarPicker(
  mode: CalendarPickerMode.single,
  label: 'Ngày khóa',
  enabled: false,
  onChanged: (dates) {},
);
```

## Các tham số tùy chỉnh

| Tham số | Loại | Mặc định | Mô tả |
|---|---|---|---|
| `mode` | `CalendarPickerMode` | `.single` | Chế độ chọn ngày (single/multi/range) |
| `value` | `List<DateTime?>?` | `null` | Giá trị đang được chọn |
| `onChanged` | `ValueChanged<List<DateTime>>`| `required` | Hàm callback khi có thay đổi |
| `label` | `String?` | `null` | Tiêu đề hiển thị trên input field |
| `hint` | `String` | `'Chọn ngày'` | Chữ hiển thị mờ khi chưa chọn |
| `firstDate` | `DateTime?` | `100 năm trước`| Ngày nhỏ nhất có thể chọn |
| `lastDate` | `DateTime?` | `10 năm sau` | Ngày lớn nhất có thể chọn |
| `accentColor`| `Color` | `Color(0xFF2563EB)`| Màu sắc chủ đạo (highlight, button) |
| `enabled` | `bool` | `true` | Cờ trạng thái cho phép thao tác |

---

# CalendarBottomSheetField

Component chọn 1 ngày dạng **bottom sheet UI Kit** với 2 tab:
- **Lịch**: lưới ngày tháng (giống Material).
- **Bánh xe**: 3 wheel day/month/year (Cupertino).

Bottom sheet bo góc trên, có drag handle, nút **Huỷ** / **Xác nhận**.

## Import

```dart
import 'package:learnflutter/shared/components/calendar/calendar_bottom_sheet_picker.dart';
```

## Cách sử dụng

### 1. Dùng dưới dạng field

```dart
DateTime? _picked;

CalendarBottomSheetField(
  label: 'Ngày hẹn',
  hint: 'Chọn ngày',
  value: _picked,
  onChanged: (d) => setState(() => _picked = d),
);
```

### 2. Gọi trực tiếp hàm `showCalendarBottomSheet`

```dart
final picked = await showCalendarBottomSheet(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  accentColor: Colors.indigo,
  title: 'Chọn ngày khám',
);
if (picked != null) {
  // dùng picked
}
```

## Tham số

| Tham số | Loại | Mặc định | Mô tả |
|---|---|---|---|
| `value` | `DateTime?` | `null` | Giá trị hiện tại |
| `onChanged` | `ValueChanged<DateTime>` | `required` | Callback khi user xác nhận |
| `label` | `String?` | `null` | Label phía trên field |
| `hint` | `String` | `'Chọn ngày'` | Placeholder khi chưa chọn |
| `firstDate` | `DateTime?` | `100 năm trước` | Ngày nhỏ nhất |
| `lastDate` | `DateTime?` | `10 năm sau` | Ngày lớn nhất |
| `accentColor` | `Color` | `Color(0xFF2563EB)` | Màu nhấn highlight + nút xác nhận |
| `enabled` | `bool` | `true` | Cho phép tương tác |
| `title` | `String` | `'Chọn ngày'` | Tiêu đề bottom sheet |

## Khác biệt với `CalendarPicker`

| | `CalendarPicker` | `CalendarBottomSheetField` |
|---|---|---|
| UI trigger | Field + dialog | Field + bottom sheet |
| Mode | single / multi / range | single (date) |
| Cách nhập | Lưới calendar | Lưới calendar **+** wheel picker (tab switch) |
| Phù hợp | Form nhiều picker, desktop-like | Mobile UI Kit, thao tác 1 tay |

---

# QuarterPickerField

Component chọn **quý** (Q1..Q4) trong năm, format hiển thị `Qx/yyyy`. Hỗ trợ:
- Bottom sheet UI Kit với grid 4 quý, switch năm trước / sau.
- Validate `minQuarter` / `maxQuarter` — các quý ngoài range bị disable.
- Helper `Quarter.current()` / `Quarter.fromDate(date)` để lấy quý hiện tại.

## Import

```dart
import 'package:learnflutter/shared/components/calendar/quarter_picker.dart';
```

## Cách sử dụng

### 1. Field cơ bản

```dart
Quarter? _quarter;

QuarterPickerField(
  label: 'Quý',
  value: _quarter,
  onChanged: (q) => setState(() => _quarter = q),
);
```

### 2. Default = quý hiện tại + giới hạn range

```dart
Quarter _q = Quarter.current();

QuarterPickerField(
  label: 'Quý báo cáo',
  value: _q,
  minQuarter: Quarter(2020, 1),
  maxQuarter: Quarter.current(),
  onChanged: (q) => setState(() => _q = q),
);
```

### 3. Chọn **nhiều quý** (`QuarterMultiPickerField`)

```dart
List<Quarter> _selected = [];

QuarterMultiPickerField(
  label: 'Các quý báo cáo',
  value: _selected,
  minQuarter: Quarter(2022, 1),
  maxQuarter: Quarter.current(),
  onChanged: (qs) => setState(() => _selected = qs),
);
```

Trong bottom sheet, tap vào tile để **toggle** chọn / bỏ chọn. Kết quả trả về `List<Quarter>` đã sort tăng dần.

### 4. Gọi trực tiếp `showQuarterPicker` / `showMultiQuarterPicker`

```dart
final picked = await showQuarterPicker(
  context: context,
  initial: Quarter.current(),
  minQuarter: Quarter(2023, 1),
  maxQuarter: Quarter(2026, 4),
);
if (picked != null) print(picked.format()); // "Q2/2026"

// Multi:
final list = await showMultiQuarterPicker(
  context: context,
  initial: [Quarter.current()],
  minQuarter: Quarter(2022, 1),
  maxQuarter: Quarter.current(),
);
// list: List<Quarter> hoặc null
```

## Modes (`QuarterPickerMode`)

| Mode | Widget | Hàm | Trả về |
|---|---|---|---|
| `single` | `QuarterPickerField` | `showQuarterPicker` | `Quarter?` |
| `multi` | `QuarterMultiPickerField` | `showMultiQuarterPicker` | `List<Quarter>?` (sort tăng dần) |

## API `Quarter`

| Thành viên | Mô tả |
|---|---|
| `Quarter(year, quarter)` | Khởi tạo (assert `quarter ∈ 1..4`). |
| `Quarter.fromDate([date])` | Trả về quý chứa `date` (default = hôm nay). |
| `Quarter.current()` | Quý hiện tại. |
| `format()` | `"Qx/yyyy"`. |
| `startMonth` / `endMonth` | Tháng đầu / cuối (1,4,7,10 → 3,6,9,12). |
| `startDate` / `endDate` | `DateTime` đầu / cuối quý. |
| `<`, `<=`, `>`, `>=`, `==`, `compareTo` | So sánh & sort. |

## Tham số `QuarterPickerField`

| Tham số | Loại | Mặc định | Mô tả |
|---|---|---|---|
| `value` | `Quarter?` | `null` | Quý đang chọn |
| `onChanged` | `ValueChanged<Quarter>` | `required` | Callback khi xác nhận |
| `label` | `String?` | `null` | Label phía trên field |
| `hint` | `String` | `'Chọn quý'` | Placeholder |
| `minQuarter` | `Quarter?` | `null` | Quý nhỏ nhất (inclusive) |
| `maxQuarter` | `Quarter?` | `null` | Quý lớn nhất (inclusive) |
| `accentColor` | `Color` | `Color(0xFF2563EB)` | Màu nhấn |
| `enabled` | `bool` | `true` | Cho phép tương tác |
| `title` | `String` | `'Chọn quý'` | Tiêu đề bottom sheet |

## Nơi dùng thử

Bạn có thể mở ứng dụng, vào màn hình **Test Screen** -> tìm mục **Calendar Picker Test** để xem demo trực quan cho tất cả các trường hợp của component này.
