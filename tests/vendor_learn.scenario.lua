--@moods: learned corrected moved notcreature indungeon
-- Packbound learns ammo vendors from the merchant window: who sells arrows or bullets, and where
-- they stand on Forever; a visit corrects a list entry that sells no ammo or stands elsewhere
local T = dofile(wb.dir .. "/tests/_hunter.lua")
local m = wb.mood
T.hunter({ 883 })
local s = wb.state
s.ammo = 50 -- low (warns at 200)
s.pos = { map = 1411, x = 0.50, y = 0.50 } -- Durotar, a Horde hunter
wb.login()

local LIST = {
	{ npc = 1, name = "Near Bowyer", map = 1411, x = 0.52, y = 0.48, side = "H", arrows = { 2512 }, bullets = {} },
	{ npc = 2, name = "Far Bowyer", map = 1411, x = 0.90, y = 0.90, side = "H", arrows = { 2512 }, bullets = {} },
}
local function useList(list) wb.ns.AMMO_VENDORS = list wb.ns.VendorsChanged() end
useList(m == "learned" and { LIST[2] } or LIST)

-- the merchant window: the npc unit and what it sells (the stub has neither)
local npc, wares = nil, {}
local G = wb.G
local guid, name = G.UnitGUID, G.UnitName
G.UnitGUID = function(u) if u == "npc" then return npc and npc.guid end return guid(u) end
G.UnitName = function(u) if u == "npc" then return npc and npc.name end return name(u) end
G.GetMerchantNumItems = function() return #wares end
G.GetMerchantItemID = function(i) return wares[i] end
local function visit(id, who, items, at)
	npc = { guid = type(id) == "string" and id or ("Creature-0-1-1-1-" .. id .. "-00001"), name = who }
	wares = items
	if at then s.pos = at end
	wb.fire("MERCHANT_SHOW")
	s.pos = { map = 1411, x = 0.50, y = 0.50 } -- walk back to where the tests stand
	wb.fire("MERCHANT_CLOSED")
end
local function status()
	wb.advance(6)
	return wb.frame("PackboundAmmoFrame").statusText:GetText()
end
local function vendors() return (wb.saved("PackboundDB") or {}).vendors or {} end

if m == "learned" then
	visit(9999, "New Bowyer", { 117, 2512 }, { map = 1411, x = 0.60, y = 0.40 })
	wb.expect("learned what it sells (ammo only)", vendors()[9999] and table.concat(vendors()[9999].arrows, ","), "2512")
	wb.expect("and where it stands", vendors()[9999] and vendors()[9999].x, 0.60)
	wb.expect("the learned vendor is the nearest", status(), "Nearest: New Bowyer, Durotar (click: waypoint)")
	wb.reload()
	useList({ LIST[2] })
	wb.expect("still known after /reload", status(), "Nearest: New Bowyer, Durotar (click: waypoint)")
elseif m == "corrected" then
	wb.expect("before the visit: the list's nearest", status(), "Nearest: Near Bowyer, Durotar (click: waypoint)")
	visit(1, "Near Bowyer", { 117 }, { map = 1411, x = 0.52, y = 0.48 })
	wb.expect("stored as selling no arrows", vendors()[1] and #vendors()[1].arrows, 0)
	wb.expect("never offered again", status(), "Nearest: Far Bowyer, Durotar (click: waypoint)")
elseif m == "moved" then
	visit(1, "Near Bowyer", { 2512 }, { map = 1411, x = 0.80, y = 0.20 })
	wb.slash("/pack ammo")
	wb.expect("the waypoint goes where it really stands", s.waypoint and math.floor(s.waypoint.position.x * 100 + 0.5), 80)
elseif m == "notcreature" then
	visit("Player-1-0ABC", "Somebody", { 2512 })
	wb.expect("a player's shop is not learned", next(vendors()), nil)
elseif m == "indungeon" then
	visit(9999, "Deep Bowyer", { 2512 }, { map = 999, x = 0.5, y = 0.5 })
	wb.expect("no position: nothing stored", next(vendors()), nil)
end
