#!/usr/bin/env python3
"""docx -> markdown tối giản (stdlib, không cần pandoc). Dùng: docx2md.py <file.docx> <out_raw.md>

- Heading theo style name, bảng -> pipe table, list -> '-', **bold**, ảnh -> [image].
- Văn bản gạch ngang (w:strike) -> ~~văn bản~~. Trong PRD, gạch ngang = nội dung BỊ BỎ ở bản mới.
- Đi vào khối w:sdt (content control); thiếu bước này mất cả mục lớn của tài liệu.
Chỉ đọc file docx; không chạy macro, không ghi ngoài out.
"""
import re, sys, zipfile
import xml.etree.ElementTree as ET

W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
z = zipfile.ZipFile(sys.argv[1])
doc = ET.fromstring(z.read("word/document.xml"))
styles = ET.fromstring(z.read("word/styles.xml"))
sname = {s.get(W + "styleId"): (s.find(W + "name").get(W + "val") if s.find(W + "name") is not None else "") for s in styles.iter(W + "style")}

def runs(p):
    out = []
    for r in p.iter(W + "r"):
        t = "".join((x.text or "") for x in r if x.tag in (W + "t",)) 
        if r.find(W + "tab") is not None: t += " "
        if r.find(W + "br") is not None: t += "<br>"
        if r.find(".//" + W + "drawing") is not None: t += "[image]"
        if not t: continue
        b = r.find(W + "rPr/" + W + "b")
        bold = b is not None and b.get(W + "val") not in ("0", "false")
        st = r.find(W + "rPr/" + W + "strike")
        struck = st is not None and st.get(W + "val") not in ("0", "false")
        seg = "**" + t.strip() + "**" if bold and t.strip() else t
        out.append(("~~" + seg + "~~") if struck and t.strip() else seg)
    s = "".join(out).replace("~~~~", "").replace("~~ ~~", " ")
    return re.sub(r"\*\*\s*\*\*", "", s.replace("****", "")).strip()

def para(p):
    st = sname.get((p.find(W + "pPr/" + W + "pStyle").get(W + "val") if p.find(W + "pPr/" + W + "pStyle") is not None else ""), "")
    txt = runs(p)
    if not txt: return ""
    m = re.match(r"heading (\d)", st.lower())
    if m: return "#" * int(m.group(1)) + " " + txt
    if p.find(W + "pPr/" + W + "numPr") is not None:
        lvl = p.find(W + "pPr/" + W + "numPr/" + W + "ilvl")
        n = int(lvl.get(W + "val")) if lvl is not None else 0
        return "  " * n + "- " + txt
    return txt

def table(t):
    rows = []
    for tr in t.findall(W + "tr"):
        cells = []
        for tc in tr.findall(W + "tc"):
            parts = [para(p) for p in tc.iter(W + "p")]
            cells.append(" <br> ".join(x for x in parts if x).replace("|", "\\|"))
        rows.append(cells)
    if not rows: return ""
    n = max(len(r) for r in rows)
    rows = [r + [""] * (n - len(r)) for r in rows]
    L = ["| " + " | ".join(rows[0]) + " |", "| " + " | ".join([":----"] * n) + " |"]
    L += ["| " + " | ".join(r) + " |" for r in rows[1:]]
    return "\n".join(L)

out = []

def walk(parent):
    for el in parent:
        if el.tag == W + "p":
            s = para(el)
            if s: out.append(s)
        elif el.tag == W + "tbl":
            out.append(table(el))
        elif el.tag == W + "sdt":  # content control: nội dung nằm trong sdtContent
            c = el.find(W + "sdtContent")
            if c is not None: walk(c)

walk(doc.find(W + "body"))
open(sys.argv[2], "w", encoding="utf-8").write("\n\n".join(out) + "\n")
print(len(out), "blocks")
