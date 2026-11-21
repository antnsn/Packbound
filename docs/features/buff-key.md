---
title: Buff key
parent: Features
nav_order: 5
description: One key that casts what the top card asks for.
---

# Buff key

Press one key, out of combat, and Packbound does what the top card asks for: call or revive your pet, feed it, cast your aspect or Trueshot Aura. No need to click the card.

## What it does

- Each press does **one** thing: what a click on the first card that has something to cast would do.
- The cards are checked in this order:
  1. **[Your pet](pet.html):** call it, revive it or feed it.
  2. **[No aspect](aspects.html):** cast your aspect.
  3. **[Trueshot Aura](aspects.html#trueshot-aura):** cast it when it is about to run out or gone.
- With nothing to do, a press says "nothing to buff right now." in chat.
- The key does nothing in combat.

The ammo card isn't on the key: its click sets a waypoint and casts nothing. Use `/pack ammo` for that.

## How to use it

1. Type `/pack` and open the **Extras** page.
2. Under **Buff key**, click the button next to **Key**, then press the key you want (for example Shift-Q). Esc cancels.
3. Out of combat, press the key when a card shows.

## Settings

In `/pack`, page **Extras**, section **Buff key**:

| Setting | Default | What it does |
| --- | --- | --- |
| Key | Not set | The key itself. **Clear** removes it. |

## Good to know

**The note in the options mentions group buffs.**
The buff key is shared by all Bound addons. In other classes it also casts a group buff on the next party member who needs it. Packbound has no group buff, so for a hunter the key only does what the cards ask for.

**Does it work in combat?**
No. The game doesn't let addons cast for you in combat, and the cards it follows hide in combat too.

**Setting the key in combat** isn't possible either: Packbound says "leave combat first."

**The key overrides the game's own binding** for that key while Packbound is loaded. Clear it to get the old binding back.
