#!/usr/bin/env python3
"""Procedural house -> assets/3d/house.glb (glTF 2.0, meters, Y-up).

Not photogrammetry: no drone imagery involved. Origin = center of the bottom
face of the ground slab. Front of the house faces +Z.

Usage (venv recommended):
  python3 -m venv .venv && .venv/bin/pip install trimesh numpy
  .venv/bin/python scripts/gen_house_glb.py [out.glb]
"""
import sys
from pathlib import Path

import numpy as np
import trimesh
from trimesh.visual.material import PBRMaterial


def mat(name, rgba, rough=0.9, blend=False):
    return PBRMaterial(
        name=name,
        baseColorFactor=[int(c * 255) for c in rgba],
        metallicFactor=0.0,
        roughnessFactor=rough,
        alphaMode="BLEND" if blend else "OPAQUE",
    )


def box(size, center, material, name):
    m = trimesh.creation.box(extents=size)
    m.apply_translation(center)
    m.visual = trimesh.visual.TextureVisuals(material=material)
    m.metadata["name"] = name
    return m


def gable_roof(length, width, rise, overhang, y0, material):
    """Triangular prism, ridge along X. Eaves at y0, ridge at y0+rise."""
    hl, hw = length / 2 + overhang, width / 2 + overhang
    v = np.array([
        [-hl, y0, -hw], [-hl, y0, hw], [-hl, y0 + rise, 0],  # left gable
        [hl, y0, -hw], [hl, y0, hw], [hl, y0 + rise, 0],     # right gable
    ])
    f = [
        [0, 2, 1], [3, 4, 5],            # end caps
        [0, 1, 4], [0, 4, 3],            # underside
        [1, 2, 5], [1, 5, 4],            # front slope (+Z)
        [0, 3, 5], [0, 5, 2],            # back slope (-Z)
    ]
    m = trimesh.Trimesh(v, f, process=False)
    trimesh.repair.fix_normals(m)
    m.visual = trimesh.visual.TextureVisuals(material=material)
    return m


def build():
    wall = mat("wall", (0.93, 0.89, 0.80, 1))
    roof = mat("roof", (0.62, 0.20, 0.15, 1))
    door = mat("door", (0.36, 0.22, 0.12, 1))
    glass = mat("glass", (0.55, 0.78, 0.92, 0.55), rough=0.1, blend=True)
    brick = mat("chimney", (0.45, 0.25, 0.20, 1))
    ground = mat("ground", (0.35, 0.58, 0.30, 1))

    L, W, H = 8.0, 6.0, 3.0  # X, Z, Y (meters)
    slab_t = 0.2
    y0 = slab_t
    parts = [
        box([14, slab_t, 12], [0, slab_t / 2, 0], ground, "ground"),
        box([L, H, W], [0, y0 + H / 2, 0], wall, "walls"),
        gable_roof(L, W, 2.2, 0.4, y0 + H, roof),
        # door and windows sit proud of the +Z wall by 0.1 m
        box([1.1, 2.1, 0.12], [0, y0 + 1.05, W / 2 + 0.04], door, "door"),
        box([1.2, 1.0, 0.1], [-2.5, y0 + 1.7, W / 2 + 0.04], glass, "window_l"),
        box([1.2, 1.0, 0.1], [2.5, y0 + 1.7, W / 2 + 0.04], glass, "window_r"),
        # chimney through the back roof slope
        box([0.7, 3.0, 0.7], [2.6, y0 + H + 1.4, -1.0], brick, "chimney"),
    ]
    parts[2].metadata["name"] = "roof"
    scene = trimesh.Scene()
    for p in parts:
        scene.add_geometry(p, geom_name=p.metadata["name"], node_name=p.metadata["name"])
    return scene, parts


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets/3d/house.glb"
    out.parent.mkdir(parents=True, exist_ok=True)
    scene, parts = build()
    out.write_bytes(scene.export(file_type="glb"))
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
