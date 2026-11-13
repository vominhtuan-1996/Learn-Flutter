#!/usr/bin/env python3
"""Export icon SVG từ Figma node.

Hướng 2 (mặc định): 1 request /nodes?geometry=paths, cache JSON, dựng SVG bằng Python.
Hướng 1 (fallback khi 429 hoặc --fig): đọc file .fig local (File > Save local copy).

  python3 figma_export.py <figma_url> [--dest learnflutter/assets/icons] [--fig file.fig]

# ponytail: fill/stroke chỉ hỗ trợ solid (gradient lấy stop đầu), không xử lý rotation/mask/effect.
# Icon lệch so với Figma → export tay node đó, hoặc mở rộng build_svg().
"""
import argparse, json, os, re, ssl, struct, sys, urllib.error, urllib.request, urllib.parse, zipfile, zlib

VECTORS = {"VECTOR", "BOOLEAN_OPERATION", "ELLIPSE", "LINE", "POLYGON", "STAR", "RECTANGLE"}
CONTAINERS = {"FRAME", "GROUP", "COMPONENT", "INSTANCE"}
GENERIC = re.compile(r"^(svg|vector|frame|group|icon|container|overlay.*)\s*\d*$", re.I)


# ---------- args / env ----------
def parse_url(url):
    q = urllib.parse.urlparse(url)
    key = q.path.split("/design/")[1].split("/")[0]
    node = urllib.parse.parse_qs(q.query)["node-id"][0].replace("-", ":")
    return key, node


def read_token():
    try:
        for line in open(".env"):
            if line.startswith("FIGMA_TOKEN="):
                t = line.split("=", 1)[1].strip().strip("\"'")
                if t and t != "your_figma_pat_here":
                    return t
    except FileNotFoundError:
        pass
    sys.exit("FIGMA_TOKEN chưa cấu hình trong .env")


# ---------- hướng 2: REST API, 1 request ----------
def fetch_node(key, node, cache):
    if os.path.exists(cache):
        return json.load(open(cache))["nodes"][node]["document"]
    req = urllib.request.Request(
        f"https://api.figma.com/v1/files/{key}/nodes?ids={node}&geometry=paths",
        headers={"X-Figma-Token": read_token()},
    )
    try:
        # Python.org trên macOS không có CA mặc định → dùng bundle hệ thống
        ca = "/etc/ssl/cert.pem"
        ctx = ssl.create_default_context(cafile=ca if os.path.exists(ca) else None)
        raw = urllib.request.urlopen(req, context=ctx).read()
    except urllib.error.HTTPError as e:
        if e.code == 429:
            return None  # caller chuyển sang .fig
        sys.exit(f"Figma API {e.code}: token sai/hết hạn (403) hoặc file/node sai (404)")
    open(cache, "wb").write(raw)
    return json.loads(raw)["nodes"][node]["document"]


# ---------- hướng 1: .fig local (kiwi) ----------
class Reader:
    def __init__(self, b):
        self.b, self.i = b, 0

    def byte(self):
        v = self.b[self.i]; self.i += 1; return v

    def uint(self):
        n = s = 0
        while True:
            c = self.byte(); n |= (c & 127) << s; s += 7
            if c < 128: return n

    def int(self):
        n = self.uint()
        return ~(n >> 1) if n & 1 else n >> 1

    def float(self):
        if self.b[self.i] == 0: self.i += 1; return 0.0
        n = int.from_bytes(self.b[self.i:self.i + 4], "little"); self.i += 4
        n = (n << 23 | n >> 9) & 0xFFFFFFFF  # kiwi xoay bit float
        return struct.unpack("<f", struct.pack("<I", n))[0]

    def string(self):
        j = self.b.index(0, self.i); s = self.b[self.i:j].decode(); self.i = j + 1; return s

    def bytes(self):
        n = self.uint(); v = self.b[self.i:self.i + n]; self.i += n; return v


BUILTIN = {-1: "bool", -2: "byte", -3: "int", -4: "uint", -5: "float", -6: "string", -7: "int", -8: "uint"}


def parse_schema(b):
    r, defs = Reader(b), []
    for _ in range(r.uint()):
        name, kind = r.string(), r.byte()
        fields = [(r.string(), r.int(), r.byte(), r.uint()) for _ in range(r.uint())]
        defs.append((name, kind, fields))
    return defs


def decode(r, defs, t):
    if t in BUILTIN:
        k = BUILTIN[t]
        return {"bool": lambda: bool(r.byte()), "byte": r.byte, "int": r.int, "uint": r.uint,
                "float": r.float, "string": r.string}[k]()
    name, kind, fields = defs[t]
    if kind == 0:  # enum
        v = r.uint()
        return next((n for n, _, _, val in fields if val == v), v)
    out = {}
    if kind == 1:  # struct
        for n, ft, arr, _ in fields:
            if ft == -2 and arr:
                out[n] = r.bytes(); continue
            out[n] = [decode(r, defs, ft) for _ in range(r.uint())] if arr else decode(r, defs, ft)
        return out
    while True:  # message
        idx = r.uint()
        if idx == 0: return out
        n, ft, arr, _ = next(f for f in fields if f[3] == idx)
        if ft == -2 and arr:
            out[n] = r.bytes()  # byte[] blob
        else:
            out[n] = [decode(r, defs, ft) for _ in range(r.uint())] if arr else decode(r, defs, ft)


def commands_to_path(blob):
    r, d = Reader(blob), []
    f = lambda: f"{struct.unpack('<f', blob[r.i:r.i + 4])[0]:.4f}".rstrip("0").rstrip(".")
    def num():
        v = f(); r.i += 4; return v
    while r.i < len(blob):
        c = r.byte()
        if c == 0: d.append("Z")
        elif c == 1: d.append(f"M{num()} {num()}")
        elif c == 2: d.append(f"L{num()} {num()}")
        elif c == 3: d.append("Q" + " ".join(num() for _ in range(4)))
        elif c == 4: d.append("C" + " ".join(num() for _ in range(6)))
        else: break
    return "".join(d)


def read_fig(path):
    """Giải mã file .fig (kiwi) → dict message (nodeChanges, blobs)."""
    data = open(path, "rb").read()
    if data[:2] == b"PK":
        data = zipfile.ZipFile(path).read("canvas.fig")
    if data[:8] != b"fig-kiwi":
        sys.exit(".fig không đúng định dạng fig-kiwi")
    i, chunks = 12, []
    while i < len(data):
        n = struct.unpack("<I", data[i:i + 4])[0]; chunks.append(data[i + 4:i + 4 + n]); i += 4 + n
    def inflate(b):
        if b[:4] == b"\x28\xb5\x2f\xfd":  # zstd magic
            try:
                import zstandard
            except ImportError:
                sys.exit("File .fig dùng zstd — chạy: pip3 install zstandard rồi thử lại")
            return zstandard.ZstdDecompressor().decompressobj().decompress(b)
        return zlib.decompress(b, -15)
    schema, body = inflate(chunks[0]), inflate(chunks[1])
    defs = parse_schema(schema)
    msg = decode(Reader(body), defs, next(i for i, d in enumerate(defs) if d[0] == "Message"))
    return msg


def load_fig(path, node):
    """Trả về cây node dạng gần giống REST API (đủ cho build_svg)."""
    msg = read_fig(path)
    blobs = msg.get("blobs", [])
    nodes = {}
    for c in msg["nodeChanges"]:
        g = c["guid"]; nid = f"{g['sessionID']}:{g['localID']}"
        t = c.get("transform") or {}
        n = {"id": nid, "name": c.get("name", ""), "type": c.get("type"), "children": [],
             "characters": (c.get("textData") or {}).get("characters", ""),
             "_size": c.get("size") or {"x": 0, "y": 0}, "_tx": t.get("m02", 0), "_ty": t.get("m12", 0),
             "fills": [x for x in c.get("fillPaints", []) if x.get("visible", True)],
             "strokes": [x for x in c.get("strokePaints", []) if x.get("visible", True)],
             "fillGeometry": [{"path": commands_to_path(blobs[x["commandsBlob"]]["bytes"] if isinstance(blobs[x["commandsBlob"]], dict) else blobs[x["commandsBlob"]])}
                              for x in c.get("fillGeometry", [])],
             "strokeGeometry": [{"path": commands_to_path(blobs[x["commandsBlob"]]["bytes"] if isinstance(blobs[x["commandsBlob"]], dict) else blobs[x["commandsBlob"]])}
                                for x in c.get("strokeGeometry", [])]}
        p = c.get("parentIndex", {}).get("guid")
        nodes[nid] = (n, f"{p['sessionID']}:{p['localID']}" if p else None, c.get("parentIndex", {}).get("position", ""))
    for nid, (n, pid, pos) in sorted(nodes.items(), key=lambda kv: kv[1][2]):
        if pid in nodes: nodes[pid][0]["children"].append(n)
    if node not in nodes:
        sys.exit(f"Node {node} không có trong .fig — Save local copy đúng file chứa node này")
    return nodes[node][0]


# ---------- chọn icon + dựng SVG ----------
def has_only_vectors(n):
    kids = n.get("children", [])
    return bool(kids) and all(k["type"] in VECTORS or (k["type"] in CONTAINERS and has_only_vectors(k)) for k in kids)


def find_icons(root, label=None):
    """Icon = container chỉ chứa vector; lấy node gần root nhất, đặt tên theo TEXT anh em nếu tên generic."""
    out = []

    def walk(n, siblings_text):
        if n["type"] in CONTAINERS and has_only_vectors(n):
            kids = n["children"]  # wrapper 1 con (vd Overlay+Border > SVG): lấy con, bbox wrapper to hơn icon
            while len(kids) == 1 and kids[0]["type"] in CONTAINERS:
                n, kids = kids[0], kids[0]["children"]
            name =n["name"] if not GENERIC.match(n["name"]) or not siblings_text else siblings_text
            out.append((n, name)); return
        texts = [k.get("characters", k["name"]) for k in n.get("children", []) if k["type"] == "TEXT"]
        for k in n.get("children", []):
            walk(k, texts[0] if texts else None)

    if root["type"] in CONTAINERS and has_only_vectors(root): return [(root, root["name"])]
    walk(root, None)
    return out


def color(paints):
    for p in paints or []:
        if p.get("visible", True) is False: continue
        c = p.get("color") or (p.get("gradientStops") or [{}])[0].get("color")
        if c:
            a = c.get("a", 1) * p.get("opacity", 1)
            rgb = "#%02X%02X%02X" % tuple(round(c[k] * 255) for k in "rgb")
            return rgb, a
    return None


def abs_pos(n, origin):
    if "absoluteBoundingBox" in n:
        b = n["absoluteBoundingBox"]; return b["x"] - origin[0], b["y"] - origin[1]
    return n.get("_tx", 0), n.get("_ty", 0)  # .fig: tx/ty tương đối cha, cộng dồn ở emit()


def build_svg(root):
    bb = root.get("absoluteBoundingBox")
    w, h = (bb["width"], bb["height"]) if bb else (root["_size"]["x"], root["_size"]["y"])
    origin = (bb["x"], bb["y"]) if bb else (0, 0)
    parts = []

    def emit(n, dx, dy):
        x, y = abs_pos(n, origin) if bb else (dx + n.get("_tx", 0), dy + n.get("_ty", 0))
        if n is root and not bb: x = y = 0
        for key, paints in (("fillGeometry", n.get("fills")), ("strokeGeometry", n.get("strokes"))):
            col = color(paints)
            for g in n.get(key, []):
                if not col or not g.get("path"): continue
                rule = ' fill-rule="evenodd" clip-rule="evenodd"' if g.get("windingRule") == "EVENODD" else ""
                op = f' fill-opacity="{col[1]:.3g}"' if col[1] < 1 else ""
                parts.append(f'<path transform="translate({x:g} {y:g})" d="{g["path"]}" fill="{col[0]}"{op}{rule}/>')
        for k in n.get("children", []): emit(k, x, y)

    emit(root, 0, 0)
    return (f'<svg width="{w:g}" height="{h:g}" viewBox="0 0 {w:g} {h:g}" fill="none" '
            f'xmlns="http://www.w3.org/2000/svg">\n' + "\n".join(parts) + "\n</svg>\n")


def slug(s):
    s = s.lower()
    s = re.sub(r"[àáạảãâầấậẩẫăằắặẳẵ]", "a", s); s = re.sub(r"[èéẹẻẽêềếệểễ]", "e", s)
    s = re.sub(r"[ìíịỉĩ]", "i", s); s = re.sub(r"[òóọỏõôồốộổỗơờớợởỡ]", "o", s)
    s = re.sub(r"[ùúụủũưừứựửữ]", "u", s); s = re.sub(r"[ỳýỵỷỹ]", "y", s); s = s.replace("đ", "d")
    return re.sub(r"_+", "_", re.sub(r"[^a-z0-9]", "_", s)).strip("_")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("url"); ap.add_argument("--dest", default="learnflutter/assets/icons")
    ap.add_argument("--fig"); ap.add_argument("--prefix", default="ic_")
    ap.add_argument("--pick", nargs="*", metavar="ID=file_name",
                    help="chỉ export node chỉ định, đặt tên tay (tên generic SVG/Frame không tự đặt được)")
    a = ap.parse_args()
    key, node = parse_url(a.url)
    out = f".figma-snapshots/export_{node.replace(':', '-')}"
    os.makedirs(out, exist_ok=True); os.makedirs(a.dest, exist_ok=True)

    root = load_fig(a.fig, node) if a.fig else fetch_node(key, node, f"{out}/nodes_raw.json")
    if root is None:
        sys.exit("RATE_LIMIT: Figma 429. Chuyển hướng 1: File > Save local copy trong Figma, "
                 "rồi chạy lại với --fig /path/file.fig")

    icons = find_icons(root)
    if a.pick:
        want = dict(p.split("=", 1) for p in a.pick)
        pool = {}

        def index(n):
            pool[n["id"]] = n
            for k in n.get("children", []): index(k)
        index(root)
        icons = [(pool[i], name) for i, name in want.items()]
        a.prefix = ""
    if not icons: sys.exit("Không có node nào chỉ chứa vector trong subtree này")
    seen, rows = set(), []
    for n, name in icons:
        fname = a.prefix + slug(name)
        while fname in seen: fname += "_2"
        seen.add(fname)
        svg = build_svg(n)
        open(f"{a.dest}/{fname}.svg", "w").write(svg); open(f"{out}/{fname}.svg", "w").write(svg)
        rows.append((n["id"], name, fname))
        print(f"{n['id']}\t{name}\t{a.dest}/{fname}.svg")


if __name__ == "__main__":
    main()
