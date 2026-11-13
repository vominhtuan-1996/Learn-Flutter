#!/usr/bin/env python3
"""Tìm nơi còn tham chiếu tới TC bị bỏ / đổi mã / tái sử dụng mã / đổi thiết kế.

Dùng: stale_refs.py <thư_mục_gốc_quét> <diff.json> [<thư_mục_gốc_quét> ...]
Quét *.md, *.csv, *.yaml, *.yml (bỏ thư mục testcase-csv/ và build). In file và TC ID tìm thấy theo mức ảnh hưởng.
Dùng để biết cần chạy lại skill nào: so sánh PRD/codebase, tạo lại flow Maestro, chạy lại test.
"""
import json, re, sys
from pathlib import Path

args = [a for a in sys.argv[1:] if not a.startswith("--")]
d = json.loads(Path(args[-1]).read_text(encoding="utf-8"))
level = {}
for k, name in (("design", "ĐỔI THIẾT KẾ"), ("renumbered", "ĐỔI MÃ"), ("reused", "TÁI SỬ DỤNG MÃ"), ("removed", "BỎ")):
    for t in d.get(k, []): level[t] = name  # mức sau ghi đè mức trước: BỎ > TÁI SỬ DỤNG > ĐỔI MÃ > ĐỔI THIẾT KẾ
pat = re.compile(r"\bTC_\d+\.\d+\b|\btc[_-](\d+)[_.-](\d+)\b", re.I)
hits = {}
for root in args[:-1]:
    for p in Path(root).rglob("*"):
        if p.suffix not in (".md", ".csv", ".yaml", ".yml") or "testcase-csv" in p.parts or "build" in p.parts or ".dart_tool" in p.parts:
            continue
        try: text = p.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError): continue
        found = {}
        for m in pat.finditer(text):
            tc = m.group(0).upper().replace("-", "_") if m.group(1) is None else f"TC_{int(m.group(1)):02d}.{int(m.group(2))}"
            if tc in level: found[tc] = level[tc]
        if found: hits[str(p)] = found
print(f"# Tham chiếu còn lại tới TC bị ảnh hưởng ({len(hits)} file)\n")
for f, found in sorted(hits.items()):
    by = {}
    for t, l in found.items(): by.setdefault(l, []).append(t)
    print(f"- `{f}`: " + "; ".join(f"{l}: {', '.join(sorted(v))[:160]}" for l, v in by.items()))
