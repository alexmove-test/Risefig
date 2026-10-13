"""12s vertical TikTok cut of one courtyard. Hard cuts, big type, same place."""
from pathlib import Path
import math
import subprocess
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFont

ASSETS = Path(r"C:\Users\Main\.cursor\projects\c-Code-Mahjong\assets")
OUT = Path(__file__).resolve().parent
FF = r"C:\Users\Main\AppData\Local\Programs\Python\Python312\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe"
FONT = Path(r"C:\Code\Mahjong\promo\fonts\Unbounded.ttf")
W, H, FPS, D = 1080, 1920, 30, 12
WHITE = (255, 255, 255, 255)
GOLD = (232, 201, 106, 255)
INK = (12, 16, 14, 255)

# start, end, file, zoom0, zoom1, focal
SHOTS = [
    (0.00, 1.85, "tiktok-seed-01-match.jpg", 1.06, 1.16, (0.48, 0.62)),
    (1.85, 3.70, "tiktok-seed-02b-ground.jpg", 1.14, 1.04, (0.50, 0.55)),
    (3.70, 5.50, "rise-03-one.jpg", 1.04, 1.12, (0.50, 0.48)),
    (5.50, 8.05, "rise-04-wait.jpg", 1.10, 1.02, (0.50, 0.58)),
    (8.05, 10.20, "rise-05-seed.jpg", 1.16, 1.05, (0.48, 0.62)),
    (10.20, 12.00, "rise-06-hold.jpg", 1.12, 1.00, (0.42, 0.58)),
]
CUTS = [1.85, 5.50, 8.05]
CARDS = [
    (0.04, 1.78, ["Я ДЕЛАЮ", "ЭТО ОДИН"], 102, 1),
    (1.88, 5.42, ["ПАССЬЯНСА", "МАЛО"], 112, 1),
    (5.52, 7.98, ["ПРИХОДИТ", "САМ"], 116, 1),
    (8.08, 11.92, ["ИМЯ", "ОСТАЁТСЯ"], 108, 0),
]


def ease(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3 - 2 * x)


def lerp(a, b, t):
    return a + (b - a) * t


def font(size, weight=780):
    face = ImageFont.truetype(str(FONT), size)
    face.set_variation_by_axes([weight])
    return face


def load_shots():
    loaded = []
    for start, end, name, z0, z1, focal in SHOTS:
        im = Image.open(ASSETS / name).convert("RGB")
        im = ImageEnhance.Contrast(im).enhance(1.14)
        im = ImageEnhance.Color(im).enhance(1.1)
        loaded.append((start, end, im, z0, z1, focal))
    return loaded


def cover(im, zoom, fx, fy):
    scale = max(W / im.width, H / im.height) * zoom
    nw, nh = int(im.width * scale), int(im.height * scale)
    resized = im.resize((max(W, nw), max(H, nh)), Image.Resampling.LANCZOS)
    left = min(max(0, int(resized.width * fx - W / 2)), resized.width - W)
    top = min(max(0, int(resized.height * fy - H / 2)), resized.height - H)
    return resized.crop((left, top, left + W, top + H))


def shot_at(shots, index, t):
    start, end, im, z0, z1, focal = shots[index]
    local = 0 if end <= start else (t - start) / (end - start)
    # Snap in, then drift. TikTok punch, not a slow Ken Burns.
    zoom = lerp(z0, z1, ease(local))
    if local < 0.12:
        zoom *= lerp(1.06, 1.0, local / 0.12)
    return cover(im, zoom, focal[0], focal[1])


def picture(shots, t):
    index = len(shots) - 1
    for i, shot in enumerate(shots):
        if shot[0] <= t < shot[1]:
            index = i
            break
    current = shot_at(shots, index, min(t, shots[index][1] - 1e-3))
    start = shots[index][0]
    if index == 0 or t > start + 0.06:
        return current
    previous = shot_at(shots, index - 1, shots[index - 1][1] - 1e-3)
    return Image.blend(previous, current, (t - start) / 0.06)


def scrim():
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for y in range(720):
        alpha = int(150 * (1 - y / 720) ** 1.7)
        draw.line((0, y, W, y), fill=(8, 16, 14, alpha))
    return layer


def fit_size(lines, size):
    while size > 54:
        face = font(size)
        if max(face.getlength(line) for line in lines) <= 920:
            return size
        size -= 2
    return size


def caption(t):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    card = next((item for item in CARDS if item[0] <= t < item[1]), None)
    if card is None:
        return layer
    start, end, lines, size, accent = card
    appear = ease(min(1, (t - start) / 0.09))
    leave = 1 if t < end - 0.06 else ease((end - t) / 0.06)
    alpha = appear * leave
    if alpha <= 0.02:
        return layer
    size = fit_size(lines, size)
    face = font(size)
    draw = ImageDraw.Draw(layer)
    y = 188 + int((1 - appear) * -36)
    ink = (*INK[:3], round(255 * alpha))
    for i, line in enumerate(lines):
        width = face.getlength(line)
        x = (W - width) / 2
        fill = GOLD if i == accent else WHITE
        draw.text((x, y), line, font=face, fill=(*fill[:3], round(255 * alpha)), stroke_width=16, stroke_fill=ink)
        box = face.getbbox(line)
        if i == accent:
            bar = int(width * appear)
            by = y + box[3] + 18
            draw.rounded_rectangle(((W - bar) / 2, by, (W + bar) / 2, by + 14), radius=7, fill=(*GOLD[:3], round(255 * alpha)))
        y += (box[3] - box[1]) + int(size * 0.08)
    return layer


def score(path):
    sr = 48000
    n = sr * D
    mix = np.zeros((n, 2))
    rng = np.random.default_rng(4)

    def add(t, values, pan=0.0):
        k = int(t * sr)
        m = min(len(values), n - k)
        if m <= 0:
            return
        mix[k : k + m, 0] += values[:m] * math.sqrt((1 - pan) / 2)
        mix[k : k + m, 1] += values[:m] * math.sqrt((1 + pan) / 2)

    tt = np.arange(n) / sr
    bed = np.sin(np.pi * np.clip(tt / D, 0, 1)) ** 0.5
    for freq, vol in ((82, 0.05), (123.47, 0.028), (164.81, 0.016)):
        add(0, vol * bed * np.sin(2 * np.pi * freq * tt))
    for beat in np.arange(0, D, 0.5):
        click = np.arange(int(sr * 0.12)) / sr
        body = 0.22 * np.exp(-click * 18) * np.sin(2 * np.pi * (90 + 40 * np.exp(-click * 30)) * np.cumsum(np.ones_like(click)) / sr)
        # simpler kick
        freq = 120 * np.exp(-click * 22) + 46
        phase = 2 * np.pi * np.cumsum(freq) / sr
        add(float(beat), 0.34 * np.exp(-click * 14) * np.sin(phase))
    slide = np.arange(int(sr * 1.6)) / sr
    noise = np.convolve(rng.normal(size=len(slide)), np.ones(40) / 40, mode="same")
    add(0.05, noise * 0.03 * np.sin(np.pi * slide / 1.6) ** 2)
    hit_t = np.arange(int(sr * 0.16)) / sr
    ceramic = (
        0.28 * np.exp(-hit_t * 36) * np.sin(2 * np.pi * 1680 * hit_t)
        + 0.12 * np.exp(-hit_t * 70) * np.sin(2 * np.pi * 2740 * hit_t)
        + 0.08 * rng.normal(size=len(hit_t)) * np.exp(-hit_t * 160)
    )
    add(1.85, ceramic)
    for t, freq in ((5.5, 880.0), (8.05, 1174.66), (10.2, 659.25)):
        tone = np.arange(int(sr * 0.9)) / sr
        env = np.exp(-tone * 2.4) * (1 - np.exp(-tone * 50))
        add(t, 0.12 * env * np.sin(2 * np.pi * freq * tone), 0.15)
    fade = np.minimum(1, np.arange(n) / sr / 0.08) * np.minimum(1, (n - np.arange(n)) / sr / 0.35)
    mix *= fade[:, None]
    mix *= 0.88 / max(1e-9, float(np.abs(mix).max()))
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(2)
        handle.setsampwidth(2)
        handle.setframerate(sr)
        handle.writeframes(np.int16(np.clip(mix, -1, 1) * 32767).tobytes())


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    review = OUT / "review"
    review.mkdir(exist_ok=True)
    wav = OUT / "score.wav"
    video = OUT / "Mahjong-Rise-12s.mp4"
    score(wav)
    shots = load_shots()
    veil = scrim()
    keep = {20, 70, 140, 200, 270, 330}
    cmd = [
        FF, "-v", "error", "-y",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-",
        "-i", str(wav), "-map", "0:v", "-map", "1:a",
        "-c:v", "libx264", "-preset", "fast", "-crf", "17", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart", "-t", str(D),
        str(video),
    ]
    enc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    for frame in range(FPS * D):
        t = frame / FPS
        image = picture(shots, t).convert("RGBA")
        image.alpha_composite(veil)
        flash = 0
        for cut in CUTS:
            dlt = t - cut
            if 0 <= dlt < 0.05:
                flash = max(flash, 1 - dlt / 0.05)
        if flash:
            image.alpha_composite(Image.new("RGBA", (W, H), (255, 248, 230, round(70 * flash))))
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
