import bpy, os, random, math
from mathutils import Vector
R=os.path.dirname(os.path.abspath(__file__)); random.seed(105)
bpy.ops.wm.open_mainfile(filepath=os.path.join(R,'ceramic-garden-v2.blend'))
s=bpy.context.scene
for o in bpy.data.objects:
 if o.name.startswith('Fern'):
  o.hide_render=True
stone=bpy.data.materials['Warm limestone']
for i in range(28):
 x=random.uniform(-7,7); y=random.uniform(3.5,10); r=random.uniform(.45,1.7)
 bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3,radius=1,location=(x,y,r*.25-.15)); o=bpy.context.object; o.name='Background weathered stone'; o.scale=(r,r*.8,r*.6); o.data.materials.append(stone)
 tex=bpy.data.textures.new('Rock irregularity','CLOUDS'); tex.noise_scale=.3
 mod=o.modifiers.new('Eroded surface','DISPLACE'); mod.texture=tex; mod.strength=.18
 for f in o.data.polygons:f.use_smooth=True
# Tightened three-quarter composition without clipping either complete tile.
cam=s.camera; cam.location=(1.5,-9.8,8.5); target=Vector((0,.35,.65)); cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler(); cam.data.lens=47
cam.data.dof.aperture_fstop=2.2
for name in ['Hero leaf left','Hero leaf high']:
 o=bpy.data.objects.get(name)
 if o:
  sub=o.modifiers.new('Soft organic silhouette','SUBSURF'); sub.levels=2
  solid=o.modifiers.new('Fine leaf thickness','SOLIDIFY'); solid.thickness=.004
for o in bpy.data.objects:
 if o.type=='LIGHT':
  if o.name=='Large softbox reflection':o.data.energy=95
  if o.name=='Warm low sunrise':o.data.energy=1500; o.data.size=1.4
s.render.resolution_x=1080; s.render.resolution_y=1920; s.cycles.samples=64
s.render.filepath=os.path.join(R,'blender-art-v3.png')
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(R,'ceramic-garden-v3.blend'))
bpy.ops.render.render(write_still=True)
