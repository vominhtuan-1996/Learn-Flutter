#!/usr/bin/env python3
"""Dựng bản đồ TC ID -> số hàng từ text copy cột A của Excel.

Dùng: python3 -I build_rowmap.py layout.txt <hàng đầu của vùng copy> > rowmap.json
Dòng trống (header nhóm gộp) được đếm hàng nhưng không vào map.
"""
import json
import re
import sys


def build(text: str, first_row: int) -> dict:
    rows = {}
    for i, line in enumerate(text.replace("\r\n", "\n").split("\n")):
        tc = line.strip()
        if re.fullmatch(r"TC_\d+\.\d+", tc):
            rows[tc] = first_row + i
    return rows


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    with open(sys.argv[1], encoding="utf-8") as f:
        rows = build(f.read(), int(sys.argv[2]))
    # TC trùng ID sẽ ghi đè nhau và ghi nhầm hàng, nên chặn từ đầu.
    assert len(rows) == len(set(rows)), "TC ID trùng"
    json.dump(rows, sys.stdout, ensure_ascii=False, indent=1)
