---
name: testcase-parse
description: Parse file testcase của QC (.xlsx) thành CSV, mỗi sheet chức năng = 1 feature → 1 CSV `tc-NN-slug.csv` + `all_testcases.csv` + `_summary.md` + `_links.csv`. Không dùng PRD (so sánh PRD sẽ do skill khác). BẮT BUỘC đọc AGENT.md trước. Luôn HỎI user folder version, file testcase, folder output trước khi chạy (không tự đoán). Trigger — "parse testcase", "testcase ra csv", "convert testcase QC", "/testcase-parse".
---

# Testcase Parse

> **BẮT BUỘC:** khi skill được gọi, việc ĐẦU TIÊN là `Read` file `.claude/skills/testcase-parse/AGENT.md` và làm theo. Chưa đọc AGENT.md thì không hỏi user, không chạy script, không chạy lệnh nào khác.

Đọc file testcase QC (xlsx, mẫu ISC `7.1-BM/PM/HDCV/ISC`), tách theo cụm chức năng (mỗi sheet = 1 feature), xuất CSV. Không đối chiếu PRD.

## Quy ước thư mục

Mỗi version có 1 folder riêng chứa mọi doc của version (PRD, testcase, ...), vd `docs/prd-v1.0/`. Testcase xlsx nằm trong folder đó (có thể trong subfolder), output cũng đặt trong folder đó.

## Bước 1 — HỎI user (bắt buộc, KHÔNG tự đoán, KHÔNG tự `find` rồi chọn)

Hỏi từng mục, chờ user trả lời trước khi chạy:
1. **Path folder version** (vd `docs/prd-v1.0`).
2. **File testcase xlsx** trong folder đó (path/tên file). Có thể liệt kê xlsx trong folder để user chọn, nhưng user phải xác nhận file.
3. **Folder output** — đề xuất `{folder version}/testcase-csv/`, user xác nhận hoặc đổi.

Đã có sẵn câu trả lời trong lệnh user → không hỏi lại mục đó.

## Bước 2 — Chạy

```bash
python3 .claude/skills/testcase-parse/parse_testcase.py <testcase.xlsx> <out_dir>
```

Luôn truyền `out_dir` tường minh (default của script là `csv/` cạnh xlsx, không dùng).
Cần `openpyxl` (`pip3 install openpyxl` nếu thiếu).

## Bước 3 — Báo cáo

Đọc `_summary.md`, báo số TC + số section mỗi feature, tổng TC. Đối chiếu tổng với sheet `Dashboard` của xlsx (cột "Tổng TC").

## Cách script hoạt động

- **Feature:** sheet có ô A (15 dòng đầu) = `Testcase ID`. Mã/tên lấy từ ô C2 (`TC_01`) / C3. Sheet khác (Cover, Summary, RTM, Bug Data...) bị bỏ qua.
- **Section (cụm con):** dòng `▬▬ 1. Phân quyền · 7 TC` → cột `section`.
- **Cột:** `feature_code, feature, sheet, section` + cột thiết kế TC (Testcase ID, Req ID, DOC Source, Group, Priority, Test Title, Pre-condition, Test Steps, Expected Result, ...). Cột kết quả chạy lặp theo ROUND bị cắt, chỉ giữ ROUND đầu.
- CSV `utf-8-sig` (Excel mở đúng tiếng Việt), ô nhiều dòng giữ nguyên xuống dòng.

## Liên kết giữa feature (`_links.csv`)

File xlsx KHÔNG có link tường minh (Req ID không dùng chung giữa sheet, không ref `TC_xx` chéo, RTM chỉ 1 Req ↔ 1 feature). Script suy ra heuristic:
- `mentions`: TC của feature A nhắc tên feature B trong Title/Pre-condition/Steps/Expected (kèm TC ID làm evidence).
- `shared-section`: section trùng tên ở ≥2 sheet (vd "Phân quyền", "Tìm kiếm").
- Feature bị nhắc bởi hầu hết TC khác (vd Đăng nhập) = tiền điều kiện chung, không phải phụ thuộc thật — khi báo cáo, tách riêng.

## Lưu ý

- Chỉ đọc, không sửa xlsx.
- Template QC đổi layout → sửa `HEADER_KEY` / `parse_sheet` trong script.
