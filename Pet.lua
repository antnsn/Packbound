-- The pet card: no pet out → call it; pet dead → revive it; pet hungry → feed it a food from the
-- bags it can eat (or say there is none). One card, one click (out of combat). Quiet in combat
-- and while mounted. Nothing before Call Pet is learned.
local _, ns = ...
if ns.disabled then return end
local D = ns.DATA

local function Known(id)
	local ok, k = pcall(IsPlayerSpell, id)
	return ok and not ns.IsSecret(k) and k and true or false
end
local function Safe(fn, ...)
	local ok, v = pcall(fn, ...)
	if not ok or ns.IsSecret(v) then return nil end
	return v
end

-- the first food in the bags the pet can eat: item ID, or nil
function ns.PetFood()
	if not (C_PetInfo and C_PetInfo.CanPetEatItem) then return nil end
	for bag = 0, 4 do
		local n = Safe(C_Container.GetContainerNumSlots, bag) or 0
		for slot = 1, n do
			local id = Safe(C_Container.GetContainerItemID, bag, slot)
			if id and Safe(C_PetInfo.CanPetEatItem, id) then return id end
		end
	end
	return nil
end

-- a pet seen dead stays "dead" until it is out alive again: its corpse can despawn (or you zone),
-- and then only Revive Pet brings it back. Saved per character, so it survives a relog.
local function Me() return (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?") end
local function Died(v)
	if v == nil then return ns.db.petDied[Me()] == true end
	ns.db.petDied[Me()] = v or nil
end

-- keep the books on the pet's life at every look, also in combat and while mounted (when the card
-- itself stays quiet): a pet that dies in a fight and despawns before it ends is still dead after
function ns.TrackPet()
	if not Safe(UnitExists, "pet") then return end
	local ok, dead = pcall(UnitIsDead, "pet")
	-- an unreadable answer (secret in combat, an error) says nothing: keep what we knew
	if not ok or ns.IsSecret(dead) then return end
	Died(dead and true or false)
end

-- the pet's happiness: 1 unhappy, 2 content, 3 happy, or nil (no pet, or the client won't say)
function ns.PetHappiness()
	local happy = C_PetInfo and C_PetInfo.GetPetHappiness and Safe(C_PetInfo.GetPetHappiness)
	if ns.IsSecret(happy) then return nil end
	return happy
end

-- /pack pet: what Packbound sees, to tell why the pet card does or doesn't show
function ns.PetReport()
	local words = { [1] = "unhappy", [2] = "content", [3] = "happy" }
	local happy = ns.PetHappiness()
	local food = ns.PetFood()
	local foodName = food and (Safe(C_Item.GetItemNameByID, food) or ("item " .. food)) or "none it eats"
	ns.Print(("pet out: %s, happiness: %s, Feed Pet known: %s, food: %s, card: %s"):format(
		Safe(UnitExists, "pet") and "yes" or "no", happy and (words[happy] or tostring(happy)) or "unknown",
		Known(D.feedPet) and "yes" or "no", foodName, ns.PetNeed() or "nothing needed"))
end

-- what the pet needs: "call", "revive", "feed", "nofood" or nil
function ns.PetNeed()
	if not Known(D.callPet) then return nil end
	ns.TrackPet()
	local exists = Safe(UnitExists, "pet")
	if not exists or Died() then return Died() and "revive" or "call" end
	local happy = ns.PetHappiness()
	local hungry = happy and (happy == 1 or (ns.db.petContent and happy == 2))
	if hungry and Known(D.feedPet) then return ns.PetFood() and "feed" or "nofood" end
	return nil
end

local M = {}
ns.modules[#ns.modules + 1] = M
local card, overlay

local TEXT = {
	call = { "Call your pet", "Missing: click to call it", "callPet" },
	revive = { "Your pet is dead", "Click to revive it", "revivePet" },
	feed = { "Feed your pet", "Unhappy: click to feed", "feedPet" },
	nofood = { "Feed your pet", "No food it eats in your bags", "noFood" },
}

function M:Update()
	if not card then return end
	ns.TrackPet()
	if ns.unlocked then
		card:SetTitle("Your pet"); card:SetStatus("Click to call it"); card:Show(); card:Glow(false)
		if not InCombatLockdown() then overlay:Sync(nil) end
		return
	end
	local need = ns.db.pet and not ns.InCombat() and not IsMounted() and ns.PetNeed()
	if need then
		local t = TEXT[need]
		local status = t[2]
		if need == "feed" and ns.PetHappiness() == 2 then status = "Content: click to feed" end
		card:SetTitle(t[1]); card:SetStatus(status, need ~= "feed"); card:SetExplain(ns.Help[t[3]])
		card:Show(); card:Glow(true)
	else
		card:Glow(false); card:Hide()
	end
	if InCombatLockdown() then return end
	local spell, macro
	if need == "call" or need == "revive" then
		local call, revive = ns.SpellName(D.callPet) or "Call Pet", ns.SpellName(D.revivePet) or "Revive Pet"
		spell = need == "call" and call or revive
		if need == "revive" then
			-- a corpse to revive, or one that has despawned: Revive Pet either way
			macro = ("/cast %s"):format(revive)
		else
			macro = ("/cast [@pet,dead] %s; [nopet] %s"):format(revive, call)
		end
	elseif need == "feed" then
		spell = ns.SpellName(D.feedPet)
		macro = ("/cast %s\n/use item:%d"):format(spell or "Feed Pet", ns.PetFood())
	end
	overlay:Sync(spell, "player", need and ns.Help[TEXT[need][3]], macro)
end

function M:Init()
	card = ns.MakeCard("PackboundPetFrame")
	card:SetIcon(132161)
	card:SetTitle("Your pet")
	ns.MakeMovable(card, "ptPoint")
	ns.ApplyPoint(card, "ptPoint")
	overlay = ns.CastOverlay(card)
	local f = CreateFrame("Frame")
	for _, e in ipairs({ "UNIT_PET", "PET_UI_UPDATE", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "SPELLS_CHANGED",
		"BAG_UPDATE_DELAYED", "PLAYER_MOUNT_DISPLAY_CHANGED", "PLAYER_ENTERING_WORLD", "UNIT_HAPPINESS" }) do
		pcall(f.RegisterEvent, f, e)
	end
	f:SetScript("OnEvent", function() M:Update() end)
	C_Timer.NewTicker(2, function() M:Update() end) -- happiness and death have no reliable event everywhere
	M:Update()
end
