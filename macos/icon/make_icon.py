#!/usr/bin/env python3
"""Genera l'icona dell'app 'Converti in Markdown' (1024x1024 PNG)."""
import os
from PIL import Image, ImageDraw, ImageFont

S = 1024
img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

# Sfondo: rounded square con gradiente verticale (teal -> blu).
top = (38, 166, 154)      # teal
bot = (33, 97, 140)       # blu profondo
bg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
for y in range(S):
    t = y / S
    r = int(top[0] * (1 - t) + bot[0] * t)
    g = int(top[1] * (1 - t) + bot[1] * t)
    b = int(top[2] * (1 - t) + bot[2] * t)
    ImageDraw.Draw(bg).line([(0, y), (S, y)], fill=(r, g, b, 255))
mask = Image.new("L", (S, S), 0)
ImageDraw.Draw(mask).rounded_rectangle([40, 40, S - 40, S - 40], radius=200, fill=255)
img.paste(bg, (0, 0), mask)
d = ImageDraw.Draw(img)

# Foglio/documento bianco al centro.
doc_x0, doc_y0, doc_x1, doc_y1 = 300, 250, 724, 700
d.rounded_rectangle([doc_x0, doc_y0, doc_x1, doc_y1], radius=36,
                    fill=(255, 255, 255, 255))

# "M" + freccia giù (logo markdown stilizzato) in colore scuro.
ink = (33, 97, 140, 255)

def load_font(size):
    for p in [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/SFNSRounded.ttf",
        "/Library/Fonts/Arial.ttf",
    ]:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                pass
    return ImageFont.load_default()

font = load_font(300)
text = "M"
tb = d.textbbox((0, 0), text, font=font)
tw, th = tb[2] - tb[0], tb[3] - tb[1]
cx = (doc_x0 + doc_x1) / 2
ty = (doc_y0 + doc_y1) / 2
d.text((cx - tw / 2 - tb[0] - 90, ty - th / 2 - tb[1]), text, font=font, fill=ink)

# Freccia verso il basso accanto alla M.
ax = cx + 70
d.line([(ax, ty - 130), (ax, ty + 90)], fill=ink, width=46)
d.polygon([(ax - 70, ty + 50), (ax + 70, ty + 50), (ax, ty + 150)], fill=ink)

out = os.path.join(os.path.dirname(__file__), "icon.png")
img.save(out)
print("scritto", out)
