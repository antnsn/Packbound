---
title: Well-Rested and Well Fed
parent: Features
nav_order: 6
description: A warning before Well-Rested or Well Fed runs out, with a countdown card.
---

# Well-Rested and Well Fed

Two buffs that are easy to lose track of while levelling. Packbound warns you before they run out.

- **Well-Rested** comes from sleeping in a Cozy Sleeping Bag: more experience for a while.
- **Well Fed** comes from buff food: better stats, and on Forever more experience too.

## What it does

![The Well-Rested card]({{ '/screenshots/frames/wrpoint.png' | relative_url }})

![The Well Fed card]({{ '/screenshots/frames/wfpoint.png' | relative_url }})

- When the buff has less time left than your limit, Packbound warns you in chat and in the middle of the screen, for example "Well Fed: 3 min left", with a sound.
- A card then counts down the time left.
- When Well Fed runs out, Packbound says "Well Fed is gone" in chat.
- With **Keep following it after it's gone** on, a faded card stays up when the buff is gone ("Buff has run out"), and you get one "is gone, rebuff" reminder, out of combat and while alive.

## How to use it

Nothing to do: both are on by default. Click **Test** on the **Extras** page to see and hear the warning.

## Settings

![The Extras page]({{ '/screenshots/options-extras.png' | relative_url }})

In `/pack`, page **Extras**. The sections **Well-Rested** and **Well Fed** have the same settings:

| Setting | Default | What it does |
| --- | --- | --- |
| Test | | Shows the warning now, so you can see and hear it. |
| Warn | On | The warning in chat and on screen. Off turns off the cards too. |
| Sound | On | Plays the raid warning sound with the warning. |
| Countdown card | On | The card that counts down the time left after the warning. |
| Keep following it after it's gone (rebuff warning) | Off | The "Buff has run out" card and the one rebuff reminder. |
| Warn with time left | Well-Rested 5 min, Well Fed 3 min | When the warning comes. 1 to 30 minutes. |

## Good to know

**The warning comes once.** If you refresh the buff, or raise the limit above the time left, Packbound warns again the next time it gets that low.

**Right after login or a loading screen,** Packbound waits five seconds before it says a buff is gone, because the game may not have filled in your buffs yet.

**"Well Fed is gone" doesn't show** when **Keep following it after it's gone** is on: then you get the card and the rebuff reminder instead.
