#!/usr/bin/env python3
"""Trích text thô từ file .docx sang .txt, KHÔNG cần pandoc/python-docx
(máy dev hiện tại không có cả hai). Dùng khi cần grep nội dung PRD/BRD
dạng .docx trong docs/brd/ — chỉ đọc, không sửa file gốc.

Usage: python3 extract_prd_docx.py <path/to/file.docx> [output.txt]
Mặc định output: /tmp/<tên file>.txt (không ghi vào repo).
"""
import html
import re
import sys
import zipfile
from pathlib import Path


def extract(docx_path: str, out_path: str) -> int:
    with zipfile.ZipFile(docx_path) as z:
        xml = z.read("word/document.xml").decode("utf-8")
    # Mỗi <w:p ...> hoặc <w:p> là 1 đoạn/1 ô bảng — tách dòng tại đó trước khi
    # bóc hết tag, giữ được cấu trúc dòng tối thiểu để grep -n còn dùng được.
    text = re.sub(r"<w:p[ >]", "\n", xml)
    text = re.sub(r"<[^>]+>", "", text)
    text = html.unescape(text)
    text = re.sub(r"\n{2,}", "\n", text)
    Path(out_path).write_text(text, encoding="utf-8")
    return text.count("\n")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: extract_prd_docx.py <file.docx> [output.txt]", file=sys.stderr)
        sys.exit(1)
    docx_path = sys.argv[1]
    out_path = sys.argv[2] if len(sys.argv) > 2 else f"/tmp/{Path(docx_path).stem}.txt"
    lines = extract(docx_path, out_path)
    print(f"{out_path} ({lines} dòng)")
