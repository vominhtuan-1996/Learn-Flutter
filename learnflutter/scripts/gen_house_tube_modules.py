#!/usr/bin/env python3
"""Split the tube house into small per-module glb files (assets/3d/modules/tube_<id>.glb).
Each module = the house clipped to a region (meshes crossing the region are cut with caps),
so one room / the yard / the roof garden can be inspected on its own.
Usage: python scripts/gen_house_tube_modules.py [out_dir]
"""
import sys
from pathlib import Path

import numpy as np
import trimesh

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_house_tube_glb as T  # noqa: E402

INF = 99.0
# id: (with_roof, (x0, x1), (y0, y1), (z0, z1))
MODULES = {
    "living": (False, (-2.6, 2.6), (0, 3.3), (5.4, 12.6)),
    "kitchen": (False, (-2.6, 2.6), (0, 3.3), (1.9, 5.5)),
    "bed1": (False, (-2.6, 1.0), (0, 3.3), (-1.6, 2.1)),
    "bed2": (False, (-2.6, 1.0), (0, 3.3), (-5.1, -1.4)),
    "wc": (False, (-2.6, 1.0), (0, 3.3), (-7.6, -4.9)),
    "corridor": (False, (0.8, 2.6), (0, 3.3), (-7.6, 2.1)),
    "yard_stair": (False, (-2.6, 2.6), (0, 4.6), (-11.6, -7.4)),
    "pergola": (True, (-2.6, 2.6), (3.2, 7.0), (5.1, 12.6)),
    "roof_garden": (True, (-2.6, 2.6), (3.2, 7.0), (-7.7, 5.1)),
}


def clip(mesh, lo, hi):
    b = mesh.bounds
    if (b[1] <= lo).any() or (b[0] >= hi).any():
        return None
    if (b[0] >= lo).all() and (b[1] <= hi).all():
        return mesh
    if not mesh.is_watertight:
        c = mesh.bounds.mean(axis=0)
        return mesh if ((c >= lo) & (c <= hi)).all() else None
    mat = mesh.visual.material
    m = mesh
    for a in range(3):
        for sgn, lim in ((1, lo[a]), (-1, hi[a])):
            if abs(lim) >= INF:
                continue
            bb = m.bounds
            if (sgn == 1 and bb[0][a] >= lim) or (sgn == -1 and bb[1][a] <= lim):
                continue
            o = np.zeros(3)
            o[a] = lim
            n = np.zeros(3)
            n[a] = sgn
            m = m.slice_plane(o, n, cap=True)
            if m is None or len(m.faces) == 0:
                return None
    m.visual = trimesh.visual.TextureVisuals(material=mat)
    return m


def main(out: Path):
    out.mkdir(parents=True, exist_ok=True)
    cache = {}
    for mid, (roof, xr, yr, zr) in MODULES.items():
        if roof not in cache:
            cache[roof] = T.build(roof)
        lo = np.array([xr[0], yr[0], zr[0]])
        hi = np.array([xr[1], yr[1], zr[1]])
        kept = []
        for name, m in cache[roof]:
            c = clip(m.copy(), lo, hi)
            if c is not None and len(c.faces):
                kept.append((name, c))
        merged = T.merge_by_material(kept)
        scene = trimesh.Scene()
        for n, m in merged:
            scene.add_geometry(m, geom_name=n, node_name=n)
        path = out / f"tube_{mid}.glb"
        path.write_bytes(scene.export(file_type="glb"))
        tris = sum(len(m.faces) for _, m in merged)
        print(f"{path.name}: {path.stat().st_size // 1024} KB, {len(kept)} parts, {tris} tris, bounds={scene.bounds.round(1).tolist()}")


if __name__ == "__main__":
    main(Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets/3d/modules")
