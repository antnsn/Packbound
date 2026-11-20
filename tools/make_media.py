"""Draws Packbound's textures into Media/ (TGA, power-of-two sizes).

Run from the addon folder:  python3 tools/make_media.py
Card textures are white with alpha so the game can tint them; the emblem comes from the painted art.
"""
import random
from PIL import Image, ImageChops, ImageDraw, ImageFilter


OUT = "Media/"
ART = "Packbound.png"  # painted by Marius; the logo, icon and crest are made from it


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
    """The emblem, from the painted art in Packbound.png (also the CurseForge project picture)."""
    return Image.open(ART).convert("RGBA").resize((size, size), Image.LANCZOS)


def crest(size=256):
    """The card crest: the same art as a white shape for the game to tint, its light parts
    brighter, so the faint motif behind the cards matches the icon."""
    art = emblem(size)
    lum = art.convert("L").point([int(70 + v * 185 / 255) for v in range(256)])
    alpha = ImageChops.multiply(art.getchannel("A"), lum)
    out = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    out.putalpha(alpha)
    return out

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
    save(crest(), "Crest")
    save(rim(), "Rim")
    save(emblem(256), "Logo256")
    save(emblem(64), "Logo64")
    save(icon(64), "Icon64")
    save(icon(128), "Icon128")
