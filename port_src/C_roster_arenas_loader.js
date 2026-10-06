const gnow=()=>AC?AC.currentTime:performance.now()/1000;
function drum(time,kind){
  if(!sndOn||!AC)return;
  if(kind==='kick'){const o=AC.createOscillator(),g=AC.createGain();o.type='sine';o.frequency.setValueAtTime(110,time);o.frequency.exponentialRampToValueAtTime(38,time+.22);
    g.gain.setValueAtTime(.0001,time);g.gain.exponentialRampToValueAtTime(.9,time+.008);g.gain.exponentialRampToValueAtTime(.0001,time+.34);o.connect(g);out(g,.35);o.start(time);o.stop(time+.38)}
  else if(kind==='tom'){const o=AC.createOscillator(),g=AC.createGain();o.type='triangle';o.frequency.setValueAtTime(190,time);o.frequency.exponentialRampToValueAtTime(90,time+.18);
    g.gain.setValueAtTime(.0001,time);g.gain.exponentialRampToValueAtTime(.45,time+.008);g.gain.exponentialRampToValueAtTime(.0001,time+.26);o.connect(g);out(g,.4);o.start(time);o.stop(time+.3)}
  else if(kind==='tick'){const n=AC.createBufferSource();n.buffer=noiseBuf(.05);const hp=AC.createBiquadFilter();hp.type='highpass';hp.frequency.value=5200;
    const g=AC.createGain();g.gain.setValueAtTime(.12,time);g.gain.exponentialRampToValueAtTime(.0001,time+.04);n.connect(hp);hp.connect(g);out(g,.1);n.start(time)}
}

/* ===================================================================
   CHARACTER BUILDER v2  -  fighter2(parent, look) -> same interface as fighter()
   look: {colors:[dark,mid,light], trim, eye, helm, cape, weapon, size, shield, glow, f(facing), ph, plumeCol, crownless}
   pose array unchanged: [x, lean, a1, a2, a3, shield, fall, crouch]
   =================================================================== */
const GRAD_CACHE={};
function ensureGrad(id,c0,c1,c2,c3){
  if(GRAD_CACHE[id])return;GRAD_CACHE[id]=1;
  const mkG=()=>{const lg=document.createElementNS(NS,'linearGradient');lg.setAttribute('id',id);lg.setAttribute('x1','0');lg.setAttribute('y1','0');lg.setAttribute('x2','1');lg.setAttribute('y2','1');
    [[0,c0],[.22,c1],[.55,c2],[1,c3]].forEach(([o,c])=>{const s=document.createElementNS(NS,'stop');s.setAttribute('offset',o);s.setAttribute('stop-color',c);s.setAttribute('stop-opacity','1');lg.appendChild(s)});return lg};
  // every drawing layer gets its own copy (iOS Safari will not resolve url(#id) into a different, zero-size <svg>)
  document.querySelectorAll('svg.layer').forEach(sv=>{let d=sv.querySelector(':scope > defs.local');if(!d){d=document.createElementNS(NS,'defs');d.setAttribute('class','local');sv.insertBefore(d,sv.firstChild)}d.appendChild(mkG())});
  
}
function shade(hex,k){ // lighten(+)/darken(-) a #rrggbb
  const n=parseInt(hex.slice(1),16);let r=n>>16,g=(n>>8)&255,b=n&255;
  const f=k<0?0:255,p=Math.abs(k);
  r=Math.round((f-r)*p+r);g=Math.round((f-g)*p+g);b=Math.round((f-b)*p+b);
  return'#'+((1<<24)+(r<<16)+(g<<8)+b).toString(16).slice(1);
}

function fighter2(par,o){
  par.innerHTML='';
  const C=o.colors,gid='cg_'+(o.id||Math.random().toString(36).slice(2,7));
  ensureGrad(gid,shade(C[2],.1),C[1],C[0],shade(C[1],-.2));
  const sz=o.size||1, W=o.weapon||'longsword';
  const sh=mk(par,'ellipse',{cy:714,ry:13,fill:'#000',opacity:.6,filter:'url(#b4)'});
  const root=mk(par,'g');
  // glow aura (cheap radial, drawn once)
  if(o.glow){const gg=mk(root,'ellipse',{cx:0,cy:-230,rx:140,ry:220,fill:o.glow,opacity:.12,filter:'url(#b9)'})}
  const capeFill=o.cape==='none'?'none':(o.cape==='rags'?'#1a1512':`url(#${o.cape==='cloakK'?'cloakK':'cloak'}) ${o.cape==='cloakK'?'#1a1f26':'#3a0a0e'}`);
  const cape=mk(root,'path',{fill:capeFill,stroke:o.cape==='none'?'none':'#000','stroke-width':1.5});
  const body=mk(root,'g',{transform:`scale(${sz})`});
  const legs=[limb(body,C,30),limb(body,C,30)];
  const up=mk(body,'g');
  const torso=mk(up,'path',{fill:`url(#${gid}) ${C[1]}`,stroke:o.trim,'stroke-width':2.5});
  mk(up,'path',{d:'M-24,-186H24',stroke:o.trim,'stroke-width':6});
  // chest emblem
  if(o.emblem==='cross')mk(up,'path',{d:'M0,-300V-170M-22,-262H22',stroke:o.emblemCol||'#7a1313','stroke-width':5,opacity:.6});
  else if(o.emblem==='crown')mk(up,'path',{d:'M-14,-300L0,-240L14,-300',fill:'none',stroke:'#7a0d0d','stroke-width':3,opacity:.8});