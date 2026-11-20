--@moods: low cheetah
local T = dofile(wb.dir .. "/tests/_hunter.lua")
T.hunter(wb.mood == "cheetah" and { 5118 } or {})
wb.state.bags[6948] = 1
wb.login()
wb.advance(2)
wb.openGameMenu()
wb.expect("panel with the menu", wb.shown("PackboundTravel"), true)
local rows = wb.ns.TravelRows()
wb.expect("cheetah", rows[1].label, "Aspect of the Cheetah")
wb.expect("known", rows[1].known, wb.mood == "cheetah")
wb.expect("pack at 40", rows[2].level, 40)
