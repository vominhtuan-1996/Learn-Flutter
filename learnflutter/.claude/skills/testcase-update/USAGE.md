# USAGE — testcase-update

Nhập file testcase mới của QC vào repo khi PRD đổi.

## Chuẩn bị

1. Đã có `docs/prd-vX/testcase-csv/` (từ `testcase-parse`).
2. **File testcase mới của QC** (`.xlsx` mẫu ISC) — bạn cung cấp; nếu chưa đưa, Claude sẽ hỏi path.
3. Tùy chọn: `prd-<ver>-impact.md` và `prd-<ver>-changes.md` (từ `prd-update`).
4. `openpyxl` (`pip3 install openpyxl` nếu thiếu).

## Cách 1 — Skill

```
/testcase-update
```

Claude đọc AGENT.md, hỏi: path file testcase mới, folder version, có impact/changes không, nơi lưu xlsx. Sau đó parse, so sánh, kiểm tra, trình bày tóm tắt; bạn đồng ý rồi mới ghi vào `testcase-csv/`.

Lời nhắc tự nhiên:

> dùng testcase-update với file learnflutter/docs/prd-v1.0/testcase/ISC_Onmember_v1.7_TestCase_v1.1.xlsx, so với testcase hiện tại và impact của PRD v2.

## Cách 2 — Script (từng bước)

```bash
S=.claude/skills/testcase-update/scripts
V=learnflutter/docs/prd-v1.0
T=/tmp/tc-update            # thư mục tạm
python3 .claude/skills/testcase-parse/parse_testcase.py <testcase_mới.xlsx> $T/new
python3 -I $S/tc_diff.py $V/testcase-csv $T/new --json $T/diff.json > $T/diff.md
python3 -I $S/check_tc.py $T/new --stale "OpenStreetMap|Thanh lý"
python3 -I $S/impact_check.py $V/prd-v2-impact.md $T/diff.json > $T/check.md
python3 -I $S/apply_parse.py $T/new $V/testcase-csv            # chạy khô
python3 -I $S/apply_parse.py $T/new $V/testcase-csv --apply     # ghi thật (thêm --prune nếu cần xóa feature cũ)
python3 -I $S/stale_refs.py $V learnflutter/lib $T/diff.json
```

## Kết quả

- `testcase-csv/` cập nhật theo file mới (chưa commit): `tc-NN-*.csv`, `all_testcases.csv`, `_rtm.csv`, `_links.csv`, `_summary.md`. File kết quả chạy `tc-NN-result-*.csv` giữ nguyên.
- `testcase-update-<ngày>.md` — tóm tắt, cảnh báo, đối chiếu impact, chi tiết thay đổi, tham chiếu còn lại, việc nên làm tiếp.

## Đọc kết quả `tc_diff`

| Nhóm | Ý nghĩa | Cần làm |
|---|---|---|
| Thêm / Bỏ | TC mới / TC không còn | Cập nhật báo cáo so sánh, flow |
| Đổi mã | Cùng TC (ghép theo tiêu đề) nhưng mã khác, thường do QC đánh số lại cả loạt | Sửa tham chiếu tới mã cũ (flow, báo cáo chạy) |
| **Tái sử dụng mã** | Mã có ở cả "bỏ" và "thêm" (cùng mã, TC khác) | **Cảnh báo cao**: flow/báo cáo chạy cũ trỏ nhầm |
| Đổi thiết kế | Đổi Title/Steps/Expected/Req ID… | Chạy lại TC; kết quả cũ không còn hợp lệ |
| Đổi kết quả | Đổi cột Kết quả/Note | Không cần chạy lại |

## Lưu ý

| Điều | Giải thích |
|---|---|
| Không sửa nội dung TC | Việc của QC; skill chỉ nhập, so sánh, kiểm |
| Không ghi `testcase-csv/` khi chưa đồng ý | Luôn chạy khô trước |
| Báo "GHI ĐÈ" nhưng không đổi nội dung | Khác xuống dòng/khoảng trắng; xem `git diff` |
| TC còn cũ so với impact | Báo QC; có thể ghi note lên file online bằng `testcase-sheet-notes` |
| Hoàn tác | `git checkout -- <file>` |
