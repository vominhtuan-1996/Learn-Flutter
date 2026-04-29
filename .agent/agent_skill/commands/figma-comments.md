# Figma Comments

Xem hoặc thêm comment vào Figma file.

## Instructions

Phân tích argument để xác định hành động:

**Xem comments** (mặc định):
- Gọi `get_comments` với `file_key`
- Hiển thị danh sách comments kèm author, nội dung, thời gian

**Thêm comment** (nếu user cung cấp nội dung):
- Gọi `post_comment` với `file_key` và `message`
- Xác nhận comment đã được thêm thành công

## Output format

**Xem:**
```
💬 Comments trong file <file_key> (<n> comments):

  [@<author>] <created_at>
  <message>
  ---
```

**Thêm:**
```
✅ Đã thêm comment:
  "<message>"
```

## Example

`/figma-comments MO4JcMsNudV8vtIwmCPGoc`
`/figma-comments MO4JcMsNudV8vtIwmCPGoc add "Cần chỉnh lại màu button theo brand guide"`
