-- The nearest ammo vendor: who sells arrows (bows, crossbows) or bullets (guns) closest to you,
-- on your side and your continent. The vendors come from Packbound's own list (VendorData.lua)
-- and from every merchant you open that sells ammo (learned, account-wide in PackboundDB.vendors:
-- a learned vendor wins over the list's entry for the same NPC, also when it sells no ammo).
-- ns.NearestAmmoVendor() -> { name, zone, map, x, y (0..1), yards } or nil, reason
-- ns.WaypointToAmmo()    sets a map waypoint (and a TomTom one, if TomTom is loaded) and says where
-- ns.VendorsChanged()    forget the worked-out vendor positions (the list changed)
-- ns.AmmoTravelRow()     the travel panel's row: the nearest vendor, a click sets the waypoint
local _, ns = ...
if ns.disabled then return end
local D = ns.DATA

local GUN = 3 -- weapon subclass that shoots bullets

-- pcall that hands back every result (GetItemInfoInstant's 7th is the weapon type), or nil
local function Safe(fn, ...)
	local r = { pcall(fn, ...) }
	if not r[1] then return nil end
	return unpack(r, 2, table.maxn(r))
end

local function AmmoKind()
	local id = Safe(GetInventoryItemID, "player", D.rangedSlot)
	if not id or ns.IsSecret(id) then return "arrows" end
	local _, _, _, _, _, _, subclassID = Safe(C_Item.GetItemInfoInstant, id)
	return subclassID == GUN and "bullets" or "arrows"
end
ns.AmmoKind = AmmoKind

local function Friendly(side)
	if side == "AH" then return true end
	local mine = Safe(UnitFactionGroup, "player")
	if ns.IsSecret(mine) then return false end
	return (mine == "Alliance" and side == "A") or (mine == "Horde" and side == "H")
end

-- every friendly vendor of that kind, with its world position; worked out once per kind
local cache = {}
function ns.VendorsChanged() cache = {} end

-- the list's entry for an NPC id, or nil
local function Listed(npc)
	for _, v in ipairs(ns.AMMO_VENDORS or {}) do
		if v.npc == npc then return v end
	end
end

-- the list with what was learned laid over it
local function Known()
	local learned = ns.db.vendors or {}
	local out = {}
	for _, v in ipairs(ns.AMMO_VENDORS or {}) do
		if not learned[v.npc] then out[#out + 1] = v end
	end
	for _, v in pairs(learned) do out[#out + 1] = v end
	return out
end

local function Vendors(kind)
	if cache[kind] then return cache[kind] end
	local out = {}
	for _, v in ipairs(Known()) do
		local sells = v[kind]
		if sells and #sells > 0 and Friendly(v.side) then
			local cont, world = Safe(C_Map.GetWorldPosFromMapPos, v.map, CreateVector2D(v.x, v.y))
			if world then
				local wx, wy = world:GetXY()
				out[#out + 1] = { name = v.name, map = v.map, x = v.x, y = v.y, cont = cont, wx = wx, wy = wy }
			end
		end
	end
	cache[kind] = out
	return out
end

local function Here()
	local map = Safe(C_Map.GetBestMapForUnit, "player")
	if not map or ns.IsSecret(map) then return nil end
	local pos = Safe(C_Map.GetPlayerMapPosition, map, "player")
	if not pos then return nil end
	local cont, world = Safe(C_Map.GetWorldPosFromMapPos, map, pos)
	if not world then return nil end
	local wx, wy = world:GetXY()
	return cont, wx, wy
end

function ns.NearestAmmoVendor()
	local cont, px, py = Here()
	if not cont then return nil, "nowhere" end
	local best, bestD
	for _, v in ipairs(Vendors(AmmoKind())) do
		if v.cont == cont then
			local d = (v.wx - px) ^ 2 + (v.wy - py) ^ 2
			if not bestD or d < bestD then best, bestD = v, d end
		end
	end
	if not best then return nil, "none" end
	local info = Safe(C_Map.GetMapInfo, best.map)
	return { name = best.name, zone = info and info.name or "?", map = best.map, x = best.x, y = best.y,
		yards = math.floor(math.sqrt(bestD) + 0.5) }
end

function ns.WaypointToAmmo()
	local v, why = ns.NearestAmmoVendor()
	if not v then
		ns.Print(({ nowhere = "can't tell where you are here (inside a dungeon?).",
			none = "no ammo vendor known on this continent yet: open one and Packbound remembers it." })[why]
			or "no ammo vendor found.")
		return
	end
	-- say "waypoint set" only for a waypoint that really was (the map's own, or TomTom's)
	local set = false
	if Safe(C_Map.CanSetUserWaypointOnMap, v.map) then
		local point = Safe(UiMapPoint.CreateFromCoordinates, v.map, v.x, v.y)
		if point and pcall(C_Map.SetUserWaypoint, point) then
			set = true
			pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
		end
	end
	local tomtom = rawget(_G, "TomTom")
	if type(tomtom) == "table" and type(tomtom.AddWaypoint) == "function" then
		local ok, uid = pcall(tomtom.AddWaypoint, tomtom, v.map, v.x, v.y, { title = v.name, from = "Packbound" })
		set = set or (ok and uid ~= nil)
	end
	ns.Print(("nearest ammo vendor: %s, %s (%.1f, %.1f), %d yards. %s"):format(
		v.name, v.zone, v.x * 100, v.y * 100, v.yards,
		set and "Waypoint set." or "No waypoint here: look for it on the map."))
end

-- the travel panel's ammo row (LibBound's action row)
function ns.AmmoTravelRow()
	local icon = AmmoKind() == "bullets" and 132384 or 132382
	local v, why = ns.NearestAmmoVendor()
	if not v and why == "nowhere" then
		return { icon = icon, label = "Ammo vendor: can't tell where you are", sub = "inside a dungeon? Look again outside",
			tip = "Nearest ammo vendor", help = ns.Help.ammoVendor }
	end
	if not v then
		return { icon = icon, label = "Ammo vendor: none known here", sub = "open one and Packbound remembers it",
			tip = "Nearest ammo vendor", help = ns.Help.ammoVendor }
	end
	return { icon = icon, label = "Ammo: " .. v.name, sub = ("%s, %d yards"):format(v.zone, v.yards),
		tip = "Nearest ammo vendor", help = ns.Help.ammoVendor, note = "Click for a waypoint.", click = ns.WaypointToAmmo }
end

-- a merchant window: remember an ammo vendor, and where it stands (you are next to it)
local AMMO = {}
for kind, ids in pairs(ns.AMMO_ITEMS) do
	for _, id in ipairs(ids) do AMMO[id] = kind end
end

local function Learn()
	local guid = Safe(UnitGUID, "npc")
	if type(guid) ~= "string" or ns.IsSecret(guid) then return end
	local unitType, _, _, _, _, id = strsplit("-", guid)
	local npc = tonumber(id)
	if (unitType ~= "Creature" and unitType ~= "Vehicle") or not npc then return end
	local map = Safe(C_Map.GetBestMapForUnit, "player")
	if not map or ns.IsSecret(map) then return end
	local pos = Safe(C_Map.GetPlayerMapPosition, map, "player")
	if not pos then return end
	local x, y = pos:GetXY()
	if ns.IsSecret(x) or ns.IsSecret(y) then return end
	if not select(2, Safe(C_Map.GetWorldPosFromMapPos, map, pos)) then return end -- an instance: no use for it
	local sells = { arrows = {}, bullets = {} }
	local n = Safe(GetMerchantNumItems) or 0
	if ns.IsSecret(n) or n == 0 then return end -- no wares (yet): nothing to learn or correct from
	for i = 1, n do
		local item = Safe(GetMerchantItemID, i)
		local kind = item and not ns.IsSecret(item) and AMMO[item]
		if kind then sells[kind][#sells[kind] + 1] = item end
	end
	local listed = Listed(npc)
	if #sells.arrows == 0 and #sells.bullets == 0 and not listed then return end -- not an ammo vendor
	local name = Safe(UnitName, "npc")
	if not name or ns.IsSecret(name) then name = listed and listed.name or "?" end
	local mine = Safe(UnitFactionGroup, "player")
	if ns.IsSecret(mine) then mine = nil end
	local side = listed and listed.side or (mine == "Alliance" and "A") or (mine == "Horde" and "H") or "AH"
	ns.db.vendors = ns.db.vendors or {}
	ns.db.vendors[npc] = { npc = npc, name = name, map = map, x = x, y = y, side = side,
		arrows = sells.arrows, bullets = sells.bullets, seen = time() }
	ns.VendorsChanged()
end

local f = CreateFrame("Frame")
f:RegisterEvent("MERCHANT_SHOW")
f:SetScript("OnEvent", Learn)
