-- Packbound: the Hunter addon of the Bound family, built on LibBound-1.0 (the shared core).
-- This file sets the addon up; every other file returns at once on a non-hunter (ns.disabled).
local addonName, ns = ...
local Bound = LibStub("LibBound-1.0")

-- Classic IDs; Forever follows Classic content. Checked in game before each release.
ns.DATA = {
	callPet = 883, revivePet = 982, feedPet = 6991,
	aspects = {
		Hawk = 13165, Monkey = 13163, Wild = 20043, Beast = 13161, Cheetah = 5118, Pack = 13159,
	},
	trueshot = 19506,
	ammoSlot = 0, rangedSlot = 18,
	-- weapon subclasses that shoot ammo: bows, guns, crossbows
	ammoWeapons = { [2] = true, [3] = true, [18] = true },
}

ns.disabled = Bound:NewAddon(addonName, ns, {
	class = "HUNTER",
	title = "Packbound",
	prefix = "d9a35a",
	db = "PackboundDB",
	slash = { "/pack", "/packbound" },
	commands = {
		ammo = { fn = function() if ns.WaypointToAmmo then ns.WaypointToAmmo() end end,
			help = "set a waypoint to the nearest ammo vendor (needs Questie)" },
	},
	media = "Interface\\AddOns\\Packbound\\Media\\",
	defaults = {
		skin = "wild",
		pet = true, petContent = false, petDied = {}, -- character -> true while the pet is dead -- warn when the pet is only content, not just unhappy
		ptPoint = { "CENTER", "UIParent", "CENTER", -250, 200 },
		ammo = true, ammoLow = 200,
		amPoint = { "CENTER", "UIParent", "CENTER", 250, 200 },
		aspect = true, aspectChoice = "Hawk",
		asPoint = { "CENTER", "UIParent", "CENTER", -250, 140 },
		trueshot = true, trueshotMinutes = 1, trueshotSound = false, trueshotIcon = true, trueshotKeep = true,
		taPoint = { "CENTER", "UIParent", "CENTER", 250, 140 },
		wrPoint = { "CENTER", "UIParent", "CENTER", 0, 320 },
		wfPoint = { "CENTER", "UIParent", "CENTER", 0, 260 },
	},
})
