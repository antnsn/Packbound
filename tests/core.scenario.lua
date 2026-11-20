--@moods: hunter rogue
local T = dofile(wb.dir .. "/tests/_hunter.lua")
if wb.mood == "hunter" then
	T.hunter({ 883, 13165 })
	wb.state.pet = { name = "Wolf", happiness = 3 }
	wb.login()
	wb.advance(7)
	wb.slash("/pack")
	wb.check(wb.shown("PackboundOptions"), "/pack opens the options")
	local titles = {}
	for _, p in ipairs(wb.ns.optionsState.pages) do titles[#titles + 1] = p.title end
	wb.expect("pages", table.concat(titles, ", "), "Pet & ammo, Aspects, Travel, Extras, Skin")
else
	wb.state.player.classFile, wb.state.player.class = "ROGUE", "Rogue"
	wb.login()
	wb.slash("/pack")
	wb.check(wb.printed("only does something on a hunter"), "a rogue is told why")
end
