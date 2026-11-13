#!/usr/bin/env python3
"""Fallback khi Figma API 429: dựng design_tokens.json + children.tsv từ file .fig local.

  python3 fig_tokens.py <file.fig> <node_id (343:917 hoặc 343-917)> <output_dir>

Cùng schema với bước 1 của SKILL.md (extract_node). Không có PNG — .fig không render được;
phân tích từ tokens là đủ cho bước diff. Dùng bộ giải mã kiwi của figma-export.
"""
import json, os, sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "figma-export"))
import figma_export as fe  # noqa: E402

WEIGHTS = {"thin": 100, "extralight": 200, "light": 300, "regular": 400, "medium": 500,
           "semibold": 600, "bold": 700, "extrabold": 800, "black": 900}


def r2(v):
    return round(v, 2) if isinstance(v, (int, float)) else v


def hexa(c):
    h = "#%02x%02x%02x" % tuple(round(c[k] * 255) for k in "rgb")
    return h + (f" a={c['a']:.2f}" if c.get("a", 1) < 1 else "")


def solids(paints):
    # paint.opacity là lớp riêng ngoài color.a (vd nền pill α0.15) — gộp vào alpha kẻo mất
    return [hexa({**p["color"], "a": p["color"].get("a", 1) * p.get("opacity", 1)})
            for p in paints or [] if p.get("type") == "SOLID" and p.get("visible", True) and "color" in p]


def weight(style):
    return WEIGHTS.get((style or "regular").lower().replace(" ", "").replace("italic", "") or "regular", 400)


def build(nodes, kids, nid, ox, oy):
    c = nodes[nid]
    t = c.get("transform") or {}
    x, y = ox + t.get("m02", 0), oy + t.get("m12", 0)  # cộng dồn transform → toạ độ tuyệt đối
    sz = c.get("size") or {"x": 0, "y": 0}
    corner = c.get("cornerRadius") or 0
    if not corner and c.get("rectangleTopLeftCornerRadius") is not None:
        r = [c.get(f"rectangle{k}CornerRadius", 0) for k in ("TopLeft", "TopRight", "BottomRight", "BottomLeft")]
        corner = r[0] if len(set(r)) == 1 else r
    is_text = c.get("type") == "TEXT"
    fn = c.get("fontName") or {}
    out = {
        "id": nid, "name": c.get("name"), "type": c.get("type"),
        "size": {"w": round(sz["x"], 2), "h": round(sz["y"], 2)},
        "position": {"x": round(x, 2), "y": round(y, 2)},
        "padding": {"top": r2(c.get("stackVerticalPadding", 0)), "right": r2(c.get("stackPaddingRight", 0)),
                    "bottom": r2(c.get("stackPaddingBottom", 0)), "left": r2(c.get("stackHorizontalPadding", 0))},
        "gap": r2(c.get("stackSpacing", 0)) or 0,
        "layout": c.get("stackMode", "NONE"),
        "fills": solids(c.get("fillPaints")),
        "strokes": solids(c.get("strokePaints")),
        "strokeWeight": c.get("strokeWeight") if c.get("strokePaints") else None,
        "corner": r2(corner) if not isinstance(corner, list) else [r2(v) for v in corner],
        "effects": [{"type": e["type"], "x": e.get("offset", {}).get("x"), "y": e.get("offset", {}).get("y"),
                     "blur": e.get("radius"), "color": hexa(e["color"])}
                    for e in c.get("effects", []) if e.get("visible", True) and "color" in e],
        "text": (c.get("textData") or {}).get("characters") if is_text else None,
        "font": {"size": c.get("fontSize"), "weight": weight(fn.get("style")), "family": fn.get("family"),
                 "letterSpacing": (c.get("letterSpacing") or {}).get("value")} if is_text else None,
        "children": [build(nodes, kids, k, x, y) for k in kids.get(nid, [])],
    }
    return out


def tree(n, d=0):
    bits = [f"{'  ' * d}[{n['type']}] {n['name']} | {n['size']['w']}×{n['size']['h']}"]
    if n["fills"]: bits.append(f"fill={n['fills']}")
    if n["corner"]: bits.append(f"r={n['corner']}")
    p = n["padding"]
    if any(p.values()): bits.append(f"pad={p['top']},{p['right']},{p['bottom']},{p['left']}")
    if n["gap"]: bits.append(f"gap={n['gap']}")
    if n["layout"] != "NONE": bits.append(n["layout"])
    if n["text"]: bits.append(f"'{n['text']}'")
    if n["font"]: bits.append(f"{n['font']['size']}px w{n['font']['weight']}")
    print(" | ".join(bits))
    for k in n["children"]: tree(k, d + 1)


def main():
    if len(sys.argv) != 4: sys.exit(__doc__)
    fig, node, out = sys.argv[1], sys.argv[2].replace("-", ":"), sys.argv[3]
    msg = fe.read_fig(fig)
    nodes, kids = {}, {}
    for c in msg["nodeChanges"]:
        g = c["guid"]; nid = f"{g['sessionID']}:{g['localID']}"
        nodes[nid] = c
        pi = c.get("parentIndex") or {}
        if pi.get("guid"):
            p = pi["guid"]; kids.setdefault(f"{p['sessionID']}:{p['localID']}", []).append((pi.get("position", ""), nid))
    kids = {p: [n for _, n in sorted(v)] for p, v in kids.items()}
    if node not in nodes:
        sys.exit(f"Node {node} không có trong .fig — Save local copy lại từ đúng file/page")
    root = build(nodes, kids, node, 0, 0)
    root["position"] = {"x": 0, "y": 0}  # toạ độ tương đối gốc = node target
    os.makedirs(out, exist_ok=True)
    json.dump(root, open(f"{out}/design_tokens.json", "w"), indent=2, ensure_ascii=False)
    with open(f"{out}/children.tsv", "w") as f:
        for ch in root["children"]: f.write(f"{ch['id']}\t{ch['name']}\t{ch['type']}\n")
    print(f"=== Node: {root['name']} | type: {root['type']} | {root['size']['w']}×{root['size']['h']} | children: {len(root['children'])} (source: .fig) ===\n")
    tree(root)
    print(f"\nSaved: {out}/design_tokens.json, children.tsv")


if __name__ == "__main__":
    main()
