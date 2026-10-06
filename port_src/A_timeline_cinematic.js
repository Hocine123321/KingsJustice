const GM={on:false,shake:0,over:false,won:false,hp:100,maxhp:100,_flashHurt:0};
var KN2=null,KG2=null,KP={cur:[0,0,0,0,0,0,0,0]},GP={cur:[0,0,0,0,0,0,0,0]};
const DUR=34;

/* ---------- bezier easing ---------- */
const bez=(a,b,c,d)=>x=>{let t=x;for(let i=0;i<8;i++){const u=1-t,cx=3*a*t*u*u+3*c*t*t*u+t**3-x,dx=3*a*u*u+6*(c-a)*t*u+3*(1-c)*t*t;if(Math.abs(dx)<1e-6)break;t-=cx/dx}t=clamp(t);const u=1-t;return 3*b*t*u*u+3*d*t*t*u+t**3};
const E={
  h:bez(.7,0,.3,1),      // heavy: slow-in slow-out
  s:bez(.85,0,1,.4),     // snap: slow wind-up, violent end
  o:bez(.1,.8,.2,1),     // out: fast start, soft landing
  z:bez(.45,0,.15,1),    // camera push
  l:x=>x                 // linear
};
const samp=(K,t)=>{let i=0;while(i<K.length-2&&t>K[i+1][0])i++;const a=K[i],b=K[i+1],u=E[b[1]](clamp((t-a[0])/(b[0]-a[0])));return a.slice(2).map((v,j)=>v+(b[j+2]-v)*u)};

/* ===================================================================
   KEYFRAMES  [time, ease, x, lean, upperArm, forearm, sword, shield, fall, crouch]
   =================================================================== */
const KN=[
 [0,'h',420,0,-40,40,80,0,0,0],[5,'h',420,0,-40,40,80,0,0,0],
 [6.8,'h',455,3,-40,45,75,0,0,2],
 // clash 1
 [8.3,'h',445,10,70,95,115,0,0,3],[8.8,'s',482,-2,-5,5,40,0,0,0],
 [9.9,'h',455,2,-30,50,85,.3,0,0],
 // clash 2
 [11.2,'h',450,8,75,100,120,0,0,3],[11.7,'s',485,-3,-10,0,35,.4,0,0],
 [13.0,'h',450,2,-35,45,80,.8,0,0],
 // clash 3 (knight pushed back)
 [14.3,'h',460,8,60,90,110,.3,0,3],[14.7,'s',490,-2,-5,10,45,.2,0,0],
 [16.2,'h',470,3,-35,40,75,.7,0,2],
 // king's overhead — knight raises shield, still hurt
 [17.6,'h',480,4,-30,60,90,.9,0,0],[18.35,'o',420,-24,-75,-55,-35,-.4,0,6],
 [20.6,'h',428,-14,-85,-65,-50,-.3,0,12],
 // desperate counter, sword flies out low
 [22.4,'h',440,-18,-90,-70,-55,-.2,0,14],
 [23.3,'o',460,-30,-95,-80,-60,-.4,.05,14],
 // collapse
 [27.5,'h',540,-40,-95,-80,-60,0,1,0]
];
const KG=[
 [0,'h',900,0,-40,45,70,0,0,0],[5,'h',900,0,-40,45,70,0,0,0],
 [6.8,'h',870,-3,-40,45,70,0,0,2],
 [8.3,'h',878,-8,75,100,125,0,0,3],[8.8,'s',830,2,-8,2,45,0,0,0],
 [9.9,'h',872,0,-30,50,80,0,0,0],
 [11.2,'h',878,-6,70,95,118,0,0,3],[11.7,'s',828,3,-12,-2,38,0,0,0],
 [13.0,'h',868,0,-35,45,80,0,0,0],
 [14.3,'h',868,-6,72,98,120,0,0,3],[14.7,'s',818,3,-10,5,40,0,0,0],
 [16.2,'h',820,0,-30,50,80,0,0,2],
 // overhead cleave
 [17.3,'h',790,-8,98,122,142,0,0,6],[17.95,'s',715,8,-20,-15,10,0,0,-2],
 [19.8,'h',705,2,-25,40,75,0,0,0],
 // finishing blow
 [22.3,'h',695,-4,88,118,142,0,0,6],[23.0,'s',620,10,-30,-45,-75,0,0,-2],
 [27,'h',612,6,-35,-50,-85,0,0,0],
 // king turns & lifts sword in triumph
 [29.5,'h',608,2,-20,10,30,0,0,0]
];
/* camera: [time, ease, zoom, cx, cy] */
const CAM=[
 [0,'h',2.3,430,520],[5,'z',1.0,660,470],
 [6.8,'h',1.06,655,462],[8.8,'h',1.22,575,448],
 [9.9,'h',1.04,665,462],[11.7,'h',1.22,575,448],
 [13.0,'h',1.04,662,465],[14.7,'h',1.28,575,445],
 [16.8,'h',1.04,665,462],
 [18.0,'o',1.2,540,500],[20.0,'h',1.16,545,450],
 [22.2,'h',1.1,600,420],[23.3,'o',1.18,480,520],
 [26,'h',1.08,380,590],[29,'z',0.98,420,570],[32,'h',1.0,400,560]
];
/* impacts: [time, x, y, sparks, shake, flashColor, flashOpacity, kind] */
const IM=[
 [8.8,650,430,30,.7,'#fff',.15,'steel'],
 [11.7,650,430,30,.75,'#fff',.15,'steel'],
 [14.7,650,425,34,.9,'#fff',.18,'steel'],
 [17.95,700,440,46,2.0,'#d01010',.34,'cleave'],
 [23.15,610,590,0,1.8,'#7a0000',.4,'kill']
];

/* ===================================================================
   RIG
   =================================================================== */
const P=(o,a,l)=>[o[0]+Math.cos(a*D)*l,o[1]-Math.sin(a*D)*l];
function limb(p,c,w){
  const g=mk(p,'g',{'stroke-linecap':'round','stroke-linejoin':'round',fill:'none'});
  const a=mk(g,'path',{stroke:c[0],'stroke-width':w}),b=mk(g,'path',{stroke:c[1],'stroke-width':w*.62}),h=mk(g,'path',{stroke:c[2],'stroke-width':w*.18,opacity:.8,transform:`translate(${-w*.2} ${-w*.22})`});
  return d=>{a.setAttribute('d',d);b.setAttribute('d',d);h.setAttribute('d',d)}
}
function fighter(par,o){
  const sh=mk(par,'ellipse',{cy:714,ry:13,fill:'#000',opacity:.6,filter:'url(#b4)'});
  const root=mk(par,'g');
  const cape=mk(root,'path',{fill:`url(#${o.cape}) ${o.cape==='cloakK'?'#1a1f26':'#3a0a0e'}`,stroke:'#000','stroke-width':1.5});
  const legs=[limb(root,o.c,30),limb(root,o.c,30)];
  const up=mk(root,'g');
  const torso=mk(up,'path',{fill:`url(#${o.g}) ${o.g==='kS'?'#5d6877':'#2b2427'}`,stroke:o.trim,'stroke-width':2.5});
  mk(up,'path',{d:'M-24,-186H24',stroke:o.trim,'stroke-width':6});
  // tabard / surcoat detail
  if(o.king){mk(up,'path',{d:'M-14,-300L0,-240L14,-300',fill:'none',stroke:'#7a0d0d','stroke-width':3,opacity:.8});}
  else{mk(up,'path',{d:'M0,-300V-170M-22,-262H22',stroke:'#7a1313','stroke-width':5,opacity:.55});}
  const pa=[-1,1].map(()=>mk(up,'ellipse',{rx:22,ry:16,fill:`url(#${o.g}) ${o.g==='kS'?'#5d6877':'#2b2427'}`,stroke:o.trim,'stroke-width':2.5}));
  if(o.king){pa.forEach((e,i)=>{ /* spikes */ });}
  const hd=mk(up,'g');
  mk(hd,'path',{d:'M-23,-322L-24,-362Q-24,-386 0,-386Q24,-386 24,-362L23,-322Q0,-312-23,-322Z',fill:`url(#${o.g}) ${o.g==='kS'?'#5d6877':'#2b2427'}`,stroke:o.trim,'stroke-width':2.5});
  mk(hd,'path',{d:'M0,-386V-322M-23,-345H23',stroke:o.trim,'stroke-width':1.6,opacity:.7});
  mk(hd,'rect',{x:-18,y:-360,width:36,height:7,fill:'#030303'});
  const eyes=[-8,8].map(x=>mk(hd,'circle',{cx:x,cy:-357,r:2.1,fill:o.eye,filter:o.king?'url(#glow)':''}));
  [-17,17].forEach(x=>[-372,-332].forEach(y=>mk(hd,'circle',{cx:x,cy:y,r:1.8,fill:o.trim})));
  // plume for knight
  if(!o.king){const pl=mk(hd,'path',{d:'M0,-386Q-24,-410 -52,-396Q-26,-396 -6,-380Z',fill:'#6a0d12',stroke:'#2a0407','stroke-width':1.2});o.plume=pl;}
  if(o.king){mk(hd,'path',{d:'M-22,-380L-30,-418L-12,-398L0,-428L12,-398L30,-418L22,-380Z',fill:'url(#gold) #b8923a',stroke:'#2a1d06','stroke-width':1.6});
             mk(hd,'circle',{cx:0,cy:-400,r:3.2,fill:'#b01616'});}
  let shG=null,splat=null;
  if(o.shield){
    shG=mk(up,'g');
    mk(shG,'path',{d:'M0,-60L32,-45L30,12Q22,50 0,72Q-22,50-30,12L-32,-45Z',fill:'url(#kS) #5d6877',stroke:'#07090c','stroke-width':3.5});
    mk(shG,'path',{d:'M-30,-10H30M0,-58V70',stroke:'#7a1616','stroke-width':6,opacity:.8});
    mk(shG,'path',{d:'M-20,-40L8,18M12,-48L26,-12',stroke:'#000','stroke-width':1.6,opacity:.5}); // scratches
    mk(shG,'circle',{r:9,fill:'url(#gold) #b8923a'});
    splat=mk(shG,'g',{'clip-path':'url(#shc)',opacity:0});
    const sb=mk(splat,'g',{filter:'url(#bd)'});
    [[-6,-12,30],[12,14,21],[-14,30,16],[16,-32,12],[2,52,15]].forEach(c=>mk(sb,'circle',{cx:c[0],cy:c[1],r:c[2],fill:'url(#blood) #6a0505'}));
    mk(sb,'path',{d:'M-6,-12V62M12,14V68',stroke:'#3d0000','stroke-width':5,opacity:.8});
  }
  const arm=limb(up,o.c,21),sw=mk(up,'g'),L=o.L;
  const bladeEls=[];
  bladeEls.push(mk(sw,'path',{d:`M0,-5L${L},-4L${L+20},0L${L},4L0,5Z`,fill:o.king?'url(#bladeDark) #3a3f46':'url(#blade) #9aa4ae'}));
  mk(sw,'path',{d:`M12,0H${L-10}`,stroke:'#fff',opacity:.45,'stroke-width':1.4});
  const bloodOnBlade=mk(sw,'path',{d:`M${L*.35},-3.5L${L+14},0L${L*.35},3.5Z`,fill:'#5a0707',opacity:0});
  mk(sw,'rect',{x:-4,y:-21,width:9,height:42,rx:2.5,fill:'url(#gold) #b8923a'});
  mk(sw,'rect',{x:-38,y:-4.5,width:35,height:9,fill:'#1a110a'});
  mk(sw,'circle',{cx:-40,r:6.5,fill:'url(#gold) #b8923a'});
  // wound / blood gush anchor
  return{splat,bloodOnBlade,eyes,root,up,
   upd(p,t){
    const[x,lean,a1,a2,a3,s,f,cr]=p, br=Math.sin(t*2.3+o.ph)*2.8, w=Math.sin(t*1.7+o.ph)*2.2;
    const dy=715+f*20+(cr||0);
    root.setAttribute('transform',`translate(${x} ${dy}) scale(${o.f} 1) rotate(${-f*88})`);
    sh.setAttribute('cx',x-(o.f>0?f*160:0));sh.setAttribute('rx',78+f*120);
    const st=Math.sin(x*.07)*10,kn=(cr||0)*.5;
    legs[0](`M0,${-165+br}L${18+st+kn},${-84+(cr||0)*.4}L${30+st*1.6},0`);
    legs[1](`M0,${-165+br}L${-15-st-kn},${-82+(cr||0)*.4}L${-34-st*1.6},0`);
    up.setAttribute('transform',`rotate(${lean} 0 -165)`);
    torso.setAttribute('d',`M-38,${-316+br}Q0,${-332+br} 38,${-316+br}L31,-254L24,-168L-24,-168L-31,-254Z`);
    pa.forEach((e,i)=>{e.setAttribute('cx',i?38:-38);e.setAttribute('cy',-314+br)});
    hd.setAttribute('transform',`translate(0 ${br*.6}) rotate(${-lean*.25} 0 -320)`);
    const S=[20,-306+br],Ee=P(S,a1,70),H=P(Ee,a2,66);
    arm(`M${S}L${Ee}L${H}`);
    sw.setAttribute('transform',`translate(${H}) rotate(${-(a3+w)})`);
    if(shG)shG.setAttribute('transform',`translate(${42+s*12} ${-232-s*40+br}) rotate(${s*8})`);
    let l='',r='';
    for(let i=0;i<=6;i++){
      const y=-316+i*o.cl/6, k=Math.sin(t*2.2+i*.8+o.ph)*i*o.wv-lean*(i*.5)-(Math.abs(p[0]-(o.px||0))>0?0:0);
      l+=`${i?'L':'M'}${-30-i*o.cw+k},${y}`; r=`L${26-i*o.cw*.4+k},${y}`+r;
    }
    cape.setAttribute('d',l+r+'Z');
    if(o.plume)o.plume.setAttribute('transform',`rotate(${Math.sin(t*3)*4+lean*.5} 0 -386)`);
   }};
}
const kn=fighter($('fK'),{c:['#1b1f25','#566170','#c4d0dc'],g:'kS',trim:'#8997a6',eye:'#cfe3ff',L:150,f:1,ph:0,shield:1,cape:'cloakK',cl:190,cw:5,wv:2.4});
const kg=fighter($('fG'),{c:['#070607','#2b2427','#8a7650'],g:'gS',trim:'#c4a043',eye:'#ff3a1a',L:190,f:-1,ph:2,king:1,cape:'cloak',cl:290,cw:9,wv:3.8});

/* ===================================================================
   WORLD: crowd (3 rows, hooded silhouettes w/ spears), stains
   =================================================================== */
let sd=7;const rnd=()=>(sd=(sd*16807)%2147483647)/2147483647;
const rows=[0,1,2].map(r=>{
  const g=mk($('cr'),'g');
  for(let x=-340;x<1960;x+=28+rnd()*10){
    const y=585+r*40+rnd()*10, c=`hsl(${20+rnd()*15} ${10+rnd()*10}% ${5+r*3+rnd()*5}%)`;
    mk(g,'ellipse',{cx:x,cy:y+30,rx:25,ry:32,fill:c});
    mk(g,'circle',{cx:x,cy:y,r:12+rnd()*2,fill:c});
    if(rnd()<.14)mk(g,'path',{d:`M${x+17} ${y+36}L${x+25} ${y-96}`,stroke:'#2a221a','stroke-width':3.5});
    if(rnd()<.05)mk(g,'path',{d:`M${x+25} ${y-96}l-6 -14l12 0z`,fill:'#2a221a'});
  }
  return g;
});

/* ===================================================================
   PARTICLES (pooled; zero DOM churn)
   =================================================================== */
const sp=[...Array(110)].map(()=>({e:mk($('fx'),'path',{stroke:'#ffd68a','stroke-width':2.4,'stroke-linecap':'round',opacity:0}),l:0}));
function spark(x,y,n){for(let k=0;k<n;k++){const q=sp.find(s=>s.l<=0);if(!q)return;const a=Math.random()*6.28,v=100+Math.random()*540;Object.assign(q,{x,y,vx:Math.cos(a)*v,vy:Math.sin(a)*v-140,l:.5+Math.random()*.7})}}
// blood droplets
const bl=[...Array(160)].map(()=>({e:mk($('gore'),'ellipse',{rx:3,ry:3,fill:'#6e0808',opacity:0}),l:0}));
function bloodBurst(x,y,n,dirx,power){for(let k=0;k<n;k++){const q=bl.find(s=>s.l<=0);if(!q)return;const a=(Math.random()*1.7-.85)+(dirx>0?-.35:Math.PI+.35),v=(120+Math.random()*520)*power;
  const r=1.8+Math.random()*5.5;Object.assign(q,{x,y,vx:Math.cos(a)*v,vy:Math.sin(a)*v-200*power,l:.9+Math.random()*1.0,r,floor:690+Math.random()*100});q.e.setAttribute('rx',r);q.e.setAttribute('ry',r)}}
// embers
const em=[...Array(46)].map(()=>{const r=1+rnd()*3;return{e:mk($('embers'),'circle',{r,fill:rnd()>.35?'#ff9a2a':'#ff4a10',opacity:0}),x:rnd()*1600,y:rnd()*900,vx:-10-rnd()*30,vy:-22-rnd()*46,ph:rnd()*6,a:.3+rnd()*.6}});
// persistent floor stains
const stains=$('stains');
function stain(x,y,r){mk(stains,'ellipse',{cx:x,cy:y,rx:r,ry:r*.22,fill:'#3a0404',opacity:.85})}

/* ===================================================================
   FLAME / BANNER PATHS
   =================================================================== */
const flame=(n,t)=>{const a=Math.sin(t*14+n)*3.5,b=Math.sin(t*9+n*2)*5;return`M-12,0Q${-17+a},-30 ${b},${-66+a}Q${17+a},-27 12,0Z`};
const banner=(x,t)=>{const s=Math.sin(t*1.5+x)*8;return`M${x-34},80L${x+34},80L${x+34+s},320L${x+s*.5},350L${x-34+s},320Z`};

/* ===================================================================
   AUDIO (procedural; no assets)
   =================================================================== */
let AC=null,master=null,sndOn=false,droneNodes=null;
function audioInit(){
  if(AC)return;
  try{AC=new (window.AudioContext||window.webkitAudioContext)();master=AC.createGain();master.gain.value=.0;master.connect(AC.destination);
      // short reverb via convolver of decaying noise
      const len=AC.sampleRate*1.8,ir=AC.createBuffer(2,len,AC.sampleRate);
      for(let c=0;c<2;c++){const d=ir.getChannelData(c);for(let i=0;i<len;i++)d[i]=(Math.random()*2-1)*Math.pow(1-i/len,2.6)}
      const cv=AC.createConvolver();cv.buffer=ir;const wet=AC.createGain();wet.gain.value=.35;cv.connect(wet);wet.connect(master);
      AC._rev=cv;
  }catch(e){AC=null}
}
function setSound(on){sndOn=on;$('bSnd').textContent='Sound: '+(on?'On':'Off');
  if(on){audioInit();if(AC){AC.resume();master.gain.setTargetAtTime(.9,AC.currentTime,.05);startDrone()}}
  else if(AC){master.gain.setTargetAtTime(0,AC.currentTime,.05);stopDrone()}}
function out(n,wet=.5){n.connect(master);if(AC._rev){const g=AC.createGain();g.gain.value=wet;n.connect(g);g.connect(AC._rev)}}
function noiseBuf(sec){const b=AC.createBuffer(1,AC.sampleRate*sec,AC.sampleRate),d=b.getChannelData(0);for(let i=0;i<d.length;i++)d[i]=Math.random()*2-1;return b}
function startDrone(){
  if(droneNodes||!AC)return;
  const g=AC.createGain();g.gain.value=.0001;g.gain.exponentialRampToValueAtTime(.09,AC.currentTime+3);
  const o1=AC.createOscillator(),o2=AC.createOscillator(),f=AC.createBiquadFilter();
  o1.type='sawtooth';o1.frequency.value=48;o2.type='sawtooth';o2.frequency.value=48.7;f.type='lowpass';f.frequency.value=180;
  const lfo=AC.createOscillator(),lg=AC.createGain();lfo.frequency.value=.12;lg.gain.value=60;lfo.connect(lg);lg.connect(f.frequency);
  o1.connect(f);o2.connect(f);f.connect(g);out(g,.2);o1.start();o2.start();lfo.start();droneNodes={g,o1,o2,lfo};
}
function stopDrone(){if(!droneNodes)return;const n=droneNodes;droneNodes=null;n.g.gain.setTargetAtTime(.0001,AC.currentTime,.2);setTimeout(()=>{try{n.o1.stop();n.o2.stop();n.lfo.stop()}catch(e){}},900)}
function sfxClang(i=1){
  if(!sndOn||!AC)return;const now=AC.currentTime;
  [1180,1790,2410,3120,4180].forEach((f,idx)=>{const o=AC.createOscillator(),g=AC.createGain();o.type='sine';o.frequency.value=f*(.94+Math.random()*.12);
    const d=.25+idx*.18;g.gain.setValueAtTime(.2*i,now);g.gain.exponentialRampToValueAtTime(.0001,now+d);o.connect(g);out(g,.6);o.start(now);o.stop(now+d)});
  const n=AC.createBufferSource();n.buffer=noiseBuf(.12);const bp=AC.createBiquadFilter();bp.type='bandpass';bp.frequency.value=2600;bp.Q.value=2.5;
  const g=AC.createGain();g.gain.setValueAtTime(.55*i,now);g.gain.exponentialRampToValueAtTime(.001,now+.11);n.connect(bp);bp.connect(g);out(g,.4);n.start(now);
}
function sfxThud(i=1){
  if(!sndOn||!AC)return;const now=AC.currentTime,o=AC.createOscillator(),g=AC.createGain();
  o.type='triangle';o.frequency.setValueAtTime(150,now);o.frequency.exponentialRampToValueAtTime(28,now+.6);
  g.gain.setValueAtTime(.95*i,now);g.gain.exponentialRampToValueAtTime(.001,now+.7);o.connect(g);out(g,.5);o.start(now);o.stop(now+.75);
}
function sfxSlash(i=1){ // wet cleave
  if(!sndOn||!AC)return;const now=AC.currentTime,n=AC.createBufferSource();n.buffer=noiseBuf(.5);
  const lp=AC.createBiquadFilter();lp.type='lowpass';lp.frequency.setValueAtTime(3500,now);lp.frequency.exponentialRampToValueAtTime(260,now+.4);
  const g=AC.createGain();g.gain.setValueAtTime(.7*i,now);g.gain.exponentialRampToValueAtTime(.001,now+.45);n.connect(lp);lp.connect(g);out(g,.35);n.start(now);
  sfxThud(.8);
}
function sfxWhoosh(){
  if(!sndOn||!AC)return;const now=AC.currentTime,n=AC.createBufferSource();n.buffer=noiseBuf(.6);
  const bp=AC.createBiquadFilter();bp.type='bandpass';bp.Q.value=1.1;bp.frequency.setValueAtTime(400,now);bp.frequency.exponentialRampToValueAtTime(2200,now+.3);bp.frequency.exponentialRampToValueAtTime(500,now+.55);
  const g=AC.createGain();g.gain.setValueAtTime(.0001,now);g.gain.exponentialRampToValueAtTime(.3,now+.25);g.gain.exponentialRampToValueAtTime(.0001,now+.58);n.connect(bp);bp.connect(g);out(g,.3);n.start(now);
}
function sfxHeartbeat(){
  if(!sndOn||!AC)return;const now=AC.currentTime;
  [0,.22].forEach((dl,k)=>{const o=AC.createOscillator(),g=AC.createGain();o.type='sine';o.frequency.setValueAtTime(64,now+dl);o.frequency.exponentialRampToValueAtTime(34,now+dl+.2);
    g.gain.setValueAtTime(.0001,now+dl);g.gain.exponentialRampToValueAtTime(k?.5:.75,now+dl+.02);g.gain.exponentialRampToValueAtTime(.0001,now+dl+.24);o.connect(g);out(g,.2);o.start(now+dl);o.stop(now+dl+.3)});
}
function sfxBell(){
  if(!sndOn||!AC)return;const now=AC.currentTime;
  [98,147,196.6,294.5,392].forEach((f,i)=>{const o=AC.createOscillator(),g=AC.createGain();o.type='sine';o.frequency.value=f;
    g.gain.setValueAtTime(.0001,now);g.gain.exponentialRampToValueAtTime(.2/(i+1),now+.03);g.gain.exponentialRampToValueAtTime(.0001,now+6);o.connect(g);out(g,.8);o.start(now);o.stop(now+6.2)});
}

/* ===================================================================
   STATE / TIMELINE
   =================================================================== */
const CHAPTERS=[[0,'I · The Challenge'],[5,'II · The Clash'],[16.5,'III · Brutality'],[22.2,'IV · The Verdict']];
// one-shot cues (time, fn) — fired in order, re-armed on seek/restart
const CUES=[
  [0.4,()=>{sfxHeartbeat()}],[2.2,()=>{sfxHeartbeat()}],[4.2,()=>{sfxHeartbeat()}],
  [8.15,sfxWhoosh],[11.05,sfxWhoosh],[14.15,sfxWhoosh],[17.1,sfxWhoosh],[22.15,sfxWhoosh],
  [8.8,()=>sfxClang(1)],[11.7,()=>sfxClang(1)],[14.7,()=>sfxClang(1.15)],
  [17.95,()=>{sfxSlash(1)}],[18.3,()=>sfxClang(.4)],
  [23.15,()=>{sfxSlash(1.2)}],[23.5,()=>sfxThud(.9)],
  [24.6,()=>sfxHeartbeat()],[26.5,()=>sfxHeartbeat()],[28.5,sfxBell]
];
const st={t:0,playing:false,started:false,ii:0,ci:0,fT:-9,fC:'#fff',fO:0,lastChap:-1};
let sceneNow=0;

function resetFx(){
  st.ii=0;st.ci=0;st.fT=-9;
  sp.forEach(s=>{s.l=0;s.e.setAttribute('opacity',0)});
  bl.forEach(s=>{s.l=0;s.e.setAttribute('opacity',0)});
  stains.innerHTML='';stainDone.clear();
}
const stainDone=new Set();

const LAYERS=[['L_bg',.4],['L_bgfx',.4],['L_cl',.62],['L_mist',.62],['L_gnd',1],['L_main',1],['L_fg',1.5],['L_em',1.25]];
let SW=1600,SH=900;
function fit(){const r=$('stage').getBoundingClientRect();SW=r.width||1600;SH=r.height||900}
addEventListener('resize',fit);
// Camera -> CSS transform (compositor-only; no re-raster of cached layers).
function lay(el,f,c,sx,sy,rot){
  // Layer element is SW x SH px, mapping 1600x900 world units via k = SW/1600 (SH/900 is identical, 16:9).
  // Screen point = center + shake + R*S*(p - focus), all in px. Layer px (u,v) = world(u/k, v/k).
  const k=SW/1600;
  const s=1+(c[0]-1)*f, fx=(800+(c[1]-800)*f)*k, fy=(450+(c[2]-450)*f)*k;
  const a=rot||0, ca=Math.cos(a)*s, sa=Math.sin(a)*s;
  const cx=(800+sx)*k, cy=(450+sy)*k;               // screen centre (+ shake), px
  const e=cx-(ca*fx-sa*fy), g=cy-(sa*fx+ca*fy);
  el.style.transform=`matrix(${ca.toFixed(5)},${sa.toFixed(5)},${(-sa).toFixed(5)},${ca.toFixed(5)},${e.toFixed(2)},${g.toFixed(2)})`;
}
/* ---- grain: pre-rendered noise frames on a tiny canvas (cheap, not an SVG filter) ---- */
const gc=$('grain'),gx=gc.getContext('2d'),GF=[];
(function(){const w=gc.width,h=gc.height;for(let k=0;k<6;k++){const im=gx.createImageData(w,h),d=im.data;for(let i=0;i<d.length;i+=4){const v=Math.random()<.5?0:255;d[i]=d[i+1]=d[i+2]=v;d[i+3]=(Math.random()*34)|0}GF.push(im)}})();
let gfi=0;

/* ---- fps meter ---- */
let fpsOn=false,fpsAcc=0,fpsN=0,fpsLast=performance.now();


/* ===================================================================
   BAKE static layers once -> bitmap canvases. The expensive filters
   (turbulence, lighting, big blurs) are paid ONE time at load, then each
   frame only transforms a cached bitmap on the GPU compositor.
   =================================================================== */
const BAKE_SCALE=1.0;                       // 1 canvas px per world unit (crisp at 1x, soft-looking by design for DoF layers)
function bakeLayer(id,live){
  return new Promise(res=>{
    const svg=$(id); if(!svg){res();return}
    const defs=(svg.querySelector(':scope > defs.local')||{outerHTML:window.__DEFS_HTML||''}).outerHTML;
    // clone the layer, drop in defs so the standalone image resolves gradients/filters
    const clone=svg.cloneNode(true);
    clone.setAttribute('width',1600);clone.setAttribute('height',900);
    clone.removeAttribute('class');clone.removeAttribute('style');
    if(!clone.querySelector(':scope > defs.local'))clone.insertAdjacentHTML('afterbegin',defs);
    // static layers have no live children we need to keep animating (those are split out below)
    const xml=new XMLSerializer().serializeToString(clone);
    const img=new Image();
    img.onload=()=>{
      const cv=document.createElement('canvas');cv.width=1600*BAKE_SCALE;cv.height=900*BAKE_SCALE;
      cv.className='layer';cv.id=id+'_baked';
      cv.getContext('2d').drawImage(img,0,0,cv.width,cv.height);
      svg.parentNode.insertBefore(cv,svg);svg.style.display='none';
      res(cv);
    };
    img.onerror=()=>res();
    img.src='data:image/svg+xml;charset=utf-8,'+encodeURIComponent(xml);
  });
}

/* ===================================================================
   RENDER(t) — pure function of time (so scrubbing works)
   =================================================================== */
let prevT=0;
function render(t,dt){
  // fire impacts / cues
  if(t<prevT-0.001){resetFx();// seek backwards: re-arm
    while(st.ii<IM.length&&IM[st.ii][0]<t)st.ii++;while(st.ci<CUES.length&&CUES[st.ci][0]<t)st.ci++;}
  while(!GM.on&&st.ii<IM.length&&t>=IM[st.ii][0]){
    const m=IM[st.ii++];
    if(t-m[0]<.3){
      st.fT=m[0];st.fC=m[5];st.fO=m[6];
      if(m[3])spark(m[1],m[2],m[3]);
      const c=$('fc');c.setAttribute('cx',m[1]);c.setAttribute('cy',m[2]);
      if(m[7]==='cleave'){bloodBurst(m[1]-10,m[2]-10,90,-1,1.25);stainAt(m[1]-120,720,60)}
      if(m[7]==='kill'){bloodBurst(m[1]-30,m[2]-60,120,-1,1.4);bloodBurst(m[1]-30,m[2]-60,50,1,.8);stainAt(m[1]-60,725,90)}
    }
  }
  while(!GM.on&&st.ci<CUES.length&&t>=CUES[st.ci][0]){const c=CUES[st.ci++];if(t-c[0]<.3&&st.playing)c[1]()}
  prevT=t;

  // camera shake (damped, trauma-based)
  let sx=0,sy=0,sr=0;
  for(const m of (GM.on?[]:IM))if(t>m[0]){const a=m[4]*20*Math.exp(-(t-m[0])*6.5);sx+=Math.sin(t*83+m[0])*a;sy+=Math.cos(t*71+m[0])*a;sr+=Math.sin(t*61+m[0])*a*.012}
  // handheld micro-drift
  sx+=Math.sin(t*1.3)*1.6;sy+=Math.cos(t*1.7)*1.3;sr+=Math.sin(t*.9)*.05;
  // slow-mo hit-stop feel: tiny punch zoom on impacts
  let punch=0;for(const m of (GM.on?[]:IM))if(t>m[0])punch+=(m[4]*.05)*Math.exp(-(t-m[0])*9);
  let c=samp(CAM,t);c[0]+=punch;
  if(GM.on){const a=GM.shake*14;sx+=Math.sin(t*83)*a;sy+=Math.cos(t*71)*a;sr+=Math.sin(t*61)*a*.01;c=[1.08+GM.shake*.012,640,462]}
  for(const [id,f] of LAYERS){const el=$(id+'_baked')||$(id);if(el)lay(el,f,c,sx,sy,sr)}

  // fighters
  if(GM.on&&KN2&&KG2){KN2.upd(KP.cur,t);KG2.upd(GP.cur,t);GM._pk=KP.cur}else{const pk0=samp(KN,t),pg0=samp(KG,t);kn.upd(pk0,t);kg.upd(pg0,t);GM._pk=pk0}
  const pk=GM._pk;

  // gore state
  (GM.on&&KN2?KN2:kn).splat.setAttribute('opacity',GM.on?Math.min(.95,Math.max(0,(1-GM.hp/GM.maxhp-.3)*1.4)):sm(17.95,19.8,t)*.95);
  (GM.on&&KG2?KG2:kg).bloodOnBlade.setAttribute('opacity',GM.on?Math.min(.9,(1-GM.hp/GM.maxhp)*1.2):sm(18.0,18.6,t)*.9);
  // knight plume droops / hurt tint; king's eyes pulse
  const pulse=.7+.3*Math.sin(t*6);kg.eyes.forEach(e=>e.setAttribute('opacity',pulse));
  // bleeding: continuous drip from the wound after the cleave
  if(!GM.on&&st.playing&&t>18.4&&t<26.5&&Math.random()<dt*14)bloodBurst(pk[0]+(pk[6]>.1?-150*pk[6]:0)+10,630+pk[6]*60,1,-1,.18);
  // pool
  const pp=GM.on?(GM.over&&!GM.won?clamp((performance.now()-(GM.endAt||0))/4000):0):sm(23.3,31,t),pl=$('pl'),pl2=$('pl2'),px=pk[0]-170*pk[6];
  pl.setAttribute('cx',px);pl.setAttribute('rx',1+pp*300);pl.setAttribute('ry',1+pp*40);pl.setAttribute('opacity',pp>0?1:0);
  pl2.setAttribute('cx',px+40);pl2.setAttribute('rx',1+pp*140);pl2.setAttribute('ry',1+pp*14);pl2.setAttribute('opacity',pp>0?.9:0);
  // dust kick when knight lands
  $('dust').setAttribute('cx',px+20);$('dust').setAttribute('opacity',GM.on?0:Math.max(0,1-Math.abs(t-24.4)/1.0)*.5);

  // crowd sway + mist + banners + torches (all cheap attribute writes)
    $('ms').setAttribute('x',-500+Math.sin(t*.25)*130);
  const fk=.86+.14*Math.sin(t*17)*Math.sin(t*5.3+1)+.03*Math.sin(t*41);
  $('lt1').setAttribute('opacity',fk);$('lt2').setAttribute('opacity',.86+.14*Math.sin(t*15+2)*Math.sin(t*4.1));
  $('tgl').setAttribute('opacity',fk);$('tgr').setAttribute('opacity',1.72-fk);
  $('fl1').setAttribute('d',flame(0,t));$('fl2').setAttribute('d',flame(3,t));
  $('bn1').setAttribute('d',banner(330,t));$('bn2').setAttribute('d',banner(1270,t));

  // particles
  const g=900;
  for(const s of sp){if(s.l<=0){if(s.on){s.e.setAttribute('opacity',0);s.on=0}continue}
    s.vy+=g*dt;s.x+=s.vx*dt;s.y+=s.vy*dt;s.l-=dt;s.on=1;
    s.e.setAttribute('d',`M${s.x.toFixed(1)} ${s.y.toFixed(1)}L${(s.x-s.vx*.04).toFixed(1)} ${(s.y-s.vy*.04).toFixed(1)}`);
    s.e.setAttribute('opacity',Math.min(1,s.l*2.5).toFixed(2))}
  for(const s of bl){if(s.l<=0){if(s.on){s.e.setAttribute('opacity',0);s.on=0}continue}
    s.vy+=1500*dt;s.x+=s.vx*dt;s.y+=s.vy*dt;s.l-=dt;s.on=1;
    if(s.y>=s.floor){ // land -> becomes a floor splat
      s.l=0;s.on=0;s.e.setAttribute('opacity',0);
      if(stains.childNodes.length<120)mk(stains,'ellipse',{cx:s.x.toFixed(0),cy:s.y.toFixed(0),rx:(s.r*1.9).toFixed(1),ry:(s.r*.6).toFixed(1),fill:'#4a0505',opacity:.8});
      continue}
    s.e.setAttribute('cx',s.x.toFixed(1));s.e.setAttribute('cy',s.y.toFixed(1));s.e.setAttribute('opacity',Math.min(1,s.l*3).toFixed(2))}
  if(GM.on)stepWeather(t,dt);else for(const e of em){e.x+=e.vx*dt;e.y+=e.vy*dt;if(e.y<-20){e.y=920;e.x=Math.random()*1600}if(e.x<-20)e.x=1620;
    e.e.setAttribute('cx',(e.x+Math.sin(t*2+e.ph)*14).toFixed(1));e.e.setAttribute('cy',e.y.toFixed(1));e.e.setAttribute('opacity',(e.a*(.6+.4*Math.sin(t*5+e.ph))).toFixed(2))}

  // flash / impact glow
  const fa=Math.exp(-(t-st.fT)*6.5);
  $('fc').setAttribute('opacity',t>=st.fT?Math.min(1,fa*1.3):0);
  $('fl').setAttribute('fill',st.fC);$('fl').setAttribute('opacity',t>=st.fT?st.fO*fa:0);
  // red "hurt" vignette after the cleave, deepening at the kill
  const hurt=GM.on?Math.max(0,(GM.hp/GM.maxhp<.35?(.35-GM.hp/GM.maxhp)*1.6:0)+(GM._flashHurt||0)):(sm(17.95,18.4,t)*(1-sm(20,22,t))*.55)+(sm(23.15,23.6,t)*.7*(1-sm(28,31,t)));
  $('hurt').setAttribute('opacity',hurt.toFixed(3));
  // desaturate-ish dim as life drains
  // title cards & fades
  const fd=GM.on?0:1-sm(0,1.6,t)+sm(31.8,33.6,t);
  $('fd').setAttribute('opacity',clamp(fd).toFixed(3));
  $('t3').setAttribute('opacity',GM.on?0:(sm(.8,1.6,t)*(1-sm(3.2,4.2,t))).toFixed(3));
  $('t1').setAttribute('opacity',GM.on?0:(sm(28.6,29.6,t)*(1-sm(31.4,32.2,t))).toFixed(3));
  $('t2').setAttribute('opacity',GM.on?0:(sm(29.2,30.2,t)*(1-sm(31.4,32.2,t))*.9).toFixed(3));

  // chapter label
  let ch=0;for(let i=0;i<CHAPTERS.length;i++)if(t>=CHAPTERS[i][0])ch=i;
  if(ch!==st.lastChap){st.lastChap=ch;const el=$('chap');el.classList.remove('on');void el.offsetWidth;el.textContent=CHAPTERS[ch][1];el.classList.add('on');}

  // HUD
  const pct=t/DUR*100;$('fill').style.width=pct+'%';$('knob').style.left=pct+'%';
  const f=n=>`${Math.floor(n/60)}:${String(Math.floor(n%60)).padStart(2,'0')}`;
  $('time').textContent=`${f(t)} / ${f(DUR)}`;
}
function stainAt(x,y,r){stain(x,y,r)}