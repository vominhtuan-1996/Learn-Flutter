#!/usr/bin/env python3
"""Liệt kê comment của người sửa trong docx kèm đoạn văn bản được gắn.

Dùng: docx_comments.py <file.docx> > comments.md
Comment thường nói rõ lý do ("bỏ hiển thị…", "cập nhật tên tab…"); comment không gắn văn bản
(đoạn gắn rỗng) cần hỏi BA vì không biết sửa chỗ nào.
"""
import sys, zipfile
import xml.etree.ElementTree as ET

W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
z = zipfile.ZipFile(sys.argv[1])
if "word/comments.xml" not in z.namelist():
    sys.exit("Không có comment trong file.")
cm = {c.get(W + "id"): (c.get(W + "author"), c.get(W + "date"), "".join(t.text or "" for t in c.iter(W + "t")))
      for c in ET.fromstring(z.read("word/comments.xml")).iter(W + "comment")}
active, anchored = set(), {k: [] for k in cm}
for el in ET.fromstring(z.read("word/document.xml")).iter():
    if el.tag == W + "commentRangeStart": active.add(el.get(W + "id"))
    elif el.tag == W + "commentRangeEnd": active.discard(el.get(W + "id"))
    elif el.tag == W + "t":
        for k in active: anchored[k].append(el.text or "")
seen = set()
for k, (author, date, text) in cm.items():
    anchor = "".join(anchored[k]).strip()
    if (text, anchor[:80]) in seen: continue  # comment nhân đôi khi gắn nhiều dòng bảng
    seen.add((text, anchor[:80]))
    flag = "" if anchor else "  **[KHÔNG GẮN VĂN BẢN — hỏi BA]**"
    print(f"- [{k}] {author} {date[:10]}: «{text}» ← {anchor[:220] or '(trống)'}{flag}")
