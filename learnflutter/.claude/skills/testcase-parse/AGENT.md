# AGENT — testcase-parse

Quy tắc cho agent khi chạy skill này.

## Mục đích

Parse xlsx testcase QC → CSV theo feature (feature = sheet chức năng). KHÔNG đọc/đối chiếu PRD (việc của skill so sánh riêng). Chỉ đọc xlsx, không sửa.

## Trình tự bắt buộc

0. Đã đọc file này (AGENT.md) trước mọi bước khác — bước 1 chỉ bắt đầu sau khi đọc xong.
1. **HỎI user, chờ trả lời, KHÔNG đoán**: (a) path folder version, (b) file testcase xlsx trong folder, (c) folder output (đề xuất `{folder version}/testcase-csv/`). Mục nào user đã nêu trong lệnh thì không hỏi lại.
   - Được liệt kê xlsx trong folder để user chọn; không tự chọn thay user.
2. Chạy: `python3 .claude/skills/testcase-parse/parse_testcase.py <xlsx> <out_dir>` — luôn truyền `out_dir` tường minh.
   - Thiếu `openpyxl` → `pip3 install openpyxl`, chạy lại.
3. Đọc `<out_dir>/_summary.md`, đối chiếu tổng TC với sheet `Dashboard` của xlsx. Lệch → báo user, không tự sửa số.
4. Báo cáo ngắn: số TC + số section mỗi feature, tổng TC, đường dẫn output.

## Về `_links.csv`

- Không có link tường minh trong xlsx; file là heuristic theo tên feature / section trùng.
- Khi báo cáo: tách "tiền điều kiện chung" (feature bị nhắc bởi ≥ ~90% TC của feature khác, vd Đăng nhập) khỏi liên kết thật.
- Không khẳng định phụ thuộc chắc chắn; nêu là suy đoán kèm evidence.

## Không làm

- Không đoán path, không chọn file thay user.
- Không ghi đè file ngoài `out_dir`; không sửa xlsx/PRD.
- Không dùng PRD để map feature (đã bỏ có chủ đích).
- Không commit output CSV trừ khi user yêu cầu.

## Sửa script

- Template QC đổi layout → sửa `HEADER_KEY` / `parse_sheet` trong `parse_testcase.py`.
- Sửa xong chạy lại trên xlsx mẫu, đối chiếu tổng TC với Dashboard.
- Script có comment `ponytail`-style tối thiểu; giữ ngắn, không thêm framework.

## Files

- `SKILL.md` — định nghĩa skill + trigger
- `USAGE.md` — hướng dẫn người dùng
- `parse_testcase.py` — parser
- `require_agent_read.py` — hook PreToolUse(Bash), chặn chạy parser nếu chưa Read AGENT.md (đăng ký trong `.claude/settings.json`)
