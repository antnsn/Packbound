--@moods: wild blizzard flat
local T = dofile(wb.dir .. "/tests/_hunter.lua")
T.hunter({ 883, 13165 })
wb.login({ saved = { PackboundDB = { skin = wb.mood } } })
wb.advance(7)
local want = ({ wild = "Wild", blizzard = "Blizzard", flat = "Flat" })[wb.mood]
wb.expect("active skin", wb.ns.UI.Active().name, want)
wb.check(wb.shown("PackboundPetFrame"), "a card builds in this skin (no pet out)")
wb.slash("/pack")
wb.check(wb.shown("PackboundOptions"), "the options build in this skin")
