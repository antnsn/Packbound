<!-- summary (CurseForge "Summary" field, at most 256 characters):
Hunter helper for WoW: Forever: one-click cards to call, revive or feed your pet, cast your aspect and fix low ammo, with a waypoint to the nearest ammo vendor; Trueshot Aura timer, and Cheetah, Pack and the vendor beside the Escape menu.
-->

# Packbound

**The hunter helper for World of Warcraft: Forever: your pet, your ammo and your aspect, explained.**

Packbound looks after the things a hunter forgets: a pet that isn't out, died or is hungry, ammo that runs low, and an aspect that isn't up. Every card is one click away from fixing it.

**Full guide with screenshots:** https://antnsn.github.io/Packbound/

**Beta:** Packbound is new. Spell IDs come from Classic and are checked on Forever before 0.1.0; tell us what doesn't work.

## Your pet
- **Not out**: click the card to call it.
- **Dead**: click to revive it, also after the corpse is gone or it died in a fight.
- **Hungry**: click to feed it a food from your bags that it eats. Says so when you have none.

## Ammo and aspect
- **Ammo**: a card when your arrows or bullets run low (with a bow, gun or crossbow equipped).
- **Nearest ammo vendor**: the ammo card names the closest vendor on your side who sells your kind of ammo. Click it, or type `/pack ammo`, for a waypoint. Packbound knows the ammo vendors all over the world (no other addon needed) and corrects its list with every one you open.
- **Aspect**: a card when no aspect is up. Click to cast yours (Hawk, Monkey or Wild). Cheetah and Pack count as travelling.
- **Trueshot Aura** as a timer when you have the talent.

## Travel
- **Press Escape**: beside the game menu you get Aspect of the Cheetah, Aspect of the Pack, the nearest ammo vendor (click for a waypoint) and your Hearthstone.

## Also in it
- **Buff key** (Extras page): out of combat, each press casts the next thing a card asks for.
- **Well Rested and Well Fed**: a countdown before they run out, with a sound if you like.
- **Carrot on a Stick** (Extras page, off by default): worn while you ride, in the trinket slot you pick; your own trinket goes back on when you get off. Not in instances, and never in combat.
- **Explained**: hover over a card or button for a plain-word explanation of what it does and why (can be turned off).
- **Your layout**: every frame can be moved, snapped to a grid and scaled (`/pack unlock`).
- **Three skins**: the hunter look, Blizzard and Flat.
- Loads on hunters only.

## Commands
- `/pack`: open the options
- `/pack help`: list every command
- `/pack unlock`: show every frame so you can drag it into place
- `/pack lock`: lock the frames again
- `/pack reset`: put every frame back where it started
- `/pack grid [size]`: snap to a grid while moving, or set its size
- `/pack minimap`: show or hide the minimap button
- `/pack explain`: turn the plain-word explanations in tooltips on or off
- `/pack ammo`: set a waypoint to the nearest ammo vendor
- `/pack pet`: say what Packbound sees about your pet (happiness, food)

## Ideas and contributions
- **Missing something?** New features are added on request: leave a comment here.
- **Feel free to contribute**: the code is on GitHub, https://github.com/antnsn/Packbound (issues and pull requests welcome).
- **Want a Bound addon for another class?** The shared core, LibBound, has a guide and API reference: https://antnsn.github.io/LibBound/

## The Bound family
Packbound is one of the Bound addons, one per class, built on the same core: Lightbound (paladin), Chronobound (mage), Stormbound (shaman), Packbound (hunter), Spiritbound (priest), Felbound (warlock), Dreambound (druid), Ragebound (warrior) and Shadowbound (rogue). They look like their class but work the same way, so if you know one, you know them all.

## Changelog
<!-- changelog:start -->
### 0.1.0 beta 6

- **Feed your pet**: the pet card says so plainly, with why underneath (Unhappy, or Content when that option is on).
- `/pack pet` says in chat what Packbound sees about your pet: happiness, Feed Pet, the food it would use.
- **The nearest ammo vendor works without Questie**: Packbound has its own list of every ammo vendor in the world (made from Questie's database) and corrects it with every ammo vendor you open.
- **On the Escape menu too**: the travel panel shows the nearest ammo vendor; click it for a waypoint.
- **License**: Packbound is GPL-3.0-or-later now (it was MIT), because the vendor list comes from Questie's GPL data.
- Built on the latest LibBound, the shared core of the Bound addons, with its small fixes. Published on CurseForge straight from GitHub now.

### 0.1.0 beta 5

- **Nearest ammo vendor**: with Questie installed, the ammo card names the closest vendor on your side who sells arrows (bow, crossbow) or bullets (gun). Click the card, or type `/pack ammo`, for a map waypoint (and a TomTom one, if you use TomTom).
- The ammo card shows the count in its title ("Ammo: 120 left").

### 0.1.0 beta 4

- **Minimap button** works with minimap addons (EllesmereUI, SexyMap, ElvUI, MinimapButtonBag, broker bars): it is a LibDBIcon button now. Its place on the minimap is kept.

### 0.1.0 beta 3

- **New icon**: hand-painted class art for the icon, the emblem and the faint crest behind the cards.

### 0.1.0 beta 2

- **New look**: a painted icon and emblem, and a faint class crest behind every card and in the corner of the options window and the travel panel (the Blizzard and Flat skins stay plain).

### 0.1.0 beta 1

- First test build: pet card (call, revive, feed), ammo card, aspect card (click to cast), Trueshot Aura timer, Aspect of the Cheetah and of the Pack beside the Escape menu, Well-Rested and Well Fed, explanations, movable frames, Wild, Blizzard and Flat skins. Built on LibBound-1.0.
<!-- changelog:end -->
