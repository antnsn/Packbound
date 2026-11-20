-- The travel panel (LibBound) beside the game menu: Aspect of the Cheetah and of the Pack, the
-- nearest ammo vendor (click: waypoint), then the Hearthstone.
local _, ns = ...
if ns.disabled then return end
local Bound = LibStub("LibBound-1.0")

local function Known(id)
	local ok, k = pcall(IsPlayerSpell, id)
	return ok and not ns.IsSecret(k) and k and true or false
end

local ROWS = {
	{ key = "Cheetah", label = "Aspect of the Cheetah", level = 20 },
	{ key = "Pack", label = "Aspect of the Pack", level = 40 },
}
function ns.TravelRows()
	local out = {}
	for _, r in ipairs(ROWS) do
		local id = ns.DATA.aspects[r.key]
		out[#out + 1] = { spell = id, label = r.label, column = 1, known = Known(id), level = r.level,
			tip = r.label, help = ns.Help[r.key:lower()], learn = "from a hunter trainer" }
	end
	return out
end

Bound.InstallTravel(ns, { columns = { "HUNTER" }, rows = ns.TravelRows, hearthHelp = ns.Help.hearthstone,
	action = function() return ns.AmmoTravelRow() end })
