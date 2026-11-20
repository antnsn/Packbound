-- The ammo card: arrows or bullets in the ammo slot run low (urgent at none), only with a bow, gun
-- or crossbow equipped. Quiet in combat.
local _, ns = ...
if ns.disabled then return end
local D = ns.DATA

local function Safe(fn, ...)
	local ok, a, b, c, d, e, f, g = pcall(fn, ...)
	if not ok then return nil end
	return a, b, c, d, e, f, g
end

-- does the ranged slot hold a weapon that shoots ammo
function ns.UsesAmmo()
	local id = Safe(GetInventoryItemID, "player", D.rangedSlot)
	if not id or ns.IsSecret(id) then return false end
	local _, _, _, _, _, classID, subclassID = Safe(C_Item.GetItemInfoInstant, id)
	return classID == 2 and D.ammoWeapons[subclassID] == true
end

function ns.AmmoCount()
	local n = Safe(GetInventoryItemCount, "player", D.ammoSlot)
	if ns.IsSecret(n) then return nil end
	return n or 0
end

local M = {}
ns.modules[#ns.modules + 1] = M
local card

function M:Update()
	if not card then return end
	if ns.unlocked then card:SetStatus("150 left"); card:Show(); card:Glow(false) return end
	local n = ns.AmmoCount()
	if ns.db.ammo and n and n <= ns.db.ammoLow and ns.UsesAmmo() and not ns.InCombat() then
		card:SetStatus(n == 0 and "None left: buy arrows or bullets" or (n .. " left"), n == 0)
		card:Show(); card:Glow(true)
	else
		card:Glow(false); card:Hide()
	end
end

function M:Init()
	card = ns.MakeCard("PackboundAmmoFrame")
	card:SetIcon(132382)
	card:SetTitle("Ammo")
	card:SetExplain(ns.Help.ammo)
	ns.MakeMovable(card, "amPoint")
	ns.ApplyPoint(card, "amPoint")
	local f = CreateFrame("Frame")
	for _, e in ipairs({ "PLAYER_EQUIPMENT_CHANGED", "BAG_UPDATE_DELAYED", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED",
		"PLAYER_ENTERING_WORLD" }) do f:RegisterEvent(e) end
	f:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
	f:SetScript("OnEvent", function() M:Update() end)
	M:Update()
end
