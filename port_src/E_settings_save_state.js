/* ===================================================================
   RHYTHM DUEL v2  -  core
   Depends on: engine (kn,kg replaced by fighter2 instances), audio (AC,out,sfx*), fx (spark,bloodBurst,stain),
   window.ROSTER / STYLES / MOVES, window.ARENAS (merged), char builder.
   =================================================================== */

/* ---------- SETTINGS (persisted) ---------- */
const DEFAULT_SET={music:.8,sfx:.9,difficulty:'normal',offset:0,shake:1,blood:2,quality:'high',haptics:true,flash:true,guide:true,style:'knight',leftHand:false};
let SET=Object.assign({},DEFAULT_SET);
try{Object.assign(SET,JSON.parse(localStorage.getItem('kj_set')||'{}'))}catch(e){}
const saveSet=()=>{try{localStorage.setItem('kj_set',JSON.stringify(SET))}catch(e){}};
const DIFF={easy:{win:1.3,take:.55,tempo:.88,enemyDmg:.65},normal:{win:1.12,take:.8,tempo:.96,enemyDmg:.85},hard:{win:.85,take:1.2,tempo:1.08,enemyDmg:1.15},brutal:{win:.72,take:1.5,tempo:1.15,enemyDmg:1.3}};

/* ---------- SAVE / PROGRESS ---------- */
let SAVE={gold:0,beat:[],best:{survival:0,rush:0,daily:{}},unlocked:{duelist:false,berserker:false},kills:0,inv:{heal:0,focus:0,edge:0,tough:0}};
try{Object.assign(SAVE,JSON.parse(localStorage.getItem('kj_save')||'{}'))}catch(e){}
SAVE.inv=Object.assign({heal:0,focus:0,edge:0,tough:0},SAVE.inv||{});SAVE.seen=SAVE.seen||{};
const saveGame=()=>{try{localStorage.setItem('kj_save',JSON.stringify(SAVE))}catch(e){}};

/* ---------- GAME STATE ---------- */
Object.assign(GM,{
  mode:'duel',started:false,paused:false,
  t:0,t0:0,bpm:84,
  hp:100,maxhp:100,khp:100,kmax:100,stamina:100,special:0,
  score:0,combo:0,maxCombo:0,nP:0,nG:0,nM:0,
  enemyIdx:0,enemy:null,style:null,phaseIdx:0,
  events:[],        // active events of the current round
  roundType:'defend',round:0,roundEnd:0,
  poolSeed:1,rng:null,
  rageUntil:0,riposte:false,guardBreak:0,
  wave:0,rushList:[],training:false,
  gold:0,fought:0,hitStop:0
});
const BEATS=()=>60/GM.bpm;
const mulberry=a=>()=>{a|=0;a=a+0x6D2B79F5|0;let t=Math.imul(a^a>>>15,1|a);t=t+Math.imul(t^t>>>7,61|t)^t;return((t^t>>>14)>>>0)/4294967296};

/* ---------- ARENA LOADER ---------- */
const ARENA_ALL=Object.assign({},window.ARENAS_A||{},window.ARENAS_B||{});
const ROSTER=window.ROSTER,STYLES=window.STYLES,MOVES=window.MOVES;
let curArena=null;
const LAYER_MAP={L_bg:'bg',L_cl:'cl',L_gnd:'gnd',L_fg:'fg'};
function hexA(h,a){return h}
async function loadArena(key){
  const A=ARENA_ALL[key];if(!A){console.warn('no arena',key);return}
  if(curArena===key)return;curArena=key;
  // swap SVG markup of the 4 baked layers and re-bake
  for(const [id,part] of Object.entries(LAYER_MAP)){
    const old=$(id+'_baked');if(old)old.remove();
    const svg=$(id);svg.style.display='';
    // keep one wrapper so bakeLayer finds children; clear then fill
    svg.innerHTML=A[part]||'';
  }
  await Promise.all(Object.keys(LAYER_MAP).map(id=>bakeLayer(id)));
  // lights
  const L=A.light||{};
  const setStop=(gid,col,op)=>{const g=document.getElementById(gid);if(!g)return;g.querySelectorAll('stop').forEach((s,i)=>{if(i===0){s.setAttribute('stop-color',col);s.setAttribute('stop-opacity',op)}else s.setAttribute('stop-color',col)})};
  if(L.key){setStop('lL',L.key,L.keyOp??.42);setStop('lR',L.key,L.keyOp??.42)}
  if(L.keyL){const e=document.getElementById('lL');e.setAttribute('cx',L.keyL.x);e.setAttribute('cy',L.keyL.y)}
  if(L.keyR){const e=document.getElementById('lR');e.setAttribute('cx',L.keyR.x);e.setAttribute('cy',L.keyR.y)}
  // fog band colour
  const mg=document.getElementById('mist');if(mg&&L.fog){const st=mg.querySelectorAll('stop');st.forEach((s,i)=>{s.setAttribute('stop-color',L.fog);s.setAttribute('stop-opacity',i===1?(L.fogOp??.17):0)})}
  setWeather(A.weather||{type:'embers',count:46,color:'#ff9a2a',wind:-20});
  window.__music=A.music||{root:48,scale:'minor',tempo:84};
  stains.innerHTML='';
}

/* ---------- WEATHER (pooled; replaces embers) ---------- */
let WX={type:'embers',list:[],wind:-20,color:'#ff9a2a'};
function setWeather(w){
  const g=$('embers');g.innerHTML='';WX={type:w.type,wind:w.wind||0,color:w.color||'#fff',list:[]};
  const n=Math.round((w.count||40)*(SET.quality==='low'?.4:SET.quality==='med'?.7:1));
  for(let i=0;i<n;i++){
    const r=rnd(),size=w.type==='snow'?1.5+r*3.2:w.type==='dust'?.8+r*1.8:w.type==='ash'?1.2+r*2.4:w.type==='fireflies'?1.6+r*2.2:1+r*3;
    const el=mk(g,w.type==='ash'?'rect':'circle',w.type==='ash'?{width:size*1.6,height:size*.8,fill:w.color}:{r:size,fill:w.type==='embers'?(rnd()>.35?w.color:'#ff4a10'):w.color});
    WX.list.push({e:el,x:rnd()*1900-150,y:rnd()*1000-50,vx:0,vy:0,ph:rnd()*6.28,a:.4+rnd()*.6,s:size,sp:.6+rnd()*.8});
  }
}
function stepWeather(t,dt){
  const w=WX,T=w.type;
  for(const p of w.list){
    if(T==='snow'){p.vy=40+p.sp*50;p.vx=w.wind*(.6+p.sp*.5)+Math.sin(t*.8+p.ph)*18}
    else if(T==='ash'){p.vy=-10+p.sp*26;p.vx=w.wind*p.sp;p.e.setAttribute('transform',`rotate(${(t*90+p.ph*50)%360} ${p.x} ${p.y})`)}
    else if(T==='fireflies'){p.vx=Math.sin(t*.7+p.ph)*24;p.vy=Math.cos(t*.9+p.ph*2)*18}
    else if(T==='dust'){p.vx=w.wind+Math.sin(t*.3+p.ph)*8;p.vy=-4+Math.sin(t*.5+p.ph)*6}
    else {p.vx=w.wind*p.sp;p.vy=-30-p.sp*40}   // embers rise
    p.x+=p.vx*dt;p.y+=p.vy*dt;
    if(p.y<-30){p.y=960;p.x=rnd()*1900-150}else if(p.y>960){p.y=-30;p.x=rnd()*1900-150}
    if(p.x<-200)p.x=1800;else if(p.x>1800)p.x=-200;
    const flick=T==='fireflies'?(.2+.8*Math.max(0,Math.sin(t*2.3+p.ph*4))):(.65+.35*Math.sin(t*4+p.ph));
    if(p.e.tagName==='rect'){p.e.setAttribute('x',p.x.toFixed(1));p.e.setAttribute('y',p.y.toFixed(1))}
    else{p.e.setAttribute('cx',p.x.toFixed(1));p.e.setAttribute('cy',p.y.toFixed(1))}
    p.e.setAttribute('opacity',(p.a*flick).toFixed(2));
  }
}

/* ---------- CHARACTERS ---------- */
function buildPlayer(){
  const S=STYLES.find(s=>s.id===SET.style)||STYLES[0];GM.style=S;
  const look=Object.assign({f:1,ph:0,capeLen:190,id:'pl_'+S.id,emblem:'cross',plumeCol:'#6a0d12'},S.look||{});
  look.colors=look.colors||['#1b1f25','#566170','#c4d0dc'];
  look.weapon=S.weapon||'longsword';
  KN2=fighter2($('fK'),look);
}
function buildEnemy(E){
  const look=Object.assign({f:-1,ph:2,capeLen:290,id:'en_'+E.id},E.look);
  KG2=fighter2($('fG'),look);
  GM.enemy=E;
}

/* ---------- POSES ---------- */
const PZ={
  kIdle :[420,0,-40,40,80,0,0,0],
  kGuard:[445,3,-30,50,85,.9,0,2],
  kParry:[482,-2,-5,5,40,.2,0,0],
  kWind :[440,8,70,95,115,0,0,3],
  kSlash:[500,-4,-5,5,35,0,0,0],
  kThrust:[512,-6,5,-5,0,0,0,2],
  kOver :[480,6,98,122,142,0,0,6],
  kDuck :[430,14,-20,30,80,.6,0,34],
  kJump :[440,-4,-60,20,60,0,0,-30],
  kDodge:[380,-12,-40,40,80,0,0,4],
  kHurt :[395,-18,-75,-55,-35,-.4,0,8],
  kDead :[540,-40,-95,-80,-60,0,1,0],
  kWin  :[470,2,60,40,100,0,0,0],
  kStun :[420,-14,-60,30,40,0,0,10],
  gIdle :[900,0,-40,45,70,0,0,0],
  gWind :[880,-8,98,122,142,0,0,6],
  gWindL:[885,6,-20,30,-25,0,0,18],
  gWindH:[880,-10,120,130,160,0,0,2],
  gLunge:[820,10,10,-5,20,0,0,10],
  gThrow:[895,-6,110,60,60,0,0,2],
  gStrike:[760,8,-20,-15,10,0,0,-2],
  gStrikeL:[775,12,-8,-12,-10,0,0,16],
  gSwing:[800,-4,75,100,125,0,0,3],
  gParried:[930,8,-10,10,50,0,0,3],
  gBlockH:[880,-4,60,95,115,0,0,0],
  gBlockL:[885,4,-30,-20,-55,0,0,14],
  gHurt :[945,10,-70,-60,-30,0,0,6],
  gDead :[1010,18,-95,-80,-60,0,1,0],
  gStun :[920,-12,-60,30,40,0,0,10],
  gWin  :[640,2,-20,10,30,0,0,0]
};
function mkP(init){return{cur:init.slice(),tgt:init.slice(),spd:9}}
function setP(p,t,spd=14){p.tgt=t.slice();p.spd=spd}
function stepP(p,dt){const k=1-Math.exp(-p.spd*dt);for(let i=0;i<p.cur.length;i++)p.cur[i]+=(p.tgt[i]-p.cur[i])*k}
KP=mkP(PZ.kIdle);GP=mkP(PZ.gIdle);

/* ===================================================================
   PLAY v2 - round generation, input judging, enemy behaviours, modes
   =================================================================== */

/* ---------- windows (seconds), scaled by style + difficulty ---------- */
function windows(){
  const S=GM.style||{windows:{perfect:.06,good:.115,miss:.17}},D=DIFF[SET.difficulty]||DIFF.normal;