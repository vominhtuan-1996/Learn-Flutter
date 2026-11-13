---
name: prd-update
description: Cập nhật breakdown PRD (các folder FR, _shared, phụ lục, 00-index) khi có PRD bản mới dạng .docx/.docx.md — chuyển docx sang markdown (nhận gạch ngang = bị bỏ, đọc comment), so sánh với bản trước theo từng FR, áp dụng thay đổi bằng patch có kiểm tra, ghi prd-vX-changes.md và prd-vX-impact.md (TC/code bị ảnh hưởng). Dùng khi user đưa PRD bản mới/bản v2 và yêu cầu "breakdown lại", "so sánh với version trước", "update lại breakdown"; dùng sau prd-breakdown, không thay prd-breakdown khi chưa có breakdown nào.
---

# PRD Update

Đưa breakdown hiện có (`prd-breakdown`) về khớp với PRD bản mới, kèm báo cáo thay đổi và tác động. **Không ghi đè nguyên file**: các `index.md` và `_shared` đã được chỉnh tay sau lần tách đầu (link shared, ghi chú), nên chỉ sửa đúng những chỗ PRD đã đổi.

> **BẮT BUỘC:** việc đầu tiên khi skill được gọi là `Read` `.claude/skills/prd-update/AGENT.md` và làm theo.

## Đầu vào (hỏi nếu thiếu, không tự đoán)

1. **File PRD bản mới** (`.docx` hoặc `.docx.md`) — path đầy đủ.
2. **Folder breakdown hiện có** (vd `learnflutter/docs/prd-v1.0`) và **file PRD bản trước** (`*.docx.md` nằm trong folder đó).
3. Có **testcase CSV** (`testcase-csv/`) và **code** để rà tác động không. Không có thì bỏ bước 7.
4. Cách đặt tên bản mới (vd `v2`) để đặt tên `prd-v2-changes.md`, `prd-v2-impact.md`.

Nếu folder chưa có breakdown (chưa chạy `prd-breakdown`) → dừng, đề nghị chạy `prd-breakdown` trước.

## Quy trình

Làm việc tạm trong thư mục scratchpad; file `.docx` không tin cậy: chạy `python3 -I`, truyền path bằng tham số.

1. **Chuyển docx → markdown thô**
   `python3 -I scripts/docx2md.py <PRD_mới.docx> raw.md`
   File đã là `.docx.md` thì bỏ bước này. Kiểm tra: số heading FR đủ, kích thước hợp lý (nếu một FR ngắn bất thường → có khối `w:sdt` hoặc nội dung bị bỏ sót; script đã xử lý sdt).
2. **Bản hiệu lực (bỏ phần gạch ngang):** `python3 -I scripts/prd_effective.py raw.md eff.md`.
   **Gạch ngang = nội dung bị bỏ** ở PRD mới (dòng bảng, cụm từ). Không bỏ bước này, nếu không phần đã bị bỏ vẫn được coi là còn hiệu lực.
3. **Đọc comment:** `python3 -I scripts/docx_comments.py <PRD_mới.docx> > comments.md`. Comment nêu lý do thay đổi. Comment **không gắn văn bản** → ghi "hỏi BA", không đoán nội dung.
4. **So sánh theo FR:** `python3 -I scripts/prd_diff.py <PRD_cũ.docx.md> eff.md > diff.md`.
   Gộp ba nguồn thay đổi: Revision History của PRD mới, comment, gạch ngang, rồi diff. Thay đổi **không có trong Revision History** vẫn phải ghi (đổi mã BR, đổi độ dài field, bỏ bảng bước…). Bỏ nhiễu định dạng (`= >` ↔ `=>`, bullet) nhưng giữ mọi đổi nội dung, mã BR, số mục, nhãn.
5. **Áp dụng vào breakdown** bằng patch có kiểm tra:
   - Soạn `patch_<ver>.py` từ [scripts/patch_template.py](scripts/patch_template.py); mỗi chỗ sửa là cặp cũ→mới **nguyên văn** lấy từ file hiện có và từ `eff.md`, khớp đúng số lần mong đợi.
   - Đồng bộ các nơi: `{NN}-frNN/index.md`, `_shared/*.md` (màn/quy tắc đã tách khỏi FR), phụ lục `97/98/99`, `00-index.md`.
   - Mã BR đổi → sửa cả tham chiếu trong `_shared`. Dòng bị gạch → xóa dòng. Dòng/mục mới → thêm đúng vị trí và giữ kiểu định dạng của file (không dán markdown thô từ bản chuyển đổi).
   - Mục mới dùng chung ≥2 FR (vd ma trận phân quyền) → tạo `_shared/{slug}.md` theo mẫu `prd-breakdown`, link từ FR liên quan và `00-index.md`.
   - Header `> Nguồn:` / `> Ngày tách:` đổi sang bản mới, ghi rõ "cập nhật theo PRD <ver>; tách lần đầu <ngày>".
   - Lưu bản chuyển đổi cạnh PRD: `<tên PRD mới>.docx.md` (giữ `~~gạch~~`, thêm dòng chú thích đầu file).
6. **Viết báo cáo** `prd-<ver>-changes.md` (mẫu bên dưới): thay đổi theo FR, thay đổi ngoài Revision History, thay đổi ngoài phạm vi breakdown, trạng thái "Đã cập nhật" từng dòng, mục chưa làm và câu hỏi cho BA.
7. **Rà tác động** (nếu có TC/code) → `prd-<ver>-impact.md`:
   - TC: `python3 -I scripts/impact_scan.py <tc.csv> keywords.json` với từ khóa lấy từ danh sách thay đổi (nhãn cũ, tên tab, bản đồ, giới hạn field…). Kết quả chỉ là ứng viên: **đọc Title/Expected từng TC** rồi ghi lệch cụ thể.
   - Code: `grep` có chọn lọc `lib/` (dùng `--include=*.dart` có nháy, vd `--include='*.dart'`). Ghi "Đã đúng / Lệch / Chưa kiểm"; không đoán.
   - Kiểm `_rtm.csv`: có thể RTM đã theo bản mới (đừng giả định RTM lỗi thời).
   - Báo cáo compare/gap cũ (theo bản trước) → đề nghị chạy lại skill so sánh, không sửa mã bằng tay.
8. **Kiểm tra cuối:** `git diff --stat` đúng các file mong đợi; không còn mã/nhãn cũ trong file đã sửa (`grep`); các link `_shared` mở được. Báo user: số thay đổi theo FR, mục chưa làm, câu hỏi cần BA.

## Mẫu `prd-<ver>-changes.md`

```
# PRD <ver> ↔ <ver cũ> — Thay đổi và trạng thái cập nhật
> So sánh: <file cũ> ↔ <file mới> (bản <x>, <ngày>, <người sửa>). Nguồn thay đổi: Revision History, N comment, văn bản gạch ngang, so sánh từng FR.
## FRxx — Tên
| Mục | Bản cũ | Bản mới | Nguồn | Đã cập nhật |
## Thay đổi ngoài Revision History
## Thay đổi ngoài FEATURE DETAIL (chưa nằm trong breakdown)
## Tài liệu khác có thể bị ảnh hưởng
## Cách kiểm tra
```

Cột "Nguồn": `Revision History` / `Comment "…"` / `Gạch ngang` / `Văn bản`. Cột "Đã cập nhật": `Có` (kèm file) / `Chưa` (kèm lý do).

## Mẫu `prd-<ver>-impact.md`

Kết luận nhanh (RTM đã theo bản mới chưa; báo cáo nào còn bản cũ; code ở đâu đã khớp) → bảng TC ảnh hưởng (`FR | Thay đổi | TC | Lệch cụ thể`) → bảng code (`Mục | Trạng thái`) → việc nên làm tiếp.

## Không làm

- Không ghi đè nguyên `index.md`/`_shared` bằng bản chuyển đổi; không dán markdown thô (mất link shared, định dạng).
- Không sửa testcase CSV/xlsx, `_rtm.csv`, báo cáo compare/gap, code `lib/`, trừ khi user yêu cầu riêng.
- Không đoán nội dung comment không gắn văn bản; không coi chữ gạch ngang là còn hiệu lực.
- Không commit trừ khi user yêu cầu.

Chi tiết dùng: [USAGE.md](USAGE.md). Quy tắc agent: [AGENT.md](AGENT.md).
