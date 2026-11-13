"""Thư viện sửa file markdown an toàn: mỗi chỗ sửa phải khớp ĐÚNG số lần mong đợi, nếu không thì dừng.
Đặt thư mục PRD bằng biến môi trường PRD_ROOT (vd learnflutter/docs/prd-v1.0).
"""
import os
from pathlib import Path
ROOT = Path(os.environ.get("PRD_ROOT", "."))

class P:
    def __init__(self, rel):
        self.path = ROOT / rel
        self.text = self.path.read_text(encoding="utf-8")
        self.n = 0
    def rep(self, old, new, count=1):
        c = self.text.count(old)
        assert c == count, f"{self.path.name}: '{old[:60]}' xuất hiện {c} lần (cần {count})"
        self.text = self.text.replace(old, new); self.n += 1
    def line(self, no, old, new):  # sửa trong 1 dòng theo số dòng (1-based), kiểm tra nội dung
        L = self.text.split("\n")
        assert old in L[no - 1], f"{self.path.name}:{no} không chứa '{old[:60]}'"
        L[no - 1] = L[no - 1].replace(old, new, 1); self.text = "\n".join(L); self.n += 1
    def after_line(self, no, startswith, newline):
        L = self.text.split("\n")
        assert L[no - 1].startswith(startswith), f"{self.path.name}:{no} không bắt đầu '{startswith[:50]}'"
        L.insert(no, newline); self.text = "\n".join(L); self.n += 1
    def save(self):
        self.path.write_text(self.text, encoding="utf-8"); print(f"{self.path.parent.name}/{self.path.name}: {self.n} chỗ")

def del_rows(p, startswith_list, expect=None):
    """Xóa các dòng bảng bắt đầu bằng tiền tố; mỗi tiền tố phải khớp đúng 1 dòng."""
    L = p.text.split("\n")
    for sw in startswith_list:
        hits = [i for i, l in enumerate(L) if l.startswith(sw)]
        assert len(hits) == 1, f"{p.path.name}: '{sw[:50]}' khớp {len(hits)} dòng"
        del L[hits[0]]; p.n += 1
    p.text = "\n".join(L)
