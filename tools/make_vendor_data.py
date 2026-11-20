"""Writes VendorData.lua (Packbound's ammo vendor list) from an installed QuestieDB.

Run from the addon folder:  python3 tools/make_vendor_data.py [path/to/QuestieDB]
(default: ../QuestieDB, next to Packbound in Interface/AddOns). Re-run when QuestieDB updates.

The vendor data (who sells which ammo, where they stand, which side they serve) comes from
QuestieDB, a part of Questie (https://github.com/Questie/Questie), used under the GPLv3 terms the
Questie team allows; see VendorData.lua's header. Only these facts are taken, for the ammo below.
QuestieDB stores entities in its TOC as base64 CBOR rows ("## X-<Kind>-<id>-S" for scalars,
"-<field>" for table fields; "~N~" means the value is split into N numbered parts).
"""
import base64
import os
import re
import struct
import sys

AMMO = {
    "arrows": [2512, 2515, 3030, 11285],   # Rough, Sharp, Razor, Jagged Arrow
    "bullets": [2516, 2519, 3033, 11284],  # Light Shot, Heavy Shot, Solid Shot, Accurate Slugs
}
ITEM_VENDORS = 14                        # itemMeta: vendors
NPC_NAME, NPC_SPAWNS, NPC_SIDE = 1, 7, 13  # npcMeta: name, spawns, friendlyToFaction


def cbor(b, i=0):
    """Decodes one CBOR item at b[i:]; returns (value, next index)."""
    head = b[i]
    major, info = head >> 5, head & 31
    i += 1
    if major == 7:
        simple = {20: False, 21: True, 22: None, 23: None}
        if info in simple:
            return simple[info], i
        size, fmt = {25: (2, ">e"), 26: (4, ">f"), 27: (8, ">d")}[info]
        return struct.unpack(fmt, b[i:i + size])[0], i + size
    if info < 24:
        n = info
    else:
        size = {24: 1, 25: 2, 26: 4, 27: 8}[info]
        n, i = int.from_bytes(b[i:i + size], "big"), i + size
    if major == 0:
        return n, i
    if major == 1:
        return -1 - n, i
    if major in (2, 3):
        raw = b[i:i + n]
        return raw.decode("utf-8") if major == 3 else raw, i + n
    if major == 4:
        out = []
        for _ in range(n):
            v, i = cbor(b, i)
            out.append(v)
        return out, i
    if major == 5:
        out = {}
        for _ in range(n):
            k, i = cbor(b, i)
            v, i = cbor(b, i)
            out[k.decode("utf-8") if isinstance(k, bytes) else k] = v
        return out, i
    if major == 6:
        return cbor(b, i)
    raise ValueError("CBOR major type %d" % major)


def text(v):
    return v.decode("utf-8") if isinstance(v, bytes) else v


class QuestieDB:
    def __init__(self, folder):
        toc = os.path.join(folder, "QuestieDB_Forever.toc")
        self.store = {}
        with open(toc, encoding="utf-8") as f:
            for line in f:
                if line.startswith("## X-"):
                    key, _, value = line[3:].partition(":")
                    self.store[key.strip()] = value.strip()
        self.zones = {}
        with open(os.path.join(folder, "support", "Forever", "Zones", "areaIdToUiMapId.lua"),
                  encoding="utf-8") as f:
            src = f.read()
        base = src.split("ZoneDB.private.areaIdToUiMapId =", 1)[1]
        override = src.split("ZoneDB.private.areaIdToUiMapIdOverride =", 1)[1].split("]]", 1)[0]
        for block in (base.split("]]", 1)[0], override):  # the override wins
            for area, ui in re.findall(r"\[(\d+)\]\s*=\s*(\d+)", block):
                self.zones[int(area)] = int(ui)

    def get(self, key):
        v = self.store.get(key)
        if v is None:
            return None
        if v.startswith("~"):
            parts = int(v.strip("~"))
            v = "".join(self.store["%s-%d" % (key, n)] for n in range(1, parts + 1))
        return cbor(base64.b64decode(v))[0]

    def field(self, kind, id_, index):
        if index == 1 or kind == "Npc" and index == NPC_SIDE:
            row = self.get("X-%s-%d-S" % (kind, id_)) or {}
            return row.get(index)
        return self.get("X-%s-%d-%d" % (kind, id_, index))


def vendors(db):
    found = {}
    for kind, items in AMMO.items():
        for item in items:
            for npc in db.field("Item", item, ITEM_VENDORS) or []:
                v = found.setdefault(npc, {"arrows": [], "bullets": []})
                v[kind].append(item)
    out, skipped = [], []
    for npc, sells in found.items():
        name = text(db.field("Npc", npc, NPC_NAME))
        side = text(db.field("Npc", npc, NPC_SIDE))
        spawns = db.field("Npc", npc, NPC_SPAWNS) or {}
        if isinstance(spawns, list):  # a Lua table keyed 1..n comes out as a list (area 1 is Dun Morogh)
            spawns = {n + 1: v for n, v in enumerate(spawns) if v}
        if side not in ("A", "H", "AH"):
            skipped.append("%s (%d): friendly to neither side" % (name, npc))
            continue
        place = None
        for area in sorted(spawns):  # the first spawn in a zone with a map (not an instance)
            ui = db.zones.get(area)
            points = [p for p in spawns[area] if p and 0 < p[0] < 100 and 0 < p[1] < 100]
            if ui and points:
                place = (ui, points[0][0] / 100, points[0][1] / 100)
                break
        if not name or not place:
            skipped.append("%s (%d): no spawn on a map" % (name, npc))
            continue
        out.append({"npc": npc, "name": name, "map": place[0], "x": place[1], "y": place[2],
                    "side": side, **sells})
    out.sort(key=lambda v: (v["map"], v["name"], v["npc"]))
    return out, skipped


def lua_list(ids):
    return "{ %s }" % ", ".join(map(str, ids)) if ids else "{}"


def lua_string(s):
    return '"%s"' % s.replace("\\", "\\\\").replace('"', '\\"')


HEADER = '''-- Ammo vendors Packbound knows from the start: { npc = NPC id, name, map = uiMapID, x, y (0..1
-- on that map), side = "A" | "H" | "AH", arrows = { item IDs sold }, bullets = { item IDs sold } }.
-- Vendors met in play are learned (Vendor.lua) and win over an entry here with the same npc.
--
-- GENERATED by tools/make_vendor_data.py from QuestieDB; do not edit by hand, re-run it.
-- The vendor facts come from QuestieDB, a part of Questie (https://github.com/Questie/Questie),
-- by Muehe, Logon, TheCrux/BreakBB, Drejjmit, Cheeq, TechnoHunter, Yttrium and the Questie
-- contributors, used under the GNU GPL v3 as the Questie team allows (Packbound is GPL-3.0-or-later).
local _, ns = ...
if ns.disabled then return end

-- the ammo vendors sell, lowest level first
ns.AMMO_ITEMS = {
	arrows = { 2512, 2515, 3030, 11285 },  -- Rough, Sharp, Razor, Jagged Arrow
	bullets = { 2516, 2519, 3033, 11284 }, -- Light Shot, Heavy Shot, Solid Shot, Accurate Slugs
}

ns.AMMO_VENDORS = {
'''


def main():
    folder = sys.argv[1] if len(sys.argv) > 1 else os.path.join("..", "QuestieDB")
    db = QuestieDB(folder)
    found, skipped = vendors(db)
    lines = [HEADER]
    for v in found:
        lines.append("\t{ npc = %d, name = %s, map = %d, x = %.4f, y = %.4f, side = \"%s\", "
                     "arrows = %s, bullets = %s },\n" % (
                         v["npc"], lua_string(v["name"]), v["map"], v["x"], v["y"], v["side"],
                         lua_list(v["arrows"]), lua_list(v["bullets"])))
    lines.append("}\n")
    with open("VendorData.lua", "w", encoding="utf-8", newline="\n") as f:
        f.write("".join(lines))
    print("VendorData.lua: %d ammo vendors." % len(found))
    for s in skipped:
        print("  left out:", s)


if __name__ == "__main__":
    main()
