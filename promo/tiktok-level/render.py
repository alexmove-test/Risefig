"""8.9s vertical TikTok of one real level. Cold open on the last slot, then the combo.

1080x1920, 30fps. Source: promo/rec/rec_a.mp4
Run: py -3.12 promo/tiktok-level/render.py
"""
from pathlib import Path
import math
import subprocess
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont

ROOT = Path(r"C:\Code\Mahjong")
PROMO = ROOT / "promo"
REC = PROMO / "rec" / "rec_a.mp4"
OUT = Path(__file__).resolve().parent
FF = r"C:\Users\Main\AppData\Local\Programs\Python\Python312\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe"
FONT = PROMO / "fonts" / "Unbounded.ttf"

W, H, FPS = 1080, 1920, 30
SW, SH = 576, 1280
# Status bar, Android nav and the booster row are cropped.
# Height drives the scale so the tray stays whole at the top.
CROP = (0, 70, 576, 1040)
SFPS = 24.18
SRC0 = 0.48
COLD = 0.70
PLAY = 7.05
HOLD = 1.15
D = COLD + PLAY + HOLD
COLD_SRC = 6.85
WHITE = (255, 255, 255, 255)
GOLD = (255, 214, 90, 255)
INK = (8, 28, 16, 255)


def ease(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3 - 2 * x)


def back(x):
    x = max(0.0, min(1.0, x))
    c1, c3 = 1.4, 2.4
    return 1 + c3 * (x - 1) ** 3 + c1 * (x - 1) ** 2


def lerp(a, b, t):
    return a + (b - a) * t


def font(size, weight=820):
    face = ImageFont.truetype(str(FONT), size)
    face.set_variation_by_axes([weight])
    return face


def load_frames():
    raw = subprocess.run(
        [FF, "-v", "error", "-i", str(REC), "-f", "rawvideo", "-pix_fmt", "rgb24", "-"],
        capture_output=True,
        check=True,
    ).stdout
    frames = np.frombuffer(raw, np.uint8).reshape(-1, SH, SW, 3)
    return frames


def src_time(t):
    if t < COLD:
        # Creep toward the full tray so the open is already moving.
        return COLD_SRC + 0.22 * (t / COLD)
    if t < COLD + PLAY:
        return SRC0 + (t - COLD) * ((7.55 - SRC0) / PLAY)
    return 7.55 + 0.18 * min(1, (t - COLD - PLAY) / HOLD)


def frame_image(frames, t):
    st = src_time(t)
    i = min(len(frames) - 1, max(0, int(round(st * SFPS))))
    im = Image.fromarray(frames[i], "RGB")
    im = im.crop(CROP)
    im = ImageEnhance.Contrast(im).enhance(1.08)
    im = ImageEnhance.Color(im).enhance(1.14)
    return im


def cover(im, zoom):
    scale = max(W / im.width, H / im.height) * zoom
    nw, nh = int(im.width * scale), int(im.height * scale)
    resized = im.resize((nw, nh), Image.Resampling.LANCZOS)
    left = max(0, (nw - W) // 2)
    # Pin the tray to the top. Extra zoom only eats the side margins.
    top = 0 if nh <= H else min(int((nh - H) * 0.08), nh - H)
    return resized.crop((left, top, left + W, top + H))


def zoom_at(t):
    z = 1.0
    if t < COLD:
        z = lerp(1.06, 1.0, ease(t / COLD))
    elif t >= COLD + PLAY:
        u = (t - COLD - PLAY) / HOLD
        z = lerp(1.0, 1.05, ease(u))
    # Hits in source time, mapped through the play window.
    for hit in (1.50, 1.92, 4.35, 5.45, 6.55):
        out = COLD + (hit - SRC0) * (PLAY / (7.55 - SRC0))
        d = t - out
        if 0 <= d < 0.16:
            z += 0.055 * (1 - d / 0.16)
    return z


def shake_at(t):
    x = y = 0.0
    for hit in (0.02, 1.50, 1.92, 4.35, 5.45, 6.55):
        if hit < 1:
            out = hit
        else:
            out = COLD + (hit - SRC0) * (PLAY / (7.55 - SRC0))
        d = t - out
        if 0 <= d < 0.18:
            k = (1 - d / 0.18) * 14
            x += k * math.sin(d * 70)
            y += k * 0.4 * math.sin(d * 52)
    return x, y


def fit_size(lines, size, limit=980):
    while size > 64:
        face = font(size)
        if max(face.getlength(line) for line in lines) <= limit:
            return size
        size -= 2
    return size


# output start, end, lines, size, accent line, y
CARDS = [
    (0.02, 0.68, ["ОДНО", "МЕСТО"], 138, 1, 500),
    (1.95, 2.85, ["x2"], 250, 0, 520),
    (4.35, 5.35, ["x4"], 270, 0, 520),
    (7.78, D, ["НАЙДИ", "ПАРУ"], 124, 1, 500),
]


def caption(t):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    card = next((c for c in CARDS if c[0] <= t < c[1]), None)
    if card is None:
        return layer
    start, end, lines, size, accent, y0 = card
    appear = back(min(1, (t - start) / 0.12))
    leave = 1 if t < end - 0.08 else ease((end - t) / 0.08)
    alpha = appear * leave
    if alpha < 0.02:
        return layer
    size = fit_size(lines, size)
    face = font(size)
    draw = ImageDraw.Draw(layer)
    y = y0 + int((1 - min(1, appear)) * -70)
    for i, line in enumerate(lines):
        width = face.getlength(line)
        x = (W - width) / 2
        fill = GOLD if i == accent else WHITE
        a = round(255 * alpha)
        draw.text((x + 6, y + 8), line, font=face, fill=(0, 0, 0, round(a * 0.45)))
        draw.text((x, y), line, font=face, fill=(*fill[:3], a), stroke_width=18, stroke_fill=(*INK[:3], a))
        box = face.getbbox(line)
        y += (box[3] - box[1]) + int(size * 0.02)
    return layer


def score(path, game):
    sr = 48000
    n = int(sr * D)
    mix = np.zeros((n, 2))
    rng = np.random.default_rng(3)

    def add(t, values, pan=0.0, vol=1.0):
        k = int(t * sr)
        m = min(len(values), n - k)
        if m <= 0:
            return
        mix[k : k + m, 0] += values[:m] * vol * math.sqrt((1 - pan) / 2)
        mix[k : k + m, 1] += values[:m] * vol * math.sqrt((1 + pan) / 2)

    def boom(t, vol=0.9):
        tt = np.arange(int(sr * 0.42)) / sr
        freq = 90 * np.exp(-tt * 14) + 42
        phase = 2 * np.pi * np.cumsum(freq) / sr
        add(t, np.exp(-tt * 7) * np.sin(phase), vol=vol)

    def tick(t):
        tt = np.arange(int(sr * 0.05)) / sr
        add(t, np.exp(-tt * 80) * np.sin(2 * np.pi * 1800 * tt), vol=0.25)

    boom(0.02, 1.0)
    tick(0.04)
    # Game audio follows the play window. One constant rate, so clicks stay with the tiles.
    play_n = int(sr * PLAY)
    src_n = int(sr * (7.55 - SRC0))
    start = int(SRC0 * sr)
    piece = game[start : start + src_n]
    if len(piece) < 8:
        piece = np.zeros(src_n)
    idx = np.linspace(0, len(piece) - 1, play_n)
    stretched = np.interp(idx, np.arange(len(piece)), piece).astype(np.float32)
    # Fade the edges of the gameplay bed.
    ramp = np.minimum(1, np.arange(play_n) / (sr * 0.05))
    ramp *= np.minimum(1, (play_n - np.arange(play_n)) / (sr * 0.12))
    add(COLD, stretched * ramp, vol=0.85)
    for hit in (1.92, 4.35, 5.45):
        out = COLD + (hit - SRC0) * (PLAY / (7.55 - SRC0))
        boom(out, 0.55)
        tick(out)
    boom(COLD + PLAY, 0.7)
    # Low pulse under the last card.
    tt = np.arange(int(sr * HOLD)) / sr
    pulse = 0.12 * np.sin(2 * np.pi * 2 * tt) * np.sin(2 * np.pi * 92 * tt) * np.exp(-tt * 0.6)
    add(COLD + PLAY, pulse, vol=1)
    fade = np.minimum(1, np.arange(n) / (sr * 0.02))
    fade *= np.minimum(1, (n - np.arange(n)) / (sr * 0.18))
    mix *= fade[:, None]
    peak = max(1e-9, float(np.abs(mix).max()))
    mix *= 0.92 / peak
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(2)
        handle.setsampwidth(2)
        handle.setframerate(sr)
        handle.writeframes(np.int16(np.clip(mix, -1, 1) * 32767).tobytes())


def load_game_audio():
    raw = subprocess.run(
        [FF, "-v", "error", "-i", str(REC), "-vn", "-ac", "1", "-ar", "48000", "-f", "s16le", "-"],
        capture_output=True,
        check=True,
    ).stdout
    pcm = np.frombuffer(raw, np.int16).astype(np.float32) / 32767
    return pcm


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    review = OUT / "review"
    review.mkdir(exist_ok=True)
    frames = load_frames()
    game = load_game_audio()
    wav = OUT / "score.wav"
    video = OUT / "Mahjong-Rise-Level.mp4"
    score(wav, game)
    keep = {8, 22, 70, 110, 150, 200, 245}
    cmd = [
        FF, "-v", "error", "-y",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-",
        "-i", str(wav), "-map", "0:v", "-map", "1:a",
        "-c:v", "libx264", "-preset", "fast", "-crf", "17", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart", "-t", f"{D:.3f}",
        str(video),
    ]
    enc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    total = int(round(D * FPS))
    for frame in range(total):
        t = frame / FPS
        sx, sy = shake_at(t)
        image = cover(frame_image(frames, t), zoom_at(t))
        image = image.transform(
            image.size,
            Image.Transform.AFFINE,
            (1, 0, -sx, 0, 1, -sy),
            resample=Image.Resampling.BICUBIC,
            fillcolor=(18, 92, 48),
        )
        image = image.filter(ImageFilter.UnsharpMask(radius=1.4, percent=80, threshold=2))
        image = image.convert("RGBA")
        flash = 0
        if t < 0.07:
            flash = 1 - t / 0.07
        if COLD - 0.04 <= t < COLD + 0.05:
            flash = max(flash, 1 - abs(t - COLD) / 0.05)
        for hit in (1.92, 4.35):
            out = COLD + (hit - SRC0) * (PLAY / (7.55 - SRC0))
            d = t - out
            if 0 <= d < 0.06:
                flash = max(flash, 0.7 * (1 - d / 0.06))
        if flash:
            image.alpha_composite(Image.new("RGBA", (W, H), (255, 255, 255, round(110 * flash))))
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
