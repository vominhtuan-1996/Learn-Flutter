# USAGE — testcase-prd-compare

So sánh PRD (theo FR) với testcase QC của FR đó.

Testcase sinh ra để test các case của PRD, nên skill chỉ trả lời: **mỗi TC có Pass không?** Pass = TC kiểm đúng một case PRD và Expected khớp PRD (đối chiếu tài liệu, không phải chạy app). PRD chưa có TC, TC dư/ngoài PRD, TC lệch hoặc chưa rõ → chỉ ghi **Note**.

## Chuẩn bị

1. `prd-breakdown` đã chạy: có `docs/prd-vX/NN-frNN-*/index.md`.
2. `testcase-parse` đã chạy: có `docs/prd-vX/testcase-csv/` (`tc-NN-*.csv`, `_rtm.csv`).

## Cách 1 — Skill

```
/testcase-prd-compare
```

Claude đọc AGENT.md, rồi hỏi: folder version, FR (hoặc tất cả), xác nhận cặp FR ↔ TC CSV.

## Cách 2 — Script

```bash
python3 .claude/skills/testcase-prd-compare/compare_fr.py \
  docs/prd-v1.0/01-fr01-dang-nhap/index.md \
  docs/prd-v1.0/testcase-csv/tc-01-dang-nhap.csv \
  docs/prd-v1.0/testcase-csv/_rtm.csv \
  docs/prd-v1.0/01-fr01-dang-nhap/testcase-compare.md
```

## Summary dạng bảng

```bash
python3 .claude/skills/testcase-prd-compare/summarize.py docs/prd-v1.0
```

Ghi `docs/prd-v1.0/testcase-compare-summary.md`: 1 dòng/FR (Mục PRD, Covered, Text-only, Uncovered, % Covered, #TC, TC Pass, TC Note, TC orphan, Gap xác nhận, link report) + dòng tổng. Skill tự chạy bước này sau khi so sánh xong các FR.

## Đọc report

| Mục | Ý nghĩa |
|-----|---------|
| `covered` | Nối PRD ↔ TC qua RTM (đáng tin) |
| `text-only` | Chỉ khớp text — cần xem lại, từ chung dễ nối nhầm |
| `uncovered` | Không thấy TC — ứng viên gap, cần agent xác nhận |
| orphan | TC không nối mục PRD nào — mặc định TC thừa/ngoài scope |

Script chỉ nối máy móc; mục **Nhận xét review** (agent thêm) mới là kết luận, gồm:

| Phần | Nội dung |
|------|----------|
| `TC Pass: N/M`, `TC Note: K` | Số TC khớp PRD / số TC có note (N + K = M) |
| Danh sách Pass + bảng Note | Mỗi TC đúng một dòng; note ghi loại (`TC lệch PRD`, `[NGOÀI PRD — QC XÁC NHẬN]`, `Chưa rõ`) và 1–2 câu |
| `### PRD chưa có TC` | Mục PRD không có TC (`Gap xác nhận: G`) |
| `### PRD cần làm rõ` | PRD mơ hồ/mâu thuẫn — hỏi chủ PRD |
| `### Testcase ngoài phạm vi PRD` | TC/tiêu chí dư, cần QC xác nhận nguồn |

Note được viết ngắn để dán vào cột Note của file testcase (skill `testcase-sheet-notes`).

## Lỗi thường gặp

| Triệu chứng | Xử lý |
|-------------|-------|
| `Không trích được mục nào từ PRD FR` | Format bảng PRD khác mẫu → sửa `extract_items` |
| Nhiều `text-only` | RTM chỉ ghi cấp bảng/màn, bình thường; agent review tay |
| Thiếu `_rtm.csv` | Chạy lại `/testcase-parse`, hoặc truyền `-` (kém chính xác) |
