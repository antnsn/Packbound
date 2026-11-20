-- Packbound's option pages; LibBound adds Extras and Skin, and builds the window.
local _, ns = ...
if ns.disabled then return end
local Bound = LibStub("LibBound-1.0")

local function PetPage(UI)
	local p = UI.NewPage("Pet & ammo", "Your pet and your arrows or bullets.")
	local W = UI.CONTENT_W
	p:Add(select(2, UI.DBToggle(p, 0, p.y, W, "pet", "Watch my pet",
		"Call it when it isn't out, revive it when it died, feed it when it's hungry. Click the card.")) + 6)
	p:Add(select(2, UI.DBToggle(p, 0, p.y, W, "petContent", "Feed it when it's only content too",
		"A happy pet does the most damage.")) + 10)
	p:Add(select(2, UI.DBToggle(p, 0, p.y, W, "ammo", "Warn when ammo runs low")) + 6)
	p:Add(select(2, UI.Slider(p, p.y, "Ammo: warn at", "ammoLow", 0, 1000, 50, " left")) + 8)
end

local function AspectPage(UI)
	local p = UI.NewPage("Aspects", "A card when no aspect is up; Cheetah and Pack count as travelling.")
	local W = UI.CONTENT_W
	p:Add(select(2, UI.DBToggle(p, 0, p.y, W, "aspect", "Warn when no aspect is up")) + 6)
	p:Add(select(2, UI.Cycle(p, p.y, "Aspect to cast", ns.ASPECT_CHOICES,
		function() return ns.db.aspectChoice end,
		function(v) ns.db.aspectChoice = v end,
		function() local s = ns.AspectSpell() return s and ("Now: " .. s) or "No aspect learned yet (Hawk at level 10)." end)) + 10)
	p:Add(UI.Section(p, p.y, "Trueshot Aura") + 2)
	local third = math.floor(W / 3)
	UI.DBToggle(p, 0, p.y, third, "trueshot", "Show")
	UI.DBToggle(p, third, p.y, third, "trueshotSound", "Sound")
	UI.DBToggle(p, third * 2, p.y, third, "trueshotKeep", "When missing", nil, function() ns.UpdateBuffTimers() end)
	p:Add(32)
	p:Add(UI.Note(p, p.y, "A Marksmanship talent: the card only shows once you have it."))
end

local function TravelPage(UI)
	local p = UI.NewPage("Travel", "Aspect of the Cheetah, of the Pack and your Hearthstone beside the game menu (Escape).")
	p:Add(select(2, UI.DBToggle(p, 0, p.y, UI.CONTENT_W, "travel", "Show the travel panel when the game menu opens")) + 8)
end

ns.optionPages[#ns.optionPages + 1] = PetPage
ns.optionPages[#ns.optionPages + 1] = AspectPage
ns.optionPages[#ns.optionPages + 1] = TravelPage
Bound.InstallOptions(ns, { header = "Hunter helper", launcher = "Hunter helper: pet, ammo, aspects." })
