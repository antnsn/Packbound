"""Draws Packbound's textures into Media/ (TGA, power-of-two sizes).

Run from the addon folder:  python3 tools/make_media.py
Card textures are white with alpha so the game can tint them; the emblem is drawn in colour.
"""
import math
import random
from PIL import Image, ImageDraw, ImageFilter

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
    """The Packbound emblem: a paw print over a level arrow, in an amber ring."""
    s = size * 4
    c = s / 2
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([s * 0.08, s * 0.08, s * 0.92, s * 0.92], outline=(225, 170, 90, 230), width=int(s * 0.04))
    paw = (245, 225, 190, 255)
    wood, fletch = (205, 145, 72, 255), (235, 200, 150, 255)
    # the arrow lies level under the paw (a diagonal through the ring would read as "no pets")
    y = s * 0.74
    d.line([(s * 0.22, y), (s * 0.76, y)], fill=wood, width=int(s * 0.026))
    d.polygon([(s * 0.80, y), (s * 0.72, y - s * 0.045), (s * 0.72, y + s * 0.045)], fill=wood)
    for k in range(3):
        x = s * (0.22 + 0.035 * k)
        d.line([(x, y), (x - s * 0.04, y - s * 0.05)], fill=fletch, width=int(s * 0.013))
        d.line([(x, y), (x - s * 0.04, y + s * 0.05)], fill=fletch, width=int(s * 0.013))
    cy = c - s * 0.06
    d.ellipse([c - s * 0.15, cy - s * 0.02, c + s * 0.15, cy + s * 0.22], fill=paw)  # pad
    for dx, dy in ((-0.19, -0.11), (-0.065, -0.20), (0.065, -0.20), (0.19, -0.11)):
        x, yy = c + dx * s, cy + dy * s
        d.ellipse([x - s * 0.055, yy - s * 0.07, x + s * 0.055, yy + s * 0.07], fill=paw)
    glow = img.filter(ImageFilter.GaussianBlur(s * 0.02))
    return Image.alpha_composite(glow, img).resize((size, size), Image.LANCZOS)


def icon(size):
    bg = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    d = ImageDraw.Draw(bg)
    for y in range(size):
        t = y / size
        d.line([(0, y), (size, y)], fill=(int(40 + 30 * (1 - t)), int(26 + 20 * (1 - t)), int(12 + 10 * (1 - t)), 255))
    e = emblem(size * 2).resize((size, size), Image.LANCZOS)
    return Image.alpha_composite(bg, e)


def save(img, name):
    img.save(OUT + name + ".tga")
    print("wrote", OUT + name + ".tga", img.size)


if __name__ == "__main__":
    save(leather(), "Leather")
    save(claw(), "Claw")
    save(rim(), "Rim")
    save(emblem(256), "Logo256")
    save(emblem(64), "Logo64")
    save(icon(64), "Icon64")
    save(icon(128), "Icon128")
