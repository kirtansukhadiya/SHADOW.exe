#!/usr/bin/env python3
"""
Generate a high-resolution, cinema-grade vertical game poster for SHADOW.exe.
Dimensions: 1200 x 1800 (2:3 aspect ratio).
"""
import math
import random
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance

W, H = 1200, 1800
img = Image.new("RGBA", (W, H), (3, 7, 13, 255))
draw = ImageDraw.Draw(img)

# Fonts
font_orbitron_large = ImageFont.truetype("assets/fonts/Orbitron.ttf", 92)
font_orbitron_med = ImageFont.truetype("assets/fonts/Orbitron.ttf", 46)
font_orbitron_small = ImageFont.truetype("assets/fonts/Orbitron.ttf", 26)
font_orbitron_xs = ImageFont.truetype("assets/fonts/Orbitron.ttf", 18)
font_mono_large = ImageFont.truetype("assets/fonts/ShareTechMono-Regular.ttf", 32)
font_mono_med = ImageFont.truetype("assets/fonts/ShareTechMono-Regular.ttf", 24)
font_mono_small = ImageFont.truetype("assets/fonts/ShareTechMono-Regular.ttf", 18)
font_mono_tiny = ImageFont.truetype("assets/fonts/ShareTechMono-Regular.ttf", 14)

# 1. Background Cyber Perspective Grid
grid_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
gdraw = ImageDraw.Draw(grid_layer)

# Radial background glow behind center
for r in range(500, 0, -25):
    alpha = int(28 * (1.0 - r / 500))
    gdraw.ellipse([W//2 - r, 850 - r, W//2 + r, 850 + r], fill=(0, 240, 255, alpha))

for r in range(400, 0, -20):
    alpha = int(22 * (1.0 - r / 400))
    gdraw.ellipse([W//2 - 250 - r, 950 - r, W//2 - 250 + r, 950 + r], fill=(255, 119, 0, alpha))
    gdraw.ellipse([W//2 + 250 - r, 950 - r, W//2 + 250 + r, 950 + r], fill=(208, 0, 255, alpha))

# Perspective lines from a vanishing point at (W//2, 750)
vp_x, vp_y = W // 2, 750
for angle_deg in range(-80, 85, 10):
    rad = math.radians(angle_deg)
    ex = vp_x + int(math.tan(rad) * 1100)
    ey = H
    gdraw.line([(vp_x, vp_y), (ex, ey)], fill=(0, 240, 255, 30), width=1)

# Horizontal perspective lines
for y_ratio in [0.05, 0.12, 0.22, 0.35, 0.50, 0.68, 0.88, 1.0]:
    y = int(vp_y + (H - vp_y) * y_ratio)
    alpha = int(20 + 45 * y_ratio)
    gdraw.line([(0, y), (W, y)], fill=(0, 240, 255, alpha), width=1)

# Ceiling perspective grid
for angle_deg in range(-75, 80, 15):
    rad = math.radians(angle_deg)
    ex = vp_x + int(math.tan(rad) * 800)
    gdraw.line([(vp_x, vp_y - 200), (ex, 0)], fill=(0, 240, 255, 18), width=1)
for y in range(0, 500, 60):
    alpha = int(10 + 25 * (1.0 - y / 500))
    gdraw.line([(0, y), (W, y)], fill=(0, 240, 255, alpha), width=1)

img = Image.alpha_composite(img, grid_layer)
draw = ImageDraw.Draw(img)

# 2. Cyber Circuit Nodes & Technical HUD Overlays
for x in range(60, W - 60, 120):
    draw.line([(x, 60), (x, 70)], fill=(0, 240, 255, 120), width=1)
    draw.line([(x, H - 60), (x, H - 70)], fill=(0, 240, 255, 120), width=1)

# Corner HUD Frame Brackets
corner_len = 80
draw.line([(40, 40), (40 + corner_len, 40)], fill=(0, 240, 255, 220), width=3)
draw.line([(40, 40), (40, 40 + corner_len)], fill=(0, 240, 255, 220), width=3)
draw.line([(W - 40, 40), (W - 40 - corner_len, 40)], fill=(0, 240, 255, 220), width=3)
draw.line([(W - 40, 40), (W - 40, 40 + corner_len)], fill=(0, 240, 255, 220), width=3)

draw.line([(40, H - 40), (40 + corner_len, H - 40)], fill=(0, 240, 255, 220), width=3)
draw.line([(40, H - 40), (40, H - 40 - corner_len)], fill=(0, 240, 255, 220), width=3)
draw.line([(W - 40, H - 40), (W - 40 - corner_len, H - 40)], fill=(0, 240, 255, 220), width=3)
draw.line([(W - 40, H - 40), (W - 40, H - 40 - corner_len)], fill=(0, 240, 255, 220), width=3)

# Top Bar Header Meta
draw.text((60, 50), "SYS_PROTOCOL // TIME_REVERSAL_SIMULATION_V2.4", font=font_mono_tiny, fill=(0, 240, 255, 180))
draw.text((W - 320, 50), "SECTOR: ESCAPE_AIRLOCK // RECURSIVE", font=font_mono_tiny, fill=(0, 240, 255, 180))

# 3. Main Title Section with Multi-layer Glow & Glitch Chromatic Aberration
title = "SHADOW FLIP"
title_w = draw.textlength(title, font=font_orbitron_large)
tx = (W - title_w) // 2
ty = 140

# Red & Blue Glitch Shadows
draw.text((tx - 6, ty + 2), title, font=font_orbitron_large, fill=(255, 0, 85, 180))
draw.text((tx + 6, ty - 2), title, font=font_orbitron_large, fill=(0, 240, 255, 180))
# White Core
draw.text((tx, ty), title, font=font_orbitron_large, fill=(255, 255, 255, 255))

# Subtitle / Tagline
tagline = "\"Your shadow remembers everything you regret.\""
tag_w = draw.textlength(tagline, font=font_mono_large)
draw.text(((W - tag_w) // 2, ty + 120), tagline, font=font_mono_large, fill=(255, 119, 0, 255))

# Hackathon Badge Bar
badge_text = "HACKATHON THEME REQUIREMENT: REVERSAL PROTOCOL"
badge_w = draw.textlength(badge_text, font=font_orbitron_xs)
bx = (W - badge_w) // 2
by = ty + 175
draw.rectangle([bx - 20, by - 6, bx + badge_w + 20, by + 28], fill=(0, 240, 255, 25), outline=(0, 240, 255, 140), width=1)
draw.text((bx, by), badge_text, font=font_orbitron_xs, fill=(0, 240, 255, 240))

# 4. Central Visual Composition: Portal Airlock & Triad of Entities
# Draw Portal Ring behind characters
portal_cx, portal_cy = W // 2, 850
portal_r = 300
for r in range(portal_r + 20, portal_r - 20, -4):
    a = int(120 * (1.0 - abs(r - portal_r) / 20.0))
    draw.ellipse([portal_cx - r, portal_cy - r, portal_cx + r, portal_cy + r], outline=(0, 240, 255, a), width=2)

# Central Platform
plat_y = 1100
draw.rectangle([portal_cx - 420, plat_y, portal_cx + 420, plat_y + 35], fill=(12, 22, 38, 255), outline=(0, 240, 255, 255), width=2)
# Neon underglow
for dy in range(1, 15):
    draw.line([(portal_cx - 420, plat_y + 35 + dy), (portal_cx + 420, plat_y + 35 + dy)], fill=(0, 240, 255, int(150 * (1 - dy / 15))), width=1)

# Load in-game character sprites and upscale them with crisp nearest-neighbor
try:
    p_img = Image.open("assets/art/player_0.png").convert("RGBA")
    g_img = Image.open("assets/art/ghost_0.png").convert("RGBA")
    gr_img = Image.open("assets/art/ghost_reverse_0.png").convert("RGBA")
except Exception:
    # Fallback to spritesheet
    sheet = Image.open("assets/art/spritesheet.png").convert("RGBA")
    p_img = sheet.crop((0, 0, 32, 32))
    g_img = sheet.crop((0, 32, 32, 64))
    gr_img = sheet.crop((0, 64, 32, 96))

# Crisp upscale
scale = 7
char_w, char_h = 32 * scale, 32 * scale
p_large = p_img.resize((char_w, char_h), Image.Resampling.NEAREST)
g_large = g_img.resize((char_w, char_h), Image.Resampling.NEAREST)
gr_large = gr_img.resize((char_w, char_h), Image.Resampling.NEAREST)

# Position characters:
# Left: Echo Shadow (Orange) - Heading forward
# Center: Player (Cyan) - Airborne leaping forward
# Right: Time-Reversed Shadow (Violet) - Leaping backward
p_x, p_y = portal_cx - char_w // 2, plat_y - char_h - 110
g_x, g_y = portal_cx - 320 - char_w // 2, plat_y - char_h + 20
gr_x, gr_y = portal_cx + 320 - char_w // 2, plat_y - char_h - 40

# Glow circles behind characters
for rad in range(160, 0, -10):
    draw.ellipse([portal_cx - rad, p_y + char_h//2 - rad, portal_cx + rad, p_y + char_h//2 + rad], fill=(0, 240, 255, int(30 * (1 - rad/160))))
    draw.ellipse([g_x + char_w//2 - rad, g_y + char_h//2 - rad, g_x + char_w//2 + rad, g_y + char_h//2 + rad], fill=(255, 119, 0, int(30 * (1 - rad/160))))
    draw.ellipse([gr_x + char_w//2 - rad, gr_y + char_h//2 - rad, gr_x + char_w//2 + rad, gr_y + char_h//2 + rad], fill=(208, 0, 255, int(30 * (1 - rad/160))))

# Paste characters
img.paste(g_large, (g_x, g_y), g_large)
img.paste(p_large, (p_x, p_y), p_large)
# Reverse shadow faces opposite
gr_flipped = gr_large.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
img.paste(gr_flipped, (gr_x, gr_y), gr_flipped)

draw = ImageDraw.Draw(img)

# Character Labels & Vector Indicators
# 1. Player
draw.text((portal_cx - 100, p_y - 45), "PLAYER: CYBER PROJECTION", font=font_mono_small, fill=(0, 240, 255, 255))
draw.line([(portal_cx, p_y - 15), (portal_cx, p_y)], fill=(0, 240, 255, 200), width=2)

# 2. Echo
draw.text((g_x - 30, g_y - 45), "PAST ECHO [>>] RECORDED", font=font_mono_small, fill=(255, 119, 0, 255))
draw.line([(g_x + char_w // 2, g_y - 15), (g_x + char_w // 2, g_y)], fill=(255, 119, 0, 200), width=2)

# 3. Reversed
draw.text((gr_x - 35, gr_y - 45), "TIME-REVERSED [<<] FLIPPED", font=font_mono_small, fill=(208, 0, 255, 255))
draw.line([(gr_x + char_w // 2, gr_y - 15), (gr_x + char_w // 2, gr_y)], fill=(208, 0, 255, 200), width=2)

# 5. Narrative Revelation Box (Center Lower)
nar_y = 1210
draw.rectangle([W//2 - 460, nar_y, W//2 + 460, nar_y + 160], fill=(6, 17, 31, 230), outline=(0, 240, 255, 180), width=1)
draw.line([(W//2 - 460, nar_y + 36), (W//2 + 460, nar_y + 36)], fill=(0, 240, 255, 100), width=1)
draw.text((W//2 - 435, nar_y + 8), "⚡ SYSTEM ESCAPE AUDIT // THE CHRONO PARADOX", font=font_orbitron_xs, fill=(0, 240, 255, 255))

lines = [
    "IDENTITY VERIFIED: YOU ARE THE ECHO.",
    "The red shadow was the original entity, preserved after system reset.",
    "By reversing time [F] and cooperating with your past self,",
    "the recursive containment cycle has shattered."
]
for i, line in enumerate(lines):
    col = (255, 119, 0, 255) if i == 0 else (201, 232, 251, 220)
    font = font_mono_med if i == 0 else font_mono_small
    draw.text((W//2 - 435, nar_y + 48 + i * 26), line, font=font, fill=col)

# 6. Gameplay Feature Pillars (Three Cards)
card_y = 1420
card_w = 330
card_h = 160
gap = 25
start_x = (W - (card_w * 3 + gap * 2)) // 2

features = [
    ("RECORD PAST", "#ff7700", "[SPACE] DEPLOY", "Every jump, sprint, and pressure plate activation is committed to temporal memory."),
    ("REVERSE TIME", "#d000ff", "[F] SHADOW FLIP", "Rewind the arrow of time. Ascend one-way drops against gravity to breach airlocks."),
    ("ESCAPED ECHO", "#00f0ff", "3 LEVEL CAMPAIGN", "Uncover the classified truth across corrupted sectors and reach the Extraction Portal.")
]

for i, (f_title, f_col, f_key, f_desc) in enumerate(features):
    cx = start_x + i * (card_w + gap)
    # Card background
    draw.rectangle([cx, card_y, cx + card_w, card_y + card_h], fill=(8, 18, 30, 230), outline=(0, 240, 255, 100), width=1)
    # Header strip
    draw.line([(cx, card_y + 34), (cx + card_w, card_y + 34)], fill=(0, 240, 255, 60), width=1)
    draw.text((cx + 15, card_y + 8), f_title, font=font_orbitron_xs, fill=(255, 255, 255, 255))
    draw.text((cx + card_w - 140, card_y + 9), f_key, font=font_mono_tiny, fill=f_col)
    
    # Description wrap
    words = f_desc.split(" ")
    cur_line = ""
    line_y = card_y + 48
    for w_word in words:
        test_line = (cur_line + " " + w_word).strip()
        if draw.textlength(test_line, font=font_mono_tiny) < card_w - 30:
            cur_line = test_line
        else:
            draw.text((cx + 15, line_y), cur_line, font=font_mono_tiny, fill=(160, 200, 225, 220))
            line_y += 20
            cur_line = w_word
    if cur_line:
        draw.text((cx + 15, line_y), cur_line, font=font_mono_tiny, fill=(160, 200, 225, 220))

# 7. Poster Footer / Credits
foot_y = 1630
draw.line([(80, foot_y), (W - 80, foot_y)], fill=(0, 240, 255, 120), width=1)
draw.text((W//2 - 230, foot_y + 20), "PLAY NOW • WEB BROWSER & GODOT DESKTOP", font=font_orbitron_small, fill=(255, 255, 255, 255))
draw.text((W//2 - 310, foot_y + 60), "CONTROLS: [W] JUMP  •  [A][D] SPRINT  •  [SPACE] DEPLOY SHADOW  •  [F] SHADOW FLIP", font=font_mono_med, fill=(0, 240, 255, 220))
draw.text((W//2 - 180, foot_y + 100), "AN INDIE CYBERPUNK TIME-REVERSAL PUZZLE GAME", font=font_mono_tiny, fill=(120, 160, 190, 180))

# Save the master rendered poster
out_path = "assets/art/poster.png"
img.save(out_path, "PNG")
print(f"Master Game Poster successfully created at {out_path} ({W}x{H})")
