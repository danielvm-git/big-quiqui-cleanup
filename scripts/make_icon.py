#!/usr/bin/env python3
"""Placeholder app icon: QuiQui on a pink square, 1024x1024, no transparency (the App Store rejects alpha).
Replace with real art in the polish pass.   python3 scripts/make_icon.py
"""
from PIL import Image

SIZE = 1024
background = Image.new("RGB", (SIZE, SIZE))
for y in range(SIZE):
    shade = int(255 - 40 * y / SIZE)
    for x in range(0, SIZE, 1):
        background.putpixel((x, y), (255, shade - 40, shade - 10))
hero = Image.open("game/assets/art/quiqui/idle.png").convert("RGBA")
hero.thumbnail((int(SIZE * 0.82), int(SIZE * 0.82)))
background.paste(hero, ((SIZE - hero.width) // 2, (SIZE - hero.height) // 2), hero)
background.save("game/icon.png")
print("wrote game/icon.png", background.size, background.mode)
