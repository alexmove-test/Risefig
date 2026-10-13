"""Mahjong Rise — «Вырастили вместе»: 22.5 s vertical TikTok spot (1080x1920, 30 fps).

Run: python promo/render_together.py [--preview] [--at 1.2,4.4]
Reuses the flat vector kit of render_friends.py; music and SFX are synthesized here.
Story: awkward first message -> grow a plant -> neighbour notices it on the showcase ->
friendship only after "Accept" -> cross plants together -> a reason to write again.
Event times below are on a 15 s grid (120 BPM, one beat = 0.5 s); SPEED stretches
picture and sound together to 22.5 s at 80 BPM.
"""
from pathlib import Path
import math
import os
import sys
import wave
import subprocess
from multiprocessing import Pool
import numpy as np
from PIL import Image, ImageDraw

import render_friends as rf
from render_friends import (W, H, FPS, S, BEAT, IVORY, JADE, PEACH, INK, IVORY_D, JADE_D, JADE_L, PEACH_D,
                            INK_D, INK_L, INK_LL, CH, RIBBON_Y, FFMPEG, clamp, prog, eout, ein, eio, back, mix, hit,
                            beatp, press, rgb, F, C, rrect, circle, poly, line, blit, blitT, txt, tw, headline,
                            leaf_pts, star_pts, heart_pts, heart_leaf, burst, ring, check_mark, people_icon, chip,
                            tile_sprite, interp, STEM, plant, plot_bed, hero_card, ribbon, avatar, eye, button, deco,
                            annulus, store_badge, font, drop)

PROMO = Path(__file__).resolve().parent
BUILD = PROMO / 'together-build'
DUR = 15
SPEED = 1.5  # story time is authored at 15 s; output plays it this much slower
OUT_DUR = DUR * SPEED
OUT = PROMO / f'Mahjong-Rise-Together-{OUT_DUR:g}s.mp4'
WHITE = '#FFFFFF'
rf.AV['Ты'] = (JADE, IVORY, 'Т')

# ---- event sheet shared by picture and sound -------------------------------
AV_POP = [.5, .75]
BUBBLE, QMARKS = 1.0, 1.25
CUT1 = 1.95
SLAMS = [2.25, 2.75, 3.25, 3.75]
LANDS = [s + .22 for s in SLAMS]
CARD_SNAP, EYE, ANYA_POP, OFFER = 5.45, 5.5, 5.73, 6.25
CUT2 = 7.0
INVITE, NOTE_IN, ACCEPT = 7.2, 7.6, 8.0
PAIR, CHECKS, HEART, FRIENDS = 8.2, [8.5, 8.625], 8.75, 8.875
CUT3 = 9.5
OWNERS = [9.6, 9.7]
STREAM, SEED, SEED_FALL, SPROUT, BLOOM, TOGETHER = 10.0, 10.25, 10.5, 10.75, 11.45, 11.5
CUT4 = 12.0
MSG1, TYPING, MSG2 = 12.375, 12.5, 12.75
CUT5 = 13.25
LOGO, CTA_IN, BADGES = 13.5, 14.0, [14.25, 14.375]


def noop_icon(c, x, y, s, col, a): pass


def hybrid(c, bx, by, s, sc, t):
    """Plant with a two-colour bloom: peach and jade petals, one from each parent."""
    plant(c, bx, by, min(s, 3.), sc, 0, t)
    f = clamp(s - 3, 0, 1.4)
    tx, ty = bx + math.sin(t * 2.6) * 4 * sc, by - interp(STEM, 3) * sc
    if f <= 0: return tx, ty
    rot = math.radians(t * 22)
    for k in range(10):
        poly(c, leaf_pts(tx, ty, 82 * f * sc, 42 * f * sc, rot + k * math.tau / 10), PEACH if k % 2 else JADE_L)
    for k in range(10):
        poly(c, leaf_pts(tx, ty, 46 * f * sc, 22 * f * sc, rot + math.tau / 20 + k * math.tau / 10), IVORY)
    circle(c, tx, ty, 21 * f * sc, INK)
    circle(c, tx, ty, 8 * f * sc, PEACH)
    return tx, ty


def caption(c, s, y, a, col=IVORY, size=40):
    blitT(c, txt(s, size, col, 'Montserrat', 700), 540, y, a=a)


# ---- scenes -----------------------------------------------------------------
def s_hook(t):
    c = C(INK)
    deco(c, t, INK_L, beat=False)
    headline(c, t, [(300, 120, [('ЗНАКОМИТЬСЯ', -.12, IVORY)]),
                    (470, 170, [('НЕЛОВКО?', .25, PEACH)])])
    for (name, x), t0 in zip((('Ты', 300), ('Аня', 780)), AV_POP):
        avatar(c, name, x, 1110, 90, back(prog(t, t0, t0 + .28)), label=IVORY)
    for i, x in enumerate((300, 780)):
        s = back(prog(t, QMARKS + i * .125, QMARKS + .25 + i * .125))
        blitT(c, txt('?', 90, PEACH), x + 84, 990 + 8 * math.sin(t * 9 + i * 2), s)
    s = back(prog(t, BUBBLE, BUBBLE + .25))
    if s > .01:
        bx = 540 + 9 * math.sin(t * 70) * hit(t, 1.5, .35)
        rrect(c, bx, 1110, 200 * s, 104 * s, 52 * s, IVORY)
        poly(c, [(bx - 30 * s, 1150 * s + 1110 * (1 - s)), (bx - 58 * s, 1192 * s + 1110 * (1 - s)), (bx - 2 * s, 1158 * s + 1110 * (1 - s))], IVORY)
        for k in range(3):
            dy = -12 * max(0, math.sin(t * 10 - k * .9))
            circle(c, bx + (k - 1) * 44 * s, 1110 + dy * s, 11 * s, INK)
    caption(c, 'Что написать первым?', 1340, prog(t, BUBBLE, BUBBLE + .2) * .9)
    return c


def grow_stage(t): return sum(back(prog(t, L, L + .24), 2.4) for L in LANDS)


def s_grow(t):
    c = C(INK)
    deco(c, t, INK_L)
    headline(c, t, [(290, 130, [('НАЧНИ', 2.0, IVORY), ('С', 2.25, IVORY)]),
                    (440, 150, [('РОСТКА', 2.5, PEACH)])], end=4.5)
    plot_bed(c, 540, 1180, sc=1 + .025 * beatp(t))
    s = grow_stage(t)
    if s < .6: circle(c, 540, 1162, 16 * (1 - s / .6) * back(prog(t, CUT1, CUT1 + .2)), PEACH)
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
    if s > 3.5: burst(c, 540, 955, prog(t, LANDS[3], LANDS[3] + .45), PEACH, 14, 110, 290, 10)
    caption(c, 'Собери пару в маджонге — польёшь росток', 1400, prog(t, 2.3, 2.5) * (1 - prog(t, 4.3, 4.5)) * .9, size=36)
    return c


ANYA = (270, 720)


def s_show(t):
    c = C(INK)
    deco(c, t, INK_L)
    headline(c, t, [(290, 130, [('ЕГО', 4.5, IVORY), ('ЗАМЕТЯТ', 4.75, IVORY)]),
                    (440, 150, [('СОСЕДИ', 5.0, PEACH)])], end=CUT2)
    if t >= 4.95: ribbon(c, t - .5)
    if t < 4.95:
        hero_card(c, t, 540, 1050, 1, eio(prog(t, 4.5, 4.95)))
    elif t < 5.2:
        p = eout(prog(t, 4.95, 5.2))
        hero_card(c, t, 540, mix(1050, 990, p), mix(1, .86, p))
    else:
        p = back(prog(t, 5.2, CARD_SNAP))
        hero_card(c, t, 540, mix(990, RIBBON_Y, p), mix(.86, .78, p), glow=prog(t, CARD_SNAP, CARD_SNAP + .2))
    ring(c, 540, RIBBON_Y, prog(t, CARD_SNAP, CARD_SNAP + .4), PEACH, 160, 420, 10)
    top = (540, RIBBON_Y - CH * .78 / 2)
    if t < ANYA_POP + .1:
        p = eout(prog(t, EYE, EYE + .3))
        if p > 0:
            x, y = mix(top[0], ANYA[0], p), mix(top[1], ANYA[1], p) - 60 * math.sin(p * math.pi)
            eye(c, x, y, back(prog(t, EYE, EYE + .3)) * (1 - ein(prog(t, ANYA_POP - .08, ANYA_POP + .06))) * .9)
    if t >= ANYA_POP:
        l = eout(prog(t, 5.9, 6.1))
        ax, ay = ANYA[0], ANYA[1] + 100
        line(c, [(ax, ay), (mix(ax, top[0], l), mix(ay, top[1] - 6, l))], IVORY, 5, .55)
        if l >= 1:
            f = (t * 1.6) % 1
            circle(c, mix(ax, top[0], f), mix(ay, top[1], f), 8, PEACH)
        avatar(c, 'Аня', *ANYA, sc=back(prog(t, ANYA_POP, ANYA_POP + .26)), label=IVORY)
        ring(c, *ANYA, prog(t, ANYA_POP, ANYA_POP + .35), PEACH, 60, 130, 6)
    if t >= OFFER:
        x = mix(-700, 80, eout(prog(t, OFFER, OFFER + .25)))
        w = chip(c, x, 1430, 'Предлагает скрещивание', 30, IVORY, INK, h=76, anchor='l', extra=48, icon=noop_icon)
        avatar(c, 'Аня', x + 40, 1430, 26, ring_col=INK)
        poly(c, leaf_pts(x + w - 34, 1444, 34, 18, math.radians(-120)), JADE)
        poly(c, leaf_pts(x + w - 34, 1444, 34, 18, math.radians(-60)), PEACH_D)
    return c


def invite_card(c, t, sc):
    if sc <= .01: return
    X, Y = 540, 1060
    rrect(c, X, Y + 14 * sc, 820 * sc, 420 * sc, 44 * sc, INK_D)
    rrect(c, X, Y, 820 * sc, 420 * sc, 44 * sc, IVORY)
    avatar(c, 'Аня', X - 305 * sc, Y - 105 * sc, 58, sc, ring_col=IVORY_D)
    blitT(c, txt('Аня', 46, INK, 'Montserrat', 900), X - 225 * sc, Y - 132 * sc, sc, anchor='l')
    blitT(c, txt('приглашает в друзья', 34, INK, 'Montserrat', 700), X - 225 * sc, Y - 78 * sc, sc, anchor='l')
    rrect(c, X, Y - 8 * sc, 720 * sc, 3 * sc, 1, IVORY_D)
    blitT(c, txt('Писать друг другу — только после «Принять»', 26, INK_LL, 'Montserrat', 700), X, Y + 40 * sc, sc)
    chip(c, X - 190 * sc, Y + 132 * sc, 'Не сейчас', 32, IVORY_D, INK, sc, h=88)
    pr = press(t, ACCEPT)
    chip(c, X + 180 * sc, Y + 132 * sc, 'Принять', 34, PEACH, INK, sc * (1 - .05 * pr), h=96, lip=INK_D, pr=pr, icon=check_mark)
    ring(c, X + 180, Y + 132, prog(t, ACCEPT, ACCEPT + .35), INK, 30, 140, 6)


def s_consent(t):
    c = C(INK)
    deco(c, t, INK_L)
    headline(c, t, [(290, 120, [('ДРУЖБА', CUT2, IVORY), ('—', 7.125, IVORY)]),
                    (440, 150, [('ПО', 7.25, PEACH), ('СОГЛАСИЮ', 7.375, PEACH)])], end=CUT3)
    if t < 8.15: invite_card(c, t, back(prog(t, INVITE, INVITE + .25)))
    elif t < 8.35: invite_card(c, t, 1 - ein(prog(t, 8.15, 8.35)))
    if t >= PAIR:
        m = eout(prog(t, PAIR, PAIR + .25))
        xs = mix(540, 380, m), mix(540, 700, m)
        la = prog(t, 8.35, 8.5)
        if la > 0: line(c, [(xs[0] + 90, 1040), (mix(xs[0] + 90, xs[1] - 90, la), 1040)], IVORY, 6, .6)
        sc = back(prog(t, PAIR, PAIR + .25))
        for name, x, ck in (('Ты', xs[0], CHECKS[0]), ('Аня', xs[1], CHECKS[1])):
            avatar(c, name, x, 1040, 88, sc, label=IVORY, check=prog(t, ck, ck + .25))
    if t >= HEART:
        k = back(prog(t, HEART, HEART + .25))
        circle(c, 540, 1040, 60 * k, INK, .95)
        heart_leaf(c, 540, 1040, 82 * k)
        ring(c, 540, 1040, prog(t, HEART, HEART + .4), JADE_L, 50, 170, 7)
    if t >= FRIENDS:
        chip(c, 540, 1250, 'Друзья', 32, PEACH, INK, back(prog(t, FRIENDS, FRIENDS + .25)), h=76, icon=people_icon)
    caption(c, 'Можно отказаться или заблокировать', 1400, prog(t, NOTE_IN, NOTE_IN + .2) * .85, size=34)
    return c


OWN = [('Ты', 290, 0), ('Аня', 790, 1)]
FLOWER_Y = 1280 - 205 * .8


def s_cross(t):
    c = C(INK)
    deco(c, t, INK_L)
    headline(c, t, [(290, 130, [('ВЫРАСТИТЕ', CUT3, IVORY)]),
                    (440, 170, [('ВМЕСТЕ', 9.75, PEACH)])], end=CUT4)
    if t >= TOGETHER:
        for _, x, _ in OWN: line(c, [(x, 840), (540, 1100)], IVORY, 4, .35 * prog(t, TOGETHER, TOGETHER + .2))
    for i, (name, x, v) in enumerate(OWN):
        side = -1 if i == 0 else 1
        avatar(c, name, x, 760, 50, back(prog(t, OWNERS[i], OWNERS[i] + .26)), label=IVORY)
        xx = x + side * (700 * (1 - eout(prog(t, CUT3, CUT3 + .3))) + 640 * ein(prog(t, SEED_FALL, SEED_FALL + .3)))
        if abs(xx - 540) < 900:
            plot_bed(c, xx, 1300, 300, 100)
            plant(c, xx, 1280, 4, .8, v, t)
        for k in range(7):
            f = prog(t, STREAM + k * .03, STREAM + .22 + k * .03)
            if 0 < f < 1:
                u = eio(f)
                px = (1 - u) ** 2 * x + 2 * (1 - u) * u * mix(x, 540, .3) + u * u * 540
                py = (1 - u) ** 2 * FLOWER_Y + 2 * (1 - u) * u * 820 + u * u * 930
                poly(c, leaf_pts(px, py, 30, 16, t * 9 + k), PEACH if v == 0 else JADE_L)
    if t >= SEED_FALL:
        plot_bed(c, 540, 1300, sc=back(prog(t, SEED_FALL, SEED_FALL + .25)))
    if SEED <= t < SPROUT:
        k = back(prog(t, SEED, SEED + .2))
        y = 930 if t < SEED_FALL else mix(930, 1282, ein(prog(t, SEED_FALL, SPROUT)))
        r = 30 * k
        circle(c, 540, y, r, PEACH)
        c.d.pieslice(((540 - r) * S, (y - r) * S, (540 + r) * S, (y + r) * S), -90, 90, fill=F(JADE_L))
        circle(c, 540 - r * .35, y - r * .35, r * .22, IVORY, .9)
    burst(c, 540, 930, prog(t, SEED, SEED + .35), IVORY, 12, 40, 170, 8)
    ring(c, 540, 930, prog(t, SEED, SEED + .4), PEACH, 30, 160, 7)
    if t >= SPROUT:
        ring(c, 540, 1280, prog(t, SPROUT, SPROUT + .4), JADE_L, 20, 240, 8)
        tx, ty = hybrid(c, 540, 1280, 4.4 * eout(prog(t, SPROUT, BLOOM)), 1., t)
        if t >= BLOOM:
            burst(c, tx, ty, prog(t, BLOOM, BLOOM + .45), PEACH, 14, 110, 300, 10)
            for k in range(4):
                a = t * 1.4 + k * math.pi / 2
                poly(c, star_pts(tx + math.cos(a) * 160, ty + math.sin(a) * 120, 18 + 6 * math.sin(t * 9 + k), .3), IVORY, prog(t, BLOOM, BLOOM + .2))
    if t >= TOGETHER:
        s = back(prog(t, TOGETHER, TOGETHER + .25))
        w = chip(c, 540 + 22 * s, 600, 'Вырастили вместе с Аней', 30, IVORY, INK, s, h=76, extra=44, icon=noop_icon)
        avatar(c, 'Аня', 540 + 22 * s - w / 2 + 2, 600, 30 * s, ring_col=INK)
    return c


def bubble(c, x, y, s, label, fill, fg, right=False):
    if s <= .01: return
    t_ = txt(label, 36, fg, 'Montserrat', 800)
    w, h = (tw(t_) + 64) * s, 96 * s
    cx = x - w / 2 if right else x + w / 2
    rrect(c, cx, y + 8 * s, w, h, 40 * s, IVORY_D)
    rrect(c, cx, y, w, h, 40 * s, fill)
    blitT(c, t_, cx, y, s)


def s_chat(t):
    c = C(IVORY)
    for k in range(3):
        p = ((t - CUT4) * .55 + k / 3) % 1
        circle(c, 540, 1100, 120 + 900 * p, None, .5 * (1 - p), IVORY_D, 10)
    headline(c, t, [(280, 140, [('ПОВОД', CUT4, INK)]), (440, 140, [('НАПИСАТЬ', 12.125, INK)]),
                    (610, 170, [('СНОВА', 12.25, PEACH)])], shadow=INK)
    s1 = back(prog(t, MSG1, MSG1 + .22))
    avatar(c, 'Аня', 130, 820, 44, s1, ring_col=INK)
    bubble(c, 200, 820, s1, 'Смотри, зацвело!', WHITE, INK)
    if TYPING <= t < MSG2 + .05:
        s = back(prog(t, TYPING, TYPING + .15))
        rrect(c, 820, 980, 150 * s, 80 * s, 40 * s, JADE)
        for k in range(3): circle(c, 820 + (k - 1) * 34 * s, 980 - 10 * max(0, math.sin(t * 12 - k * .9)) * s, 9 * s, IVORY)
    if t >= MSG2:
        bubble(c, 900, 980, back(prog(t, MSG2, MSG2 + .22)), 'Ура! Скрестим ещё?', JADE, IVORY, right=True)
    plot_bed(c, 540, 1330, 220, 80)
    hybrid(c, 540, 1305, 4.4, .75, t)
    return c


def s_end(t):
    c = C(JADE)
    deco(c, t, JADE_D)
    for k in range(6):
        a = k * math.tau / 6 + t * .25
        rrect(c, 540 + 560 * math.cos(a), 900 + 760 * math.sin(a), 120, 156, 22, None, .8, JADE_D, 6)
    p = eout(prog(t, CUT5, LOGO))
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
    headline(c, t, [(1140, 44, [('Играй.', 13.75, IVORY), ('Расти.', 13.875, IVORY), ('Знакомься.', 14.0, IVORY)])],
             align='c', name='Montserrat')
    pulse = .06 * beatp(t) if t > CTA_IN + .3 else 0
    button(c, 540, 1262, 'Играть бесплатно', t, CTA_IN, None, 44, PEACH, INK, INK, 116, pulse=pulse)
    store_badge(c, 360, 1386, 'App Store', 'apple', back(prog(t, BADGES[0], BADGES[0] + .25)))
    store_badge(c, 720, 1386, 'Google Play', 'play', back(prog(t, BADGES[1], BADGES[1] + .25)))
    return c


SCENES = [(CUT1, s_hook), (4.5, s_grow), (CUT2, s_show), (CUT3, s_consent), (CUT4, s_cross), (CUT5, s_chat), (99, s_end)]


def slash(c, t, t0, cols):
    for col, wd, lag in zip(cols, (1800, 260, 120), (0, .05, .09)):
        x = mix(2900, -2400, eio(prog(t, t0 + lag, t0 + .32 + lag)))
        poly(c, [(x - wd / 2 + 320, 0), (x + wd / 2 + 320, 0), (x + wd / 2 - 320, H), (x - wd / 2 - 320, H)], col)


def frame(t):
    fn = next(f for end, f in SCENES if t < end)
    c = fn(t)
    if CUT1 - .2 <= t < CUT1 + .2:
        ro = 2300 * ein(prog(t, CUT1 - .2, CUT1)) if t < CUT1 else 2300
        ri = 2300 * eout(prog(t, CUT1, CUT1 + .2)) if t >= CUT1 else 0
        annulus(c, 540, 1162, ri, ro, PEACH)
        if ro - ri > 4: annulus(c, 540, 1162, ri, min(ro, ri + 150), JADE)
    if CUT2 - .16 <= t < CUT2 + .2: slash(c, t, CUT2 - .16, (JADE, INK_D, PEACH))
    if CUT3 - .16 <= t < CUT3 + .2: slash(c, t, CUT3 - .16, (PEACH, INK_D, JADE))
    if CUT4 - .2 <= t < CUT4:
        annulus(c, 540, 1098, 0, 2400 * ein(prog(t, CUT4 - .2, CUT4)), IVORY)
    if CUT5 - .25 <= t < CUT5:
        p = eio(prog(t, CUT5 - .25, CUT5))
        for col, lead in ((PEACH, 70), (JADE, 0)):
            top = mix(H + 120, -140, p) + lead
            pts = [(x, top + 34 * math.sin(x / 120 + t * 14)) for x in range(-20, W + 41, 40)]
            poly(c, pts + [(W + 20, H + 20), (-20, H + 20)], col)
    return c.im.reduce(S).convert('RGB')


def frame_bytes(i): return frame(i / FPS / SPEED).tobytes()


# ---- sound ------------------------------------------------------------------
SR = 48000
NOTE = lambda n: 440 * 2 ** ((n - 69) / 12)
CHORDS = {'C': [60, 64, 67], 'G': [59, 62, 67], 'Am': [57, 60, 64], 'F': [57, 60, 65]}
ROOTS = {'C': 48, 'G': 43, 'Am': 45, 'F': 41}
PROG = [(0, 2, 'Am'), (2, 3, 'C'), (3, 4, 'G'), (4, 5, 'Am'), (5, 6, 'F'), (6, 7, 'C'), (7, 8, 'G'), (8, 9, 'Am'),
        (9, 10, 'F'), (10, 11, 'C'), (11, 12, 'G'), (12, 13.25, 'Am'), (13.25, 14.5, 'F'), (14.5, 15, 'C')]


def chord_at(t): return next(ch for a, b, ch in PROG if t < b)
def groove(t): return CUT1 <= t < 14.5


def soundtrack(path):
    n = int(SR * OUT_DUR)
    bus = {k: np.zeros((n, 2)) for k in ('drum', 'mus', 'sfx')}
    rng = np.random.default_rng(41)

    def add(b, at, sig, amp=1., pan=0.):
        i = int(round(at * SPEED * SR))
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
        x, q = noise(d), tt(d)
        out = np.zeros_like(x)
        for s_ in range(8):
            k = int(mix(k0, k1, s_ / 7 if up else 1 - s_ / 7))
            seg = slice(int(len(x) * s_ / 8), int(len(x) * (s_ + 1) / 8))
            out[seg] = lp(x, max(1, k))[seg]
        return out * np.sin(np.pi * q / d) ** 1.5

    def zip_up(d=.22, f0=320, f1=1100):
        q = tt(d)
        f = f0 * (f1 / f0) ** (q / d)
        return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.sin(np.pi * q / d) ** 2

    def key_tick():
        q = tt(.04)
        return (np.sin(2 * np.pi * 3100 * q) + .6 * hp(noise(.04), 2)) * np.exp(-q / .006)

    # hook: sparse plucks over a soft pad, typing ticks while the bubble waits
    for i in range(4):
        add('mus', i * BEAT, pluck(NOTE(CHORDS['Am'][i % 3] + 12), .6, .7, .25), .06, .3 * math.sin(i))
    for j, at in enumerate(np.arange(BUBBLE + .125, CUT1 - .2, .125)):
        add('sfx', at, key_tick(), .12 if j % 3 else .18, .3 * math.sin(j * 1.7))
    add('sfx', CUT1 - .2, whoosh(.2, True, 50, 3), .22)
    add('drum', CUT1, kick(2.), .6)
    add('sfx', CUT1, pop(300, .14), .45)
    # drums
    for k in range(30):
        at = k * BEAT
        if groove(at):
            add('drum', at, kick(), .75)
            if k % 2: add('drum', at, clap(), .28)
            add('drum', at + .25, hat(), .09, .3)
            if 4.5 <= at < 12.0:
                add('drum', at + .125, hat(.03), .04, -.3)
                add('drum', at + .375, hat(.03), .04, -.3)
    # harmony
    for i in range(60):
        at = i * .25
        ch = chord_at(at)
        if at >= 14.5: continue
        q = tt(.24)
        if at >= CUT1:
            add('mus', at, saw(NOTE(ROOTS[ch]), q, 6) * np.minimum(q / .004, 1) * np.exp(-q / .16), .12)
            tones = CHORDS[ch]
            add('mus', at, pluck(NOTE(tones[[0, 1, 2, 1, 2, 0, 2, 1][i % 8]] + 12), .4, 1., .14), .05, .35 * math.sin(i))
        if i % 2 == 1 and at >= CUT1:
            for nn in CHORDS[ch]: add('mus', at, pluck(NOTE(nn), .3, .8, .09), .04)
    for a, b, ch in PROG:
        d = (b - a) * SPEED + .4
        q = tt(d)
        env = np.minimum(q / .25, 1) * np.clip((d - q) / .4, 0, 1)
        add('mus', a, sum(np.sin(2 * np.pi * NOTE(nn) * dt * q) for nn in CHORDS[ch] for dt in (.997, 1.003)) * env, .024)
    # events
    for j, at in enumerate(AV_POP): add('sfx', at, pop(620 + 90 * j, .12), .3, -.4 + .8 * j)
    add('sfx', BUBBLE, pop(480, .12), .28)
    for j in range(2): add('sfx', QMARKS + j * .125, pop(900 + 150 * j, .08), .18, -.4 + .8 * j)
    for ts, L in zip(SLAMS, LANDS):
        add('sfx', ts, click(), .55, -.1)
        add('sfx', ts + .012, click(), .35, .1)
        add('sfx', L - .2, zip_up(.22, 300 + 80 * SLAMS.index(ts), 1000 + 150 * SLAMS.index(ts)), .08)
        add('sfx', L, pop(520, .1), .25)
    for j, nn in enumerate((72, 76, 79, 84)): add('mus', LANDS[3] + j * .04, bell(NOTE(nn), 1.3, .5), .06)
    add('sfx', 4.5, whoosh(.4, False, 4, 40), .15)
    add('sfx', CARD_SNAP, click(), .45)
    add('sfx', CARD_SNAP, pop(420, .1), .3)
    add('sfx', EYE, pop(1000), .2, -.4)
    add('sfx', ANYA_POP, pop(700, .12), .3, -.4)
    add('sfx', OFFER, whoosh(.25, True, 40, 3), .12, -.5)
    add('sfx', OFFER + .2, pop(560, .1), .24)
    for at in (CUT2 - .16, CUT3 - .16): add('sfx', at, whoosh(.35, True, 80, 2), .26)
    add('sfx', INVITE, pop(460, .14), .3)
    add('sfx', NOTE_IN, pop(800, .08), .12)
    add('sfx', ACCEPT, click(), .5)
    for j, nn in enumerate((72, 76, 79)): add('mus', ACCEPT + .03 * j, bell(NOTE(nn), 1.2, .5), .07)
    add('sfx', PAIR, whoosh(.25, False, 6, 40), .12)
    for j, at in enumerate(CHECKS): add('sfx', at + .02, bell(NOTE(84 + 3 * j), .5, .18), .08, -.4 + .8 * j)
    add('sfx', HEART, pop(380, .16), .3)
    add('mus', HEART + .02, bell(NOTE(88), .9, .35), .07)
    add('sfx', FRIENDS, pop(600, .1), .22)
    for j, at in enumerate(OWNERS): add('sfx', at, pop(620 + 90 * j, .12), .26, -.5 + j)
    for j in range(7): add('sfx', STREAM + j * .03, pop(1200 + 90 * j, .05), .06, -.6 + .2 * j)
    add('sfx', STREAM, zip_up(.25, 400, 1300), .07)
    for j, nn in enumerate((76, 81)): add('mus', SEED + .03 * j, bell(NOTE(nn), 1.0, .4), .08)
    add('sfx', SEED_FALL, whoosh(.25, False, 4, 50), .14)
    add('drum', SPROUT, kick(1.6), .35)
    add('sfx', SPROUT, pop(300, .14), .4)
    add('sfx', SPROUT, zip_up((BLOOM - SPROUT) * SPEED, 260, 900), .06)
    for j, nn in enumerate((72, 76, 79, 84, 88)): add('mus', BLOOM + j * .045, bell(NOTE(nn), 1.5, .6), .06)
    add('sfx', TOGETHER, pop(560, .1), .22)
    add('sfx', CUT4 - .2, whoosh(.2, True, 30, 2), .22)
    add('sfx', MSG1, pop(520, .12), .3, -.4)
    for j in range(3): add('sfx', TYPING + .02 + j * .08, key_tick(), .12, .4)
    add('sfx', MSG2, pop(760, .12), .3, .4)
    add('sfx', CUT5 - .27, whoosh(.3, True, 60, 3), .24)
    add('sfx', LOGO - .38, whoosh(.38, True, 50, 2), .2)
    add('sfx', LOGO, click(), .6, -.2)
    add('sfx', LOGO + .01, click(), .5, .2)
    add('drum', LOGO, kick(2.2), .55)
    for j, nn in enumerate((60, 64, 67, 72, 76, 79, 84)): add('mus', LOGO + j * .045, bell(NOTE(nn), 1.6, .8), .055)
    for at in (CTA_IN, *BADGES): add('sfx', at, pop(560, .1), .22)
    q = tt(1.5)
    add('mus', 14.5, sum(np.sin(2 * np.pi * NOTE(nn) * q) for nn in (48, 60, 64, 67, 72)) * np.exp(-q / .6) * np.minimum(q / .01, 1), .07)
    add('drum', 14.5, kick(1.5), .55)
    # sidechain, reverb, master
    duck = np.ones(n)
    for k in range(30):
        at = k * BEAT
        if groove(at):
            i = int(at * SPEED * SR)
            m = min(int(.22 * SR), n - i)
            duck[i:i + m] = np.minimum(duck[i:i + m], 1 - .4 * np.exp(-np.arange(m) / SR / .07))
    bus['mus'] *= duck[:, None]
    ir_n = int(1.6 * SR)
    ir = lp(rng.standard_normal(ir_n) * np.exp(-np.arange(ir_n) / SR / .45), 20)
    ir /= np.sqrt(np.sum(ir ** 2))
    nfft = 1 << (n + ir_n).bit_length()
    IR = np.fft.rfft(ir, nfft)
    wet_src = bus['mus'] * .7 + bus['sfx'] * .35
    wet = np.stack([np.fft.irfft(np.fft.rfft(wet_src[:, ch], nfft) * IR, nfft)[:n] for ch in range(2)], 1)
    mixd = bus['drum'] + bus['mus'] + bus['sfx'] + wet * .22
    tm = np.arange(n) / SR
    mixd *= np.minimum(tm / .005, 1)[:, None] * np.clip((OUT_DUR - tm) / .3, 0, 1)[:, None]
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
        else: marks = [.2, 1.3, 2.6, 4.2, 5.0, 5.9, 6.6, 7.7, 8.1, 9.2, 10.3, 10.9, 11.8, 12.9, 13.6, 14.8]
        cols = 8
        rows = math.ceil(len(marks) / cols)
        sheet = Image.new('RGB', (270 * cols, 480 * rows), rgb(INK_D))
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
           '-c:a', 'aac', '-b:a', '192k', '-t', str(OUT_DUR), '-movflags', '+faststart', str(OUT)]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    try:
        with Pool(max(1, (os.cpu_count() or 2) - 1)) as pool:
            for i, buf in enumerate(pool.imap(frame_bytes, range(round(FPS * OUT_DUR)), chunksize=2)):
                proc.stdin.write(buf)
                if i % 30 == 0: print(f'Render {i // 30:02d}/{OUT_DUR:g} s', flush=True)
    finally:
        proc.stdin.close()
    if proc.wait() != 0: raise RuntimeError('Video encoding failed')
    frame(14.8).save(BUILD / 'poster.jpg', quality=95)
    print(f'Exported {OUT} ({OUT.stat().st_size:,} bytes)', flush=True)


if __name__ == '__main__':
    main()
