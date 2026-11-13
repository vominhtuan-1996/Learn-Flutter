# AGENT — testcase-update

Quy tắc cho agent khi chạy skill `testcase-update`.

## Mục đích

Nhập file testcase mới của QC, so với `testcase-csv/` hiện có, báo thay đổi và việc phải làm lại. Không viết/sửa nội dung TC. PRD là nguồn chuẩn: TC mới lệch PRD → ghi nhận cho QC.

## Trình tự bắt buộc

0. Đã đọc file này; đã `Read` `.claude/skills/testcase-parse/AGENT.md` (hook chặn `parse_testcase.py` nếu chưa đọc).
1. **Hỏi user, chờ trả lời, KHÔNG đoán:** path file testcase mới (xlsx hoặc CSV đã parse); folder version; (tùy chọn) `prd-<ver>-impact.md` và `prd-<ver>-changes.md`; nơi lưu xlsx mới. User chưa đưa file → hỏi path hoặc file tương đương; không tự `find` rồi chọn, không dùng xlsx cũ làm "bản mới". Mục user đã nêu thì không hỏi lại.
2. Parse vào **scratchpad** (không vào repo). Thiếu `openpyxl` → `pip3 install openpyxl`. Đối chiếu tổng TC với Dashboard.
3. `tc_diff.py` → đọc từng nhóm. **Tái sử dụng mã là cảnh báo cao nhất**: nêu rõ vì flow Maestro, bằng chứng và báo cáo chạy cũ trỏ nhầm TC.
4. `check_tc.py` với `--stale` lấy từ danh sách thay đổi PRD; lỗi dữ liệu báo cho user, không tự sửa CSV.
5. `impact_check.py` nếu có impact. Với TC "Đã sửa": **đọc** Title/Steps/Expected mới và đối chiếu PRD hiện hành, rồi kết luận khớp/không khớp từng TC; không chỉ tin việc "có đổi".
6. Tóm tắt cho user và **chờ đồng ý** trước khi ghi `testcase-csv/`. Chạy `apply_parse.py` khô, đưa danh sách file, rồi mới `--apply`.
7. `stale_refs.py`, viết `testcase-update-<ngày>.md`, nêu việc nên làm tiếp (đề nghị skill, không tự chạy).
8. Báo cáo ngắn: số TC mỗi nhóm, cảnh báo, TC còn cũ, file đã ghi, đường dẫn báo cáo.

## Quy tắc diễn giải

- **Đổi thiết kế** (Title/Steps/Expected/Req ID/Priority/section…) → kết quả chạy cũ không còn hợp lệ, TC cần chạy lại. **Đổi cột kết quả/Note** → không cần chạy lại.
- **Ghép theo tiêu đề, không theo mã.** Đổi mã = cùng TC, mã khác (nêu điểm bắt đầu mỗi đoạn lệch). Ghép sai chỉ khi tiêu đề bị sửa nhiều (<0.85) — khi đó TC hiện ra là "bỏ + thêm"; kết luận cuối là của người dùng/QC.
- Impact và báo cáo cũ dùng **mã cũ**; `impact_check` và `design` khóa theo mã cũ, bảng đổi mã cho biết mã mới.
- **Không giả định** RTM lỗi thời hay mới; đọc `_rtm.csv` sau khi áp dụng và nêu thay đổi Req ID nếu có.
- TC "Còn cũ" so với impact là việc của QC; nêu rõ lệch gì (từ impact), không tự sửa TC.

## Không làm

- Không sửa nội dung TC, xlsx của QC, PRD, code.
- Không ghi đè `testcase-csv/` khi chưa được đồng ý; không chạm `tc-NN-result-*.csv`.
- Không đoán path file; không dùng bản parse nằm trong repo làm "bản mới".
- Không undo/hoàn nguyên hàng loạt; hoàn tác bằng `git`.
- Không commit trừ khi user yêu cầu.

## Files

- `SKILL.md` — định nghĩa skill, quy trình, mẫu báo cáo
- `USAGE.md` — hướng dẫn người dùng
- `AGENT.md` — quy tắc agent (file này)
- `scripts/tcids.py` — tiện ích dùng chung (đọc CSV, bung danh sách TC ID)
- `scripts/tc_diff.py` — so sánh 2 bộ CSV theo Testcase ID
- `scripts/check_tc.py` — kiểm dữ liệu TC mới
- `scripts/impact_check.py` — đối chiếu impact ↔ TC mới
- `scripts/apply_parse.py` — áp dụng vào `testcase-csv/` (mặc định chạy khô)
- `scripts/stale_refs.py` — tìm nơi còn tham chiếu TC bị ảnh hưởng
