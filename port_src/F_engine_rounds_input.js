/* ===================================================================
   PLAY v2 - round generation, input judging, enemy behaviours, modes
   =================================================================== */

/* ---------- windows (seconds), scaled by style + difficulty ---------- */
function windows(){
  const S=GM.style||{windows:{perfect:.06,good:.115,miss:.17}},D=DIFF[SET.difficulty]||DIFF.normal;
  const w=S.windows,k=.8,f=(GM.focusUntil>GM.t)?1.5:1;return{perfect:w.perfect*k*D.win*f,good:w.good*k*D.win*f,miss:w.miss*k*D.win*f+.01}
}

/* ---------- round -> event list ----------
   event: {time, kind, input, lane, flag, state, tellDone, hit2, id, dmg, group}  */
function buildRound(){
  const E=GM.enemy,rng=GM.rng,B=BEATS();
  let pool,type;
  // alternate: defend, attack. Enrage phases may swap pools.
  type=GM.round%2===0?'defend':'attack';
  GM.roundType=type;
  const ph=null,phN=E.phases?E.phases.filter(p=>GM.khp/GM.kmax<=p.at).length:0;
  const key=type==='defend'?'defendPatterns':'attackPatterns';
  let list=E[key];
  if(ph&&ph.newPatternPool&&E[ph.newPatternPool+(type==='defend'?'D':'A')])list=E[ph.newPatternPool+(type==='defend'?'D':'A')];
  // later rounds prefer later (harder) patterns in the list
  const prog=clamp(GM.round/16+phN*.2,0,1);
  let idx=Math.min(list.length-1,Math.floor((rng()*.5+prog*.6)*list.length));
  if(GM.round<2)idx=Math.min(idx,1);
  if(GM.round<2&&(GM.mode==='duel'||GM.mode==='rush')&&GM.enemyIdx>0)idx=Math.min(idx,2)
  const pat=list[idx];
  const lead=type==='attack'?1:0;
  const base=Math.ceil((GM.t+.15)/B)*B+lead*B;
  const evs=[];let gid=0;
  for(const raw of pat){
    if(type==='defend'){
      const[b,kind]=raw;const M=MOVES[kind]||MOVES.slash;
      const push=(bb,k,extra)=>evs.push(Object.assign({time:base+bb*B,kind:k,input:M.input,lane:-1,flag:null,state:'live',tellDone:false,id:evs.length,group:gid,dmg:M.dmg,tell:M.tellBeats*B,pose:M.pose},extra||{}));
      if(kind==='double'){push(b,'slash',{dmg:M.dmg});push(b+.5,'slash',{dmg:M.dmg,tell:B*.5})}
      else if(kind==='triple'){push(b,'slash');push(b+.33,'slash',{tell:B*.33});push(b+.66,'slash',{tell:B*.33})}
      else if(kind==='sweep_combo'){push(b,'low',{input:'duck',pose:'low'});push(b+1,'high',{input:'jump',pose:'high',tell:B*.8})}
      else if(kind==='feint'){push(b+.5,'slash',{feint:true,feintAt:base+b*B,tell:B*1.1})}
      else if(kind==='grab'){push(b,'grab',{input:'grab'})}
      else push(b,kind);
      gid++;
    }else{
      const[b,lane,flag]=raw;
      evs.push({time:base+b*B,kind:'note',input:'lane',lane,flag:flag||null,state:'live',id:evs.length,group:gid++,armorHit:0,orig:lane});
      if(flag==='A')evs.push({time:base+(b+.25)*B,kind:'note',input:'lane',lane,flag:'A2',state:'live',id:evs.length,group:gid++,armorHit:0,orig:lane,dep:evs.length-1});
    }
  }
  evs.sort((a,b)=>a.time-b.time);
  if(GM.staggerUntil>GM.t||GM.guardBreak>GM.t)evs.forEach(e=>{if(e.flag==='P'||e.flag==='BH'||e.flag==='BL')e.flag=null});
  for(const ev of evs){const k=ev.kind==='note'?(ev.flag&&ev.flag!=='A2'?'note:'+ev.flag:null):ev.kind;if(k&&TIPS[k]&&!SAVE.seen[k]){setTimeout(()=>showTip(k),type==='defend'?250:150);break}}
  GM.events=evs;
  const last=evs.length?evs[evs.length-1].time:base;
  GM.roundEnd=last+B*1.1;
  GM.roundStart=base;
}

/* ---------- start / next round ---------- */
function startRound2(){
  buildRound();
  const t=GM.roundType;
  // prompt
  const pr=$('gPrompt');pr.textContent=(t==='defend'?'Defend':'Strike')+(GM.stamina>=100&&!isTouch?'  ·  Q focus':'');pr.style.opacity=.9;clearTimeout(pr._t);pr._t=setTimeout(()=>pr.style.opacity=0,1100);
  if(t==='attack'){setP(KP,PZ.kWind,6);setP(GP,GM.enemy.look.shield?PZ.gBlockH:PZ.gIdle,8)}
  else{setP(KP,PZ.kGuard,8);setP(GP,PZ.gIdle,8)}
  updHud2();
  // touch controls reflect round type
  const touch=isTouch||SET.forceTouch;
  $('gPads').style.display=t==='attack'&&touch?'flex':'none';
  $('gDef').style.display=t==='defend'&&touch?'block':'none';
  $('gFocus').style.display=touch?'flex':'none';$('gPot').style.display=touch&&GM.potion?'flex':'none';
  GM.round++;
}

/* ---------- INPUT ----------
   kinds: 'parry' (space/tap), 'duck' (S/down), 'jump' (W/up), 'dodge' (A/left), 'lane0/1/2' */
function input2(kind,lane){
  if(!GM.on||!GM.started||GM.over||GM.paused)return;
  const W=windows(),now=GM.t+SET.offset/1000;
  flashBtn(kind,lane);
  if(GM.roundType==='attack'){
    if(kind!=='lane')return;
    // nearest live note in this lane
    let best=null,bd=9;
    for(const e of GM.events){if(e.state!=='live'||e.kind!=='note'||e.lane!==lane)continue;const d=Math.abs(e.time-now);if(d<bd){bd=d;best=e}}
    if(!best||bd>W.miss+.05){ // whiff: swing at air, lose combo, drains stamina
      GM.combo=0;
      setP(KP,[PZ.kSlash,PZ.kThrust,PZ.kOver][lane],20);setTimeout(()=>GM.roundType==='attack'&&setP(KP,PZ.kWind,10),130);sfxWhoosh();updHud2();return;
    }
    const grade=bd<=W.perfect?'perfect':bd<=W.good?'good':'late';
    resolveNote(best,grade);return;
  }
  // DEFEND: pick nearest live defend event
  let best=null,bd=9;
  for(const e of GM.events){if(e.state!=='live')continue;const d=Math.abs(e.time-now);if(d<bd){bd=d;best=e}}
  if(!best||bd>W.miss+.08){ // nothing to react to: panic press
    if(GM.training)return;
    return;
  }
  // feint punish: pressing before the feint "tell reversal" window costs you
  if(best.feint&&now<best.feintAt+.02&&!best.feintOk){best.feintBit=1;say('Fooled','#c9a46a');GM.combo=0;chip(4);return}
  const grade=bd<=W.perfect?'perfect':bd<=W.good?'good':'late';
  const need=best.input;
  // input matching
  let ok=false;
  if(need==='parry')ok=(kind==='parry');
  else if(need==='duck')ok=(kind==='duck');
  else if(need==='jump')ok=(kind==='jump');
  else if(need==='dodge')ok=(kind==='dodge');
  else if(need==='grab'){ // need two different presses within 0.18s
    best._g=best._g||{};best._g[kind]=now;
    const ks=Object.keys(best._g);ok=ks.length>=2&&Math.abs(best._g[ks[0]]-best._g[ks[1]])<.22;
    if(!ok){flashBtn(kind);return}
  }
  if(!ok){
    // wrong input: unblockable cannot be parried; wrong dodge still hurts
    if(need==='dodge'&&kind==='parry'){best.state='broken';say('Unblockable!','#ff5a3a');hitPlayer(best,1.0);return}
    if(need!=='parry'&&kind==='parry'){best.state='hit-wrong';say('Wrong guard','#c9a46a');hitPlayer(best,.8);return}
    return; // ignore stray key, maybe the right one follows
  }
  resolveDefend(best,grade);
}

/* ---------- judge ---------- */
function say(txt,col){const j=$('gJudge');j.textContent=txt;j.style.color=col;j.style.opacity=1;j._t=performance.now()}
function lenFactor(){const i=GM.mode==='duel'||GM.mode==='rush'?GM.enemyIdx:Math.min(5,GM.wave||0);return [1,.9,.8,.7,.6,.52,.42][Math.min(6,i)]||1}
function earlyEase(){const i=GM.mode==='duel'||GM.mode==='rush'?GM.enemyIdx:Math.min(4,GM.wave);return [.6,.68,.74,.8,.85,.9,.92][Math.min(6,i)]||1}
function chip(n){
  if(GM.invulnUntil>GM.t)return;
  GM.hp-=n*(DIFF[SET.difficulty]||DIFF.normal).take*(GM.style.takeMul||1)*earlyEase()*(GM.tough?.8:1);
  if(GM.hp<=0){
    if(!GM.windUsed){GM.windUsed=true;GM.hp=Math.round(GM.maxhp*.25);GM.invulnUntil=GM.t+BEATS()*2;GM.stamina=100;GM._fReady=1;say('SECOND WIND','#ffe08a');taunt('Not yet.');flashScreen('#ffd070',.35);shake2(1)}
    else{updHud2();end2(false);return}
  }
  updHud2();
}
function useFocus(){
  if(!GM.on||!GM.started||GM.over||GM.paused)return;
  if(GM.stamina<100||GM.focusUntil>GM.t)return;
  GM.focusUntil=GM.t+3.5;GM._fReady=0;say('FOCUS','#9fd0ff');flashScreen('#6fa8ff',.22);
}
function gainFocus(n){if(GM.focusUntil>GM.t)return;GM.stamina=Math.min(100,GM.stamina+n);if(GM.stamina>=100&&!GM._fReady){GM._fReady=1;say('Focus ready','#9fd0ff')}}
function addScore2(p){GM.combo++;gainFocus(p>=300?5:3);GM.maxCombo=Math.max(GM.maxCombo,GM.combo);GM.score+=Math.round(p*(1+Math.min(GM.combo,40)*.08)*(GM.rageUntil>GM.t?2:1));
  // special charge
  const S=GM.style.special;if(S){if(S.charge==='combo')GM.special=Math.min(S.need,GM.combo);}
  if(S&&S.id==='rage'&&GM.special>=S.need&&GM.rageUntil<GM.t){GM.rageUntil=GM.t+6;GM.special=0;say('RAGE','#ff4a3a');shake2(1.2)}}

function resolveDefend(e,grade){
  e.state='done';const perfect=grade==='perfect',late=grade==='late';
  const M=MOVES[e.kind]||MOVES.slash;
  if(late){say('Scraped','#c9a46a');GM.combo=0;chip(Math.max(2,e.dmg*.35));spark(660,440,12);sfxClang(.6);setP(KP,PZ.kParry,22);shake2(.5)}
  else{
    say(perfect?(e.input==='parry'?'Perfect parry':'Perfect'):'Good',perfect?'#e8f2ff':'#c8d4e0');
    if(perfect)GM.nP++;else GM.nG++;
    addScore2(perfect?300:150);
    {const S=GM.style.special;if(S&&S.charge==='perfect'&&perfect){GM.special=Math.min(S.need,GM.special+1);
      if(S.id==='bastion'&&GM.special>=S.need&&!GM.bastion){GM.bastion=true;say('Bastion ready','#ffe08a')}}}
    if(e.input==='parry'){
      spark(650,430,perfect?36:22);sfxClang(perfect?1.2:.9);shake2(perfect?.8:.5);
      setP(KP,PZ.kParry,26);setP(GP,PZ.gParried,26);GM.hitStop=perfect?.09:.05;
      damageEnemy((perfect?2.2:1.2)*lenFactor()*GM.kmax/100*(1+(GM.style.parryBonus||0)));
      if(perfect){GM.pStreak=(GM.pStreak||0)+1;GM.hp=Math.min(GM.maxhp,GM.hp+1);if(GM.pStreak>=3){GM.pStreak=0;GM.counterWin=GM.t+BEATS()*10;say('Counter window','#ffd070');taunt('You read him.')}}else GM.pStreak=0;
      if(perfect&&GM.style.special&&GM.style.special.id==='riposte'){GM.riposte=true;say('Riposte ready','#ffe08a')}
    }else{ // duck/jump/dodge successes
      sfxWhoosh();setP(KP,e.input==='duck'?PZ.kDuck:e.input==='jump'?PZ.kJump:PZ.kDodge,24);
      if(perfect)spark(560,520,10);
      damageEnemy(1.0*lenFactor()*GM.kmax/100);
    }
    // unblockable / grab successes stun the enemy a beat
    if(e.input==='dodge'||e.input==='grab'||e.kind==='triple'||e.kind==='sweep_combo'){GM.staggerUntil=GM.t+BEATS()*8;say('Opening!','#ffd070')}
    if(e.input==='dodge'||e.input==='grab'){GM.stunUntil=GM.t+BEATS()*.8;setP(GP,PZ.gStun,18);damageEnemy(1.4*GM.kmax/100)}
  }
  setTimeout(()=>{if(!GM.over&&GM.roundType==='defend'){setP(KP,PZ.kGuard,10);setP(GP,PZ.gIdle,10)}},200);
  updHud2();
}
function hitPlayer(e,k=1){
  GM.pStreak=0;
  e.state=e.state==='live'?'miss':e.state;
  if(GM.bastion){GM.bastion=false;GM.special=0;say('Bastion holds','#ffe08a');sfxClang(1.2);spark(600,500,30);shake2(.6);updHud2();return}
  GM.combo=0;
  const dmg=(e.dmg||12)*k*(DIFF[SET.difficulty]||DIFF.normal).enemyDmg*(GM.enemy.dmgMul||1);
  setP(GP,PZ[(e.pose==='low'?'gStrikeL':'gStrike')]||PZ.gStrike,30);setP(KP,PZ.kHurt,26);
  bloodBurst(600,540,[0,30,60,90][SET.blood]||60,-1,1);if(SET.blood>0)stain(520+Math.random()*80,724,40);
  sfxSlash(.9);shake2(1.4);GM.hitStop=.08;vibrate(40);
  GM._flashHurt=.6;setTimeout(()=>GM._flashHurt=0,420);
  say('Struck','#c23a2a');
  chip(dmg);
  setTimeout(()=>{if(!GM.over&&GM.roundType==='defend'){setP(KP,PZ.kGuard,8);setP(GP,PZ.gIdle,8)}},260);
}
function missDefend(e){hitPlayer(e,1)}

/* ---------- attack notes ---------- */
function resolveNote(n,grade){
  const perfect=grade==='perfect',good=grade==='good';
  const S=GM.style,E=GM.enemy;
  // flags
  let dmg=(perfect?3.7:good?2.7:1.3)*GM.kmax/100*lenFactor()*(S.dmgMul||1)*(GM.dmgScale||1);
  let msg=perfect?'Perfect':good?'Good':'Glancing',col=perfect?'#ffe08a':good?'#cdbfa6':'#9a8f7c';
  {let m=1+Math.min(.6,Math.floor(GM.combo/8)*.1);
   if(GM.counterWin>GM.t)m*=1.6;
   if(GM.staggerUntil>GM.t)m*=1.25;
   if(GM.guardBreak>GM.t)m*=1.25;
   if(GM.edge)m*=1.2;
   dmg*=Math.min(m,2.0)}
  if(GM.riposte){dmg*=2;GM.riposte=false;msg='Riposte!'}
  if(GM.rageUntil>GM.t)dmg*=2;
  n.state='hit';
  if(n.flag==='P'){ // enemy parries
    if(perfect){msg='Guard broken!';col='#ff9a5a';dmg*=1.4;GM.guardBreak=GM.t+BEATS()*3;say('Guard broken! Strike!','#ff9a5a');setP(GP,PZ.gStun,20);sfxClang(1.2);spark(710,430,40)}
    else{msg='Parried';col='#8fb0d0';dmg*=.15;GM.combo=0;setP(GP,PZ.gBlockH,26);sfxClang(.8);spark(710,430,16);}
  }else if(n.flag==='BH'&&n.lane===2){dmg*=.2;msg='Blocked high';col='#8fb0d0';GM.combo=0;setP(GP,PZ.gBlockH,26);sfxClang(.7)}
  else if(n.flag==='BL'&&n.lane===0){dmg*=.2;msg='Blocked low';col='#8fb0d0';GM.combo=0;setP(GP,PZ.gBlockL,26);sfxClang(.7)}
  else if(n.flag==='C'){ // counter: enemy ripostes next beat
    msg='Countered';col='#ff7a5a';GM.combo=0;
    GM.events.push({time:GM.t+BEATS()*.9,kind:'slash',input:'parry',lane:-1,flag:null,state:'live',tellDone:false,id:GM.events.length,group:99,dmg:10,tell:BEATS()*.8,pose:'wind',counter:true});
    GM.events.sort((a,b)=>a.time-b.time);GM.roundEnd=Math.max(GM.roundEnd,GM.t+BEATS()*3)
  }
  if(n.flag==='A'){n.state='live';n.flag='Ah';dmg*=.4;n.time+=BEATS()*0;msg='Armor cracked';col='#c8d4e0';sfxClang(.8);spark(700,440,10);damageEnemy(dmg);updHud2();GM.combo++;return}
  if(n.flag==='A2'){msg=perfect?'Armor broken!':'Cracked';dmg*=1.6}
  say(msg,col);
  if(perfect)GM.nP++;else if(good)GM.nG++;
  if(n.flag!=='P'||perfect){addScore2(perfect?300:good?150:60)}
  damageEnemy(dmg);
  const P=[PZ.kSlash,PZ.kThrust,PZ.kOver][n.lane];
  setP(KP,P,28);setTimeout(()=>GM.roundType==='attack'&&setP(KP,PZ.kWind,10),140);
  if(!n.flag||n.flag==='A2'||(n.flag==='P'&&perfect)){setP(GP,PZ.gHurt,24);setTimeout(()=>!GM.over&&setP(GP,GM.enemy.look.shield?PZ.gBlockH:PZ.gIdle,9),170);
    spark(720,430,perfect?30:16);bloodBurst(760,470,[0,perfect?14:8,perfect?34:18,perfect?50:26][SET.blood],1,perfect?.9:.6);if(perfect&&SET.blood>0)stain(800+Math.random()*80,722,34+Math.random()*30);
    sfxSlash(perfect?.8:.5)}
  shake2(perfect?1.1:.6);GM.hitStop=perfect?.07:.04;vibrate(perfect?25:12);
  updHud2();
}
function missNote(n){
  n.state='miss';GM.combo=0;GM.nM++;say('Missed','#8a7f6a');
  updHud2();
}
function damageEnemy(d){
  if(GM.training)return;
  GM.khp-=d;
  if(GM.khp<=0)end2(true);
}

/* ---------- per-frame ---------- */
function tick2(dtReal){
  if(!GM.on)return;
  if(!GM.started)return;
  if(GM.paused){return}
  let dt=dtReal;if(GM.hitStop>0){GM.hitStop-=dtReal;dt=dtReal*.08}
  GM.t=gnow()-GM.t0;
  schedDrums2();
  const B=BEATS(),W=windows();
  if(!GM.over){
    for(const e of GM.events){
      if(e.state!=='live')continue;
      const dtN=e.time-GM.t;
      if(e.kind!=='note'){
        // telegraph
        if(!e.tellDone&&dtN<(e.tell||B)){
          e.tellDone=true;
          const pz=e.pose==='low'?'gWindL':e.pose==='high'?'gWindH':e.pose==='lunge'?'gLunge':e.pose==='throw'?'gThrow':'gWind';
          setP(GP,PZ[pz],Math.min(14,5+1/Math.max(.2,dtN)*1.2));
          (e.kind==='unblockable'?sfxHeartbeat:sfxWhoosh)();
          if(e.feint)e.feintAt=e.time-B*.5;
        }
        if(e.feint&&GM.t>e.feintAt)e.feintOk=true;
        if(dtN<-W.miss){missDefend(e)}
      }else{
        if(e.flag==='S+'||e.flag==='S-'){ if(!e._sh&&dtN<B*.35){e._sh=1;e.lane=clamp(e.lane+(e.flag==='S+'?1:-1),0,2);e.shifted=true} }
        if(dtN<-W.miss){ if(e.flag==='Ah'){e.state='done'}else missNote(e) }
      }
    }
    // stamina regen

    if(GM.focusUntil&&GM.t>GM.focusUntil){GM.focusUntil=0;GM.stamina=0;GM._fReady=0;say('Focus fades','#6a8aa8')}
    // round end
    if(GM.t>GM.roundEnd){ if(GM.hp>0&&GM.khp>0){maybePhase();startRound2()} }
  }
  // tempo ramps as enemy weakens; difficulty scales
  const D=DIFF[SET.difficulty]||DIFF.normal;
  const frac=1-clamp(GM.khp/GM.kmax,0,1);
  const ph=GM.enemy.phases?GM.enemy.phases.filter(p=>GM.khp/GM.kmax<=p.at):[];
  const add=ph.reduce((a,p)=>a+(p.bpmAdd||0),0);
  GM.bpm=(GM.enemy.bpm+frac*10+add)*D.tempo;
  stepP(KP,dt);stepP(GP,dt);
  GM.shake*=Math.exp(-dtReal*7);
  const j=$('gJudge');if(+j.style.opacity>0){const age=(performance.now()-(j._t||0))/1000;j.style.opacity=Math.max(0,1-age*1.8).toFixed(2);j.style.transform=`scale(${1+Math.max(0,.25-age)*1.2})`}
}
function maybePhase(){
  const E=GM.enemy;if(!E.phases)return;
  for(let i=0;i<E.phases.length;i++){const p=E.phases[i];
    if(GM.khp/GM.kmax<=p.at&&GM.phaseIdx<=i){GM.phaseIdx=i+1;if(p.line)taunt(p.line);shake2(1.2);sfxHeartbeat();flashScreen('#a00',.35)}}
}

/* ===================================================================
   UI v2 - menus, HUD, settings, renderer for notes/rings, modes, end screens
   =================================================================== */
const GL2=document.createElement('div');GL2.id='gameUI';
GL2.innerHTML=`
<div id="gHud">
  <div class="bars">
    <div class="bar kn"><span id="nmK">KNIGHT</span><i><b id="hpK"></b></i><i class="st"><b id="stK"></b></i><small id="swK"></small></div>
    <div class="bar kg"><span id="nmG">THE KING</span><i><b id="hpG"></b></i></div>
  </div>
  <div id="gScore"><em id="gCombo"></em><strong id="gPts">0</strong><small id="gMode"></small></div>
  <button id="gPause" aria-label="Pause">II</button>
</div>
<canvas id="gCv"></canvas>
<div id="gJudge"></div>
<div id="gPrompt"></div>
<div id="gTaunt"></div>
<div id="gSpecial"><i><b id="spB"></b></i><span id="spT"></span></div>
`;
$('stage').appendChild(GL2);

const DOCK2=document.createElement('div');DOCK2.id='gDock';
DOCK2.innerHTML=`
<div id="gPads"><button data-l="0"><i>Slash</i></button><button data-l="1"><i>Thrust</i></button><button data-l="2"><i>Over</i></button></div>
<div id="gDef">
  <div class="zl"><button data-k="jump"><i>Jump</i></button><button data-k="dodge"><i>Dodge</i></button><button data-k="duck"><i>Duck</i></button></div>
  <div class="zr"><button data-k="parry" class="big"><i>Parry</i></button></div>
</div>
<button id="gFocus" aria-label="Focus"><i>Focus</i><u></u></button><button id="gPot" aria-label="Potion"><i>Heal</i></button>`;
$('wrap').appendChild(DOCK2);

/* ---------- menu / settings / pause / end overlays (inside #stage so they scale with it) ---------- */
const MENU=document.createElement('div');MENU.id='gMenu';
$('stage').appendChild(MENU);

const css2=document.createElement('style');css2.textContent=`
#gameUI{position:absolute;inset:0;z-index:6;pointer-events:none;display:none;font-family:Georgia,serif}
#gameUI.on{display:block}
#gHud{position:absolute;top:calc(8% + 8px);left:0;right:0;padding:0 3%;display:flex;justify-content:space-between;align-items:flex-start;gap:10px}
#gHud .bars{display:flex;gap:3%;flex:1}
.bar{flex:1;max-width:38%}
.bar span{display:block;font:600 clamp(8px,1.05vw,11px) system-ui;letter-spacing:.28em;color:#a89c86;margin-bottom:4px;text-shadow:0 0 6px #000;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.bar.kg{text-align:right;margin-left:auto}
.bar i{display:block;height:clamp(6px,1vw,10px);background:rgba(0,0,0,.65);border:1px solid rgba(205,191,166,.3);border-radius:2px;overflow:hidden;margin-bottom:3px}
.bar i.st{height:clamp(3px,.45vw,5px)}
.bar b{display:block;height:100%;width:100%;transition:width .25s}
#hpK{background:linear-gradient(90deg,#6c7f93,#c4d0dc)}
.bar small{display:block;font:600 9px system-ui;letter-spacing:.2em;color:#c9a46a;text-transform:uppercase;margin-top:1px}
#stK{background:linear-gradient(90deg,#8a6a2a,#e0b84a)}
#hpG{background:linear-gradient(90deg,#8a1010,#d03a2a);margin-left:auto}
#gScore{text-align:right;font:600 clamp(9px,1.1vw,12px) system-ui;letter-spacing:.2em;color:#cdbfa6;text-shadow:0 0 8px #000;min-width:84px}
#gScore strong{display:block;font-size:clamp(14px,2.2vw,24px);letter-spacing:.1em}
#gScore em{display:block;font-style:normal;color:#d9b45a;min-height:1.2em}
#gScore small{display:block;font-size:.8em;color:#7d725f;letter-spacing:.3em;text-transform:uppercase}
#gPause{pointer-events:auto;min-height:0;width:clamp(28px,4vw,40px);height:clamp(28px,4vw,40px);padding:0;border-radius:50%;font-size:12px;letter-spacing:0}
#gCv{position:absolute;inset:0;width:100%;height:100%}
#gJudge{position:absolute;left:0;right:0;top:40%;text-align:center;font:italic clamp(18px,4vw,50px) Georgia,serif;letter-spacing:.12em;opacity:0;text-shadow:0 0 18px currentColor,0 2px 4px #000}
#gPrompt{position:absolute;left:0;right:0;top:calc(8% + 54px);text-align:center;font:600 clamp(10px,1.2vw,13px) system-ui;letter-spacing:.5em;color:#cdbfa6;text-transform:uppercase;text-shadow:0 0 8px #000;opacity:0;transition:opacity .3s}
#gTaunt{position:absolute;left:8%;right:8%;top:24%;text-align:center;font:italic clamp(14px,2.3vw,28px) Georgia,serif;color:#d8c8b0;text-shadow:0 0 14px #000,0 2px 3px #000;opacity:0;transition:opacity .6s;letter-spacing:.06em}
#gSpecial{position:absolute;left:3%;bottom:calc(8% + 8px);width:min(24%,220px);opacity:.9}
#gSpecial i{display:block;height:5px;background:rgba(0,0,0,.6);border:1px solid rgba(205,191,166,.25);border-radius:3px;overflow:hidden}
#gSpecial b{display:block;height:100%;width:0;background:linear-gradient(90deg,#8a4a10,#ffd070)}
#gSpecial span{display:block;font:600 9px system-ui;letter-spacing:.26em;color:#9a8c70;margin-top:4px;text-transform:uppercase}
#gDock{position:fixed;left:0;right:0;bottom:0;top:0;z-index:7;pointer-events:none;display:none}
#gDock.on{display:block}
#gDock button{pointer-events:auto;touch-action:none;-webkit-tap-highlight-color:transparent;font:600 clamp(10px,1.3vw,13px) system-ui;letter-spacing:.18em;text-transform:uppercase;border-radius:16px;background:rgba(14,10,8,.5);backdrop-filter:blur(3px);display:flex;align-items:center;justify-content:center;padding:0;min-height:0;transition:transform .06s,background .06s}
#gDock button i{font-style:normal;pointer-events:none}
#gDock button.hit{background:rgba(150,110,40,.8);transform:scale(.95)}
/* landscape / desktop: big thumb zones in the lower corners, outside the fighters' sight line */
#gPads,#gDef{display:none;position:absolute;bottom:max(14px,env(safe-area-inset-bottom));left:0;right:0;height:min(34vh,200px);padding:0 max(14px,env(safe-area-inset-left))}
#gPads{gap:12px;justify-content:center;align-items:stretch}
#gPads button{flex:1;max-width:240px}
#gDef .zl{position:absolute;left:max(14px,env(safe-area-inset-left));bottom:0;top:0;width:min(46%,420px);display:grid;grid-template-columns:1fr 1fr;grid-template-rows:1fr 1fr;gap:10px}
#gDef .zl button[data-k="jump"]{grid-column:1/-1}
#gDef .zr{position:absolute;right:max(14px,env(safe-area-inset-right));bottom:0;top:0;width:min(40%,360px);display:flex}
#gDef .zr button{flex:1}
#gFocus{position:absolute;right:max(14px,env(safe-area-inset-right));bottom:calc(max(14px,env(safe-area-inset-bottom)) + min(34vh,200px) + 12px);width:clamp(64px,9vw,92px);height:clamp(64px,9vw,92px);border-radius:50%!important;display:none;border:2px solid #4a6a88;color:#9fd0ff;overflow:hidden;position:absolute}
#gFocus u{position:absolute;left:0;right:0;bottom:0;height:0;background:linear-gradient(0deg,rgba(80,150,255,.55),rgba(80,150,255,.15));transition:height .2s;pointer-events:none}
#gPot{position:absolute;right:calc(max(14px,env(safe-area-inset-right)) + clamp(64px,9vw,92px) + 10px);bottom:calc(max(14px,env(safe-area-inset-bottom)) + min(34vh,200px) + 12px);width:clamp(52px,7vw,72px);height:clamp(52px,7vw,72px);border-radius:50%!important;display:none;border:2px solid #4a8a5a;color:#8fd0a0;position:absolute}
#gFocus.ready{border-color:#bfe4ff;box-shadow:0 0 22px rgba(120,190,255,.7);animation:fpulse 1s infinite}
@keyframes fpulse{50%{box-shadow:0 0 34px rgba(160,210,255,.95)}}
#gDock .on-flex{display:flex!important}
#gPads button[data-l="0"]{border:2px solid #d9b45a;color:#f1d98e}
#gPads button[data-l="1"]{border:2px solid #c8d4e0;color:#e3ecf5}
#gPads button[data-l="2"]{border:2px solid #c23a2a;color:#ff9a8a}
#gDef button[data-k="parry"]{border:2px solid #c8d4e0;color:#e3ecf5;font-size:clamp(14px,2vw,20px)}
#gDef button[data-k="dodge"]{border:2px solid #c23a2a;color:#ff9a8a}
#gDef button[data-k="jump"]{border:2px solid #8fc4a0;color:#bfe8cc}
#gDef button[data-k="duck"]{border:2px solid #d9b45a;color:#f1d98e}
/* hide the pause button's reach conflict: top-right, small */
#gPause{pointer-events:auto}
/* PORTRAIT phones: picture on top, controls fill the lower half in the thumb arc */
@media (orientation:portrait) and (max-width:700px){
  #wrap{align-items:flex-start;padding-top:max(5vh,env(safe-area-inset-top))}
  #gPads,#gDef{height:min(44vh,330px);bottom:max(12px,env(safe-area-inset-bottom));padding:0 12px}
  #gPads{gap:8px}
  #gPads button{max-width:none;font-size:15px!important;border-radius:20px}
  #gPads button[data-l="1"]{margin-top:-34px}            /* arc: middle lane sits higher, easier for the thumb to roll */
  #gDef .zl{width:calc(50% - 18px);left:12px;gap:8px}
  #gDef .zr{width:calc(50% - 18px);right:12px}
  #gDef .zr button{border-radius:24px;font-size:18px}
  #gFocus{bottom:calc(max(12px,env(safe-area-inset-bottom)) + min(44vh,330px) + 10px);right:14px;width:68px;height:68px}
  #gPot{bottom:calc(max(12px,env(safe-area-inset-bottom)) + min(44vh,330px) + 14px);right:92px;width:58px;height:58px}
}
/* LANDSCAPE phones: two thumb clusters in the lower corners; centre stays clear for the fight */