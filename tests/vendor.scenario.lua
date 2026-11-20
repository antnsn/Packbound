--@moods: noquestie near gun click dungeon nowaypoint
-- the nearest ammo vendor, from (a stand-in for) Questie's database: on your side, on your
-- continent, arrows for a bow and bullets for a gun; a click on the card sets a waypoint
local T = dofile(wb.dir .. "/tests/_hunter.lua")
local m = wb.mood
T.hunter({ 883 })
local s = wb.state
s.ammo = 50 -- low (warns at 200)
s.pos = { map = 1411, x = 0.50, y = 0.50 } -- Durotar, a Horde hunter
if m == "gun" then
	s.slots[18] = 2508
	s.items[2508] = { name = "Old Blunderbuss", classID = 2, subclassID = 3 }
end
if m == "dungeon" then s.pos = { map = 999, x = 0.5, y = 0.5 } end
wb.login()

-- Questie: item -> vendors, npc -> name / side / spawns ({ [areaId] = { { x, y } } }, 0..100)
local NPCS = {
	[1] = { name = "Near Bowyer", friendlyToFaction = "H", spawns = { [14] = { { 52, 48 } } } },
	[2] = { name = "Far Bowyer", friendlyToFaction = "H", spawns = { [14] = { { 90, 90 } } } },
	[3] = { name = "Alliance Bowyer", friendlyToFaction = "A", spawns = { [14] = { { 50, 51 } } } },
	[4] = { name = "Gunsmith", friendlyToFaction = "AH", spawns = { [14] = { { 70, 70 } } } },
	[5] = { name = "Elwynn Bowyer", friendlyToFaction = "AH", spawns = { [12] = { { 50, 50 } } } },
}
local VENDORS = { [2512] = { 1, 2, 3, 5 }, [2516] = { 4 } }
local AREA = { [14] = 1411, [12] = 1429 }
if m ~= "noquestie" then
	local db = {
		QueryItemSingle = function(id, key) if key == "vendors" then return VENDORS[id] end end,
		QueryNPCSingle = function(id, key) return NPCS[id] and NPCS[id][key] end,
	}
	local zones = { GetUiMapIdByAreaId = function(_, area) return AREA[area] end }
	wb.G.QuestieLoader = { ImportModule = function(_, name) return ({ QuestieDB = db, ZoneDB = zones })[name] end }
end
wb.advance(6) -- the card looks again every 5 seconds
local card = wb.frame("PackboundAmmoFrame")
wb.expect("ammo card", wb.shown("PackboundAmmoFrame"), true)
wb.expect("title", card.titleText:GetText(), "Ammo: 50 left")
local status = card.statusText:GetText()
if m == "noquestie" then
	wb.expect("no vendor line without Questie", status, "Running low")
	wb.slash("/pack ammo")
	wb.check(wb.printed("needs Questie"), "/pack ammo says it needs Questie")
elseif m == "near" then
	wb.expect("the nearest friendly vendor", status, "Nearest: Near Bowyer, Durotar (click: waypoint)")
elseif m == "gun" then
	wb.expect("bullets for a gun", status, "Nearest: Gunsmith, Durotar (click: waypoint)")
elseif m == "dungeon" then
	wb.expect("no position (a dungeon): no vendor line", status, "Running low")
elseif m == "nowaypoint" then
	wb.state.maps[1411].mapType = 2 -- a map that takes no waypoints, and no TomTom
	card:GetScript("OnMouseUp")(card, "LeftButton")
	wb.expect("no waypoint", s.waypoint, nil)
	wb.check(wb.printed("No waypoint here"), "says so instead of claiming one")
	wb.check(not wb.printed("Waypoint set"), "and doesn't say one was set")
elseif m == "click" then
	card:GetScript("OnMouseUp")(card, "LeftButton")
	local w = s.waypoint
	wb.check(w ~= nil, "a waypoint is set")
	wb.expect("on the vendor's map", w and w.uiMapID, 1411)
	wb.expect("at the vendor", w and math.floor(w.position.x * 100 + 0.5), 52)
	wb.expect("and tracked", s.superTracked, true)
	wb.check(wb.printed("Near Bowyer, Durotar %(52.0, 48.0%)"), "says where")
	wb.expect("the card takes clicks", card.__clicks, true)
	wb.slash("/pack unlock"); wb.slash("/pack lock")
	wb.expect("and still does after moving the frames", card.__clicks and card:IsMouseEnabled(), true)
end
