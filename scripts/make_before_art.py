#!/usr/bin/env python3
"""Placeholder "before" pictures for t34_rub_reveal: each room background, hazy and grimy.
Same size as the background so the reveal lines up. Replace with real art in the polish pass.
  python3 scripts/make_before_art.py
"""
import random
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

ROOMS = ["living_room", "kitchen", "bathroom", "bedroom", "garden"]
ART = "game/assets/art"

for room in ROOMS:
    rng = random.Random(room)
    image = Image.open(f"{ART}/backgrounds/{room}.jpg").convert("RGB")
    image = ImageEnhance.Color(image).enhance(0.35)
    image = ImageEnhance.Brightness(image).enhance(0.72)
    grime = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(grime)
    for _ in range(70):
        x, y = rng.randrange(image.width), rng.randrange(image.height)
        r = rng.randrange(25, 90)
        shade = rng.randrange(70, 110)
        draw.ellipse((x - r, y - r, x + r, y + r), fill=(shade + 20, shade, shade - 25, 90))
    grime = grime.filter(ImageFilter.GaussianBlur(14))
    image = Image.alpha_composite(image.convert("RGBA"), grime).convert("RGB")
    image.save(f"{ART}/before/{room}.jpg", quality=80)
    print("wrote", room)
