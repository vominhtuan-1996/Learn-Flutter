---
name: testcase-update
description: Nhập file testcase mới của QC (.xlsx, do user cung cấp) vào repo khi PRD đổi — parse bằng testcase-parse vào thư mục tạm, so với testcase-csv hiện có (thêm/bỏ/đổi mã/tái sử dụng mã/đổi thiết kế), kiểm dữ liệu, đối chiếu với danh sách TC bị ảnh hưởng của prd-update, áp dụng vào testcase-csv sau khi user đồng ý, rồi liệt kê tài liệu/flow còn tham chiếu TC cũ. Dùng khi user đưa file testcase đã cập nhật và yêu cầu "update testcase", "cập nhật testcase theo PRD mới", "so sánh testcase mới với bản cũ"; nếu user chưa đưa file thì HỎI path; không dùng để tự viết/sửa nội dung testcase.
---

# Testcase Update

Đưa **file testcase mới do QC cung cấp** vào repo và biết chính xác cái gì đã đổi so với bản trước. Skill **không tự viết hay sửa nội dung TC** (việc của QC); nó nhập, so sánh, kiểm tra, áp dụng và chỉ ra việc phải làm lại.

> **BẮT BUỘC:** việc đầu tiên khi skill được gọi là `Read` `.claude/skills/testcase-update/AGENT.md` và làm theo. Vì skill dùng `testcase-parse`, phải `Read` cả `.claude/skills/testcase-parse/AGENT.md` trước khi chạy `parse_testcase.py` (hook chặn nếu chưa đọc).

## Đầu vào (HỎI nếu thiếu, không tự đoán, không tự `find` rồi chọn)

**File testcase mới là bắt buộc. User chưa đưa → hỏi path** (hoặc file tương đương: CSV đã parse theo `testcase-parse`). Hỏi gộp một lần các mục còn thiếu:

1. **File testcase mới** (`.xlsx` mẫu ISC `7.1-BM/PM/HDCV/ISC`, hoặc thư mục CSV đã parse).
2. **Folder version** (vd `learnflutter/docs/prd-v1.0`) — nơi có `testcase-csv/` hiện tại.
3. **Tùy chọn:** `prd-<ver>-impact.md` (đầu ra của `prd-update`) để biết TC nào đã được dặn sửa; `prd-<ver>-changes.md` để lấy từ khóa cũ cần biến mất.
4. Nơi lưu xlsx mới: đề xuất `<folder version>/testcase/` với tên do user đặt. **Không ghi đè xlsx cũ.**

Chưa có `testcase-csv/` (chưa từng parse) → đề nghị chạy `testcase-parse` trước, không dùng skill này.

## Quy trình

1. **Hỏi và xác nhận đầu vào** (trên). Lưu xlsx mới vào folder đã thống nhất nếu user chưa đặt.
2. **Parse vào thư mục tạm**, không vào repo:
   `python3 .claude/skills/testcase-parse/parse_testcase.py <xlsx_mới> <scratch>/new`
   Đối chiếu tổng TC với sheet `Dashboard` (như `testcase-parse`); lệch thì báo user, không tự sửa số.
3. **So sánh** với testcase hiện có:
   `python3 -I scripts/tc_diff.py <folder>/testcase-csv <scratch>/new --json <scratch>/diff.json > <scratch>/diff.md`
   Đọc kết quả. Script **ghép TC cũ↔mới theo tiêu đề** (trùng chính xác, rồi giống ≥0.85) vì QC thường bỏ/chèn TC rồi đánh số lại cả loạt; so theo mã sẽ báo sai hàng trăm TC. Bỏ nhãn `(setup)` QC thêm vào bước chuẩn bị. Các nhóm: **Thêm**, **Bỏ**, **Đổi mã** (cùng TC, mã khác — tham chiếu theo mã cũ trỏ nhầm), **Tái sử dụng mã** (mã có ở cả "bỏ" và "thêm" — nguy hiểm vì flow Maestro, bằng chứng, báo cáo chạy cũ trỏ nhầm TC), **Đổi thiết kế** (Title/Steps/Expected/Req ID…, khóa theo mã cũ), **Đổi kết quả** (cột Review/Kết quả/Note, không cần chạy lại).
4. **Kiểm dữ liệu** TC mới: `python3 -I scripts/check_tc.py <scratch>/new --stale "<regex từ khóa cũ>"`. Lỗi: ID trùng/sai định dạng, Title/Steps/Expected rỗng, Expected tham chiếu bước không có trong Steps, còn từ khóa cũ (lấy từ `prd-<ver>-changes.md`, vd `OpenStreetMap|Thanh lý`).
5. **Đối chiếu impact** (nếu có): `python3 -I scripts/impact_check.py <prd-<ver>-impact.md> <scratch>/diff.json > <scratch>/check.md`.
   - **Đã sửa** → đọc Title/Steps/Expected mới và đối chiếu với PRD hiện hành (`NN-frNN/index.md`) xem có khớp không.
   - **Còn cũ** → TC bị dặn sửa mà QC chưa sửa; báo QC.
   - **Đổi ngoài danh sách** → xem thay đổi có đúng ý không (có thể là sửa lỗi riêng của QC).
6. **Trình bày cho user** tóm tắt (số TC mỗi nhóm, các cảnh báo: tái sử dụng mã, lỗi dữ liệu, TC còn cũ) và **chờ đồng ý** trước khi ghi vào repo.
7. **Áp dụng** (chạy khô trước):
   `python3 -I scripts/apply_parse.py <scratch>/new <folder>/testcase-csv` rồi thêm `--apply`. Thêm `--prune` chỉ khi user đồng ý xóa file feature không còn. Script không đụng file kết quả chạy `tc-NN-result-<ngày>.csv`. File có thể báo "GHI ĐÈ" dù nội dung TC không đổi (khác xuống dòng/khoảng trắng) — vẫn an toàn, xem `git diff`.
8. **Tìm tham chiếu còn lại:** `python3 -I scripts/stale_refs.py <folder> learnflutter/lib <scratch>/diff.json` (quét `.md/.csv/.yaml`: báo cáo compare/gap/chạy test, flow Maestro).
9. **Viết báo cáo** `<folder>/testcase-update-<yyyy-mm-dd>.md` (mẫu dưới) rồi nêu việc nên làm tiếp (mục "Sau khi cập nhật").
10. **Kiểm tra cuối:** `git status`/`git diff --stat` đúng các file mong đợi; tổng TC trong `_summary.md` khớp `tc_diff`.

## Sau khi cập nhật — skill nên chạy lại (đề nghị, không tự chạy)

| Việc | Khi nào | Skill |
|---|---|---|
| Làm mới đối chiếu PRD ↔ TC | Có TC thêm/bỏ/đổi thiết kế | `testcase-prd-compare` |
| Làm mới đối chiếu TC ↔ code | Có TC thêm/đổi thiết kế | `testcase-codebase-compare` |
| Tạo/sửa Maestro flow | TC mới hoặc đổi thiết kế đã có flow; TC bị đổi/tái sử dụng mã | `testcase-maestro-flow` |
| Chạy lại test và lưu kết quả | TC đổi thiết kế (kết quả cũ không còn hợp lệ) | `testcase-run-report` |
| Ghi note lên file testcase online | Cần báo TC còn cũ hoặc kết quả mới cho QC | `testcase-sheet-notes` |

## Mẫu `testcase-update-<ngày>.md`

```
# Cập nhật testcase — <ngày>
> File mới: <path xlsx> (Dashboard: N TC). Bản trước: testcase-csv/ (M TC). PRD tham chiếu: prd-<ver>-impact.md.
## Tóm tắt
THÊM a · BỎ b · ĐỔI MÃ c · TÁI SỬ DỤNG MÃ d · ĐỔI THIẾT KẾ e · ĐỔI KẾT QUẢ f
## Cảnh báo   (tái sử dụng mã, lỗi dữ liệu check_tc)
## Đối chiếu impact   (đã sửa / còn cũ / đổi ngoài danh sách)
## Chi tiết thay đổi   (dán tc_diff.md)
## Tham chiếu còn lại   (dán stale_refs)
## Việc nên làm tiếp
```

## Không làm

- Không sửa/viết nội dung TC, không sửa xlsx của QC, không đoán ý QC khi TC mâu thuẫn PRD (ghi nhận, báo user).
- Không ghi `testcase-csv/` trước khi user đồng ý; không chạm file kết quả chạy.
- Không sửa mã TC trong flow/báo cáo cũ bằng tay; chạy lại skill tương ứng.
- Không commit trừ khi user yêu cầu.

Chi tiết dùng: [USAGE.md](USAGE.md). Quy tắc agent: [AGENT.md](AGENT.md).
