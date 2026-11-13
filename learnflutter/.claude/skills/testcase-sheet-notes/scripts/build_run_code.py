#!/usr/bin/env python3
"""Sinh code JS cho browser_run_code_unsafe từ notes.json + rowmap.json.

Dùng: python3 -I build_run_code.py notes.json rowmap.json <cột> [--chunk N] [--part K]
In ra stdout phần K (bắt đầu 1) của danh sách ô, mỗi phần tối đa N ô (mặc định 35).
"""
import json
import sys
from pathlib import Path

TEMPLATE = Path(__file__).with_name("write_notes.js").read_text(encoding="utf-8")


def main(argv):
    notes_path, rowmap_path, col = argv[1], argv[2], argv[3]
    chunk = int(argv[argv.index("--chunk") + 1]) if "--chunk" in argv else 35
    part = int(argv[argv.index("--part") + 1]) if "--part" in argv else 1
    notes = json.loads(Path(notes_path).read_text(encoding="utf-8"))
    rowmap = json.loads(Path(rowmap_path).read_text(encoding="utf-8"))
    missing = [tc for tc in notes if tc not in rowmap]
    assert not missing, f"TC không có trong rowmap: {missing}"
    texts = set(notes.values())
    prefixed = [a for a in texts for b in texts if a != b and b.startswith(a)]
    assert not prefixed, f"Note là tiền tố của note khác (Excel autocomplete sẽ nối chữ): {prefixed[0][:40]}"
    cells = sorted(((rowmap[tc], text) for tc, text in notes.items()))
    batch = cells[(part - 1) * chunk : part * chunk]
    assert batch, "Không còn ô nào cho phần này"
    payload = [[f"{col}{row}", text] for row, text in batch]
    print(TEMPLATE.replace("__CELLS__", json.dumps(payload, ensure_ascii=False)))


if __name__ == "__main__":
    main(sys.argv)
