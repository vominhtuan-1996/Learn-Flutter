#!/usr/bin/env python3
"""Procedural house + surroundings -> assets/3d/house_scene.glb (glTF 2.0, meters, Y-up).

Reuses the house from gen_house_glb.py and adds ground, river + bridge, path,
mountains, trees, rocks, sun and clouds. Not photogrammetry. Front of the
house faces +Z, mountains are behind (-Z), river is in front (+Z).
Layout is deterministic (fixed seed).

Usage: .venv/bin/python scripts/gen_house_scene_glb.py [out.glb]
"""
import sys
from pathlib import Path

import numpy as np
import trimesh
from trimesh.transformations import rotation_matrix
from trimesh.visual.material import PBRMaterial

sys.path.insert(0, str(Path(__file__).resolve().parent))
from gen_house_glb import box, build as build_house, mat  # noqa: E402

TOP = 0.2  # top of the ground slab (house base sits here too)


def paint(m, material):
    m.visual = trimesh.visual.TextureVisuals(material=material)
    return m


def cone_up(radius, height, base, material, sections=8):
    m = trimesh.creation.cone(radius=radius, height=height, sections=sections)
    m.apply_transform(rotation_matrix(-np.pi / 2, [1, 0, 0]))  # +Z axis -> +Y
    m.apply_translation([0, 0, 0])
    m.apply_translation(base)
    return paint(m, material)


def cylinder_up(radius, height, base, material, sections=8):
    m = trimesh.creation.cylinder(radius=radius, height=height, sections=sections)
    m.apply_transform(rotation_matrix(np.pi / 2, [1, 0, 0]))
    m.apply_translation([base[0], base[1] + height / 2, base[2]])
    return paint(m, material)


def ball(radius, center, material, scale=(1, 1, 1)):
    m = trimesh.creation.icosphere(subdivisions=1, radius=radius)
    m.apply_scale(scale)
    m.apply_translation(center)
    return paint(m, material)


def river_z(x):
    return 16 + 2.5 * np.sin(x / 7.0)


def main():
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets/3d/house_scene.glb"
    rng = np.random.default_rng(7)

    grass = mat("grass", (0.35, 0.58, 0.30, 1))
    water = mat("water", (0.18, 0.45, 0.78, 0.8), rough=0.1, blend=True)
    dirt = mat("path", (0.62, 0.50, 0.34, 1))
    wood = mat("wood", (0.45, 0.30, 0.16, 1))
    rock_m = mat("mountain", (0.46, 0.48, 0.52, 1))
    rock_d = mat("mountain_dark", (0.36, 0.38, 0.43, 1))
    snow = mat("snow", (0.96, 0.97, 1.0, 1))
    trunk = mat("trunk", (0.40, 0.26, 0.14, 1))
    pine = mat("pine", (0.12, 0.38, 0.20, 1))
    leaf = mat("leaf", (0.28, 0.58, 0.22, 1))
    stone = mat("stone", (0.55, 0.55, 0.55, 1))
    cloud_m = mat("cloud", (1, 1, 1, 1))
    sun_m = PBRMaterial(name="sun", baseColorFactor=[255, 214, 64, 255],
                        emissiveFactor=[1.0, 0.82, 0.25], metallicFactor=0.0,
                        roughnessFactor=1.0)

    parts = []  # (name, mesh)
    parts.append(("ground", box([60, TOP, 60], [0, TOP / 2, 0], grass, "ground")))

    # house without its small ground slab
    _, house_parts = build_house()
    for p in house_parts:
        n = p.metadata.get("name", "part")
        if n != "ground":
            parts.append((f"house_{n}", p))

    # river (in front, +Z) as short segments following a sine curve, with a bridge
    seg_w, width = 5.0, 4.5
    for i, x in enumerate(np.arange(-30 + seg_w / 2, 30, seg_w)):
        parts.append((f"river_{i}", box([seg_w + 0.3, 0.06, width], [x, TOP + 0.03, river_z(x)], water, "river")))
    parts.append(("path", box([1.6, 0.04, river_z(0) - 3.2 - width / 2 + 0.2], [0, TOP + 0.02, (3.2 + river_z(0) - width / 2) / 2], dirt, "path")))
    parts.append(("bridge_deck", box([2.4, 0.2, width + 2.0], [0, TOP + 0.35, river_z(0)], wood, "bridge")))
    for sx in (-1.1, 1.1):
        parts.append((f"bridge_rail_{sx}", box([0.12, 0.7, width + 2.0], [sx, TOP + 0.8, river_z(0)], wood, "bridge")))

    # mountains behind the house (-Z): body + snow cap
    for i, (x, z, r, h, m) in enumerate([
        (-18, -24, 11, 15, rock_m), (-4, -28, 14, 20, rock_d), (14, -25, 12, 16, rock_m),
        (27, -20, 8, 10, rock_d), (-28, -14, 7, 9, rock_d),
    ]):
        parts.append((f"mountain_{i}", cone_up(r, h, [x, TOP, z], m, sections=7)))
        if h >= 14:
            parts.append((f"snow_{i}", cone_up(r * 0.3, h * 0.3, [x, TOP + h * 0.7, z], snow, sections=7)))

    # trees: keep out of house footprint, path and river
    def free(x, z):
        if abs(x) < 9 and abs(z) < 8:
            return False
        if abs(x) < 2.2 and 0 < z < 20:
            return False
        if abs(z - river_z(x)) < 4.2:
            return False
        if z < -16:
            return False
        return True

    placed = []
    while len(placed) < 14:
        x, z = rng.uniform(-27, 27), rng.uniform(-15, 27)
        if free(x, z) and all((x - a) ** 2 + (z - b) ** 2 > 9 for a, b, _ in placed):
            placed.append((x, z, rng.random() < 0.55))
    for i, (x, z, is_pine) in enumerate(placed):
        s = rng.uniform(0.8, 1.3)
        parts.append((f"trunk_{i}", cylinder_up(0.25 * s, 1.6 * s, [x, TOP, z], trunk)))
        if is_pine:
            for k in range(3):
                parts.append((f"pine_{i}_{k}", cone_up((1.7 - 0.45 * k) * s, 2.0 * s, [x, TOP + (1.2 + 1.2 * k) * s, z], pine)))
        else:
            parts.append((f"crown_{i}", ball(1.7 * s, [x, TOP + 3.0 * s, z], leaf, scale=(1, 0.9, 1))))

    # rocks
    for i in range(6):
        x, z = rng.uniform(-25, 25), rng.uniform(-13, 25)
        if free(x, z):
            parts.append((f"rock_{i}", ball(rng.uniform(0.4, 0.9), [x, TOP + 0.2, z], stone, scale=(1.2, 0.6, 1))))

    # sun + clouds
    parts.append(("sun", ball(3.0, [-20, 22, -30], sun_m)))
    for i, (x, y, z) in enumerate([(8, 24, -12), (22, 20, 4), (-12, 26, 6)]):
        for k, (dx, r) in enumerate([(-1.6, 1.6), (0, 2.2), (1.8, 1.5)]):
            parts.append((f"cloud_{i}_{k}", ball(r, [x + dx, y, z], cloud_m, scale=(1.3, 0.7, 1))))

    scene = trimesh.Scene()
    for name, m in parts:
        scene.add_geometry(m, geom_name=name, node_name=name)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(scene.export(file_type="glb"))
    tris = sum(len(m.faces) for _, m in parts)
    print(f"wrote {out} ({out.stat().st_size} bytes, {len(parts)} meshes, {tris} tris)")
    print("bounds:", scene.bounds.round(1).tolist())


if __name__ == "__main__":
    main()
