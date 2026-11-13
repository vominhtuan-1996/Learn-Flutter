#!/usr/bin/env python3
"""Sinh notes.json từ file kết quả chạy thiết bị (device-test-run-*.md).

Dùng: python3 -I notes_from_run.py <folder FR | file device-test-run-*.md> > notes.json

Truyền folder FR (vd learnflutter/docs/prd-v1.0/01-fr01-dang-nhap) thì tự chọn file
device-test-run-YYYY-MM-DD.md mới nhất trong folder; file được chọn in ra stderr.

Đọc 3 bảng: "Pass 100%", "Cần theo dõi", "Chưa chạy". Mỗi TC một note:
  Pass          -> "Pass dd/mm/yyyy (<bản chạy>): <bằng chứng>"
  Cần theo dõi  -> "Chưa Pass 100% (dd/mm/yyyy): <đã xác nhận> Còn thiếu: <việc còn thiếu>"
  Chưa chạy     -> "Chưa chạy: <lý do>"
Ô TC có thể là danh sách rút gọn ("TC_01.4, .6, .61") — tự bung thành TC đầy đủ.
Ngoài ra che chuỗi giống tên đăng nhập (chữ + >=4 chữ số) để không đưa credential vào sheet.
"""
import json
import re
import sys
from pathlib import Path

MASK = re.compile(r"`?\b[A-Za-z]{2,}\d{4,}\b`?")


def clean(s: str) -> str:
    s = MASK.sub("[ẩn]", s)
    return re.sub(r"\s+", " ", s.replace("`", "")).strip()


def expand(cell: str) -> list[str]:
    ids, prefix = [], None
    for tok in re.split(r"[,\s]+", cell.strip()):
        m = re.fullmatch(r"(TC_\d+)\.(\d+)", tok)
        if m:
            prefix = m.group(1)
            ids.append(tok)
        elif re.fullmatch(r"\.\d+", tok) and prefix:
            ids.append(prefix + tok)
    return ids


def meta(text: str) -> str:
    d = re.search(r"Ngày chạy:\s*(\d{4})-(\d{2})-(\d{2})", text)
    b = re.search(r"Bản chạy:\s*([^\n]+)", text)
    date = f"{d.group(3)}/{d.group(2)}/{d.group(1)}" if d else "?"
    ver = re.search(r"`([^`]+)`", b.group(1)) if b else None
    env = re.match(r"([A-Za-z ]+?)\s*`", b.group(1)) if b else None
    build = f"{(env.group(1).strip() if env else '')} {ver.group(1) if ver else ''}".strip()
    return date, build


def find_run_file(arg: str) -> Path:
    p = Path(arg)
    if p.is_file():
        return p
    # Tên file có ngày ISO nên sắp xếp theo tên là sắp xếp theo thời gian.
    runs = sorted(p.glob("device-test-run-*.md"))
    if not runs:
        sys.exit(f"Không có device-test-run-*.md trong {p}. Hỏi user path file run test hoặc tài liệu kết quả tương đương.")
    if len(runs) > 1:
        print("Có nhiều file run, dùng file mới nhất: " + ", ".join(r.name for r in runs), file=sys.stderr)
    return runs[-1]


def main(path: str) -> dict:
    src = find_run_file(path)
    print(f"Nguồn: {src}", file=sys.stderr)
    text = src.read_text(encoding="utf-8")
    date, build = meta(text)
    notes, kind = {}, None
    for line in text.splitlines():
        if line.startswith("## "):
            h = line.lower()
            # "Cần theo dõi — chưa Pass 100%" chứa cụm "pass 100": phải xét 2 bảng kia trước.
            kind = ("watch" if "theo dõi" in h else "todo" if "chưa chạy" in h
                    else "pass" if "pass 100" in h else None)
            continue
        if kind is None or not line.startswith("|") or set(line) <= set("|- "):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        ids = expand(cells[0])
        if not ids or len(cells) < 2:
            continue
        rest = [clean(c) for c in cells[1:] if c]
        if kind == "pass":
            note = f"Pass {date} ({build}): {rest[0]}"
        elif kind == "watch":
            missing = rest[1] if len(rest) > 1 else ""
            note = f"Chưa Pass 100% ({date}): {rest[0]} Còn thiếu: {missing}".strip()
        else:
            note = "Chưa chạy: " + " ".join(rest)
        for tc in ids:
            assert tc not in notes, f"{tc} xuất hiện ở nhiều bảng"
            notes[tc] = note
    return notes


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    json.dump(main(sys.argv[1]), sys.stdout, ensure_ascii=False, indent=1)
