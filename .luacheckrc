-- luacheck config: run "luacheck ." from this folder (Lua 5.1, like the WoW client).
-- The real API list is wowbench's (wowbench check .); this one only lists what Packbound uses.
std = "lua51"
max_line_length = false
ignore = { "212", "432" }
exclude_files = { "Libs/", "tests/", "tools/" }
read_globals = {
	"C_Container", "C_Item", "C_Map", "C_PetInfo", "C_SuperTrack", "C_Timer", "CreateVector2D", "CreateFrame", "GetInventoryItemCount", "GetInventoryItemID",
	"GetMerchantItemID", "GetMerchantNumItems", "GetRealmName", "InCombatLockdown", "strsplit", "time", "UnitGUID", "IsMounted", "IsPlayerSpell", "LibStub", "UiMapPoint", "UnitExists", "UnitFactionGroup", "UnitIsDead", "UnitName",
}
