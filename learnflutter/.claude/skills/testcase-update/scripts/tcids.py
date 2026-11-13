"""Tiện ích dùng chung: đọc CSV testcase theo feature, bung danh sách TC ID rút gọn."""
import csv, re
from pathlib import Path

# Cột kết quả chạy: đổi cột này không phải đổi thiết kế testcase.
RESULT_COLS = ("Origin", "Review", "Automated", "Script", "Vibe-test", "KQ Script", "Kết quả", "Executed By", "ID Bugs", "Note")
DESIGN_COLS = ("section", "Req ID", "DOC Source", "Group", "Priority", "Test Title", "Pre-condition", "Test Steps", "Expected Result")


def feature_files(d):
    """tc-NN-slug.csv của testcase-parse; bỏ file kết quả chạy (tc-NN-result-<ngày>.csv)."""
    return sorted(p for p in Path(d).glob("tc-*.csv") if "-result-" not in p.name)


def load_dir(d):
    """{Testcase ID: row} cho toàn bộ feature trong thư mục; ID trùng là lỗi dữ liệu nên dừng."""
    out = {}
    for f in feature_files(d):
        for row in csv.DictReader(open(f, encoding="utf-8-sig")):
            tc = row["Testcase ID"].strip()
            assert tc not in out, f"Testcase ID trùng: {tc} ({f.name})"
            row["_file"] = f.name
            out[tc] = row
    return out


def expand_ids(text):
    """Bung 'TC_03.146, .149', 'TC_03.199–TC_03.203', 'TC_05.135–.140' thành danh sách TC ID đầy đủ."""
    ids, prefix, last = [], None, None
    for m in re.finditer(r"TC_(\d+)\.(\d+)(?:\s*[–-]\s*(?:TC_\d+)?\.?(\d+))?|(?<![\w.])\.(\d+)(?:\s*[–-]\s*\.?(\d+))?", text):
        if m.group(1):
            prefix, a, b = m.group(1), int(m.group(2)), m.group(3)
        elif prefix:
            a, b = int(m.group(4)), m.group(5)
        else:
            continue
        hi = int(b) if b and int(b) >= a else a
        ids += [f"TC_{prefix}.{n}" for n in range(a, hi + 1)]
    return list(dict.fromkeys(ids))
