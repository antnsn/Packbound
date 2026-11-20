"""Draws Packbound's textures into Media/ (TGA, power-of-two sizes).

Run from the addon folder:  python3 tools/make_media.py
Card textures are white with alpha so the game can tint them; the emblem is drawn in colour.
"""
import math
import random
from PIL import Image, ImageDraw, ImageFilter

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "LibBound", "tools"))
from paint import Canvas, bar, disc, grow, leaf, lick, mask, minus, poly, radial_disc, rays, ring, sparkle, union  # noqa: E402

S = 1024

OUT = "Media/"


def leather(size=128, seed=5):
    """Leather grain: fine mottled pores and a few creases, tileable, white on alpha."""
    rnd = random.Random(seed)
    img = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(img)
    for _ in range(1400):
        x, y = rnd.randrange(size), rnd.randrange(size)
        r = rnd.uniform(0.6, 1.8)
        v = rnd.randint(30, 110)
        for dx in (-size, 0, size):
            for dy in (-size, 0, size):
                d.ellipse([x + dx - r, y + dy - r, x + dx + r, y + dy + r], fill=v)
    for _ in range(8):
        x, y = rnd.randrange(size), rnd.randrange(size)
        pts = [(x, y)]
        for _ in range(4):
            x += rnd.uniform(-10, 10); y += rnd.uniform(4, 12)
            pts.append((x, y))
        for dx in (-size, 0, size):
            for dy in (-size, 0, size):
                d.line([(px + dx, py + dy) for px, py in pts], fill=140, width=1)
    img = img.filter(ImageFilter.GaussianBlur(0.9))
    out = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    out.putalpha(img)
    return out


def claw(size=32):
    """Three claw scratches running out of the top-left corner."""
    s = size * 4
    img = Image.new("L", (s, s), 0)
    d = ImageDraw.Draw(img)
    for i in range(3):
        off = s * (0.10 + i * 0.16)
        d.line([(off, s * 0.04), (s * 0.04, off)], fill=255, width=int(s * 0.05))
    img = img.filter(ImageFilter.GaussianBlur(s * 0.01)).resize((size, size), Image.LANCZOS)
    out = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    out.putalpha(img)
    return out


def rim(size=64, width=5):
    img = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(img)
    for i in range(width * 2):
        v = int(255 * (1 - i / (width * 2)) ** 2)
        d.rectangle([i, i, size - 1 - i, size - 1 - i], outline=v)
    img = img.filter(ImageFilter.GaussianBlur(1.2))
    out = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    out.putalpha(img)
    return out


def emblem(size=256):
    """The Packbound emblem, painted (tools in LibBound/tools/paint.py)."""
    s = S
    cv = Canvas(s)
    radial_disc(cv, 0.40, (58, 40, 20), (12, 8, 4))
    rg = ring(s, 0.415, 0.365)
    cv.paint(rg, top=(170, 110, 60), bottom=(70, 40, 18), bevel=10, gloss=0.4)
    st = mask(s); d = ImageDraw.Draw(st)
    for k in range(36):
        a0 = k * 2 * math.pi / 36
        a1 = a0 + 2 * math.pi / 36 * 0.5
        d.line([(s / 2 + math.sin(a0) * s * 0.39, s / 2 - math.cos(a0) * s * 0.39),
                (s / 2 + math.sin(a1) * s * 0.39, s / 2 - math.cos(a1) * s * 0.39)], fill=255, width=6)
    cv.paint(st, top=(240, 210, 160), bottom=(160, 120, 70), bevel=2, gloss=0.2)
    # two crossed arrows, breaking out of the ring at the corners
    for (x0, y0, x1, y1) in ((0.12, 0.88, 0.88, 0.12), (0.88, 0.88, 0.12, 0.12)):
        dx, dy = x1 - x0, y1 - y0
        L = math.hypot(dx, dy); ux, uy = dx / L, dy / L
        shaft = bar(s, x0 + ux * 0.05, y0 + uy * 0.05, x1 - ux * 0.08, y1 - uy * 0.08, 0.012)
        cv.shadow(shaft, 8, 4, 8, 0.6)
        cv.paint(shaft, top=(220, 170, 110), bottom=(110, 70, 30), bevel=5, gloss=0.4)
        hx, hy = x1 - ux * 0.10, y1 - uy * 0.10
        nx, ny = -uy, ux
        head = poly(s, [(x1, y1), (hx + nx * 0.045, hy + ny * 0.045), (hx + ux * 0.02, hy + uy * 0.02), (hx - nx * 0.045, hy - ny * 0.045)])
        cv.shadow(head, 8, 4, 8, 0.6)
        cv.paint(head, top=(245, 245, 250), bottom=(110, 115, 130), bevel=6, gloss=0.9)
        for k in range(2):
            fx, fy = x0 + ux * (0.06 + k * 0.05), y0 + uy * (0.06 + k * 0.05)
            for side in (-1, 1):
                f = poly(s, [(fx, fy), (fx + ux * 0.07 + nx * side * 0.045, fy + uy * 0.07 + ny * side * 0.045),
                             (fx + ux * 0.10, fy + uy * 0.10)])
                cv.paint(f, top=(235, 225, 205), bottom=(150, 60, 40), bevel=3, gloss=0.3)
    # the paw
    toes = [disc(s, 0.050, (0.5 + dx) * s, (0.58 + dy) * s) for dx, dy in ((-0.15, -0.12), (-0.055, -0.20), (0.055, -0.20), (0.15, -0.12))]
    pad = union(disc(s, 0.072, 0.43 * s, 0.63 * s), disc(s, 0.072, 0.57 * s, 0.63 * s), disc(s, 0.080, 0.5 * s, 0.58 * s),
                poly(s, [(0.40, 0.66), (0.5, 0.72), (0.60, 0.66), (0.5, 0.60)]))
    paw = union(pad, *toes).filter(ImageFilter.GaussianBlur(2))
    cv.glow(paw, (255, 190, 90), 36, 0.6)
    cv.shadow(paw, 14, 6, 12, 0.8)
    cv.paint(paw, top=(255, 245, 220), bottom=(205, 150, 85), bevel=16, gloss=0.7, light=0.7, dark=0.7)
    return cv.image(size)


def icon(size):
    bg = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    d = ImageDraw.Draw(bg)
    for y in range(size):
        t = y / size
        d.line([(0, y), (size, y)], fill=(int(40 + 30 * (1 - t)), int(26 + 20 * (1 - t)), int(12 + 10 * (1 - t)), 255))
    e = emblem(size * 2).resize((size, size), Image.LANCZOS)
    return Image.alpha_composite(bg, e)


def _finish(img, size):
    """White line art at 4x: a soft glow under it, down to size, as alpha."""
    glow = img.filter(ImageFilter.GaussianBlur(img.size[0] * 0.012))
    img = Image.composite(img, glow, img).resize((size, size), Image.LANCZOS)
    out = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    out.putalpha(img)
    return out

def _paw(d, x, y, r, fill):
    d.ellipse([x - r, y - r * 0.8, x + r, y + r * 0.9], fill=fill)
    for dx, dy in ((-0.95, -1.05), (-0.35, -1.45), (0.35, -1.45), (0.95, -1.05)):
        t = r * 0.36
        d.ellipse([x + dx * r - t, y + dy * r - t * 1.2, x + dx * r + t, y + dy * r + t * 1.2], fill=fill)


def crest(size=256):
    """The card crest: a trail of paw prints, the way a hunter reads the ground."""
    s = size * 4
    img = Image.new("L", (s, s), 0)
    d = ImageDraw.Draw(img)
    for x, y, r, f in ((0.24, 0.80, 0.075, 150), (0.42, 0.62, 0.085, 190), (0.58, 0.48, 0.095, 225), (0.76, 0.28, 0.105, 255)):
        _paw(d, s * x, s * y, s * r, f)
    return _finish(img, size)


def save(img, name):
    img.save(OUT + name + ".tga")
    print("wrote", OUT + name + ".tga", img.size)


if __name__ == "__main__":
    save(leather(), "Leather")
    save(claw(), "Claw")
    save(crest(), "Crest")
    save(rim(), "Rim")
    save(emblem(256), "Logo256")
    save(emblem(64), "Logo64")
    save(icon(64), "Icon64")
    save(icon(128), "Icon128")
    emblem(1024).save("Packbound.png")  # the CurseForge project picture
    print("wrote Packbound.png (1024, 1024)")
