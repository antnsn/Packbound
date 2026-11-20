--@moods: plenty low empty wand nobuff hawk cheetah monkey trueshot
local T = dofile(wb.dir .. "/tests/_hunter.lua")
local m = wb.mood
T.hunter({ 13165, 13163, 5118, m == "trueshot" and 19506 or nil })
local s = wb.state
if m == "low" then s.ammo = 120 end
if m == "empty" then s.ammo = 0 end
if m == "wand" then s.ammo = 0; s.items[2504].subclassID = 19 end -- not a bow
s.auras.player = { wb.aura("Aspect of the Hawk", 13165, 3600) }
if m == "nobuff" or m == "monkey" then s.auras.player = {} end
if m == "cheetah" then s.auras.player = { wb.aura("Aspect of the Cheetah", 5118, 3600) } end
if m == "trueshot" then s.auras.player = { wb.aura("Aspect of the Hawk", 13165, 3600) } end
wb.login({ saved = { PackboundDB = { aspectChoice = m == "monkey" and "Monkey" or "Hawk" } } })
wb.advance(7)
local ammo = wb.shown("PackboundAmmoFrame")
if m == "low" then
	wb.expect("ammo card", ammo, true)
	wb.expect("count", wb.frame("PackboundAmmoFrame").titleText:GetText(), "Ammo: 120 left")
elseif m == "empty" then
	wb.expect("urgent at none", wb.frame("PackboundAmmoFrame").titleText:GetText(), "No ammo left")
else
	wb.expect("no ammo card", ammo, false)
end
local aspect = wb.shown("PackboundAspectFrame")
if m == "nobuff" or m == "monkey" then
	wb.expect("no aspect: card", aspect, true)
	local want = m == "monkey" and "Aspect of the Monkey" or "Aspect of the Hawk"
	wb.check(T.macroFor(want), "a click casts " .. want)
	wb.setAuras({ wb.aura(want, 1, 3600) })
	wb.expect("gone when it's up", wb.shown("PackboundAspectFrame"), false)
else
	wb.expect("no aspect card", aspect, false)
end
if m == "trueshot" then
	wb.expect("trueshot card when missing", wb.shown("PackboundTrueshotFrame"), true)
	wb.check(T.macroFor("Trueshot Aura"), "a click casts it")
else
	wb.expect("no trueshot card without the talent", wb.shown("PackboundTrueshotFrame"), false)
end
