---
title: Getting started
nav_order: 2
description: Install Packbound and set it up in about two minutes.
---

# Getting started
{: .no_toc }

Two minutes from install to a hunter who fixes the pet, the ammo and the aspect with one click.
{: .fs-6 .fw-300 }

1. TOC
{:toc}

---

## 1. Install it

Pick one:

- **CurseForge app or WowUp:** search for **Packbound** and click Install.
- **By hand:** download it from [CurseForge](https://www.curseforge.com/wow/addons/packbound) or from [Releases on GitHub](https://github.com/antnsn/Packbound/releases) (the `Packbound-<version>.zip` file, not the green "Code > Download ZIP" button). Unzip it into your `World of Warcraft\_forever_\Interface\AddOns` folder, so you get a folder called `Packbound` there.

Start the game (or type `/reload` if it was already running) and log in on your hunter.

{: .note }
Packbound only loads on hunters. On any other class it does nothing, and it turns itself off for that character from the next login. The AddOns list can tick it again.

## 2. Open the options

Type `/pack` in chat, or click the Packbound button on your minimap.

The options window has one page per feature on the left: **Pet & ammo**, **Aspects**, **Travel**, **Extras** and **Skin**. Almost everything is on by default, so you mostly turn off what you don't want.

## 3. Pick your aspect

On the **Aspects** page, **Aspect to cast** sets the aspect the aspect card casts: Hawk (the default), Monkey or Wild. The line under it says which aspect you get now. If the one you picked isn't learned yet, Packbound falls back to Hawk, then Monkey.

## 4. Play

When something needs you, a card shows up. Click the card to fix it:

| Card | A click |
| --- | --- |
| Call your pet | Calls your pet. |
| Your pet is dead | Revives your pet. |
| Your pet is hungry | Feeds it a food from your bags that it eats. |
| No aspect | Casts your aspect. |
| Ammo | Sets a waypoint to the nearest ammo vendor. |
| Trueshot Aura | Casts Trueshot Aura. |

The pet, aspect and ammo cards stay hidden in combat. Clicks that cast a spell only work out of combat.

{: .tip }
Hover over a card for a short explanation of what it is for. You can turn these off once you know them. See [Explanations in tooltips](features/explanations.html).

## 5. Put the frames where you want them

1. Type `/pack unlock` (or Shift-click the minimap button) to unlock the frames. Every frame shows, with sample text.
2. Drag each frame where you want it. Scroll the mouse wheel over a frame to resize it.
3. Type `/pack lock` to lock them again.

`/pack reset` puts every frame back where it started. More in [Frames and the minimap button](features/frames.html).

Using EllesmereUI, ElvUI or another flat UI? Pick the **Flat** look on the **Skin** page in `/pack`. See [Skins](features/skins.html).

## 6. Optional: a buff key

On the **Extras** page you can set a key that casts whatever the top card asks for, so you don't have to click the card. See [Buff key](features/buff-key.html).

## That's it

Everything else works on its own. When you want to know what a card means or change how something behaves, look it up under [Features](features/).
