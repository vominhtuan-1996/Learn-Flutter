#!/usr/bin/env python3
"""Mẫu script áp dụng thay đổi PRD vào các file breakdown hiện có. Sao chép, sửa nội dung, chạy 1 lần.

PRD_ROOT=learnflutter/docs/prd-v1.0 python3 -I patch_<version>.py
Mỗi thao tác phải khớp đúng số lần mong đợi, sai là dừng và không ghi gì cho file đó.
"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from patchlib import P, del_rows

# --- sửa 1 chỗ trong 1 dòng/đoạn
f = P("01-fr01-dang-nhap/index.md")
f.rep("câu cũ nguyên văn", "câu mới nguyên văn")                       # khớp đúng 1 lần
f.rep("| BR01-03 | …cũ… |", "| BR01-03 | …mới… |\n| BR01-04 | thêm dòng BR mới |")  # thêm dòng
del_rows(f, ["|  | Tên field bị bỏ |"])                                # xóa dòng bảng theo tiền tố (khớp đúng 1 dòng)
f.save()

# --- đổi cùng một cụm ở nhiều chỗ: truyền count
g = P("03-fr03-quan-ly-thiet-bi/index.md")
g.rep("BR-02-0", "BR-03-0", 5)
g.save()
