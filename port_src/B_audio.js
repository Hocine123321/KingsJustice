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