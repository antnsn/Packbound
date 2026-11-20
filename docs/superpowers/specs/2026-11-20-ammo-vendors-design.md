# Nearest ammo vendor without Questie, and on screen

## Why

Beta 5 finds the nearest ammo vendor only when Questie is installed, and only shows it on the
ammo card (below the warn level, out of combat) or through `/pack ammo`. Marius played a hunter
and found no way to it on screen. It should work for every hunter from level 1, with or without
Questie, and be visible when you want it, not only when you are nearly out.

## Goals

- A vendor list shipped in Packbound: works from the first login, no other addon needed.
- Low levels are covered completely: every starting area, its first town and the capitals of
  both sides, for the lowest ammo (Rough Arrow, Light Shot) and the next (Sharp Arrow, Heavy
  Shot). The rest of the world (later towns, Razor Arrow, Solid Shot, Jagged Arrow, Accurate
  Slugs) as far as the list gets; vendors it lacks are learned in play.
- Packbound learns: opening a merchant that sells arrows or bullets stores that vendor and where
  it stands on Forever (account-wide). A learned vendor wins over the shipped entry for the same
  NPC, and adds vendors the list doesn't have.
- On screen: a row on the travel panel (Escape), "Nearest ammo: <name>, <zone>, N yards"; a
  click sets the map waypoint (and TomTom's, if loaded). The ammo card keeps its vendor line and
  click.

## Non-goals

- Questie: its code goes (one source to keep right). Its GPL data is never copied.
- No scraping: Wowhead is used to look vendors up by hand; entries are written in our own table
  (facts: NPC id, name, zone, coordinates, faction, what ammo they sell).
- No route finding: nearest is straight-line on your continent, as now.

## Anti-goals

- A wrong vendor shown with confidence. Entries from the list that Forever contradicts (the
  merchant at that spot doesn't sell it) are corrected by what was learned.
- Anything in combat that moves frames or throws errors.

## Approaches

- Own list + learning (picked): works at level 1, license-clean, corrects itself on Forever.
- Learning only: clean but empty for a new hunter, the case that matters most.
- Keep Questie as an extra source: more complete, but two code paths and a GPL dependency at run
  time; dropped for simplicity.

## Shape (builder's choices, Claude's call)

- `VendorData.lua`: `{ npc = id, name, map = uiMapID, x, y (0..1), side = "A"|"H"|"AH",
  sells = { arrows = { itemIDs }, bullets = { itemIDs } } }`, grouped by zone with a comment.
- Learned vendors in the account SavedVariables, keyed by NPC id (from the merchant's GUID),
  with map, x, y and the ammo item IDs seen in the merchant window (MERCHANT_SHOW).
- `ns.NearestAmmoVendor()` keeps its signature; reasons become `none` / `nowhere`.
- Travel row via LibBound's travel panel if it takes a non-spell row; otherwise LibBound gets a
  small, generic "extra row" hook (MINOR bump) that Packbound uses.
- Scenario tests in wowbench: nearest pick, learned overriding shipped, faction filter, gun vs
  bow, the travel row's click.

## Left to the builder

- Exact list contents (looked up and written by hand), and how the row looks in each skin.
