"""12-second vertical TikTok cut. Pictures stay free of type; captions are composited here."""
from pathlib import Path
import math
import subprocess
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFont

ROOT = Path(r"C:\Code\Mahjong")
ASSETS = Path(r"C:\Users\Main\.cursor\projects\c-Code-Mahjong\assets")
OUT = Path(__file__).resolve().parent
FF = r"C:\Users\Main\AppData\Local\Programs\Python\Python312\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe"
FONT_PATH = ROOT / "promo" / "fonts" / "Unbounded.ttf"
W, H, FPS, D = 1080, 1920, 30, 12
CREAM = (255, 248, 236, 255)
JADE = (198, 236, 176, 255)
INK = (10, 16, 14, 255)

# start, end, file, zoom0, zoom1, focal (x, y)
SHOTS = [
    (0.00, 2.05, "tiktok-seed-01-match.jpg", 1.05, 1.14, (0.48, 0.62)),
    (2.05, 4.40, "tiktok-seed-02b-ground.jpg", 1.06, 1.12, (0.50, 0.55)),
    (4.40, 6.40, "tiktok-seed-03-one.jpg", 1.02, 1.10, (0.46, 0.52)),
    (6.40, 8.50, "tiktok-seed-04-wait.jpg", 1.08, 1.00, (0.50, 0.46)),
    (8.50, 10.60, "tiktok-seed-05b-meet.jpg", 1.12, 1.02, (0.50, 0.58)),
    (10.60, 12.00, "tiktok-seed-06-hold.jpg", 1.10, 1.00, (0.62, 0.42)),
]
FADE = 0.20

# start, end, lines, size, index of the jade line, optional small lockup
CARDS = [
    (0.06, 1.98, ["Я делаю", "это один."], 108, 1, False),
    (2.08, 6.32, ["Пасьянса", "мне мало."], 104, 1, False),
    (6.42, 8.40, ["Второй приходит,", "только если", "сам согласился."], 78, 2, False),
    (8.55, 11.90, ["Растение хранит", "его имя."], 92, 1, True),
]


def ease(x):
    x = max(0.0, min(1.0, x))
    return x * x * (3 - 2 * x)


def font(size, weight=760):
    face = ImageFont.truetype(str(FONT_PATH), size)
    face.set_variation_by_axes([weight])
    return face


def load_shots():
    loaded = []
    for start, end, name, z0, z1, focal in SHOTS:
        im = Image.open(ASSETS / name).convert("RGB")
        im = ImageEnhance.Contrast(im).enhance(1.06)
        im = ImageEnhance.Color(im).enhance(1.08)
        loaded.append((start, end, im, z0, z1, focal))
    return loaded


def cover(im, zoom, focal):
    sw, sh = im.size
    scale = max(W / sw, H / sh) * zoom
    nw, nh = max(W, int(sw * scale)), max(H, int(sh * scale))
    resized = im.resize((nw, nh), Image.Resampling.LANCZOS)
    fx, fy = focal
    left = min(max(0, int(nw * fx) - W // 2), nw - W)
    top = min(max(0, int(nh * fy) - H // 2), nh - H)
    return resized.crop((left, top, left + W, top + H))


def shot_frame(shots, index, t):
    start, end, im, z0, z1, focal = shots[index]
    local = 0 if end == start else (t - start) / (end - start)
    zoom = z0 + (z1 - z0) * ease(local)
    return cover(im, zoom, focal)


def picture(shots, t):
    index = 0
    for i, shot in enumerate(shots):
        if shot[0] <= t < shot[1] or i == len(shots) - 1:
            index = i
            break
    current = shot_frame(shots, index, min(t, shots[index][1] - 1e-4))
    start = shots[index][0]
    if index > 0 and t < start + FADE:
        previous = shot_frame(shots, index - 1, shots[index - 1][1] - 1e-4)
        return Image.blend(previous, current, ease((t - start) / FADE))
    return current


def scrim():
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for y in range(860):
        alpha = int(168 * (1 - y / 860) ** 1.55)
        draw.line((0, y, W, y), fill=(6, 14, 12, alpha))
    return layer


def fit_size(lines, size, max_w=860):
    while size > 52:
        face = font(size)
        if max(face.getlength(line) for line in lines) <= max_w:
            return size
        size -= 2
    return size


def caption(t):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    active = None
    for card in CARDS:
        if card[0] <= t <= card[1]:
            active = card
            break
    if active is None:
        return layer
    start, end, lines, size, accent, lockup = active
    appear = ease((t - start) / 0.16)
    leave = 1.0 if t < end - 0.14 else ease((end - t) / 0.14)
    alpha = appear * leave
    if alpha <= 0.01:
        return layer
    size = fit_size(lines, size)
    face = font(size)
    small = font(34, 640)
    gap = int(size * 0.16)
    heights = []
    for line in lines:
        box = face.getbbox(line)
        heights.append(box[3] - box[1])
    block = sum(heights) + gap * (len(lines) - 1)
    if lockup:
        block += 64
    rest_y = 300
    dy = int((1 - appear) * -28)
    draw = ImageDraw.Draw(layer)
    y = rest_y + dy
    longest = 0
    placed = []
    for i, line in enumerate(lines):
        width = face.getlength(line)
        longest = max(longest, width)
        x = (W - width) / 2
        fill = JADE if i == accent else CREAM
        fill = (*fill[:3], round(255 * alpha))
        stroke = (*INK[:3], round(255 * alpha))
        draw.text((x, y), line, font=face, fill=fill, stroke_width=10, stroke_fill=stroke)
        placed.append((x, y, width))
        y += heights[i] + gap
    rule_w = int(longest * ease(appear))
    rule_y = y + 22
    if rule_w > 8:
        rx = (W - rule_w) / 2
        draw.rounded_rectangle(
            (rx, rule_y, rx + rule_w, rule_y + 8),
            radius=4,
            fill=(*JADE[:3], round(230 * alpha)),
        )
    if lockup and appear > 0.4:
        label = "MAHJONG RISE"
        lw = small.getlength(label)
        draw.text(
            ((W - lw) / 2, rule_y + 28),
            label,
            font=small,
            fill=(*CREAM[:3], round(220 * alpha)),
            stroke_width=4,
            stroke_fill=(*INK[:3], round(220 * alpha)),
        )
    return layer


def score(path):
    sr = 48000
    n = sr * D
    mix = np.zeros((n, 2))
    rng = np.random.default_rng(12)

    def add(t, values, pan=0.0):
        k = int(t * sr)
        m = min(len(values), n - k)
        if m <= 0:
            return
        mix[k : k + m, 0] += values[:m] * math.sqrt((1 - pan) / 2)
        mix[k : k + m, 1] += values[:m] * math.sqrt((1 + pan) / 2)

    def bell(t, freq, dur=1.7, vol=0.06, pan=0.0):
        tt = np.arange(int(sr * dur)) / sr
        env = (1 - np.exp(-tt * 90)) * np.exp(-tt * 2.1 / dur)
        wave_v = np.sin(2 * np.pi * freq * tt) + 0.22 * np.sin(2 * np.pi * freq * 2.005 * tt) * np.exp(-tt * 2.4)
        add(t, vol * env * wave_v, pan)

    tt = np.arange(n) / sr
    bed = np.sin(np.pi * tt / D) ** 0.65
    for freq, vol in ((92, 0.034), (138.59, 0.02), (185, 0.012)):
        add(0, vol * bed * np.sin(2 * np.pi * freq * tt))
    slide_n = int(sr * 1.7)
    slide_t = np.arange(slide_n) / sr
    noise = np.convolve(rng.normal(size=slide_n), np.ones(48) / 48, mode="same")
    add(0.08, noise * 0.028 * np.sin(np.pi * slide_t / 1.7) ** 2)
    click_n = int(sr * 0.26)
    click_t = np.arange(click_n) / sr
    hit = (
        0.18 * np.exp(-click_t * 42) * np.sin(2 * np.pi * 1720 * click_t)
        + 0.08 * np.exp(-click_t * 74) * np.sin(2 * np.pi * 2860 * click_t)
        + 0.05 * rng.normal(size=click_n) * np.exp(-click_t * 190)
    )
    add(2.02, hit)
    drop_t = np.arange(int(sr * 0.18)) / sr
    add(2.32, 0.055 * np.exp(-drop_t * 28) * np.sin(2 * np.pi * 920 * drop_t), 0.25)
    for t, freq, pan in (
        (2.7, 523.25, -0.2),
        (3.45, 659.25, 0.25),
        (4.7, 783.99, -0.15),
        (6.7, 587.33, 0.1),
        (7.55, 880.0, -0.2),
        (8.62, 1046.5, 0.15),
        (10.75, 523.25, 0.0),
    ):
        bell(t, freq, 1.8, 0.05, pan)
    chord_t = np.arange(int(sr * 2.4)) / sr
    chord_env = np.sin(np.pi * np.arange(len(chord_t)) / len(chord_t)) ** 1.35
    for freq in (130.81, 164.81, 196.0, 261.63):
        add(9.6, 0.018 * chord_env * np.sin(2 * np.pi * freq * chord_t))
    fade = np.minimum(1, np.arange(n) / sr / 0.18) * np.minimum(1, (n - np.arange(n)) / sr / 0.4)
    mix *= fade[:, None]
    mix *= 0.82 / max(1e-9, float(np.abs(mix).max()))
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
    video = OUT / "Mahjong-Rise-TikTok-12s.mp4"
    score(wav)
    shots = load_shots()
    veil = scrim()
    keep = {24, 78, 168, 222, 282, 342}
    cmd = [
        FF, "-v", "error", "-y",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-",
        "-i", str(wav),
        "-map", "0:v", "-map", "1:a",
        "-c:v", "libx264", "-preset", "fast", "-crf", "18", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart", "-t", str(D),
        str(video),
    ]
    enc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    frames = FPS * D
    for frame in range(frames):
        t = frame / FPS
        image = picture(shots, t).convert("RGBA")
        image.alpha_composite(veil)
        image.alpha_composite(caption(t))
        rgb = image.convert("RGB")
        if frame in keep:
            rgb.save(review / f"f{t:05.2f}.jpg", quality=90)
        enc.stdin.write(rgb.tobytes())
        if frame % 60 == 0:
            print(f"frame {frame}/{frames}", flush=True)
    enc.stdin.close()
    if enc.wait() != 0:
        raise RuntimeError("ffmpeg failed")
    print(video, flush=True)


if __name__ == "__main__":
    main()
