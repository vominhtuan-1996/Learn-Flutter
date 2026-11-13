#!/usr/bin/env python3
"""So sánh PRD cũ và PRD mới theo từ, gộp theo từng FR (mục 8.n) và các mục lớn khác.

Dùng: prd_diff.py <old.md> <new_effective.md> > diff.md
Mỗi chỗ khác in: ngữ cảnh | CŨ: «…» → MỚI: «…». Lọc nhiễu định dạng ('= >' vs '=>', bullet '-').
Mặc định nhận FR bằng heading dạng '8.n FR…'; nếu PRD đặt tên khác sửa regex FR_RE.
Gộp theo FR (không theo heading con) vì PRD mới hay đổi cấp heading; so theo heading con sẽ báo sai.
"""
import difflib, re, sys

FR_RE = r"8\.(\d)\s+FR"
TOP_RE = r"(NON-FUNCTIONAL|ARTIFACT|PART [A-C]|DEFINITION OF DONE|REVISION|PERSONAS|SCOPES|BUSINESS PROCESS|USER STORIES|FEATURE CATALOGUE|FEATURE DETAIL|EXECUTIVE|GOALS)"


def norm(s):
    s = re.sub(r"\{#[^}]*\}", " ", s)
    s = re.sub(r"!\[\]\[image\d+\]|\[image\]", " ", s)
    s = s.replace("<br>", " ")
    s = re.sub(r"[“”]", '"', s)
    s = re.sub(r"= >|- >", "=>", s)
    s = re.sub(r"[|*\\#]|:?-{3,}:?", " ", s)
    s = re.sub(r"(?<=\s)-(?=\s)", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def split(path):
    parts, cur, buf = {}, "ĐẦU", []
    for line in open(path, encoding="utf-8"):
        if line.startswith("[image") and "data:" in line:
            continue
        h = re.match(r"^#{1,6}\s+(.*)", line)
        if h:
            t = norm(h.group(1))
            m = re.match(FR_RE, t)
            top = re.match(TOP_RE, t.upper())
            if m or top:
                parts[cur] = parts.get(cur, "") + " " + " ".join(buf)
                buf = []
                cur = f"FR0{m.group(1)}" if m else t.split("–")[0].split(" - ")[0].strip()
        buf.append(line)
    parts[cur] = parts.get(cur, "") + " " + " ".join(buf)
    return {k: norm(v) for k, v in parts.items()}


def main():
    A, B = split(sys.argv[1]), split(sys.argv[2])
    print("Mục bản cũ:", list(A)); print("Mục bản mới:", list(B))
    for k in B:
        if k not in A:
            print(f"\n## {k}: chỉ có ở bản mới (có thể chỉ do tách mục khác cấp; so sánh tay)"); continue
        aw, bw = A[k].split(), B[k].split()
        ops = [o for o in difflib.SequenceMatcher(None, aw, bw, autojunk=False).get_opcodes() if o[0] != "equal"]
        print(f"\n## {k} — {len(ops)} chỗ khác (cũ {len(aw)} từ, mới {len(bw)} từ)")
        for _, i1, i2, j1, j2 in ops:
            print(f"  …{' '.join(aw[max(0, i1 - 7):i1])} | CŨ: «{' '.join(aw[i1:i2])[:420]}» → MỚI: «{' '.join(bw[j1:j2])[:420]}»")


if __name__ == "__main__":
    main()
