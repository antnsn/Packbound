-- The aspect card: no aspect up out of combat → click casts the chosen one (Hawk by default).
-- Cheetah and Pack count as travelling and don't nag. Trueshot Aura as a buff timer when known.
local _, ns = ...
if ns.disabled then return end
local D = ns.DATA

ns.ASPECT_CHOICES = { "Hawk", "Monkey", "Wild" }

local function Known(id)
	local ok, k = pcall(IsPlayerSpell, id)
	return ok and not ns.IsSecret(k) and k and true or false
end
local function AspectName(key) return ns.SpellName(D.aspects[key]) or ("Aspect of the " .. key) end

-- the aspect to cast: the chosen one when known, else Hawk, else Monkey; nil when none is known
function ns.AspectSpell()
	for _, k in ipairs({ ns.db.aspectChoice, "Hawk", "Monkey" }) do
		if D.aspects[k] and Known(D.aspects[k]) then return AspectName(k) end
	end
	return nil
end

local M = {}
ns.modules[#ns.modules + 1] = M
local card, overlay

function M:Update()
	if not card then return end
	if ns.unlocked then card:SetStatus("Click to cast"); card:Show(); card:Glow(false); if not InCombatLockdown() then overlay:Sync(nil) end return end
	local spell = ns.AspectSpell()
	local show = false
	if ns.db.aspect and spell and not ns.InCombat() and not IsMounted() then
		local buffs, hidden = ns.ReadPlayerBuffs()
		if not hidden then
			show = true
			for k in pairs(D.aspects) do if buffs[AspectName(k)] then show = false end end
		end
	end
	if show then
		card:SetTitle("No aspect")
		card:SetStatus("Click for " .. spell, true)
		card:Show(); card:Glow(true)
	else
		card:Glow(false); card:Hide()
	end
	if not InCombatLockdown() then overlay:Sync(show and spell or nil, "player", ns.Help.aspect) end
end

function M:Init()
	card = ns.MakeCard("PackboundAspectFrame")
	card:SetIcon(136076)
	card:SetTitle("No aspect")
	card:SetExplain(ns.Help.aspect)
	ns.MakeMovable(card, "asPoint")
	ns.ApplyPoint(card, "asPoint")
	overlay = ns.CastOverlay(card)
	local f = CreateFrame("Frame")
	for _, e in ipairs({ "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "SPELLS_CHANGED", "PLAYER_ENTERING_WORLD",
		"PLAYER_MOUNT_DISPLAY_CHANGED" }) do f:RegisterEvent(e) end
	f:RegisterUnitEvent("UNIT_AURA", "player")
	f:SetScript("OnEvent", function() M:Update() end)
	M:Update()
end

ns.MakeBuffTimer({
	key = "trueshot", point = "taPoint", frameName = "PackboundTrueshotFrame",
	label = "Trueshot Aura", icon = 132329,
	names = function() return { ns.SpellName(D.trueshot) or "Trueshot Aura" } end,
	active = function() return Known(D.trueshot) end,
	cast = function() return Known(D.trueshot) and ns.SpellName(D.trueshot) or nil end,
	explain = ns.Help.trueshot,
	goneText = "Missing: click to cast",
})
