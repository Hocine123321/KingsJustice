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
  else if(o.emblem==='skull'){mk(up,'circle',{cx:0,cy:-262,r:11,fill:'#d6cdb8',opacity:.75});mk(up,'rect',{x:-6,y:-256,width:12,height:9,fill:'#d6cdb8',opacity:.75});[-4,4].forEach(x=>mk(up,'circle',{cx:x,cy:-264,r:2.6,fill:'#000'}))}
  else if(o.emblem==='chains'){mk(up,'path',{d:'M-30,-300L30,-190M30,-300L-30,-190',stroke:'#9aa3ad','stroke-width':3,'stroke-dasharray':'6 4',opacity:.75})}
  else mk(up,'path',{d:'M-28,-282H28',stroke:o.trim,'stroke-width':3,opacity:.4});
  // pauldrons
  const pa=[-1,1].map(()=>mk(up,'ellipse',{rx:22*(o.bigShoulders?1.25:1),ry:16,fill:`url(#${gid}) ${C[1]}`,stroke:o.trim,'stroke-width':2.5}));
  const spikes=[];
  if(o.spiked){[-1,1].forEach(sx=>{spikes.push(mk(up,'path',{d:'M0,0L-5,-26L5,-26Z',fill:o.trim,stroke:'#000','stroke-width':1}))})}
  // head
  const hd=mk(up,'g');const H=o.helm||'greathelm';
  const eyes=[];
  const skin='#b79c86';
  if(H==='greathelm'||H==='horned'||H==='crown'||H==='skull'&&false){
    mk(hd,'path',{d:'M-23,-322L-24,-362Q-24,-386 0,-386Q24,-386 24,-362L23,-322Q0,-312-23,-322Z',fill:`url(#${gid}) ${C[1]}`,stroke:o.trim,'stroke-width':2.5});
    mk(hd,'path',{d:'M0,-386V-322M-23,-345H23',stroke:o.trim,'stroke-width':1.6,opacity:.7});
    mk(hd,'rect',{x:-18,y:-360,width:36,height:7,fill:'#030303'});
    [-8,8].forEach(x=>eyes.push(mk(hd,'circle',{cx:x,cy:-357,r:2.1,fill:o.eye,filter:o.glow?'url(#glow)':''})));
    [-17,17].forEach(x=>[-372,-332].forEach(y=>mk(hd,'circle',{cx:x,cy:y,r:1.8,fill:o.trim})));
    if(H==='horned'){[-1,1].forEach(sx=>mk(hd,'path',{d:`M${sx*20},-376Q${sx*52},-382 ${sx*50},-424Q${sx*38},-396 ${sx*14},-388Z`,fill:'#d6cdb8',stroke:'#2a2118','stroke-width':1.6}))}
    if(H==='crown'){mk(hd,'path',{d:'M-22,-380L-30,-418L-12,-398L0,-428L12,-398L30,-418L22,-380Z',fill:'url(#gold) #b8923a',stroke:'#2a1d06','stroke-width':1.6});mk(hd,'circle',{cx:0,cy:-400,r:3.2,fill:'#b01616'})}
    if(H==='greathelm'&&o.plumeCol){o.plume=mk(hd,'path',{d:'M0,-386Q-24,-410 -52,-396Q-26,-396 -6,-380Z',fill:o.plumeCol,stroke:'#2a0407','stroke-width':1.2})}
  }else if(H==='hood'||H==='cowl'){
    mk(hd,'path',{d:'M-27,-318L-30,-366Q-30,-396 0,-398Q30,-396 30,-366L27,-318Q0,-306-27,-318Z',fill:H==='cowl'?'#1a1114':`url(#${gid})`,stroke:'#000','stroke-width':2});
    mk(hd,'ellipse',{cx:0,cy:-350,rx:15,ry:20,fill:'#050304'});
    [-6,6].forEach(x=>eyes.push(mk(hd,'circle',{cx:x,cy:-352,r:2.4,fill:o.eye,filter:'url(#glow)'})));
    mk(hd,'path',{d:'M-27,-318Q0,-296 27,-318',fill:'none',stroke:o.trim,'stroke-width':1.5,opacity:.5});
  }else if(H==='skull'){
    mk(hd,'path',{d:'M-22,-322L-23,-358Q-23,-384 0,-384Q23,-384 23,-358L22,-322Q0,-312-22,-322Z',fill:'#cfc6b2',stroke:'#2a2118','stroke-width':2});
    [-9,9].forEach(x=>{mk(hd,'ellipse',{cx:x,cy:-356,rx:6.5,ry:8,fill:'#050304'});eyes.push(mk(hd,'circle',{cx:x,cy:-356,r:2.2,fill:o.eye,filter:'url(#glow)'}))});
    mk(hd,'path',{d:'M0,-348L-3,-340H3Z',fill:'#050304'});
    for(let i=-3;i<=3;i++)mk(hd,'path',{d:`M${i*5},-330V-322`,stroke:'#050304','stroke-width':1.4});
    mk(hd,'path',{d:'M-24,-382Q0,-408 24,-382',fill:'none',stroke:o.trim,'stroke-width':3});
  }else{ // bare head
    mk(hd,'path',{d:'M-20,-322L-21,-358Q-21,-380 0,-380Q21,-380 21,-358L20,-322Q0,-313-20,-322Z',fill:skin,stroke:'#2a1d14','stroke-width':1.6});
    mk(hd,'path',{d:'M-22,-360Q-20,-392 2,-388Q24,-386 22,-358Q14,-374-2,-372Q-16,-372-22,-360Z',fill:'#1a1210'});
    [-7,7].forEach(x=>eyes.push(mk(hd,'circle',{cx:x,cy:-354,r:1.9,fill:o.eye})));
    mk(hd,'path',{d:'M-8,-336Q0,-332 8,-336',stroke:'#4a1a14','stroke-width':1.6,fill:'none'});
    mk(hd,'path',{d:'M-14,-370L-9,-340',stroke:'#6a0d0d','stroke-width':1.6,opacity:.7});
  }
  // shield
  let shG=null,splat=null;
  if(o.shield){
    shG=mk(up,'g');
    const shp=o.shieldShape==='round'?'M-38,-30Q-38,-62 0,-62Q38,-62 38,-30Q38,30 0,50Q-38,30 -38,-30Z':'M0,-60L32,-45L30,12Q22,50 0,72Q-22,50-30,12L-32,-45Z';
    mk(shG,'path',{d:shp,fill:`url(#${gid}) ${C[1]}`,stroke:'#07090c','stroke-width':3.5});
    mk(shG,'path',{d:'M-30,-10H30M0,-58V70',stroke:o.emblemCol||'#7a1616','stroke-width':6,opacity:.8});
    mk(shG,'path',{d:'M-20,-40L8,18M12,-48L26,-12',stroke:'#000','stroke-width':1.6,opacity:.5});
    mk(shG,'circle',{r:9,fill:'url(#gold) #b8923a'});
    splat=mk(shG,'g',{opacity:0});
    const sb=mk(splat,'g',{filter:'url(#bd)'});
    [[-6,-12,30],[12,14,21],[-14,30,16],[16,-32,12]].forEach(c=>mk(sb,'circle',{cx:c[0],cy:c[1],r:c[2],fill:'url(#blood) #6a0505'}));
  }else{ splat=mk(up,'g',{opacity:0});
    const sb=mk(splat,'g',{filter:'url(#bd)'});[[-6,-250,26],[10,-215,18],[-12,-190,14]].forEach(c=>mk(sb,'circle',{cx:c[0],cy:c[1],r:c[2],fill:'url(#blood) #6a0505'}))}
  // arm + weapon
  const arm=limb(up,C,21),sw=mk(up,'g');
  const blades=weaponArt(sw,W,o);
  const bloodOnBlade=mk(sw,'path',{d:`M${blades.L*.35},-3.5L${blades.L+10},0L${blades.L*.35},3.5Z`,fill:'#5a0707',opacity:0});
  // off-hand weapon for twinblades
  let sw2=null,arm2=null;
  if(W==='twinblades'){arm2=limb(up,C,19);sw2=mk(up,'g');weaponArt(sw2,'longsword',Object.assign({},o,{}))}
  return{splat,bloodOnBlade,eyes,root,up,L:blades.L,
   upd(p,t){
    const[x,lean,a1,a2,a3,s,f,cr]=p, br=Math.sin(t*2.3+(o.ph||0))*2.8, w=Math.sin(t*1.7+(o.ph||0))*2.2;
    const dy=715+f*20+(cr||0)*sz;
    root.setAttribute('transform',`translate(${x} ${dy}) scale(${o.f} 1) rotate(${-f*88})`);
    sh.setAttribute('cx',x-(o.f>0?f*160:0));sh.setAttribute('rx',(78+f*120)*sz);
    const st=Math.sin(x*.07)*10,kn=(cr||0)*.5;
    legs[0](`M0,${-165+br}L${18+st+kn},${-84+(cr||0)*.4}L${30+st*1.6},0`);
    legs[1](`M0,${-165+br}L${-15-st-kn},${-82+(cr||0)*.4}L${-34-st*1.6},0`);
    up.setAttribute('transform',`rotate(${lean} 0 -165)`);
    torso.setAttribute('d',`M-38,${-316+br}Q0,${-332+br} 38,${-316+br}L31,-254L24,-168L-24,-168L-31,-254Z`);
    const pw=o.bigShoulders?46:38;
    pa.forEach((e,i)=>{e.setAttribute('cx',i?pw:-pw);e.setAttribute('cy',-314+br)});
    spikes.forEach((e,i)=>e.setAttribute('transform',`translate(${i?pw:-pw} ${-326+br}) rotate(${i?18:-18})`));
    hd.setAttribute('transform',`translate(0 ${br*.6}) rotate(${-lean*.25} 0 -320)`);
    const S=[20,-306+br],Ee=P(S,a1,70),Hh=P(Ee,a2,66);
    arm(`M${S}L${Ee}L${Hh}`);
    sw.setAttribute('transform',`translate(${Hh}) rotate(${-(a3+w)})`);
    if(sw2){const S2=[-18,-306+br],E2=P(S2,a1*.6-10,70),H2=P(E2,a2*.7-10,66);arm2(`M${S2}L${E2}L${H2}`);sw2.setAttribute('transform',`translate(${H2}) rotate(${-(a3*.6+w+20)})`)}
    if(shG)shG.setAttribute('transform',`translate(${42+s*12} ${-232-s*40+br}) rotate(${s*8})`);
    if(o.cape!=='none'){
      let l='',r='';const cl=o.capeLen||230,cw=o.cape==='rags'?7:6,wv=o.cape==='rags'?4.2:3;
      for(let i=0;i<=6;i++){const y=-316+i*cl/6,k=Math.sin(t*2.2+i*.8+(o.ph||0))*i*wv-lean*(i*.5);
        l+=`${i?'L':'M'}${-30-i*cw+k},${y}`;r=`L${26-i*cw*.4+k},${y}`+r}
      cape.setAttribute('d',l+r+'Z');
    }
    if(o.plume)o.plume.setAttribute('transform',`rotate(${Math.sin(t*3)*4+lean*.5} 0 -386)`);
   }};
}

/* weapon art, built along +x from the grip. returns {L: length} */
function weaponArt(g,W,o){
  const dark=o.bladeDark;
  const blade=dark?'url(#bladeDark)':'url(#blade)';
  let L=150;
  const grip=()=>{mk(g,'rect',{x:-4,y:-21,width:9,height:42,rx:2.5,fill:'url(#gold) #b8923a'});mk(g,'rect',{x:-38,y:-4.5,width:35,height:9,fill:'#1a110a'});mk(g,'circle',{cx:-40,r:6.5,fill:'url(#gold) #b8923a'})};
  if(W==='longsword'||W==='twinblades'){L=W==='twinblades'?125:150;
    mk(g,'path',{d:`M0,-5L${L},-4L${L+20},0L${L},4L0,5Z`,fill:blade});mk(g,'path',{d:`M12,0H${L-10}`,stroke:'#fff',opacity:.45,'stroke-width':1.4});grip()}
  else if(W==='greatsword'){L=215;
    mk(g,'path',{d:`M0,-9L${L},-8L${L+30},0L${L},8L0,9Z`,fill:blade,stroke:'#0b0d0f','stroke-width':1.2});mk(g,'path',{d:`M14,0H${L-14}`,stroke:'#fff',opacity:.4,'stroke-width':2});
    mk(g,'path',{d:`M30,-6V6M${L*.5},-6V6`,stroke:'#000',opacity:.35});
    mk(g,'rect',{x:-8,y:-30,width:12,height:60,rx:3,fill:'url(#gold) #b8923a'});mk(g,'rect',{x:-58,y:-5.5,width:52,height:11,fill:'#1a110a'});mk(g,'circle',{cx:-60,r:8,fill:'url(#gold) #b8923a'})}
  else if(W==='axe'){L=130;
    mk(g,'rect',{x:-30,y:-4,width:L+20,height:8,rx:2,fill:'#3a2a1a',stroke:'#150e08','stroke-width':1});
    mk(g,'path',{d:`M${L-20},-6Q${L+22},-72 ${L+54},-40Q${L+40},-6 ${L+8},-4L${L-20},-4Z`,fill:blade,stroke:'#0b0d0f','stroke-width':1.4});
    mk(g,'path',{d:`M${L-8},-8Q${L+28},-46 ${L+46},-38`,stroke:'#fff',opacity:.4,fill:'none','stroke-width':1.4});
    mk(g,'path',{d:`M${L-18},4L${L+4},30L${L+14},4Z`,fill:'#5d6670',stroke:'#0b0d0f'})}
  else if(W==='mace'){L=125;
    mk(g,'rect',{x:-30,y:-4.5,width:L+10,height:9,rx:2,fill:'#2a1e14',stroke:'#100a06','stroke-width':1});
    mk(g,'circle',{cx:L+22,r:25,fill:'url(#bladeDark)',stroke:'#0b0d0f','stroke-width':2});
    for(let a=0;a<8;a++){const r=a*Math.PI/4;mk(g,'path',{d:`M${L+22+Math.cos(r)*22},${Math.sin(r)*22}L${L+22+Math.cos(r)*36},${Math.sin(r)*36}L${L+22+Math.cos(r+.35)*22},${Math.sin(r+.35)*22}Z`,fill:'#7f8791',stroke:'#0b0d0f','stroke-width':1})}
    L=L+22}
  else if(W==='spear'){L=230;
    mk(g,'rect',{x:-70,y:-3.5,width:L+60,height:7,rx:2,fill:'#3a2a1a',stroke:'#150e08','stroke-width':1});
    mk(g,'path',{d:`M${L-10},-13L${L+50},0L${L-10},13Q${L-2},0 ${L-10},-13Z`,fill:blade,stroke:'#0b0d0f','stroke-width':1.2});
    mk(g,'path',{d:`M${L-16},-4L${L-16},4`,stroke:'#7a1313','stroke-width':6})}
  else if(W==='scythe'){L=200;
    mk(g,'rect',{x:-60,y:-3.5,width:L+40,height:7,rx:2,fill:'#2a2018',stroke:'#100a06','stroke-width':1});
    mk(g,'path',{d:`M${L-4},-4Q${L+40},-70 ${L+110},-34Q${L+50},-44 ${L+10},4Z`,fill:blade,stroke:'#0b0d0f','stroke-width':1.4});
    mk(g,'path',{d:`M${L+6},-10Q${L+44},-56 ${L+96},-34`,stroke:'#fff',opacity:.35,fill:'none','stroke-width':1.3});
    L=L+60}
  return{L};
}

/* HP-driven wounds: reveals the splat group progressively */
function setWound(ch,k){ch.splat.setAttribute('opacity',Math.min(.95,k))}
