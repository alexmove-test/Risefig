# Rise Fig — 3D garden animation

The user approved animation at the current V3 scene quality. This is not represented as matching the generated photorealistic reference.

## Production

- Source: ceramic-garden-v3.blend.
- Animation: animate_ad.py / ceramic-garden-animated.blend.
- 14 seconds. Actual 3D tile translation, animated camera, scaled botanical emergence and subtle plant sway.
- First 3 seconds: macro reveal. 3–10 seconds: paired tiles and plant growth. 10–14 seconds: pullback and brand end card.
- Native 3D render: 540×960, 12 fps, Cycles, eight samples with denoising.
- Delivery: 1080×1920, 30 fps, H.264 / yuv420p + stereo AAC. Frames are enlarged with Lanczos and motion-interpolated; this is not native 1080p/30 rendering.
- Music and ceramic contact sound are synthesized in assemble_ad.py. No externally licensed audio was used.
- Contact accent at 4 seconds. Titles begin at 10.5 seconds; call to action begins at 11.1 seconds.

## Files

- Mahjong-Rise-3D-14s.mp4 — final composite, once assembly completes.
- ad-motion-30fps.mp4 — intermediate clean animation without titles or audio.
- ad-sound.wav — original stereo soundtrack.
- ad-review-*.jpg — frames extracted during final compositing for visual review.

## Limitations

The environment retains the stylized appearance of V3. Plant emergence uses scale animation rather than simulated biological unfolding. Motion interpolation can introduce local artifacts. The low native sample count can produce changing fine surface detail. No game UI or recorded gameplay is shown.
