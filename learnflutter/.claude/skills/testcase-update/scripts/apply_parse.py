#!/usr/bin/env python3
"""Áp dụng kết quả testcase-parse mới vào thư mục testcase-csv của repo.

Dùng: apply_parse.py <thư_mục_mới> <thư_mục_đích> [--apply] [--prune]
Mặc định chạy khô (chỉ in việc sẽ làm). --apply mới ghi. --prune: xóa tc-NN-*.csv của feature không còn trong bản mới.
Chép: tc-NN-*.csv, all_testcases.csv, _links.csv, _rtm.csv, _summary.md.
Không bao giờ đụng file kết quả chạy (tc-NN-result-<ngày>.csv) hay file khác. Hoàn tác bằng git.
"""
import shutil, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from tcids import feature_files

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
apply, prune = "--apply" in sys.argv, "--prune" in sys.argv
new_names = {p.name for p in feature_files(src)}
todo = [(p, dst / p.name) for p in feature_files(src)]
todo += [(src / n, dst / n) for n in ("all_testcases.csv", "_links.csv", "_rtm.csv", "_summary.md") if (src / n).exists()]
for s, t in todo:
    state = "mới" if not t.exists() else ("giữ nguyên" if t.read_bytes() == s.read_bytes() else "GHI ĐÈ")
    print(f"{'chép' if apply else 'sẽ chép'}: {t.name} ({state})")
    if apply and state != "giữ nguyên":
        t.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(s, t)
for old in feature_files(dst):
    if old.name not in new_names:
        print(f"{'xóa' if apply and prune else 'bản mới không còn'}: {old.name}" + ("" if prune else " (giữ lại; thêm --prune nếu muốn xóa)"))
        if apply and prune: old.unlink()
if not apply: print("\n(chạy khô — thêm --apply để ghi)")
