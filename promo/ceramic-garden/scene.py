import bpy, math, random, os
from mathutils import Vector
random.seed(31)
ROOT=os.path.dirname(os.path.abspath(__file__))
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
def mat(name,color,rough=.3,metal=0):
 m=bpy.data.materials.new(name); m.diffuse_color=(*color,1); m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF'); p.inputs['Base Color'].default_value=(*color,1); p.inputs['Roughness'].default_value=rough; p.inputs['Metallic'].default_value=metal
 return m
ivory=mat('Warm porcelain glaze',(.88,.80,.60),.23)
jade=mat('Deep jade enamel',(.022,.17,.10),.19)
gold=mat('Champagne inlay',(.56,.32,.09),.24,.72)
leafmat=mat('Fresh translucent leaves',(.18,.39,.025),.32)
leafmat.node_tree.nodes.get('Principled BSDF').inputs['Subsurface Weight'].default_value=.12
stone=mat('Warm limestone',(.27,.25,.18),.86)
n=stone.node_tree.nodes; noise=n.new('ShaderNodeTexNoise'); noise.inputs['Scale'].default_value=8; noise.inputs['Detail'].default_value=5
bump=n.new('ShaderNodeBump'); bump.inputs['Strength'].default_value=.3; bump.inputs['Distance'].default_value=.1
stone.node_tree.links.new(noise.outputs['Fac'],bump.inputs['Height']); stone.node_tree.links.new(bump.outputs[0],n.get('Principled BSDF').inputs['Normal'])
moss=[mat('Moss '+str(i),(.022+i*.008,.055+i*.018,.012+i*.003),.9) for i in range(5)]
def cube(name,loc,scale,ma,bev=.1,parent=None):
 bpy.ops.mesh.primitive_cube_add(size=1,location=loc); o=bpy.context.object; o.name=name; o.dimensions=scale; bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 o.data.materials.append(ma); b=o.modifiers.new('Soft crafted edges','BEVEL'); b.width=bev; b.segments=5; o.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
 if parent:o.parent=parent
 return o
def curve(name,pts,ma,width):
 c=bpy.data.curves.new(name,'CURVE'); c.dimensions='3D'; c.bevel_depth=width; c.bevel_resolution=3
 s=c.splines.new('BEZIER'); s.bezier_points.add(len(pts)-1)
 for b,pt in zip(s.bezier_points,pts): b.co=pt; b.handle_left_type='AUTO'; b.handle_right_type='AUTO'
 o=bpy.data.objects.new(name,c); bpy.context.collection.objects.link(o); o.data.materials.append(ma); return o
plinth=cube('Rounded stone garden', (0,0,-.22),(7,7,.42),stone,.3)
cube('Forest floor',(0,0,-.6),(200,200,.3),moss[0],.1)
for x,y,ang in [(-1.12,-.35,-.16),(1.10,.37,.14)]:
 bpy.ops.object.empty_add(); root=bpy.context.object; root.name='Tile assembly'
 cube('Jade ceramic base',(0,0,.24),(2.08,2.8,.5),jade,.17,root)
 cube('Ivory glazed face',(0,0,.52),(2.08,2.8,.29),ivory,.17,root)
 for u,v in [(-.51,-.74),(.51,-.74),(0,0),(-.51,.74),(.51,.74)]:
  bpy.ops.mesh.primitive_torus_add(major_radius=.235,minor_radius=.052,major_segments=48,minor_segments=12,location=(u,v,.674))
  o=bpy.context.object; o.name='Five circles jade inlay'; o.data.materials.append(jade); o.parent=root
  for f in o.data.polygons:f.use_smooth=True
  bpy.ops.mesh.primitive_torus_add(major_radius=.156,minor_radius=.012,major_segments=40,minor_segments=8,location=(u,v,.675)); o=bpy.context.object; o.data.materials.append(gold); o.parent=root
 root.location=(x,y,0); root.rotation_euler[2]=ang
 root.keyframe_insert(data_path='location',frame=60); root.location.x+=(-.35 if x<0 else .35); root.keyframe_insert(data_path='location',frame=1)
stem=curve('Living stem',[(0,.05,.3),(.08,.1,1),(-.03,.18,1.6),(.17,.22,2.4)],leafmat,.028)
for idx,(z,side,length) in enumerate([(1.05,-1,.95),(1.6,1,.98),(2.0,-1,.68)]):
 verts=[]; faces=[]
 for i in range(17):
  t=i/16; center=Vector((side*length*t,.18+.08*math.sin(t*math.pi),z+.55*t))
  width=.29*math.sin(math.pi*t)**.85
  for j in [-1,0,1]:verts.append(tuple(center+Vector((0,j*width,-abs(j)*.09*math.sin(math.pi*t)))))
 for i in range(16):
  for j in range(2):a=i*3+j; faces.append((a,a+1,a+4,a+3))
 mesh=bpy.data.meshes.new('Curved leaf'); mesh.from_pydata(verts,[],faces); mesh.update(); o=bpy.data.objects.new('Leaf',mesh); bpy.context.collection.objects.link(o); o.data.materials.append(leafmat)
 sol=o.modifiers.new('Leaf thickness','SOLIDIFY'); sol.thickness=.008
 sub=o.modifiers.new('Leaf smoothing','SUBSURF'); sub.levels=2
 for f in mesh.polygons:f.use_smooth=True
 curve('Leaf midrib',[(side*length*t,.18+.08*math.sin(t*math.pi),z+.55*t+.006) for t in [0,.25,.5,.75,1]],moss[4],.009)
for i in range(210):
 x=random.uniform(-5,5); y=random.uniform(-4,7)
 if abs(x)<2.35 and abs(y)<2:continue
 z=-.05 if abs(x)<3.4 and abs(y)<3.4 else -.39
 bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2,radius=1,location=(x,y,z)); o=bpy.context.object; o.name='Moss cushion'; r=random.uniform(.10,.43); o.scale=(r,r*.85,r*.45); o.data.materials.append(random.choice(moss))
 for f in o.data.polygons:f.use_smooth=True
for i in range(18):
 x=random.choice([-1,1])*random.uniform(2.8,5.5); y=random.uniform(1,8)
 for j in range(5):
  a=j*1.25; h=random.uniform(.7,1.8)
  curve('Garden grass',[(x,y,-.3),(x+.12*math.cos(a),y+.12*math.sin(a),h*.5),(x+.5*math.cos(a),y+.5*math.sin(a),h)],random.choice(moss),.023)
def light(name,loc,color,power,size,target):
 bpy.ops.object.light_add(type='AREA',location=loc); o=bpy.context.object; o.name=name; o.data.energy=power; o.data.color=color; o.data.shape='DISK'; o.data.size=size; o.rotation_euler=(Vector(target)-o.location).to_track_quat('-Z','Y').to_euler()
light('Sun through canopy',(-3,2,7),(1,.77,.43),1000,4,(0,0,0))
light('Cool sky reflection',(3,-3,5),(.59,.77,1),260,5,(0,0,0))
light('Leaf rim',(1,4,4),(1,.86,.55),700,3,(0,0,1))
bpy.ops.object.camera_add(location=(5,-8,7)); camera=bpy.context.object; camera.rotation_euler=(Vector((0,.2,.8))-camera.location).to_track_quat('-Z','Y').to_euler(); camera.data.lens=48
bpy.ops.object.empty_add(location=(0,0,.8)); focus=bpy.context.object; camera.data.dof.use_dof=True; camera.data.dof.focus_object=focus; camera.data.dof.aperture_fstop=6.3
scene=bpy.context.scene; scene.camera=camera; scene.render.engine='CYCLES'; scene.cycles.samples=32; scene.cycles.use_denoising=True
scene.world.color=(.12,.12,.12); scene.render.resolution_x=720; scene.render.resolution_y=1280; scene.render.resolution_percentage=100
scene.render.fps=30; scene.frame_end=60; scene.frame_set(60)
camera.keyframe_insert(data_path='location',frame=60); camera.location=(5.3,-8.4,7.3); camera.keyframe_insert(data_path='location',frame=1)
scene.render.image_settings.file_format='PNG'; scene.render.filepath=os.path.join(ROOT,'blender-proof.png')
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(ROOT,'ceramic-garden.blend'))
bpy.ops.render.render(write_still=True)
