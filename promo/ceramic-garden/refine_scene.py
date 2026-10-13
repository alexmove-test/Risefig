"""Second art pass: real geometry and procedural materials, no image backdrop."""
import bpy, math, random, os
from mathutils import Vector
R=os.path.dirname(os.path.abspath(__file__)); random.seed(94)
bpy.ops.wm.open_mainfile(filepath=os.path.join(R,'ceramic-garden.blend'))
s=bpy.context.scene; s.frame_set(60)
for o in list(bpy.data.objects):
 if o.name.startswith(('Moss cushion','Garden grass','Leaf','Living stem')) or o.type=='LIGHT': bpy.data.objects.remove(o,do_unlink=True)
def material(name,c,rough=.4):
 m=bpy.data.materials.new(name); m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*c,1); p.inputs['Roughness'].default_value=rough
 return m
def texture(m,colors,scale,strength,distance):
 n=m.node_tree.nodes; l=m.node_tree.links; p=n.get('Principled BSDF')
 tex=n.new('ShaderNodeTexNoise'); tex.inputs['Scale'].default_value=scale; tex.inputs['Detail'].default_value=4
 ramp=n.new('ShaderNodeValToRGB'); ramp.color_ramp.elements[0].position=.2; ramp.color_ramp.elements[1].position=.8
 for el,c in zip(ramp.color_ramp.elements,colors): el.color=(*c,1)
 l.new(tex.outputs['Fac'],ramp.inputs[0]); l.new(ramp.outputs[0],p.inputs['Base Color'])
 b=n.new('ShaderNodeBump'); b.inputs['Strength'].default_value=strength; b.inputs['Distance'].default_value=distance
 l.new(tex.outputs['Fac'],b.inputs['Height']); l.new(b.outputs[0],p.inputs['Normal'])
 return p
ivory=bpy.data.materials['Warm porcelain glaze']; p=texture(ivory,[(.64,.53,.34),(.94,.86,.68)],155,.12,.014)
p.inputs['Coat Weight'].default_value=.42; p.inputs['Coat Roughness'].default_value=.17; p.inputs['Roughness'].default_value=.27
jade=bpy.data.materials['Deep jade enamel']; p=texture(jade,[(.008,.045,.025),(.042,.24,.13)],5,.08,.013)
p.inputs['Coat Weight'].default_value=.55; p.inputs['Coat Roughness'].default_value=.14
stone=bpy.data.materials['Warm limestone']; texture(stone,[(.10,.085,.055),(.39,.33,.22)],34,.6,.085)
# Pair arranged on a diagonal, keeping the central seam free for the sprout.
roots=sorted([o for o in bpy.data.objects if o.name.startswith('Tile assembly')],key=lambda o:o.name)
for o,loc,a in zip(roots,[(-.99,-.65,0),(.96,.65,0)],[-.13,.13]):
 o.animation_data_clear(); o.location=loc; o.rotation_euler[2]=a
for o in bpy.data.objects:
 if o.name.startswith('Five circles'):
  o.location.z=.647
 elif o.name.startswith('Torus'): o.location.z=.654
for o in bpy.data.objects:
 if o.name.startswith('Rounded stone'): o.scale=(1.5,1.5,1); o.modifiers['Soft crafted edges'].segments=8
def curve(name,pts,ma,r):
 c=bpy.data.curves.new(name,'CURVE'); c.dimensions='3D'; c.bevel_depth=r; c.bevel_resolution=3
 sp=c.splines.new('BEZIER'); sp.bezier_points.add(len(pts)-1)
 for b,co in zip(sp.bezier_points,pts): b.co=co; b.handle_left_type='AUTO'; b.handle_right_type='AUTO'
 o=bpy.data.objects.new(name,c); bpy.context.collection.objects.link(o); o.data.materials.append(ma); return o
leaf=material('Leaf translucent tissue',(.16,.34,.023),.38)
p=texture(leaf,[(.045,.13,.008),(.27,.47,.036)],12,.17,.009)
p.inputs['Subsurface Weight'].default_value=.08
n=leaf.node_tree.nodes; l=leaf.node_tree.links
trans=n.new('ShaderNodeBsdfTranslucent'); trans.inputs[0].default_value=(.22,.4,.04,1)
mix=n.new('ShaderNodeMixShader'); mix.inputs[0].default_value=.28
l.new(p.outputs[0],mix.inputs[1]); l.new(trans.outputs[0],mix.inputs[2]); l.new(mix.outputs[0],n.get('Material Output').inputs[0])
vein=material('Leaf vein',(.28,.43,.055),.45)
stemmat=material('Stem green',(.12,.23,.014),.4)
curve('Hero curved stem',[(0,.05,.35),(.04,.12,1.1),(-.1,.18,1.85),(.15,.26,2.65)],stemmat,.024)
def makeleaf(name,base,tip,width,ma,details=False):
 base=Vector(base); tip=Vector(tip); axis=tip-base; side=axis.cross(Vector((.1,-1,.3))).normalized()
 def point(t,u):
  w=width*math.sin(math.pi*t)**.85
  return base+axis*t+side*w*u+Vector((0,-.10*math.sin(math.pi*t)*(1-u*u),.09*math.sin(2*math.pi*t)))
 verts=[tuple(point(i/24,j/4)) for i in range(25) for j in range(-4,5)]
 faces=[]
 for i in range(24):
  for j in range(8):a=i*9+j; faces.append((a,a+1,a+10,a+9))
 me=bpy.data.meshes.new(name); me.from_pydata(verts,[],faces); me.update()
 o=bpy.data.objects.new(name,me); bpy.context.collection.objects.link(o); o.data.materials.append(ma)
 for f in me.polygons:f.use_smooth=True
 if details:
  curve(name+' midrib',[point(t,0)+Vector((0,-.008,0)) for t in [0,.2,.4,.6,.8,1]],vein,.006)
  for t in [.2,.32,.44,.56,.68,.8]:
   for sign in [-1,1]:curve(name+' secondary vein',[point(t,0)+Vector((0,-.009,0)),point(t+.04,sign*.5)+Vector((0,-.009,0)),point(min(.98,t+.105),sign*.89)+Vector((0,-.009,0))],vein,.0025)
 return o
makeleaf('Hero leaf left',(-.02,.16,1.53),(-1.03,.15,2.09),.32,leaf,True)
makeleaf('Hero leaf high',(.03,.23,2.12),(.61,.32,3.05),.29,leaf,True)
# Thousands of tiny tapered blades create moss instead of smooth placeholder balls.
mats=[material('Moss filament '+str(i),(.025+i*.008,.055+i*.019,.007+i*.003),.88) for i in range(6)]
verts=[]; faces=[]; indices=[]
for patch in range(210):
 x=random.uniform(-6,6); y=random.uniform(-5,8)
 if abs(x)<2.55 and abs(y)<2.25:continue
 radius=random.uniform(.15,.6)
 for j in range(110):
  a=random.random()*math.tau; rr=radius*math.sqrt(random.random()); px=x+rr*math.cos(a); py=y+rr*math.sin(a)
  h=random.uniform(.045,.15)+.09*(1-rr/radius); z=-.025
  w=random.uniform(.009,.022); lean=random.uniform(-.045,.045); b=len(verts)
  verts.extend([(px-w,py,z),(px+w,py,z),(px+lean+w*.3,py+.012,z+h*.65),(px+lean,py+.025,z+h),(px+lean-w*.3,py+.012,z+h*.65)])
  faces.extend([(b,b+1,b+2,b+4),(b+4,b+2,b+3)]); indices.extend([random.randrange(6)]*2)
me=bpy.data.meshes.new('Dense moss geometry'); me.from_pydata(verts,[],faces); me.update(); o=bpy.data.objects.new('Fine living moss carpet',me); bpy.context.collection.objects.link(o)
for m in mats:me.materials.append(m)
for f,i in zip(me.polygons,indices):f.material_index=i
# Fern fronds frame the composition, with paired tapered leaflets.
for k,(x,y,h) in enumerate([(-3,1,2.5),(3.2,2.5,2.8),(-2.8,4,2.7),(2.8,-2,1.2),(-3,-2.6,1.1),(1.5,5,3.1)]):
 for fr in range(3):
  direction=fr*1.1+k*.6; vec=Vector((math.cos(direction),math.sin(direction),0))
  def center(t):return Vector((x,y,0))+vec*(.8*t*t)+Vector((0,0,h*t-.35*t*t))
  curve('Fern rachis',[center(t) for t in [0,.25,.5,.75,1]],stemmat,.012)
  for j in range(3,15):
   t=j/16; c=center(t); lateral=Vector((-vec.y,vec.x,.1)); length=.43*math.sin(math.pi*t)**.8
   for sign in [-1,1]:makeleaf('Fern leaflet',c,c+lateral*sign*length+vec*.18+Vector((0,0,.08)),length*.19,leaf)
def area(name,loc,power,col,size,target):
 bpy.ops.object.light_add(type='AREA',location=loc); o=bpy.context.object; o.name=name; o.data.energy=power; o.data.color=col; o.data.shape='DISK'; o.data.size=size; o.rotation_euler=(Vector(target)-o.location).to_track_quat('-Z','Y').to_euler()
area('Warm low sunrise',(-3,3,5),1150,(1,.72,.35),2.1,(0,0,.5))
area('Large softbox reflection',(-2,-4,6),180,(.72,.84,1),5,(0,0,0))
area('Leaf transmitted rim',(1,3,3.5),460,(1,.85,.52),1.6,(0,0,1.6))
s.world.use_nodes=True; s.world.node_tree.nodes.get('Background').inputs[0].default_value=(.12,.18,.16,1); s.world.node_tree.nodes.get('Background').inputs[1].default_value=.18
cam=s.camera; cam.animation_data_clear(); cam.location=(3.4,-7.8,6.1); target=Vector((0,.1,1.1)); cam.rotation_euler=(target-cam.location).to_track_quat('-Z','Y').to_euler(); cam.data.lens=43
cam.data.dof.focus_object.location=(0,0,1); cam.data.dof.aperture_fstop=3.5
s.cycles.samples=48; s.cycles.use_denoising=True; s.cycles.max_bounces=8
s.render.resolution_x=720; s.render.resolution_y=1280
s.render.filepath=os.path.join(R,'blender-art-v2.png')
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(R,'ceramic-garden-v2.blend'))
bpy.ops.render.render(write_still=True)
