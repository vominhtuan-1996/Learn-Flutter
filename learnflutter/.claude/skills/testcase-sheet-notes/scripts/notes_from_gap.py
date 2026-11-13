#!/usr/bin/env python3
"""Sinh notes.json (+ titles.json để đối chiếu hàng) từ file GAP gửi QC (gap-testcase-qc-*.md).

Dùng: python3 -I notes_from_gap.py <gap.md> <out_dir>
Mỗi mục "## N. TC_xx — tiêu đề" có Loại/Ưu tiên, Hiện tại, Căn cứ PRD, Đề nghị -> 1 note:
  "[GAP PRD v2 · <Loại> · <Ưu tiên>] <Đề nghị> Căn cứ: <PRD rút gọn>"
Mục không có mã TC (vd "(chưa có)" = thiếu TC) không có hàng để ghi: in ra stderr để báo user.
titles.json: mã TC -> tiêu đề trong GAP, dùng để kiểm tra mã trên sheet đúng TC trước khi ghi.
"""
import json, re, sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(encoding="utf-8")
out = Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=True)
notes, titles, skipped = {}, {}, []
for block in re.split(r"\n(?=## \d+\. )", text):
    m = re.match(r"## (\d+)\. (.+?) — (.+)", block)
    if not m: continue
    tc, title = m.group(2).strip(), m.group(3).strip()
    f = lambda k: (re.search(rf"\*\*{k}:\*\* (.+)", block) or [None, ""])[1].strip()
    meta = f("FR / Loại / Ưu tiên").split(" / ")
    if not re.fullmatch(r"TC_\d+\.\d+", tc):
        skipped.append(f"{m.group(1)}. {tc} — {f('Hiện tại')[:80]}"); continue
    loai, pri = " / ".join(meta[1:-1]), meta[-1]  # Loại có thể chứa " / " (vd "Cần sửa / xác nhận")
    prd = f("Căn cứ PRD v2"); prd = prd if len(prd) <= 150 else prd[:147].rsplit(" ", 1)[0].rstrip(" ,;:") + "…"  # cắt ở ranh giới từ
    notes[tc] = f"[GAP PRD v2 · {loai} · {pri}] {f('Đề nghị')} Căn cứ: {prd}"
    titles[tc] = title
(out / "notes.json").write_text(json.dumps(notes, ensure_ascii=False, indent=1), encoding="utf-8")
(out / "titles.json").write_text(json.dumps(titles, ensure_ascii=False, indent=1), encoding="utf-8")
print(f"{len(notes)} note, bỏ qua {len(skipped)} mục không có mã TC", file=sys.stderr)
for s in skipped: print("  bỏ qua:", s, file=sys.stderr)
