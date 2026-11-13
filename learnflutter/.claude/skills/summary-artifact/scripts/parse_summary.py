#!/usr/bin/env python3
"""Đọc file summary bug (Markdown) và xuất JSON: mỗi bug là 1 dòng.

Dùng:  python3 parse_summary.py <summary.md> [-o rows.json]

Quy tắc (không cần thư viện ngoài):
- Chỉ lấy dòng của bảng Markdown có cột mã bug (vd `OMB-295`). Bảng tổng hợp không có mã bug bị bỏ qua.
- Cùng 1 mã xuất hiện ở nhiều bảng thì gộp: mỗi trường lấy giá trị đầu tiên không rỗng.
- `status` lấy từ cột Status, nếu bảng không có thì lấy từ tiêu đề gần nhất `## To Do (n)`, `## In review (n)`...
- `module` lấy từ cột Flow/Module, nếu thiếu thì lấy từ tiền tố `[TC_03 - Tên module]` của tóm tắt.
- In cảnh báo ra stderr khi số bug khác số khai báo trong file (`## Tổng: N`), hoặc thiếu trường.
"""
import argparse
import json
import re
import sys

KEY_RE = re.compile(r"^[A-Z][A-Z0-9]+-\d+$")
STATUS_HEAD_RE = re.compile(r"^#{2,4}\s+(To Do|In Progress|In progress|In review|In Review|Done|Pending|Open|Closed)\b", re.I)
STATUS_CANON = {
    "to do": "To Do",
    "in progress": "In progress",
    "in review": "In review",
    "done": "Done",
    "pending": "Pending",
    "open": "Open",
    "closed": "Closed",
}
HEADER_ALIASES = {
    "key": {"key", "mã", "ma", "ticket", "issue", "mã bug"},
    "summary": {"summary", "tóm tắt", "tom tat", "mô tả", "title", "tiêu đề"},
    "status": {"status", "trạng thái", "trang thai"},
    "assignee": {"assignee", "người xử lý", "nguoi xu ly", "người nhận", "owner"},
    "module": {"flow (tc)", "flow", "module", "tc", "nhóm tc", "module (tc)"},
    "priority": {"priority", "ưu tiên", "mức ưu tiên", "uu tien"},
}
FIELDS = ["key", "summary", "status", "assignee", "module", "priority"]
PREFIX_RE = re.compile(r"^\s*\[\s*(TC_\d+[^\]]*?)\s*\]\s*[-–:]?\s*", re.I)


def clean_cell(text):
    t = text.strip()
    t = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", t)  # [text](url) -> text
    t = re.sub(r"\*+|`|~~", "", t)  # không xoá "_" vì có trong data_block, TC_03
    return t.strip()


def split_row(line):
    s = line.strip()
    if s.startswith("|"):
        s = s[1:]
    if s.endswith("|"):
        s = s[:-1]
    return [c for c in re.split(r"(?<!\\)\|", s)]


def is_separator(cells):
    return all(re.fullmatch(r":?-{2,}:?", c.strip()) for c in cells if c.strip()) and any(c.strip() for c in cells)


def map_header(cells):
    mapping = {}
    for i, c in enumerate(cells):
        name = clean_cell(c).lower()
        for field, aliases in HEADER_ALIASES.items():
            if name in aliases and field not in mapping.values():
                mapping[i] = field
                break
    return mapping


def canon_status(text):
    return STATUS_CANON.get(text.strip().lower(), text.strip())


def parse(path):
    lines = open(path, encoding="utf-8").read().splitlines()
    rows = {}
    order = []
    declared_total = None
    current_status = ""
    i = 0
    while i < len(lines):
        line = lines[i]
        m = STATUS_HEAD_RE.match(line)
        if m:
            current_status = canon_status(m.group(1))
        elif re.match(r"^#{1,4}\s+", line) and not m:
            current_status = ""
        tm = re.search(r"Tổng:\s*(\d+)", line)
        if tm:
            declared_total = int(tm.group(1))

        if line.strip().startswith("|") and i + 1 < len(lines) and is_separator(split_row(lines[i + 1])):
            header = map_header(split_row(line))
            j = i + 2
            while j < len(lines) and lines[j].strip().startswith("|"):
                cells = split_row(lines[j])
                rec = {}
                for idx, field in header.items():
                    if idx < len(cells):
                        rec[field] = clean_cell(cells[idx])
                key = rec.get("key", "")
                if KEY_RE.match(key):
                    if "status" in rec:
                        rec["status"] = canon_status(rec["status"])
                    elif current_status:
                        rec["status"] = current_status
                    cur = rows.get(key)
                    if cur is None:
                        rows[key] = cur = {}
                        order.append(key)
                    for f in FIELDS:
                        v = rec.get(f, "")
                        if not v:
                            continue
                        if not cur.get(f):
                            cur[f] = v
                        elif f == "summary" and cur[f].startswith("[") and not v.startswith("["):
                            cur[f] = v  # ưu tiên bản tóm tắt đã bỏ tiền tố [TC_xx]
                j += 1
            i = j
            continue
        i += 1

    out = []
    for key in order:
        r = rows[key]
        summary = r.get("summary", "")
        if not r.get("module"):
            pm = PREFIX_RE.match(summary)
            if pm:
                r["module"] = pm.group(1).strip()
        summary = PREFIX_RE.sub("", summary).strip()
        r["summary"] = summary
        out.append({f: r.get(f, "") for f in FIELDS})
    out.sort(key=lambda r: int(r["key"].rsplit("-", 1)[1]))
    return out, declared_total


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("summary")
    ap.add_argument("-o", "--out", default="")
    args = ap.parse_args()

    rows, declared = parse(args.summary)
    if not rows:
        sys.exit("Không thấy dòng bug nào (bảng có cột Key kiểu OMB-123) trong file này. Cần 1 bảng liệt kê từng bug.")

    print(f"Đọc được {len(rows)} bug từ {args.summary}", file=sys.stderr)
    if declared is not None and declared != len(rows):
        print(f"CẢNH BÁO: file khai báo tổng {declared} bug nhưng chỉ đọc được {len(rows)} dòng. "
              "File thiếu bảng liệt kê đủ từng bug.", file=sys.stderr)
    for f in FIELDS[1:]:
        missing = sum(1 for r in rows if not r[f])
        if missing:
            print(f"- thiếu `{f}`: {missing}/{len(rows)} bug", file=sys.stderr)
    by_status = {}
    for r in rows:
        by_status[r["status"] or "(không rõ)"] = by_status.get(r["status"] or "(không rõ)", 0) + 1
    print("- theo trạng thái:", ", ".join(f"{k}={v}" for k, v in by_status.items()), file=sys.stderr)

    text = json.dumps(rows, ensure_ascii=False, indent=1)
    if args.out:
        with open(args.out, "w", encoding="utf-8") as f:
            f.write(text)
    else:
        print(text)


if __name__ == "__main__":
    main()
