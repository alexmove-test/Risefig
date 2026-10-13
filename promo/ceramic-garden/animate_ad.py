import bpy, os, math, sys
from mathutils import Vector
R=os.path.dirname(os.path.abspath(__file__))
bpy.ops.wm.open_mainfile(filepath=os.path.join(R,'ceramic-garden-v3.blend'))
s=bpy.context.scene; cam=s.camera
s.render.engine='CYCLES'; s.cycles.samples=8; s.cycles.use_denoising=True
s.render.resolution_x=540; s.render.resolution_y=960; s.render.resolution_percentage=100
s.render.fps=12; s.frame_start=1; s.frame_end=168
s.render.use_persistent_data=True
roots=sorted([o for o in bpy.data.objects if o.name.startswith('Tile assembly')],key=lambda o:o.name)
original=[o.location.copy() for o in roots]
plant=[o for o in bpy.data.objects if o.name.startswith(('Hero leaf','Hero curved stem'))]
bpy.ops.object.empty_add(location=(0,.1,.35)); growth=bpy.context.object; growth.name='Animated plant growth'
for o in plant:
 world=o.matrix_world.copy(); o.parent=growth; o.matrix_world=world
def ease(x):x=max(0,min(1,x)); return x*x*(3-2*x)
def lerp(a,b,t):return Vector(a).lerp(Vector(b),t)
def position(t):
 if t<3:
  q=ease(t/3); return lerp((1.8,-5.1,4.9),(2.2,-6.9,6.2),q),lerp((-.7,-.5,.4),(0,0,.6),q),49
 if t<10:
  q=ease((t-3)/7); return lerp((1.7,-9.7,8.1),(.6,-8.6,6.9),q),lerp((0,0,.7),(0,.15,1.1),q),47
 q=ease((t-10)/4); return lerp((.6,-8.6,6.9),(1.5,-10.5,8.5),q),lerp((0,.15,1.1),(0,.35,.85),q),47
for f in range(1,169):
 t=(f-1)/12
 for i,o in enumerate(roots):
  offset=(1-ease(t/4))*.63
  o.location=original[i]+Vector(((-1 if i==0 else 1)*offset,0,0)); o.keyframe_insert(data_path='location',frame=f)
 g=ease((t-4.3)/3.5)
 growth.scale=(max(.001,g**.65),max(.001,g**.65),max(.001,g)); growth.rotation_euler[2]=.018*math.sin(t*2)*g
 growth.keyframe_insert(data_path='scale',frame=f); growth.keyframe_insert(data_path='rotation_euler',frame=f)
 loc,target,lens=position(t); cam.location=loc; cam.rotation_euler=(target-loc).to_track_quat('-Z','Y').to_euler(); cam.data.lens=lens
 cam.keyframe_insert(data_path='location',frame=f); cam.keyframe_insert(data_path='rotation_euler',frame=f); cam.data.keyframe_insert(data_path='lens',frame=f)
 cam.data.dof.focus_object.location=(0,0,.65+g*.5); cam.data.dof.focus_object.keyframe_insert(data_path='location',frame=f)
os.makedirs(os.path.join(R,'ad-frames'),exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(R,'ceramic-garden-animated.blend'))
args=sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else []
frames=[1,37,79,121,168] if 'preview' in args else range(1,169)
for f in frames:
 path=os.path.join(R,'ad-frames',f'{f:04d}.png')
 if os.path.exists(path):continue
 s.frame_set(f); s.render.filepath=path; bpy.ops.render.render(write_still=True)
 print('AD_FRAME',f,flush=True)
