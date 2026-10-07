#!/usr/bin/env python3
"""Draws the Kings Justice app icon procedurally (no AI imagery). Run: python3 tools/make_icon.py
Writes AppIcon.png, AppIcon-Dark.png, AppIcon-Tinted.png (1024x1024, opaque RGB) into the asset catalog."""
import math, os, json
from PIL import Image, ImageDraw, ImageFilter, ImageChops, ImageEnhance, ImageOps

S = 2048          # supersampled canvas, downscaled to 1024
OUT = 1024
rng_state = 12345
def rnd():
    global rng_state
    rng_state = (rng_state * 1103515245 + 12345) & 0x7fffffff
    return rng_state / 0x7fffffff

def lerp(a, b, t): return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))

def gradient_v(size, stops):
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    for y in range(h):
        t = y / (h - 1)
        for i in range(len(stops) - 1):
            if stops[i][0] <= t <= stops[i + 1][0]:
                u = (t - stops[i][0]) / (stops[i + 1][0] - stops[i][0])
                c = lerp(stops[i][1], stops[i + 1][1], u)
                break
        for x in range(w): px[x, y] = c
    return img

def radial(size, center, radius, inner, outer):
    """Returns an L mask: 255 at center fading to 0 at radius."""
    w, h = size
    m = Image.new("L", size, 0)
    px = m.load()
    cx, cy = center
    for y in range(h):
        for x in range(w):
            d = math.hypot(x - cx, y - cy) / radius
            v = max(0.0, 1.0 - d)
            px[x, y] = int(255 * (v ** 1.6))
    return m

def metal_fill(mask, box, stops, horizontal=False):
    """Fill a mask with a metal gradient spanning box."""
    x0, y0, x1, y1 = box
    g = gradient_v((1, 256), stops).resize((x1 - x0, y1 - y0)) if not horizontal else \
        gradient_v((1, 256), stops).rotate(90, expand=True).resize((x1 - x0, y1 - y0))
    full = Image.new("RGB", mask.size, (0, 0, 0))
    full.paste(g, (x0, y0))
    return full

# ---------- background ----------
bg = gradient_v((S, S), [(0.0, (92, 14, 22)), (0.55, (52, 8, 16)), (1.0, (14, 4, 8))])
glow = radial((S, S), (S * 0.5, S * 0.46), S * 0.62, 255, 0)
warm = Image.new("RGB", (S, S), (176, 60, 28))
bg = Image.composite(warm, bg, glow.point(lambda v: int(v * 0.55)))
# vignette
vig = radial((S, S), (S * 0.5, S * 0.5), S * 0.80, 255, 0).point(lambda v: 255 - v)
bg = Image.composite(Image.new("RGB", (S, S), (6, 2, 4)), bg, vig.point(lambda v: int(v * 0.55)))
canvas = bg.convert("RGBA")

def layer(): return Image.new("RGBA", (S, S), (0, 0, 0, 0))

def paste_masked(base, fill_rgb_img, mask):
    fl = fill_rgb_img.convert("RGBA"); fl.putalpha(mask)
    return Image.alpha_composite(base, fl)

def soft_shadow(base, mask, offset=(0, 28), blur=34, alpha=150):
    sh = Image.new("L", (S, S), 0)
    sh.paste(mask, offset)
    sh = sh.filter(ImageFilter.GaussianBlur(blur)).point(lambda v: int(v * alpha / 255))
    black = Image.new("RGBA", (S, S), (0, 0, 0, 255)); black.putalpha(sh)
    return Image.alpha_composite(base, black)

def rot(pt, c, ang):
    s, co = math.sin(ang), math.cos(ang)
    x, y = pt[0] - c[0], pt[1] - c[1]
    return (c[0] + x * co - y * s, c[1] + x * s + y * co)

CX, CY = S // 2, int(S * 0.60)

# ---------- swords ----------
def sword_masks(angle_deg):
    """Return (blade_mask, blade_highlight_mask, guard_mask, grip_mask, pommel_mask) for a sword pointing up, rotated."""
    a = math.radians(angle_deg)
    c = (CX, CY)
    def poly(points):
        m = Image.new("L", (S, S), 0)
        ImageDraw.Draw(m).polygon([rot(p, c, a) for p in points], fill=255)
        return m
    top = CY - 880; bot = CY + 330
    bw = 84
    blade = poly([(CX - bw, bot), (CX - bw, top + 150), (CX, top), (CX + bw, top + 150), (CX + bw, bot)])
    # center fuller highlight (right half brighter)
    hi = poly([(CX, bot), (CX, top + 20), (CX + bw, top + 150), (CX + bw, bot)])
    gy = bot
    guard = poly([(CX - 250, gy - 8), (CX - 282, gy + 28), (CX - 200, gy + 72), (CX + 200, gy + 72), (CX + 282, gy + 28), (CX + 250, gy - 8),
                  (CX + 80, gy - 44), (CX - 80, gy - 44)])
    grip = poly([(CX - 38, gy + 72), (CX + 38, gy + 72), (CX + 34, gy + 330), (CX - 34, gy + 330)])
    pom = Image.new("L", (S, S), 0)
    pc = rot((CX, gy + 372), c, a)
    ImageDraw.Draw(pom).ellipse([pc[0] - 64, pc[1] - 64, pc[0] + 64, pc[1] + 64], fill=255)
    return blade, hi, guard, grip, pom

STEEL = [(0.0, (236, 242, 250)), (0.45, (170, 182, 200)), (1.0, (92, 102, 122))]
GOLD  = [(0.0, (255, 236, 150)), (0.5, (226, 170, 52)), (1.0, (140, 82, 20))]
LEATH = [(0.0, (110, 40, 36)), (1.0, (54, 16, 18))]

for ang in (-42, 42):
    blade, hi, guard, grip, pom = sword_masks(ang)
    allm = ImageChops.lighter(ImageChops.lighter(blade, guard), ImageChops.lighter(grip, pom))
    canvas = soft_shadow(canvas, allm)
    canvas = paste_masked(canvas, metal_fill(blade, (0, 0, S, S), [(0.0, STEEL[0][1]), (0.5, STEEL[1][1]), (1.0, STEEL[2][1])]), blade)
    # steel edge shading: bright right half
    canvas = paste_masked(canvas, Image.new("RGB", (S, S), (250, 252, 255)), hi.point(lambda v: int(v * 0.35)))
    # blade outline
    edge = ImageChops.subtract(blade, blade.filter(ImageFilter.MinFilter(5)))
    canvas = paste_masked(canvas, Image.new("RGB", (S, S), (60, 70, 92)), edge.point(lambda v: int(v * 0.55)))
    canvas = paste_masked(canvas, metal_fill(grip, (0, 0, S, S), LEATH), grip)
    canvas = paste_masked(canvas, metal_fill(guard, (0, CY + 300, S, CY + 420), GOLD), guard)
    canvas = paste_masked(canvas, metal_fill(pom, (0, CY + 600, S, CY + 760), GOLD), pom)

# ---------- crown ----------
crown = Image.new("L", (S, S), 0)
d = ImageDraw.Draw(crown)
base_y = CY - 150
bx0, bx1 = CX - 300, CX + 300
band_top = base_y - 110
# body with five points
pts = [(bx0, base_y), (bx0 - 20, band_top - 330), (bx0 + 130, band_top - 130), (CX - 150, band_top - 400),
       (CX, band_top - 170), (CX + 150, band_top - 400), (bx1 - 130, band_top - 130), (bx1 + 20, band_top - 330), (bx1, base_y)]
d.polygon(pts, fill=255)
# round jewel balls on the points
tips = [(bx0 - 20, band_top - 345), (CX - 150, band_top - 415), (CX, band_top - 195), (CX + 150, band_top - 415), (bx1 + 20, band_top - 345)]
for (tx, ty), r in zip(tips, (34, 38, 30, 38, 34)):
    d.ellipse([tx - r, ty - r, tx + r, ty + r], fill=255)
# base band
d.rounded_rectangle([bx0 - 24, base_y - 6, bx1 + 24, base_y + 118], radius=34, fill=255)
crown = crown.filter(ImageFilter.GaussianBlur(1.2)).point(lambda v: 255 if v > 127 else 0)

canvas = soft_shadow(canvas, crown, offset=(0, 34), blur=40, alpha=190)
canvas = paste_masked(canvas, metal_fill(crown, (0, band_top - 460, S, base_y + 130), GOLD), crown)
# inner bevel: darker inset + bright rim
inner = crown.filter(ImageFilter.MinFilter(15))
rim = ImageChops.subtract(crown, inner)
canvas = paste_masked(canvas, Image.new("RGB", (S, S), (255, 240, 170)), rim.point(lambda v: int(v * 0.55)))
shade = ImageChops.subtract(inner, inner.filter(ImageFilter.MinFilter(9)))
canvas = paste_masked(canvas, Image.new("RGB", (S, S), (120, 66, 14)), shade.point(lambda v: int(v * 0.40)))

# band details: dark groove + jewels
gd = Image.new("L", (S, S), 0); g = ImageDraw.Draw(gd)
g.rounded_rectangle([bx0 - 10, base_y + 10, bx1 + 10, base_y + 22], radius=6, fill=255)
canvas = paste_masked(canvas, Image.new("RGB", (S, S), (110, 60, 12)), gd.point(lambda v: int(v * 0.8)))
jew = Image.new("RGBA", (S, S), (0, 0, 0, 0)); jd = ImageDraw.Draw(jew)
for jx, col in ((CX - 210, (200, 24, 44)), (CX, (36, 110, 214)), (CX + 210, (200, 24, 44))):
    r = 46 if jx == CX else 36
    jy = base_y + 66
    jd.ellipse([jx - r - 8, jy - r - 8, jx + r + 8, jy + r + 8], fill=(120, 70, 14, 255))
    jd.ellipse([jx - r, jy - r, jx + r, jy + r], fill=col + (255,))
    jd.ellipse([jx - r * 0.55, jy - r * 0.6, jx - r * 0.05, jy - r * 0.1], fill=(255, 255, 255, 170))
canvas = Image.alpha_composite(canvas, jew)

# ---------- embers ----------
em = Image.new("RGBA", (S, S), (0, 0, 0, 0)); ed = ImageDraw.Draw(em)
for _ in range(46):
    x = rnd() * S; y = S * 0.35 + rnd() * S * 0.6
    if abs(x - CX) < 380 and abs(y - CY) < 420: continue
    r = 3 + rnd() * 7
    ed.ellipse([x - r, y - r, x + r, y + r], fill=(255, int(150 + rnd() * 80), int(40 + rnd() * 40), int(120 + rnd() * 110)))
em = em.filter(ImageFilter.GaussianBlur(1.6))
canvas = Image.alpha_composite(canvas, em)

# warm top-light bloom over the crown
bloom = radial((S, S), (CX, CY - 330), 640, 255, 0).point(lambda v: int(v * 0.22))
canvas = paste_masked(canvas, Image.new("RGB", (S, S), (255, 214, 120)), bloom)

# Scale the artwork (not the background) up around the icon center so it fills the frame
ZOOM = 1.16
art_bg = bg.convert("RGBA")
zoomed = canvas.resize((int(S * ZOOM), int(S * ZOOM)), Image.LANCZOS)
ox = (zoomed.width - S) // 2
oy = int((zoomed.height - S) / 2 + S * 0.01)
zoomed = zoomed.crop((ox, oy, ox + S, oy + S))
canvas = zoomed
final = canvas.convert("RGB").resize((OUT, OUT), Image.LANCZOS)

# ---------- write catalog ----------
here = os.path.dirname(os.path.abspath(__file__))
ic = os.path.join(here, "..", "KingsJustice", "Assets.xcassets", "AppIcon.appiconset")
os.makedirs(ic, exist_ok=True)
final.save(os.path.join(ic, "AppIcon.png"), optimize=True)
dark = ImageEnhance.Contrast(ImageEnhance.Brightness(final).enhance(0.82)).enhance(1.08)
dark.save(os.path.join(ic, "AppIcon-Dark.png"), optimize=True)
ImageOps.autocontrast(ImageOps.grayscale(final), cutoff=1).convert("RGB").save(os.path.join(ic, "AppIcon-Tinted.png"), optimize=True)
json.dump({"images": [
    {"filename": "AppIcon.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"},
    {"appearances": [{"appearance": "luminosity", "value": "dark"}], "filename": "AppIcon-Dark.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"},
    {"appearances": [{"appearance": "luminosity", "value": "tinted"}], "filename": "AppIcon-Tinted.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}],
    "info": {"author": "xcode", "version": 1}}, open(os.path.join(ic, "Contents.json"), "w"), indent=2)
final.save(os.path.join(here, "icon_preview_1024.png"))
print("done", final.size, final.mode)
