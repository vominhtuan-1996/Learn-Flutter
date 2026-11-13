# USAGE — testcase-run-report

Chạy các Maestro flow của một FR rồi lưu summary, ảnh bằng chứng và CSV kết quả vào `learnflutter/docs/prd-v1.0`.

## Gọi

```text
/testcase-run-report
FR: learnflutter/docs/prd-v1.0/02-fr02-trang-chu
Testcase: learnflutter/docs/prd-v1.0/testcase-csv/tc-02-trang-chu.csv
Flow: learnflutter/lib/features/home/.maestro
Executed By: tuanvm37
```

Chỉ chạy một phần: thêm `TC ID: TC_02.48, TC_02.49`. Thiết bị khác Simulator đang boot: nêu UDID.

## Kết quả

| File | Nội dung |
|---|---|
| `<FR>/maestro-test-run-YYYY-MM-DD.md` | Summary: Pass 100%, cần theo dõi, chưa chạy, GAP, ghi chú runner, ảnh bằng chứng |
| `<FR>/evidence/tc-NN-<số>-<mô-tả>.png` | Ảnh bằng chứng, đã loại PII |
| `testcase-csv/tc-NN-result-YYYY-MM-DD.csv` | Mỗi TC một dòng: Kết quả, Note, Flow, Executed By, Ngày chạy — để dán vào sheet QC |

Mẫu tham chiếu: `02-fr02-trang-chu/maestro-test-run-2026-10-08.md` và `testcase-csv/tc-02-result-2026-10-08.csv`; FR01: `01-fr01-dang-nhap/device-test-run-2026-10-07.md`.

## Chạy tay bằng script

```bash
.claude/skills/testcase-run-report/run_flows.sh \
  learnflutter/lib/features/home/.maestro 'tc_02_*.yaml' /tmp/results.tsv
```

Ghi `flow / exit / seconds / debug_dir`; exit khác 0 là flow fail, mở `debug_dir` để xem ảnh lúc fail.

## Không làm

Skill không viết flow mới (dùng `testcase-maestro-flow`), không sửa testcase gốc, không điều khiển iPhone thật, không ghi vào SharePoint/Excel, không commit nếu user chưa yêu cầu.
