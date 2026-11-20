-- The nearest ammo vendor: who sells arrows (bows, crossbows) or bullets (guns) closest to you,
-- on your side and your continent. The vendors come from Packbound's own list (VendorData.lua).
-- ns.NearestAmmoVendor() -> { name, zone, map, x, y (0..1), yards } or nil, reason
-- ns.WaypointToAmmo()    sets a map waypoint (and a TomTom one, if TomTom is loaded) and says where
-- ns.VendorsChanged()    forget the worked-out vendor positions (the list changed)
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

local function Vendors(kind)
	if cache[kind] then return cache[kind] end
	local out = {}
	for _, v in ipairs(ns.AMMO_VENDORS or {}) do
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
ns.VendorHere = Here

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
