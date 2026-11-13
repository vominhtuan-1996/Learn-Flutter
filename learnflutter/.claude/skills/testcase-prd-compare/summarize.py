#!/usr/bin/env python3
"""Gộp mọi {FR}/testcase-compare.md trong folder version thành 1 bảng summary.

Usage: summarize.py <version_folder> [out.md]   (mặc định <version_folder>/testcase-compare-summary.md)
Cột "TC Pass" (N/M), "TC Note" và "Gap xác nhận" lấy từ dòng `TC Pass: N/M`, `TC Note: K`, `Gap xác nhận: G` agent ghi trong mục Nhận xét review; chưa có thì "—".
"""
import re, sys
from pathlib import Path

NUM = lambda pat, t: (m.group(1) if (m := re.search(pat, t)) else None)


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    root = Path(sys.argv[1])
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else root / "testcase-compare-summary.md"
    rows = []
    for rep in sorted(root.glob("*/testcase-compare.md")):
        t = rep.read_text(encoding="utf-8")
        m = re.search(r"Mục PRD trích được: (\d+) — covered (\d+), text-only (\d+), uncovered (\d+)", t)
        if not m:
            continue
        items, cov, weak, unc = map(int, m.groups())
        tc = NUM(r"\((\d+) TC\)", t) or "?"
        orphan = NUM(r"TC chưa nối được mục PRD nào: (\d+)/", t) or "?"
        gap = NUM(r"Gap xác nhận:\s*(\d+)", t) or "—"
        pm = re.search(r"TC Pass:\s*(\d+)\s*/\s*(\d+)", t)
        tc_pass = f"{pm.group(1)}/{pm.group(2)}" if pm else "—"
        tc_note = NUM(r"TC Note:\s*(\d+)", t) or "—"
        pct = f"{100 * cov // items}%" if items else "—"
        rows.append((rep.parent.name, items, cov, weak, unc, pct, tc, orphan, gap, f"{rep.parent.name}/testcase-compare.md", tc_pass, tc_note))
    if not rows:
        sys.exit("Không có testcase-compare.md nào trong " + str(root))
    tot = [sum(r[i] for r in rows) for i in (1, 2, 3, 4)]
    def total_at(index):
        values = [r[index] for r in rows]
        return str(sum(int(v) for v in values)) if all(v.isdigit() for v in values) else "—"

    pass_n = pass_m = 0
    for r in rows:
        if r[10] != "—":
            n, m = r[10].split("/")
            pass_n += int(n); pass_m += int(m)
    pass_total = f"{pass_n}/{pass_m}" if pass_m else "—"

    review = ""
    if out.exists():
        _, marker, review = out.read_text(encoding="utf-8").partition("\n## Nhận xét review\n")
        if not marker:
            review = ""
    L = [f"# Testcase Compare — Summary ({root.name})", "",
         "| FR | Mục PRD | Covered | Text-only | Uncovered | % Covered | #TC | TC Pass | TC Note | TC orphan | Gap xác nhận | Report |",
         "|---|---|---|---|---|---|---|---|---|---|---|---|"]
    L += [f"| {a} | {b} | {c} | {d} | {e} | {f} | {g} | {k} | {l} | {h} | {i} | [{j}]({j}) |" for a, b, c, d, e, f, g, h, i, j, k, l in rows]
    L += [f"| **Tổng** | **{tot[0]}** | **{tot[1]}** | **{tot[2]}** | **{tot[3]}** | **{100 * tot[1] // tot[0]}%** | **{total_at(6)}** | **{pass_total}** | **{total_at(11)}** | **{total_at(7)}** | **{total_at(8)}** | |", "",
          "- Covered = nối qua RTM · Text-only = chỉ khớp text (yếu) · Uncovered = không thấy TC (ứng viên gap)",
          "- TC Pass = TC kiểm đúng case PRD và Expected khớp PRD (đối chiếu tài liệu, không phải chạy app); TC Note = TC có ghi chú (ngoài PRD / lệch / chưa rõ)",
          "- Gap xác nhận = số mục PRD chưa có TC đã xác nhận sau review của agent; `—` = chưa review",
          "- % Covered chỉ tính nối qua RTM nên thấp với FR mà RTM ghi nguồn cấp bảng/màn"]
    content = "\n".join(L) + "\n"
    if review:
        content += "\n## Nhận xét review\n" + review
    out.write_text(content, encoding="utf-8")
    print("\n".join(L)); print(f"\nOut: {out}")


if __name__ == "__main__":
    main()
