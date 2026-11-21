---
title: Your pet
parent: Features
nav_order: 1
description: A card to call your pet, revive it or feed it, one click each.
---

# Your pet

One card for your pet. It shows when the pet isn't out, has died or is hungry, and a click fixes it.

## What it does

The card shows one of these:

| Card | When | A click |
| --- | --- | --- |
| **Call your pet** (Missing: click to call it) | Your pet isn't out. | Casts Call Pet. |
| **Your pet is dead** (Click to revive it) | Your pet has died. | Casts Revive Pet. |
| **Your pet is hungry** (Click to feed it) | Your pet is unhappy, and you have food it eats. | Casts Feed Pet on the first food in your bags that your pet eats. |
| **Your pet is hungry** (No food it eats in your bags) | Your pet is unhappy, and none of your food suits it. | Nothing to cast. Buy or loot food your pet eats. |

- The card glows while it shows.
- It stays hidden in combat and while you are mounted.
- It shows nothing until you have learned Call Pet.
- The hungry card needs Feed Pet. Without it, Packbound doesn't nag about hunger.

## How to use it

1. Leave **Watch my pet** on (it is on by default).
2. When the card shows, click it, out of combat.

You can also put the click on a key: see [Buff key](buff-key.html).

## Settings

In `/pack`, page **Pet & ammo**:

| Setting | Default | What it does |
| --- | --- | --- |
| Watch my pet | On | The pet card: call it, revive it, feed it. |
| Feed it when it's only content too | Off | Also shows the hungry card when your pet is content, not only when it is unhappy. A happy pet does the most damage. |

## Good to know

**My pet died in a fight and its body is gone. Does the card still say "dead"?**
Yes. Packbound remembers that your pet died, also when it died in combat, the corpse despawned or you changed zones, until the pet is out and alive again. It remembers this per character, across a relog. Only Revive Pet brings a dead pet back, so the card casts Revive Pet, not Call Pet.

**Which food does it use?**
The first food in your bags (bag 0 to 4, in order) that the game says your pet can eat.

**Clicks don't work in combat.**
The game doesn't let addons cast for you in combat, so the card hides then. Call or revive your pet by hand in a fight.

**How quickly does it notice?**
Packbound checks on pet, bag, mount and combat changes, and every two seconds, because happiness and death don't fire a reliable event everywhere.
