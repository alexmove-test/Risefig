"""Bold 10s TikTok spot built from the game's own art. 1080x1920, 30fps.

Run: py -3.12 promo/tiktok-bold/render.py
"""
from pathlib import Path
import math
import subprocess
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont

ROOT = Path(r"C:\Code\Mahjong")
ASSETS = ROOT / "assets"
OUT = Path(__file__).resolve().parent
FF = r"C:\Users\Main\AppData\Local\Programs\Python\Python312\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe"
FONT = ROOT / "promo" / "fonts" / "Unbounded.ttf"
W, H, FPS, D = 1080, 1920, 30, 10
WHITE = (255, 255, 255, 255)
GOLD = (232, 201, 106, 255)
INK = (18, 12, 8, 255)


def ease(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3 - 2 * x)


def back(x):
    x = max(0.0, min(1.0, x))
    c1, c3 = 1.70158, 2.70158
    return 1 + c3 * (x - 1) ** 3 + c1 * (x - 1) ** 2


def lerp(a, b, t):
    return a + (b - a) * t


def font(size, weight=780):
    face = ImageFont.truetype(str(FONT), size)
    face.set_variation_by_axes([weight])
    return face


def load(path, key_black=False):
    im = Image.open(path).convert("RGBA")
    if key_black:
        arr = np.array(im)
        lum = arr[:, :, :3].max(axis=2).astype(np.int16)
        keyed = np.clip((lum - 10) * 7, 0, 255).astype(np.uint8)
        arr[:, :, 3] = np.minimum(arr[:, :, 3], keyed)
        im = Image.fromarray(arr)
    alpha = im.split()[-1]
    if alpha.getextrema()[0] > 250:
        arr = np.array(im)
        lum = arr[:, :, :3].max(axis=2).astype(np.int16)
        arr[:, :, 3] = np.clip((lum - 10) * 7, 0, 255).astype(np.uint8)
        im = Image.fromarray(arr)
        alpha = im.split()[-1]
    box = alpha.getbbox()
    if box:
        l, t, r, b = box
        im = im.crop((max(0, l - 4), max(0, t - 4), min(im.width, r + 4), min(im.height, b + 4)))
    return im


def hue_shift(im, amount):
    rgb = im.convert("RGB").convert("HSV")
    h, s, v = rgb.split()
    h = h.point(lambda p: (p + amount) % 256)
    out = Image.merge("HSV", (h, s, v)).convert("RGBA")
    out.putalpha(im.split()[-1])
    return out


def make_tile(base, fruit):
    tile = base.copy()
    tw, th = tile.size
    fw = int(tw * 0.58)
    fh = max(1, int(fw * fruit.height / fruit.width))
    glyph = fruit.resize((fw, fh), Image.Resampling.LANCZOS)
    tile.alpha_composite(glyph, (int(tw * 0.45 - fw / 2), int(th * 0.40 - fh / 2)))
    return tile


def make_seed():
    side = 860
    yy, xx = np.mgrid[0:side, 0:side]
    cx, cy, rx, ry = 430, 430, 390, 168
    nx = (xx - cx) / rx
    ny = (yy - cy) / ry
    dist = nx ** 2 + ny ** 2
    light = np.clip(1.18 - 0.42 * nx - 0.28 * ny, 0.55, 1.3)
    jade = np.clip((nx - 0.05) / 0.55, 0, 1)
    cream = np.array([246, 230, 188], dtype=np.float32)
    green = np.array([32, 148, 98], dtype=np.float32)
    color = cream * (1 - jade[..., None]) + green * jade[..., None]
    color = np.clip(color * light[..., None], 0, 255)
    image = np.zeros((side, side, 4), dtype=np.uint8)
    edge = np.clip((1 - dist) * 10, 0, 1)
    image[..., :3] = color.astype(np.uint8)
    image[..., 3] = (edge * 255).astype(np.uint8)
    hx = (xx - (cx - 120)) / 110
    hy = (yy - (cy - 46)) / 52
    highlight = (hx ** 2 + hy ** 2) < 1
    image[highlight, :3] = np.clip(image[highlight, :3].astype(np.int16) + 48, 0, 255)
    return Image.fromarray(image)


def make_ring():
    side = 700
    im = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    draw.ellipse((30, 30, side - 30, side - 30), outline=(255, 248, 220, 230), width=18)
    return im


def cover(im, zoom, fx, fy, ox, oy):
    scale = max(W / im.width, H / im.height) * zoom
    nw, nh = int(im.width * scale), int(im.height * scale)
    resized = im.resize((nw, nh), Image.Resampling.LANCZOS)
    left = min(max(0, int(nw * fx - W / 2 + ox)), nw - W)
    top = min(max(0, int(nh * fy - H / 2 + oy)), nh - H)
    return resized.crop((left, top, left + W, top + H)).convert("RGBA")


def blit(base, sprite, cx, cy, width, sx=1, sy=1, spin=0, alpha=255):
    if width < 4 or alpha <= 2:
        return
    height = max(2, int(sprite.height * width / sprite.width))
    w = max(2, int(width * sx))
    h = max(2, int(height * sy))
    sp = sprite.resize((w, h), Image.Resampling.LANCZOS)
    if abs(spin) > 0.2:
        sp = sp.rotate(spin, resample=Image.Resampling.BICUBIC, expand=True)
    if alpha < 255:
        band = sp.split()[-1].point(lambda p: p * alpha // 255)
        sp.putalpha(band)
    shade = Image.new("RGBA", sp.size, (0, 0, 0, 0))
    shade.putalpha(sp.split()[-1].point(lambda p: p * 70 // 255))
    blit_raw(base, shade, int(cx - sp.width / 2 + 16), int(cy - sp.height / 2 + 26))
    blit_raw(base, sp, int(cx - sp.width / 2), int(cy - sp.height / 2))


def blit_raw(base, sprite, x, y):
    x1, y1 = max(0, x), max(0, y)
    x2, y2 = min(W, x + sprite.width), min(H, y + sprite.height)
    if x2 <= x1 or y2 <= y1:
        return
    crop = sprite.crop((x1 - x, y1 - y, x2 - x, y2 - y))
    base.alpha_composite(crop, (x1, y1))


def squash(t, land):
    d = t - land
    if d < 0 or d > 0.16:
        return 1.0, 1.0
    k = math.sin(d / 0.16 * math.pi)
    return 1 + 0.10 * k, 1 - 0.14 * k


def shake(t, hits, amp=16):
    x = y = 0.0
    for hit in hits:
        d = t - hit
        if 0 <= d < 0.22:
            k = (1 - d / 0.22) * amp
            x += k * math.sin(d * 62)
            y += k * 0.55 * math.sin(d * 48)
    return x, y


def punch(t, hits):
    z = 0.0
    for hit in hits:
        d = t - hit
        if 0 <= d < 0.16:
            z += 0.05 * (1 - d / 0.16)
    return z


HITS = [0.50, 1.50, 3.00, 3.50, 5.00, 6.50, 8.00]


def scene(t):
    """Hero sprites for this instant: key, cx, cy, width, spin, alpha, land."""
    items = []
    if t < 1.55:
        p = back(min(1, t / 0.50))
        left = lerp(-260, 390, p)
        right = lerp(1340, 690, p)
        tilt = lerp(14, 0, p)
        fade = 1 if t < 1.15 else ease((1.55 - t) / 0.40)
        drop = 0 if t < 1.15 else lerp(0, 280, ease((t - 1.15) / 0.40))
        items.append(("tile", left, 1040 + drop, 500, tilt, fade, 0.50))
        items.append(("tile", right, 1040 + drop, 500, -tilt, fade, 0.50))
    if 1.15 < t < 4.85:
        p = back(min(1, (t - 1.15) / 0.35))
        fade = 1 if t < 4.35 else ease((4.85 - t) / 0.50)
        items.append(("bed", 540, lerp(1460, 1020, p), lerp(80, 680, p), 0, fade, 1.50))
    if 2.55 < t < 4.90:
        p = back(min(1, (t - 2.55) / 0.45))
        fade = 1 if t < 4.40 else ease((4.90 - t) / 0.50)
        items.append(("house", 500, lerp(80, 690, p), lerp(200, 700, p), 0, fade, 3.00))
        if t > 3.15:
            fp = back(min(1, (t - 3.15) / 0.35))
            items.append(("fox", 790, lerp(1320, 1080, fp), lerp(40, 320, fp), 0, fade, 3.50))
    if t >= 4.55:
        gap_end = 6.15
        if t < gap_end:
            p = back(min(1, (t - 4.55) / 0.45))
            lx, rx = 300, lerp(1500, 800, p)
            lw = rw = lerp(120, 520, min(1, p + 0.2))
        else:
            p = back(min(1, (t - gap_end) / 0.35))
            lx, rx = lerp(300, 340, p), lerp(800, 740, p)
            wide = 1 if t < 8.05 else ease((t - 8.05) / 0.6)
            lw = rw = lerp(520, 430, 1 - wide) if t < 8.05 else lerp(520, 360, ease((t - 8.05) / 0.7))
        items.append(("bed", lx, 1000, lw, 0, 1, 5.00 if t < gap_end else 6.50))
        items.append(("bed2", rx, 1020, rw, 0, 1, 5.00 if t < gap_end else 6.50))
    if t >= 6.45:
        p = back(min(1, (t - 6.45) / 0.28))
        items.append(("seed", 540, 1040, lerp(40, 460, p), 0, 1, 6.50))
    if t >= 7.7:
        p = ease(min(1, (t - 7.7) / 0.55))
        items.append(("house", 540, lerp(1500, 760, p), lerp(80, 560, p), 0, 1, 8.00))
        items.append(("fox", 860, lerp(1500, 1120, p), lerp(40, 300, p), 0, 1, 8.00))
    items.sort(key=lambda item: item[0] == "seed")
    return items


CARDS = [
    (0.00, 1.40, ["СНИМИ ПАРУ"], 118, None),
    (1.42, 2.90, ["ЭТОГО", "МАЛО"], 132, 1),
    (2.92, 4.90, ["Я ДЕЛАЮ", "ЭТО ОДИН"], 108, 1),
    (4.92, 6.40, ["ПРИХОДИТ", "САМ"], 124, 1),
    (6.42, 7.95, ["ИМЯ", "ОСТАЁТСЯ"], 120, 0),
    (8.00, 10.0, ["MAHJONG RISE", "вдвоём"], 86, 1),
]


def fit_size(lines, size):
    while size > 48:
        face = font(size)
        if max(face.getlength(line) for line in lines) <= 960:
            return size
        size -= 2
    return size


def caption(t):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    card = None
    for item in CARDS:
        if item[0] <= t < item[1]:
            card = item
            break
    if card is None:
        return layer
    start, end, lines, size, accent = card
    appear = back(min(1, (t - start) / 0.14))
    leave = 1 if t < end - 0.08 else ease((end - t) / 0.08)
    size = fit_size(lines, size)
    face = font(size)
    draw = ImageDraw.Draw(layer)
    y = 210 + int((1 - min(1, appear)) * -50)
    for i, line in enumerate(lines):
        width = face.getlength(line)
        x = (W - width) / 2
        fill = GOLD if i == accent else WHITE
        alpha = round(255 * leave)
        draw.text((x, y), line, font=face, fill=(*fill[:3], alpha), stroke_width=14, stroke_fill=(*INK[:3], alpha))
        box = face.getbbox(line)
        if i == accent:
            bar = int(width * min(1, appear))
            by = y + box[3] + 14
            draw.rounded_rectangle(((W - bar) / 2, by, (W + bar) / 2, by + 12), radius=6, fill=(*GOLD[:3], alpha))
        y += (box[3] - box[1]) + int(size * 0.12)
    return layer


def score(path):
    sr = 48000
    n = sr * D
    mix = np.zeros((n, 2))
    rng = np.random.default_rng(7)

    def add(t, values, pan=0.0):
        k = int(t * sr)
        m = min(len(values), n - k)
        if m <= 0:
            return
        mix[k : k + m, 0] += values[:m] * math.sqrt((1 - pan) / 2)
        mix[k : k + m, 1] += values[:m] * math.sqrt((1 + pan) / 2)

    def kick_at(t, vol=0.9):
        tt = np.arange(int(sr * 0.2)) / sr
        freq = 150 * np.exp(-tt * 26) + 48
        phase = 2 * np.pi * np.cumsum(freq) / sr
        add(t, vol * np.exp(-tt * 12) * np.sin(phase))

    def click_at(t):
        tt = np.arange(int(sr * 0.09)) / sr
        body = np.exp(-tt * 55) * np.sin(2 * np.pi * 2100 * tt)
        noise = rng.normal(size=len(tt)) * np.exp(-tt * 90)
        add(t, 0.35 * body + 0.18 * noise)

    def hat_at(t):
        tt = np.arange(int(sr * 0.04)) / sr
        add(t, 0.12 * rng.normal(size=len(tt)) * np.exp(-tt * 80), 0.3)

    beats = [i * 0.5 for i in range(20)]
    quiet = {5.5}
    for beat in beats:
        if any(abs(beat - q) < 0.2 for q in quiet):
            continue
        if beat < D:
            kick_at(beat, 0.72 if beat % 1 else 0.95)
            hat_at(beat + 0.25)
    for hit in (0.50, 1.50, 3.00, 5.00, 6.50):
        click_at(hit)
    # Bright stab on the seed and the title.
    for start, notes in (
        (1.5, (523.25, 659.25, 783.99)),
        (6.5, (659.25, 830.61, 1046.5)),
        (8.0, (523.25, 659.25, 783.99, 1046.5)),
    ):
        for i, freq in enumerate(notes):
            tt = np.arange(int(sr * 0.7)) / sr
            env = np.exp(-tt * 3.2) * (1 - np.exp(-tt * 40))
            add(start + i * 0.08, 0.16 * env * np.sin(2 * np.pi * freq * tt), -0.2 if i % 2 else 0.2)
    fade = np.minimum(1, np.arange(n) / sr / 0.05) * np.minimum(1, (n - np.arange(n)) / sr / 0.25)
    mix *= fade[:, None]
    mix *= 0.9 / max(1e-9, float(np.abs(mix).max()))
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(2)
        handle.setsampwidth(2)
        handle.setframerate(sr)
        handle.writeframes(np.int16(np.clip(mix, -1, 1) * 32767).tobytes())


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    review = OUT / "review"
    review.mkdir(exist_ok=True)
    tile_base = load(ASSETS / "tile_base.png")
    peach = load(ASSETS / "titles" / "fruit" / "10.png", key_black=True)
    bed = load(ASSETS / "courtyard" / "props" / "flower_bed.png")
    house = load(ASSETS / "courtyard" / "builds" / "house" / "12.png")
    fox = load(ASSETS / "pets" / "fox.png")
    meadow = Image.open(ASSETS / "courtyard" / "world" / "country_base.png").convert("RGB")
    meadow = ImageEnhance.Color(meadow).enhance(1.12)
    meadow = ImageEnhance.Contrast(meadow).enhance(1.05)
    sprites = {
        "tile": make_tile(tile_base, peach),
        "bed": bed,
        "bed2": hue_shift(bed, 70),
        "house": house,
        "fox": fox,
        "seed": make_seed(),
    }
    wav = OUT / "score.wav"
    video = OUT / "Mahjong-Rise-TikTok.mp4"
    score(wav)
    keep = {12, 24, 55, 100, 160, 210, 250, 285}
    cmd = [
        FF, "-v", "error", "-y",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-",
        "-i", str(wav), "-map", "0:v", "-map", "1:a",
        "-c:v", "libx264", "-preset", "fast", "-crf", "18", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart", "-t", str(D),
        str(video),
    ]
    enc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    frames = FPS * D
    for frame in range(frames):
        t = frame / FPS
        sx, sy = shake(t, HITS, 18)
        zoom = 1.12 - 0.08 * ease(t / D) + punch(t, HITS)
        image = cover(meadow, zoom, 0.50, 0.58, sx, sy)
        for key, cx, cy, width, spin, alpha, land in scene(t):
            qx, qy = squash(t, land)
            blit(image, sprites[key], cx + sx, cy + sy, width, qx, qy, spin, round(255 * alpha))
        flash = 0
        for hit in HITS:
            d = t - hit
            if 0 <= d < 0.07:
                flash = max(flash, 1 - d / 0.07)
        if flash:
            white = Image.new("RGBA", (W, H), (255, 255, 255, round(90 * flash)))
            image.alpha_composite(white)
        image.alpha_composite(caption(t))
        rgb = image.convert("RGB")
        if frame in keep:
            rgb.save(review / f"f{t:05.2f}.jpg", quality=90)
        enc.stdin.write(rgb.tobytes())
    enc.stdin.close()
    if enc.wait() != 0:
        raise RuntimeError("ffmpeg failed")
    print(video)


if __name__ == "__main__":
    main()
