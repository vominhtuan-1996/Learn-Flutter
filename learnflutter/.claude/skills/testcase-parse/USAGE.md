# USAGE — testcase-parse

Hướng dẫn cho người dùng: parse testcase QC (xlsx) → CSV theo feature.

## Chuẩn bị

Mỗi version 1 folder chứa doc của version, ví dụ:

```
docs/prd-v1.0/
├── ISC_..._PRD_v1.0.docx.md
├── testcase/ISC_Onmember_v1.7_TestCase_v1.0.xlsx
└── testcase-csv/            ← output (skill tạo)
```

Yêu cầu: `python3`, `openpyxl` (`pip3 install openpyxl`).

## Cách 1 — Gọi skill trong Claude Code

```
/testcase-parse
```

Claude sẽ hỏi lần lượt (không tự đoán):
1. Path folder version
2. File testcase xlsx trong folder đó
3. Folder output (đề xuất `{folder version}/testcase-csv/`)

## Cách 2 — Chạy script trực tiếp

```bash
python3 .claude/skills/testcase-parse/parse_testcase.py <testcase.xlsx> <out_dir>
```

Ví dụ:

```bash
python3 .claude/skills/testcase-parse/parse_testcase.py \
  learnflutter/docs/prd-v1.0/testcase/ISC_Onmember_v1.7_TestCase_v1.0.xlsx \
  learnflutter/docs/prd-v1.0/testcase-csv
```

## Output

| File | Nội dung |
|------|----------|
| `tc-NN-slug.csv` | 1 feature (= 1 sheet chức năng), vd `tc-03-quan-ly-thiet-bi.csv` |
| `all_testcases.csv` | Gộp mọi feature |
| `_summary.md` | Số TC, số section mỗi feature |
| `_links.csv` | Liên kết giữa feature (heuristic): `mentions`, `shared-section` |
| `_rtm.csv` | Req ID → nguồn trong PRD (§, BR, field) từ sheet RTM; skill `testcase-prd-compare` dùng |

Cột CSV: `feature_code, feature, sheet, section, Testcase ID, Req ID, DOC Source, Group, Priority, Test Title, Pre-condition, Test Steps, Expected Result, Origin, Review, ...` (chỉ giữ ROUND đầu, bỏ cột kết quả lặp).

CSV encoding `utf-8-sig` → mở bằng Excel đúng tiếng Việt.

## Kiểm tra kết quả

- Tổng TC trong `_summary.md` phải bằng cột "Tổng TC" ở sheet `Dashboard` của xlsx.
- `_links.csv` là suy đoán theo tên — xem cột `evidence` (Testcase ID) để kiểm lại. Feature "Đăng nhập" bị nhắc ở hầu hết TC = tiền điều kiện chung, không phải phụ thuộc thật.

## Lỗi thường gặp

| Triệu chứng | Nguyên nhân / cách xử lý |
|-------------|--------------------------|
| `ModuleNotFoundError: openpyxl` | `pip3 install openpyxl` |
| Không ra feature nào | Sheet không có ô cột A = `Testcase ID` trong 15 dòng đầu → template khác, sửa `HEADER_KEY` / `parse_sheet` |
| Tổng TC lệch Dashboard | Dòng TC thiếu `Testcase ID` (bị bỏ qua) — kiểm sheet xlsx |
