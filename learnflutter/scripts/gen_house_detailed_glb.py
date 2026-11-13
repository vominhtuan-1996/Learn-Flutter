#!/usr/bin/env python3
"""Detailed procedural house with interior -> assets/3d/house_detailed.glb and
assets/3d/house_interior.glb (same house, roof removed so rooms are visible
from above). glTF 2.0, meters, Y-up. Front faces +Z. Not photogrammetry.

Layout (plan, X right, Z toward the viewer/front):
  back  (-Z):  kitchen (left) | bathroom (right)
  front (+Z):  living  (left) | bedroom  (right)
  Front wall has the main door; back wall has a back door; every side has windows.

Usage: .venv/bin/python scripts/gen_house_detailed_glb.py [out_dir]
"""
import sys
from pathlib import Path

import numpy as np
import trimesh
from trimesh.visual.material import PBRMaterial

FY, H = 0.45, 2.8          # floor top / wall height (m)
T, TI = 0.2, 0.12          # exterior / interior wall thickness
X0, X1, Z0, Z1 = -5.0, 5.0, -4.0, 4.0   # outer faces
IX0, IX1, IZ0, IZ1 = X0 + T, X1 - T, Z0 + T, Z1 - T   # inner faces


def mat(name, rgb, rough=0.85, alpha=1.0, emissive=None, metal=0.0):
    return PBRMaterial(
        name=name,
        baseColorFactor=[int(c * 255) for c in (*rgb, alpha)],
        metallicFactor=metal, roughnessFactor=rough,
        emissiveFactor=emissive,
        alphaMode="BLEND" if alpha < 1 else "OPAQUE")


M = dict(
    wall=mat("wall", (0.93, 0.89, 0.80)), trim=mat("trim", (0.97, 0.97, 0.95)),
    roof=mat("roof", (0.45, 0.18, 0.15)), door=mat("door", (0.15, 0.35, 0.45)),
    wood=mat("wood", (0.45, 0.30, 0.16)), found=mat("foundation", (0.50, 0.50, 0.52)),
    glass=mat("glass", (0.60, 0.82, 0.93), rough=0.1, alpha=0.45),
    brick=mat("brick", (0.50, 0.28, 0.22)), grass=mat("grass", (0.35, 0.58, 0.30)),
    stone=mat("stone", (0.62, 0.62, 0.60)), green=mat("green", (0.25, 0.55, 0.22)),
    pot=mat("pot", (0.60, 0.35, 0.22)), metal=mat("metal", (0.75, 0.77, 0.80), rough=0.4, metal=0.6),
    dark=mat("dark", (0.10, 0.10, 0.12)), white=mat("white", (0.95, 0.95, 0.95), rough=0.5),
    fl_wood=mat("floor_wood", (0.66, 0.50, 0.32)), fl_tile=mat("floor_tile", (0.80, 0.80, 0.78), rough=0.4),
    fl_bed=mat("floor_carpet", (0.72, 0.68, 0.62)), fl_bath=mat("floor_bath", (0.62, 0.78, 0.85), rough=0.4),
    sofa=mat("sofa", (0.35, 0.42, 0.55)), rug=mat("rug", (0.70, 0.30, 0.28)),
    blanket=mat("blanket", (0.55, 0.30, 0.32)), counter=mat("countertop", (0.25, 0.25, 0.28), rough=0.4),
    cabinet=mat("cabinet", (0.88, 0.85, 0.78)), mirror=mat("mirror", (0.80, 0.90, 1.0), rough=0.05, metal=0.5),
    lamp=mat("lamp", (1, 0.9, 0.6), emissive=[1.0, 0.85, 0.5]),
)

parts = []


def add(name, mesh, material):
    mesh.visual = trimesh.visual.TextureVisuals(material=M[material])
    parts.append((name, mesh))


def box(name, size, center, material):
    m = trimesh.creation.box(extents=size)
    m.apply_translation(center)
    add(name, m, material)


def cyl(name, r, h, base, material, sections=12):
    m = trimesh.creation.cylinder(radius=r, height=h, sections=sections)
    m.apply_transform(trimesh.transformations.rotation_matrix(np.pi / 2, [1, 0, 0]))
    m.apply_translation([base[0], base[1] + h / 2, base[2]])
    add(name, m, material)


def ball(name, r, center, material, scale=(1, 1, 1)):
    m = trimesh.creation.icosphere(subdivisions=1, radius=r)
    m.apply_scale(scale)
    m.apply_translation(center)
    add(name, m, material)


def piece(name, axis, fixed, u0, u1, ya, yb, t, material):
    """Slab along `axis` ('x': runs along X at z=fixed, 'z': along Z at x=fixed)."""
    uc, yc = (u0 + u1) / 2, (ya + yb) / 2
    if axis == "x":
        box(name, [u1 - u0, yb - ya, t], [uc, yc, fixed], material)
    else:
        box(name, [t, yb - ya, u1 - u0], [fixed, yc, uc], material)


def wall(name, axis, fixed, a0, a1, t, openings, material="wall"):
    """Wall with rectangular openings: (center, width, sill, height) above FY."""
    cur, i = a0, 0
    for c, w, sill, oh in sorted(openings):
        l, r = c - w / 2, c + w / 2
        if l > cur:
            piece(f"{name}_{i}", axis, fixed, cur, l, FY, FY + H, t, material); i += 1
        if sill > 0:
            piece(f"{name}_sill_{i}", axis, fixed, l, r, FY, FY + sill, t, material); i += 1
        if sill + oh < H:
            piece(f"{name}_head_{i}", axis, fixed, l, r, FY + sill + oh, FY + H, t, material); i += 1
        cur = r
    if a1 > cur:
        piece(f"{name}_{i}", axis, fixed, cur, a1, FY, FY + H, t, material)


def window(name, axis, fixed, c, w, sill, oh, t, side, shutters=False):
    """Frame + glass + muntins (+ sill ledge and shutters on the exterior `side`=+1/-1)."""
    ft, y0, y1 = 0.06, FY + sill, FY + sill + oh
    d = t + 0.04
    l, r = c - w / 2, c + w / 2
    piece(f"{name}_fb", axis, fixed, l, r, y0, y0 + ft, d, "trim")
    piece(f"{name}_ft", axis, fixed, l, r, y1 - ft, y1, d, "trim")
    piece(f"{name}_fl", axis, fixed, l, l + ft, y0, y1, d, "trim")
    piece(f"{name}_fr", axis, fixed, r - ft, r, y0, y1, d, "trim")
    piece(f"{name}_mv", axis, fixed, c - 0.02, c + 0.02, y0, y1, d * 0.8, "trim")
    piece(f"{name}_mh", axis, fixed, l, r, (y0 + y1) / 2 - 0.02, (y0 + y1) / 2 + 0.02, d * 0.8, "trim")
    piece(f"{name}_glass", axis, fixed, l, r, y0, y1, 0.02, "glass")
    if side:
        piece(f"{name}_ledge", axis, fixed + side * 0.08, l - 0.1, r + 0.1, y0 - 0.05, y0, t + 0.04, "stone")
        if shutters:
            for k, (a, b) in enumerate([(l - 0.5, l - 0.05), (r + 0.05, r + 0.5)]):
                piece(f"{name}_shutter{k}", axis, fixed + side * (t / 2 + 0.03), a, b, y0, y1, 0.05, "door")


def door(name, axis, fixed, c, w, oh, t, side, color="door", knob=True):
    y0, y1, ft = FY, FY + oh, 0.07
    l, r = c - w / 2, c + w / 2
    off = fixed + side * 0.05
    piece(f"{name}_leaf", axis, off, l + ft, r - ft, y0, y1 - ft, 0.06, color)
    piece(f"{name}_fl", axis, fixed, l, l + ft, y0, y1, t + 0.04, "trim")
    piece(f"{name}_fr", axis, fixed, r - ft, r, y0, y1, t + 0.04, "trim")
    piece(f"{name}_ft", axis, fixed, l, r, y1 - ft, y1, t + 0.04, "trim")
    for k, (pa, pb) in enumerate([(y0 + 0.2, y0 + 0.95), (y0 + 1.05, y1 - 0.25)]):  # raised panels
        piece(f"{name}_panel{k}", axis, off + side * 0.035, l + 0.18, r - 0.18, pa, pb, 0.02, "trim")
    kx = r - 0.15
    if axis == "x":
        ball(f"{name}_knob", 0.035, [kx, y0 + 1.0, off + side * 0.06], "metal")
    else:
        ball(f"{name}_knob", 0.035, [off + side * 0.06, y0 + 1.0, kx], "metal")


def build(with_roof):
    parts.clear()
    # ---- site -----------------------------------------------------------
    box("ground", [16, 0.2, 14], [0, 0.1, 0], "grass")
    box("foundation", [10.4, 0.25, 8.4], [0, 0.325, 0], "found")
    for i, z in enumerate([5.9, 6.6]):
        box(f"paver_{i}", [1.4, 0.03, 0.55], [-1.5, 0.215, z], "stone")
    for sx in (-1, 1):
        ball(f"bush_{sx}", 0.55, [sx * 4.2 + (-0.0), 0.65, 4.55], "green", scale=(1.2, 0.9, 1))

    # ---- floors (one per room) -------------------------------------------
    def floor(n, x0, x1, z0, z1, m):
        box(f"floor_{n}", [x1 - x0, 0.02, z1 - z0], [(x0 + x1) / 2, FY + 0.01, (z0 + z1) / 2], m)
    floor("living", IX0, 1.5, 0, IZ1, "fl_wood")
    floor("kitchen", IX0, 1.5, IZ0, 0, "fl_tile")
    floor("bedroom", 1.5, IX1, 0, IZ1, "fl_bed")
    floor("bath", 1.5, IX1, IZ0, 0, "fl_bath")

    # ---- exterior walls (openings: center, width, sill, height) ----------
    front = [(-1.5, 1.0, 0, 2.1), (-3.8, 1.4, 0.9, 1.2), (3.2, 1.4, 0.9, 1.2)]
    back = [(-3.1, 1.2, 1.1, 0.9), (0.5, 1.0, 0, 2.1), (3.2, 0.7, 1.5, 0.6)]
    left = [(2.6, 1.2, 0.9, 1.2), (-2.0, 1.4, 1.1, 0.9)]
    right = [(1.8, 1.2, 0.9, 1.2), (-2.6, 0.7, 1.5, 0.6)]
    wall("wall_front", "x", Z1 - T / 2, X0, X1, T, front)
    wall("wall_back", "x", Z0 + T / 2, X0, X1, T, back)
    wall("wall_left", "z", X0 + T / 2, IZ0, IZ1, T, left)
    wall("wall_right", "z", X1 - T / 2, IZ0, IZ1, T, right)
    for sx in (-1, 1):
        for sz in (-1, 1):
            box(f"corner_{sx}_{sz}", [0.22, H, 0.22], [sx * (X1 - 0.09), FY + H / 2, sz * (Z1 - 0.09)], "trim")
    # interior partitions
    wall("part_x", "z", 1.5, IZ0, IZ1, TI, [(2.0, 0.9, 0, 2.1), (-2.0, 0.9, 0, 2.1)])
    wall("part_z", "x", 0.0, 1.5 + TI / 2, IX1, TI, [])

    cf, cb = Z1 - T / 2, Z0 + T / 2   # wall centre lines
    # ---- FRONT (+Z): door, steps, canopy, windows with shutters ----------
    door("door_front", "x", cf, -1.5, 1.0, 2.1, T, +1)
    window("win_front_living", "x", cf, -3.8, 1.4, 0.9, 1.2, T, +1, shutters=True)
    window("win_front_bed", "x", cf, 3.2, 1.4, 0.9, 1.2, T, +1, shutters=True)
    box("step_upper", [1.8, 0.25, 0.5], [-1.5, 0.325, 4.45], "stone")
    box("step_lower", [1.8, 0.125, 0.5], [-1.5, 0.2625, 4.95], "stone")
    box("canopy", [2.4, 0.1, 1.5], [-1.5, FY + 2.55, 4.65], "roof")
    for sx in (-2.6, -0.4):
        cyl(f"canopy_post_{sx}", 0.06, 2.55 - 0.1, [sx, 0.325, 5.3], "trim")
    box("house_number", [0.18, 0.12, 0.02], [-0.5, FY + 1.6, Z1 + 0.025], "metal")
    # ---- BACK (-Z): back door + stoop, windows, AC unit -------------------
    door("door_back", "x", cb, 0.5, 1.0, 2.1, T, -1, color="wood")
    window("win_back_kitchen", "x", cb, -3.1, 1.2, 1.1, 0.9, T, -1)
    window("win_back_bath", "x", cb, 3.2, 0.7, 1.5, 0.6, T, -1)
    box("stoop", [1.6, 0.25, 0.8], [0.5, 0.325, -4.6], "stone")
    box("ac_unit", [0.9, 0.55, 0.35], [-1.3, FY + 2.0, Z0 - 0.2], "white")
    box("ac_fan", [0.55, 0.55, 0.02], [-1.3, FY + 2.0, Z0 - 0.385], "dark")
    # ---- LEFT (-X) / RIGHT (+X) windows ------------------------------------
    window("win_left_living", "z", X0 + T / 2, 2.6, 1.2, 0.9, 1.2, T, -1, shutters=True)
    window("win_left_kitchen", "z", X0 + T / 2, -2.0, 1.4, 1.1, 0.9, T, -1)
    window("win_right_bed", "z", X1 - T / 2, 1.8, 1.2, 0.9, 1.2, T, +1, shutters=True)
    window("win_right_bath", "z", X1 - T / 2, -2.6, 0.7, 1.5, 0.6, T, +1)
    # downspouts
    for i, (x, z) in enumerate([(X0 - 0.03, Z1 + 0.03), (X1 + 0.03, Z0 - 0.03)]):
        cyl(f"downspout_{i}", 0.04, H + 0.1, [x, FY, z], "metal", 8)

    # ---- roof ----------------------------------------------------------------
    y0, rise, ov = FY + H, 2.2, 0.5
    if with_roof:
        hl, hw = X1 + ov, Z1 + ov
        v = np.array([[-hl, y0, -hw], [-hl, y0, hw], [-hl, y0 + rise, 0],
                      [hl, y0, -hw], [hl, y0, hw], [hl, y0 + rise, 0]])
        f = [[0, 2, 1], [3, 4, 5], [0, 1, 4], [0, 4, 3], [1, 2, 5], [1, 5, 4], [0, 3, 5], [0, 5, 2]]
        roof = trimesh.Trimesh(v, f, process=False)
        trimesh.repair.fix_normals(roof)
        add("roof", roof, "roof")
        box("ridge_cap", [2 * hl + 0.1, 0.1, 0.3], [0, y0 + rise + 0.02, 0], "brick")
        for sz in (-1, 1):
            box(f"gutter_{sz}", [2 * hl, 0.1, 0.12], [0, y0 - 0.02, sz * (hw + 0.04)], "metal")
        # gable-end vents
        for sx in (-1, 1):
            ball(f"gable_vent_{sx}", 0.28, [sx * (hl - 0.01), y0 + 0.75, 0], "trim", scale=(0.05, 1, 1))
    # chimney (kept in both variants)
    box("chimney", [0.7, 3.0, 0.7], [3.5, y0 + 1.5 - 0.4, -1.6], "brick")
    box("chimney_cap", [0.9, 0.12, 0.9], [3.5, y0 + 2.66, -1.6], "stone")

    # ---- INTERIOR ------------------------------------------------------------
    # living room
    box("rug", [2.4, 0.02, 3.0], [-3.4, FY + 0.03, 1.6], "rug")
    box("sofa_base", [0.9, 0.45, 2.2], [-2.2, FY + 0.225, 1.4], "sofa")
    box("sofa_back", [0.2, 0.55, 2.2], [-1.65, FY + 0.55, 1.4], "sofa")
    for sz in (0.3, 2.5):
        box(f"sofa_arm_{sz}", [0.9, 0.3, 0.15], [-2.2, FY + 0.6, sz], "sofa")
    box("coffee_table_top", [0.7, 0.05, 1.1], [-3.4, FY + 0.4, 1.4], "wood")
    for i, (dx, dz) in enumerate([(-.3, -.5), (.3, -.5), (-.3, .5), (.3, .5)]):
        cyl(f"coffee_leg_{i}", 0.03, 0.4, [-3.4 + dx, FY, 1.4 + dz], "wood", 8)
    box("tv_stand", [0.4, 0.5, 1.4], [-4.6, FY + 0.25, 0.9], "wood")
    box("tv", [0.06, 0.65, 1.15], [-4.7, FY + 0.5 + 0.38, 0.9], "dark")
    cyl("plant_pot", 0.22, 0.4, [0.8, FY, 3.4], "pot")
    ball("plant", 0.4, [0.8, FY + 0.85, 3.4], "green", scale=(1, 1.2, 1))
    cyl("lamp_pole", 0.02, 1.4, [-1.1, FY, 3.3], "metal", 8)
    ball("lamp_shade", 0.16, [-1.1, FY + 1.5, 3.3], "lamp")
    # kitchen
    box("counter_base", [3.2, 0.85, 0.6], [-3.1, FY + 0.425, -3.5], "cabinet")
    box("counter_top", [3.2, 0.05, 0.65], [-3.1, FY + 0.875, -3.475], "counter")
    box("sink", [0.6, 0.03, 0.4], [-3.1, FY + 0.905, -3.45], "metal")
    cyl("faucet", 0.02, 0.28, [-3.1, FY + 0.9, -3.72], "metal", 8)
    for i, x in enumerate((-4.25, -1.95)):
        box(f"wall_cab_{i}", [0.9, 0.7, 0.35], [x, FY + 1.85, -3.625], "cabinet")
    box("stove_top", [0.6, 0.02, 0.5], [-4.3, FY + 0.91, -3.45], "dark")
    box("fridge", [0.7, 1.8, 0.7], [-0.9, FY + 0.9, -3.4], "metal")
    box("fridge_split", [0.68, 0.02, 0.02], [-0.9, FY + 1.25, -3.04], "dark")
    box("dining_top", [1.4, 0.05, 0.9], [-3.2, FY + 0.75, -1.2], "wood")
    for i, (dx, dz) in enumerate([(-.6, -.35), (.6, -.35), (-.6, .35), (.6, .35)]):
        cyl(f"dining_leg_{i}", 0.04, 0.75, [-3.2 + dx, FY, -1.2 + dz], "wood", 8)
    for i, (x, z, s) in enumerate([(-3.7, -0.45, -1), (-2.7, -0.45, -1), (-3.7, -1.95, 1), (-2.7, -1.95, 1)]):
        box(f"chair_seat_{i}", [0.4, 0.05, 0.4], [x, FY + 0.45, z], "wood")
        box(f"chair_back_{i}", [0.4, 0.45, 0.05], [x, FY + 0.7, z - s * 0.2 + (0.0)], "wood")
        for dx, dz in [(-.17, -.17), (.17, -.17), (-.17, .17), (.17, .17)]:
            cyl(f"chair_leg_{i}_{dx}_{dz}", 0.025, 0.45, [x + dx, FY, z + dz], "wood", 6)
    # bedroom
    box("bed_frame", [1.5, 0.35, 2.0], [3.4, FY + 0.175, 1.2], "wood")
    box("bed_head", [1.5, 0.9, 0.08], [3.4, FY + 0.45, 0.16], "wood")
    box("mattress", [1.4, 0.2, 1.9], [3.4, FY + 0.45, 1.2], "white")
    box("blanket", [1.42, 0.06, 1.2], [3.4, FY + 0.58, 1.65], "blanket")
    for i, x in enumerate((3.0, 3.8)):
        box(f"pillow_{i}", [0.5, 0.12, 0.3], [x, FY + 0.6, 0.45], "white")
    for i, x in enumerate((2.3, 4.5)):
        box(f"nightstand_{i}", [0.45, 0.5, 0.4], [x, FY + 0.25, 0.4], "wood")
        ball(f"bed_lamp_{i}", 0.1, [x, FY + 0.62, 0.4], "lamp")
    box("wardrobe", [0.6, 2.0, 1.2], [4.5, FY + 1.0, 3.1], "wood")
    box("wardrobe_split", [0.02, 1.9, 0.02], [4.19, FY + 1.0, 3.1], "dark")
    # bathroom
    box("tub", [1.7, 0.55, 0.75], [3.9, FY + 0.275, -3.4], "white")
    box("tub_water", [1.5, 0.02, 0.55], [3.9, FY + 0.5, -3.4], "glass")
    box("toilet_base", [0.4, 0.4, 0.55], [2.1, FY + 0.2, -3.4], "white")
    box("toilet_tank", [0.4, 0.35, 0.2], [2.1, FY + 0.55, -3.68], "white")
    box("vanity", [0.5, 0.85, 0.8], [4.55, FY + 0.425, -1.2], "cabinet")
    box("vanity_top", [0.52, 0.04, 0.82], [4.55, FY + 0.87, -1.2], "counter")
    box("mirror", [0.03, 0.7, 0.6], [4.77, FY + 1.5, -1.2], "mirror")
    box("towel_bar", [0.03, 0.03, 0.5], [2.0, FY + 1.3, -1.0], "metal") if False else None
    return list(parts)


def export(path, with_roof):
    ps = build(with_roof)
    scene = trimesh.Scene()
    for name, m in ps:
        scene.add_geometry(m, geom_name=name, node_name=name)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(scene.export(file_type="glb"))
    tris = sum(len(m.faces) for _, m in ps)
    print(f"wrote {path} ({path.stat().st_size} bytes, {len(ps)} meshes, {tris} tris) bounds={scene.bounds.round(2).tolist()}")


if __name__ == "__main__":
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets/3d"
    export(out / "house_detailed.glb", True)
    export(out / "house_interior.glb", False)
