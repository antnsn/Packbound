-- Ammo vendors Packbound knows from the start, looked up by hand (Wowhead Classic) and written
-- here: { npc = NPC id, name, map = uiMapID, x, y (0..1 on that map), side = "A" | "H" | "AH",
-- arrows = { item IDs sold }, bullets = { item IDs sold } }. Vendors met in play are learned
-- (Vendor.lua) and win over an entry here with the same npc.
local _, ns = ...
if ns.disabled then return end

-- the ammo vendors sell, lowest level first
ns.AMMO_ITEMS = {
	arrows = { 2512, 2515, 3030, 11285 },  -- Rough, Sharp, Razor, Jagged Arrow
	bullets = { 2516, 2519, 3033, 11284 }, -- Light Shot, Heavy Shot, Solid Shot, Accurate Slugs
}

ns.AMMO_VENDORS = {
}
