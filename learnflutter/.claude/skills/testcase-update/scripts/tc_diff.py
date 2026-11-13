#!/usr/bin/env python3
"""So sánh 2 bộ CSV testcase (đầu ra testcase-parse): ghép theo tiêu đề, rồi so từng cặp.

Dùng: tc_diff.py <thư_mục_cũ> <thư_mục_mới> [--json diff.json] > diff.md
Ghép TC cũ↔mới theo tiêu đề (exact rồi ≥0.85) vì QC thường đánh số lại cả loạt. Phân loại: THÊM, BỎ,
ĐỔI MÃ (cùng TC, ID khác), TÁI SỬ DỤNG MÃ (ID có ở cả "bỏ" và "thêm"), ĐỔI THIẾT KẾ (Title/Steps/Expected/Req ID/…; khóa theo mã cũ),
ĐỔI KẾT QUẢ (cột Kết quả/Note…). Đổi thiết kế mới cần chạy lại TC; đổi kết quả thì không.
"""
import difflib, json, re, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from tcids import load_dir, DESIGN_COLS, RESULT_COLS

ratio = lambda a, b: difflib.SequenceMatcher(None, a, b, autojunk=False).ratio()
norm = lambda s: " ".join(s.lower().split())


def canon(col, s):
    """Chuẩn hóa trước khi so: QC hay thêm nhãn '(setup)' vào bước chuẩn bị — không phải đổi thiết kế."""
    s = s.strip()
    if col == "Test Steps": s = re.sub(r"[ \t]*\(setup\)", "", s)
    return s


def match(old, new):
    """Ghép TC cũ ↔ mới theo tiêu đề (QC hay đánh số lại cả loạt khi bỏ/chèn TC, nên ghép theo ID là sai).
    Vòng 1: tiêu đề trùng chính xác (cùng feature, theo thứ tự). Vòng 2: giống ≥0.85."""
    pairs, used = {}, set()
    by_title = {}
    for t, r in new.items():
        by_title.setdefault((r["feature_code"], norm(r["Test Title"])), []).append(t)
    for t, r in old.items():
        for cand in by_title.get((r["feature_code"], norm(r["Test Title"])), []):
            if cand not in used:
                pairs[t] = cand; used.add(cand); break
    for t, r in old.items():
        if t in pairs: continue
        cand = [(ratio(norm(r["Test Title"]), norm(new[a]["Test Title"])), a) for a in new
                if a not in used and new[a]["feature_code"] == r["feature_code"]]
        if cand and max(cand)[0] >= 0.85:
            pairs[t] = max(cand)[1]; used.add(max(cand)[1])
    return pairs


def diff(old, new):
    pairs = match(old, new)
    removed = [t for t in old if t not in pairs]
    added = [t for t in new if t not in set(pairs.values())]
    renum = {o: n for o, n in pairs.items() if o != n}
    # cùng ID nhưng nội dung khác hẳn: ID nằm ở cả "bỏ" và "thêm" (tham chiếu cũ trỏ nhầm TC)
    reused = [t for t in removed if t in added]
    design, result = {}, {}
    for o, n in pairs.items():
        a, b = old[o], new[n]
        d = {c: (a.get(c, ""), b.get(c, "")) for c in DESIGN_COLS if canon(c, a.get(c, "")) != canon(c, b.get(c, ""))}
        r = {c: (a.get(c, ""), b.get(c, "")) for c in RESULT_COLS if a.get(c, "").strip() != b.get(c, "").strip()}
        if d: design[o] = d
        if r: result[o] = r
    return added, removed, renum, reused, design, result, pairs


def short(s, n=140):
    s = " ".join(s.split())
    return s if len(s) <= n else s[:n] + "…"


def main():
    old, new = load_dir(sys.argv[1]), load_dir(sys.argv[2])
    added, removed, renum, reused, design, result, pairs = diff(old, new)
    key = lambda t: tuple(int(x) for x in t.replace("TC_", "").split("."))
    print(f"# So sánh testcase\n\n- Cũ: {len(old)} TC ({sys.argv[1]})\n- Mới: {len(new)} TC ({sys.argv[2]})\n"
          f"- THÊM {len(added)} · BỎ {len(removed)} · ĐỔI MÃ {len(renum)} · TÁI SỬ DỤNG MÃ {len(reused)} · ĐỔI THIẾT KẾ {len(design)} · ĐỔI KẾT QUẢ {len(result)}\n")
    if reused:
        print("## ⚠ Tái sử dụng mã (cùng ID nhưng là TC khác)\n\nTham chiếu cũ tới các ID này (flow Maestro, báo cáo chạy, bằng chứng) đang trỏ nhầm TC.\n")
        for t in sorted(reused, key=key): print(f"- {t}: «{short(old[t]['Test Title'], 80)}» → «{short(new[t]['Test Title'], 80)}»")
        print()
    if renum:
        print(f"## Đổi mã ({len(renum)} TC) — tham chiếu theo ID cũ sẽ trỏ nhầm\n")
        shown = sorted(renum.items(), key=lambda x: key(x[0]))
        # đánh số lại cả loạt: chỉ liệt kê điểm bắt đầu mỗi đoạn lệch (đủ để biết khoảng bị dịch)
        prev = None
        for o, n in shown:
            delta = int(n.split(".")[1]) - int(o.split(".")[1])
            if (o.split(".")[0], delta) != prev:
                print(f"- từ {o} → {n} (lệch {delta:+d}): {short(new[n]['Test Title'], 80)}")
                prev = (o.split(".")[0], delta)
        print()
    if added:
        print("## Thêm\n"); [print(f"- {t} [{new[t]['section']}] {short(new[t]['Test Title'], 110)}") for t in sorted(added, key=key)]; print()
    if removed:
        print("## Bỏ\n"); [print(f"- {t} [{old[t]['section']}] {short(old[t]['Test Title'], 110)}") for t in sorted(removed, key=key)]; print()
    if design:
        print("## Đổi thiết kế (cần chạy lại)\n")
        for t in sorted(design, key=key):
            n = pairs[t]
            print(f"### {t}" + (f" → {n}" if n != t else "") + f" — {short(new[n]['Test Title'], 100)}")
            for c, (o, n) in design[t].items(): print(f"- **{c}**: «{short(o)}» → «{short(n)}»")
        print()
    if result:
        cols = {}
        for t_, c_ in result.items():
            for c in c_: cols.setdefault(c, []).append(t_)
        print("## Đổi cột kết quả/ghi chú (không đổi thiết kế)\n")
        for c, ts in cols.items():
            vals = {(result[t_][c][0], result[t_][c][1]) for t_ in ts}
            print(f"- **{c}**: {len(ts)} TC" + (f" (vd «{short(next(iter(vals))[0], 40)}» → «{short(next(iter(vals))[1], 40)}»)" if len(vals) <= 3 else ""))
    if "--json" in sys.argv:
        Path(sys.argv[sys.argv.index("--json") + 1]).write_text(json.dumps(
            {"added": added, "removed": removed, "renumbered": renum, "reused": reused, "pairs": pairs,
             "design": {t: list(d) for t, d in design.items()}, "result": {t: list(d) for t, d in result.items()}}, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
