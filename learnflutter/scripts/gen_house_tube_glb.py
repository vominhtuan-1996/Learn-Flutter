#!/usr/bin/env python3
"""Tube house 4 m x 22 m (nha ong), one storey -> assets/3d/house_tube.glb and
assets/3d/house_tube_interior.glb (no roof/ceiling, to see the rooms).
glTF 2.0, meters, Y-up. Front faces +Z. Procedural, not photogrammetry.

Plan (outer 4.0 x 22.0 m, X = width, Z = length, front at +Z):
  z +11 .. +2   open living room + kitchen/dining (one space)
  z  +2 .. -7.5 left: bedroom 1, bedroom 2, toilet   |  right: 0.9 m corridor
  z -7.5 .. -11 open-air drying yard (san phoi), no roof

Reuses the helpers of gen_house_detailed_glb.py.
Usage: .venv/bin/python scripts/gen_house_tube_glb.py [out_dir]
"""
import sys
from pathlib import Path

import numpy as np
import trimesh

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_house_detailed_glb as G  # noqa: E402
from gen_house_detailed_glb import FY, H, T, TI, ball, box, cyl, door, wall, window  # noqa: E402

G.M.update(
    cloth1=G.mat("cloth1", (0.85, 0.30, 0.30)), cloth2=G.mat("cloth2", (0.30, 0.50, 0.85)),
    cloth3=G.mat("cloth3", (0.95, 0.85, 0.35)), cloth4=G.mat("cloth4", (0.95, 0.95, 0.95)),
    yard=G.mat("yard_floor", (0.58, 0.60, 0.58), rough=0.8),
    fl_corr=G.mat("floor_corridor", (0.82, 0.80, 0.76), rough=0.5),
    washer=G.mat("washer", (0.90, 0.92, 0.95), rough=0.4),
    curtain1=G.mat("curtain_warm", (0.88, 0.82, 0.70)), curtain2=G.mat("curtain_cool", (0.58, 0.68, 0.78)),
    tile=G.mat("wall_tile", (0.90, 0.93, 0.95), rough=0.35), wooddk=G.mat("wood_dark", (0.30, 0.20, 0.12)),
    book1=G.mat("book1", (0.70, 0.25, 0.25)), book2=G.mat("book2", (0.25, 0.40, 0.65)),
    book3=G.mat("book3", (0.30, 0.55, 0.35)), fruit_r=G.mat("fruit_red", (0.80, 0.15, 0.12)),
    fruit_o=G.mat("fruit_orange", (0.95, 0.55, 0.10)), steelk=G.mat("steel_dark", (0.25, 0.26, 0.28), rough=0.4, metal=0.6),
    soil=G.mat("soil", (0.28, 0.20, 0.14)), toy=G.mat("toy", (0.95, 0.65, 0.20)),
    rubber=G.mat("rubber", (0.14, 0.14, 0.15), rough=1.0), hose=G.mat("hose", (0.20, 0.55, 0.30), rough=0.6),
    concrete=G.mat("concrete", (0.60, 0.60, 0.58), rough=0.95), concrete_dk=G.mat("concrete_dark", (0.45, 0.45, 0.44), rough=0.95),
    flower_p=G.mat("flower_pink", (0.92, 0.45, 0.65)), flower_y=G.mat("flower_yellow", (0.98, 0.85, 0.20)),
    leaf_dk=G.mat("leaf_dark", (0.16, 0.42, 0.18)), tank=G.mat("water_tank", (0.80, 0.82, 0.84), rough=0.3, metal=0.7),
    panel=G.mat("pergola_panel", (0.55, 0.78, 0.85), rough=0.2, alpha=0.55), bark=G.mat("bark", (0.38, 0.27, 0.18)),
    sconce=G.mat("sconce", (1, 0.92, 0.7), emissive=[1.0, 0.88, 0.55]),
)

XW, ZF, ZB = 2.0, 11.0, -11.0      # half width, front / back outer faces
IX, IZF, IZB = XW - T, ZF - T, ZB + T
ZY = -7.5                          # wall between toilet/corridor and drying yard


def build(with_roof):
    G.parts.clear()
    # ---- site ----------------------------------------------------------------
    box("ground", [10, 0.2, 30], [0, 0.1, 0], "grass")
    box("foundation", [4.4, 0.25, 22.4], [0, 0.325, 0], "found")
    for i, z in enumerate([12.9, 13.6, 14.3]):
        box(f"paver_{i}", [1.2, 0.03, 0.5], [0.8, 0.215, z], "stone")
    # front fence with gate gap at x in [0.2, 1.4]
    for name, x0, x1 in [("fence_l", -3.6, 0.2), ("fence_r", 1.4, 3.6)]:
        box(name, [x1 - x0, 0.9, 0.1], [(x0 + x1) / 2, 0.65, 15.0], "trim")
    for i, x in enumerate((-3.6, 0.2, 1.4, 3.6)):
        box(f"fence_post_{i}", [0.18, 1.1, 0.18], [x, 0.75, 15.0], "stone")
    for sx in (-1, 1):
        ball(f"bush_{sx}", 0.5, [sx * 1.4, 0.65, 11.9], "green", scale=(1.2, 0.9, 1))

    # ---- floors -----------------------------------------------------------------
    def floor(n, x0, x1, z0, z1, m):
        box(f"floor_{n}", [x1 - x0, 0.02, z1 - z0], [(x0 + x1) / 2, FY + 0.01, (z0 + z1) / 2], m)
    floor("living", -IX, IX, 5.5, IZF, "fl_wood")
    floor("kitchen", -IX, IX, 2.0, 5.5, "fl_tile")
    floor("bed1", -IX, 0.9, -1.5, 2.0, "fl_bed")
    floor("bed2", -IX, 0.9, -5.0, -1.5, "fl_bed")
    floor("wc", -IX, 0.9, ZY, -5.0, "fl_bath")
    floor("corridor", 0.9, IX, ZY, 2.0, "fl_corr")
    floor("yard", -IX, IX, IZB, ZY, "yard")

    # ---- exterior walls (center, width, sill, height) ---------------------------
    cf, cb, cl, cr = ZF - T / 2, ZB + T / 2, -XW + T / 2, XW - T / 2
    front = [(0.8, 1.0, 0, 2.1), (-0.8, 1.0, 0.9, 1.2)]
    back = [(0.0, 1.2, 1.2, 0.8)]
    left = [(10.0, 1.0, 0.9, 1.2), (3.8, 0.9, 1.1, 0.9), (0.5, 1.0, 0.9, 1.2),
            (-3.0, 1.0, 0.9, 1.2), (-6.2, 0.5, 1.5, 0.5)]
    right = [(9.5, 1.2, 0.9, 1.2), (3.5, 0.9, 1.1, 0.9), (-1.2, 0.6, 1.3, 0.6), (-4.5, 0.6, 1.3, 0.6)]
    wall("wall_front", "x", cf, -XW, XW, T, front)
    wall("wall_back", "x", cb, -XW, XW, T, back)
    wall("wall_left", "z", cl, IZB, IZF, T, left)
    wall("wall_right", "z", cr, IZB, IZF, T, right)
    for sx in (-1, 1):
        for sz in (-1, 1):
            box(f"corner_{sx}_{sz}", [0.22, H, 0.22], [sx * (XW - 0.09), FY + H / 2, sz * (ZF - 0.09)], "concrete")

    # ---- partitions ---------------------------------------------------------------
    wall("part_living", "x", 2.0, -IX, IX, TI, [(1.35, 0.9, 0, 2.1)])          # open space | rooms, corridor entry
    wall("part_corridor", "z", 0.9, ZY, 2.0, TI, [(0.5, 0.8, 0, 2.1), (-3.0, 0.8, 0, 2.1), (-6.2, 0.8, 0, 2.1)])
    wall("part_bed", "x", -1.5, -IX, 0.9, TI, [])
    wall("part_wc", "x", -5.0, -IX, 0.9, TI, [])
    wall("part_yard", "x", ZY, -IX, IX, TI, [(1.35, 0.9, 0, 2.1)])
    for n, c in (("bed1", 0.5), ("bed2", -3.0), ("wc", -6.2)):
        door(f"door_{n}", "z", 0.9, c, 0.8, 2.1, TI, -1, color="wood")
    door("door_yard", "x", ZY, 1.35, 0.9, 2.1, TI, -1, color="door")

    # ---- FRONT (+Z) -----------------------------------------------------------------
    door("door_front", "x", cf, 0.8, 1.0, 2.1, T, +1)
    window("win_front", "x", cf, -0.8, 1.0, 0.9, 1.2, T, +1, shutters=True)
    box("step_upper", [1.6, 0.25, 0.5], [0.8, 0.325, 11.45], "stone")
    box("step_lower", [1.6, 0.125, 0.5], [0.8, 0.2625, 11.95], "stone")
    box("canopy", [2.2, 0.12, 1.5], [0.8, FY + 2.55, 11.65], "concrete")
    for sx in (-0.2, 1.8):
        cyl(f"canopy_post_{sx}", 0.06, 2.45, [sx, 0.325, 12.3], "concrete")
    box("house_number", [0.18, 0.12, 0.02], [1.6, FY + 1.6, ZF + 0.025], "metal")
    # ---- BACK (-Z) --------------------------------------------------------------------
    window("win_back", "x", cb, 0.0, 1.2, 1.2, 0.8, T, -1)
    cyl("tap_pipe", 0.025, 0.25, [-1.4, FY + 0.7, ZB - 0.15], "metal", 8)
    box("ac_unit", [0.9, 0.55, 0.35], [1.1, FY + 2.1, ZB - 0.2], "white")
    box("ac_fan", [0.55, 0.55, 0.02], [1.1, FY + 2.1, ZB - 0.385], "dark")
    # ---- SIDES ----------------------------------------------------------------------------
    for i, (c, w, s, oh) in enumerate(left):
        window(f"win_left_{i}", "z", cl, c, w, s, oh, T, -1, shutters=(i in (0, 2, 3)))
    for i, (c, w, s, oh) in enumerate(right):
        window(f"win_right_{i}", "z", cr, c, w, s, oh, T, +1, shutters=(i == 0))
    for i, (x, z) in enumerate([(-XW - 0.03, ZF + 0.03), (XW + 0.03, ZY + 0.2)]):
        cyl(f"downspout_{i}", 0.04, H + 0.1, [x, FY, z], "metal", 8)

    # ---- concrete frame: pilasters + edge beams, flat slab roof with roof garden ------------------
    y0 = FY + H
    for sx in (-1, 1):
        for i, z in enumerate((6.5, 2.0, -1.9, -5.4)):
            box(f"pilaster_{sx}_{i}", [0.1, H, 0.25], [sx * (XW + 0.05), FY + H / 2, z], "concrete")
    box("beam_front", [4.3, 0.25, 0.28], [0, y0 - 0.125, ZF + 0.04], "concrete")
    box("beam_back", [4.3, 0.25, 0.28], [0, y0 - 0.125, ZB - 0.04], "concrete")
    for sx in (-1, 1):
        box(f"beam_side_{sx}", [0.28, 0.25, ZF - ZB], [sx * (XW + 0.04), y0 - 0.125, 0], "concrete")
    stair(with_roof)
    if with_roof:
        rooftop()
    # parapet cap on the open-air yard walls
    for sx in (-1, 1):
        box(f"yard_cap_{sx}", [0.28, 0.06, ZY - IZB + 0.2], [sx * (XW - T / 2), y0 + 0.03, (ZY + IZB) / 2 - 0.1], "trim")
    box("yard_cap_back", [4.0, 0.06, 0.28], [0, y0 + 0.03, ZB + T / 2], "trim")

    # ---- INTERIOR ------------------------------------------------------------------------------
    # living room (z 5.5 .. 10.8): sofa on the right wall facing a TV on the left wall
    box("rug", [1.8, 0.02, 2.8], [0.0, FY + 0.03, 7.7], "rug")
    box("sofa_base", [0.9, 0.45, 2.2], [1.35, FY + 0.225, 7.7], "sofa")
    box("sofa_back", [0.2, 0.55, 2.2], [1.7, FY + 0.55, 7.7], "sofa")
    for z in (6.7, 8.7):
        box(f"sofa_arm_{z}", [0.9, 0.3, 0.15], [1.35, FY + 0.6, z], "sofa")
    box("coffee_top", [0.6, 0.05, 1.0], [0.0, FY + 0.4, 7.7], "wood")
    for i, (dx, dz) in enumerate([(-.22, -.4), (.22, -.4), (-.22, .4), (.22, .4)]):
        cyl(f"coffee_leg_{i}", 0.03, 0.4, [dx, FY, 7.7 + dz], "wood", 8)
    box("tv_stand", [0.4, 0.5, 1.4], [-1.55, FY + 0.25, 7.7], "wood")
    box("tv", [0.06, 0.65, 1.15], [-1.65, FY + 0.88, 7.7], "dark")
    box("shoe_rack", [0.3, 0.9, 1.0], [-1.6, FY + 0.45, 10.2], "cabinet")
    cyl("plant_pot", 0.2, 0.35, [-1.45, FY, 6.0], "pot")
    ball("plant", 0.35, [-1.45, FY + 0.75, 6.0], "green", scale=(1, 1.2, 1))
    cyl("lamp_pole", 0.02, 1.4, [1.55, FY, 9.9], "metal", 8)
    ball("lamp_shade", 0.15, [1.55, FY + 1.5, 9.9], "lamp")
    # kitchen + dining (z 2.2 .. 5.5)
    box("counter_base", [0.6, 0.85, 2.8], [-1.5, FY + 0.425, 3.8], "cabinet")
    box("counter_top", [0.65, 0.05, 2.8], [-1.475, FY + 0.875, 3.8], "counter")
    box("sink", [0.4, 0.03, 0.6], [-1.45, FY + 0.905, 3.9], "metal")
    cyl("faucet", 0.02, 0.28, [-1.7, FY + 0.9, 3.9], "metal", 8)
    box("stove_top", [0.5, 0.02, 0.6], [-1.5, FY + 0.91, 2.85], "dark")
    for i, z in enumerate((2.85, 4.8)):
        box(f"wall_cab_{i}", [0.35, 0.7, 0.9], [-1.625, FY + 1.85, z], "cabinet")
    box("fridge", [0.7, 1.8, 0.7], [1.45, FY + 0.9, 4.9], "metal")
    box("fridge_split", [0.02, 0.02, 0.68], [1.09, FY + 1.25, 4.9], "dark")
    box("dining_top", [0.8, 0.05, 1.2], [0.1, FY + 0.75, 3.7], "wood")
    for i, (dx, dz) in enumerate([(-.33, -.5), (.33, -.5), (-.33, .5), (.33, .5)]):
        cyl(f"dining_leg_{i}", 0.04, 0.75, [0.1 + dx, FY, 3.7 + dz], "wood", 8)
    for i, (x, z, s) in enumerate([(-0.6, 3.4, -1), (-0.6, 4.0, -1), (0.8, 3.4, 1), (0.8, 4.0, 1)]):
        box(f"chair_seat_{i}", [0.4, 0.05, 0.4], [x, FY + 0.45, z], "wood")
        box(f"chair_back_{i}", [0.05, 0.45, 0.4], [x + s * 0.2, FY + 0.7, z], "wood")
        for dx, dz in [(-.17, -.17), (.17, -.17), (-.17, .17), (.17, .17)]:
            cyl(f"chair_leg_{i}_{dx}_{dz}", 0.025, 0.45, [x + dx, FY, z + dz], "wood", 6)
    # bedrooms (x -1.8 .. 0.9)
    for n, zc, head_z, ward_z in (("bed1", 0.25, 1.9, -1.2), ("bed2", -3.25, -1.6, -4.7)):
        bz = head_z - 1.0 if head_z > zc else head_z + 1.0
        box(f"{n}_frame", [1.6, 0.35, 2.0], [-1.0, FY + 0.175, bz], "wood")
        box(f"{n}_mattress", [1.5, 0.2, 1.9], [-1.0, FY + 0.45, bz], "white")
        hs = 1 if head_z > zc else -1
        box(f"{n}_head", [1.6, 0.9, 0.08], [-1.0, FY + 0.45, head_z + hs * 0.0 + (0.04 if hs > 0 else -0.04)], "wood")
        box(f"{n}_blanket", [1.52, 0.06, 1.2], [-1.0, FY + 0.58, bz - hs * 0.35], "blanket")
        for i, x in enumerate((-1.4, -0.6)):
            box(f"{n}_pillow_{i}", [0.5, 0.12, 0.3], [x, FY + 0.6, bz + hs * 0.7], "white")
        box(f"{n}_nightstand", [0.4, 0.5, 0.4], [0.5, FY + 0.25, head_z - hs * 0.25], "wood")
        ball(f"{n}_lamp", 0.1, [0.5, FY + 0.62, head_z - hs * 0.25], "lamp")
        box(f"{n}_wardrobe", [1.4, 2.0, 0.55], [-1.0, FY + 1.0, ward_z], "wood")
        box(f"{n}_wardrobe_split", [0.02, 1.9, 0.02], [-1.0, FY + 1.0, ward_z + (0.28 if ward_z < zc else -0.28)], "dark")
    # toilet (z -7.4 .. -5.1)
    box("toilet_base", [0.4, 0.4, 0.55], [-1.4, FY + 0.2, -5.5], "white")
    box("toilet_tank", [0.4, 0.35, 0.2], [-1.4, FY + 0.55, -5.22], "white")
    box("vanity", [0.5, 0.85, 0.6], [0.55, FY + 0.425, -5.45], "cabinet")
    box("vanity_top", [0.52, 0.04, 0.62], [0.55, FY + 0.87, -5.45], "counter")
    box("mirror", [0.5, 0.6, 0.03], [0.55, FY + 1.5, -5.1], "mirror")
    box("shower_tray", [0.9, 0.06, 0.9], [-1.3, FY + 0.03, -6.9], "white")
    box("shower_glass", [0.02, 1.9, 0.9], [-0.84, FY + 0.95, -6.9], "glass")
    cyl("shower_pipe", 0.02, 1.7, [-1.7, FY, -6.9], "metal", 8)
    ball("shower_head", 0.09, [-1.62, FY + 1.75, -6.9], "metal", scale=(1, 0.4, 1))
    # drying yard (z -7.5 .. -10.8)
    for zc in (-8.6, -9.9):          # drying lines on the right half; the left half holds the spiral stair
        for sx in (-0.15, 1.7):
            cyl(f"line_pole_{sx}_{zc}", 0.03, 2.4, [sx, FY, zc], "metal", 8)
        m = trimesh.creation.cylinder(radius=0.008, height=1.85, sections=6)
        m.apply_transform(trimesh.transformations.rotation_matrix(np.pi / 2, [0, 0, 1]))
        m.apply_translation([0.775, FY + 2.35, zc])
        G.add(f"clothesline_{zc}", m, "metal")
    for i, (x, zc, c, w, h) in enumerate([
            (0.5, -8.6, "cloth4", 0.6, 0.9), (1.2, -8.6, "cloth3", 0.4, 0.5),
            (0.2, -9.9, "cloth3", 0.4, 0.5), (0.9, -9.9, "cloth1", 0.5, 0.7)]):
        box(f"cloth_{i}", [w, h, 0.02], [x, FY + 2.35 - h / 2, zc], c)
    box("washer", [0.6, 0.85, 0.6], [-1.4, FY + 0.425, -10.4], "washer")
    cyl("washer_door", 0.18, 0.02, [-1.4, FY + 0.35, -10.09], "dark", 12)
    for i, (x, z) in enumerate([(1.5, -10.4), (0.9, -10.5), (-0.1, -10.5)]):
        cyl(f"planter_{i}", 0.2, 0.4, [x, FY, z], "pot")
        ball(f"planter_leaf_{i}", 0.3, [x, FY + 0.65, z], "green", scale=(1, 1.1, 1))
    box("drain", [0.3, 0.02, 0.3], [0.0, FY + 0.03, -8.9], "dark")
    box("stool", [0.35, 0.3, 0.35], [0.3, FY + 0.15, -7.9], "wood")
    cyl("bucket", 0.14, 0.28, [0.7, FY, -7.9], "cloth2", 10)
    details(with_roof)
    return list(G.parts)


SX, SZ, SR, SN = -1.0, -8.7, 0.72, 17           # spiral stair: centre, outer radius, number of treads
YT = FY + H + 0.2                               # top of the concrete roof slab


def seg(name, p0, p1, r, m, sections=6):
    """Thin cylinder between two points."""
    p0, p1 = np.array(p0, float), np.array(p1, float)
    d = p1 - p0
    g = trimesh.creation.cylinder(radius=r, height=float(np.linalg.norm(d)), sections=sections)
    g.apply_transform(trimesh.geometry.align_vectors([0, 0, 1], d / np.linalg.norm(d)))
    g.apply_translation((p0 + p1) / 2)
    G.add(name, g, m)


def stair(with_roof):
    """Concrete spiral stair from the drying yard up to the roof slab (one full turn)."""
    rise = (YT - FY) / SN
    for i in range(SN):
        top = FY + (i + 1) * rise
        phi = np.radians((i - (SN - 1)) * 21.2)
        g = trimesh.creation.box([0.32, 0.07, SR])
        g.apply_translation([0, 0, SR / 2])
        g.apply_transform(trimesh.transformations.rotation_matrix(phi, [0, 1, 0]))
        g.apply_translation([SX, top - 0.035, SZ])
        G.add(f"stair_{i}", g, "concrete")
    cyl("stair_pole", 0.08, YT - FY + 0.9, [SX, FY, SZ], "steelk", 16)
    prev = None
    for i in range(SN - 2):                       # rail stops before the landing so the exit stays open
        top = FY + (i + 1) * rise
        phi = np.radians((i - (SN - 1)) * 21.2)
        x, z = SX + 0.69 * np.sin(phi), SZ + 0.69 * np.cos(phi)
        cyl(f"stair_post_{i}", 0.012, 0.9, [x, top, z], "steelk", 6)
        pt = [x, top + 0.9, z]
        if prev is not None:
            seg(f"stair_rail_{i}", prev, pt, 0.02, "steelk")
        prev = pt
    # landing + guard rails
    box("landing", [0.9, 0.2, 0.6], [SX, FY + H + 0.1, -7.8], "concrete")
    for sx in (-0.45, 0.45):
        for z in (-8.05, -7.62):
            cyl(f"landing_post_{sx}_{z}", 0.012, 0.9, [SX + sx, YT, z], "steelk", 6)
        seg(f"landing_rail_{sx}", [SX + sx, YT + 0.9, -8.05], [SX + sx, YT + 0.9, -7.62], 0.02, "steelk")
    cyl("landing_leg", 0.05, H, [SX, FY, -7.85], "concrete", 10)


def rooftop():
    """Flat concrete roof slab with parapet, lawn, flower + vegetable beds, deck and a pergola."""
    R = lambda h: YT + h  # noqa: E731
    y0 = FY + H
    zf, zb = ZF + 0.3, ZY - 0.06
    L, zc = zf - zb, (zf + zb) / 2
    box("roof_slab", [4.3, 0.2, L], [0, y0 + 0.1, zc], "concrete")
    # parapet 0.9 m, open at the stair landing (x -1.5 .. -0.5)
    for sx in (-1, 1):
        box(f"parapet_{sx}", [0.15, 0.9, L], [sx * 2.075, R(0.45), zc], "concrete")
        box(f"parapet_cap_{sx}", [0.24, 0.05, L], [sx * 2.075, R(0.925), zc], "concrete_dk")
    box("parapet_front", [4.0, 0.9, 0.15], [0, R(0.45), zf - 0.075], "concrete")
    box("parapet_front_cap", [4.3, 0.05, 0.24], [0, R(0.925), zf - 0.075], "concrete_dk")
    for n, x0, x1 in (("a", -2.15, -1.5), ("b", -0.5, 2.15)):
        box(f"parapet_back_{n}", [x1 - x0, 0.9, 0.15], [(x0 + x1) / 2, R(0.45), zb + 0.075], "concrete")
        box(f"parapet_back_cap_{n}", [x1 - x0, 0.05, 0.24], [(x0 + x1) / 2, R(0.925), zb + 0.075], "concrete_dk")
    # everything below is authored with the pergola at the back; mirrored in Z at the end
    # so the pergola ends up at the front and the garden at the back (next to the stair exit)
    n0 = len(G.parts)
    # lawn + stepping stones + deck
    box("lawn", [2.6, 0.06, 5.4], [0, R(0.03), 7.2], "grass")
    for i, z in enumerate(np.arange(10.0, 2.7, -0.6)):
        box(f"step_stone_{i}", [0.5, 0.1, 0.32], [0, R(0.05), float(z)], "stone")
    box("deck", [2.9, 0.05, 0.95], [0, R(0.025), 10.45], "wood")
    box("bench_seat", [1.4, 0.06, 0.45], [0, R(0.45), 10.55], "wooddk")
    box("bench_back", [1.4, 0.4, 0.05], [0, R(0.7), 10.8], "wooddk")
    for sx in (-0.6, 0.6):
        box(f"bench_leg_{sx}", [0.06, 0.45, 0.4], [sx, R(0.225), 10.55], "wooddk")
    for i, (x, m) in enumerate(((-0.35, "cloth1"), (0.35, "cloth3"))):
        box(f"bench_cushion_{i}", [0.55, 0.1, 0.4], [x, R(0.53), 10.55], m)
    for sx, lz in ((1.1, 10.45), (1.7, 9.9)):                      # potted lemon trees
        cyl(f"lemon_pot_{sx}", 0.25, 0.4, [sx, YT, lz], "pot", 14)
        cyl(f"lemon_trunk_{sx}", 0.04, 0.8, [sx, R(0.4), lz], "bark", 8)
        ball(f"lemon_crown_{sx}", 0.42, [sx, R(1.4), lz], "green", scale=(1, 0.95, 1))
        for k in range(5):
            a = k * 2 * np.pi / 5
            ball(f"lemon_{sx}_{k}", 0.05, [sx + 0.4 * np.sin(a), R(1.3 + 0.08 * (k % 2)), lz + 0.4 * np.cos(a)], "flower_y")
    # flower beds along both parapets
    zs = np.arange(3.4, 9.7, 0.55)
    for sx in (-1, 1):
        x = sx * 1.75
        box(f"fbed_{sx}", [0.5, 0.35, 6.8], [x, R(0.175), 6.4], "brick")
        box(f"fbed_soil_{sx}", [0.4, 0.04, 6.68], [x, R(0.35), 6.4], "soil")
        for i, z in enumerate(zs):
            ball(f"fplant_{sx}_{i}", 0.2, [x, R(0.55), float(z)], ("green", "leaf_dk")[i % 2], scale=(1, 1.1, 1))
            ball(f"fflower_{sx}_{i}", 0.065, [x + 0.08, R(0.76), float(z) + 0.05], ("flower_p", "flower_y", "cloth1")[(i + (sx > 0)) % 3])
    # vegetable beds + paver path
    box("veg_path", [0.9, 0.03, 3.0], [0, R(0.015), 0.9], "stone")
    for sx, fruit in ((-1, "fruit_r"), (1, "fruit_o")):
        x = sx * 1.2
        box(f"vbed_{sx}", [1.1, 0.3, 3.0], [x, R(0.15), 0.9], "brick")
        box(f"vbed_soil_{sx}", [1.0, 0.04, 2.9], [x, R(0.3), 0.9], "soil")
        for i, z in enumerate(np.arange(-0.3, 2.2, 0.5)):
            for j, dx in enumerate((-0.3, 0.0, 0.3)):
                ball(f"veg_{sx}_{i}_{j}", 0.11, [x + dx, R(0.42), float(z)], ("green", "leaf_dk")[(i + j) % 2], scale=(1, 0.8, 1))
            cyl(f"stake_{sx}_{i}", 0.01, 0.9, [x, R(0.3), float(z)], "wooddk", 6)
            ball(f"veg_fruit_{sx}_{i}", 0.045, [x + 0.05, R(0.75 - 0.05 * (i % 2)), float(z)], fruit)
    # pergola (polycarbonate roof, slightly tilted to drain to the back)
    tilt = -np.arctan(0.30 / 5.3)

    def tbox(name, size, centre, m):
        g = trimesh.creation.box(size)
        g.apply_transform(trimesh.transformations.rotation_matrix(tilt, [1, 0, 0]))
        g.apply_translation(centre)
        G.add(name, g, m)

    for sx in (-1.85, 1.85):
        for z, h in ((-1.7, 2.55), (-7.0, 2.25)):
            box(f"pergola_post_{sx}_{z}", [0.12, h, 0.12], [sx, R(h / 2), z], "steelk")
        tbox(f"pergola_beam_{sx}", [0.1, 0.12, 5.6], [sx, R(2.4), -4.35], "steelk")
    for i, z in enumerate((-1.7, -2.9, -4.1, -5.3, -6.5)):
        tbox(f"pergola_rafter_{i}", [4.0, 0.08, 0.08], [0, R(2.4 + (z + 4.35) * 0.0566), z], "steelk")
    tbox("pergola_panel", [4.1, 0.05, 5.7], [0, R(2.4 + 0.065), -4.35], "panel")
    for i, x in enumerate(np.arange(-1.6, 1.7, 0.4)):   # string lights
        ball(f"string_light_{i}", 0.035, [float(x), R(2.4 + (-1.7 + 4.35) * 0.0566 - 0.1), -1.7], "sconce")
    # outdoor dining set under the pergola
    tx, tz = 0.8, -4.2
    box("otable", [0.9, 0.05, 1.3], [tx, R(0.75), tz], "wood")
    for i, (dx, dz) in enumerate([(-.4, -.6), (.4, -.6), (-.4, .6), (.4, .6)]):
        cyl(f"otable_leg_{i}", 0.03, 0.75, [tx + dx, YT, tz + dz], "wood", 8)
    for i, (dx, dz, bx, bz) in enumerate([(0, 0.9, 0, 0.2), (0, -0.9, 0, -0.2), (-0.7, 0, -0.2, 0), (0.7, 0, 0.2, 0)]):
        cx_, cz_ = tx + dx, tz + dz
        box(f"ochair_seat_{i}", [0.4, 0.05, 0.4], [cx_, R(0.45), cz_], "wooddk")
        box(f"ochair_back_{i}", [0.4 if bz else 0.05, 0.4, 0.05 if bz else 0.4], [cx_ + bx, R(0.7), cz_ + bz], "wooddk")
        for ddx, ddz in [(-.17, -.17), (.17, -.17), (-.17, .17), (.17, .17)]:
            cyl(f"ochair_leg_{i}_{ddx}_{ddz}", 0.02, 0.45, [cx_ + ddx, YT, cz_ + ddz], "wooddk", 6)
    cyl("opendant_cord", 0.006, 0.5, [tx, R(1.85), tz], "dark", 6)
    ball("opendant", 0.13, [tx, R(1.8), tz], "sconce", scale=(1, 0.7, 1))
    cyl("o_vase", 0.04, 0.16, [tx, R(0.775), tz], "glass", 10)
    # BBQ grill
    for sx, sz in [(-.25, -.18), (.25, -.18), (-.25, .18), (.25, .18)]:
        cyl(f"bbq_leg_{sx}_{sz}", 0.02, 0.55, [1.5 + sx, YT, -6.4 + sz], "steelk", 6)
    box("bbq_body", [0.65, 0.2, 0.45], [1.5, R(0.65), -6.4], "dark")
    ball("bbq_lid", 0.3, [1.5, R(0.8), -6.4], "dark", scale=(1.1, 0.5, 0.75))
    # water tank on a steel stand
    for sx, sz in [(-.4, -.4), (.4, -.4), (-.4, .4), (.4, .4)]:
        cyl(f"tank_leg_{sx}_{sz}", 0.03, 0.5, [-1.5 + sx, YT, -2.45 + sz], "steelk", 8)
    box("tank_deck", [0.9, 0.05, 0.9], [-1.5, R(0.525), -2.45], "steelk")
    cyl("tank", 0.4, 1.0, [-1.5, R(0.55), -2.45], "tank", 24)
    ball("tank_lid", 0.4, [-1.5, R(1.55), -2.45], "tank", scale=(1, 0.22, 1))
    cyl("tank_pipe", 0.02, 0.6, [-1.14, YT, -2.45], "metal", 8)
    # pots near the stair exit
    for i, (x, z) in enumerate([(1.55, -7.1), (0.6, -7.2)]):
        cyl(f"rpot_{i}", 0.2, 0.35, [x, YT, z], "pot", 12)
        ball(f"rpot_leaf_{i}", 0.3, [x, R(0.6), z], ("green", "leaf_dk")[i], scale=(1, 1.1, 1))
    zm = zf + zb                  # mirror plane: z' = (zf + zb) - z
    for k in range(n0, len(G.parts)):
        n, m = G.parts[k]
        m.vertices = m.vertices * [1, 1, -1] + [0, 0, zm]
        m.faces = m.faces[:, ::-1]


def Y(h):
    return FY + h


def cz(name, r, h, c, m, sections=16):
    """Cylinder along Z (c = centre)."""
    g = trimesh.creation.cylinder(radius=r, height=h, sections=sections)
    g.apply_translation(c)
    G.add(name, g, m)


def cx(name, r, h, c, m, sections=12):
    """Cylinder along X (c = centre)."""
    g = trimesh.creation.cylinder(radius=r, height=h, sections=sections)
    g.apply_transform(trimesh.transformations.rotation_matrix(np.pi / 2, [0, 1, 0]))
    g.apply_translation(c)
    G.add(name, g, m)


def details(with_roof):
    """Extra fittings, decor, curtains, lights and tiles for every room."""
    drop = {"wall_cab_0", "stove_top"}
    G.parts[:] = [p for p in G.parts if p[0] not in drop]
    zh = Y(H)

    # ---- shared: skirting boards, curtains, switches ---------------------------------
    for n, x, z0, z1 in (("sk_left", -IX + 0.01, -7.4, 10.8), ("sk_right_a", IX - 0.01, 2.0, 10.8), ("sk_right_b", IX - 0.01, -7.4, 2.0)):
        box(n, [0.02, 0.1, z1 - z0], [x, Y(0.05), (z0 + z1) / 2], "trim")
    box("sk_front", [3.6, 0.1, 0.02], [0, Y(0.05), IZF - 0.01], "trim")

    def curtains(n, axis, face, c, w, pal):
        """axis 'z': window on a side wall (face = inner x); 'x': on front wall (face = inner z)."""
        for k, sgn in enumerate((-1, 1)):
            u = c + sgn * (w / 2 + 0.28)
            sx = [0.07, 1.75, 0.5] if axis == "z" else [0.5, 1.75, 0.07]
            ctr = [face, Y(1.2), u] if axis == "z" else [u, Y(1.2), face]
            box(f"{n}_cur{k}", sx, ctr, pal)
        rod = [0.04, 0.04, w + 1.1] if axis == "z" else [w + 1.1, 0.04, 0.04]
        box(f"{n}_rod", rod, [face, Y(2.15), c] if axis == "z" else [c, Y(2.15), face], "metal")

    curtains("cur_front", "x", IZF - 0.06, -0.8, 1.0, "curtain1")
    curtains("cur_live_l", "z", -IX + 0.06, 10.0, 1.0, "curtain1")
    curtains("cur_live_r", "z", IX - 0.06, 9.5, 1.2, "curtain1")
    curtains("cur_bed1", "z", -IX + 0.06, 0.5, 1.0, "curtain2")
    curtains("cur_bed2", "z", -IX + 0.06, -3.0, 1.0, "curtain1")
    for i, (x, z, y) in enumerate([(1.55, IZF - 0.01, 1.2), (-1.2, 2.065, 1.2), (0.82, -3.7, 1.2)]):
        box(f"switch_{i}", [0.1, 0.12, 0.02] if i < 2 else [0.02, 0.12, 0.1], [x, Y(y), z], "white")

    # ---- LIVING ROOM ------------------------------------------------------------------
    box("doormat", [0.8, 0.02, 0.5], [0.8, Y(0.04), 10.45], "rubber")
    box("coat_rack", [0.03, 0.04, 0.8], [-IX + 0.03, Y(1.6), 9.0], "metal")
    for i, z in enumerate((8.7, 9.0, 9.3)):
        cx(f"coat_hook_{i}", 0.015, 0.06, [-IX + 0.06, Y(1.6), z], "metal", 8)
    for i, (z, m) in enumerate(((8.8, "cloth2"), (9.2, "cloth1"))):
        box(f"coat_{i}", [0.12, 0.8, 0.25], [-IX + 0.1, Y(1.2), z], m)
    for i, (z, m) in enumerate(((6.95, "cloth1"), (7.7, "cloth3"), (8.45, "cloth2"))):
        box(f"cushion_{i}", [0.15, 0.38, 0.42], [1.48, Y(0.65), z], m)
    box("throw", [0.9, 0.04, 0.4], [1.35, Y(0.5), 6.75], "blanket")
    box("tray", [0.35, 0.02, 0.5], [0.0, Y(0.43), 7.7], "wooddk")
    cyl("vase", 0.05, 0.2, [0.0, Y(0.44), 7.8], "glass", 10)
    for i, (dx, dy, dz) in enumerate([(0, 0.28, 0), (0.05, 0.22, 0.04), (-0.05, 0.24, -0.04)]):
        ball(f"flower_{i}", 0.05, [dx, Y(0.44 + dy), 7.8 + dz], ("cloth1", "cloth3", "cloth2")[i])
    for i, m in enumerate(("book1", "book2", "book3")):
        box(f"coffee_book_{i}", [0.22, 0.03, 0.3], [0.0, Y(0.45 + 0.03 * i + 0.015), 7.4], m)
    cyl("pouf", 0.22, 0.4, [-0.55, FY + 0.03, 8.9], "toy")
    box("soundbar", [0.08, 0.1, 0.8], [-1.55, Y(0.55), 7.7], "dark")
    box("settop", [0.25, 0.05, 0.3], [-1.55, Y(0.525), 7.15], "steelk")
    box("ac_living", [0.28, 0.3, 0.9], [-1.64, Y(2.25), 7.7], "white")
    box("ac_living_vent", [0.02, 0.04, 0.8], [-1.5, Y(2.15), 7.7], "dark")
    for i, (z, m) in enumerate(((7.35, "cloth1"), (8.05, "cloth2"))):
        box(f"frame_back_{i}", [0.02, 0.66, 0.56], [IX - 0.02, Y(1.7), z], "trim")
        box(f"frame_art_{i}", [0.02, 0.58, 0.48], [IX - 0.035, Y(1.7), z], m)
    box("side_table", [0.4, 0.5, 0.4], [1.5, Y(0.25), 9.4], "wood")
    box("side_book", [0.2, 0.04, 0.28], [1.5, Y(0.52), 9.4], "book2")
    # ---- KITCHEN / DINING -----------------------------------------------------------------
    box("hood", [0.4, 0.14, 0.7], [-1.58, Y(1.75), 2.85], "steelk")
    box("hood_flue", [0.18, 1.0, 0.25], [-1.69, Y(2.3), 2.85], "steelk")
    box("splash_stove", [0.02, 0.7, 0.9], [-IX + 0.01, Y(1.25), 2.85], "tile")
    box("stove_top", [0.5, 0.02, 0.65], [-1.5, Y(0.91), 2.85], "dark")
    for i, z in enumerate((2.65, 3.05)):
        cyl(f"burner_{i}", 0.09, 0.015, [-1.5, Y(0.92), z], "steelk", 14)
    cyl("pot", 0.12, 0.13, [-1.5, Y(0.93), 2.65], "metal")
    cyl("pot_lid", 0.125, 0.015, [-1.5, Y(1.06), 2.65], "steelk")
    cyl("kettle", 0.08, 0.18, [-1.5, Y(0.93), 3.05], "steelk")
    for k in range(4):   # cabinet doors and handles on the counter front
        z = 2.4 + 0.35 + k * 0.7
        box(f"cab_line_{k}", [0.01, 0.8, 0.01], [-1.19, Y(0.42), z + 0.35], "dark")
        box(f"cab_handle_{k}", [0.02, 0.12, 0.03], [-1.18, Y(0.62), z - 0.05], "metal")
    box("drawer_line", [0.01, 0.01, 2.8], [-1.19, Y(0.72), 3.8], "dark")
    box("rice_cooker", [0.25, 0.25, 0.25], [-1.55, Y(1.025), 4.95], "white")
    box("microwave", [0.35, 0.22, 0.5], [-1.6, Y(1.0), 4.45], "steelk")
    box("cutting_board", [0.3, 0.02, 0.4], [-1.5, Y(0.915), 3.35], "wood")
    box("knife_block", [0.1, 0.2, 0.15], [-1.7, Y(0.99), 3.2], "wooddk")
    box("dish_rack", [0.3, 0.03, 0.4], [-1.5, Y(0.92), 4.35], "metal")
    for i in range(3):
        cx(f"rack_plate_{i}", 0.12, 0.012, [-1.5, Y(1.03), 4.2 + i * 0.1], "white", 16)
    cyl("soap", 0.03, 0.12, [-1.7, Y(0.9), 3.55], "toy", 8)
    cyl("trash_bin", 0.17, 0.5, [-1.45, FY, 5.45], "steelk", 14)
    for i, y in enumerate((1.0, 1.5)):
        box(f"fridge_handle_{i}", [0.03, 0.4 if i else 0.25, 0.04], [1.075, Y(y), 4.6], "metal")
    cz("wall_clock", 0.15, 0.03, [-0.4, Y(2.1), 2.075], "white", 24)
    box("clock_hand_h", [0.02, 0.1, 0.01], [-0.4, Y(2.14), 2.095], "dark")
    box("clock_hand_m", [0.08, 0.02, 0.01], [-0.36, Y(2.1), 2.095], "dark")
    for i, z in enumerate((3.4, 4.0)):                      # table setting, 2 sides
        for side, x in ((-1, -0.2), (1, 0.4)):
            box(f"mat_{i}_{side}", [0.28, 0.01, 0.24], [x, Y(0.78), z], "cloth4")
            cyl(f"plate_{i}_{side}", 0.1, 0.015, [x, Y(0.79), z], "white", 16)
            cyl(f"glass_{i}_{side}", 0.03, 0.1, [x + side * 0.1, Y(0.78), z + 0.1], "glass", 8)
    cyl("fruit_bowl", 0.12, 0.05, [0.1, Y(0.78), 3.7], "white", 16)
    for i, (dx, dz, m) in enumerate([(-0.04, 0, "fruit_r"), (0.04, 0.03, "fruit_o"), (0, -0.04, "fruit_r")]):
        ball(f"fruit_{i}", 0.045, [0.1 + dx, Y(0.87), 3.7 + dz], m)
    cyl("dining_vase", 0.04, 0.15, [0.1, Y(0.78), 4.1], "glass", 10)
    if with_roof:
        for i, z in enumerate((3.4, 4.0)):
            box(f"pendant_cord_{i}", [0.012, H - 1.95, 0.012], [0.1, Y((H + 1.95) / 2), z], "dark")
            ball(f"pendant_{i}", 0.13, [0.1, Y(1.95), z], "sconce", scale=(1, 0.7, 1))

    # ---- BEDROOM 1 (master) -----------------------------------------------------------------
    box("rug_bed1", [2.0, 0.02, 1.4], [-0.95, Y(0.03), -0.7], "rug")
    box("bed1_throw", [1.5, 0.05, 0.3], [-1.0, Y(0.56), 0.15], "cloth2")
    for i, x in enumerate((-1.4, -0.6)):
        box(f"bed1_pillow_b{i}", [0.5, 0.12, 0.3], [x, Y(0.7), 1.65], "cloth4")
    box("bed1_art_back", [0.9, 0.5, 0.03], [-1.0, Y(1.45), 1.96], "trim")
    box("bed1_art", [0.8, 0.4, 0.03], [-1.0, Y(1.45), 1.945], "cloth3")
    box("ac_bed1", [0.9, 0.28, 0.2], [-1.0, Y(2.3), 1.85], "white")
    box("clock_alarm", [0.1, 0.08, 0.05], [0.5, Y(0.54), 1.6], "dark")
    box("bed1_book", [0.2, 0.05, 0.15], [0.5, Y(0.525), 1.35], "book1")
    for i in range(2):
        box(f"bed1_drawer_{i}", [0.01, 0.01, 0.34], [0.5, Y(0.18 + 0.2 * i), 1.38], "dark")
    for k, x in enumerate((-1.45, -1.0, -0.55)):
        box(f"bed1_storage_{k}", [0.4, 0.25, 0.4], [x, Y(2.12), -1.2], "cabinet")
    for k, x in enumerate((-1.2, -0.8)):
        box(f"bed1_wardrobe_handle_{k}", [0.03, 0.25, 0.03], [x, Y(1.0), -0.93], "metal")
    box("dress_top", [0.4, 0.04, 0.9], [0.62, Y(0.75), -0.95], "wood")
    box("dress_body", [0.38, 0.2, 0.86], [0.62, Y(0.62), -0.95], "wood")
    for i, (dx, dz) in enumerate([(-.17, -.4), (.17, -.4), (-.17, .4), (.17, .4)]):
        cyl(f"dress_leg_{i}", 0.025, 0.52, [0.62 + dx, FY, -0.95 + dz], "wood", 6)
    box("dress_mirror", [0.03, 0.7, 0.5], [0.82, Y(1.25), -0.95], "mirror")
    for i, z in enumerate((-1.15, -0.95, -0.75)):
        cyl(f"cosmetic_{i}", 0.025, 0.08 + 0.02 * i, [0.68, Y(0.77), z], ("cloth1", "cloth4", "toy")[i], 8)
    cyl("dress_stool", 0.17, 0.45, [0.25, FY, -0.95], "sofa", 12)
    # ---- BEDROOM 2 (study / guest) ------------------------------------------------------------
    box("bed2_blanket_over", [1.52, 0.06, 1.0], [-1.0, Y(0.58), -2.3], "cloth2")
    box("rug_bed2", [1.6, 0.02, 1.2], [-1.0, Y(0.03), -4.05], "rug")
    box("ac_bed2", [0.9, 0.28, 0.2], [-1.0, Y(2.3), -1.7], "white")
    for i, (x, m) in enumerate(((-1.45, "cloth1"), (-1.0, "cloth3"), (-0.55, "cloth2"))):
        box(f"bed2_frame_{i}", [0.3, 0.4, 0.02], [x, Y(1.5), -1.58], m)
    box("desk_top", [0.5, 0.04, 0.95], [0.55, Y(0.75), -4.3], "wood")
    box("desk_panel", [0.03, 0.7, 0.95], [0.78, Y(0.37), -4.3], "wood")
    for i, dz in enumerate((-0.42, 0.42)):
        cyl(f"desk_leg_{i}", 0.025, 0.73, [0.33, FY, -4.3 + dz], "wood", 6)
    box("laptop_base", [0.26, 0.012, 0.2], [0.5, Y(0.776), -4.3], "steelk")
    box("laptop_screen", [0.01, 0.18, 0.2], [0.62, Y(0.87), -4.3], "dark")
    for i, m in enumerate(("book2", "book3", "book1")):
        box(f"desk_book_{i}", [0.18, 0.03, 0.14], [0.65, Y(0.775 + 0.03 * i), -3.95], m)
    cyl("desk_lamp_base", 0.05, 0.02, [0.75, Y(0.77), -4.65], "metal", 10)
    cyl("desk_lamp_arm", 0.012, 0.35, [0.75, Y(0.79), -4.65], "metal", 6)
    ball("desk_lamp", 0.07, [0.7, Y(1.15), -4.65], "sconce", scale=(1, 0.6, 1))
    box("chair2_seat", [0.4, 0.05, 0.4], [0.05, Y(0.45), -4.3], "cloth2")
    box("chair2_back", [0.05, 0.45, 0.4], [-0.13, Y(0.7), -4.3], "cloth2")
    for dx, dz in [(-.15, -.15), (.15, -.15), (-.15, .15), (.15, .15)]:
        cyl(f"chair2_leg_{dx}_{dz}", 0.02, 0.45, [0.05 + dx, FY, -4.3 + dz], "metal", 6)
    box("toy_box", [0.5, 0.3, 0.5], [-1.5, Y(0.15), -4.0], "toy")
    for i, (x, z, m) in enumerate(((-0.9, -3.95, "cloth1"), (-0.7, -4.25, "cloth2"), (-1.1, -4.3, "cloth3"))):
        ball(f"toy_ball_{i}", 0.08, [x, Y(0.1), z], m)
    ball("teddy_body", 0.12, [-1.0, Y(0.66), -2.0], "wooddk")
    ball("teddy_head", 0.08, [-1.0, Y(0.8), -2.0], "wooddk")
    for i, dx in enumerate((-0.06, 0.06)):
        ball(f"teddy_ear_{i}", 0.03, [-1.0 + dx, Y(0.87), -2.0], "wooddk")
    for k, x in enumerate((-1.2, -0.8)):
        box(f"bed2_wardrobe_handle_{k}", [0.03, 0.25, 0.03], [x, Y(1.0), -4.43], "metal")
    # ---- TOILET --------------------------------------------------------------------------------
    h = 1.2
    box("tile_left", [0.02, h, 2.4], [-IX + 0.01, Y(h / 2), -6.25], "tile")
    box("tile_part", [2.7, h, 0.02], [-0.45, Y(h / 2), -5.07], "tile")
    box("tile_back", [2.7, h, 0.02], [-0.45, Y(h / 2), -7.43], "tile")
    box("tile_corr_a", [0.02, h, 0.8], [0.83, Y(h / 2), -7.0], "tile")
    box("tile_corr_b", [0.02, h, 0.74], [0.83, Y(h / 2), -5.43], "tile")
    box("toilet_lid", [0.38, 0.02, 0.42], [-1.4, Y(0.415), -5.5], "white")
    cyl("flush_btn", 0.03, 0.02, [-1.4, Y(0.74), -5.22], "metal", 10)
    cx("tp_holder", 0.03, 0.12, [-IX + 0.08, Y(0.8), -5.5], "metal", 8)
    cx("tp_roll", 0.055, 0.1, [-IX + 0.12, Y(0.8), -5.5], "white", 10)
    cyl("bidet_hose", 0.012, 0.3, [-IX + 0.04, Y(0.55), -5.8], "metal", 6)
    box("vanity_bowl", [0.4, 0.03, 0.4], [0.55, Y(0.895), -5.45], "white")
    cyl("vanity_faucet", 0.015, 0.2, [0.55, Y(0.9), -5.3], "metal", 8)
    for i, z in enumerate((-5.25, -5.65)):
        box(f"vanity_handle_{i}", [0.02, 0.1, 0.02], [0.79, Y(0.7), z], "metal")
    box("vanity_line", [0.01, 0.8, 0.01], [0.805, Y(0.42), -5.45], "dark")
    box("mirror_light", [0.4, 0.04, 0.04], [0.55, Y(1.85), -5.1], "sconce")
    cyl("brush_cup", 0.035, 0.1, [0.4, Y(0.9), -5.3], "glass", 8)
    cyl("hand_soap", 0.03, 0.14, [0.7, Y(0.9), -5.3], "toy", 8)
    box("towel_rail", [0.5, 0.03, 0.03], [-0.45, Y(1.3), -5.1], "metal")
    box("towel_a", [0.25, 0.55, 0.03], [-0.55, Y(1.0), -5.1], "cloth3")
    box("towel_b", [0.25, 0.55, 0.03], [-0.3, Y(1.0), -5.1], "cloth2")
    box("bath_mat", [0.5, 0.015, 0.35], [-0.4, Y(0.03), -6.7], "cloth2")
    box("shower_shelf", [0.12, 0.03, 0.3], [-IX + 0.07, Y(1.0), -7.15], "metal")
    for i, (z, m) in enumerate(((-7.07, "cloth2"), (-7.15, "toy"), (-7.23, "cloth1"))):
        cyl(f"shower_bottle_{i}", 0.025, 0.14, [-IX + 0.07, Y(1.015), z], m, 8)
    cx("shower_arm", 0.012, 0.3, [-1.62, Y(1.8), -6.9], "metal", 6)
    cx("shower_mixer", 0.04, 0.05, [-IX + 0.03, Y(1.1), -6.9], "metal", 12)
    cyl("shower_drain", 0.05, 0.01, [-1.3, Y(0.065), -6.9], "dark", 12)
    box("shower_glass_handle", [0.03, 0.3, 0.02], [-0.82, Y(1.0), -6.5], "metal")
    cyl("wc_bin", 0.1, 0.25, [0.65, FY, -6.9], "white", 12)
    # ---- CORRIDOR --------------------------------------------------------------------------------
    box("corridor_runner", [0.5, 0.015, 8.5], [1.35, Y(0.03), -2.7], "cloth2")
    for i, z in enumerate((-2.8, -3.4)):
        box(f"corr_frame_{i}", [0.02, 0.5, 0.4], [IX - 0.02, Y(1.5), z], "trim")
        box(f"corr_art_{i}", [0.02, 0.42, 0.32], [IX - 0.035, Y(1.5), z], ("cloth1", "cloth3")[i])
    for i, z in enumerate((-1.8, -5.0)):
        box(f"sconce_{i}", [0.05, 0.15, 0.1], [0.97, Y(1.9), z], "sconce")
    box("db_panel", [0.03, 0.35, 0.25], [IX - 0.02, Y(1.5), 1.5], "metal")
    # ---- DRYING YARD ----------------------------------------------------------------------------------
    for i, z in enumerate(np.arange(-10.5, -7.6, 0.6)):
        box(f"yard_joint_z{i}", [3.6, 0.005, 0.015], [0, Y(0.025), z], "found")
    for i, x in enumerate((-1.2, -0.6, 0.0, 0.6, 1.2)):
        box(f"yard_joint_x{i}", [0.015, 0.005, 3.3], [x, Y(0.025), -9.15], "found")
    cyl("laundry_basket", 0.22, 0.35, [0.35, FY, -10.35], "toy", 14)
    box("basket_clothes", [0.3, 0.05, 0.3], [0.35, Y(0.36), -10.35], "cloth4")
    t = trimesh.creation.torus(major_radius=0.16, minor_radius=0.025, major_sections=18, minor_sections=8)
    t.apply_translation([0.95, Y(0.8), -10.7])
    G.add("hose_coil", t, "hose")
    cyl("mop_pole", 0.015, 1.4, [1.72, FY, -8.1], "wooddk", 6)
    box("mop_head", [0.04, 0.05, 0.25], [1.72, Y(0.05), -8.1], "cloth4")
    cyl("broom_pole", 0.015, 1.3, [1.72, FY, -8.4], "wooddk", 6)
    box("broom_head", [0.04, 0.12, 0.2], [1.72, Y(0.06), -8.4], "toy")
    box("yard_lamp", [0.15, 0.1, 0.1], [0.4, Y(2.3), ZY - 0.08], "sconce")
    box("yard_tap", [0.04, 0.04, 0.12], [-0.4, Y(0.6), IZB + 0.06], "metal")
    cyl("yard_tap_pipe", 0.02, 0.6, [-0.4, FY, IZB + 0.03], "metal", 8)

    # ---- ceiling + flush lights (roofed variant only) -----------------------------------------------------
    if with_roof:
        box("ceiling", [3.6, 0.04, ZF - 0.2 - (ZY + 0.06)], [0, zh - 0.02, (ZF - 0.2 + ZY + 0.06) / 2], "trim")
        for i, (x, z) in enumerate([(0, 8.0), (0, 5.5), (-0.4, 0.2), (-0.4, -3.2), (-0.4, -6.2), (1.35, -1.8), (1.35, -5.0)]):
            cyl(f"ceil_light_{i}", 0.14, 0.02, [x, zh - 0.05, z], "sconce", 16)
        cyl("exhaust_fan", 0.1, 0.02, [-1.2, zh - 0.05, -5.8], "white", 14)
        cyl("exhaust_fan_core", 0.07, 0.025, [-1.2, zh - 0.055, -5.8], "dark", 14)


def merge_by_material(ps):
    """One mesh per material (flat shading): far fewer nodes/accessors than ~900 loose boxes."""
    groups = {}
    for _, m in ps:
        groups.setdefault(m.visual.material.name, []).append(m)
    out = []
    for name, ms in groups.items():
        verts, faces, off = [], [], 0
        for m in ms:
            m = m.copy()
            m.unmerge_vertices()
            verts.append(m.vertices)
            faces.append(m.faces + off)
            off += len(m.vertices)
        merged = trimesh.Trimesh(np.vstack(verts), np.vstack(faces), process=False)
        merged.visual = trimesh.visual.TextureVisuals(material=ms[0].visual.material)
        out.append((name, merged))
    return out


def export(path, with_roof):
    ps = build(with_roof)
    n_loose = len(ps)
    ps = merge_by_material(ps)
    scene = trimesh.Scene()
    for name, m in ps:
        scene.add_geometry(m, geom_name=name, node_name=name)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(scene.export(file_type="glb"))
    tris = sum(len(m.faces) for _, m in ps)
    print(f"wrote {path.name} ({path.stat().st_size} bytes, {n_loose} parts -> {len(ps)} meshes, {tris} tris) bounds={scene.bounds.round(2).tolist()}")


if __name__ == "__main__":
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "assets/3d"
    export(out / "house_tube.glb", True)
    export(out / "house_tube_interior.glb", False)
