<p align="center"><img src="Packbound.png" width="180" alt="Packbound"></p>

# Packbound

A hunter helper for **WoW: Forever**, part of the Bound family (Lightbound, Chronobound,
Stormbound).

- **Your pet**: a card when it isn't out (click to call it), when it died (click to revive it)
  and when it's hungry (click to feed it a food from your bags it eats; says so when you have none).
- **Ammo**: a card when your arrows or bullets run low (with a bow, gun or crossbow). It names
  the nearest ammo vendor on your side; click the card (or type `/pack ammo`) for a waypoint to
  it. Packbound knows the ammo vendors all over the world and corrects its list with every one
  you open.
- **Aspect**: a card when no aspect is up; click to cast yours (Hawk, Monkey or Wild).
- **Trueshot Aura** when you have the talent.
- **Travel**: press Escape, and beside the game menu you get Aspect of the Cheetah, Aspect of the
  Pack, the nearest ammo vendor (click for a waypoint) and your Hearthstone.
- **Well-Rested and Well Fed** timers, plain-word explanations in tooltips, movable frames
  (`/pack unlock`), three skins (Wild, Blizzard, Flat).

Type `/pack` for the options, `/pack help` for the commands.

## Install

1. Open [Releases](https://github.com/antnsn/Packbound/releases) and download
   `Packbound-<version>.zip` (not the green "Code > Download ZIP" button).
2. Unzip it into `World of Warcraft/_forever_/Interface/AddOns/`, so you get `AddOns/Packbound`.
3. Restart the game. Packbound only loads on hunters.

## Development

Built on [LibBound](https://github.com/antnsn/LibBound), developed in the folder next to it.

```bash
tools/sync-libbound.sh
for f in *.lua; do luac5.1 -p "$f"; done
~/.luarocks/bin/luacheck .
wowbench check . && wowbench test .
wowbench pack . --set-version 0.1.0
python3 tools/make_media.py
```

## License

GPL-3.0-or-later: GNU General Public License, version 3 or (at your option) any later
version; see [LICENSE](LICENSE). LibBound-1.0 (in `Libs/LibBound`) is MIT, see its own LICENSE. The ammo vendor list (`VendorData.lua`) is made from
[QuestieDB](https://github.com/Questie/Questie) (part of Questie) by `tools/make_vendor_data.py`, used
under the GPLv3 as the Questie team allows.
