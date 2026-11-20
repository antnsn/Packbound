# Nearest ammo vendor without Questie — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Packbound finds the nearest ammo vendor from its own list plus vendors it learns in
play, with no Questie, and shows it on the travel panel (Escape) as a clickable row.

**Architecture:** `VendorData.lua` ships a hand-written vendor table (`ns.AMMO_VENDORS`).
`Vendor.lua` merges it with learned vendors (`ns.db.vendors`, filled on `MERCHANT_SHOW`) and
picks the nearest on your continent, as today. LibBound's travel panel gets a generic non-secure
"action row" that Packbound fills with the nearest vendor.

**Tech Stack:** Lua 5.1, WoW: Forever client API (wowbench `api/client.txt`), LibBound-1.0,
wowbench scenarios, luacheck.

**Spec:** `docs/superpowers/specs/2026-11-20-ammo-vendors-design.md`

## Global Constraints

- Lua 5.1; only API in wowbench's `api/client.txt`; `wowbench check .` 0 errors; luacheck clean.
- No Questie code or data in Packbound; Wowhead used for lookups by hand, never scraped.
- Low levels covered completely: every starting area, its first town and both sides' capitals,
  for Rough Arrow / Light Shot and Sharp Arrow / Heavy Shot.
- Ammo item IDs: arrows `2512, 2515, 3030, 11285`; bullets `2516, 2519, 3033, 11284`.
- A learned vendor wins over the shipped entry for the same NPC id.
- Nothing moves frames or throws in combat; secret values (`ns.IsSecret`) are never computed with.
- LibBound: bump `MINOR` to 15; Chronobound/Lightbound scenarios stay green.
- `/codex:review` before every commit; PRs opened and merged by Claude (protected main).

## Review Focus

1. Merchant window opened on a non-creature (a player's guild vendor GUID "Player-…", or no
   `npc` unit): no learned entry, no error. → Task 3, mood `notcreature`.
2. Merchant that sells ammo but the player's position is unknown (inside an instance): skip
   learning, no error. → Task 3, mood `indungeon`.
3. A shipped vendor that Forever shows selling no ammo: after one visit, never offered again. →
   Task 3, mood `corrected`.
4. Escape opened with no vendor known on this continent (e.g. Kalimdor-only list, standing in
   Eastern Kingdoms): the row says how to fill it, a click does nothing harmful. → Task 4, mood
   `rownone`.
5. `/reload` after learning: the learned vendor is still there. → Task 3, mood `learned` ends
   with `wb.reload()` and checks again.

---

### Task 1: LibBound travel panel action row

**Files:**
- Modify: `../LibBound/Travel.lua` (header doc; `Build`, `UpdateCounts`)
- Modify: `../LibBound/Core.lua:20` (MINOR 14 → 15)

**Interfaces:**
- Produces: `lib.InstallTravel(ns, cfg)` accepts optional `cfg.action = function() return
  { icon = fileID, label = string, sub = string|nil, tip = string, help = string|nil,
  note = string|nil, click = function()|nil } end` (or `nil` to hide the row). Rendered as one
  plain (non-secure) `Button` named `<addon>TravelAction`, full width, between the spell rows
  and the footer. Text refreshes in `M:UpdateCounts()` (each menu open and bag update, also in
  combat since it is not secure); a click calls `click()` then closes the game menu like the
  others.

- [ ] **Step 1:** Add the action row as above; panel height counts it when `cfg.action` exists.
- [ ] **Step 2:** Bump MINOR to 15.
- [ ] **Step 3:** Verify: `cd ../Chronobound && tools/sync-libbound.sh && wowbench test .` all
  pass; same in `../Packbound`; `wowbench check .` and `luacheck .` in LibBound clean.
  (Behaviour of the new row is tested through Packbound in Task 4.)
- [ ] **Step 4:** Commit on LibBound branch `travel-action-row` (PR after Task 4 shows it works).

### Task 2: Vendor.lua on Packbound's own list (Questie out)

**Files:**
- Create: `VendorData.lua` (a few real entries for now; the full list is Task 5)
- Modify: `Vendor.lua` (rewrite the data source), `Packbound.toc` (`VendorData.lua` before
  `Vendor.lua`), `Core.lua:25-26` (help: "set a waypoint to the nearest ammo vendor")
- Test: `tests/vendor.scenario.lua` (rewrite)

**Interfaces:**
- Produces:
  - `ns.AMMO_VENDORS = { { npc = number, name = string, map = uiMapID, x = 0..1, y = 0..1,
    side = "A"|"H"|"AH", arrows = { itemIDs }, bullets = { itemIDs } }, ... }`
  - `ns.AMMO_ITEMS = { arrows = { 2512, 2515, 3030, 11285 }, bullets = { 2516, 2519, 3033, 11284 } }`
  - `ns.NearestAmmoVendor() -> { name, zone, map, x, y, yards } | nil, "none"|"nowhere"`
  - `ns.VendorsChanged()` drops the cached vendor list (called after learning; tests call it
    after replacing `ns.AMMO_VENDORS`)
  - `ns.WaypointToAmmo()` unchanged behaviour; the "needs Questie" message is gone.
  - `ns.HasVendorData()` removed; callers (`Ammo.lua`) use `ns.NearestAmmoVendor()` alone.

- [ ] **Step 1: Rewrite the scenario.** Moods `near gun faction click dungeon nowaypoint none`.
  Setup as today (Horde hunter in Durotar 1411 at 0.5, 0.5, ammo 50) but replace Questie with
  `wb.ns.AMMO_VENDORS = {...}; wb.ns.VendorsChanged()` after login:
  `Near Bowyer` H 1411 (0.52, 0.48) arrows; `Far Bowyer` H 1411 (0.90, 0.90) arrows;
  `Alliance Bowyer` A 1411 (0.50, 0.51) arrows; `Gunsmith` AH 1411 (0.70, 0.70) bullets;
  `Elwynn Bowyer` AH 1429 (0.5, 0.5) arrows. Expectations:
  - near: status `"Nearest: Near Bowyer, Durotar (click: waypoint)"`
  - gun: `"Nearest: Gunsmith, Durotar (click: waypoint)"`
  - faction: Alliance Bowyer never chosen though closest (`s.player.faction = "Horde"`)
  - click / nowaypoint / dungeon: as in the current file
  - none: `wb.ns.AMMO_VENDORS = {}` → status `"Running low"`; `/pack ammo` prints
    `"no ammo vendor known on this continent"`
- [ ] **Step 2:** Run `wowbench test . -f vendor` → fails (Vendor.lua still asks Questie).
- [ ] **Step 3:** Implement. World positions from `C_Map.GetWorldPosFromMapPos` as today;
  side from `UnitFactionGroup("player")` (`"AH"` always friendly); a vendor counts for a kind
  when its list for that kind is non-empty.
- [ ] **Step 4:** `wowbench test .` all pass; `wowbench check .`; `luacheck .`.
- [ ] **Step 5:** Codex review, commit "Ammo vendors from Packbound's own list, Questie out".

### Task 3: Learn vendors from the merchant window

**Files:**
- Modify: `Vendor.lua` (MERCHANT_SHOW handler), `Core.lua` defaults (`vendors = {}`)
- Test: `tests/vendor_learn.scenario.lua`

**Interfaces:**
- Consumes: `ns.AMMO_VENDORS`, `ns.AMMO_ITEMS`, `ns.VendorsChanged()` (Task 2)
- Produces: `ns.db.vendors[npcID] = { name, map, x, y, side, arrows = { itemIDs },
  bullets = { itemIDs }, seen = time() }` (account-wide; PackboundDB is not per character).
  NPC id is field 6 of a `"Creature-…"` or `"Vehicle-…"` GUID from `UnitGUID("npc")`; position
  is the player's (`C_Map.GetBestMapForUnit` + `GetPlayerMapPosition`); side is the player's
  faction letter. Items come from `GetMerchantItemID(i)` for `i = 1, GetMerchantNumItems()`,
  kept only if in `ns.AMMO_ITEMS`. A merchant with no ammo is stored only when its NPC is in
  `ns.AMMO_VENDORS` (with empty lists: the correction); otherwise ignored.
  Merge rule in the vendor list: a learned entry replaces the shipped entry with the same `npc`.

- [ ] **Step 1: Write the scenario.** The stub has no merchant API: define
  `wb.G.GetMerchantNumItems` / `wb.G.GetMerchantItemID` in the scenario, set the `npc` unit's
  guid (`"Creature-0-0-0-0-9999-0"`) and name, then `wb.fire("MERCHANT_SHOW")`. Moods:
  - learned: unknown NPC 9999 selling 2512 at the player's spot (0.60, 0.40 in 1411), with the
    shipped list holding only `Far Bowyer` → status names the new vendor;
    `wb.saved("PackboundDB").vendors[9999].arrows[1] == 2512`; after `wb.reload()` still chosen.
  - corrected: shipped `Near Bowyer` (npc 1) visited and sells only 117 (food) → next nearest
    (`Far Bowyer`) is chosen; `vendors[1].arrows` is empty.
  - moved: shipped npc 1 visited at (0.80, 0.20) → the waypoint goes to 0.80.
  - notcreature: guid `"Player-1-0ABC"` → `vendors` stays empty, no Lua error.
  - indungeon: player on map 999 (no position) → nothing stored, no error.
- [ ] **Step 2:** Run `wowbench test . -f vendor_learn` → fails.
- [ ] **Step 3:** Implement the handler (registered only when not `ns.disabled`), skip on any
  secret value.
- [ ] **Step 4:** `wowbench test .`, `wowbench check .`, `luacheck .` all clean.
- [ ] **Step 5:** Codex review, commit "Packbound learns ammo vendors from the merchant window".

### Task 4: The travel panel row, texts and docs

**Files:**
- Modify: `Travel.lua` (pass `action = ns.AmmoTravelRow`), `Vendor.lua` (add
  `ns.AmmoTravelRow`), `Help.lua` (help text), `Ammo.lua` (drop `ns.HasVendorData` use),
  `README.md`, `CURSEFORGE.md` (feature text and summary: no Questie), `CHANGELOG.md`
  (`## Unreleased`), `docs/` pages that mention Questie
- Test: `tests/travel.scenario.lua` (new moods)

**Interfaces:**
- Consumes: `cfg.action` (Task 1), `ns.NearestAmmoVendor()`, `ns.WaypointToAmmo()` (Task 2)
- Produces: `ns.AmmoTravelRow() -> action table`:
  - vendor known: `label = "Ammo: <name>"`, `sub = "<zone>, <yards> yards"`,
    `tip = "Nearest ammo vendor"`, `note = "Click for a waypoint."`, `click = ns.WaypointToAmmo`,
    icon = the equipped ammo kind's lowest item icon (arrows 2512 / bullets 2516)
  - none: `label = "Ammo vendor: none known here"`, `sub = "open one and Packbound remembers it"`,
    no click

- [ ] **Step 1: Scenario moods** in `travel.scenario.lua`: `rowvendor` (Escape opens with the
  Task 2 test vendors → `PackboundTravelAction` shown, text `"Ammo: Near Bowyer"`; click sets
  `s.waypoint`, game menu hides), `rownone` (empty list → none text, click leaves
  `s.waypoint == nil`).
- [ ] **Step 2:** Run → fails. **Step 3:** Implement. **Step 4:** `tools/sync-libbound.sh &&
  wowbench test .` all pass; check + luacheck.
- [ ] **Step 5:** Texts: no "needs Questie" anywhere (`grep -ri questie` outside `docs/superpowers`
  and older changelog entries returns nothing); CHANGELOG Unreleased: "The nearest ammo vendor
  works without Questie: Packbound has its own list and learns every ammo vendor you visit. On the
  Escape menu's travel panel too." `python3 tools/sync_curseforge.py --check` ok.
- [ ] **Step 6:** Codex review of LibBound and Packbound; commit both.

### Task 5: The vendor list

**Files:**
- Modify: `VendorData.lua`
- Test: `tests/vendor_data.scenario.lua`

**Interfaces:**
- Consumes: the `ns.AMMO_VENDORS` entry shape (Task 2)

- [ ] **Step 1: Write the data scenario** against the real list: every entry has a numeric
  `npc` (unique), non-empty `name`, `map` a number, `0 < x, y < 1`, `side` in `A/H/AH`, at least
  one of `arrows`/`bullets` non-empty, every item in `ns.AMMO_ITEMS`. Coverage: for each map in
  `{1429 Elwynn, 1426 Dun Morogh, 1438 Teldrassil, 1453 Stormwind, 1455 Ironforge, 1457 Darnassus}`
  an `A`/`AH` vendor, and for `{1411 Durotar, 1412 Mulgore, 1420 Tirisfal, 1454 Orgrimmar,
  1456 Thunder Bluff, 1458 Undercity}` an `H`/`AH` vendor; across each side both 2512 and 2516 and
  both 2515 and 2519 are sold somewhere.
- [ ] **Step 2:** Run → fails on coverage.
- [ ] **Step 3: Fill the list** by looking each vendor up on Wowhead Classic by hand (item page →
  "Sold by" → NPC page for coordinates), one entry per NPC, grouped by zone with a comment.
  Low-level set first (starting areas, first towns, capitals); then the later towns as far as it
  goes. No bulk download; nothing from Questie.
- [ ] **Step 4:** `wowbench test .` all pass; check + luacheck.
- [ ] **Step 5:** Codex review, commit "Ammo vendor list: starting areas, first towns, capitals…".

### Task 6: Ship

- [ ] **Step 1:** LibBound PR (`travel-action-row`, MINOR 15), merge; `tools/sync-libbound.sh`
  in Packbound, Chronobound (and the other Bound addons that sync) → `wowbench test .` green.
- [ ] **Step 2:** Packbound PR with spec, plan and Tasks 2–5; merge. Release is the maintainer's
  call after testing in game (bead for the in-game check: list vendors match Forever).
