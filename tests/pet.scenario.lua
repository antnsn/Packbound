--@moods: fresh nopet dead despawned diedinfight hungry nofood happy content combat mounted
local T = dofile(wb.dir .. "/tests/_hunter.lua")
local m = wb.mood
T.hunter(m == "fresh" and {} or { 883, 982, 6991 })
local s = wb.state
if m == "dead" or m == "despawned" then s.pet = { name = "Wolf", dead = true } end
if m == "diedinfight" then s.pet = { name = "Wolf", happiness = 3 } end
if m == "hungry" or m == "nofood" or m == "content" then s.pet = { name = "Wolf", happiness = m == "content" and 2 or 1 } end
if m == "happy" or m == "combat" or m == "mounted" or m == "fresh" then s.pet = { name = "Wolf", happiness = 3 } end
if m == "combat" or m == "mounted" then s.pet = nil end
if m == "nofood" then s.items[117].petFood = false end
s.bags[117] = 5
wb.login({ saved = { PackboundDB = { petContent = m == "content" } } })
wb.advance(3)
local shown = wb.shown("PackboundPetFrame")
local card = wb.frame("PackboundPetFrame")
local function Title() return card.titleText:GetText() end
if m == "fresh" or m == "happy" then
	wb.expect("nothing to do", shown, false)
elseif m == "nopet" then
	wb.expect("call card", Title(), "Call your pet")
	wb.check(T.macroFor("[nopet] Call Pet"), "a click calls it (or revives it if it died)")
	s.pet = { name = "Wolf", happiness = 3 }
	wb.fire("UNIT_PET", "player")
	wb.expect("gone once it's out", wb.shown("PackboundPetFrame"), false)
elseif m == "despawned" then
	wb.expect("dead", Title(), "Your pet is dead")
	s.pet = nil -- the corpse is gone
	wb.fire("UNIT_PET", "player")
	wb.reload() -- and even after a /reload
	wb.advance(3)
	wb.expect("still knows it is dead", wb.frame("PackboundPetFrame").titleText:GetText(), "Your pet is dead")
	wb.check(T.macroFor("/cast Revive Pet"), "a click revives it, not Call Pet")
	s.pet = { name = "Wolf", happiness = 3 }
	wb.fire("UNIT_PET", "player")
	wb.advance(3)
	wb.expect("alive again: no card", wb.shown("PackboundPetFrame"), false)
	s.pet = nil
	wb.fire("UNIT_PET", "player")
	wb.advance(3)
	wb.expect("dismissed (alive): call it", wb.frame("PackboundPetFrame").titleText:GetText(), "Call your pet")
elseif m == "diedinfight" then
	wb.combat(true)
	s.pet = { name = "Wolf", dead = true }
	wb.fire("UNIT_PET", "player")
	wb.advance(1)
	s.pet = nil -- the corpse goes before the fight ends
	wb.fire("UNIT_PET", "player")
	wb.combat(false)
	wb.advance(3)
	wb.expect("dead after the fight", wb.frame("PackboundPetFrame").titleText:GetText(), "Your pet is dead")
	wb.check(T.macroFor("/cast Revive Pet"), "and the click revives it")
elseif m == "dead" then
	wb.expect("revive card", Title(), "Your pet is dead")
	wb.check(T.macroFor("/cast Revive Pet"), "a click revives it")
elseif m == "hungry" or m == "content" then
	wb.expect("a card that says to feed it", Title(), "Feed your pet")
	wb.expect("and why", wb.frame("PackboundPetFrame").statusText:GetText(),
		m == "content" and "Content: click to feed" or "Unhappy: click to feed")
	wb.check(T.macroFor("/cast Feed Pet\n/use item:117"), "a click feeds it the jerky")
	wb.slash("/pack pet")
	wb.check(wb.printed(m == "content" and "happiness: content" or "happiness: unhappy"), "/pack pet says what it sees")
	wb.check(wb.printed("Tough Jerky"), "and the food it would use")
elseif m == "nofood" then
	wb.expect("feed card, but", Title(), "Feed your pet")
	wb.expect("says there is no food", card.statusText:GetText(), "No food it eats in your bags")
elseif m == "combat" then
	wb.combat(true)
	wb.advance(3)
	wb.expect("quiet in combat", wb.shown("PackboundPetFrame"), false)
	wb.combat(false)
	wb.advance(3)
	wb.expect("back after", wb.shown("PackboundPetFrame"), true)
elseif m == "mounted" then
	wb.mount(true)
	wb.advance(3)
	wb.expect("quiet while mounted", wb.shown("PackboundPetFrame"), false)
end
