/* LANDSCAPE phones: two thumb clusters in the lower corners; centre stays clear for the fight */
@media (orientation:landscape) and (max-height:520px){
  #gPads,#gDef{height:min(30vh,110px);bottom:max(6px,env(safe-area-inset-bottom))}
  #gDock button{background:rgba(14,10,8,.38);backdrop-filter:none;border-radius:14px}
  /* defend: left cluster = Jump over (Dodge|Duck); right cluster = big Parry */
  #gDef .zl{width:min(34%,300px);gap:8px;left:max(10px,env(safe-area-inset-left))}
  #gDef .zr{width:min(30%,260px);right:max(10px,env(safe-area-inset-right))}
  /* attack: three lanes become a left cluster (Slash, Thrust) and right cluster (Overhead) split by the fight */
  #gPads{justify-content:space-between;padding:0 max(10px,env(safe-area-inset-left));gap:8px}
  #gPads button{max-width:none;flex:0 0 auto;width:min(19%,160px)}
  #gPads button[data-l="2"]{margin-left:auto}
  #gPads button[data-l="1"]{margin-right:auto}
  /* Focus + Heal sit directly above the right thumb cluster, out of the Pause corner */
  #gFocus{right:max(10px,env(safe-area-inset-right));bottom:calc(max(6px,env(safe-area-inset-bottom)) + min(30vh,110px) + 8px);width:56px;height:56px}
  #gPot{right:calc(max(10px,env(safe-area-inset-right)) + 66px);bottom:calc(max(6px,env(safe-area-inset-bottom)) + min(30vh,110px) + 12px);width:46px;height:46px}
}
@media (orientation:landscape) and (max-height:400px){
  #gPads,#gDef{height:min(27vh,96px)}
  #gDef .zl button[data-k="jump"]{grid-column:auto}
  #gDef .zl{grid-template-columns:1fr 1fr 1fr;grid-template-rows:1fr;width:min(44%,330px)}
  #gDef .zr{width:min(28%,220px)}
  #gFocus{bottom:max(8px,env(safe-area-inset-bottom));right:calc(max(10px,env(safe-area-inset-right)) + min(30%,260px) + 8px);width:52px;height:52px}
  #gPot{bottom:calc(max(8px,env(safe-area-inset-bottom)) + 58px);right:calc(max(10px,env(safe-area-inset-right)) + min(30%,260px) + 8px);width:44px;height:44px}
  #gPads button{width:min(17%,140px)}
}
/* menu */
#gMenu{position:absolute;inset:0;z-index:12;display:none;flex-direction:column;align-items:center;justify-content:center;gap:12px;padding:3% 4%;background:radial-gradient(ellipse at center,rgba(18,8,6,.78),rgba(0,0,0,.96));text-align:center;overflow:auto}
#gMenu.on{display:flex;touch-action:manipulation;-webkit-touch-callout:none;-webkit-tap-highlight-color:transparent}
#gMenu button,#gMenu .card{touch-action:manipulation;-webkit-user-select:none;user-select:none;-webkit-touch-callout:none}
#gMenu .press{transform:scale(.97);filter:brightness(1.25)}
#gMenu h2{margin:0;font-weight:400;font-style:italic;font-size:clamp(22px,4.4vw,52px);letter-spacing:.14em;text-shadow:0 0 28px rgba(180,20,20,.55)}
#gMenu .kick{font:600 clamp(9px,1.1vw,12px) system-ui;letter-spacing:.4em;color:#8a7f6a;text-transform:uppercase}
#gMenu .grid{display:grid;gap:10px;width:min(100%,900px)}
#gMenu .grid.c3{grid-template-columns:repeat(3,1fr)}
#gMenu .grid.c2{grid-template-columns:repeat(2,1fr)}
#gMenu .card{position:relative;text-align:left;padding:clamp(8px,1.6vw,16px);border:1px solid rgba(205,191,166,.28);border-radius:10px;background:rgba(20,14,12,.7);cursor:pointer;color:#e6dcc9;font-family:Georgia,serif;text-transform:none;letter-spacing:.02em;min-height:0;display:block}
#gMenu .card:hover,#gMenu .card.sel{background:rgba(70,16,16,.7);border-color:rgba(220,120,110,.7)}
#gMenu .card b{display:block;font-size:clamp(12px,1.7vw,18px);font-weight:600;letter-spacing:.12em;text-transform:uppercase;margin-bottom:4px}
#gMenu .card span{display:block;font:clamp(9px,1.15vw,12px)/1.35 system-ui;color:#a89c86;letter-spacing:.04em}
#gMenu .card.lock{opacity:.4;pointer-events:none}
#gMenu .card em{position:absolute;right:10px;top:8px;font:600 9px system-ui;letter-spacing:.2em;color:#d9b45a;font-style:normal}
#gMenu .row{display:flex;gap:10px;flex-wrap:wrap;justify-content:center}
#gMenu button.pill{min-height:44px;padding:11px 26px;border-radius:40px;letter-spacing:.26em;font-size:11px}
#gMenu .set{width:min(100%,640px);text-align:left;display:grid;gap:8px}
#gMenu .set label{display:flex;justify-content:space-between;align-items:center;gap:12px;padding:8px 12px;border:1px solid rgba(205,191,166,.16);border-radius:8px;background:rgba(14,10,8,.6);font:600 clamp(10px,1.3vw,13px) system-ui;letter-spacing:.16em;text-transform:uppercase;color:#cdbfa6}
#gMenu .set input[type=range]{width:44%;accent-color:#a8341f}
#gMenu .set select{background:#140e0c;color:#e6dcc9;border:1px solid rgba(205,191,166,.3);border-radius:6px;padding:6px 8px;font:12px system-ui}
#gMenu .set input[type=checkbox]{width:20px;height:20px;accent-color:#a8341f}
#gMenu .set small{display:block;font:11px system-ui;letter-spacing:.06em;color:#7d725f;text-transform:none;margin-top:2px}
#gMenu .stats{display:flex;gap:5vw;font:600 clamp(10px,1.3vw,13px) system-ui;letter-spacing:.2em;color:#cdbfa6;text-transform:uppercase;margin:4px 0 8px;flex-wrap:wrap;justify-content:center}
#gMenu .stats b{display:block;font-size:clamp(16px,2.8vw,28px);letter-spacing:.08em;margin-top:4px}
#gMenu .mini{font:11px system-ui;color:#7d725f;letter-spacing:.1em}
.dot{display:inline-block;width:9px;height:9px;border-radius:50%;margin-right:6px;vertical-align:middle}
`;
document.head.appendChild(css2);

/* ---------- HUD ---------- */
function updFocusUI(){const f=$('gFocus');if(!f)return;const u=f.querySelector('u');if(u)u.style.height=(GM.focusUntil>GM.t?Math.max(0,(GM.focusUntil-GM.t)/3.5*100):GM.stamina)+'%';f.classList.toggle('ready',GM.stamina>=100&&!(GM.focusUntil>GM.t))}
function updHud2(){updFocusUI();
  $('hpK').style.width=Math.max(0,GM.hp/GM.maxhp*100)+'%';
  $('hpG').style.width=Math.max(0,GM.khp/GM.kmax*100)+'%';
  $('stK').style.width=Math.max(0,GM.stamina)+'%';$('stK').style.background=GM.focusUntil>GM.t?'linear-gradient(90deg,#4a8fe0,#bfe4ff)':GM.stamina>=100?'linear-gradient(90deg,#6fb0ff,#e0f2ff)':'linear-gradient(90deg,#3a5a7a,#7aa8d0)';
  const sw=$('swK');if(sw)sw.textContent=(GM.windUsed?'':'♥ second wind')+(GM.tough?' · tonic':'')+(GM.edge?' · edge':'');
  $('gPts').textContent=String(GM.score).padStart(6,'0');
  $('gCombo').textContent=GM.combo>=3?GM.combo+' combo':'';
  const S=GM.style&&GM.style.special;
  if(S){ $('spB').style.width=(GM.rageUntil>GM.t?100:Math.min(100,GM.special/S.need*100))+'%'; $('spT').textContent=S.name+(S.id==='riposte'&&GM.riposte?' · READY':''); }
}
function taunt(line){const t=$('gTaunt');t.textContent='“'+line+'”';t.style.opacity=1;clearTimeout(t._t);t._t=setTimeout(()=>t.style.opacity=0,3000)}
function shake2(n){GM.shake=Math.max(GM.shake,n*SET.shake)}
function flashScreen(col,o){if(!SET.flash)return;G.fCol=col;G.fO=o;G.fT=performance.now()}
function vibrate(ms){if(SET.haptics&&navigator.vibrate)try{navigator.vibrate(ms)}catch(e){}}
function flashBtn(kind,lane){
  let b=null;
  if(kind==='lane')b=document.querySelector(`#gPads [data-l="${lane}"]`);else b=document.querySelector(`#gDef [data-k="${kind}"]`);
  if(b){b.classList.add('hit');setTimeout(()=>b.classList.remove('hit'),90)}
}

/* ---------- canvas renderer: lanes, rings, guides ---------- */
const gcv=$('gCv'),gctx=gcv.getContext('2d');
let CW=1600,CH=900,DPR=1;
function gsize(){const r=$('stage').getBoundingClientRect();DPR=Math.min(2,window.devicePixelRatio||1)*(SET.quality==='low'?.7:1);CW=r.width;CH=r.height;gcv.width=CW*DPR;gcv.height=CH*DPR}
addEventListener('resize',gsize);
const LANE_COL=['#d9b45a','#c8d4e0','#c23a2a'],LANE_NAME=['Slash','Thrust','Overhead'];
const INPUT_COL={parry:'#e8f2ff',duck:'#f1d98e',jump:'#bfe8cc',dodge:'#ff5a3a',grab:'#ff9a3a'};
const INPUT_ICON={parry:'PARRY',duck:'DUCK',jump:'JUMP',dodge:'DODGE',grab:'BREAK'};
function drawGame(){
  gctx.setTransform(DPR,0,0,DPR,0,0);gctx.clearRect(0,0,CW,CH);
  if(!GM.on||!GM.started||GM.over||GM.paused)return;
  const B=BEATS(),t=GM.t,W=windows();
  if(GM.roundType==='attack'){
    const foc=GM.focusUntil>GM.t,laneX=[CW*.30,CW*.50,CW*.70],yH=CH*.82,yTop=CH*.16,trav=B*(foc?3.1:2);
    for(let l=0;l<3;l++){
      const g=gctx.createLinearGradient(0,yTop,0,yH);g.addColorStop(0,'rgba(0,0,0,0)');g.addColorStop(1,LANE_COL[l]+'55');
      gctx.fillStyle=g;gctx.fillRect(laneX[l]-CW*.045,yTop,CW*.09,yH-yTop);
      gctx.strokeStyle=LANE_COL[l]+'cc';gctx.lineWidth=2;gctx.beginPath();gctx.arc(laneX[l],yH,CW*.032,0,6.283);gctx.stroke();
      gctx.fillStyle=LANE_COL[l]+'cc';gctx.font=`600 ${Math.max(9,CW*.011)}px system-ui`;gctx.textAlign='center';
      if(SET.guide)gctx.fillText(isTouch?LANE_NAME[l].toUpperCase():['A / ←','W / ↑','D / →'][l],laneX[l],yH+CW*.055);
    }
    for(const n of GM.events){
      if(n.state!=='live'||n.kind!=='note')continue;
      const d=n.time-t;if(d>trav||d<-W.miss)continue;
      const u=1-d/trav,y=yTop+(yH-yTop)*u,r=CW*(.014+.02*u);
      // shifting notes slide to their new lane near the end
      let lx=laneX[n.lane];
      if(n.flag&&(n.flag==='S+'||n.flag==='S-')&&!n.shifted){const to=clamp(n.orig+(n.flag==='S+'?1:-1),0,2);const k=sm(.2,.0,d/B);lx=laneX[n.orig]+(laneX[to]-laneX[n.orig])*(1-clamp(d/(B*.35)));}
      noteShape(lx,y,r,n);
    }
  }else{
    const cx=CW*.44,cy=CH*.52,rEnd=CW*.045,rStart=CW*.17;
    // guide: show required input for upcoming event
    let shown=0;
    for(const e of GM.events){
      if(e.state!=='live'||e.kind==='note')continue;
      const tell=Math.max(e.tell||B*1.4,B*1.4)*((GM.focusUntil>GM.t)?1.5:1),d=e.time-t;if(d>tell||d<-W.miss)continue;
      const u=clamp(1-d/tell),r=rStart+(rEnd-rStart)*u,col=INPUT_COL[e.input]||'#fff';
      gctx.save();gctx.globalAlpha=.25+.75*u;
      const perfectNow=Math.abs(d)<W.perfect;
      gctx.strokeStyle=perfectNow?'#fff':col;gctx.lineWidth=3+u*3;gctx.shadowColor=col;gctx.shadowBlur=16;
      if(e.input==='dodge'){gctx.setLineDash([10,7])}
      if(e.feint&&!e.feintOk){gctx.globalAlpha*=.5+.5*Math.sin(t*30);gctx.setLineDash([4,6])}
      gctx.beginPath();gctx.arc(cx,cy,r,0,6.283);gctx.stroke();
      if(e.input==='grab'){gctx.beginPath();gctx.arc(cx,cy,r*.82,0,6.283);gctx.stroke()}
      gctx.setLineDash([]);gctx.globalAlpha=.9;gctx.lineWidth=2;gctx.strokeStyle='#c23a2a';gctx.beginPath();gctx.arc(cx,cy,rEnd,0,6.283);gctx.stroke();
      // input label inside ring (until commit)
      if(SET.guide&&shown<1){shown++;gctx.globalAlpha=.55+.45*u;gctx.fillStyle=col;gctx.font=`700 ${Math.max(10,CW*.013)}px system-ui`;gctx.textAlign='center';gctx.shadowBlur=0;
        const keyHint=isTouch?'':{parry:' (SPACE)',duck:' (S)',jump:' (W)',dodge:' (A)',grab:' (SPACE+A)'}[e.input]||'';
        gctx.fillText((INPUT_ICON[e.input]||'')+keyHint,cx,cy-r-CW*.012)}
      gctx.restore();
    }
  }
}
function noteShape(x,y,r,n){
  const col=LANE_COL[n.lane];
  gctx.save();gctx.translate(x,y);
  gctx.shadowColor=col;gctx.shadowBlur=18;
  let fill=col;
  if(n.flag==='P'){fill='#7fa8d0'}
  gctx.fillStyle=fill;
  gctx.beginPath();gctx.moveTo(0,-r*1.5);gctx.lineTo(r,0);gctx.lineTo(0,r*1.5);gctx.lineTo(-r,0);gctx.closePath();gctx.fill();
  gctx.fillStyle='rgba(0,0,0,.35)';gctx.beginPath();gctx.moveTo(0,-r*.7);gctx.lineTo(r*.45,0);gctx.lineTo(0,r*.7);gctx.lineTo(-r*.45,0);gctx.closePath();gctx.fill();
  gctx.shadowBlur=0;gctx.lineWidth=2.5;
  if(n.flag==='P'){gctx.strokeStyle='#dff0ff';gctx.beginPath();gctx.arc(0,0,r*1.9,0,6.283);gctx.stroke()}       // shield ring: enemy parries
  else if(n.flag==='BH'||n.flag==='BL'){gctx.strokeStyle='#9fb4c8';gctx.beginPath();gctx.moveTo(-r*1.5,n.flag==='BH'?-r*1.9:r*1.9);gctx.lineTo(r*1.5,n.flag==='BH'?-r*1.9:r*1.9);gctx.stroke()} // block bar
  else if(n.flag==='A'||n.flag==='A2'||n.flag==='Ah'){gctx.strokeStyle='#e8e8e8';gctx.strokeRect(-r*1.25,-r*1.25,r*2.5,r*2.5)}   // armor box
  else if(n.flag==='C'){gctx.strokeStyle='#ff6a4a';gctx.beginPath();gctx.moveTo(-r*1.6,0);gctx.lineTo(r*1.6,0);gctx.moveTo(0,-r*1.6);gctx.lineTo(0,r*1.6);gctx.stroke()}  // counter cross
  else if(n.flag==='S+'||n.flag==='S-'){gctx.strokeStyle='#c9e86a';gctx.beginPath();const s=n.flag==='S+'?1:-1;gctx.moveTo(s*r*1.1,-r*.8);gctx.lineTo(s*r*2,0);gctx.lineTo(s*r*1.1,r*.8);gctx.stroke()}
  gctx.restore();
}

/* ===================================================================
   MENUS + MODES + FLOW
   =================================================================== */
const MODES=[
  {id:'duel',name:'Trial by Combat',desc:'Fight seven champions across six battlefields. The King waits at the end.'},
  {id:'survival',name:'Survival',desc:'Endless waves. Every kill restores a little health. How long can you stand?'},
  {id:'rush',name:'Boss Rush',desc:'Every champion back to back. One health bar. No mercy.'},
  {id:'daily',name:'Daily Challenge',desc:'One seeded fight per day, same for everyone. Beat your own best score.'},
  {id:'training',name:'Training Yard',desc:'No damage taken or dealt. Practice every move at your own pace.'}
];
function showMenu(html){MENU.innerHTML=html;MENU.classList.add('on');MENU.scrollTop=0}

/* ---------- reliable taps for every menu button ----------
   Browsers cancel a click when the finger drifts a few px (the menu scrolls), which looked like
   "the button just highlights". We track pointerdown->pointerup ourselves and fire the button if the
   finger stayed within a generous slop, then swallow the browser's own click so nothing double-fires. */
var __menuTapInit=0;
(function(){
  let down=null,lastFire=0;
  const SLOP=30;
  const target=e=>e.target.closest&&e.target.closest('#gMenu button,#gMenu .card,#gMenu [data-mode],#gMenu [data-i],#gMenu [data-t],#gMenu [data-st],#gMenu label.tgl');
  MENU.addEventListener('pointerdown',e=>{
    const b=target(e);if(!b||b.disabled||b.classList.contains('lock')){down=null;return}
    down={b,x:e.clientX,y:e.clientY,id:e.pointerId,moved:0};b.classList.add('press');
  },true);
  MENU.addEventListener('pointermove',e=>{
    if(!down||e.pointerId!==down.id)return;
    const d=Math.hypot(e.clientX-down.x,e.clientY-down.y);if(d>down.moved)down.moved=d;
  },true);
  const clear=()=>{if(down)down.b.classList.remove('press');down=null};
  MENU.addEventListener('pointercancel',e=>{
    // the browser took the gesture for a scroll: if the finger barely moved, still count it as a tap
    if(down&&e.pointerId===down.id&&down.moved<=SLOP&&e.pointerType!=='mouse'){const b=down.b;clear();fire(b)}else clear();
  },true);
  MENU.addEventListener('pointerup',e=>{
    if(!down||e.pointerId!==down.id){clear();return}
    const b=down.b,ok=down.moved<=SLOP;clear();
    if(!ok)return;
    e.preventDefault();fire(b);
  },true);
  function fire(b){
    const now=performance.now();if(now-lastFire<250)return;lastFire=now;
    if(!document.body.contains(b))return;
    b.click();
  }
  // our pointerup already fired the button: ignore the browser's synthetic click (and let mouse clicks through)
  MENU.addEventListener('click',e=>{
    if(e.isTrusted&&performance.now()-lastFire<600&&!e.__ours){e.stopImmediatePropagation();e.preventDefault()}
  },true);
})();

function hideMenu(){MENU.classList.remove('on');MENU.innerHTML=''}

function mainMenu(){
  GM.on=false;GL2.classList.remove('on');DOCK2.classList.remove('on');gctx.clearRect(0,0,CW,CH);
  $('hud').style.display='none';
  showMenu(`<p class="kick">A Medieval Duel</p><h2>The King's Justice</h2>
   <div class="grid c2" style="margin-top:6px">${MODES.map(m=>`<button class="card" data-mode="${m.id}"><b>${m.name}</b><span>${m.desc}</span>${m.id==='daily'&&SAVE.best.daily[today()]?`<em>BEST ${SAVE.best.daily[today()]}</em>`:m.id==='survival'&&SAVE.best.survival?`<em>BEST ${SAVE.best.survival} WAVES</em>`:''}</button>`).join('')}</div>
   <div class="row" style="margin-top:8px"><button class="pill" id="mStyle">Fighting style</button><button class="pill" id="mShop">Tonics</button><button class="pill" id="mSet">Settings</button><button class="pill" id="mWatch">Watch cinematic</button></div>
   <p class="mini">Gold ${SAVE.gold} · Champions slain ${SAVE.kills}</p>`);
  MENU.querySelectorAll('[data-mode]').forEach(b=>b.onclick=e=>{e.stopPropagation();pickStart(b.dataset.mode)});
  $('mStyle').onclick=e=>{e.stopPropagation();styleMenu()};
  $('mShop').onclick=e=>{e.stopPropagation();shopMenu(mainMenu)};
  $('mSet').onclick=e=>{e.stopPropagation();settingsMenu(mainMenu)};
  $('mWatch').onclick=e=>{e.stopPropagation();hideMenu();stopGame2();$('hud').style.display='';seek(0);prevT=-1;play()};
}
const today=()=>new Date().toISOString().slice(0,10);

function styleMenu(){
  showMenu(`<p class="kick">Choose your way of killing</p><h2>Fighting Style</h2>
   <div class="grid c3">${STYLES.map(s=>{
     const locked=s.unlock&&!SAVE.unlocked[s.id];
     return`<button class="card ${SET.style===s.id?'sel':''} ${locked?'lock':''}" data-st="${s.id}"><b>${s.name}</b><span>${s.desc}</span><span style="margin-top:6px;color:#d9b45a">${s.special.name}: ${s.special.desc}</span>${locked?`<em>${s.unlock} GOLD</em>`:''}</button>`}).join('')}</div>
   <div class="row"><button class="pill" id="mBack">Back</button></div>`);
  MENU.querySelectorAll('[data-st]').forEach(b=>b.onclick=e=>{e.stopPropagation();SET.style=b.dataset.st;saveSet();styleMenu()});
  $('mBack').onclick=e=>{e.stopPropagation();mainMenu()};
}

function settingsMenu(back){
  const sl=(k,label,min=0,max=1,step=.05)=>`<label>${label}<input type="range" data-k="${k}" min="${min}" max="${max}" step="${step}" value="${SET[k]}"></label>`;
  const sel=(k,label,opts)=>`<label>${label}<select data-k="${k}">${opts.map(o=>`<option value="${o[0]}" ${String(SET[k])===String(o[0])?'selected':''}>${o[1]}</option>`).join('')}</select></label>`;
  const chk=(k,label,sub)=>`<label><span>${label}${sub?`<small>${sub}</small>`:''}</span><input type="checkbox" data-k="${k}" ${SET[k]?'checked':''}></label>`;
  showMenu(`<p class="kick">Settings</p><h2>Tune the Fight</h2>
   <div class="set">
    ${sl('music','Music volume')}${sl('sfx','Effects volume')}
    ${sel('difficulty','Difficulty',[['easy','Squire (easy)'],['normal','Knight (normal)'],['hard','Champion (hard)'],['brutal','Brutal']])}
    <label><span>Timing offset <small>If hits feel late (Bluetooth), raise it. Test it in Training.</small></span><span><input type="range" data-k="offset" min="-150" max="250" step="5" value="${SET.offset}" style="width:140px"> <b id="offV">${SET.offset}ms</b></span></label>
    ${sel('blood','Gore',[[0,'Off'],[1,'Light'],[2,'Normal'],[3,'Heavy']])}
    ${sl('shake','Screen shake',0,1.5,.1)}
    ${sel('quality','Graphics quality',[['high','High'],['med','Medium'],['low','Low (fastest)']])}
    ${chk('flash','Impact flashes')}${chk('guide','Show input hints')}${chk('haptics','Vibration (phones)')}
   </div>
   <div class="row"><button class="pill" id="mBack">Done</button><button class="pill" id="mReset">Reset</button><button class="pill" id="mWipe">Erase progress</button></div>`);
  MENU.querySelectorAll('[data-k]').forEach(el=>{
    const k=el.dataset.k;
    el.oninput=el.onchange=e=>{
      e.stopPropagation();
      let v=el.type==='checkbox'?el.checked:el.type==='range'?parseFloat(el.value):el.value;
      if(el.tagName==='SELECT'&&['blood'].includes(k))v=parseInt(v);
      SET[k]=v;saveSet();applySettings();
      if(k==='offset')$('offV').textContent=v+'ms';
    };
  });
  $('mBack').onclick=e=>{e.stopPropagation();back()};
  $('mReset').onclick=e=>{e.stopPropagation();SET=Object.assign({},DEFAULT_SET);saveSet();applySettings();settingsMenu(back)};
  $('mWipe').onclick=e=>{e.stopPropagation();if(confirm('Erase gold, unlocks and best scores?')){SAVE={gold:0,beat:[],best:{survival:0,rush:0,daily:{}},unlocked:{duelist:false,berserker:false},kills:0};saveGame();settingsMenu(back)}};
}
function applySettings(){
  if(AC&&master)master.gain.setTargetAtTime(.9*(SET.sfx),AC.currentTime,.05);
  if(window.__musicGain)window.__musicGain.gain.value=SET.music;
}



/* ---------- first-time tips: explain a move the first time it appears ---------- */
const TIPS={
 slash:['Parry','Press PARRY (Space / tap) just as the ring closes on the red circle.'],
 low:['Low sweep','Duck it: press S or tap DUCK as the ring closes.'],
 high:['Overhead','Jump over it: press W or tap JUMP.'],
 unblockable:['Unblockable','Red dashed ring: you cannot parry this. DODGE it (A or tap DODGE). A clean dodge stuns him.'],
 feint:['Feint','The ring flickers: he is faking. Wait for it to settle, then parry.'],
 double:['Double strike','Two hits half a beat apart. Parry twice.'],
 triple:['Triple strike','Three quick hits. Tap parry three times in rhythm.'],
 grab:['Grab','Press PARRY and DODGE together to break his grip.'],
 ranged:['Thrown weapon','Parry it as it arrives. Small damage, long warning.'],
 sweep_combo:['Sweep combo','Duck, then jump.'],
 'note:P':['He parries','Blue-ringed notes will be blocked. Hit them PERFECT to break his guard and open him up.'],
 'note:BH':['High guard','His guard covers high strikes. Use Slash or Thrust on these.'],
 'note:BL':['Low guard','His guard covers low strikes. Use Thrust or Overhead on these.'],
 'note:S+':['Sidestep','Green-arrow notes slide to the next lane right at the end. Hit the lane they land in.'],
 'note:S-':['Sidestep','Green-arrow notes slide to the next lane right at the end. Hit the lane they land in.'],
 'note:A':['Armour','Boxed notes need two hits in the same lane.'],
 'note:C':['Counter','Red-cross notes provoke a counter. Be ready to parry right after.']
};
function showTip(key){
  if(SAVE.seen[key]||!TIPS[key])return;SAVE.seen[key]=1;saveGame();
  const t=$('gTaunt');t.innerHTML='<b style="font:600 clamp(9px,1.2vw,13px) system-ui;letter-spacing:.3em;color:#d9b45a;display:block;margin-bottom:6px;text-transform:uppercase">'+TIPS[key][0]+'</b>'+TIPS[key][1];
  t.style.opacity=1;clearTimeout(t._t);t._t=setTimeout(()=>{t.style.opacity=0},3800);
}

/* ---------- TONIC SHOP ---------- */
const TONICS=[
 {id:'heal',name:'Healing Draught',cost:60,desc:'Press H (or tap the flask) mid-fight: restore 35% health. Once per fight.'},
 {id:'focus',name:'Battle Focus',cost:50,desc:'Start the next fight with your Focus meter half full.'},
 {id:'edge',name:'Whetstone',cost:70,desc:'+25% damage dealt for the next fight.'},
 {id:'tough',name:'Iron Gambeson',cost:80,desc:'20% less damage taken for the next fight.'}
];
function shopMenu(back){
  showMenu(`<p class="kick">Armourer's tent · Gold ${SAVE.gold}</p><h2>Tonics &amp; Tempering</h2>
   <div class="grid c2">${TONICS.map(t=>`<button class="card" data-t="${t.id}"><b>${t.name} <span style="display:inline;color:#d9b45a">· ${t.cost}</span></b><span>${t.desc}</span><em>OWNED ${SAVE.inv[t.id]||0}</em></button>`).join('')}</div>
   <p class="mini">Tonics are used up in the fight they are prepared for. Win fights to earn more gold.</p>
   <div class="row"><button class="pill" id="mBack">Back</button></div>`);
  MENU.querySelectorAll('[data-t]').forEach(b=>b.onclick=e=>{e.stopPropagation();const t=TONICS.find(x=>x.id===b.dataset.t);
    if(SAVE.gold>=t.cost){SAVE.gold-=t.cost;SAVE.inv[t.id]=(SAVE.inv[t.id]||0)+1;saveGame();shopMenu(back)}else{b.querySelector('b').style.color='#c23a2a'}});
  $('mBack').onclick=e=>{e.stopPropagation();back()};
}
/* apply prepared one-fight tonics at fight start */
function applyTonics(){
  if(SAVE.inv.focus>0){SAVE.inv.focus--;GM.stamina=50}
  if(SAVE.inv.edge>0){SAVE.inv.edge--;GM.edge=true}
  if(SAVE.inv.tough>0){SAVE.inv.tough--;GM.tough=true}
  GM.potion=SAVE.inv.heal>0?1:0;if(GM.potion)SAVE.inv.heal--;
  saveGame();
}
function drinkPotion(){
  if(!GM.on||!GM.started||GM.over||GM.paused||!GM.potion)return;
  GM.potion=0;GM.hp=Math.min(GM.maxhp,GM.hp+GM.maxhp*.35);say('Restored','#8fd0a0');flashScreen('#6fe08a',.2);updHud2();
}

/* ---------- mode start ---------- */
function pickStart(mode){
  GM.mode=mode;GM.training=mode==='training';
  if(mode==='training'){GM.enemyIdx=0;return beginFight(0)}
  if(mode==='duel'){
    // choose starting champion (unlocked up to furthest beaten)
    const far=Math.min(ROSTER.length-1,SAVE.beat.length);
    showMenu(`<p class="kick">Trial by Combat</p><h2>Choose your opponent</h2>
     <div class="grid c2">${ROSTER.map((r,i)=>`<button class="card ${i>far?'lock':''}" data-i="${i}"><b>${r.name}</b><span>${r.title} · ${ARENA_ALL[r.arena]?ARENA_ALL[r.arena].name:r.arena}</span>${SAVE.beat.includes(r.id)?'<em>SLAIN</em>':''}</button>`).join('')}</div>
     <div class="row"><button class="pill" id="mBack">Back</button></div>`);
    MENU.querySelectorAll('[data-i]').forEach(b=>b.onclick=e=>{e.stopPropagation();beginFight(+b.dataset.i)});
    $('mBack').onclick=e=>{e.stopPropagation();mainMenu()};
    return;
  }
  if(mode==='survival'){GM.wave=0;return beginFight(0)}
  if(mode==='rush'){GM.rushList=ROSTER.map((r,i)=>i);return beginFight(0)}
  if(mode==='daily'){return beginFight(0)}
}

function enemyFor(mode,idx){
  if(mode==='survival'){ // scale roster entries by wave
    const base=ROSTER[Math.min(ROSTER.length-2,GM.wave%6)];
    const k=1+Math.floor(GM.wave/6)*.25;
    return Object.assign({},base,{hp:Math.round(base.hp*.55*k),bpm:Math.min(124,base.bpm+GM.wave*1.2),dmgMul:1+GM.wave*.04});
  }
  if(mode==='daily'){
    const r=mulberry(hashStr(today()));
    const base=ROSTER[Math.floor(r()*ROSTER.length)];
    const arenas=Object.keys(ARENA_ALL);
    return Object.assign({},base,{arena:arenas[Math.floor(r()*arenas.length)],hp:Math.round(base.hp*(.9+r()*.4)),bpm:base.bpm+Math.floor(r()*10)});
  }
  if(mode==='training')return Object.assign({},ROSTER[0],{hp:9999});
  return ROSTER[idx];
}
const hashStr=s=>{let h=2166136261;for(const c of s){h^=c.charCodeAt(0);h=Math.imul(h,16777619)}return h>>>0};

async function beginFight(idx,keepHp){
  hideMenu();
  GM.enemyIdx=idx;
  const E=enemyFor(GM.mode,idx);
  // loading card
  showMenu(`<p class="kick">${E.title||''}</p><h2>${E.name}</h2><p class="mini">${ARENA_ALL[E.arena]?ARENA_ALL[E.arena].name+' · '+ARENA_ALL[E.arena].sub:''}</p><p class="mini">preparing the field…</p>`);
  gsize();
  await loadArena(E.arena);
  buildPlayer();buildEnemy(E);
  hideMenu();
  // state
  GM.on=true;GM.over=false;GM.paused=false;GM.started=false;
  GM.maxhp=100*(GM.style.hpMul||1);
  if(!keepHp||GM.hp<=0)GM.hp=GM.maxhp;
  GM.kmax=E.hp;GM.khp=E.hp;GM.special=0;GM.combo=0;GM.round=0;GM.phaseIdx=0;GM.events=[];GM.shake=0;GM.hitStop=0;GM.rageUntil=0;GM.riposte=false;GM.bastion=false;GM.windUsed=false;GM.staggerUntil=0;GM.guardBreak=0;GM.focusUntil=0;GM._fReady=0;GM.pStreak=0;GM.counterWin=0;GM.invulnUntil=0;GM.stamina=GM.startFocus||0;GM.tough=!!GM.pendTough;GM.edge=!!GM.pendEdge;GM.pendTough=GM.pendEdge=false;
  if(!keepHp){GM.score=0;GM.maxCombo=0;GM.nP=GM.nG=GM.nM=0}
  GM.rng=mulberry(GM.mode==='daily'?hashStr(today()):(Date.now()&0xffffff));
  GM.bpm=E.bpm;
  $('nmG').textContent=E.name.toUpperCase();$('nmK').textContent=(GM.style.name||'KNIGHT').toUpperCase();
  $('gMode').textContent=GM.mode==='survival'?'Wave '+(GM.wave+1):GM.mode==='rush'?'Boss '+(idx+1)+'/'+ROSTER.length:GM.mode==='daily'?'Daily':GM.mode==='training'?'Training':'Duel '+(idx+1)+'/'+ROSTER.length;
  stains.innerHTML='';resetFx();applyTonics();
  KP=mkP(PZ.kIdle);GP=mkP(PZ.gIdle);
  GL2.classList.add('on');DOCK2.classList.add('on');
  st.playing=false;seek(0);$('hud').style.display='none';$('chap').style.display='none';
  $('fd').setAttribute('opacity',0);['t1','t2','t3'].forEach(i=>$(i).setAttribute('opacity',0));
  updHud2();audioInit();if(AC)AC.resume();setSound(true);applySettings();
  taunt(E.intro||'');
  const pr=$('gPrompt');pr.textContent=E.name;pr.style.opacity=.95;
  GM.t0=gnow()+.3;GM.t=-.3;drumNext2=gnow()+.3;drumStep2=0;
  setTimeout(()=>{pr.style.opacity=0;GM.started=true;GM.t0=gnow()+BEATS()*2.5;GM.t=-BEATS()*2.5;drumNext2=gnow();drumStep2=0;
    setP(KP,PZ.kGuard,6);startRound2()},1700);
}

/* ---------- end of fight ---------- */
function end2(win){
  if(GM.over)return;GM.over=true;GM.won=win;GM.endAt=performance.now();
  DOCK2.querySelectorAll('#gPads,#gDef').forEach(e=>e.style.display='none');
  const E=GM.enemy;
  if(win){
    setP(GP,PZ.gDead,3);setP(KP,PZ.kSlash,6);
    bloodBurst(790,500,[0,60,140,200][SET.blood],1,1.5);bloodBurst(790,500,[0,24,60,90][SET.blood],-1,.9);if(SET.blood)stain(860,722,110);
    sfxSlash(1.3);shake2(2.2);flashScreen('#fff',.25);setTimeout(sfxBell,900);GM.slow=1;
  }else{
    setP(KP,PZ.kDead,2.4);setP(GP,PZ.gWin,3);
    bloodBurst(620,560,[0,60,140,200][SET.blood],-1,1.5);if(SET.blood)stain(560,725,100);sfxSlash(1.3);shake2(2.2);setTimeout(sfxBell,900);
  }
  setTimeout(()=>showEnd(win),2400);
}
function showEnd(win){
  const E=GM.enemy,mode=GM.mode;
  let title,sub,btns='',extra='';
  const gold=win?Math.round((E.reward||50)*(1+GM.maxCombo/60)):0;
  if(win){SAVE.gold+=gold;SAVE.kills++;if(mode==='duel'&&!SAVE.beat.includes(E.id))SAVE.beat.push(E.id)}
  if(win&&mode==='survival'){GM.wave++;GM.hp=Math.min(GM.maxhp,GM.hp+22);if(GM.wave>SAVE.best.survival)SAVE.best.survival=GM.wave}
  if(mode==='daily'&&GM.score>(SAVE.best.daily[today()]||0))SAVE.best.daily[today()]=GM.score;
  // unlock styles
  STYLES.forEach(s=>{if(s.unlock&&!SAVE.unlocked[s.id]&&SAVE.gold>=s.unlock){SAVE.unlocked[s.id]=true;extra+=`<p class="mini" style="color:#d9b45a">Style unlocked: ${s.name}</p>`}});
  saveGame();
  if(win){
    const last=mode==='duel'&&GM.enemyIdx>=ROSTER.length-1;
    if(mode==='survival'){title='Wave '+GM.wave+' cleared';sub='Another comes';btns=`<button class="pill" id="eNext">Next wave</button>`}
    else if(mode==='rush'){const nx=GM.enemyIdx+1;if(nx>=ROSTER.length){title='The Rush is over';sub='Every champion lies dead';SAVE.best.rush=Math.max(SAVE.best.rush,GM.score);saveGame();btns=''}else{title=E.name+' falls';sub='Next: '+ROSTER[nx].name;btns=`<button class="pill" id="eNext">Onward</button>`}}
    else if(last){title='The King Falls';sub='Trial by combat won';btns=''}
    else if(mode==='duel'){title=E.name+' falls';sub='Next: '+ROSTER[GM.enemyIdx+1].name;btns=`<button class="pill" id="eNext">Next champion</button>`}
    else{title='Victory';sub=mode==='daily'?'Daily complete':'';btns=''}
  }else{
    title='Justice Is Served';sub='You have been judged';
    if(mode==='survival'){sub='You fell on wave '+(GM.wave+1)}
    btns=`<button class="pill" id="eRetry">${mode==='survival'?'Begin again':'Fight again'}</button>`;
  }
  showMenu(`<p class="kick">${sub}</p><h2>${title}</h2>
   <div class="stats"><div>Score<b>${GM.score}</b></div><div>Best combo<b>${GM.maxCombo}</b></div><div>Perfect<b>${GM.nP}</b></div><div>Gold<b>+${gold}</b></div></div>${extra}
   <div class="row">${btns}<button class="pill" id="eShop">Tonics</button><button class="pill" id="eMenu">Main menu</button></div>`);
  $('eShop').onclick=e=>{e.stopPropagation();shopMenu(()=>showEnd(win))};
  const nx=$('eNext');if(nx)nx.onclick=e=>{e.stopPropagation();
    if(GM.mode==='survival')beginFight(0,true);else beginFight(GM.enemyIdx+1,GM.mode==='rush')};
  const rt=$('eRetry');if(rt)rt.onclick=e=>{e.stopPropagation();if(GM.mode==='survival'){GM.wave=0;GM.score=0}GM.hp=GM.maxhp;beginFight(GM.mode==='duel'||GM.mode==='rush'?GM.enemyIdx:0)};
  $('eMenu').onclick=e=>{e.stopPropagation();mainMenu()};
}

/* ---------- pause ---------- */
function pauseGame(){
  if(!GM.on||!GM.started||GM.over||GM.paused)return;
  GM.paused=true;GM._pauseAt=gnow();if(AC)AC.suspend();
  showMenu(`<p class="kick">Paused</p><h2>The blades wait</h2><div class="row"><button class="pill" id="pResume">Resume</button><button class="pill" id="pSet">Settings</button><button class="pill" id="pQuit">Quit to menu</button></div>`);
  $('pResume').onclick=e=>{e.stopPropagation();resumeGame()};
  $('pSet').onclick=e=>{e.stopPropagation();settingsMenu(()=>{pauseGame2()})};
  $('pQuit').onclick=e=>{e.stopPropagation();GM.paused=false;GM.over=true;if(AC)AC.resume();mainMenu()};
}
function pauseGame2(){showMenu(`<p class="kick">Paused</p><h2>The blades wait</h2><div class="row"><button class="pill" id="pResume">Resume</button><button class="pill" id="pSet">Settings</button><button class="pill" id="pQuit">Quit to menu</button></div>`);
  $('pResume').onclick=e=>{e.stopPropagation();resumeGame()};$('pSet').onclick=e=>{e.stopPropagation();settingsMenu(pauseGame2)};$('pQuit').onclick=e=>{e.stopPropagation();GM.paused=false;GM.over=true;if(AC)AC.resume();mainMenu()}}
function resumeGame(){
  hideMenu();
  const go=()=>{ // shift the audio-clock origin by the paused duration so the beat grid is preserved
    const gap=gnow()-GM._pauseAt;GM.t0+=gap;drumNext2+=gap;GM.paused=false};
  if(AC){AC.resume().then(go)}else go();
}
$('gPause').addEventListener('pointerdown',e=>{e.preventDefault();e.stopPropagation();pauseGame()});
document.addEventListener('visibilitychange',()=>{if(document.hidden)pauseGame()});

function stopGame2(){GM.on=false;GL2.classList.remove('on');DOCK2.classList.remove('on');hideMenu();$('hud').style.display='';$('chap').style.display='';gctx.clearRect(0,0,CW,CH)}

/* ---------- keyboard + touch bindings ---------- */
addEventListener('keydown',e=>{
  if(!GM.on||e.repeat)return;
  const k=e.key.toLowerCase();
  if(k==='escape'||k==='p'){e.preventDefault();GM.paused?resumeGame():pauseGame();return}
  if(k==='q'||k==='e'||e.key==='Shift'){e.preventDefault();useFocus();return}
  if(k==='h'){e.preventDefault();drinkPotion();return}
  if(!GM.started||GM.over||GM.paused)return;
  if(GM.roundType==='attack'){
    if(k==='a'||e.code==='ArrowLeft'){e.preventDefault();input2('lane',0)}
    else if(k==='w'||e.code==='ArrowUp'||e.code==='Space'){e.preventDefault();input2('lane',1)}
    else if(k==='d'||e.code==='ArrowRight'){e.preventDefault();input2('lane',2)}
    else if(k==='s'||e.code==='ArrowDown'){e.preventDefault();input2('lane',1)}
  }else{
    if(e.code==='Space'||k==='enter'||k==='f'){e.preventDefault();input2('parry')}
    else if(k==='s'||e.code==='ArrowDown'){e.preventDefault();input2('duck')}
    else if(k==='w'||e.code==='ArrowUp'){e.preventDefault();input2('jump')}
    else if(k==='a'||e.code==='ArrowLeft'){e.preventDefault();input2('dodge')}
    else if(k==='d'||e.code==='ArrowRight'){e.preventDefault();input2('parry')}
  }
},true);
DOCK2.querySelectorAll('#gPads button').forEach(b=>b.addEventListener('pointerdown',e=>{e.preventDefault();e.stopPropagation();input2('lane',+b.dataset.l)}));
DOCK2.querySelectorAll('#gDef button').forEach(b=>b.addEventListener('pointerdown',e=>{e.preventDefault();e.stopPropagation();input2(b.dataset.k)}));
$('gFocus').addEventListener('pointerdown',e=>{e.preventDefault();e.stopPropagation();useFocus()});
$('gPot').addEventListener('pointerdown',e=>{e.preventDefault();e.stopPropagation();drinkPotion()});
$('stage').addEventListener('pointerdown',e=>{if(!GM.on||!GM.started||GM.over||GM.paused||GM.roundType!=='defend')return;if(e.target.closest('#gMenu,#gHud'))return;input2('parry')});

/* ---------- drums (reuses v1 drum voices, scheduled from GM clock) ---------- */
let drumNext2=0,drumStep2=0;
function schedDrums2(){
  if(!AC||!GM.started)return;
  const B=BEATS(),ahead=gnow()+.25;
  while(drumNext2<ahead){
    const s=drumStep2%8,tt=Math.max(drumNext2,gnow()),m=window.__music||{};
    if(s===0||s===4)drum(tt,'kick');
    if(s===2||s===6)drum(tt,'tom');
    if(s%2===1)drum(tt,'tick');
    if(s===5&&GM.round>3)drum(tt,'kick');
    if(s===0&&drumStep2%32===0)bassNote(tt,m);
    drumNext2+=B/2;drumStep2++;
  }
}
const SCALES={minor:[0,2,3,5,7,8,10],phrygian:[0,1,3,5,7,8,10],dorian:[0,2,3,5,7,9,10]};
function bassNote(time,m){
  if(!sndOn||!AC)return;const root=m.root||48,sc=SCALES[m.scale]||SCALES.minor;
  const deg=[0,0,3,5,0,4,3,1][Math.floor(drumStep2/32)%8];const f=440*Math.pow(2,((root+sc[deg%7])-69)/12);
  const o=AC.createOscillator(),g=AC.createGain(),lp=AC.createBiquadFilter();o.type='sawtooth';o.frequency.value=f;lp.type='lowpass';lp.frequency.value=260;
  const B=BEATS()*4;g.gain.setValueAtTime(.0001,time);g.gain.exponentialRampToValueAtTime(.16*SET.music,time+.2);g.gain.exponentialRampToValueAtTime(.0001,time+B);
  o.connect(lp);lp.connect(g);out(g,.3);o.start(time);o.stop(time+B+.1);
}

// expose a tiny test hook (used by headless verification; harmless otherwise)
window.__kj={chip,drinkPotion,GM,useFocus,input2,beginFight,mainMenu,pickStart,SET,SAVE,ROSTER,STYLES,ARENA_ALL,loadArena,st,seek,render:(t)=>{seek(t);render(t,0)},begin,DUR,play,pause};

// first paint (title card is behind the start overlay)
fit();render(0,0);
requestAnimationFrame(loop);
const go=document.querySelector('#start .go');go.textContent='Preparing…';
Promise.all([bakeLayer('L_bg'),bakeLayer('L_cl'),bakeLayer('L_gnd'),bakeLayer('L_fg')]).then(()=>{
  go.textContent='Watch';window.__kjReady=true;render(0,0);if(wantStart)begin();if(window.__wantPlay)openGame();
});
})();