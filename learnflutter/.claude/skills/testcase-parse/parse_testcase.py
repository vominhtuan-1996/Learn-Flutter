#!/usr/bin/env python3
"""Parse file testcase QC (.xlsx) -> CSV theo feature (mỗi sheet chức năng = 1 feature).

Usage: parse_testcase.py <testcase.xlsx> [out_dir]
Out:   out_dir/all_testcases.csv + out_dir/{tc-code-slug}.csv + out_dir/_summary.md + out_dir/_links.csv + out_dir/_rtm.csv
"""
import csv, re, sys, unicodedata
from pathlib import Path

import openpyxl

HEADER_KEY = "Testcase ID"


def slug(s):
    s = unicodedata.normalize("NFD", s.replace("đ", "d").replace("Đ", "D"))
    s = "".join(c for c in s if unicodedata.category(c) != "Mn").lower()
    return re.sub(r"[^a-z0-9]+", "-", s).strip("-")


def clean(v):
    return "" if v is None else str(v).replace("\r", "").strip()


def parse_sheet(ws):
    """Trả (meta, rows) hoặc None nếu không phải sheet testcase."""
    hdr_row = next((i for i, r in enumerate(ws.iter_rows(max_row=15, values_only=True), 1)
                    if r and clean(r[0]) == HEADER_KEY), None)
    if not hdr_row:
        return None
    meta_code = clean(ws.cell(2, 3).value)
    meta_name = clean(ws.cell(3, 3).value) or ws.title
    headers = [clean(c).split("\n")[0] for c in next(ws.iter_rows(min_row=hdr_row, max_row=hdr_row, values_only=True))]
    # cột lặp lại (ROUND 1/2/3: Kết quả, Executed By...) là kết quả chạy, không phải thiết kế TC -> cắt tại cột lặp đầu tiên
    cols, seen = [], set()
    for i, h in enumerate(headers):
        if h in seen:
            break
        if h:
            seen.add(h); cols.append(i)
    section, rows = "", []
    for r in ws.iter_rows(min_row=hdr_row + 1, values_only=True):
        if not clean(r[0]):
            marker = clean(r[2]) if len(r) > 2 else ""
            if marker.startswith("▬"):
                # "▬▬  1. Phân quyền  ·  7 TC (...)" -> "Phân quyền"
                section = re.sub(r"^▬+\s*\d*\.?\s*", "", marker).split("·")[0].strip()
            continue
        rows.append({"section": section, **{headers[i]: clean(r[i]) for i in cols}})
    return {"code": meta_code, "name": meta_name, "headers": [headers[i] for i in cols]}, rows


def write_links(rows, out):
    """Liên kết giữa feature: (1) TC nhắc tên feature khác, (2) section trùng tên giữa các sheet.
    File xlsx không có link tường minh (Req ID không dùng chung, không ref TC_xx chéo) -> heuristic theo tên."""
    feats = {r["feature_code"]: r["feature"] for r in rows}
    keys = {c: [k.strip().lower() for k in re.split(r"\s*[-/]\s*", n) if len(k.strip()) >= 5] + [n.lower()]
            for c, n in feats.items()}
    hits = {}
    for r in rows:
        text = " ".join(r.get(k, "") for k in ("Test Title", "Pre-condition", "Test Steps", "Expected Result")).lower()
        for c, ks in keys.items():
            if c != r["feature_code"] and any(k in text for k in ks):
                hits.setdefault((r["feature_code"], c), []).append(r["Testcase ID"])
    with open(out / "_links.csv", "w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(["from", "to", "type", "count", "evidence"])
        for (a, b), ids in sorted(hits.items()):
            w.writerow([a, b, "mentions", len(ids), " ".join(ids[:15])])
        secs = {}
        for r in rows:
            secs.setdefault(r["section"], set()).add(r["feature_code"])
        for sec, fs in sorted(secs.items()):
            if len(fs) > 1:
                w.writerow([",".join(sorted(fs)), "", "shared-section", len(fs), sec])


def write_rtm(wb, out):
    """RTM: Req ID -> nguồn trong PRD (§, BR, field...) — skill so sánh PRD dùng để nối FR với TC."""
    if "RTM" not in wb.sheetnames:
        return
    ws = wb["RTM"]
    with open(out / "_rtm.csv", "w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(["Req ID", "Yêu cầu", "Nguồn (DOC)", "Số TC"])
        for r in ws.iter_rows(min_row=6, values_only=True):
            if clean(r[1]).startswith("REQ"):
                w.writerow([clean(r[1]), clean(r[2]), clean(r[3]), clean(r[4])])


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    xlsx = sys.argv[1]
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else Path(xlsx).parent / "csv"
    out.mkdir(parents=True, exist_ok=True)

    wb = openpyxl.load_workbook(xlsx, data_only=True)
    all_rows, summary, headers = [], [], None
    for ws in wb.worksheets:
        parsed = parse_sheet(ws)
        if not parsed:
            continue
        meta, rows = parsed
        headers = headers or meta["headers"]
        code = meta["code"] or ws.title
        fname = f"{slug(code)}-{slug(meta['name'])}.csv"
        for r in rows:
            r.update({"feature_code": code, "feature": meta["name"], "sheet": ws.title})
        cols = ["feature_code", "feature", "sheet", "section"] + headers
        with open(out / fname, "w", newline="", encoding="utf-8-sig") as f:
            w = csv.DictWriter(f, cols, extrasaction="ignore")
            w.writeheader(); w.writerows(rows)
        all_rows += rows
        summary.append((code, meta["name"], len(rows), len({r["section"] for r in rows}), fname))

    cols = ["feature_code", "feature", "sheet", "section"] + (headers or [])
    with open(out / "all_testcases.csv", "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, cols, extrasaction="ignore")
        w.writeheader(); w.writerows(all_rows)

    write_links(all_rows, out)
    write_rtm(wb, out)
    lines = ["# Testcase parse summary", "", "| Code | Feature | #TC | #Section | CSV |", "|---|---|---|---|---|"]
    lines += [f"| {a} | {b} | {c} | {d} | {e} |" for a, b, c, d, e in summary]
    lines += ["", f"Tổng: {len(all_rows)} TC / {len(summary)} feature."]
    (out / "_summary.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("\n".join(lines)); print(f"\nOut: {out}")


if __name__ == "__main__":
    main()
