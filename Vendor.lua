-- The nearest ammo vendor: who sells arrows (bows, crossbows) or bullets (guns) closest to you,
-- on your side and your continent. The data comes from Questie's database while Questie is
-- loaded (it knows who sells what, and where); Questie is GPL, so it is asked at run time and
-- nothing of it is copied into Packbound. Without Questie there is no vendor line.
-- ns.NearestAmmoVendor() -> { name, zone, map, x, y (0..1), yards } or nil, reason
-- ns.WaypointToAmmo()    sets a map waypoint (and a TomTom one, if TomTom is loaded) and says where
local _, ns = ...
if ns.disabled then return end
local D = ns.DATA

-- Classic ammo sold by vendors, lowest level first
local ARROWS = { 2512, 2515, 3030, 11285 }  -- Rough, Sharp, Razor, Jagged Arrow
local BULLETS = { 2516, 2519, 3033, 11284 } -- Light Shot, Heavy Shot, Solid Shot, Accurate Slugs
local GUN = 3                               -- weapon subclass that shoots bullets

-- pcall that hands back every result (GetItemInfoInstant's 7th is the weapon type), or nil
local function Safe(fn, ...)
	local r = { pcall(fn, ...) }
	if not r[1] then return nil end
	return unpack(r, 2, table.maxn(r))
end

-- Questie's QuestieDB and ZoneDB modules, or nil
local function Questie()
	local loader = rawget(_G, "QuestieLoader")
	if type(loader) ~= "table" or type(loader.ImportModule) ~= "function" then return nil end
	local db = Safe(loader.ImportModule, loader, "QuestieDB")
	local zones = Safe(loader.ImportModule, loader, "ZoneDB")
	if type(db) ~= "table" or type(zones) ~= "table" or type(db.QueryItemSingle) ~= "function"
		or type(db.QueryNPCSingle) ~= "function" or type(zones.GetUiMapIdByAreaId) ~= "function" then
		return nil
	end
	return db, zones
end
function ns.HasVendorData() return Questie() ~= nil end

local function AmmoKind()
	local id = Safe(GetInventoryItemID, "player", D.rangedSlot)
	if not id or ns.IsSecret(id) then return "arrows" end
	local _, _, _, _, _, _, subclassID = Safe(C_Item.GetItemInfoInstant, id)
	return subclassID == GUN and "bullets" or "arrows"
end

local function Friendly(db, faction)
	if type(db.IsFriendlyToPlayer) == "function" then
		local ok, yes = pcall(db.IsFriendlyToPlayer, faction)
		if ok then return yes and true or false end
	end
	local mine = Safe(UnitFactionGroup, "player")
	return faction == nil or faction == "AH" or (mine == "Alliance" and faction == "A") or (mine == "Horde" and faction == "H")
end

-- every spawn of every friendly vendor of that kind, with its world position; built once per kind
-- (only when Questie answered: its database may still be loading right after login)
local cache = {}
local function Vendors(kind)
	if cache[kind] then return cache[kind] end
	local db, zones = Questie()
	if not db then return nil end
	local out, seen = {}, {}
	for _, item in ipairs(kind == "bullets" and BULLETS or ARROWS) do
		for _, npc in ipairs(Safe(db.QueryItemSingle, item, "vendors") or {}) do
			if not seen[npc] then
				seen[npc] = true
				local name = Safe(db.QueryNPCSingle, npc, "name")
				local spawns = Safe(db.QueryNPCSingle, npc, "spawns")
				if name and type(spawns) == "table" and Friendly(db, Safe(db.QueryNPCSingle, npc, "friendlyToFaction")) then
					for area, points in pairs(spawns) do
						local map = Safe(zones.GetUiMapIdByAreaId, zones, area)
						for _, p in ipairs(map and points or {}) do
							local x, y = p[1] and p[1] / 100, p[2] and p[2] / 100
							local cont, world = Safe(C_Map.GetWorldPosFromMapPos, map, CreateVector2D(x or 0, y or 0))
							if x and y and world then
								local wx, wy = world:GetXY()
								out[#out + 1] = { name = name, map = map, x = x, y = y, cont = cont, wx = wx, wy = wy }
							end
						end
					end
				end
			end
		end
	end
	if #out > 0 then cache[kind] = out end
	return out
end

local function Here()
	local map = Safe(C_Map.GetBestMapForUnit, "player")
	if not map then return nil end
	local pos = Safe(C_Map.GetPlayerMapPosition, map, "player")
	if not pos then return nil end
	local cont, world = Safe(C_Map.GetWorldPosFromMapPos, map, pos)
	if not world then return nil end
	local wx, wy = world:GetXY()
	return cont, wx, wy
end

function ns.NearestAmmoVendor()
	if not Questie() then return nil, "noquestie" end
	local list = Vendors(AmmoKind())
	if not list or #list == 0 then return nil, "none" end
	local cont, px, py = Here()
	if not cont then return nil, "nowhere" end
	local best, bestD
	for _, v in ipairs(list) do
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
		ns.Print(({ noquestie = "finding an ammo vendor needs Questie (it knows where the vendors are).",
			nowhere = "can't tell where you are here (inside a dungeon?).",
			none = "no ammo vendor on this continent in Questie's data." })[why] or "no ammo vendor found.")
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
