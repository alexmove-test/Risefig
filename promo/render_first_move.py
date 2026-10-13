"""Original procedural motion-design ad. Run with Python + Pillow + numpy."""
from pathlib import Path
import math, subprocess, wave
from functools import lru_cache
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'first-move-build'
OUT.mkdir(exist_ok=True)
FF = r'C:\Users\Main\AppData\Local\Programs\Python\Python312\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe'
W,H,FPS,DURATION = 1080,1920,30,15
CREAM='#F6F1DF'; GREEN='#BAE9A2'
def p(t,a,b): return max(0,min(1,(t-a)/(b-a)))
def ease(x): return 1-(1-x)**3
@lru_cache(None)
def font(s):
    f=ImageFont.truetype(str(ROOT/'fonts'/'Montserrat.ttf'),s)
    f.set_variation_by_axes([650])
    return f
def label(im,s,y,size=66,color=CREAM):
    d=ImageDraw.Draw(im); f=font(size)
    d.text((W/2,y),s,font=f,fill=color,anchor='mm',stroke_width=0)

# Soft illuminated backdrop, rendered once.
yy,xx=np.mgrid[0:H,0:W]
glow=np.exp(-(((xx-540)/680)**2+((yy-930)/790)**2)*1.8)
bg=np.stack([10+14*glow,23+38*glow,26+29*glow],axis=-1).astype('uint8')
BG=Image.fromarray(bg)
def tile(angle):
    im=Image.new('RGBA',(330,450)); d=ImageDraw.Draw(im)
    d.rounded_rectangle((23,35,307,432),radius=43,fill='#172E2C')
    d.rounded_rectangle((16,12,300,409),radius=43,fill='#8B9E87')
    d.rounded_rectangle((16,5,300,382),radius=43,fill=CREAM)
    d.rounded_rectangle((29,18,287,369),radius=33,outline='#FFFFFF',width=3)
    for x,y in [(102,122),(213,122),(157,195),(102,269),(213,269)]:
        d.ellipse((x-26,y-26,x+26,y+26),fill='#347563')
        d.ellipse((x-13,y-13,x+13,y+13),outline='#ACD6A0',width=4)
    return im.rotate(angle,Image.Resampling.BICUBIC,expand=True)
def place(im,asset,x,y): im.paste(asset,(round(x-asset.width/2),round(y-asset.height/2)),asset)
def frame(t):
    im=BG.copy(); d=ImageDraw.Draw(im)
    # Subtle orbital marks and drifting motes.
    for r in [365,465,565]:
        d.arc((540-r,985-r,540+r,985+r),205+t*3,335+t*3,fill='#28483F',width=2)
    for i in range(22):
        x=90+(i*137)%880; y=570+(i*173-t*(12+i%5))%850
        d.ellipse((x,y,x+3,y+3),fill='#577B66')
    label(im,'M A H J O N G   R I S E',225,30,GREEN)
    if t<3.5:
        a=ease(p(t,0,.7)); y=435+35*(1-a)
        label(im,'Сложно сделать',y,64)
        label(im,'первый шаг?',y+86,78)
        msg='Привет…'[:int(p(t,.6,1.8)*7)]
        if t>2.5: msg=msg[:max(0,7-int((t-2.5)*12))]
        d.rounded_rectangle((270,1280,810,1400),radius=60,fill='#274B40')
        label(im,msg+('|' if int(t*3)%2==0 else ''),1340,47)
    elif t<7:
        label(im,'Начни',440,78); label(im,'с игры.',540,96,GREEN)
    elif t<11:
        label(im,'Знакомства',435,76); label(im,'начинаются',525,64)
        label(im,'с малого.',615,76,GREEN)
    else:
        label(im,'Mahjong',455,106); label(im,'Rise',580,130,GREEN)
    join=ease(p(t,3.6,5.2))
    spread=300-143*join
    end=ease(p(t,10.6,11.5))
    cy=1000+end*50
    for sign in [-1,1]:
        angle=sign*(13-join*9)+math.sin(t*2+sign)*1.8
        place(im,tile(angle),540+sign*spread,cy+math.sin(t*2+sign)*12)
    d=ImageDraw.Draw(im)
    grow=ease(p(t,6.4,8.8))
    if grow>0:
        base=1110; top=base-360*grow
        pts=[(540+math.sin(i/30*2.4)*20*grow,base-i/30*360*grow) for i in range(31)]
        d.line(pts,fill=GREEN,width=12)
        for j,sgn in enumerate([-1,1,-1,1]):
            leaf=ease(p(t,6.9+j*.32,7.6+j*.32)); y=base-80-j*66
            x=551; tip=(x+sgn*115*leaf,y-75*leaf)
            polygon=[]
            for k in range(31):
                u=k/30; polygon.append((x+(tip[0]-x)*u,y+(tip[1]-y)*u-35*leaf*math.sin(math.pi*u)))
            for k in range(30,-1,-1):
                u=k/30; polygon.append((x+(tip[0]-x)*u,y+(tip[1]-y)*u+24*leaf*math.sin(math.pi*u)))
            d.polygon(polygon,fill=GREEN if j%2 else '#71B88A')
    if 5.1<t<6.1:
        q=p(t,5.1,6.1)
        for i in range(12):
            a=i*math.pi/6; r=90+280*q
            x=540+math.cos(a)*r; y=1000+math.sin(a)*r
            sz=7*(1-q); d.ellipse((x-sz,y-sz,x+sz,y+sz),fill=GREEN)
    if t>=11:
        d.rounded_rectangle((160,1350,920,1480),radius=65,fill=GREEN)
        label(im,'Сделай первый ход',1415,49,'#102D25')
        label(im,'Играй. Знакомься. Расти.',1560,36)
    elif t>=7:
        label(im,'Одна игра. Новый повод общаться.',1430,37)
    return im

def audio():
    sr=48000; n=sr*DURATION; mix=np.zeros(n)
    def note(start,f,dur,vol):
        count=min(int(dur*sr),n-int(start*sr)); tt=np.arange(count)/sr
        env=(1-np.exp(-tt*55))*np.exp(-tt*3.7/dur)
        v=(np.sin(2*np.pi*f*tt)+.22*np.sin(2*np.pi*f*2*tt))*env*vol
        k=int(start*sr); mix[k:k+count]+=v
    melody=[261.63,329.63,392,493.88,440,392,329.63,293.66]
    for i in range(30):
        note(i*.5,melody[i%8],1.3,.10)
        if i%4==0: note(i*.5,130.81 if i%8==0 else 110,1.9,.12)
    for t in [3.5,5.2,7,11]: note(t,1046.5,.25,.20); note(t+.065,1567.98,.3,.10)
    mix*=np.minimum(1,np.arange(n)/sr/.35)*np.minimum(1,(n-np.arange(n))/sr/.65)
    stereo=np.column_stack([mix,mix*.96]); stereo=np.int16(np.clip(stereo,-.95,.95)*32767)
    with wave.open(str(OUT/'sound.wav'),'wb') as f:
        f.setnchannels(2); f.setsampwidth(2); f.setframerate(sr); f.writeframes(stereo.tobytes())

if __name__=='__main__':
    audio()
    previews=[]
    for t in [1.5,4.5,8.5,12.5]:
        im=frame(t); im.save(OUT/f'frame-{t}.jpg'); previews.append(im.resize((270,480)))
    sheet=Image.new('RGB',(1080,480))
    for i,im in enumerate(previews): sheet.paste(im,(i*270,0))
    sheet.save(OUT/'storyboard.jpg')
    cmd=[FF,'-y','-f','rawvideo','-vcodec','rawvideo','-pix_fmt','rgb24','-s',f'{W}x{H}','-r',str(FPS),'-i','-','-i',str(OUT/'sound.wav'),'-c:v','libx264','-preset','fast','-crf','19','-pix_fmt','yuv420p','-c:a','aac','-b:a','192k','-movflags','+faststart','-t',str(DURATION),str(ROOT/'Mahjong-Rise-First-Move.mp4')]
    with open(OUT/'encode.log','w') as log:
        proc=subprocess.Popen(cmd,stdin=subprocess.PIPE,stderr=log)
        for i in range(FPS*DURATION):
            proc.stdin.write(frame(i/FPS).tobytes())
            if i%90==0: print(f'Rendered {i}/{FPS*DURATION}',flush=True)
        proc.stdin.close()
        if proc.wait(): raise RuntimeError('Encoding failed: see encode.log')
    print('DONE',flush=True)
