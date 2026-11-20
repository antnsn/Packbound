-- shared setup: a hunter with the given spells known and a bow equipped (loaded with dofile)
local M = {}
local NAMES = {
	[883] = "Call Pet", [982] = "Revive Pet", [6991] = "Feed Pet", [13165] = "Aspect of the Hawk",
	[13163] = "Aspect of the Monkey", [5118] = "Aspect of the Cheetah", [13159] = "Aspect of the Pack",
	[20043] = "Aspect of the Wild", [13161] = "Aspect of the Beast", [19506] = "Trueshot Aura", [429959] = "Well-Rested",
}
function M.hunter(known)
	local s = wb.state
	s.player.classFile, s.player.class, s.player.classId = "HUNTER", "Hunter", 3
	for _, id in ipairs(known or {}) do s.spells[id] = NAMES[id] end
	s.spells[429959] = "Well-Rested"
	for id, n in pairs(NAMES) do if not s.spells[id] then s.known[id] = false end end
	s.slots[18] = 2504 -- a bow
	s.items[2504] = { name = "Worn Shortbow", classID = 2, subclassID = 2 }
	s.items[117] = { name = "Tough Jerky", petFood = true }
	s.ammo = 1000
end
function M.macroFor(text)
	for _, f in ipairs(wb.frames()) do
		local m = f:GetAttribute("macrotext")
		if m and f.__shown and m:find(text, 1, true) then return f end
	end
end
return M
