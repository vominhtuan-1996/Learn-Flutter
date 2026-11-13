#!/usr/bin/env python3
"""Quét testcase CSV tìm TC có thể bị ảnh hưởng bởi thay đổi PRD (theo từ khóa).

Dùng: impact_scan.py <tc.csv> <keywords.json>
keywords.json: {"Tên thay đổi": "regex", ...}. In số TC và danh sách TC ID cho từng từ khóa.
Chỉ là ứng viên theo từ khóa — phải đọc Title/Expected từng TC trước khi kết luận lệch.
Cột đọc: "Testcase ID", "Test Title", "Test Steps", "Expected Result" (định dạng testcase-parse).
"""
import csv, json, re, sys

rows = list(csv.DictReader(open(sys.argv[1], encoding="utf-8-sig")))
kw = json.load(open(sys.argv[2], encoding="utf-8"))
print(f"## {sys.argv[1]} ({len(rows)} TC)")
for name, pat in kw.items():
    hits = [r["Testcase ID"] for r in rows
            if re.search(pat, " ".join(r[c] for c in ("Test Title", "Test Steps", "Expected Result")), re.I)]
    print(f"- {name}: {len(hits)} — {', '.join(hits)}")
