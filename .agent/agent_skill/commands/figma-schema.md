# Figma Schema

Phân tích Figma file để suy ra cấu trúc database schema từ UI screens.

## Instructions

Gọi tool `get_file` (depth=6) để lấy toàn bộ node tree.
Phân tích TEXT nodes trong từng screen để suy ra các entity và field.

Xuất ra:
- **SQL schema** (CREATE TABLE)
- **Dart model class** (với Hive / SQLite / Freezed annotation)
- **JSON schema** (dạng object mô tả cấu trúc)

Logic suy luận:
- Mỗi FRAME cấp cao → 1 entity/table
- TEXT node là label/placeholder → field name
- Nhận dạng field type từ tên: id, name, email, date, phone, image, count, bool...
- INPUT / RECTANGLE giống form field → confirm field exists

## Output format

```
📊 Schema từ <file_key>:

Entity: <ScreenName>
  - <field_name>: <type>  // suy luận từ "<text_label>"
  ...

SQL:
  CREATE TABLE <entity> (
    id INTEGER PRIMARY KEY,
    ...
  );

Dart:
  class <Entity>Model {
    final int id;
    ...
  }
```

## Example

`/figma-schema MO4JcMsNudV8vtIwmCPGoc`
`/figma-schema MO4JcMsNudV8vtIwmCPGoc format=sql`
`/figma-schema MO4JcMsNudV8vtIwmCPGoc format=dart`
`/figma-schema MO4JcMsNudV8vtIwmCPGoc format=json`
