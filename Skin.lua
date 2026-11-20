-- Packbound's look, "Wild": dark leather panels, a warm amber edge, claw scratches in the corners,
-- a slow amber rim while a card needs you. LibBound derives the Blizzard and Flat skins from it.
-- Textures: tools/make_media.py.
local _, ns = ...
if ns.disabled then return end
local Bound = LibStub("LibBound-1.0")
local F = Bound.FONTS

local wild = {
	name = "Wild",
	font = { ui = F.friz, title = F.friz, narrow = F.arialn, card = F.morpheus },
	color = {
		bg = { 0, 0, 0, 0 },
		side = { 0.05, 0.03, 0.01, 0.40 },
		header = { 0.05, 0.03, 0.01, 0.35 },
		border = { 0.62, 0.45, 0.22, 0.9 },
		hover = { 0.26, 0.18, 0.09, 1 },
		selected = { 0.24, 0.16, 0.08, 1 },
		text = { 0.96, 0.92, 0.84 },
		dim = { 0.72, 0.66, 0.56 },
		accent = { 0.92, 0.70, 0.36 },
		track = { 0.18, 0.12, 0.06, 1 },
		button = { 0.09, 0.06, 0.03, 1 },
		navGlow = { 0.95, 0.70, 0.30, 0.65 },
		row = { 0.14, 0.10, 0.05, 0.8 },
		rowWarn = { 0.40, 0.30, 0.05, 0.5 },
		rowBad = { 0.45, 0.08, 0.10, 0.55 },
		highlight = { 1, 0.86, 0.6, 0.08 },
		cell = { 0.14, 0.10, 0.06, 0.85 },
		cdText = { 1, 0.9, 0.7 },
		glow = { 0.95, 0.72, 0.36 },
		gridLine = { 1, 0.86, 0.6, 0.08 },
		gridCentre = { 0.95, 0.70, 0.30, 0.45 },
	},
	box = {
		backdrop = {
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true, tileSize = 16, edgeSize = 14,
			insets = { left = 3, right = 3, top = 3, bottom = 3 },
		},
		bg = { 0.08, 0.05, 0.03 },
		border = { 0.80, 0.60, 0.30, 1 },
	},
	dialog = {
		backdrop = {
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 11, right = 11, top = 12, bottom = 11 },
		},
		outset = 10,
		border = { 0.86, 0.68, 0.40, 1 },
		under = { 0.06, 0.04, 0.02, 1 },
		plate = false,
	},
	tex = Bound.STOCK_TEX,
	card = {
		panel = { 0.10, 0.07, 0.04, 0.94 },
		gilt = { 0.66, 0.48, 0.24, 1 },
		giltFaint = { 0.44, 0.32, 0.16, 0.9 },
		light = { 1, 0.86, 0.6, 0.07 },
		rays = { 1, 0.78, 0.42 },
		raysFaded = { 0.66, 0.60, 0.52 },
		title = { 0.98, 0.78, 0.44 },
		status = { 0.94, 0.89, 0.80 },
		urgent = { 1, 0.62, 0.42 },
		glowEdge = { 1, 0.80, 0.46, 1 },
		iconEdge = { 0.80, 0.60, 0.30, 0.9 },
		frost = "Leather", frostTint = { 0.80, 0.62, 0.40, 0.14 },
		crest = "Crest", crestTint = { 0.95, 0.74, 0.45, 0.15 },
		shards = "Claw", shardTint = { 0.96, 0.80, 0.52, 0.95 },
		rim = "Rim", breathe = true, breatheTime = 3.0,
		burst = false, studs = false, ring = false, round = false,
	},
	widgets = "blizzard",
}

Bound.InstallSkin(ns, {
	skins = { wild = wild },
	order = { "wild", "blizzard", "flat" },
	default = "wild",
	about = { wild = "Dark leather, a warm amber edge and claw marks in the corners." },
})
Bound.InstallBuffTimers(ns)
Bound.InstallMinimap(ns)
