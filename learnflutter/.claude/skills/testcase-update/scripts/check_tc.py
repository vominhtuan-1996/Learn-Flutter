#!/usr/bin/env python3
"""Kiểm tra dữ liệu thư mục CSV testcase mới trước khi áp dụng.

Dùng: check_tc.py <thư_mục> [--stale "regex1|regex2"]
Kiểm: Testcase ID duy nhất và đúng định dạng TC_NN.n; Title/Steps/Expected không rỗng; Expected chỉ tham chiếu
bước có trong Steps (số đầu dòng); không còn từ khóa cũ (--stale) trong Title/Steps/Expected.
Thoát mã 1 nếu có lỗi.
"""
import re, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from tcids import load_dir

rows = load_dir(sys.argv[1])
stale = re.compile(sys.argv[sys.argv.index("--stale") + 1], re.I) if "--stale" in sys.argv else None
errs = []
for tc, r in rows.items():
    if not re.fullmatch(r"TC_\d+\.\d+", tc): errs.append(f"{tc}: ID sai định dạng")
    for c in ("Test Title", "Test Steps", "Expected Result"):
        if not r[c].strip(): errs.append(f"{tc}: {c} rỗng")
    steps = set(re.findall(r"^\s*(\d+)\.", r["Test Steps"], re.M))
    exp = set(re.findall(r"^\s*(\d+)\.", r["Expected Result"], re.M))
    if steps and exp and not exp <= steps: errs.append(f"{tc}: Expected tham chiếu bước {sorted(exp - steps, key=int)} không có trong Steps")
    if stale:
        for c in ("Test Title", "Test Steps", "Expected Result"):
            m = stale.search(r[c])
            if m: errs.append(f"{tc}: {c} còn từ khóa cũ «{m.group(0)}»")
print(f"{len(rows)} TC, {len(errs)} lỗi")
print("\n".join("- " + e for e in errs[:200]))
sys.exit(1 if errs else 0)
