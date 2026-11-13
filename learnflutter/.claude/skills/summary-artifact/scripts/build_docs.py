#!/usr/bin/env python3
"""Dựng 3 tài liệu JSON để ghi vào store của artifact kiểu Dashboard.

Dùng:
  python3 build_docs.py --rows rows.json --out <dir> --title "Bug R1 LearnFlutter" \
      --blob-url /_blob/<id> --source-note "Nguồn: ..." [--subtitle ...] [--takeaway ...]

Ghi ra <dir>: meta_doc.json (dash/meta), ds_doc.json (datasets/bugs), index_doc.json (files/index.html).
Chỉ dùng thư viện chuẩn. Không đọc hay ghi credential.
"""
import argparse
import datetime
import html
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
TEMPLATE = os.path.join(HERE, "..", "assets", "dashboard_page.html")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rows", required=True, help="rows.json do parse_summary.py tạo")
    ap.add_argument("--out", required=True)
    ap.add_argument("--title", required=True, help="Tên dashboard, 2-4 từ")
    ap.add_argument("--subtitle", default="")
    ap.add_argument("--takeaway", default="")
    ap.add_argument("--source-note", default="")
    ap.add_argument("--blob-url", required=True, help="url /_blob/<id> sau khi upload rows.json")
    ap.add_argument("--by", default="Claude, từ file summary")
    args = ap.parse_args()

    rows = json.load(open(args.rows, encoding="utf-8"))
    if not rows:
        raise SystemExit("rows.json rỗng")
    if not re.fullmatch(r"/_blob/[0-9a-f]{32}", args.blob_url):
        raise SystemExit("--blob-url phải đúng dạng /_blob/<32 ký tự hex> như kết quả upload")

    os.makedirs(args.out, exist_ok=True)
    esc = html.escape
    # Câu tóm tắt chỉ chứa lời, không chứa con số: mọi con số trên trang phải đến từ dataset.
    subtitle = args.subtitle or args.takeaway or "Bấm \"Chỉ To Do\" để xem các bug chưa ai nhận xử lý."
    page = open(TEMPLATE, encoding="utf-8").read()
    for token, value in (("{{TITLE}}", args.title), ("{{SUBTITLE}}", subtitle), ("{{SOURCE_NOTE}}", args.source_note)):
        page = page.replace(token, esc(value))
    if "{{" in page:
        raise SystemExit("Template còn placeholder chưa thay")

    def dump(name, obj):
        with open(os.path.join(args.out, name), "w", encoding="utf-8") as f:
            json.dump(obj, f, ensure_ascii=False)

    dump("meta_doc.json", {"title": args.title})
    dump("ds_doc.json", {
        "title": args.title[:30],
        "description": f"{len(rows)} bug lấy từ file summary; mỗi dòng gồm mã, tóm tắt, trạng thái, người xử lý, module, ưu tiên.",
        "source": {"kind": "file", "url": args.blob_url, "name": "rows.json", "format": "json"},
        "updated": {"at": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"), "by": args.by},
        "fixed": True,
    })
    dump("index_doc.json", {"text": page})
    print(f"Đã tạo meta_doc.json, ds_doc.json, index_doc.json trong {args.out} ({len(rows)} bug)")


if __name__ == "__main__":
    main()
