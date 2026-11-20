--@moods: low cheetah rowvendor rownone rownowhere
local T = dofile(wb.dir .. "/tests/_hunter.lua")
local m = wb.mood
T.hunter(m == "cheetah" and { 5118 } or {})
wb.state.bags[6948] = 1
wb.state.pos = { map = 1411, x = 0.50, y = 0.50 } -- Durotar, a Horde hunter
if m == "rownowhere" then wb.state.pos = { map = 999, x = 0.5, y = 0.5 } end -- inside an instance
wb.login()
wb.advance(2)
if m == "rowvendor" or m == "rownone" or m == "rownowhere" then
	-- the nearest ammo vendor, on the travel panel: a click sets the waypoint and closes the menu
	wb.ns.AMMO_VENDORS = m == "rownone" and {} or {
		{ npc = 1, name = "Near Bowyer", map = 1411, x = 0.52, y = 0.48, side = "H", arrows = { 2512 }, bullets = {} },
	}
	wb.ns.VendorsChanged()
	wb.openGameMenu()
	local row = wb.frame("PackboundTravelAction")
	wb.expect("the ammo row is on the panel", wb.shown("PackboundTravelAction"), true)
	if m == "rowvendor" then
		wb.expect("names the vendor", row.text:GetText(), "Ammo: Near Bowyer")
		wb.check(row.sub:GetText():find("^Durotar, %d+ yards$") ~= nil, "zone and distance underneath")
		row:GetScript("OnClick")(row, "LeftButton", false)
		wb.advance(0.1)
		wb.expect("a click sets the waypoint", wb.state.waypoint and wb.state.waypoint.uiMapID, 1411)
		wb.expect("and closes the game menu", wb.shown("GameMenuFrame"), false)
	elseif m == "rownowhere" then
		wb.expect("doesn't claim none is known", row.text:GetText(), "Ammo vendor: can't tell where you are")
		wb.expect("says why", row.sub:GetText(), "inside a dungeon? Look again outside")
	else
		wb.expect("says none is known here", row.text:GetText(), "Ammo vendor: none known here")
		wb.expect("and how the list fills", row.sub:GetText(), "open one and Packbound remembers it")
		row:GetScript("OnClick")(row, "LeftButton", false)
		wb.advance(0.1)
		wb.expect("a click sets nothing", wb.state.waypoint, nil)
	end
	return
end
wb.openGameMenu()
wb.expect("panel with the menu", wb.shown("PackboundTravel"), true)
local rows = wb.ns.TravelRows()
wb.expect("cheetah", rows[1].label, "Aspect of the Cheetah")
wb.expect("known", rows[1].known, m == "cheetah")
wb.expect("pack at 40", rows[2].level, 40)
