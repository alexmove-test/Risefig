"""Mahjong Rise — «Свои прикроют»: 15 s vertical TikTok spot (1080x1920, 30 fps).

Run: python promo/render_friends.py [--preview] [--at 1.2,4.4]
Flat 2D vector only: every shape is drawn here, music and SFX are synthesized.
Grid: 120 BPM, one beat = 0.5 s; all events below sit on beats or half-beats.
"""
from pathlib import Path
import math
import os
import sys
import wave
import subprocess
from functools import lru_cache
from multiprocessing import Pool
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
PROMO = ROOT / 'promo'
OUT = PROMO / 'Mahjong-Rise-Friends-15s.mp4'
BUILD = PROMO / 'friends-build'
FONTS = PROMO / 'fonts'
FFMPEG = Path(r'C:\Users\Main\AppData\Local\Programs\Python\Python312\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe')
W, H, FPS, DUR = 1080, 1920, 30, 15
S = 2
BEAT = .5

IVORY, JADE, PEACH, INK, CORAL = '#F5EFE3', '#2F8F6B', '#FF9E7A', '#1E2433', '#FF5A4E'
IVORY_D, JADE_D, JADE_L, PEACH_D, CORAL_D = '#E3D8C3', '#22694F', '#62B993', '#EC8460', '#C8413A'
INK_D, INK_L, INK_LL, NIGHT = '#151A26', '#283044', '#363F57', '#0D1018'
PLOT = INK_LL
TINT = {'jade': '#DCEEE4', 'peach': '#FBE0D3', 'ivory': '#E9E1D1', 'ink': '#D8DCE6'}

# ---- event sheet shared by picture and sound -------------------------------
SEED_LAND = 1.0
SLAMS = [2.0, 2.5, 3.0, 3.5]
LANDS = [s + .22 for s in SLAMS]
CARD_SNAP = 5.0
EYES = [5.0, 5.125, 5.25]
AV_POP = [5.5, 5.75, 6.0]
OFFER = 7.0
HEART_IN = 7.75
ADD_PRESS = 8.0
TICKS = [8.0, 8.25, 8.5]
ATK_PILL = 9.25
FOX_IN = 9.5
IMPACTS = [9.75, 10.0, 10.25, 10.625]
CRACK = 10.0
HELP_IN = [10.0, 10.125]
PROTECT = [10.5, 10.75]
ARRIVE = [10.75, 11.0]
MERGE = 11.0
SHATTER = [11.0, 11.125, 11.25, 11.375]
RING_POP = [11.55, 11.65, 11.75, 11.85]
THANKS_IN, THANKS_BTN, THANKS_PRESS, HEART_HIT = 12.0, 12.25, 12.5, 12.85
LOGO = 13.5
CTA_IN = 14.0
BADGES = [14.25, 14.375]


# ---- maths ------------------------------------------------------------------
def clamp(x, a=0., b=1.): return max(a, min(b, x))
def prog(t, a, b): return clamp((t - a) / (b - a))
def eout(x): x = clamp(x); return 1 - (1 - x) ** 3
def ein(x): x = clamp(x); return x ** 3
def eio(x): x = clamp(x); return 4 * x ** 3 if x < .5 else 1 - (-2 * x + 2) ** 3 / 2
def back(x, s=1.9): x = clamp(x) - 1; return 1 + (s + 1) * x ** 3 + s * x * x
def mix(a, b, p): return a + (b - a) * p
def hit(t, at, dur=.3): return (1 - prog(t, at, at + dur)) ** 2 if t >= at else 0.
def beatp(t): return math.exp(-((t / BEAT) % 1.) * 7)


def kf(t, keys, e=eio):
    if t <= keys[0][0]: return keys[0][1]
    for (a, va), (b, vb) in zip(keys, keys[1:]):
        if t <= b: return mix(va, vb, e(prog(t, a, b)))
    return keys[-1][1]


def press(t, at):
    if t < at - .05: return 0.
    if t < at: return eout(prog(t, at - .05, at))
    return 1 - eout(prog(t, at + .06, at + .2))


def rgb(h): h = h.lstrip('#'); return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))
def F(c, a=1.): return rgb(c) + (round(255 * clamp(a)),)
def lerpc(a, b, p): return '#%02x%02x%02x' % tuple(round(mix(x, y, clamp(p))) for x, y in zip(rgb(a), rgb(b)))


# ---- drawing primitives (coordinates in 1080x1920 space) --------------------
class C:
    def __init__(self, bg=None, w=W, h=H):
        self.im = Image.new('RGBA', (round(w * S), round(h * S)), F(bg) if bg else (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.im, 'RGBA')


def rrect(c, cx, cy, w, h, r, fill=None, a=1., outline=None, width=0):
    if w <= .5 or h <= .5 or a <= .003: return
    r = max(0, min(r, w / 2, h / 2))
    c.d.rounded_rectangle(((cx - w / 2) * S, (cy - h / 2) * S, (cx + w / 2) * S, (cy + h / 2) * S), r * S,
                          fill=F(fill, a) if fill else None, outline=F(outline, a) if outline else None,
                          width=max(1, round(width * S)) if outline else 0)


def circle(c, x, y, r, fill=None, a=1., outline=None, width=0):
    if r <= .3 or a <= .003: return
    c.d.ellipse(((x - r) * S, (y - r) * S, (x + r) * S, (y + r) * S), fill=F(fill, a) if fill else None,
                outline=F(outline, a) if outline else None, width=max(1, round(width * S)) if outline else 0)


def poly(c, pts, fill, a=1.):
    if a > .003: c.d.polygon([(x * S, y * S) for x, y in pts], fill=F(fill, a))


def line(c, pts, fill, width, a=1., caps=True):
    if a <= .003 or width <= .2: return
    c.d.line([(x * S, y * S) for x, y in pts], fill=F(fill, a), width=max(1, round(width * S)), joint='curve')
    if caps:
        for x, y in (pts[0], pts[-1]): circle(c, x, y, width / 2, fill, a)


def arc(c, x, y, r, a0, a1, fill, width, a=1.):
    if a > .003:
        c.d.arc(((x - r) * S, (y - r) * S, (x + r) * S, (y + r) * S), a0, a1, fill=F(fill, a), width=max(1, round(width * S)))


def comp(base, im, X, Y):
    X, Y = round(X), round(Y)
    x0, y0 = max(0, X), max(0, Y)
    x1, y1 = min(base.width, X + im.width), min(base.height, Y + im.height)
    if x1 > x0 and y1 > y0: base.alpha_composite(im.crop((x0 - X, y0 - Y, x1 - X, y1 - Y)), (x0, y0))


def fade(im, a):
    if a >= .999: return im
    im = im.copy()
    im.putalpha(im.getchannel('A').point([round(v * a) for v in range(256)]))
    return im


def blit(c, im, x, y, sc=1., ang=0., a=1.):
    if sc <= .004 or a <= .004: return
    if abs(sc - 1) > .002: im = im.resize((max(1, round(im.width * sc)), max(1, round(im.height * sc))), Image.Resampling.BICUBIC)
    if ang: im = im.rotate(ang, Image.Resampling.BICUBIC, expand=True)
    comp(c.im, fade(im, a), x * S - im.width / 2, y * S - im.height / 2)


@lru_cache(None)
def font(name, px, wght):
    f = ImageFont.truetype(str(FONTS / f'{name}.ttf'), px)
    f.set_variation_by_axes([wght])
    return f


class T:
    """Text sprite; `mid` is the cap-height centre row so mixed strings align."""
    def __init__(self, im, mid): self.im, self.mid = im, mid


@lru_cache(4096)
def txt(s, size, color=IVORY, name='Unbounded', wght=900, shadow=None):
    f = font(name, max(2, round(size * S)), wght)
    l, tp, r, b = f.getbbox(s)
    _, ht, _, hb = f.getbbox('H')
    top, bot = min(tp, ht), max(b, hb)
    sh = round(size * S * .05) if shadow else 0
    pad = round(3 * S)
    im = Image.new('RGBA', (r - l + 2 * pad + sh, bot - top + 2 * pad + sh))
    d = ImageDraw.Draw(im)
    if shadow: d.text((pad - l + sh, pad - top + sh), s, font=f, fill=F(shadow))
    d.text((pad - l, pad - top), s, font=f, fill=F(color))
    return T(im, pad + (ht + hb) / 2 - top)


def tw(t_): return t_.im.width / S


def blitT(c, t_, x, y, sc=1., a=1., anchor='c'):
    """anchor 'c' centres the text on (x, y); 'l' puts its left edge at x."""
    if sc <= .004 or a <= .004: return
    im, mid = t_.im, t_.mid * sc
    if abs(sc - 1) > .002: im = im.resize((max(1, round(im.width * sc)), max(1, round(im.height * sc))), Image.Resampling.BICUBIC)
    X = x * S - (im.width / 2 if anchor == 'c' else 0)
    comp(c.im, fade(im, a), X, y * S - mid)


def word(c, t_, x, y, t, t0, t1=None, dur=.18):
    """Kinetic word: rises out of a mask on t0, leaves upward through it on t1."""
    p = eout(prog(t, t0, t0 + dur))
    if p <= 0: return
    q = ein(prog(t, t1 - .15, t1)) if t1 is not None else 0
    if q >= 1: return
    im, h = t_.im, t_.im.height
    off = round((1 - p) * h - q * h)
    r0, r1 = max(0, -off), min(h, h - off)
    if r1 <= r0: return
    comp(c.im, im.crop((0, r0, im.width, r1)), x * S, y * S - t_.mid + r0 + off)


def headline(c, t, lines, end=None, x=80, maxw=900, align='l', name='Unbounded', shadow=None):
    for y, size, words in lines:
        def build(sz): return [txt(w, round(sz, 1), col, name, 900, shadow if col == PEACH else None) for w, _, col in words]
        ts = build(size)
        gap = lambda sz: sz * .26
        total = sum(map(tw, ts)) + gap(size) * (len(ts) - 1)
        if total > maxw:
            size *= maxw / total
            ts = build(size)
            total = sum(map(tw, ts)) + gap(size) * (len(ts) - 1)
        xx = x if align == 'l' else 540 - total / 2
        for (w, t0, _), t_ in zip(words, ts):
            word(c, t_, xx, y, t, t0, end)
            xx += tw(t_) + gap(size)


# ---- shapes -----------------------------------------------------------------
def leaf_pts(x, y, L, wd, ang, n=14):
    ca, sa = math.cos(ang), math.sin(ang)
    half = [(i / n * L, math.sin(math.pi * i / n) ** .85 * wd / 2) for i in range(n + 1)]
    pts = [(u, -v) for u, v in half] + [(u, v) for u, v in reversed(half)]
    return [(x + u * ca - v * sa, y + u * sa + v * ca) for u, v in pts]


def heart_pts(cx, cy, size, n=56):
    k = size / 34
    return [(cx + 16 * math.sin(a) ** 3 * k, cy - (13 * math.cos(a) - 5 * math.cos(2 * a) - 2 * math.cos(3 * a) - math.cos(4 * a)) * k - 2 * k)
            for a in (i / n * math.tau for i in range(n))]


def star_pts(x, y, r, inner=.32, n=4, rot=0.):
    return [(x + math.cos(rot + i * math.pi / n - math.pi / 2) * (r if i % 2 == 0 else r * inner),
             y + math.sin(rot + i * math.pi / n - math.pi / 2) * (r if i % 2 == 0 else r * inner)) for i in range(2 * n)]


def shield_pts(cx, cy, w, h, n=14):
    hw, hh = w / 2, h / 2
    p0, p1, p2 = (cx + hw, cy - hh + h * .36), (cx + hw, cy + hh * .6), (cx, cy + hh)
    right = [(cx + hw * .82, cy - hh), (cx + hw, cy - hh + h * .07), p0]
    for i in range(1, n + 1):
        u = i / n
        right.append(((1 - u) ** 2 * p0[0] + 2 * (1 - u) * u * p1[0] + u * u * p2[0],
                      (1 - u) ** 2 * p0[1] + 2 * (1 - u) * u * p1[1] + u * u * p2[1]))
    left = [(2 * cx - x, y) for x, y in reversed(right[:-1])]
    return right + left


def heart_leaf(c, x, y, size, a=1.):
    poly(c, heart_pts(x, y, size), JADE, a)
    k = size / 34
    line(c, [(x, y + 12 * k), (x, y - 6 * k)], IVORY, 2.6 * k, a)
    for s in (-1, 1): line(c, [(x, y + 3 * k), (x + 7 * s * k, y - 4 * k)], IVORY, 2 * k, a)
    line(c, [(x, y + 12 * k), (x + 3 * k, y + 19 * k)], JADE_D, 3 * k, a)


def burst(c, x, y, p, color, n=12, r0=40, r1=220, width=9, rot=.2):
    if not 0 < p < 1: return
    e = eout(p)
    for k in range(n):
        a = rot + k * math.tau / n
        ra = mix(r0, r1, e)
        rb = ra + (r1 - r0) * .32 * (1 - p)
        line(c, [(x + math.cos(a) * ra, y + math.sin(a) * ra), (x + math.cos(a) * rb, y + math.sin(a) * rb)], color, width * (1 - p) + 1.5)


def ring(c, x, y, p, color, r0=20, r1=160, width=8):
    if 0 < p < 1: circle(c, x, y, mix(r0, r1, eout(p)), None, 1, color, width * (1 - p) + 1)


def bolt(c, x, y, s, color, a=1.):
    poly(c, [(x + .2 * s, y - s), (x - .55 * s, y + .12 * s), (x - .02 * s, y + .12 * s), (x - .2 * s, y + s),
             (x + .55 * s, y - .16 * s), (x + .02 * s, y - .16 * s)], color, a)


def arrow_icon(c, x, y, s, color, a=1.):
    line(c, [(x - s, y + s * .7), (x + s * .5, y - s * .5)], color, s * .34, a)
    poly(c, [(x + s, y - s), (x + s * .05, y - s * .78), (x + s * .78, y - s * .05)], color, a)


def people_icon(c, x, y, s, color, a=1.):
    for dx, k in ((-.42, .8), (.38, 1.)):
        circle(c, x + dx * s, y - .38 * s * k, .34 * s * k, color, a)
        rrect(c, x + dx * s, y + .45 * s * k, 1.0 * s * k, .62 * s * k, .3 * s * k, color, a)


def check_mark(c, x, y, s, color, a=1.):
    line(c, [(x - s * .5, y), (x - s * .12, y + s * .38), (x + s * .55, y - s * .4)], color, s * .28, a)


def sparkle_icon(c, x, y, s, color, a=1.):
    poly(c, star_pts(x, y, s, .3), color, a)
    poly(c, star_pts(x + s * .9, y - s * .75, s * .42, .3), color, a)


def chip(c, x, y, label, size=32, fill=PEACH, fg=INK, sc=1., a=1., h=None, icon=None, icon_col=None,
         lip=None, pr=0., name='Montserrat', wght=900, anchor='c', extra=0.):
    if sc <= .01 or a <= .01: return 0
    t_ = txt(label, size, fg, name, wght)
    h = h or size * 2.15
    padx = h * .45
    iw = h * .62 if icon else 0
    w = (tw(t_) + 2 * padx + iw + extra) * sc
    X = x if anchor == 'c' else x + w / 2
    if lip: rrect(c, X, y + 9 * sc, w, h * sc, h * sc / 2, lip, a)
    yy = y + 9 * sc * pr if lip else y
    sw = 1 - .03 * pr
    rrect(c, X, yy, w * sw, h * sc, h * sc / 2, fill, a)
    if icon: icon(c, X - w / 2 + (padx * .85 + iw / 2) * sc, yy, h * .26 * sc, icon_col or fg, a)
    blitT(c, t_, X + (iw - extra) * sc / 2 - (padx * .08 * sc if icon else 0), yy, sc, a)
    return w


# ---- sprites ----------------------------------------------------------------
@lru_cache(None)
def tile_sprite(kind):
    c = C(None, 170, 226)
    cx, cy = 85, 104
    rrect(c, cx, cy + 14, 150, 192, 30, JADE_D)
    rrect(c, cx, cy, 150, 192, 30, IVORY)
    rrect(c, cx, cy, 128, 170, 22, None, outline=IVORY_D, width=4)
    if kind == 0:
        for dx, dy, col in ((-32, -46, PEACH), (0, 0, JADE), (32, 46, PEACH)):
            circle(c, cx + dx, cy + dy, 23, col)
            circle(c, cx + dx, cy + dy, 8, IVORY)
    elif kind == 1:
        for dx in (-34, 0, 34):
            rrect(c, cx + dx, cy, 22, 130, 11, JADE)
            for dy in (-28, 24): rrect(c, cx + dx, cy + dy, 30, 9, 4, JADE_D)
    elif kind == 2:
        rrect(c, cx, cy - 8, 88, 62, 14, None, outline=INK, width=13)
        rrect(c, cx, cy, 16, 142, 8, INK)
        circle(c, cx + 42, cy + 58, 10, PEACH)
    elif kind == 3:
        for k in range(5):
            a = k * math.tau / 5 - math.pi / 2
            circle(c, cx + math.cos(a) * 30, cy + math.sin(a) * 30, 24, PEACH)
        circle(c, cx, cy, 17, JADE)
    else:
        blitT(c, txt(kind, 108, JADE if kind == 'M' else PEACH_D), cx, cy)
    return c.im


@lru_cache(None)
def fox_sprite():
    c = C(None, 260, 290)
    poly(c, leaf_pts(92, 236, 158, 78, math.radians(-128)), PEACH_D)
    a = math.radians(-128)
    poly(c, leaf_pts(92 + math.cos(a) * 100, 236 + math.sin(a) * 100, 58, 44, a), IVORY)
    circle(c, 130, 214, 70, PEACH)
    poly(c, leaf_pts(130, 270, 92, 72, math.radians(-90)), IVORY)
    for sx in (-1, 1):
        poly(c, [(130 + sx * 78, 98), (130 + sx * 70, 18), (130 + sx * 18, 66)], PEACH)
        poly(c, [(130 + sx * 66, 84), (130 + sx * 63, 42), (130 + sx * 36, 68)], INK)
    c.d.ellipse(((130 - 86) * S, (98 - 52) * S, (130 + 86) * S, (98 + 52) * S), fill=F(PEACH))
    poly(c, [(44, 100), (216, 100), (130, 176)], PEACH)
    poly(c, [(60, 112), (130, 176), (200, 112), (130, 138)], IVORY)
    for sx in (-1, 1):
        circle(c, 130 + sx * 33, 100, 10, INK)
        circle(c, 130 + sx * 33 + 3, 96, 3.4, IVORY)
    circle(c, 130, 168, 11, INK)
    for sx in (-1, 1): rrect(c, 130 + sx * 30, 278, 46, 22, 11, IVORY)
    return c.im


# ---- game objects -----------------------------------------------------------
STEM = [0, 70, 128, 182, 205]
LEAF1 = [0, 40, 64, 74, 80]
LEAF2 = [0, 34, 56, 68, 76]
LEAF3 = [0, 0, 30, 44, 52]


def interp(tab, s):
    i = max(0, min(int(math.floor(s)), len(tab) - 2))
    return mix(tab[i], tab[i + 1], s - i)


def grow_stage(t): return sum(back(prog(t, L, L + .24), 2.4) for L in LANDS)


def plant(c, bx, by, s, sc=1., v=0, t=0.):
    if s <= .02: return
    h = interp(STEM, s) * sc
    sw = math.sin(t * 2.6) * 4 * sc * clamp(s / 2)
    tx, ty = bx + sw, by - h
    pts = [(mix(bx, tx, u) + math.sin(u * math.pi) * 6 * sc, by - h * u) for u in np.linspace(0, 1, 10)]
    line(c, pts, JADE, max(2.5, 11 * sc * clamp(s)))
    for fy, side, tab in ((.32, -1, LEAF1), (.55, 1, LEAF2), (.76, -1, LEAF3)):
        L = interp(tab, s) * sc
        if L < 2: continue
        x, y = mix(bx, tx, fy) + math.sin(fy * math.pi) * 6 * sc, by - h * fy
        ang = math.radians(-150 if side < 0 else -30) + math.sin(t * 2 + fy * 5) * .07
        poly(c, leaf_pts(x, y, L, L * .52, ang), JADE)
        line(c, [(x, y), (x + math.cos(ang) * L * .66, y + math.sin(ang) * L * .66)], JADE_D, max(1, 3 * sc), caps=False)
    b = clamp(s - 2, 0, 1.3) * (1 - clamp((s - 3) * 2.5))
    if b > 0:
        for s_ in (-1, 1): poly(c, leaf_pts(tx, ty + 4 * sc, 30 * b * sc, 18 * b * sc, math.radians(-90 + 52 * s_)), JADE_D)
        poly(c, leaf_pts(tx, ty + 8 * sc, 54 * b * sc, 38 * b * sc, math.radians(-90)), PEACH)
    f = clamp(s - 3, 0, 1.4)
    if f <= 0: return
    rot = math.radians(t * 22)
    if v == 0:
        for k in range(8): poly(c, leaf_pts(tx, ty, 84 * f * sc, 50 * f * sc, rot + k * math.pi / 4), PEACH)
        for k in range(8): poly(c, leaf_pts(tx, ty, 52 * f * sc, 30 * f * sc, rot + math.pi / 8 + k * math.pi / 4), IVORY)
        circle(c, tx, ty, 21 * f * sc, INK)
        circle(c, tx, ty, 8 * f * sc, PEACH)
    elif v == 1:
        for k in range(6):
            a = k * math.tau / 6 + rot * .4
            circle(c, tx + math.cos(a) * 36 * f * sc, ty + math.sin(a) * 36 * f * sc, 24 * f * sc, JADE_L)
        circle(c, tx, ty, 22 * f * sc, PEACH)
    elif v == 2:
        for a in (-90, -130, -50):
            poly(c, leaf_pts(tx, ty + 26 * f * sc, 80 * f * sc, 46 * f * sc, math.radians(a)), INK_LL)
        circle(c, tx, ty + 8 * f * sc, 12 * f * sc, IVORY)
    else:
        for k in range(12): poly(c, leaf_pts(tx, ty, 62 * f * sc, 20 * f * sc, rot * .6 + k * math.tau / 12), PEACH_D)
        circle(c, tx, ty, 18 * f * sc, INK)


def plot_bed(c, cx, cy, w=460, h=130, sc=1.):
    w, h = w * sc, h * sc
    rrect(c, cx, cy + 10 * sc, w, h, 30 * sc, INK_D)
    rrect(c, cx, cy, w, h, 30 * sc, PLOT)
    for k in (-1, 0, 1): line(c, [(cx - w * .36, cy + k * h * .25), (cx + w * .36, cy + k * h * .25)], INK_L, 6 * sc)
    rrect(c, cx, cy, w, h, 30 * sc, None, outline=JADE, width=7 * sc)


CW, CH = 340, 460


def card_body(c, cx, cy, w, h, r, body=IVORY, shadow=INK_D):
    rrect(c, cx, cy + 14 * h / CH, w, h, r, shadow)
    rrect(c, cx, cy, w, h, r, body)


def card_content(c, cx, cy, sc, name, power, v, tint, t, a=1., hero=False, plant_s=4.):
    rrect(c, cx, cy - 77 * sc, 304 * sc, 270 * sc, 24 * sc, TINT[tint], a)
    if a > .3: plant(c, cx, cy + 36 * sc, plant_s, .6 * sc, v, t)
    blitT(c, txt(name, 42, INK, 'Montserrat', 900), cx - 150 * sc, cy + 96 * sc, sc, a, 'l')
    chip(c, cx - 152 * sc, cy + 166 * sc, f'Сила {power}', 28, PEACH if hero else IVORY_D, INK, sc, a, h=58, icon=bolt, anchor='l')
    if hero:
        poly(c, star_pts(cx + 128 * sc, cy - 196 * sc, 40 * sc, .5, 5, t * .8), PEACH, a)
        poly(c, star_pts(cx + 128 * sc, cy - 196 * sc, 16 * sc, .5, 5, t * .8), IVORY, a)


def card(c, cx, cy, sc, name, power, v, tint, t, hero=False, glow=0.):
    if sc <= .01: return
    if glow > 0: rrect(c, cx, cy, (CW + 26) * sc, (CH + 26) * sc, 46 * sc, None, glow, PEACH, 7 * sc)
    card_body(c, cx, cy, CW * sc, CH * sc, 34 * sc)
    card_content(c, cx, cy, sc, name, power, v, tint, t, 1., hero)


def hero_card(c, t, cx, cy, sc, m=1., glow=0.):
    if m >= 1: return card(c, cx, cy, sc, 'Ты', 42, 0, 'jade', t, True, glow)
    X, Y = mix(540, cx, m), mix(1180, cy, m)
    w, h = mix(460, CW * sc, m), mix(130, CH * sc, m)
    rrect(c, X, Y + 12, w, h, mix(30, 34 * sc, m), INK_D)
    rrect(c, X, Y, w, h, mix(30, 34 * sc, m), lerpc(PLOT, IVORY, m))
    ia = prog(m, .45, .9)
    rrect(c, X, Y - 77 * sc * m, 304 * sc * mix(.6, 1, m), 270 * sc * m, 24 * sc, TINT['jade'], ia)
    plant(c, mix(540, X, m), mix(1160, Y + 36 * sc, m), 4, mix(1, .6 * sc, m), 0, t)
    if m > .7:
        a = prog(m, .7, 1)
        blitT(c, txt('Ты', 42, INK, 'Montserrat', 900), X - 150 * sc, Y + 96 * sc, sc, a, 'l')
        chip(c, X - 152 * sc, Y + 166 * sc, 'Сила 42', 28, PEACH, INK, sc, a, h=58, icon=bolt, anchor='l')


AV = {'Аня': (PEACH, INK, 'А'), 'Kai': (JADE, IVORY, 'K'), 'Somchai': (IVORY, INK, 'S'), 'fox': (INK, IVORY, '')}


def avatar(c, name, x, y, r=62, sc=1., a=1., ring_col=IVORY, label=None, check=0.):
    if sc <= .01: return
    fill, fg, ch = AV[name]
    R = r * sc
    circle(c, x, y, R + 7 * sc, ring_col, a)
    circle(c, x, y, R, fill, a)
    if name == 'fox': blit(c, fox_sprite(), x, y + 8 * sc, sc * r / 140, a=a)
    else: blitT(c, txt(ch, r * .95, fg), x, y, sc, a)
    if label: blitT(c, txt(name, 28, label, 'Montserrat', 800), x, y + R + 34 * sc, sc, a)
    if check > 0:
        k = back(check)
        circle(c, x + R * .74, y + R * .72, 25 * sc * k, ring_col, a)
        circle(c, x + R * .74, y + R * .72, 20 * sc * k, JADE, a)
        check_mark(c, x + R * .74, y + R * .72, 20 * sc * k, IVORY, a)


def eye(c, x, y, sc, a=1.):
    if sc <= .01: return
    poly(c, leaf_pts(x - 56 * sc, y, 112 * sc, 66 * sc, 0), IVORY, a)
    circle(c, x, y, 23 * sc, INK, a)
    circle(c, x + 7 * sc, y - 7 * sc, 7 * sc, PEACH, a)


def shield(c, x, y, h, inner=JADE, rim=IVORY, a=1., emblem=PEACH):
    w = h * .84
    poly(c, shield_pts(x, y, w, h), rim, a)
    poly(c, shield_pts(x, y - h * .03, w * .76, h * .78), inner, a)
    if emblem: poly(c, leaf_pts(x, y + h * .14, h * .36, h * .2, math.radians(-90)), emblem, a)


def big_shield(c, x, y, h):
    w = h * .84
    poly(c, shield_pts(x, y, w * 1.06, h * 1.06), IVORY)
    poly(c, shield_pts(x, y, w, h), JADE_L)
    poly(c, shield_pts(x, y - h * .03, w * .8, h * .8), PEACH)
    poly(c, shield_pts(x, y - h * .06, w * .58, h * .58), JADE)
    poly(c, leaf_pts(x, y + h * .06, h * .26, h * .14, math.radians(-90)), IVORY)


def arrow(c, x, y, ang, a=1., L=128):
    ca, sa = math.cos(ang), math.sin(ang)
    P = lambda u, v: (x + u * ca - v * sa, y + u * sa + v * ca)
    for k, off in enumerate((-.0, 26, -26)):
        line(c, [P(-L - 50 - 30 * k, off * .6), P(-L - 190 - 20 * k, off * .6)], CORAL, 4, a * .32)
    line(c, [P(-L, 0), P(-30, 0)], CORAL, 11, a)
    poly(c, [P(4, 0), P(-44, -24), P(-32, 0), P(-44, 24)], CORAL, a)
    for s in (-1, 1): poly(c, [P(-L + 8, 0), P(-L - 18, 20 * s), P(-L - 2, 20 * s), P(-L + 26, 0)], CORAL_D, a)


def button(c, x, y, label, t, t_in, t_press=None, size=36, fill=PEACH, fg=INK, lip=INK_D, h=104, icon=None, pulse=0.):
    s = back(prog(t, t_in, t_in + .28))
    if s <= .01: return
    pr = press(t, t_press) if t_press is not None else 0
    chip(c, x, y, label, size, fill, fg, s * (1 - .05 * pr + pulse), h=h, icon=icon, lip=lip, pr=pr)


# ---- backgrounds & transitions ----------------------------------------------
def deco(c, t, col, a=1., beat=True):
    bp = beatp(t) if beat else 0
    for cx, cy, r, spd in ((930, 330, 300, .22), (110, 1600, 400, -.18), (1010, 1500, 150, .4)):
        rr = r * (1 + .02 * bp)
        a0 = math.degrees(t * spd)
        arc(c, cx, cy, rr, a0, a0 + 230, col, 4, a)
        arc(c, cx, cy, rr * .78, -a0 * 1.3 + 40, -a0 * 1.3 + 140, col, 4, a)
    for k in range(14):
        x = (k * 331 + 60 * math.sin(t * .7 + k)) % W
        y = (k * 613 - t * (18 + k % 4 * 8)) % H
        if k % 3 == 0:
            line(c, [(x - 10, y), (x + 10, y)], col, 4, a)
            line(c, [(x, y - 10), (x, y + 10)], col, 4, a)
        else:
            circle(c, x, y, 3 + k % 3, col, a)


GRID = {}


def annulus(c, cx, cy, ri, ro, color):
    if 'yy' not in GRID:
        yy, xx = np.mgrid[0:H * S, 0:W * S].astype(np.float32)
        GRID['yy'], GRID['xx'] = yy, xx
    d = np.hypot(GRID['xx'] - cx * S, GRID['yy'] - cy * S)
    m = np.clip(ro * S - d, 0, 1) * np.clip(d - ri * S, 0, 1)
    layer = Image.new('RGBA', c.im.size, F(color))
    layer.putalpha(Image.fromarray((m * 255).astype(np.uint8)))
    c.im.alpha_composite(layer)


@lru_cache(8)
def vignette(level):
    w, h = W // 4, H // 4
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    d = np.sqrt(((xx - w / 2) / (w * .62)) ** 2 + ((yy - h * .58) / (h * .56)) ** 2)
    a = np.clip((d - .5) / .7, 0, 1) ** 1.4 * (level / 10)
    arr = np.zeros((h, w, 4), np.uint8)
    arr[..., :3] = rgb(CORAL)
    arr[..., 3] = (a * 255).astype(np.uint8)
    return Image.fromarray(arr).resize((W * S, H * S), Image.Resampling.BILINEAR)


# ---- scenes -----------------------------------------------------------------
def s_hook(t):
    c = C(INK)
    deco(c, t, INK_L)
    headline(c, t, [(300, 110, [('КАК', -.12, IVORY), ('ЗАВЕСТИ', .25, IVORY)]),
                    (480, 190, [('ДРУЗЕЙ', .5, PEACH)]),
                    (660, 150, [('В', .75, IVORY), ('ИГРЕ?', 1.0, IVORY)])])
    plot_bed(c, 540, 1180, sc=1 + .025 * beatp(t))
    if t >= .75:
        f = prog(t, .75, SEED_LAND)
        y = mix(780, 1162, ein(f))
        sq = hit(t, SEED_LAND, .18)
        sx, sy = 1 + .7 * sq - .25 * (f < 1) * f, 1 - .45 * sq + .6 * (f < 1) * f
        c.d.ellipse(((540 - 16 * sx) * S, (y - 16 * sy) * S, (540 + 16 * sx) * S, (y + 16 * sy) * S), fill=F(PEACH))
        if f < 1: line(c, [(540, y - 30), (540, y - 30 - 120 * f)], PEACH, 5, .45, caps=False)
        ring(c, 540, 1162, prog(t, SEED_LAND, SEED_LAND + .45), IVORY, 20, 170, 8)
        ring(c, 540, 1162, prog(t, SEED_LAND + .08, SEED_LAND + .6), PEACH, 20, 260, 6)
    return c


def drop(c, x, y, r, stretch=1.):
    L = r * (1.4 + 1.1 * stretch)
    pts = [(x, y - L)] + [(x + r * math.cos(math.radians(a)), y + r * math.sin(math.radians(a))) for a in range(-20, 201, 12)]
    poly(c, pts, JADE_L)
    circle(c, x - r * .35, y - r * .1, r * .26, IVORY, .9)


def s_grow(t):
    c = C(INK)
    deco(c, t, INK_L)
    headline(c, t, [(290, 130, [('ВЫРАСТИ', 1.5, IVORY)]),
                    (440, 130, [('ЧТО-ТО', 2.0, IVORY), ('РЕДКОЕ', 2.5, PEACH)])], end=4.0)
    plot_bed(c, 540, 1180)
    s = grow_stage(t)
    if s < .6: circle(c, 540, 1162, 16 * (1 - s / .6), PEACH)
    if s > 3.4:
        for k in range(4):
            a = t * 1.4 + k * math.pi / 2
            poly(c, star_pts(540 + math.cos(a) * 150, 955 + math.sin(a) * 120, 18 + 6 * math.sin(t * 9 + k), .3), IVORY, prog(s, 3.4, 3.9))
    plant(c, 540, 1160, s, 1., 0, t)
    for i, ts in enumerate(SLAMS):
        enter = ts - .45
        if not enter <= t < LANDS[i] + .5: continue
        if t < ts + .06:
            p, q = eout(prog(t, enter, ts - .08)), ein(prog(t, ts - .08, ts))
            for side in (-1, 1):
                x = mix(mix(540 + side * 720, 540 + side * 92, p), 540 + side * 30, q)
                blit(c, tile_sprite(i % 4), x, 680, .86 * (1 - .3 * q), side * -mix(26, 0, p), 1 - prog(t, ts, ts + .06))
        burst(c, 540, 680, prog(t, ts, ts + .32), IVORY, 10, 60, 210, 8)
        if ts <= t < LANDS[i]:
            f = prog(t, ts, LANDS[i])
            drop(c, 540, mix(690, 1120, ein(f)), 26 * back(prog(t, ts, ts + .08)), f)
        L = LANDS[i]
        ring(c, 540, 1150, prog(t, L, L + .4), JADE_L, 20, 200, 8)
        for k in range(6):
            p = prog(t, L, L + .35)
            if 0 < p < 1:
                a = math.radians(-160 + k * 28)
                circle(c, 540 + math.cos(a) * 120 * eout(p), 1150 + math.sin(a) * 90 * eout(p) + 80 * p * p, 9 * (1 - p), JADE_L)
    if s > 3.5: burst(c, 540, 955, prog(t, LANDS[3], LANDS[3] + .45), PEACH, 14, 110, 290, 10)
    # growth meter
    fill = sum(eout(prog(t, L, L + .18)) for L in LANDS) / 4
    blitT(c, txt('РОСТ', 28, IVORY, 'Montserrat', 900), 200, 1330, a=.85, anchor='l')
    rrect(c, 600, 1330, 560, 34, 17, INK_L)
    if fill > 0: rrect(c, 320 + 280 * fill, 1330, 560 * fill, 34, 17, lerpc(PEACH, JADE_L, prog(fill, .7, 1)))
    for k in (1, 2, 3): rrect(c, 320 + 140 * k, 1330, 5, 34, 2, INK)
    return c


OTHERS = [(-2, 'Мира', 31, 2, 'ink'), (-1, 'Лео', 37, 1, 'peach'), (1, 'Тао', 35, 3, 'ivory'), (2, 'Ника', 28, 1, 'peach')]
AVPOS = {'Аня': (270, 700), 'Kai': (540, 700), 'Somchai': (810, 700)}
NAMES = ['Аня', 'Kai', 'Somchai']
RIBBON_Y = 1095


def ribbon(c, t, spread=0., a=1.):
    hb = 420 * eout(prog(t, 4.45, 4.7))
    rrect(c, 540, RIBBON_Y, 1200, hb, 0, INK_L, a)
    if hb > 300: chip(c, 80, RIBBON_Y - 210, 'ВИТРИНА', 24, JADE, IVORY, a=a * prog(t, 4.6, 4.8), h=50, anchor='l')
    slide = (1 - eout(prog(t, 4.45, 4.95))) * 1250
    for k, name, power, v, tint in OTHERS:
        card(c, 540 + k * 285 + slide + spread * (1 if k > 0 else -1), RIBBON_Y, .7, name, power, v, tint, t + k)


def s_show(t):
    c = C(INK)
    deco(c, t, INK_L)
    headline(c, t, [(290, 130, [('ЕГО', 4.0, IVORY), ('УВИДЯТ', 4.5, IVORY)]),
                    (440, 150, [('СОСЕДИ', 5.0, PEACH)])], end=6.5)
    if t >= 4.45: ribbon(c, t)
    if t < 4.5:
        hero_card(c, t, 540, 1050, 1, eio(prog(t, 4.0, 4.45)))
    elif t < 4.75:
        p = eout(prog(t, 4.5, 4.75))
        hero_card(c, t, 540, mix(1050, 990, p), mix(1, .86, p))
    else:
        p = back(prog(t, 4.75, CARD_SNAP))
        hero_card(c, t, 540, mix(990, RIBBON_Y, p), mix(.86, .78, p), glow=prog(t, CARD_SNAP, CARD_SNAP + .2))
    ring(c, 540, RIBBON_Y, prog(t, CARD_SNAP, CARD_SNAP + .4), PEACH, 160, 420, 10)
    top = (540, RIBBON_Y - CH * .78 / 2)
    for i, name in enumerate(NAMES):
        e0, m0 = EYES[i], AV_POP[i]
        if t < m0 + .1:
            p = eout(prog(t, e0, e0 + .3))
            if p > 0:
                x, y = mix(top[0], AVPOS[name][0], p), mix(top[1], AVPOS[name][1], p) - 60 * math.sin(p * math.pi)
                eye(c, x, y, back(prog(t, e0, e0 + .3)) * (1 - ein(prog(t, m0 - .08, m0 + .06))) * .9)
        if t >= m0 - .02:
            avatar(c, name, *AVPOS[name], sc=back(prog(t, m0 - .02, m0 + .26)), label=IVORY)
            ring(c, *AVPOS[name], prog(t, m0, m0 + .35), PEACH, 60, 130, 6)
    return c


def s_meet(t):
    c = C(INK)
    deco(c, t, INK_L)
    headline(c, t, [(290, 130, [('ТАК', 6.5, IVORY), ('НАХОДЯТ', 6.75, IVORY)]),
                    (440, 150, [('СВОИХ', 7.0, PEACH)])], end=9.0)
    o = ein(prog(t, 6.5, 6.85))
    if o < 1: ribbon(c, t, 760 * o, 1 - o)
    hx = kf(t, [(7.25, 540), (7.55, 760), (7.85, 680)])
    hs = kf(t, [(7.25, .78), (7.55, .66)])
    htop = RIBBON_Y - CH * hs / 2
    for i, name in enumerate(NAMES):
        l = eout(prog(t, 6.5 + i * .1, 6.85 + i * .1))
        ax, ay = AVPOS[name][0], AVPOS[name][1] + 112
        ex, ey = mix(ax, hx, l), mix(ay, htop - 6, l)
        line(c, [(ax, ay), (ex, ey)], IVORY, 5, .55)
        if l >= 1:
            f = (t * 1.6 + i * .33) % 1
            circle(c, mix(ax, hx, f), mix(ay, htop, f), 8, PEACH)
    if t >= 7.25:
        p = eout(prog(t, 7.25, 7.55))
        ax = kf(t, [(7.25, 270), (7.55, 320), (7.85, 400)])
        ay = mix(AVPOS['Аня'][1], RIBBON_Y, p)
        card(c, ax, ay, .66 * back(prog(t, 7.25, 7.55)), 'Аня', 39, 1, 'peach', t)
        if t >= 7.85:
            for k in range(5):
                x = mix(ax + 120, hx - 120, (k + .5) / 5)
                circle(c, x, RIBBON_Y + 150, 5, PEACH, prog(t, 7.85 + k * .03, 7.95 + k * .03))
    hero_card(c, t, hx, RIBBON_Y, hs, glow=1.)
    if t >= HEART_IN:
        k = back(prog(t, HEART_IN, HEART_IN + .25)) * (1 + .22 * hit(t, 8.0, .3) + .22 * hit(t, 8.5, .3))
        circle(c, 540, 1040, 74 * k, INK, .9)
        heart_leaf(c, 540, 1040, 104 * k)
        ring(c, 540, 1040, prog(t, 8.0, 8.4), JADE_L, 60, 170, 7)
    for i, name in enumerate(NAMES):
        avatar(c, name, *AVPOS[name], label=IVORY, check=prog(t, TICKS[i], TICKS[i] + .25))
    if t >= OFFER:
        p = eout(prog(t, OFFER, OFFER + .25)) * (1 - ein(prog(t, 8.75, 8.95)))
        x = mix(-700, 80, p)
        w = chip(c, x, 562, 'Предлагает скрещивание', 30, IVORY, INK, h=76, anchor='l', extra=48,
                 icon=lambda c_, x_, y_, s_, col, a: None)
        avatar(c, 'Аня', x + 40, 562, 26, ring_col=INK)
        poly(c, leaf_pts(x + w - 34, 576, 34, 18, math.radians(-120)), JADE)
        poly(c, leaf_pts(x + w - 34, 576, 34, 18, math.radians(-60)), PEACH_D)
    if t >= HEART_IN:
        n = sum(t >= k for k in TICKS)
        s = back(prog(t, HEART_IN, HEART_IN + .25))
        w = chip(c, 540 - 26 * s, 880, 'Знакомые', 30, IVORY, INK, s, h=70, icon=people_icon)
        bx = 540 - 26 * s + w / 2 + 6 * s
        circle(c, bx, 880, 37 * s * (1 + .25 * hit(t, max([k for k in TICKS if k <= t], default=-9), .25)), PEACH)
        c_im = txt(str(n), 34, INK)
        prev = txt(str(max(0, n - 1)), 34, INK)
        roll = eout(prog(t, max([k for k in TICKS if k <= t], default=-9), max([k for k in TICKS if k <= t], default=-9) + .14))
        if s > .5:
            if roll < 1 and n > 0:
                blitT(c, prev, bx, 880 - 30 * roll, s, 1 - roll)
                blitT(c, c_im, bx, 880 + 30 * (1 - roll), s, roll)
            else:
                blitT(c, c_im, bx, 880, s)
    button(c, 540, 1345, 'Добавить в знакомые', t, 7.7, ADD_PRESS, 34, icon=people_icon)
    return c


ATTACKERS = [(9.75, 1010, 1130), (10.0, 1230, 1170), (10.25, 960, 1110), (10.625, 1180, 1190),
             (11.0, 1000, 1020), (11.125, 1260, 1240), (11.25, 1120, 1120), (11.375, 940, 990)]
FOX_XY, SH_XY = (690, 1200), (805, 1150)
HELP_Y = [600, 770]


def help_card(c, t, i, name):
    p = eout(prog(t, HELP_IN[i], HELP_IN[i] + .25))
    if p <= 0: return None
    X = mix(-640, 60, p)
    w, y = 560, HELP_Y[i]
    rrect(c, X + w / 2, y + 9, w, 128, 32, INK_D)
    rrect(c, X + w / 2, y, w, 128, 32, IVORY)
    avatar(c, name, X + 66, y, 40, ring_col=INK)
    blitT(c, txt('Ищет защиту', 28, INK, 'Montserrat', 900), X + 122, y, anchor='l')
    pr = press(t, PROTECT[i])
    done = t >= PROTECT[i]
    chip(c, X + 455, y, 'Защитить', 26, JADE_D if done else JADE, IVORY, 1 - .05 * pr, h=68, lip=INK if not done else None, pr=pr)
    return X + 455, y


def s_attack(t):
    c = C(NIGHT)
    lvl = .18 + .4 * max([hit(t, i, .35) for i in IMPACTS + [9.0]] + [0])
    if t < MERGE + .2: c.im.alpha_composite(vignette(round(lvl * 10)))
    for k in range(7):
        y = 820 + k * 90
        x = (1400 - ((t * 1900 + k * 377) % 1900))
        line(c, [(x, y), (x + 160 + 40 * (k % 3), y)], CORAL, 4, .14, caps=False)
    headline(c, t, [(290, 130, [('А', 9.0, IVORY), ('ЕСЛИ', 9.25, IVORY)]),
                    (440, 150, [('НАПАДУТ —', 9.5, CORAL)])], end=11.5)
    plot_bed(c, 360, 1300, 360, 110)
    plant(c, 360, 1255, 4, .82, 0, t)
    s = back(prog(t, ATK_PILL, ATK_PILL + .25)) * (1 + .1 * max(hit(t, i, .2) for i in IMPACTS))
    chip(c, 770, 880, 'Атака 58', 32, CORAL, IVORY, s, a=1 - .5 * prog(t, MERGE, MERGE + .3), h=78, icon=arrow_icon)
    if t >= FOX_IN - .05:
        fy = mix(2150, FOX_XY[1], back(prog(t, FOX_IN - .05, FOX_IN + .22)))
        blit(c, fox_sprite(), FOX_XY[0], fy, .92)
    jolt = sum(hit(t, i, .18) for i in IMPACTS) * 10
    if t < MERGE and t >= FOX_IN:
        sy = mix(1650, SH_XY[1], back(prog(t, FOX_IN, FOX_IN + .25)))
        sx = SH_XY[0] - jolt
        shield(c, sx, sy, 172)
        cr = eout(prog(t, CRACK, CRACK + .1))
        if cr > 0:
            pts = [(sx + 40, sy - 78), (sx + 14, sy - 34), (sx + 30, sy - 8), (sx - 4, sy + 30), (sx + 8, sy + 62)]
            n = max(2, round(len(pts) * cr))
            line(c, pts[:n], INK, 7)
            line(c, [(sx + 14, sy - 34), (sx - 26, sy - 22)][:2], INK, 6, cr)
            line(c, [(sx + 30, sy - 8), (sx + 56, sy + 14)], INK, 5, cr)
    if t >= MERGE:
        k = back(prog(t, MERGE, MERGE + .22), 2.4)
        hh = 172 * mix(1, 2.15, k)
        big_shield(c, SH_XY[0] - 10 * k, SH_XY[1] - 30 * k, hh)
        burst(c, SH_XY[0], SH_XY[1] - 30, prog(t, MERGE, MERGE + .4), IVORY, 16, 160, 380, 10)
        ring(c, SH_XY[0], SH_XY[1] - 30, prog(t, MERGE, MERGE + .45), JADE_L, 150, 520, 12)
    for ti, sx0, sy0 in ATTACKERS:
        f = prog(t, ti - .38, ti)
        if t < ti - .38: continue
        if ti >= MERGE:
            tx, ty = SH_XY[0] + 165, sy0 * .5 + SH_XY[1] * .5 - 40
        else:
            tx, ty = SH_XY[0] + 60, mix(SH_XY[1] - 40, SH_XY[1] + 30, (sx0 % 7) / 6)
        x0, y0 = sx0 + 300, sy0 - 120
        if t < ti:
            ang = math.atan2(ty - y0, tx - x0)
            arrow(c, mix(x0, tx, f), mix(y0, ty, f), ang)
        elif ti < MERGE:
            burst(c, tx, ty, prog(t, ti, ti + .22), CORAL, 8, 16, 90, 7)
        else:
            p = prog(t, ti, ti + .5)
            if p < 1:
                rng = np.random.default_rng(int(ti * 1000))
                for _ in range(18):
                    a = rng.uniform(-1.3, 1.3)
                    v = rng.uniform(140, 420)
                    sz = rng.uniform(8, 18) * (1 - p)
                    px = tx + math.cos(a) * v * eout(p) + 40
                    py = ty + math.sin(a) * v * eout(p) + 260 * p * p
                    rrect(c, px, py, sz, sz, 0, CORAL if rng.random() < .6 else PEACH, 1 - p * .6)
    seats = []
    for i, name in enumerate(['Аня', 'Kai']):
        seats.append(help_card(c, t, i, name))
    for i, seat in enumerate(seats):
        if seat is None or t < PROTECT[i]: continue
        bx, by = seat
        f = prog(t, PROTECT[i], ARRIVE[i])
        cx_, cy_ = max(bx, SH_XY[0]) + 140, by + 80
        if t < ARRIVE[i] + .3:
            line(c, [(bx, by + 40), (SH_XY[0], SH_XY[1] - 40)], JADE_L, 4, .5 * (1 - prog(t, ARRIVE[i], ARRIVE[i] + .3)), caps=False)
        if f < 1:
            u = eio(f)
            x = (1 - u) ** 2 * bx + 2 * (1 - u) * u * cx_ + u * u * SH_XY[0]
            y = (1 - u) ** 2 * by + 2 * (1 - u) * u * cy_ + u * u * SH_XY[1]
            shield(c, x, y, mix(70, 150, u), PEACH if i == 0 else JADE_L, IVORY, emblem=IVORY)
        ring(c, *SH_XY, prog(t, ARRIVE[i], ARRIVE[i] + .3), PEACH if i == 0 else JADE_L, 80, 220, 8)
    lbl = 'Защита 40' if t < ARRIVE[0] else 'Защита 40+25' if t < ARRIVE[1] else 'Защита 40+25+20'
    fl = hit(t, CRACK, .4)
    fill = JADE if t >= MERGE else lerpc(IVORY, CORAL, fl)
    fg = IVORY if t >= MERGE or fl > .5 else INK
    s = back(prog(t, FOX_IN + .1, FOX_IN + .35)) * (1 + .12 * hit(t, ARRIVE[0], .25) + .2 * hit(t, MERGE, .3))
    chip(c, 600, 1405, lbl, 32, fill, fg, s, h=80, icon=lambda c_, x, y, s_, col, a: shield(c_, x, y, s_ * 2.4, col, col, a, None))
    return c


RING_C, RING_R = (540, 930), 250
RING = [('Аня', -135), ('Kai', -45), ('Somchai', 135), ('fox', 45)]


def s_safe(t):
    c = C(IVORY)
    for k in range(3):
        p = ((t - 11.5) * .55 + k / 3) % 1
        circle(c, *RING_C, 120 + 900 * p, None, .5 * (1 - p), IVORY_D, 10)
    headline(c, t, [(290, 170, [('—', 11.5, INK), ('СВОИ', 11.5, PEACH)]),
                    (470, 170, [('ПРИКРОЮТ.', 12.0, INK)])], end=None, shadow=INK)
    burst(c, *RING_C, prog(t, 11.5, 11.95), PEACH, 18, 140, 640, 14)
    burst(c, *RING_C, prog(t, 11.55, 12.05), JADE, 18, 100, 520, 10, .35)
    rp = eout(prog(t, 11.5, 11.85))
    rot = (t - 11.5) * 30
    for k in range(12):
        a0 = rot + k * 30
        arc(c, *RING_C, RING_R, a0, a0 + 30 * .62 * rp, JADE, 7)
    plot_bed(c, 540, 1080, 190, 80)
    plant(c, 540, 1040, 4, .85 * (1 + .04 * beatp(t)), 0, t)
    for k in range(4):
        a = t * 1.3 + k * math.pi / 2
        poly(c, star_pts(540 + math.cos(a) * 130, 860 + math.sin(a) * 100, 16, .3), PEACH, .9)
    for i, (name, deg) in enumerate(RING):
        x = RING_C[0] + math.cos(math.radians(deg)) * RING_R
        y = RING_C[1] + math.sin(math.radians(deg)) * RING_R
        bump = .14 * hit(t, HEART_HIT, .3) if name == 'Kai' else 0
        avatar(c, name, x, y, 64, back(prog(t, RING_POP[i], RING_POP[i] + .26)) * (1 + bump), ring_col=INK,
               label=INK if name != 'fox' else None)
    if t >= THANKS_IN:
        s = back(prog(t, THANKS_IN, THANKS_IN + .25))
        w = chip(c, 540 + 22 * s, 1275, 'Помог тебе', 32, INK, IVORY, s, h=84, extra=44,
                 icon=lambda c_, x, y, s_, col, a: None)
        avatar(c, 'Kai', 540 + 22 * s - w / 2 + 2, 1275, 34 * s, ring_col=INK)
        sparkle_icon(c, 540 + 22 * s + w / 2 - 30 * s, 1278, 15 * s, PEACH)
    button(c, 540, 1388, 'Поблагодарить', t, THANKS_BTN, THANKS_PRESS, 34, h=96,
           icon=lambda c_, x, y, s_, col, a: poly(c_, heart_pts(x, y, s_ * 1.6), col, a))
    if t >= THANKS_PRESS:
        f = prog(t, THANKS_PRESS, HEART_HIT)
        kx, ky = RING_C[0] + math.cos(math.radians(-45)) * RING_R, RING_C[1] + math.sin(math.radians(-45)) * RING_R
        if f < 1:
            u = eio(f)
            x = (1 - u) ** 2 * 540 + 2 * (1 - u) * u * 900 + u * u * kx
            y = (1 - u) ** 2 * 1330 + 2 * (1 - u) * u * 1100 + u * u * ky
            poly(c, heart_pts(x, y, mix(40, 80, math.sin(u * math.pi) * .6 + u * .4)), PEACH)
        else:
            burst(c, kx, ky, prog(t, HEART_HIT, HEART_HIT + .35), PEACH, 10, 70, 170, 8)
    return c


def store_badge(c, x, y, label, kind, s):
    if s <= .01: return
    rrect(c, x, y, 330 * s, 92 * s, 24 * s, INK)
    ix = x - 112 * s
    if kind == 'apple':
        rrect(c, ix, y, 52 * s, 52 * s, 14 * s, IVORY)
        line(c, [(ix - 12 * s, y + 13 * s), (ix + 1 * s, y - 15 * s)], JADE, 6 * s)
        line(c, [(ix + 12 * s, y + 13 * s), (ix - 1 * s, y - 15 * s)], JADE, 6 * s)
        line(c, [(ix - 15 * s, y + 4 * s), (ix + 15 * s, y + 4 * s)], JADE, 5 * s)
    else:
        poly(c, [(ix - 20 * s, y - 26 * s), (ix + 26 * s, y), (ix - 20 * s, y + 26 * s)], PEACH)
        poly(c, [(ix - 20 * s, y - 26 * s), (ix + 6 * s, y), (ix - 20 * s, y + 26 * s)], JADE_L)
    blitT(c, txt(label, 32, IVORY, 'Montserrat', 800), ix + 38 * s, y, s, anchor='l')


def s_end(t):
    c = C(JADE)
    deco(c, t, JADE_D)
    for k in range(6):
        a = k * math.tau / 6 + t * .25
        rrect(c, 540 + 560 * math.cos(a), 900 + 760 * math.sin(a), 120, 156, 22, None, .8, JADE_D, 6)
    p = eout(prog(t, 13.12, LOGO))
    bump = hit(t, LOGO, .3)
    for side, kind in ((-1, 'M'), (1, 'R')):
        x = mix(540 + side * 760, 540 + side * 76, p)
        blit(c, tile_sprite(kind), x, 640, 1.08 * (1 + .1 * bump), -side * mix(40, 9, p))
    lg = back(prog(t, LOGO, LOGO + .3), 2.6)
    if lg > 0:
        line(c, [(540, 545), (540, 545 - 60 * lg)], JADE_D, 9)
        poly(c, leaf_pts(540, 545 - 40 * lg, 92 * lg, 50 * lg, math.radians(-140)), IVORY)
        poly(c, leaf_pts(540, 545 - 56 * lg, 82 * lg, 46 * lg, math.radians(-40)), PEACH)
        burst(c, 540, 600, prog(t, LOGO, LOGO + .45), IVORY, 14, 180, 360, 9)
    headline(c, t, [(880, 128, [('MAHJONG', LOGO, IVORY)]), (1020, 168, [('RISE', 13.75, PEACH)])], align='c', shadow=JADE_D)
    headline(c, t, [(1140, 44, [('Расти.', 13.75, IVORY), ('Знакомься.', 14.0, IVORY), ('Защищай.', 14.25, IVORY)])],
             align='c', name='Montserrat')
    pulse = .06 * beatp(t) if t > CTA_IN + .3 else 0
    button(c, 540, 1262, 'Играть бесплатно', t, CTA_IN, None, 44, PEACH, INK, INK, 116, pulse=pulse)
    store_badge(c, 360, 1386, 'App Store', 'apple', back(prog(t, BADGES[0], BADGES[0] + .25)))
    store_badge(c, 720, 1386, 'Google Play', 'play', back(prog(t, BADGES[1], BADGES[1] + .25)))
    return c


SCENES = [(1.5, s_hook), (4.0, s_grow), (6.5, s_show), (9.0, s_meet), (11.5, s_attack), (13.0, s_safe), (99, s_end)]


def frame(t):
    fn = next(f for end, f in SCENES if t < end)
    c = fn(t)
    if 1.3 <= t < 1.75:
        ro = 2300 * ein(prog(t, 1.3, 1.5)) if t < 1.5 else 2300
        ri = 2300 * eout(prog(t, 1.5, 1.72)) if t >= 1.5 else 0
        annulus(c, 540, 1162, ri, ro, PEACH)
        if ro - ri > 4: annulus(c, 540, 1162, ri, min(ro, ri + 150), JADE)
    if 8.84 <= t < 9.18:
        for k, (col, wd, lag) in enumerate(((CORAL, 1800, 0), (INK_D, 260, .05), (CORAL, 120, .09))):
            x = mix(2900, -2400, eio(prog(t, 8.84 + lag, 9.16 + lag)))
            poly(c, [(x - wd / 2 + 320, 0), (x + wd / 2 + 320, 0), (x + wd / 2 - 320, H), (x - wd / 2 - 320, H)], col)
    if 11.36 <= t < 11.5:
        annulus(c, *SH_XY, 0, 2400 * ein(prog(t, 11.36, 11.5)), IVORY)
    if 12.78 <= t < 13.02:
        p = eio(prog(t, 12.78, 13.0))
        for col, lead in ((PEACH, 70), (JADE, 0)):
            top = mix(H + 120, -140, p) + lead
            pts = [(x, top + 34 * math.sin(x / 120 + t * 14)) for x in range(-20, W + 41, 40)]
            poly(c, pts + [(W + 20, H + 20), (-20, H + 20)], col)
    im = c.im.reduce(S).convert('RGB')
    if 9.0 <= t < 11.5:
        amp = 18 * max([hit(t, i, .16) for i in IMPACTS + [9.0, MERGE]] + [0])
        if amp > .5:
            dx, dy = round(amp * math.sin(t * 91)), round(amp * math.cos(t * 77))
            shaken = Image.new('RGB', im.size, rgb(NIGHT))
            shaken.paste(im, (dx, dy))
            im = shaken
    return im


def frame_bytes(i): return frame(i / FPS).tobytes()


# ---- sound ------------------------------------------------------------------
SR = 48000
NOTE = lambda n: 440 * 2 ** ((n - 69) / 12)
CHORDS = {'C': [60, 64, 67], 'G': [59, 62, 67], 'Am': [57, 60, 64], 'F': [57, 60, 65]}
ROOTS = {'C': 48, 'G': 43, 'Am': 45, 'F': 41}


def chord_at(t):
    for end, ch in ((2, 'C'), (4, 'G'), (6, 'Am'), (8, 'F'), (9, 'C'), (11, None), (12, 'F'), (13, 'G'), (99, 'C')):
        if t < end: return ch


def groove(t): return t < 9.0 or 11.0 <= t < 14.5


def soundtrack(path):
    n = int(SR * DUR)
    bus = {k: np.zeros((n, 2)) for k in ('drum', 'mus', 'sfx')}
    rng = np.random.default_rng(23)

    def add(b, at, sig, amp=1., pan=0.):
        i = int(round(at * SR))
        if i < 0: sig, i = sig[-i:], 0
        m = min(len(sig), n - i)
        if m <= 0: return
        gl, gr = math.cos((pan + 1) * math.pi / 4) * 1.414, math.sin((pan + 1) * math.pi / 4) * 1.414
        bus[b][i:i + m, 0] += sig[:m] * amp * gl
        bus[b][i:i + m, 1] += sig[:m] * amp * gr

    def tt(d): return np.arange(int(d * SR)) / SR
    def noise(d): return rng.standard_normal(int(d * SR))
    def hp(x, k=6): return x - np.convolve(x, np.ones(k) / k, 'same')
    def lp(x, k=8): return np.convolve(x, np.ones(k) / k, 'same')

    def kick(big=1.):
        q = tt(.5)
        f = 46 + 120 * np.exp(-q / .032)
        return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-q / (.15 * big)) + .25 * hp(noise(.5)) * np.exp(-q / .003)

    def clap():
        q = tt(.32)
        env = sum(np.exp(-(q - o) / .006) * (q >= o) for o in (0, .011, .022)) * .5 + np.exp(-np.maximum(q - .022, 0) / .09) * (q >= .022)
        return lp(hp(noise(.32), 5), 2) * env

    def hat(d=.06): q = tt(d); return hp(noise(d), 3) * np.exp(-q / .013)

    def saw(f, q, k=7): return sum(np.sin(2 * np.pi * f * j * q) / j for j in range(1, k + 1))

    def pluck(f, d=.45, bright=1., dec=.18):
        q = tt(d)
        s = sum(np.sin(2 * np.pi * f * j * q + j) * (bright / j ** 1.3) * np.exp(-q / (dec / j ** .5)) for j in range(1, 7))
        return s * np.minimum(q / .003, 1)

    def bell(f, d=1.5, dec=.6):
        q = tt(d)
        return sum(a * np.sin(2 * np.pi * f * r * q) * np.exp(-q / (dec / r ** .4)) for r, a in ((1, 1), (2.76, .45), (5.4, .2), (8.9, .08))) * np.minimum(q / .004, 1)

    def pop(f=700, d=.09):
        q = tt(d)
        fr = f * (1.6 * np.exp(-q / .012) + .7)
        return np.sin(2 * np.pi * np.cumsum(fr) / SR) * np.exp(-q / .028)

    def click():
        q = tt(.06)
        return (np.sin(2 * np.pi * 2300 * q) * .6 + np.sin(2 * np.pi * 1150 * q) + .5 * hp(noise(.06), 2)) * np.exp(-q / .009)

    def whoosh(d=.3, up=True, k0=60, k1=4):
        x = noise(d)
        q = tt(d)
        out = np.zeros_like(x)
        steps = 8
        for s_ in range(steps):
            k = int(mix(k0, k1, s_ / (steps - 1) if up else 1 - s_ / (steps - 1)))
            seg = slice(int(len(x) * s_ / steps), int(len(x) * (s_ + 1) / steps))
            out[seg] = lp(x, max(1, k))[seg]
        return out * np.sin(np.pi * q / d) ** 1.5

    def zip_up(d=.22, f0=320, f1=1100):
        q = tt(d)
        f = f0 * (f1 / f0) ** (q / d)
        return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.sin(np.pi * q / d) ** 2

    def clang(f0=430, d=2.2):
        q = tt(d)
        parts = ((1, 1, .9), (2.32, .7, .7), (3.86, .5, .5), (5.41, .35, .4), (6.93, .25, .3), (8.83, .2, .22))
        s = sum(a * np.sin(2 * np.pi * f0 * r * q + r) * np.exp(-q / dc) for r, a, dc in parts)
        return s * np.minimum(q / .002, 1) + .4 * hp(noise(d), 3) * np.exp(-q / .02)

    def thud():
        q = tt(.5)
        f = 38 + 90 * np.exp(-q / .05)
        return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-q / .18) + .3 * lp(noise(.5), 30) * np.exp(-q / .06)

    # drums
    for k in range(30):
        at = k * BEAT
        if groove(at):
            add('drum', at, kick(), .8)
            if k % 2: add('drum', at, clap(), .32)
            add('drum', at + .25, hat(), .10, .3)
            if 4.0 <= at < 9.0 or 11.5 <= at < 14.5:
                add('drum', at + .125, hat(.03), .045, -.3)
                add('drum', at + .375, hat(.03), .045, -.3)
    # harmony
    for i in range(60):
        at = i * .25
        ch = chord_at(at)
        if ch is None or at >= 14.5: continue
        r = NOTE(ROOTS[ch])
        q = tt(.24)
        add('mus', at, saw(r, q, 6) * np.minimum(q / .004, 1) * np.exp(-q / .16), .14)
        if i % 2 == 1:
            for nn in CHORDS[ch]: add('mus', at, pluck(NOTE(nn), .3, .8, .09), .05)
        if at >= 1.5:
            tones = CHORDS[ch]
            nn = tones[[0, 1, 2, 1, 2, 0, 2, 1][i % 8]] + 12
            add('mus', at, pluck(NOTE(nn), .4, 1., .14), .055, .35 * math.sin(i))
    for start, end, ch in ((0, 2, 'C'), (2, 4, 'G'), (4, 6, 'Am'), (6, 8, 'F'), (8, 9, 'C'), (11, 12, 'F'), (12, 13, 'G'), (13, 15, 'C')):
        d = end - start + .4
        q = tt(d)
        env = np.minimum(q / .25, 1) * np.clip((d - q) / .4, 0, 1)
        sig = sum(np.sin(2 * np.pi * NOTE(nn) * dt * q) for nn in CHORDS[ch] for dt in (.997, 1.003))
        add('mus', start, sig * env, .022)
    # attack: drop, sub drone, impacts, crack, riser, clang
    add('sfx', 8.6, whoosh(.4, True, 80, 2), .3)
    add('sfx', 9.0, thud(), .7)
    add('sfx', 9.0, kick(3.), .45)
    q = tt(2.0)
    drone = (saw(NOTE(33), q, 5) + .6 * saw(NOTE(40), q, 4)) * (.6 + .4 * np.sin(2 * np.pi * 4 * q) ** 2)
    add('mus', 9.0, drone * np.minimum(q / .2, 1) * np.clip((2.0 - q) / .05, 0, 1), .065)
    for at in (9.5, 10.5): add('drum', at, thud(), .35)
    for ti, sx, sy in ATTACKERS:
        add('sfx', ti - .32, whoosh(.32, True, 30, 3), .13, .6)
        if ti < MERGE:
            add('sfx', ti, thud(), .45)
            add('sfx', ti, clang(980, .35), .1, .4)
    q = tt(.3)
    crackle = hp(noise(.3), 2) * (rng.random(len(q)) < .08) * np.exp(-q / .08)
    add('sfx', CRACK, crackle, .9, .3)
    add('sfx', CRACK, hp(noise(.12), 3) * np.exp(-tt(.12) / .03), .4)
    add('sfx', 10.0, whoosh(1.0, True, 120, 3) * np.linspace(0, 1, int(SR)), .22)
    add('sfx', 10.0, zip_up(1.0, 140, 620), .07)
    add('sfx', ARRIVE[0], clang(640, .9), .16, .2)
    add('sfx', MERGE, clang(430, 2.2), .3)
    add('sfx', MERGE, kick(2.), .35)
    for j, nn in enumerate((65, 69, 72, 77)): add('mus', MERGE + .02 * j, bell(NOTE(nn), 1.8, .7), .07)
    for ti in SHATTER:
        for j in range(5):
            add('sfx', ti + j * .018, np.sin(2 * np.pi * rng.uniform(2500, 5200) * tt(.07)) * np.exp(-tt(.07) / .015), .08, rng.uniform(-.5, .8))
    # game & UI sound design
    add('sfx', SEED_LAND, pop(300, .14), .45)
    add('sfx', 1.3, whoosh(.25, True, 50, 3), .22)
    for ts, L in zip(SLAMS, LANDS):
        add('sfx', ts, click(), .55, -.1)
        add('sfx', ts + .012, click(), .35, .1)
        add('sfx', L - .2, zip_up(.22, 300 + 80 * SLAMS.index(ts), 1000 + 150 * SLAMS.index(ts)), .09)
        add('sfx', L, pop(520, .1), .25)
    for j, nn in enumerate((72, 76, 79, 84)): add('mus', LANDS[3] + j * .04, bell(NOTE(nn), 1.3, .5), .06)
    add('sfx', 4.0, whoosh(.4, False, 4, 40), .16)
    add('sfx', CARD_SNAP, click(), .45)
    add('sfx', CARD_SNAP, pop(420, .1), .3)
    for j, at in enumerate(EYES): add('sfx', at, pop(900 + 120 * j), .22, -.4 + .4 * j)
    for j, at in enumerate(AV_POP): add('sfx', at, pop(620 + 90 * j, .12), .3, -.5 + .5 * j)
    for at in (OFFER, HEART_IN, 9.25, 9.5, *HELP_IN, THANKS_IN, THANKS_BTN, CTA_IN, *BADGES, *RING_POP):
        add('sfx', at, pop(560, .1), .24)
    for j, at in enumerate((6.5, 6.6, 6.7)): add('sfx', at, zip_up(.3, 500 + 60 * j, 900 + 60 * j), .035, -.5 + .5 * j)
    for at in (ADD_PRESS, *PROTECT, THANKS_PRESS): add('sfx', at, click(), .4)
    for j, at in enumerate(TICKS): add('sfx', at + .02, bell(NOTE(84 + 2 * j), .5, .18), .07)
    add('sfx', 7.75, pop(380, .14), .2)
    add('sfx', 11.36, whoosh(.2, True, 30, 2), .25)
    for j, nn in enumerate((79, 84, 88, 91)): add('mus', 11.5 + j * .05, bell(NOTE(nn), 1.2, .45), .05)
    add('sfx', HEART_HIT, bell(NOTE(88), .8, .3), .08)
    add('sfx', 12.75, whoosh(.3, True, 60, 3), .25)
    # sting
    add('sfx', LOGO - .38, whoosh(.38, True, 50, 2), .2)
    add('sfx', LOGO, click(), .6, -.2)
    add('sfx', LOGO + .01, click(), .5, .2)
    add('drum', LOGO, kick(2.2), .55)
    for j, nn in enumerate((60, 64, 67, 72, 76, 79, 84)): add('mus', LOGO + j * .045, bell(NOTE(nn), 1.6, .8), .055)
    q = tt(1.5)
    add('mus', 14.5, sum(np.sin(2 * np.pi * NOTE(nn) * q) for nn in (48, 60, 64, 67, 72)) * np.exp(-q / .6) * np.minimum(q / .01, 1), .07)
    add('drum', 14.5, kick(1.5), .6)
    # sidechain, reverb, master
    duck = np.ones(n)
    for k in range(30):
        at = k * BEAT
        if groove(at):
            i = int(at * SR)
            m = min(int(.22 * SR), n - i)
            duck[i:i + m] = np.minimum(duck[i:i + m], 1 - .45 * np.exp(-np.arange(m) / SR / .07))
    bus['mus'] *= duck[:, None]
    ir_n = int(1.6 * SR)
    ir = rng.standard_normal(ir_n) * np.exp(-np.arange(ir_n) / SR / .45)
    ir = lp(ir, 20)
    ir /= np.sqrt(np.sum(ir ** 2))
    nfft = 1 << (n + ir_n).bit_length()
    IR = np.fft.rfft(ir, nfft)
    wet_src = bus['mus'] * .7 + bus['sfx'] * .35
    wet = np.stack([np.fft.irfft(np.fft.rfft(wet_src[:, ch], nfft) * IR, nfft)[:n] for ch in range(2)], 1)
    mixd = bus['drum'] + bus['mus'] + bus['sfx'] + wet * .22
    tm = np.arange(n) / SR
    mixd *= np.minimum(tm / .005, 1)[:, None] * np.clip((DUR - tm) / .3, 0, 1)[:, None]
    mixd = np.tanh(mixd * 1.4) / 1.4
    mixd *= .9 / np.max(np.abs(mixd))
    with wave.open(str(path), 'wb') as f:
        f.setnchannels(2); f.setsampwidth(2); f.setframerate(SR)
        f.writeframes((mixd * 32767).astype('<i2').tobytes())


# ---- entry ------------------------------------------------------------------
def main():
    BUILD.mkdir(parents=True, exist_ok=True)
    if '--preview' in sys.argv or '--at' in sys.argv:
        if '--at' in sys.argv: marks = [float(x) for x in sys.argv[sys.argv.index('--at') + 1].split(',')]
        else: marks = [.3, 1.2, 2.6, 3.9, 4.6, 6.2, 7.3, 8.6, 9.8, 10.6, 11.3, 12.7, 13.9, 14.8]
        cols = 7
        rows = math.ceil(len(marks) / cols)
        sheet = Image.new('RGB', (270 * cols, 480 * rows), INK_D)
        for i, t in enumerate(marks):
            im = frame(t)
            im.save(BUILD / f'f{t:05.2f}.png')
            th = im.resize((270, 480), Image.Resampling.LANCZOS)
            d = ImageDraw.Draw(th)
            d.line((0, 360, 270, 360), fill=(255, 0, 0), width=1)
            d.text((8, 455), f'{t:.2f}s', font=font('Montserrat', 18, 800), fill='white', stroke_width=2, stroke_fill='black')
            sheet.paste(th, ((i % cols) * 270, (i // cols) * 480))
        sheet.save(BUILD / 'storyboard.jpg', quality=92)
        print(BUILD / 'storyboard.jpg', flush=True)
        return
    wav = BUILD / 'soundtrack.wav'
    soundtrack(wav)
    print('Soundtrack ready', flush=True)
    cmd = [str(FFMPEG), '-y', '-loglevel', 'error', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-s', f'{W}x{H}', '-r', str(FPS),
           '-i', 'pipe:0', '-i', str(wav), '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-preset', 'slow', '-crf', '17',
           '-c:a', 'aac', '-b:a', '192k', '-t', str(DUR), '-movflags', '+faststart', str(OUT)]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    try:
        with Pool(max(1, (os.cpu_count() or 2) - 1)) as pool:
            for i, buf in enumerate(pool.imap(frame_bytes, range(FPS * DUR), chunksize=2)):
                proc.stdin.write(buf)
                if i % 30 == 0: print(f'Render {i // 30:02d}/{DUR} s', flush=True)
    finally:
        proc.stdin.close()
    if proc.wait() != 0: raise RuntimeError('Video encoding failed')
    frame(14.8).save(BUILD / 'poster.jpg', quality=95)
    print(f'Exported {OUT} ({OUT.stat().st_size:,} bytes)', flush=True)


if __name__ == '__main__':
    main()
