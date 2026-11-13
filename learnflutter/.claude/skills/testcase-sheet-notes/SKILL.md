---
name: testcase-sheet-notes
description: Ghi note vào cột Note (ROUND n) của file testcase Excel online (SharePoint/OneDrive) bằng Playwright, CHỈ cho hai trường hợp — TC cần BA/QC xác nhận, hoặc thiếu case. Không ghi kết quả chạy test (Pass/Chưa Pass/Chưa chạy). Dùng khi user yêu cầu ghi note GAP/xác nhận/thiếu case lên file testcase online; không dùng để sửa nội dung testcase, không dùng cho file Excel local (dùng skill xlsx).
---

# Testcase → ghi Note lên Excel online

Ghi note từ **file GAP gửi QC** vào cột Note của sheet FR trong file testcase trên SharePoint. **Chỉ ghi cột Note của round được chỉ định.** Không sửa cột khác, không sửa header, không đổi định dạng.

## Phạm vi ghi — chỉ 2 trường hợp

| Trường hợp | Khi nào | Ghi ở đâu |
|---|---|---|
| **Cần BA/QC xác nhận** | TC mơ hồ, lệch hoặc mâu thuẫn PRD, cần người có thẩm quyền chốt (GAP loại `Cần sửa`, `Cần sửa / xác nhận`…) | Hàng của TC đó |
| **Thiếu case** | PRD có yêu cầu nhưng file testcase chưa có TC (GAP loại `Thiếu TC`) | Hàng của TC liên quan nếu GAP chỉ rõ mã; GAP không có mã thì **không ghi**, báo user |

**Không ghi gì ngoài hai trường hợp trên.** Cụ thể không ghi: kết quả chạy test (`Pass`, `Chưa Pass 100%`, `Chưa chạy`), bằng chứng, ngày chạy, nhận định riêng. TC không có trong file GAP thì để nguyên ô Note. Không thêm hàng mới vào sheet cho case thiếu.

## Nguồn dữ liệu

File GAP: `gap-testcase-qc-*.md` (mỗi mục `## N. TC_xx — tiêu đề`, có `FR / Loại / Ưu tiên`, `Hiện tại`, `Căn cứ PRD`, `Đề nghị`).
`python3 -I scripts/notes_from_gap.py <gap.md> <out_dir>` sinh `notes.json` (`[GAP PRD v2 · Loại · Ưu tiên] Đề nghị Căn cứ: …`) và `titles.json` (mã → tiêu đề). Mục không có mã TC (thiếu case, chưa có hàng) script in ra để báo user. Mã TC trong GAP là mã của file testcase **mới**; file online phải đã là bản mới — kiểm bằng tiêu đề, không tin riêng mã.
Ghi từng sheet bằng `scripts/build_verify_write.py <notes.json> <titles.json> <tiền tố vd TC_03> "<tên sheet>" S --write`: sinh code Playwright dựng bản đồ hàng từ cột A, **kiểm tiêu đề (cột F) từng ô đích và kiểm ô Note đang trống**, chỉ ghi khi tất cả khớp (chạy không `--write` trước để chỉ kiểm). Chia theo sheet vì mỗi sheet FR là một tab.

`scripts/notes_from_run.py` (đọc `device-test-run-*.md`) đã ngừng dùng cho skill này vì kết quả chạy test không được ghi lên sheet.

## Đầu vào (hỏi nếu thiếu)

**File GAP là bắt buộc. User chưa cung cấp thì HỎI path, không tự đoán, không tự bịa nội dung note.**

1. **File GAP** (`gap-testcase-qc-*.md`) hoặc tài liệu tương đương liệt kê TC cần xác nhận/thiếu case. Tài liệu khác định dạng thì nói rõ cách đọc và chờ user xác nhận trước khi sinh `notes.json`.
2. **Link file Excel online** + tên sheet FR (ví dụ `Đăng nhập`). Thiếu thì hỏi.
3. **Cột Note + round** (ví dụ cột `S`, ROUND 1). Xác nhận bằng ảnh header, không đoán theo chữ cái.

Hỏi gộp một lần mọi mục còn thiếu; mục user đã nêu thì không hỏi lại.

## Quy trình

1. **Sinh notes.json** bằng `notes_from_gap.py`. Đọc lại: mọi note thuộc 1 trong 2 trường hợp trên; không có credential/PII. Mục nào không thuộc hai trường hợp thì bỏ khỏi `notes.json`.
2. **Đăng nhập.** Mở link bằng Playwright. Gặp trang đăng nhập Microsoft thì dừng, bảo user tự đăng nhập (kể cả MFA). Không nhập credential thay user.
3. **Chế độ sửa.** File ở Reading View/"WORKBOOK REPAIRED" → hỏi user trước khi bấm `Fix it` (sửa file chung của người khác). Chỉ ghi khi banner read-only đã mất.
4. **Dựng bản đồ hàng.** `scripts/read_column.js` copy cột A, lưu text vào `layout.txt`, rồi `scripts/build_rowmap.py layout.txt <hàng đầu>`. Dòng trống = header nhóm gộp (bỏ qua, tuyệt đối không ghi vào). Không giả định hàng liên tục. TC có trong `notes.json` mà không có trong sheet → dừng, báo user.
5. **Cho user xem danh sách TC sắp ghi** (số TC cần xác nhận / thiếu case), chờ đồng ý.
6. **Ghi từng ô** (xem "Cách gõ đúng"). Chia 30–40 ô mỗi lượt gọi. Ô đích phải trống trước khi ghi; ô đã có nội dung của người khác thì hỏi.
7. **Kiểm tra.** Zoom 40–50%, cuộn và chụp ảnh toàn sheet: note đúng hàng, header nhóm còn nguyên, không có text lạ ở cột khác.
8. **Báo cáo** cho user: ghi những TC nào, TC nào bỏ qua (thiếu case không có mã), mọi sự cố.

## Cách gõ đúng (đã kiểm chứng; sai là ghi nhầm ô)

Lưới Excel online là canvas; ghi chú theo đúng chuỗi này cho mỗi ô:

1. Click Name Box (`#FormulaBar-NameBox-input`) `clickCount:3`, `Meta+A`, gõ địa chỉ ô, `Enter`.
2. **`Escape`** để trả focus về lưới. Thiếu bước này chữ rơi vào Name Box ("Name an empty range").
3. `keyboard.type(text)` — **không** dùng `insertText` (lưới bỏ qua), tiếng Việt gõ được bằng `type`.
4. `Enter` để commit.

Name Box nằm trong iframe `xlviewerinternal`; locate bằng `page.frames().find(f => f.url().includes('xlviewerinternal'))`.

## Cạm bẫy

- **Autocomplete:** nếu text của ô này là tiền tố của text đã có trong cùng cột, Enter sẽ nối thêm phần còn lại. Đặt phần khác biệt ở **đầu** note (tag trong `[...]`), đừng thêm đuôi vào text nhóm đã dùng.
- **Tuần tự bằng Enter/ArrowDown dễ lệch hàng** và có thể rơi vào cột/hàng header. Luôn nhảy bằng Name Box cho từng ô.
- **Không bấm Undo hàng loạt.** 80 lần Undo làm Excel treo ("Working on it…") và để lại trạng thái nửa vời. Hoàn nguyên bằng Clear Contents theo đoạn (Name Box chọn đoạn → ribbon `Clear` ≈ (1337,129) → `Clear Contents` ≈ (1371,212)) hoặc Version History.
- **Clear theo đoạn tránh header gộp**, ví dụ `S8:S14`, `S16:S50` — không `S8:S91` vì xóa luôn header nhóm.
- Đọc nhiều ô bằng clipboard không ổn định ("Retrieving data…"); kiểm bằng ảnh chụp thay vì copy.
- Excel cuộn/zoom nhớ vị trí cũ; chụp ảnh ngay sau khi ghi để biết vùng nào đang hiển thị.
- Đang có người khác mở file: ghi nhận trong báo cáo, không ghi đè ô của họ. Ô đích phải trống trước khi ghi.

## Nội dung note

- Lấy nguyên từ file GAP (`Đề nghị` + `Căn cứ`); không tự thêm nhận định.
- Note ngắn (1–2 câu), bắt đầu bằng tag `[GAP PRD v2 · Loại · Ưu tiên]`. Không dán lại cả bảng.
- Không ghi credential, tên đăng nhập, dữ liệu cá nhân, đường dẫn máy.

## Sự cố thường gặp

| Hiện tượng | Xử lý |
|---|---|
| Dialog "Fix this workbook?" | Hỏi user, không tự bấm |
| Banner "read-only mode" dù thanh trên ghi Editing | Chờ/hỏi user bấm `Edit Workbook`, reload rồi thử 1 ô |
| Gõ không có chữ vào ô | Chưa Escape sau Name Box, hoặc dùng `insertText` |
| Header nhóm bị ghi đè | Gõ lại nguyên văn (lấy từ bản copy cột A lúc đầu) |
| Excel treo "Working on it" | Dừng thao tác, đợi, reload; không gửi thêm lệnh |

Chi tiết dùng: [USAGE.md](USAGE.md). Agent chạy riêng: [agents/sheet-note-writer.md](agents/sheet-note-writer.md).
