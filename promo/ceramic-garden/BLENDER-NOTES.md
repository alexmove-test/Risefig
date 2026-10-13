# Blender proof of concept

Portable official Blender 4.5.9 LTS downloaded into tools/. No system installation or plugin required. Archive SHA256 matches the official manifest: 41da973b9bf95bb312cbeff4d1982feb13259b43c821686b9bafea4dfe5477cf.

- scene.py builds the editable scene and renders blender-proof.png.
- ceramic-garden.blend contains actual mesh geometry, materials, lights, camera and tile animation.
- motion_test.py renders 24 frames at 360×640 for a two-second 12 fps technical test.
- blender-motion-test.mp4 is the silent motion test, not a finished advertisement.

Observed still render: 720×1280, Cycles CPU, 32 samples with denoising, about 33 seconds. First tests used six CPU threads. Full-resolution production cost must be measured separately.

Quality assessment: the proof demonstrates local 3D rendering and animation but does not yet match approved-style.png. Moss is currently placeholder geometry; leaves lack detailed veins; lighting and ceramic microtexture require refinement. Do not label this scene as final commercial quality. The test does not implement growth, final typography or sound design.

Next artistic work: replace moss cushions and grass with detailed botanical geometry, add ceramic and stone variation, improve framing and depth of field, animate leaf unfolding, then approve a final-quality still before rendering all 14 seconds.
