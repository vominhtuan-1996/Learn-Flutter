# Figma File

Lấy toàn bộ cấu trúc JSON của một Figma file.

## Instructions

Đọc `file_key` từ arguments (lấy từ URL Figma: `figma.com/file/<file_key>/...`).

Gọi tool `get_file` với:
- `file_key`: bắt buộc
- `depth`: nếu user chỉ muốn xem tổng quan → dùng `depth: 2`
- `ids`: nếu user chỉ muốn xem 1 số node cụ thể

Sau khi lấy data, tóm tắt cấu trúc file: tên file, số pages, danh sách page names.

## Output format

```
📄 File: <tên file>
🔑 Key : <file_key>
📑 Pages (<n>):
  - Page 1: <name>
  - Page 2: <name>
```

Kèm raw JSON nếu user yêu cầu.

## Example

`/figma-file MO4JcMsNudV8vtIwmCPGoc`
`/figma-file MO4JcMsNudV8vtIwmCPGoc depth=2`
