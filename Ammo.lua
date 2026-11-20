-- The ammo card: arrows or bullets in the ammo slot run low (urgent at none), only with a bow, gun
-- or crossbow equipped. Quiet in combat. It also names the nearest ammo vendor (Vendor.lua), and a
-- click on the card sets a waypoint to it.
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
	if ns.unlocked then card:SetTitle("Ammo: 150 left"); card:SetStatus("Nearest: a vendor near you"); card:Show(); card:Glow(false) return end
	local n = ns.AmmoCount()
	if ns.db.ammo and n and n <= ns.db.ammoLow and ns.UsesAmmo() and not ns.InCombat() then
		local v = ns.NearestAmmoVendor()
		card:SetTitle(n == 0 and "No ammo left" or ("Ammo: " .. n .. " left"))
		if v then
			card:SetStatus(("Nearest: %s, %s (click: waypoint)"):format(v.name, v.zone), n == 0)
		else
			card:SetStatus(n == 0 and "Buy arrows or bullets" or "Running low", n == 0)
		end
		card:Show(); card:Glow(true)
	else
		card:Glow(false); card:Hide()
	end
end

function M:Init()
	card = ns.MakeCard("PackboundAmmoFrame", { width = 300, clickable = true })
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
	-- a click sets a waypoint to the nearest ammo vendor (not while moving the frames)
	card:SetScript("OnMouseUp", function(_, button)
		if button == "LeftButton" and not ns.unlocked and card:IsShown() then ns.WaypointToAmmo() end
	end)
	-- the nearest vendor changes as you travel
	C_Timer.NewTicker(5, function() if card:IsShown() then M:Update() end end)
	M:Update()
end
