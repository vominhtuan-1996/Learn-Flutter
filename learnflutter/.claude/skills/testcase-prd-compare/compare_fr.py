#!/usr/bin/env python3
"""So sánh 1 FR của PRD (index.md) với testcase của FR đó (tc-NN-*.csv) -> report .md.

Usage: compare_fr.py <fr_index.md> <tc.csv> <rtm.csv|-> <out.md>
Máy móc: trích mục kiểm thử được từ PRD (Trigger/Pre/Post, BR, bước, field, message trong ngoặc kép),
nối với TC qua RTM (Req ID -> nguồn PRD), fallback tìm text. Đánh giá ngữ nghĩa là việc của agent.
"""
import csv, re, sys
from pathlib import Path

QUOTE = re.compile(r"[\"“”]([^\"“”]{6,80})[\"“”]")
BR = re.compile(r"BR-?\d+-\d+", re.I)


def norm(s):
    return re.sub(r"\s+", " ", s.replace("\\", "").replace("*", "").replace("`", "")).strip()


def key(s):
    return re.sub(r"[\"“”'‘’]", "", norm(s)).lower()


def cells(line):
    return [norm(c) for c in line.strip().strip("|").split("|")]


def extract_items(md):
    """Trả list {id, type, text, section}."""
    items, header, section = [], None, ""
    for line in Path(md).read_text(encoding="utf-8").splitlines():
        if line.startswith("## "):
            section = norm(line[3:])
        if not line.startswith("|"):
            header = None
            continue
        c = cells(line)
        if set("".join(c)) <= set("-: "):
            continue
        low = [x.lower() for x in c]
        if header is None:
            header = low
            if low[0] in ("description",) or (len(c) == 2 and low[0] and low[1] == ""):
                pass
            # bảng key/value đầu FR: header giả là dòng Description
            if low[0] == "description":
                header = ["kv"]
            continue
        if header == ["kv"]:
            if low[0] in ("trigger", "pre-conditions", "post-conditions"):
                items.append({"id": c[0], "type": "condition", "text": c[1], "section": "Header FR"})
        elif header[0] == "br id" and BR.fullmatch(c[0]):
            items.append({"id": c[0], "type": "br", "text": c[1], "section": section})
        elif header[0] == "id" and "activity" in header[1] and c[0].isdigit():
            items.append({"id": f"bước {c[0]}", "type": "step", "text": c[1], "section": section})
        elif header[0] == "stt" and len(c) >= 5:
            name, desc = c[1], c[-1]
            if not name:
                continue  # dòng nhóm "Header" chỉ có STT in đậm
            items.append({"id": name, "type": "field", "text": f"{c[3]} — {desc}", "section": section})
            for q in QUOTE.findall(desc):
                items.append({"id": q, "type": "message", "text": f"trong field «{name}»", "section": section})
    return items


def load_tc(path):
    with open(path, encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))


def tc_text(r):
    return key(" ".join(r.get(k, "") for k in ("Test Title", "Pre-condition", "Test Steps", "Expected Result")))


def rtm_map(path, tc_reqs):
    """item-key -> set(Req ID) từ cột nguồn của RTM, chỉ lấy Req có TC trong CSV này."""
    m = {}
    if path == "-" or not Path(path).exists():
        return m
    for r in load_tc(path):
        if r["Req ID"] not in tc_reqs:
            continue
        src = r["Nguồn (DOC)"]
        keys = {b.upper().replace("-", "") for b in BR.findall(src)}
        keys |= {f"bước {n}" for n in re.findall(r"bước (\d+)", src)}
        keys |= {key(x) for q in re.findall(r"field \"([^\n]+?)\"(?: ·|$)", src) for x in q.split(" / ")}
        keys |= {key(x) for x in re.findall(r"·\s*(Trigger|Pre-Conditions|Post-Conditions)\b", src, re.I)}
        for k in keys:
            m.setdefault(k.lower() if not k.startswith("BR") else k, set()).add(r["Req ID"])
    return m


def link(item, tcs, texts, rtm, reqs_by_key):
    k = item["id"]
    kk = k.upper().replace("-", "") if item["type"] == "br" else key(k)
    via_rtm = sorted(reqs_by_key.get(kk, reqs_by_key.get(kk.lower(), set())))
    ids = [t["Testcase ID"] for t in tcs if t["Req ID"] in via_rtm]
    if ids:
        return "covered", ids
    if item["type"] in ("field", "message", "condition"):
        kq = key(k)
        ids = [t["Testcase ID"] for t, x in zip(tcs, texts) if len(kq) >= 4 and kq in x]
        if ids:
            return "text-only", ids
    return "uncovered", []


def main():
    if len(sys.argv) < 5:
        sys.exit(__doc__)
    md, tc_csv, rtm_csv, out = sys.argv[1:5]
    items, tcs = extract_items(md), load_tc(tc_csv)
    if not items:
        sys.exit("Không trích được mục nào từ PRD FR (kiểm định dạng bảng BR/bước/field)")
    texts = [tc_text(t) for t in tcs]
    tc_reqs = {t["Req ID"] for t in tcs}
    reqs_by_key = rtm_map(rtm_csv, tc_reqs)

    rows, used = [], set()
    for it in items:
        st, ids = link(it, tcs, texts, rtm_csv, reqs_by_key)
        used.update(ids)
        rows.append((it, st, ids))
    orphans = [t for t in tcs if t["Testcase ID"] not in used]

    cnt = {s: sum(1 for _, x, _ in rows if x == s) for s in ("covered", "text-only", "uncovered")}
    L = [f"# So sánh PRD ↔ Testcase — {Path(md).parent.name}", "",
         f"- PRD: `{md}`", f"- Testcase: `{tc_csv}` ({len(tcs)} TC)", f"- RTM: `{rtm_csv}`", "",
         "## Tổng quan", "",
         f"- Mục PRD trích được: {len(items)} — covered {cnt['covered']}, text-only {cnt['text-only']}, uncovered {cnt['uncovered']}",
         f"- TC chưa nối được mục PRD nào: {len(orphans)}/{len(tcs)}", "",
         "Nguồn chuẩn: **PRD**. Lệch giữa PRD và TC → TC sai/thiếu, không phải PRD.", "",
         "`covered` = nối qua RTM · `text-only` = chỉ khớp text, nối yếu · `uncovered` = không thấy TC", "",
         "## PRD chưa có TC (uncovered)", ""]
    unc = [(i, ids) for i, s, ids in rows if s == "uncovered"]
    L += [f"- [{i['type']}] **{i['id']}** — {i['text'][:140]} _({i['section']})_" for i, _ in unc] or ["- (không)"]
    L += ["", "## Nối yếu (text-only)", ""]
    L += [f"- [{i['type']}] **{i['id']}** → {' '.join(ids[:8])}" for i, s, ids in rows if s == "text-only"] or ["- (không)"]
    L += ["", "## TC chưa nối mục PRD nào (orphan — PRD là chuẩn: mặc định TC thừa/ngoài scope, cần QC xác nhận)", ""]
    L += [f"- {t['Testcase ID']} ({t['Req ID']}) — {t['Test Title'][:100]}" for t in orphans[:60]] or ["- (không)"]
    if len(orphans) > 60:
        L.append(f"- … còn {len(orphans) - 60} TC")
    L += ["", "## Bảng đầy đủ", "", "| Loại | Mục PRD | Trạng thái | TC |", "|---|---|---|---|"]
    L += [f"| {i['type']} | {i['id']} | {s} | {' '.join(ids[:6])}{' …' if len(ids) > 6 else ''} |" for i, s, ids in rows]
    Path(out).write_text("\n".join(L) + "\n", encoding="utf-8")
    print("\n".join(L[:12]))
    print(f"\nOut: {out}")


if __name__ == "__main__":
    main()
