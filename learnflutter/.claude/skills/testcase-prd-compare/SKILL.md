---
name: testcase-prd-compare
description: Đối chiếu 1 FR của PRD với testcase CSV do user chỉ định, chỉ để biết từng TC có Pass (kiểm đúng case PRD, Expected khớp PRD) hay không; PRD chưa có TC, TC dư/ngoài PRD, TC lệch hoặc chưa rõ thì ghi Note; ghi testcase-compare.md trong folder FR. Dùng khi user yêu cầu đối chiếu PRD với testcase hoặc hỏi testcase có phủ PRD không; phân biệt với skill đối chiếu testcase và codebase.
---

# Testcase Compare

> **BẮT BUỘC:** khi skill được gọi, việc ĐẦU TIÊN là `Read` file `.claude/skills/testcase-prd-compare/AGENT.md` và làm theo. Chưa đọc AGENT.md thì không hỏi user, không chạy script, không chạy lệnh nào khác.

So sánh từng FR: PRD (`{NN}-frNN-*/index.md`) ↔ testcase (`testcase-csv/tc-NN-*.csv`). Tiền đề: đã chạy `testcase-parse` (có `_rtm.csv`) và `prd-breakdown`.

## Nguyên tắc

Testcase sinh ra để kiểm các case của PRD. Skill chỉ trả lời 1 câu hỏi cho mỗi TC: **TC này có Pass không?**

- **Pass** = TC kiểm đúng một case có trong PRD và Expected Result khớp PRD (giá trị, message, quy tắc). Đây là kết quả đối chiếu tài liệu, **không** phải kết quả chạy app.
- **Note** = mọi trường hợp còn lại. Chỉ ghi lại, không chấm điểm nặng, không đề xuất sửa PRD:
  - `TC dư / ngoài PRD` — TC kiểm điều PRD không nói tới (QC có thể dựa tài liệu khác; hỏi QC, không coi là PRD thiếu). Gắn nhãn `[NGOÀI PRD — QC XÁC NHẬN]`.
  - `TC lệch PRD` — Expected Result khác PRD → note để QC xem lại TC.
  - `Chưa rõ` — PRD mơ hồ/tự mâu thuẫn hoặc không đủ căn cứ để kết luận; ghi mục "PRD cần làm rõ", không tự chọn bên.
- Mục PRD không có TC nào → ghi `PRD chưa có TC` ở cấp mục PRD (không thuộc TC nào).

PRD vẫn là nguồn chuẩn: lệch thì note ở phía TC. Không sửa PRD, testcase, code.

## Quy ước thư mục

```
docs/prd-vX/
├── 01-fr01-dang-nhap/index.md        ← PRD FR (prd-breakdown)
│   └── testcase-compare.md           ← output skill này
├── testcase-csv/tc-01-*.csv, _rtm.csv ← testcase-parse
└── testcase-compare-summary.md       ← bảng tổng hợp (summarize.py)
```

## Bước 1 — HỎI user (bắt buộc, KHÔNG tự đoán)

1. **Folder version** (vd `docs/prd-v1.0`).
2. **FR cần so sánh** (folder FR, hoặc "tất cả"). Được liệt kê folder FR để user chọn.
3. **Cặp FR ↔ TC CSV**: tên FR và tên sheet TC có thể lệch (vd FR04 "Hải trình" ↔ TC_04). Đề xuất cặp theo số, user xác nhận.

## Bước 2 — Chạy (mỗi FR 1 lần)

```bash
python3 .claude/skills/testcase-prd-compare/compare_fr.py <FR>/index.md <testcase-csv>/tc-NN-*.csv <testcase-csv>/_rtm.csv <FR>/testcase-compare.md
```

Không có `_rtm.csv` → truyền `-` (chỉ khớp text, kém chính xác; nên chạy lại `testcase-parse`).

## Bước 3 — Review ngữ nghĩa (việc của agent)

Script chỉ nối máy móc. Agent đọc report + PRD FR + TC liên quan rồi bổ sung cuối `testcase-compare.md` mục **"Nhận xét review"** với: `### Kết quả theo TC` (mỗi TC một kết luận Pass hoặc Note), `### PRD chưa có TC`, `### PRD cần làm rõ`, `### Testcase ngoài phạm vi PRD`. Ba dòng đếm bắt buộc (summarize.py đọc): `TC Pass: N/M`, `TC Note: K`, `Gap xác nhận: G` (G = số mục PRD chưa có TC đã xác nhận). Pass + Note = M, mỗi TC đúng một kết luận. Chi tiết và mẫu: AGENT.md.

## Bước 4 — Summary dạng bảng

Sau khi xong mọi FR (và review), gộp thành 1 bảng:

```bash
python3 .claude/skills/testcase-prd-compare/summarize.py <folder version>
```

Ghi `<folder version>/testcase-compare-summary.md`: mỗi FR 1 dòng (Mục PRD, Covered, Text-only, Uncovered, % Covered, #TC, TC Pass, TC Note, TC orphan, Gap xác nhận, link report) + dòng tổng. Các cột `TC Pass`, `TC Note`, `Gap xác nhận` lấy từ 3 dòng đếm agent ghi ở mục "Nhận xét review" của từng report; chưa ghi thì hiện `—`.

## Cách script hoạt động

- **Mục PRD:** Trigger/Pre/Post-Conditions, BR (`BRxx-xx`), bước (`ID`), field (bảng `STT | Tên field`), message trong ngoặc kép.
- **Nối TC:** (1) RTM: cột "Nguồn (DOC)" chứa BR/bước/field → Req ID → TC cùng Req ID = `covered`; (2) fallback tìm tên field/message trong Title/Pre/Steps/Expected = `text-only` (yếu, từ ngắn như "Đăng nhập" dễ nối nhầm); (3) còn lại `uncovered`.
- **Orphan:** TC không nối được mục PRD nào.
- Hạn chế: RTM của field thường chỉ ghi cấp bảng/màn ("bảng 'Màn hình …'") → nhiều field chỉ ra `text-only` dù có TC. Đừng kết luận thiếu TC khi chưa review.

## Lưu ý

- Chỉ đọc PRD và CSV; chỉ ghi `testcase-compare.md` trong folder FR.
- Mục `shared` (`_shared/*.md` được FR link tới) không nằm trong report — nếu cần, so sánh tay.
