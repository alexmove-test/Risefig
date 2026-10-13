"""Composite rendered 3D frames, original synthesized score, and titles."""
from pathlib import Path
import subprocess, math, wave
import numpy as np
from PIL import Image, ImageDraw, ImageFont
R=Path(__file__).resolve().parent
FF=r'C:\Users\Main\AppData\Local\Programs\Python\Python312\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe'
W,H,FPS,D=1080,1920,30,14
def ease(x): x=max(0,min(1,x)); return x*x*(3-2*x)
def score():
 sr=48000; mix=np.zeros((sr*D,2)); rng=np.random.default_rng(31)
 def add(t,v,pan=0):
  k=int(t*sr); n=min(len(v),len(mix)-k)
  if n<=0:return
  mix[k:k+n,0]+=v[:n]*math.sqrt((1-pan)/2); mix[k:k+n,1]+=v[:n]*math.sqrt((1+pan)/2)
 def bell(t,f,dur=1.8,vol=.08,pan=0):
  tt=np.arange(int(sr*dur))/sr; env=(1-np.exp(-tt*150))*np.exp(-tt*3/dur)
  v=vol*env*(np.sin(2*np.pi*f*tt)+.24*np.sin(2*np.pi*f*2.003*tt)*np.exp(-tt*3)+.08*np.sin(2*np.pi*f*3.99*tt)*np.exp(-tt*6))
  add(t,v,pan); add(t+.22,v*.12,-pan)
 notes=[261.63,329.63,392,523.25,440,329.63,293.66,392]
 for i in range(20):bell(.15+i*.65,notes[i%8],2,.085,(-.25 if i%2 else .25))
 for t,chord in [(0,[130.81,164.81,196]),(3.5,[110,130.81,164.81]),(7,[146.83,174.61,220]),(10.5,[130.81,164.81,196])]:
  tt=np.arange(int(sr*3.5))/sr; env=np.sin(np.pi*np.arange(len(tt))/len(tt))**1.6
  for f in chord:add(t,.022*env*(np.sin(2*np.pi*f*tt)+.3*np.sin(2*np.pi*f*2*tt)))
 # Ceramic contact, locked to the end of the tile movement at 4 seconds.
 tt=np.arange(int(sr*.35))/sr
 hit=.14*np.exp(-tt*35)*np.sin(2*np.pi*1750*tt)+.08*np.exp(-tt*60)*np.sin(2*np.pi*2800*tt)+.08*rng.normal(size=len(tt))*np.exp(-tt*160)
 add(4,hit)
 # Quiet sliding texture, then soft rising botanical accents.
 tt=np.arange(int(sr*3.8))/sr; noise=rng.normal(size=len(tt)); smooth=np.convolve(noise,np.ones(13)/13,mode='same')
 add(.1,smooth*.026*np.sin(np.pi*np.arange(len(tt))/len(tt))**2)
 for t,f in [(4.5,659.25),(5.1,783.99),(6,1046.5),(7.1,1318.5),(10.8,523.25)]:bell(t,f,1.7,.045)
 fade=np.minimum(1,np.arange(len(mix))/sr/.25)*np.minimum(1,(len(mix)-np.arange(len(mix)))/sr/.8)
 mix*=fade[:,None]; mix*=.76/max(1e-9,float(np.abs(mix).max()))
 with wave.open(str(R/'ad-sound.wav'),'wb') as out:
  out.setnchannels(2); out.setsampwidth(2); out.setframerate(sr); out.writeframes(np.int16(np.clip(mix,-1,1)*32767).tobytes())
def font(size):
 f=ImageFont.truetype(str(R.parent/'fonts'/'Montserrat.ttf'),size); f.set_variation_by_axes([650]); return f
def title(t):
 layer=Image.new('RGBA',(W,H)); d=ImageDraw.Draw(layer)
 a=ease((t-10.5)/.6)
 if a<=0:return layer
 for y in range(600):
  v=int(160*a*(1-y/600)**1.4); d.line((0,y,W,y),fill=(4,14,10,v))
 offset=round(24*(1-a))
 d.text((540,220+offset),'MAHJONG',font=font(77),anchor='mm',fill=(251,246,228,round(255*a)))
 d.text((540,315+offset),'RISE',font=font(104),anchor='mm',fill=(201,231,171,round(255*a)))
 b=ease((t-11.1)/.5)
 d.rounded_rectangle((172,1470,908,1584),radius=57,fill=(216,235,179,round(242*b)))
 d.text((540,1525),'Сделай первый ход',font=font(45),anchor='mm',fill=(18,45,28,round(255*b)))
 return layer
def main():
 score()
 # Interpolate motion before typography so lettering stays crisp.
 cmd=[FF,'-v','error','-y','-framerate','12','-start_number','1','-i',str(R/'ad-frames'/'%04d.png'),'-vf','tpad=stop_mode=clone:stop_duration=0.25,minterpolate=fps=30:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1:scd=fdiff','-t','14','-an','-c:v','libx264','-crf','16','-pix_fmt','yuv420p',str(R/'ad-motion-30fps.mp4')]
 subprocess.run(cmd,check=True)
 dec=subprocess.Popen([FF,'-v','error','-i',str(R/'ad-motion-30fps.mp4'),'-vf','scale=1080:1920:flags=lanczos','-f','rawvideo','-pix_fmt','rgb24','-'],stdout=subprocess.PIPE)
 enc=subprocess.Popen([FF,'-v','error','-y','-f','rawvideo','-pix_fmt','rgb24','-s','1080x1920','-r','30','-i','-','-i',str(R/'ad-sound.wav'),'-map','0:v','-map','1:a','-c:v','libx264','-preset','fast','-crf','18','-pix_fmt','yuv420p','-c:a','aac','-b:a','192k','-movflags','+faststart','-t','14',str(R/'Mahjong-Rise-3D-14s.mp4')],stdin=subprocess.PIPE)
 frames=0
 while True:
  raw=dec.stdout.read(W*H*3)
  if not raw:break
  if len(raw)!=W*H*3:raise RuntimeError('Incomplete decoded frame')
  im=Image.frombytes('RGB',(W,H),raw).convert('RGBA'); im.alpha_composite(title(frames/FPS)); im=im.convert('RGB')
  if frames in [30,120,210,390]:im.save(R/f'ad-review-{frames:03d}.jpg')
  enc.stdin.write(im.tobytes()); frames+=1
 enc.stdin.close()
 if dec.wait()!=0 or enc.wait()!=0:raise RuntimeError('Video encoding failed')
 if frames!=420:raise RuntimeError(f'Expected 420 frames, got {frames}')
 print('Completed: 420 frames, 14 seconds, sound and titles.',flush=True)
if __name__=='__main__':main()
