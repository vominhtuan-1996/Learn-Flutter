# Usage — testcase-sheet-notes

Ghi note vào cột Note của file testcase Excel online, **chỉ** cho TC cần BA/QC xác nhận hoặc thiếu case (nguồn: file GAP). Không ghi kết quả chạy test.

## Gọi skill

```
/testcase-sheet-notes <link-excel-online> sheet="Đăng nhập" col=S gap=learnflutter/docs/prd-v1.0/gap-testcase-qc-2026-10-13.md
```

Ví dụ lời nhắc tự nhiên:

> dùng playwright ghi note GAP vào cột S của file testcase online <link>.

## Khi chưa đưa tài liệu

Không nêu path file GAP → Claude hỏi bạn path. Claude không tự bịa nội dung note và không ghi gì ngoài hai trường hợp trên.

## Điều kiện

- Plugin Playwright MCP đã bật (`mcp__plugin_playwright_playwright__*`).
- Có file GAP `gap-testcase-qc-*.md`. Skill chỉ ghi note cho TC cần BA/QC xác nhận hoặc thiếu case; không ghi kết quả chạy test.
- User đăng nhập Microsoft thủ công trong cửa sổ Playwright.
- User có quyền sửa file; file không ở trạng thái "damaged" hoặc đã được user chấp thuận `Fix it`.

## Các bước (người dùng thấy)

1. Claude tìm file run test trong folder FR, sinh `notes.json`, cho bạn xem tên file và số TC theo loại.
2. Claude mở link, dừng ở trang đăng nhập → bạn đăng nhập → báo "đã đăng nhập".
3. Claude hỏi (nếu cần): `Fix it`, cột Note/round, file run test nào.
4. Claude dựng bản đồ TC → hàng, đưa bạn xem danh sách sẽ ghi. Bạn đồng ý rồi mới ghi.
5. Claude ghi từng ô, chụp ảnh kiểm tra, báo cáo.

## Dùng script

```bash
# 1. notes.json + titles.json từ file GAP
python3 -I scripts/notes_from_gap.py <gap.md> <out_dir>

# 2. Lưu text copy cột A (kết quả của scripts/read_column.js) vào layout.txt, rồi sinh bản đồ hàng
python3 -I scripts/build_rowmap.py layout.txt 7 > rowmap.json

# 3. Sinh đoạn code cho browser_run_code_unsafe (35 ô mỗi phần; đổi --part 2, 3 ... cho các lượt sau)
python3 -I scripts/build_run_code.py notes.json rowmap.json S --chunk 35 --part 1 > run_code_batch1.js
```

Dán nội dung `run_code_batch*.js` vào `mcp__plugin_playwright_playwright__browser_run_code_unsafe` (tham số `code`). Xóa note: `scripts/clear_ranges.js` với danh sách đoạn.

## Kết quả mong đợi

- Mỗi TC trong 3 bảng của file run test có đúng 1 note ở cột Note, đúng hàng theo TC ID cột A.
- TC không có trong 3 bảng không bị ghi.
- Header nhóm và cột khác không đổi.
- Báo cáo cuối liệt kê TC đã ghi, TC bỏ qua, sự cố.

## Hoàn nguyên

Clear Contents theo đoạn bằng `clear_ranges.js`, hoặc Version History của file. Không bấm Undo hàng loạt.
