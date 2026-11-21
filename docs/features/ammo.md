---
title: Ammo and the nearest ammo vendor
parent: Features
nav_order: 2
description: A card when arrows or bullets run low, with the closest ammo vendor and a waypoint to it.
---

# Ammo and the nearest ammo vendor

A card when your arrows or bullets run low. It names the closest vendor on your side who sells your kind of ammo, and a click sets a waypoint to that vendor.

## What it does

![The ammo card]({{ '/screenshots/frames/ampoint.png' | relative_url }})

- The card shows when the ammo in your ammo slot is at or below your limit (200 by default), and only while you have a bow, gun or crossbow equipped.
- Its title shows the count, for example "Ammo: 120 left". With none left it says "No ammo left", and the line below it turns to the warning color.
- Below the title it names the nearest ammo vendor and the zone, for example "Nearest: Duokna, Durotar (click: waypoint)". If no vendor is known nearby, it says "Running low" or "Buy arrows or bullets".
- It stays hidden in combat.

### The nearest vendor

- **Your kind of ammo.** With a gun it looks for bullets. With a bow or crossbow it looks for arrows.
- **Your side.** Only vendors friendly to your faction count, plus neutral ones.
- **Your continent.** It picks the closest one on the continent you are on.
- The nearest vendor is worked out again every five seconds while the card shows, so it follows you as you travel.

### Where the vendor list comes from

Packbound brings its own list of 128 ammo vendors from all over the world. You don't need Questie or any other addon.

It also learns: every time you open a vendor who sells arrows or bullets, Packbound stores who it is, where it stands and what it sells. A vendor you have opened wins over the list's entry for the same NPC. If a vendor from the list no longer sells ammo when you open it, Packbound drops it. What it learns is shared by all your characters.

## How to use it

![The travel panel with the nearest ammo vendor]({{ '/screenshots/travel.png' | relative_url }})

1. Leave **Warn when ammo runs low** on (it is on by default).
2. When the card shows, click it, or type `/pack ammo`.
3. Packbound puts a waypoint on the map and tracks it, and says in chat who the vendor is, the zone, the map coordinates and how many yards away it is.

The nearest vendor is also on the [travel panel](travel-panel.html) beside the Escape menu, with the same click.

{: .tip }
If you use TomTom, Packbound adds a TomTom waypoint too.

## Settings

![The Pet & ammo page]({{ '/screenshots/options-pet-ammo.png' | relative_url }})

In `/pack`, page **Pet & ammo**:

| Setting | Default | What it does |
| --- | --- | --- |
| Warn when ammo runs low | On | The ammo card. |
| Ammo: warn at | 200 left | The card shows at this many or fewer. 0 to 1000, in steps of 50. At 0 it shows only when you are out. |

## Good to know

**"Can't tell where you are here (inside a dungeon?)."**
Inside dungeons and other instances the game gives no map position, so Packbound can't pick a vendor. Look again outside.

**"No ammo vendor known on this continent yet."**
No vendor on the list, and none you have opened, sells your kind of ammo on this continent for your side. Open an ammo vendor and Packbound remembers it.

**"No waypoint here: look for it on the map."**
Some maps don't take a waypoint. Packbound still names the vendor and gives the coordinates.

**The vendor isn't where the card says.**
The list comes from Classic data. Open the vendor where it really stands, and Packbound corrects its entry.

**Clicking the card while the frames are unlocked** doesn't set a waypoint: then the click is for dragging.

The vendor list is made from QuestieDB, part of [Questie](https://github.com/Questie/Questie) by Muehe, Logon, TheCrux/BreakBB, Drejjmit, Cheeq, TechnoHunter, Yttrium and the Questie contributors, used under the GNU GPL v3 as the Questie team allows. That is why Packbound is GPL-3.0-or-later.
