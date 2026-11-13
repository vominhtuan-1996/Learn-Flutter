# USAGE — prd-update

Cập nhật breakdown PRD khi có PRD bản mới.

## Chuẩn bị

1. Đã chạy `prd-breakdown`: có `docs/prd-vX/NN-frNN-*/index.md`, `_shared/`, `00-index.md`, và PRD bản trước dạng `*.docx.md` trong folder đó.
2. Có file PRD bản mới (`.docx` hoặc `.docx.md`) đặt trong cùng folder (hoặc nói path).
3. Tùy chọn: `testcase-csv/` (từ `testcase-parse`) và `lib/` để rà tác động.

## Cách 1 — Skill

```
/prd-update
```

Claude đọc AGENT.md, hỏi: path PRD mới, folder breakdown + PRD bản trước, có TC/code không, tên bản mới (vd `v2`).

Lời nhắc tự nhiên:

> dùng prd-update breakdown learnflutter/docs/prd-v1.0/ISC_..._v2.docx, so sánh với version trước và update lại.

## Cách 2 — Script (từng bước)

```bash
S=.claude/skills/prd-update/scripts
python3 -I $S/docx2md.py  <PRD_mới.docx> /tmp/raw.md          # docx → md (gạch ngang thành ~~…~~)
python3 -I $S/prd_effective.py /tmp/raw.md /tmp/eff.md          # bỏ phần gạch ngang
python3 -I $S/docx_comments.py <PRD_mới.docx> > /tmp/comments.md
python3 -I $S/prd_diff.py <PRD_cũ.docx.md> /tmp/eff.md > /tmp/diff.md
```

Áp dụng thay đổi: sao chép `scripts/patch_template.py` thành `patch_<ver>.py`, điền các cặp cũ→mới, chạy:

```bash
PRD_ROOT=learnflutter/docs/prd-v1.0 python3 -I patch_v2.py
```

Quét TC ứng viên:

```bash
echo '{"Bản đồ OSM":"openstreet","SSID":"ssid|network name"}' > keywords.json
python3 -I $S/impact_scan.py learnflutter/docs/prd-v1.0/testcase-csv/tc-04-*.csv keywords.json
```

## Kết quả

- Các `index.md`, `_shared/*`, `97/98/99`, `00-index.md` cập nhật theo PRD mới (chưa commit).
- `<PRD mới>.docx.md` — bản chuyển đổi.
- `prd-<ver>-changes.md` — thay đổi theo FR, ngoài Revision History, ngoài phạm vi breakdown, trạng thái `Đã cập nhật`.
- `prd-<ver>-impact.md` — TC/code bị ảnh hưởng (nếu có TC/code).

## Lưu ý

| Điều | Giải thích |
|---|---|
| Gạch ngang = bị bỏ | `docx2md.py` ghi `~~…~~`, `prd_effective.py` bỏ chúng. Bỏ bước này sẽ giữ lại nội dung đã bị xóa |
| Một FR ngắn bất thường | Thường do khối `w:sdt` hoặc đổi cấp heading; kiểm tra chuyển đổi trước khi kết luận PRD bỏ nội dung |
| Comment không gắn văn bản | Ghi "hỏi BA", không đoán |
| Không ghi đè nguyên file | `index.md` đã có link `_shared` và ghi chú chỉnh tay; chỉ patch từng chỗ |
| TC/RTM/báo cáo cũ | Không sửa tay; chạy lại `testcase-prd-compare` / `prd-gap-review` / `testcase-codebase-compare` |
| Hoàn tác | `git diff` / `git checkout -- <file>`; mọi thay đổi chưa commit |
