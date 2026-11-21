---
title: Frames and the minimap button
parent: Features
nav_order: 8
description: Move and resize every frame, snap them to a grid, and open Packbound from the minimap.
---

# Frames and the minimap button

Put every card exactly where you want it, at the size you want, and open Packbound from the minimap.

## What it does

### Moving and resizing frames

- Unlocking shows **every** Packbound card with sample text, so you can place cards that are normally hidden: your pet, ammo, no aspect, Trueshot Aura, Well-Rested and Well Fed.
- Drag a card to move it. Cards snap to a grid around the center of your screen. Hold **Shift** while dragging to place a card freely.
- Scroll the **mouse wheel** over a card to make it bigger or smaller (50% to 250%).
- While unlocked, a small bar at the top of the screen sets the grid size (**-** and **+**, or the mouse wheel; hold Shift for 1 pixel steps), turns **Snap** on or off, and has a **Lock** button.
- **Reset positions** puts every card back in its default place and size.

### Minimap button and addon menu

| Click | Does |
| --- | --- |
| Left-click | Opens the options (`/pack`). |
| Shift-click or middle-click | Unlocks the frames (and locks them again). |
| Drag | Moves the button around the minimap. |

Minimap addons such as EllesmereUI, SexyMap, ElvUI, MinimapButtonBag and broker bars collect the button like any other. Where the game has an addon menu (the puzzle-piece button), Packbound is listed there too, with the same clicks. The game's **Settings > AddOns** list also has a Packbound entry with an **Open options** button.

## How to use it

1. Type `/pack unlock`, Shift-click the minimap button, or click **Unlock frames** at the bottom of the `/pack` window.
2. Drag cards into place. Scroll on a card to resize it.
3. Click **Lock** on the bar at the top, or type `/pack lock`.
4. Made a mess? `/pack reset` (or **Reset positions** in `/pack`) puts everything back.

## Settings

In `/pack`, page **Skin**, section **General**:

| Setting | Default | What it does |
| --- | --- | --- |
| Minimap button (left-click options, shift-click unlock) | On | Shows or hides the minimap button. Also `/pack minimap`. |

At the bottom of every page of `/pack`: **Unlock frames** (or **Lock frames**) and **Reset positions**.

The grid has no options page. Change it on the bar shown while frames are unlocked, or with `/pack grid`:

| Command | Does |
| --- | --- |
| `/pack grid` | Turns snapping on or off (on by default). |
| `/pack grid 30` | Sets the grid size (4 to 100, default 20) and turns snapping on. |

## Good to know

**Not in combat.**
Unlocking, locking, moving, resizing and resetting frames all wait until you leave combat. A drag stops when a fight starts.

**Closing the options window** locks the frames again, but only if you unlocked them with the options' own button. Frames unlocked with `/pack unlock` stay unlocked until you lock them.

**The options window** is moved by dragging its title bar, not with unlock. Escape closes it. The [travel panel](travel-panel.html) can't be moved.
