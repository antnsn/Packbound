--@moods: near gun faction click dungeon nowaypoint none
-- the nearest ammo vendor, from Packbound's own list (a test list here): on your side, on your
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

wb.ns.AMMO_VENDORS = m == "none" and {} or {
	{ npc = 1, name = "Near Bowyer", map = 1411, x = 0.52, y = 0.48, side = "H", arrows = { 2512 }, bullets = {} },
	{ npc = 2, name = "Far Bowyer", map = 1411, x = 0.90, y = 0.90, side = "H", arrows = { 2512, 2515 }, bullets = {} },
	{ npc = 3, name = "Alliance Bowyer", map = 1411, x = 0.50, y = 0.51, side = "A", arrows = { 2512 }, bullets = {} },
	{ npc = 4, name = "Gunsmith", map = 1411, x = 0.70, y = 0.70, side = "AH", arrows = {}, bullets = { 2516 } },
	{ npc = 5, name = "Elwynn Bowyer", map = 1429, x = 0.50, y = 0.50, side = "AH", arrows = { 2512 }, bullets = {} },
}
wb.ns.VendorsChanged()
wb.advance(6) -- the card looks again every 5 seconds
local card = wb.frame("PackboundAmmoFrame")
wb.expect("ammo card", wb.shown("PackboundAmmoFrame"), true)
wb.expect("title", card.titleText:GetText(), "Ammo: 50 left")
local status = card.statusText:GetText()
if m == "near" then
	wb.expect("the nearest friendly vendor", status, "Nearest: Near Bowyer, Durotar (click: waypoint)")
elseif m == "faction" then
	wb.check(not status:find("Alliance Bowyer", 1, true), "never the other side's vendor, though it stands closest")
	wb.slash("/pack ammo")
	wb.check(not wb.printed("Alliance Bowyer"), "not on /pack ammo either")
elseif m == "gun" then
	wb.expect("bullets for a gun", status, "Nearest: Gunsmith, Durotar (click: waypoint)")
elseif m == "dungeon" then
	wb.expect("no position (a dungeon): no vendor line", status, "Running low")
elseif m == "none" then
	wb.expect("no vendor known: no vendor line", status, "Running low")
	wb.slash("/pack ammo")
	wb.check(wb.printed("no ammo vendor known on this continent"), "/pack ammo says none is known here")
	wb.check(not wb.printed("Questie"), "and never asks for Questie")
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
