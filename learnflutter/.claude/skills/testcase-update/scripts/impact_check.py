#!/usr/bin/env python3
"""Đối chiếu TC bị đánh dấu ảnh hưởng (từ prd-vX-impact.md) với thay đổi thật trong file testcase mới.

Dùng: impact_check.py <prd-vX-impact.md> <diff.json> > check.md
- ĐÃ SỬA: TC bị đánh dấu và có đổi thiết kế → xác nhận nội dung mới khớp PRD (đọc tay).
- CÒN CŨ: bị đánh dấu nhưng không đổi → vẫn lệch PRD, báo QC.
- BỎ: bị đánh dấu nhưng không còn trong file mới. Đổi mã: liệt kê mã cũ → mã mới.
- ĐỔI NGOÀI DANH SÁCH: TC đổi thiết kế nhưng không nằm trong impact → xem có đúng ý không.
"""
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from tcids import expand_ids

flagged = []
for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines():
    if line.startswith("|") and "TC_" in line:
        cells = [c for c in line.strip().strip("|").split("|")]
        flagged += expand_ids(" ".join(cells[2:3] if len(cells) > 3 else cells))  # cột "TC bị ảnh hưởng"
flagged = list(dict.fromkeys(flagged))
d = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
# impact dùng MÃ CŨ; design/removed/renumbered cũng khóa theo mã cũ (tc_diff ghép theo tiêu đề)
design, removed, renum = set(d["design"]), set(d["removed"]), d["renumbered"]
fixed = [t for t in flagged if t in design]
stale = [t for t in flagged if t not in design and t not in removed]
gone = [t for t in flagged if t in removed]
moved = [f"{t}→{renum[t]}" for t in flagged if t in renum]
extra = sorted(design - set(flagged))
sec = lambda title, xs: print(f"## {title} ({len(xs)})\n\n" + (", ".join(xs) if xs else "(không)") + "\n")
print(f"# Đối chiếu impact ↔ testcase mới\n\nTC được đánh dấu trong impact: {len(flagged)}\n")
sec("ĐÃ SỬA (cần đọc tay xác nhận khớp PRD)", fixed)
sec("CÒN CŨ (vẫn lệch PRD)", stale)
sec("ĐÃ BỎ khỏi file mới", gone)
sec("Bị đánh số lại (nội dung cũ → mã mới)", moved)
sec("ĐỔI THIẾT KẾ NGOÀI DANH SÁCH IMPACT", extra)
