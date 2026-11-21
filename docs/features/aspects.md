---
title: Aspects and Trueshot Aura
parent: Features
nav_order: 3
description: A card when no aspect is up, and a timer for Trueshot Aura once you have the talent.
---

# Aspects and Trueshot Aura

An aspect is a hunter stance: Aspect of the Hawk gives ranged attack power, Monkey gives dodge. Packbound shows a card when none is up, and keeps an eye on Trueshot Aura if you have it.

## What it does

### The aspect card

- The card **No aspect** shows when you have no aspect up, out of combat and not mounted.
- A click casts your aspect. The card says which one, for example "Click for Aspect of the Hawk".
- Any aspect counts as up: Hawk, Monkey, Wild, the Beast, the Cheetah and the Pack. So Cheetah and Pack count as travelling, and the card leaves you alone.
- It shows nothing until you have learned an aspect it can cast.

**Which aspect it casts:** the one you pick under **Aspect to cast**. If you haven't learned that one yet, it casts Hawk, and without Hawk, Monkey.

### Trueshot Aura

Trueshot Aura is a Marksmanship talent that gives you and your group more attack power. Once you have it, Packbound follows it like a long buff:

- With 1 minute left, it warns you in chat and in the middle of the screen ("Trueshot Aura: 1 min left"), and a card counts down the time.
- When it is gone, a faded card says "Missing: click to cast", and you get one "Trueshot Aura is gone, rebuff" reminder, out of combat and while alive.
- A click on either card casts Trueshot Aura.
- Without the talent, nothing about Trueshot Aura shows.

## How to use it

1. Type `/pack` and open the **Aspects** page.
2. Click **Aspect to cast** to step through Hawk, Monkey and Wild (right-click goes back). The line under it says what you get now.
3. When a card shows, click it, out of combat.

Both cards can also go on a key: see [Buff key](buff-key.html).

## Settings

In `/pack`, page **Aspects**:

| Setting | Default | What it does |
| --- | --- | --- |
| Warn when no aspect is up | On | The aspect card. |
| Aspect to cast | Hawk | Hawk, Monkey or Wild. The line under it says "Now: ..." or "No aspect learned yet (Hawk at level 10)." |

Section **Trueshot Aura**:

| Setting | Default | What it does |
| --- | --- | --- |
| Show | On | Follows Trueshot Aura. Off turns off the warning and both cards. |
| Sound | Off | Plays the raid warning sound with the warning and the reminder. |
| When missing | On | The "Missing: click to cast" card and the one rebuff reminder when Trueshot Aura is gone. |

## Good to know

**The aspect card doesn't show in combat.**
On Forever the game hides some of your buffs from addons in combat, so Packbound can't tell if an aspect is up. The card waits until the fight is over. Clicks can't cast in combat anyway.

**Can I set when the Trueshot Aura warning comes?**
No. It is always 1 minute before it runs out.

**I switched to Cheetah and the card went away.**
That is on purpose: Cheetah and Pack are for travel, so Packbound doesn't ask you to switch back.

**Right after login or a loading screen,** Packbound waits five seconds before it says Trueshot Aura is missing, because the game may not have filled in your buffs yet.
