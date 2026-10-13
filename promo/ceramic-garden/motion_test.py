import bpy, os
root=os.path.dirname(os.path.abspath(__file__))
bpy.ops.wm.open_mainfile(filepath=os.path.join(root,'ceramic-garden.blend'))
s=bpy.context.scene
s.render.resolution_x=360; s.render.resolution_y=640
s.cycles.samples=8; s.render.fps=12
os.makedirs(os.path.join(root,'motion-frames'),exist_ok=True)
for i in range(24):
 s.frame_set(1+round(i*59/23))
 s.render.filepath=os.path.join(root,'motion-frames',f'{i:04}.png')
 bpy.ops.render.render(write_still=True)
