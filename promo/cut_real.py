"""Mahjong Rise — 15 s TikTok cut from real screen recordings (1080x1920, 30 fps).

Run: python promo/cut_real.py [--at 1.0,5.2]
Sources: promo/rec/rec_a.mp4 (mahjong round), promo/rec/rec_b.mp4 (yard, seeds, pet).
Footage keeps its own sound; only framing, tap marks and captions are added.
"""
from pathlib import Path
import math
import subprocess
import sys
import wave
from functools import lru_cache
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
PROMO = ROOT / 'promo'
REC = PROMO / 'rec'
BUILD = PROMO / 'real-build'
OUT = PROMO / 'Mahjong-Rise-Real-15s.mp4'
FONTS = PROMO / 'fonts'
FFMPEG = r'C:\Users\Main\AppData\Local\Programs\Python\Python312\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe'
W, H, FPS, DUR = 1080, 1920, 30, 15
SW, SH, SFPS = 576, 1280, 24.18
TOP, BOT = 40, 1228  # status bar and Android nav bar are cropped away
IVORY, JADE, PEACH, INK = '#F5EFE3', '#2F8F6B', '#FF9E7A', '#1E2433'

# Framing maps source point (fx, fy) to output point (ox, oy) at zoom k; start -> end keyframes.
# Shot bottoms keep tapped buttons above 75 % of the frame (TikTok caption zone).
SHOTS = [
    dict(src='rec_a', a=.85, b=5.25, f0=(288, 40, 540, 0, 1.6), f1=(288, 40, 540, -12, 1.66),
         cap=['Я делаю маджонг,', 'где за пары растёт огород'], cap_y=440, taps=[]),
    dict(src='rec_b', a=17.55, b=18.64, f0=(288, 300, 540, 0, 1.6), f1=(288, 300, 540, -6, 1.63),
         cap=['За очки сажаю семена'], cap_y=780, taps=[(18.5, 288, 1139)]),
    dict(src='rec_b', a=19.6, b=21.45, f0=(288, 300, 540, 0, 1.6), f1=(288, 300, 540, -6, 1.63),
         cap=['Растёт 20 минут —', 'или ускоряю и собираю'], cap_y=420, taps=[(20.37, 288, 1131), (21.22, 288, 1135)]),
    dict(src='rec_b', a=4.45, b=6.75, f0=(288, 230, 540, 0, 1.6), f1=(288, 230, 540, -6, 1.62),
         cap=['Урожаем кормлю хомяка —', 'он охраняет огород'], cap_y=1090,
         taps=[(5.06, 288, 1036), (5.77, 288, 355), (6.3, 288, 591)]),
    dict(src='rec_b', a=21.45, b=22.2, speed=.5, f0=(288, 630, 540, 528, 1.6), f1=(420, 650, 790, 840, 2.0),
         cap=['А если нападут,', 'на помощь придут соседи'], cap_y=330, taps=[], pulse=(500, 630)),
]
t = 0.
for s in SHOTS:
    s.setdefault('speed', 1.)
    s['start'] = t
    t += (s['b'] - s['a']) / s['speed']
    s['end'] = t
END_START = t
MUSIC_SRC = ('rec_b', 2.3)  # clean stretch: game music without UI clicks


def clamp(x, a=0., b=1.): return max(a, min(b, x))
def prog(x, a, b): return clamp((x - a) / (b - a))
def eout(x): x = clamp(x); return 1 - (1 - x) ** 3
def eio(x): x = clamp(x); return 4 * x ** 3 if x < .5 else 1 - (-2 * x + 2) ** 3 / 2
def back(x, s=1.7): x = clamp(x) - 1; return 1 + (s + 1) * x ** 3 + s * x * x
def mix(a, b, p): return a + (b - a) * p
def rgb(h): return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


@lru_cache(None)
def font(name, px, wght):
    f = ImageFont.truetype(str(FONTS / f'{name}.ttf'), px)
    f.set_variation_by_axes([wght])
    return f


@lru_cache(None)
def segment(src, a, b):
    raw = subprocess.run([FFMPEG, '-loglevel', 'error', '-ss', f'{a:.3f}', '-t', f'{b - a + .15:.3f}', '-i', str(REC / f'{src}.mp4'),
                          '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'], capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.uint8).reshape(-1, SH, SW, 3)


def src_frame(shot, st):
    frames = segment(shot['src'], shot['a'], shot['b'])
    i = min(len(frames) - 1, max(0, round((st - shot['a']) * SFPS)))
    return Image.fromarray(frames[i])


def backdrop(im):
    small = im.crop((0, TOP, SW, BOT)).resize((18, 32), Image.Resampling.BILINEAR)
    bg = small.resize((W, H), Image.Resampling.BICUBIC)
    return Image.blend(bg, Image.new('RGB', (W, H), rgb(INK)), .55).convert('RGBA')


def place_footage(canvas, im, fx, fy, ox, oy, k):
    """Paste the cropped recording so that source (fx, fy) lands on output (ox, oy)."""
    X0, Y0 = (0 - fx) * k + ox, (TOP - fy) * k + oy
    X1, Y1 = X0 + SW * k, Y0 + (BOT - TOP) * k
    vx0, vy0, vx1, vy1 = max(0, X0), max(0, Y0), min(W, X1), min(H, Y1)
    if vx1 <= vx0 or vy1 <= vy0: return
    box = ((vx0 - X0) / k, TOP + (vy0 - Y0) / k, (vx1 - X0) / k, TOP + (vy1 - Y0) / k)
    size = (round(vx1 - vx0), round(vy1 - vy0))
    piece = im.resize(size, Image.Resampling.LANCZOS, box=box).convert('RGBA')
    mask = Image.new('L', (W * 2, H * 2))
    ImageDraw.Draw(mask).rounded_rectangle((X0 * 2, Y0 * 2, X1 * 2, Y1 * 2), 64, fill=255)
    mask = mask.resize((W, H), Image.Resampling.BILINEAR).crop((round(vx0), round(vy0), round(vx0) + size[0], round(vy0) + size[1]))
    canvas.paste(piece, (round(vx0), round(vy0)), mask)


def to_out(f, sx, sy):
    fx, fy, ox, oy, k = f
    return (sx - fx) * k + ox, (sy - fy) * k + oy


def overlay_draw(canvas, fn):
    layer = Image.new('RGBA', (W * 2, H * 2))
    fn(ImageDraw.Draw(layer), 2)
    canvas.alpha_composite(layer.resize((W, H), Image.Resampling.LANCZOS))


def tap_mark(d, s, x, y, u):
    if not -.06 <= u < .45: return
    p = prog(u, -.06, .0)
    r = mix(46, 36, p) if u < .08 else 36
    a = (1 - prog(u, .12, .32)) * .55
    if a > 0: d.ellipse(((x - r) * s, (y - r) * s, (x + r) * s, (y + r) * s), fill=(255, 255, 255, round(255 * a)))
    q = prog(u, 0, .42)
    if 0 < q < 1:
        rr = mix(40, 110, eout(q))
        d.ellipse(((x - rr) * s, (y - rr) * s, (x + rr) * s, (y + rr) * s), outline=(255, 255, 255, round(220 * (1 - q))), width=round(6 * s))


def captions(canvas, lines, y, u, size=52):
    f = font('Montserrat', size * 2, 800)
    line_h = size * 1.62
    y0 = y - line_h * (len(lines) - 1) / 2
    layer = Image.new('RGBA', (W * 2, H * 2))
    d = ImageDraw.Draw(layer)
    for i, s in enumerate(lines):
        p = back(prog(u, .05 + i * .1, .3 + i * .1))
        if p <= 0: continue
        l, tp, r, b = f.getbbox(s)
        tw, cy = (r - l) / 2, y0 + i * line_h + 18 * (1 - clamp(p))
        _, ht, _, hb = f.getbbox('Н')
        bw, bh = tw / 2 + 26, (hb - ht) / 4 + 22
        sc = .9 + .1 * clamp(p)
        x0, x1 = 540 - bw * sc, 540 + bw * sc
        y0b, y1b = cy - bh * sc, cy + bh * sc
        alpha = round(255 * clamp(p * 1.5))
        d.rounded_rectangle((x0 * 2, y0b * 2, x1 * 2, y1b * 2), 20 * 2, fill=rgb(IVORY) + (alpha,))
        d.text((540 * 2, cy * 2 + 2), s, font=f, fill=rgb(INK) + (alpha,), anchor='mm')
    canvas.alpha_composite(layer.resize((W, H), Image.Resampling.LANCZOS))


@lru_cache(None)
def icon():
    im = Image.open(ROOT / 'store' / 'play-icon-512.png').convert('RGBA').resize((300, 300), Image.Resampling.LANCZOS)
    m = Image.new('L', (600, 600))
    ImageDraw.Draw(m).rounded_rectangle((0, 0, 599, 599), 132, fill=255)
    im.putalpha(Image.composite(im.getchannel('A'), Image.new('L', (300, 300)), m.resize((300, 300), Image.Resampling.LANCZOS)))
    return im


@lru_cache(None)
def end_backdrop():
    last = SHOTS[-1]
    im = src_frame(last, last['b'] - .02)
    bg = im.crop((0, TOP, SW, BOT)).resize((36, 64), Image.Resampling.BILINEAR).resize((W, H), Image.Resampling.BICUBIC)
    return Image.blend(bg, Image.new('RGB', (W, H), rgb(INK)), .62).convert('RGBA')


def end_card(t):
    c = end_backdrop().copy()
    u = t - END_START
    p = back(prog(u, 0, .35))
    if p > .01:
        ic = icon().resize((max(1, round(300 * p)), max(1, round(300 * p))), Image.Resampling.BICUBIC)
        c.alpha_composite(ic, (540 - ic.width // 2, 600 - ic.height // 2))

    def draw(d, s):
        def text(str_, y, size, col, name, wght, t0):
            q = eout(prog(u, t0, t0 + .3))
            if q <= 0: return
            d.text((540 * s, (y + 24 * (1 - q)) * s), str_, font=font(name, size * s, wght), anchor='mm', fill=rgb(col) + (round(255 * q),))
        text('Mahjong Rise', 860, 92, IVORY, 'Unbounded', 800, .25)
        text('маджонг · огород · соседи', 950, 40, IVORY, 'Montserrat', 600, .45)
        q = back(prog(u, .7, 1.0))
        if q > .01:
            beat = 1 + .035 * max(0, math.sin(max(0, u - 1.0) * math.pi * 2))
            bw, bh = 300 * q * beat, 58 * q * beat
            d.rounded_rectangle(((540 - bw) * s, (1110 - bh) * s, (540 + bw) * s, (1110 + bh) * s), bh * s, fill=rgb(PEACH) + (255,))
            d.text((540 * s, 1112 * s), 'Играть бесплатно', font=font('Montserrat', round(44 * q * beat * s), 800), anchor='mm', fill=rgb(INK) + (255,))
        text('Google Play · App Store', 1225, 34, IVORY, 'Montserrat', 600, .9)
    overlay_draw(c, draw)
    return c


def frame(t):
    if t >= END_START: return end_card(t).convert('RGB')
    shot = next(s for s in SHOTS if t < s['end'])
    u = t - shot['start']
    st = shot['a'] + u * shot['speed']
    im = src_frame(shot, st)
    e = eio(prog(u, 0, shot['end'] - shot['start']))
    f = tuple(mix(a, b, e) for a, b in zip(shot['f0'], shot['f1']))
    c = backdrop(im)
    place_footage(c, im, *f)

    def marks(d, s):
        for ti, sx, sy in shot['taps']:
            x, y = to_out(f, sx, sy)
            tap_mark(d, s, x, y, st - ti)
        if 'pulse' in shot:
            x, y = to_out(f, *shot['pulse'])
            for k in range(2):
                q = ((u * 1.3) + k * .5) % 1
                if u > .3:
                    rr = mix(70, 170, eout(q))
                    d.ellipse(((x - rr) * s, (y - rr) * s, (x + rr) * s, (y + rr) * s), outline=rgb(PEACH) + (round(255 * (1 - q)),), width=round(8 * s))
    overlay_draw(c, marks)
    captions(c, shot['cap'], shot['cap_y'], u)
    return c.convert('RGB')


def load_wav(name):
    path = REC / f'{name}.wav'
    if not path.exists():
        subprocess.run([FFMPEG, '-loglevel', 'error', '-y', '-i', str(REC / f'{name}.mp4'), '-vn', '-ac', '1', '-ar', '48000', str(path)], check=True)
    with wave.open(str(path)) as w:
        return np.frombuffer(w.readframes(w.getnframes()), '<i2') / 32768.


def soundtrack(path):
    sr = 48000
    n = sr * DUR
    out = np.zeros(n)
    src = {k: load_wav(k) for k in ('rec_a', 'rec_b')}
    xf = int(.04 * sr)

    def put(at, sig):
        i = int(at * sr)
        sig = sig[:n - i].copy()
        ramp = np.minimum(1, np.minimum(np.arange(len(sig)) / xf, (len(sig) - 1 - np.arange(len(sig))) / xf + 1))
        out[i:i + len(sig)] += sig * np.clip(ramp, 0, 1)

    for s in SHOTS[:-1]:
        a = int(s['a'] * sr)
        put(s['start'], src[s['src']][a:a + int((s['end'] - s['start']) * sr) + xf])
    name, at = MUSIC_SRC
    a = int(at * sr)
    put(SHOTS[-1]['start'], src[name][a:a + int((DUR - SHOTS[-1]['start']) * sr) + xf])
    tm = np.arange(n) / sr
    out *= np.clip((DUR - tm) / .9, 0, 1)
    rms = np.sqrt(np.mean(out[:int(12 * sr)] ** 2))
    out *= 10 ** (-16 / 20) / rms
    out = np.tanh(out * 1.1) / 1.1
    out *= min(1, .93 / np.max(np.abs(out)))
    stereo = np.repeat((out * 32767).astype('<i2')[:, None], 2, axis=1)
    with wave.open(str(path), 'wb') as w:
        w.setnchannels(2); w.setsampwidth(2); w.setframerate(sr)
        w.writeframes(stereo.tobytes())


def main():
    BUILD.mkdir(parents=True, exist_ok=True)
    if '--at' in sys.argv:
        marks = [float(x) for x in sys.argv[sys.argv.index('--at') + 1].split(',')]
        sheet = Image.new('RGB', (270 * len(marks), 480), rgb(INK))
        for i, tt in enumerate(marks):
            im = frame(tt)
            im.save(BUILD / f'f{tt:05.2f}.png')
            th = im.resize((270, 480), Image.Resampling.LANCZOS)
            dd = ImageDraw.Draw(th)
            dd.line((0, 360, 270, 360), fill=(255, 0, 0))
            dd.text((6, 456), f'{tt:.2f}s', font=font('Montserrat', 18, 800), fill='white', stroke_width=2, stroke_fill='black')
            sheet.paste(th, (i * 270, 0))
        sheet.save(BUILD / 'storyboard.jpg', quality=92)
        print(BUILD / 'storyboard.jpg')
        return
    wav = BUILD / 'soundtrack.wav'
    soundtrack(wav)
    cmd = [FFMPEG, '-y', '-loglevel', 'error', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-s', f'{W}x{H}', '-r', str(FPS), '-i', 'pipe:0',
           '-i', str(wav), '-c:v', 'libx264', '-preset', 'slow', '-crf', '17', '-pix_fmt', 'yuv420p', '-c:a', 'aac', '-b:a', '192k',
           '-t', str(DUR), '-movflags', '+faststart', str(OUT)]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    try:
        for i in range(FPS * DUR):
            proc.stdin.write(frame(i / FPS).tobytes())
            if i % 30 == 0: print(f'Render {i // 30:02d}/{DUR} s', flush=True)
    finally:
        proc.stdin.close()
    if proc.wait(): raise RuntimeError('encode failed')
    frame(2.0).save(BUILD / 'poster.jpg', quality=95)
    print(f'Exported {OUT} ({OUT.stat().st_size:,} bytes)')


if __name__ == '__main__':
    main()
