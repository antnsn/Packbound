-- Packbound's own ammo vendor list (VendorData.lua): every entry well-formed, and the low levels
-- covered on both sides: every starting zone and capital has a vendor, and the two lowest kinds
-- of arrows and bullets are sold somewhere on each side
local T = dofile(wb.dir .. "/tests/_hunter.lua")
T.hunter({ 883 })
wb.login()
local ns = wb.ns
local list, items = ns.AMMO_VENDORS, ns.AMMO_ITEMS
local AMMO = {}
for kind, ids in pairs(items) do for _, id in ipairs(ids) do AMMO[id] = kind end end

local seen, bad = {}, {}
for i, v in ipairs(list) do
	local function no(why) bad[#bad + 1] = ("#%d %s: %s"):format(i, tostring(v.name), why) end
	if type(v.npc) ~= "number" then no("npc id") elseif seen[v.npc] then no("npc listed twice") end
	seen[v.npc or i] = true
	if type(v.name) ~= "string" or v.name == "" then no("name") end
	if type(v.map) ~= "number" then no("map") end
	if type(v.x) ~= "number" or v.x <= 0 or v.x >= 1 or type(v.y) ~= "number" or v.y <= 0 or v.y >= 1 then no("x, y") end
	if v.side ~= "A" and v.side ~= "H" and v.side ~= "AH" then no("side") end
	local n = 0
	for _, kind in ipairs({ "arrows", "bullets" }) do
		if type(v[kind]) ~= "table" then no(kind .. " list") else
			for _, id in ipairs(v[kind]) do
				n = n + 1
				if AMMO[id] ~= kind then no(("item %s is not %s"):format(tostring(id), kind)) end
			end
		end
	end
	if n == 0 then no("sells no ammo") end
end
wb.expect("every entry well-formed", table.concat(bad, "; "), "")

local function forSide(v, side) return v.side == side or v.side == "AH" end
local AREAS = {
	A = { [1429] = "Elwynn Forest", [1426] = "Dun Morogh", [1438] = "Teldrassil",
		[1453] = "Stormwind", [1455] = "Ironforge", [1457] = "Darnassus" },
	H = { [1411] = "Durotar", [1412] = "Mulgore", [1420] = "Tirisfal Glades",
		[1454] = "Orgrimmar", [1456] = "Thunder Bluff", [1458] = "Undercity" },
}
for side, areas in pairs(AREAS) do
	for map, zone in pairs(areas) do
		local found = false
		for _, v in ipairs(list) do if v.map == map and forSide(v, side) then found = true end end
		wb.check(found, ("%s: an ammo vendor in %s"):format(side, zone))
	end
	for _, item in ipairs({ 2512, 2516, 2515, 2519 }) do
		local found = false
		for _, v in ipairs(list) do
			if forSide(v, side) then
				for _, id in ipairs(v[AMMO[item]] or {}) do if id == item then found = true end end
			end
		end
		wb.check(found, ("%s: item %d sold somewhere"):format(side, item))
	end
end
