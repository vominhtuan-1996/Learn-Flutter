# AGENT — testcase-prd-compare

Quy tắc cho agent khi chạy skill này.

## Mục đích

Testcase sinh ra để test các case của PRD. Với 1 FR, chỉ cần biết **từng TC có Pass hay không**:

- **Pass** = TC kiểm đúng một case có trong PRD FR và Expected Result khớp PRD. Đây là đối chiếu tài liệu, không phải kết quả chạy app.
- **Note** = chưa Pass vì: `TC dư / ngoài PRD`, `TC lệch PRD`, hoặc `Chưa rõ`. Chỉ ghi lại để QC/BA xem, không nặng lời, không bắt buộc sửa.
- Mục PRD không có TC → note `PRD chưa có TC` ở cấp mục PRD.

PRD là nguồn chuẩn. Khi PRD và TC khác nhau → note ở TC; không kết luận "PRD sai" hay đề xuất sửa PRD theo TC. Chỉ khi PRD tự mâu thuẫn/mơ hồ mới ghi "PRD cần làm rõ" (hỏi chủ PRD, không tự chọn bên). Không sửa PRD, testcase, code.

## Trình tự bắt buộc

0. Đã đọc file này (AGENT.md) trước mọi bước khác.
1. **HỎI user, chờ trả lời, KHÔNG đoán**: (a) folder version, (b) FR nào (hoặc tất cả), (c) xác nhận cặp FR ↔ `tc-NN-*.csv`. Mục nào user đã nêu thì không hỏi lại.
   - Được liệt kê folder FR / file CSV để user chọn; không tự chọn thay user.
   - Thiếu `testcase-csv/` hoặc `_rtm.csv` → báo user chạy `/testcase-parse` trước (không tự chạy khi chưa được hỏi).
2. Chạy `compare_fr.py` cho từng FR (cú pháp ở SKILL.md); output `{FR folder}/testcase-compare.md`.
3. **Review ngữ nghĩa** cho từng FR. Đi qua **từng TC** trong CSV (không chỉ mẫu) và gán đúng một kết luận:
   - Đọc Title/Steps/Expected, tìm mục PRD tương ứng (BR, bước, field, message).
   - Có căn cứ PRD và Expected khớp → **Pass**.
   - Expected khác PRD (giá trị, message, quy tắc) → **Note: TC lệch PRD**, nêu PRD nói gì / TC nói gì.
   - Không có căn cứ trong PRD (TC orphan hoặc tiêu chí vượt PRD) → **Note: TC dư / ngoài PRD**, gắn `[NGOÀI PRD — QC XÁC NHẬN]`. Một TC vừa có phần theo PRD vừa có tiêu chí ngoài PRD → chỉ note phần vượt phạm vi; phần có căn cứ vẫn tính, nêu rõ trong ghi chú.
   - PRD mơ hồ/mâu thuẫn hoặc không đủ căn cứ để kết luận → **Note: Chưa rõ**, đồng thời ghi vào `### PRD cần làm rõ`.
   - `uncovered` → tìm tay trong TC (`grep` theo từ khóa PRD). Thật sự không có TC → `### PRD chưa có TC`; có TC → "false gap" kèm TC ID.
   - `text-only` → mở 2–3 TC xác nhận có kiểm đúng mục PRD hay nối nhầm do từ chung.
   - Orphan chỉ là ứng viên cho đến khi đã đối chiếu PRD và nội dung TC; không tự động kết luận.
   - Chỉ ghi điều đã kiểm chứng, không suy đoán. Mỗi note: TC ID / mục PRD / vấn đề / đề nghị (QC xác nhận nguồn hoặc chỉnh TC theo PRD).
4. Thêm mục `## Nhận xét review` cuối `testcase-compare.md` (script không tạo mục này; thêm bằng Edit) theo mẫu:

   ```
   ## Nhận xét review

   ### Kết quả theo TC
   TC Pass: N/M
   TC Note: K
   Gap xác nhận: G

   Pass: TC_01.9, TC_01.22, ...

   | TC | Loại note | Ghi chú |
   |---|---|---|
   | TC_01.8 | Chưa rõ | BR01-03 chưa nói rõ ... |
   | TC_01.12 | [NGOÀI PRD — QC XÁC NHẬN] | PRD không đặc tả nguyên văn thông báo ... |

   ### PRD chưa có TC
   - ... (hoặc: Không phát hiện.)

   ### PRD cần làm rõ
   - ... (hoặc: Không có.)

   ### Testcase ngoài phạm vi PRD
   - [NGOÀI PRD — QC XÁC NHẬN] TC_01.xx–xx: ... (hoặc: Không phát hiện testcase ngoài phạm vi PRD đã xác nhận.)
   ```
   - Ba dòng đếm `TC Pass: N/M`, `TC Note: K`, `Gap xác nhận: G` mỗi dòng riêng, đúng cú pháp — `summarize.py` đọc. N + K = M (M = số TC của FR); mỗi TC xuất hiện đúng một lần (trong danh sách Pass hoặc bảng Note). G = số mục PRD chưa có TC đã xác nhận.
   - Tiểu mục `### Testcase ngoài phạm vi PRD` luôn có.
   - Note nên đủ ngắn để dán thẳng vào cột Note của file testcase (xem skill `testcase-sheet-notes`).
5. Sau khi xong mọi FR được chọn: chạy `python3 .claude/skills/testcase-prd-compare/summarize.py <folder version>` → `testcase-compare-summary.md` (bảng mỗi FR + tổng).
6. Báo cáo ngắn mỗi FR: `TC Pass N/M`, `TC Note K`, mục PRD chưa có TC, 3–5 note quan trọng nhất, path report.

## Không làm

- Không đoán path / FR / cặp TC.
- Không kết luận "thiếu TC" chỉ dựa vào `uncovered`/`text-only` — script chỉ gợi ý.
- Không đánh giá TC theo kết quả chạy app; "Pass" ở đây chỉ nghĩa là TC khớp PRD.
- Không coi TC dư/ngoài PRD là lỗi nặng hay PRD gap; chỉ note.
- Không sửa `index.md`, CSV, xlsx.
- Không đề xuất sửa PRD cho khớp TC; đề xuất luôn nhắm vào TC (sửa/thêm/xóa).
- Không ghi file ngoài `testcase-compare.md` của FR và `testcase-compare-summary.md` của folder version.
- Không commit report trừ khi user yêu cầu.

## Sửa script

- PRD đổi format bảng → sửa `extract_items`. RTM đổi cột → sửa `rtm_map`.
- Sửa xong chạy lại trên FR mẫu (FR01 ↔ TC_01), kiểm số mục trích được.

## Files

- `SKILL.md` — định nghĩa skill + trigger
- `USAGE.md` — hướng dẫn người dùng
- `compare_fr.py` — so sánh máy móc
- `summarize.py` — gộp report các FR thành bảng summary
- `require_agent_read.py` — hook PreToolUse(Bash), chặn chạy `compare_fr.py` nếu chưa Read AGENT.md (đăng ký trong `.claude/settings.json`)
