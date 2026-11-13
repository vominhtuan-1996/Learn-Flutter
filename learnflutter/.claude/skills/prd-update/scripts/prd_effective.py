#!/usr/bin/env python3
"""Bỏ phần gạch ngang khỏi markdown thô để ra bản "hiệu lực" của PRD mới.

Dùng: prd_effective.py <raw.md> <effective.md>
- ~~đoạn~~ trong dòng thường/ô bảng -> xóa đoạn.
- Dòng bảng mà mọi ô (trừ cột STT) đều bị gạch -> xóa cả dòng.
"""
import re, sys

out = []
for line in open(sys.argv[1], encoding="utf-8"):
    line = line.rstrip("\n")
    if "~~" in line:
        stripped = re.sub(r"~~.*?~~", "", line)
        if line.startswith("|"):
            cells = [c.strip() for c in stripped.strip().strip("|").split("|")]
            if not any(cells[1:]):
                continue
        line = re.sub(r" {2,}", " ", stripped)
    out.append(line)
open(sys.argv[2], "w", encoding="utf-8").write("\n".join(out) + "\n")
