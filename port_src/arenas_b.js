window.ARENAS_B = {
  swamp: {
    name: 'Drowned Marsh',
    sub: 'Fog, rot and whispering reeds',
    bg: `<g>
      <defs>
        <linearGradient id="sw_sky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#050e0b"/>
          <stop offset="40%" stop-color="#122920"/>
          <stop offset="75%" stop-color="#1e3a2b"/>
          <stop offset="100%" stop-color="#0e1a13"/>
        </linearGradient>
        <radialGradient id="sw_moon" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="#effae6" stop-opacity="1"/>
          <stop offset="25%" stop-color="#bce3aa" stop-opacity="0.8"/>
          <stop offset="60%" stop-color="#588c52" stop-opacity="0.35"/>
          <stop offset="100%" stop-color="#142e1d" stop-opacity="0"/>
        </radialGradient>
        <linearGradient id="sw_fog" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#51735a" stop-opacity="0"/>
          <stop offset="50%" stop-color="#7fb08a" stop-opacity="0.32"/>
          <stop offset="100%" stop-color="#2d4233" stop-opacity="0"/>
        </linearGradient>
      </defs>
      <rect x="-1200" y="0" width="4000" height="900" fill="url(#sw_sky)"/>
      <circle cx="980" cy="190" r="220" fill="url(#sw_moon)"/>
      <circle cx="980" cy="190" r="55" fill="#f2fce6"/>
      <ellipse cx="980" cy="180" rx="200" ry="24" fill="#122920" opacity="0.7"/>
      <ellipse cx="940" cy="208" rx="160" ry="20" fill="#122920" opacity="0.6"/>
      <path d="M-1200,690 L-1200,560 Q-800,520 -400,550 Q0,570 400,540 Q800,510 1200,540 Q1600,560 2000,530 Q2400,510 2800,550 L2800,690 Z" fill="#0f261c"/>
      <path d="M-1000,600 L-990,530 L-980,600 M-850,590 L-840,510 L-830,590 M-600,580 L-590,500 L-580,580 M-300,590 L-285,490 L-270,590 M0,600 L15,505 L30,600 M350,580 L365,480 L380,580 M700,570 L715,470 L730,570 M1100,580 L1115,485 L1130,580 M1500,590 L1515,490 L1530,590 M1900,570 L1915,480 L1930,570 M2300,580 L2315,500 L2330,580" stroke="#0a1a13" stroke-width="14" stroke-linecap="round"/>
      <rect x="-1200" y="500" width="4000" height="190" fill="url(#sw_fog)"/>
    </g>`,
    cl: `<g filter="url(#b6)">
      <defs>
        <linearGradient id="sw_mish" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="#243d2f" stop-opacity="0"/>
          <stop offset="50%" stop-color="#588c68" stop-opacity="0.45"/>
          <stop offset="100%" stop-color="#243d2f" stop-opacity="0"/>
        </linearGradient>
      </defs>
      <path d="M180,710 L180,550 M230,710 L230,540 M280,710 L280,560 M340,710 L340,550 M390,710 L390,570" stroke="#0e1713" stroke-width="12"/>
      <path d="M160,570 L410,560 M170,600 L380,595 M200,580 L260,575 M300,572 L370,568" stroke="#16241d" stroke-width="9"/>
      <path d="M1150,670 C1180,695 1260,705 1310,670 C1290,650 1220,645 1150,670 Z" fill="#0e1713" stroke="#1f3327" stroke-width="4"/>
      <path d="M1200,645 L1190,600 M1240,650 L1245,590 M1270,655 L1280,605" stroke="#192a20" stroke-width="5"/>
      <path d="M120,700 Q140,530 90,400 Q130,450 170,340 M120,470 Q70,410 30,390 M110,430 Q160,380 220,400" fill="none" stroke="#0b1410" stroke-width="18" stroke-linecap="round"/>
      <path d="M35,390 C30,440 40,480 32,530 M80,410 C75,460 85,500 78,550 M180,360 C185,410 175,460 182,510 M210,400 C205,450 215,490 208,540" stroke="#233d2c" stroke-width="5" fill="none"/>
      <path d="M1450,700 Q1420,510 1480,360 Q1440,420 1390,320 M1450,460 Q1500,400 1540,380 M1460,410 Q1400,360 1350,370" fill="none" stroke="#0b1410" stroke-width="20" stroke-linecap="round"/>
      <path d="M1395,320 C1390,370 1400,420 1392,480 M1480,360 C1485,410 1475,470 1482,520 M1535,380 C1530,430 1540,480 1532,530" stroke="#233d2c" stroke-width="5" fill="none"/>
      <rect x="-1200" y="520" width="4000" height="170" fill="url(#sw_mish)"/>
    </g>`,
    gnd: `<g>
      <defs>
        <linearGradient id="sw_wat" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#162e22"/>
          <stop offset="40%" stop-color="#0b1c13"/>
          <stop offset="100%" stop-color="#050d09"/>
        </linearGradient>
        <linearGradient id="sw_pth" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#382b1d"/>
          <stop offset="50%" stop-color="#241b12"/>
          <stop offset="100%" stop-color="#120e08"/>
        </linearGradient>
        <radialGradient id="sw_refl" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="#a3e39a" stop-opacity="0.45"/>
          <stop offset="50%" stop-color="#55994e" stop-opacity="0.22"/>
          <stop offset="100%" stop-color="#162e22" stop-opacity="0"/>
        </radialGradient>
      </defs>
      <rect x="-1200" y="685" width="4000" height="215" fill="url(#sw_wat)"/>
      <ellipse cx="980" cy="740" rx="260" ry="42" fill="url(#sw_refl)"/>
      <path d="M120,900 L230,695 Q600,685 950,695 Q1300,685 1470,695 L1580,900 Z" fill="url(#sw_pth)" filter="url(#mud)"/>
      <ellipse cx="300" cy="715" rx="100" ry="10" fill="none" stroke="#5d946b" stroke-width="2.5" opacity="0.65"/>
      <ellipse cx="600" cy="710" rx="160" ry="12" fill="none" stroke="#5d946b" stroke-width="2.5" opacity="0.55"/>
      <ellipse cx="1000" cy="712" rx="200" ry="14" fill="none" stroke="#7ebf8e" stroke-width="3" opacity="0.75"/>
      <ellipse cx="1300" cy="718" rx="120" ry="10" fill="none" stroke="#5d946b" stroke-width="2.5" opacity="0.65"/>
      <ellipse cx="520" cy="735" rx="80" ry="14" fill="#1c3b2a" opacity="0.8"/>
      <ellipse cx="520" cy="735" rx="55" ry="9" fill="#71b585" opacity="0.45"/>
      <ellipse cx="900" cy="740" rx="130" ry="18" fill="#1c3b2a" opacity="0.85"/>
      <ellipse cx="900" cy="740" rx="90" ry="11" fill="#8ed19e" opacity="0.5"/>
      <path d="M80,730 L75,660 M85,730 L88,655 M92,730 L98,665 M220,720 L215,650 M225,720 L230,645 M232,720 L238,652 M1080,725 L1075,650 M1088,725 L1092,645 M1380,730 L1375,655 M1388,730 L1392,650" stroke="#314d3a" stroke-width="3.5"/>
      <circle cx="75" cy="660" r="3.5" fill="#4d3522"/><circle cx="88" cy="655" r="3.5" fill="#4d3522"/><circle cx="215" cy="650" r="3.5" fill="#4d3522"/><circle cx="1075" cy="650" r="3.5" fill="#4d3522"/><circle cx="1375" cy="655" r="3.5" fill="#4d3522"/>
    </g>`,
    fg: `<g filter="url(#b9)">
      <path d="M-100,0 L120,0 Q70,300 100,600 Q130,780 -50,900 L-100,900 Z" fill="#030806"/>
      <path d="M1700,0 L1480,0 Q1530,300 1500,600 Q1470,780 1650,900 L1700,900 Z" fill="#030806"/>
      <path d="M20,0 Q10,120 25,220 M60,0 Q75,100 55,180 M110,0 Q90,110 105,190 M1490,0 Q1510,110 1495,200 M1540,0 Q1525,130 1545,230 M1580,0 Q1600,100 1585,180" stroke="#08120d" stroke-width="10" fill="none"/>
      <path d="M-100,900 L300,900 Q130,800 -100,810 Z" fill="#030806"/>
      <path d="M1700,900 L1300,900 Q1470,800 1700,810 Z" fill="#030806"/>
    </g>`,
    light: { ambient: '#07090a', key: '#7fb08a', keyL: { x: 170, y: 400 }, keyR: { x: 1430, y: 400 }, keyOp: .3, fog: '#8fa597', fogOp: .28 },
    weather: { type: 'fireflies', count: 40, color: '#c9e86a', wind: 10 },
    music: { root: 41, scale: 'phrygian', tempo: 78 }
  },
  cliff: {
    name: 'Blood Moon Crag',
    sub: 'Crimson sky, howling wind and razor stone',
    bg: `<g>
      <defs>
        <linearGradient id="cl_sky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#0e0407"/>
          <stop offset="30%" stop-color="#360a13"/>
          <stop offset="65%" stop-color="#5e1422"/>
          <stop offset="100%" stop-color="#2b070d"/>
        </linearGradient>
        <radialGradient id="cl_moon" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="#ff6666" stop-opacity="1"/>
          <stop offset="25%" stop-color="#e62626" stop-opacity="0.95"/>
          <stop offset="60%" stop-color="#8c0d0d" stop-opacity="0.5"/>
          <stop offset="100%" stop-color="#2b0202" stop-opacity="0"/>
        </radialGradient>
        <linearGradient id="cl_sea" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#3b0f19"/>
          <stop offset="50%" stop-color="#1f050b"/>
          <stop offset="100%" stop-color="#0a0103"/>
        </linearGradient>
      </defs>
      <rect x="-1200" y="0" width="4000" height="900" fill="url(#cl_sky)"/>
      <circle cx="780" cy="360" r="300" fill="url(#cl_moon)"/>
      <circle cx="780" cy="360" r="130" fill="#ff3333"/>
      <path d="M480,310 Q780,270 1080,320 Q800,340 480,310 Z" fill="#2b070d" opacity="0.85"/>
      <path d="M520,380 Q780,340 1040,390 Q760,410 520,380 Z" fill="#2b070d" opacity="0.75"/>
      <path d="M-1200,690 L-1200,510 L-600,540 L0,490 L500,530 L1000,480 L1600,520 L2200,480 L2800,530 L2800,690 Z" fill="#1c070c"/>
      <rect x="-1200" y="550" width="4000" height="140" fill="url(#cl_sea)"/>
      <path d="M-1000,580 Q-800,565 -600,585 T-200,580 T200,585 T600,580 T1000,585 T1400,580 T1800,585 T2200,580 T2600,585" stroke="#ff6666" stroke-width="2.5" fill="none" opacity="0.75"/>
      <path d="M-900,610 Q-700,595 -500,615 T-100,610 T300,615 T700,610 T1100,615 T1500,610 T1900,615 T2300,610" stroke="#e62e2e" stroke-width="3" fill="none" opacity="0.65"/>
      <path d="M1280,480 L1280,410 L1315,410 M1280,430 L1300,410 M1310,410 L1310,440" stroke="#0a0203" stroke-width="5" fill="none"/>
    </g>`,
    cl: `<g filter="url(#b6)">
      <defs>
        <linearGradient id="cl_mist" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#73212c" stop-opacity="0"/>
          <stop offset="50%" stop-color="#ad3440" stop-opacity="0.4"/>
          <stop offset="100%" stop-color="#4d121a" stop-opacity="0"/>
        </linearGradient>
      </defs>
      <path d="M220,690 L220,470 L260,450 L300,470 L300,690 Z" fill="#17070b"/>
      <path d="M240,490 L280,490 M240,530 L280,530 M240,570 L280,570" stroke="#330e18" stroke-width="6"/>
      <path d="M180,690 Q150,560 100,500 Q140,520 80,460" fill="none" stroke="#0f0305" stroke-width="14" stroke-linecap="round"/>
      <path d="M1380,690 Q1410,550 1460,490 Q1420,510 1490,450" fill="none" stroke="#0f0305" stroke-width="14" stroke-linecap="round"/>
      <path d="M-600,690 L-400,500 L-200,690 M450,690 L550,540 L650,690 M1050,690 L1180,510 L1280,690" fill="#120508"/>
      <rect x="-1200" y="530" width="4000" height="160" fill="url(#cl_mist)"/>
    </g>`,
    gnd: `<g>
      <defs>
        <linearGradient id="cl_gndRock" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#302029"/>
          <stop offset="40%" stop-color="#1d1219"/>
          <stop offset="100%" stop-color="#0c050a"/>
        </linearGradient>
        <linearGradient id="cl_redSheen" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#ff4d4d" stop-opacity="0.45"/>
          <stop offset="40%" stop-color="#b32424" stop-opacity="0.25"/>
          <stop offset="100%" stop-color="#4a0808" stop-opacity="0"/>
        </linearGradient>
      </defs>
      <rect x="-1200" y="685" width="4000" height="215" fill="url(#cl_gndRock)"/>
      <rect x="-1200" y="685" width="4000" height="215" fill="url(#wall)" opacity="0.5"/>
      <rect x="-1200" y="685" width="4000" height="150" fill="url(#cl_redSheen)"/>
      <path d="M300,720 L380,740 L450,730 M550,710 L620,750 L710,735 M820,715 L900,745 L1020,725 L1100,750 M1200,710 L1280,740" fill="none" stroke="#ff6666" stroke-width="3" opacity="0.85" filter="url(#glow)"/>
      <path d="M380,740 L410,770 M900,745 L930,780 M1020,725 L1050,760" fill="none" stroke="#e62e2e" stroke-width="2.2" opacity="0.7"/>
      <path d="M200,710 L205,680 L212,710 M215,710 L220,675 L226,710 M650,705 L654,678 L660,705 M1050,708 L1055,680 L1061,708 M1350,712 L1355,682 L1362,712" stroke="#662931" stroke-width="2.5" fill="none"/>
      <ellipse cx="660" cy="735" rx="90" ry="14" fill="#6e121a" opacity="0.85"/>
      <ellipse cx="660" cy="735" rx="60" ry="8" fill="#ff4d4d" opacity="0.45"/>
      <ellipse cx="1120" cy="740" rx="120" ry="17" fill="#6e121a" opacity="0.9"/>
      <ellipse cx="1120" cy="740" rx="80" ry="10" fill="#ff6666" opacity="0.5"/>
    </g>`,
    fg: `<g filter="url(#b9)">
      <path d="M-100,0 L130,0 L90,350 L150,650 L-30,900 L-100,900 Z" fill="#080304"/>
      <path d="M1700,0 L1470,0 L1510,350 L1450,650 L1630,900 L1700,900 Z" fill="#080304"/>
      <path d="M-100,0 L600,0 L450,120 L-100,150 Z" fill="#080304"/>
      <path d="M1700,0 L1000,0 L1150,130 L1700,160 Z" fill="#080304"/>
      <path d="M-100,900 L340,900 L190,790 L-100,800 Z" fill="#080304"/>
      <path d="M1700,900 L1260,900 L1400,795 L1700,805 Z" fill="#080304"/>
    </g>`,
    light: { ambient: '#0a0507', key: '#e63939', keyL: { x: 170, y: 400 }, keyR: { x: 1430, y: 400 }, keyOp: 0.35, fog: '#5c1d24', fogOp: 0.25 },
    weather: { type: 'ash', count: 45, color: '#ff6a4a', wind: -90 },
    music: { root: 38, scale: 'locrian', tempo: 92 }
  },
  cathedral: {
    name: 'Ruined Basilica',
    sub: 'Cold starlight, broken arches and forgotten blood',
    bg: `<g>
      <defs>
        <linearGradient id="cd_sky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#060912"/>
          <stop offset="40%" stop-color="#111a2e"/>
          <stop offset="75%" stop-color="#1a2842"/>
          <stop offset="100%" stop-color="#0b101c"/>
        </linearGradient>
      </defs>
      <rect x="-1200" y="0" width="4000" height="900" fill="url(#cd_sky)"/>
      <path d="M-800,0 Q-800,300 -600,300 Q-400,300 -400,0 M-400,0 Q-400,300 -200,300 Q0,300 0,0 M0,0 Q0,300 200,300 Q400,300 400,0 M400,0 Q400,300 600,300 Q800,300 800,0 M800,0 Q800,300 1000,300 Q1200,300 1200,0 M1200,0 Q1200,300 1400,300 Q1600,300 1600,0 M1600,0 Q1600,300 1800,300 Q2000,300 2000,0 M2000,0 Q2000,300 2200,300 Q2400,300 2400,0" stroke="#162338" stroke-width="14" fill="none"/>
      <circle cx="800" cy="200" r="120" fill="#192b45" stroke="#334b6e" stroke-width="10"/>
      <path d="M800,200 L800,80 M800,200 L800,320 M800,200 L680,200 M800,200 L920,200 M800,200 L715,115 M800,200 L885,285 M800,200 L715,285 M800,200 L885,115" stroke="#334b6e" stroke-width="5"/>
      <circle cx="800" cy="200" r="85" fill="none" stroke="#334b6e" stroke-width="5"/>
      <path d="M800,200 L800,80 A120,120 0 0,1 885,115 Z" fill="#3b82ed" opacity="0.75"/>
      <path d="M800,200 L885,115 A120,120 0 0,1 920,200 Z" fill="#8e44ad" opacity="0.75"/>
      <path d="M800,200 L920,200 A120,120 0 0,1 885,285 Z" fill="#1b9aaa" opacity="0.75"/>
      <path d="M800,200 L715,115 A120,120 0 0,1 800,80 Z" fill="#4a00e0" opacity="0.75"/>
      <path d="M520,380 L520,200 Q570,140 620,200 L620,380 Z" fill="#243859" stroke="#3d5c87" stroke-width="7"/>
      <path d="M980,380 L980,200 Q1030,140 1080,200 L1080,380 Z" fill="#243859" stroke="#3d5c87" stroke-width="7"/>
      <path d="M520,270 Q570,200 620,270 M980,270 Q1030,200 1080,270" stroke="#3d5c87" stroke-width="5" fill="none"/>
      <polygon points="780,130 820,110 810,160" fill="#d0eaff" opacity="0.9"/>
      <polygon points="550,230 580,200 590,250" fill="#a6d5ff" opacity="0.85"/>
      <polygon points="1010,240 1050,210 1030,260" fill="#a6d5ff" opacity="0.85"/>
    </g>`,
    cl: `<g filter="url(#b6)">
      <defs>
        <linearGradient id="cd_god" x1="0" y1="0" x2="0.5" y2="1">
          <stop offset="0%" stop-color="#dceeff" stop-opacity="0.45"/>
          <stop offset="50%" stop-color="#88bce8" stop-opacity="0.22"/>
          <stop offset="100%" stop-color="#3d6894" stop-opacity="0"/>
        </linearGradient>
        <radialGradient id="cd_glow" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="#ffcc00" stop-opacity="0.9"/>
          <stop offset="35%" stop-color="#e67300" stop-opacity="0.45"/>
          <stop offset="100%" stop-color="#4a1500" stop-opacity="0"/>
        </radialGradient>
      </defs>
      <path d="M200,690 L200,240 Q300,160 400,240 L400,690 M1200,690 L1200,240 Q1300,160 1400,240 L1400,690" fill="none" stroke="#121e2d" stroke-width="28"/>
      <polygon points="530,200 630,180 1000,700 740,700" fill="url(#cd_god)"/>
      <polygon points="760,100 840,100 1300,700 1060,700" fill="url(#cd_god)"/>
      <polygon points="970,200 1070,180 1540,700 1300,700" fill="url(#cd_god)"/>
      <rect x="720" y="605" width="160" height="85" fill="#182436" stroke="#334863" stroke-width="5"/>
      <rect x="700" y="592" width="200" height="16" fill="#21314a" stroke="#3f5980" stroke-width="3"/>
      <rect x="740" y="565" width="7" height="27" fill="#ebdcc8"/>
      <rect x="765" y="560" width="7" height="32" fill="#ebdcc8"/>
      <rect x="830" y="558" width="7" height="34" fill="#ebdcc8"/>
      <rect x="855" y="563" width="7" height="29" fill="#ebdcc8"/>
      <polygon points="743,555 740,565 747,565" fill="#ffea00"/>
      <polygon points="768,550 765,560 772,560" fill="#ffea00"/>
      <polygon points="833,548 830,558 837,558" fill="#ffea00"/>
      <polygon points="858,553 855,563 862,563" fill="#ffea00"/>
      <circle cx="800" cy="590" r="160" fill="url(#cd_glow)"/>
      <path d="M310,670 L380,685 L360,650 L310,670 Z" fill="#182436" stroke="#334863" stroke-width="3"/>
      <circle cx="295" cy="675" r="14" fill="#182436" stroke="#334863" stroke-width="3"/>
    </g>`,
    gnd: `<g>
      <defs>
        <linearGradient id="cd_floor" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#1e2738"/>
          <stop offset="50%" stop-color="#121824"/>
          <stop offset="100%" stop-color="#080a12"/>
        </linearGradient>
      </defs>
      <rect x="-1200" y="685" width="4000" height="215" fill="url(#cd_floor)"/>
      <rect x="-1200" y="685" width="4000" height="215" fill="url(#st)" opacity="0.45"/>
      <polygon points="200,685 350,685 320,710 140,710" fill="#2b384e"/>
      <polygon points="500,685 650,685 630,710 470,710" fill="#2b384e"/>
      <polygon points="800,685 950,685 940,710 780,710" fill="#2b384e"/>
      <polygon points="1100,685 1250,685 1250,710 1090,710" fill="#2b384e"/>
      <polygon points="1400,685 1550,685 1560,710 1400,710" fill="#2b384e"/>
      <polygon points="140,710 320,710 280,745 60,745" fill="#121824"/>
      <polygon points="470,710 630,710 600,745 420,745" fill="#121824"/>
      <polygon points="780,710 940,710 920,745 740,745" fill="#121824"/>
      <polygon points="1090,710 1250,710 1240,745 1060,745" fill="#121824"/>
      <polygon points="1400,710 1560,710 1570,745 1390,745" fill="#121824"/>
      <polygon points="60,745 280,745 220,795 -40,795" fill="#2b384e"/>
      <polygon points="420,745 600,745 560,795 360,795" fill="#2b384e"/>
      <polygon points="740,745 920,745 890,795 690,795" fill="#2b384e"/>
      <polygon points="1060,745 1240,745 1220,795 1010,795" fill="#2b384e"/>
      <polygon points="1390,745 1570,745 1560,795 1340,795" fill="#2b384e"/>
      <polygon points="-40,795 220,795 150,860 -150,860" fill="#121824"/>
      <polygon points="360,795 560,795 500,860 280,860" fill="#121824"/>
      <polygon points="690,795 890,795 840,860 620,860" fill="#121824"/>
      <polygon points="1010,795 1220,795 1180,860 950,860" fill="#121824"/>
      <polygon points="1340,795 1560,795 1520,860 1280,860" fill="#121824"/>
      <ellipse cx="860" cy="720" rx="160" ry="28" fill="#b8ddff" opacity="0.32" filter="url(#b4)"/>
      <ellipse cx="1180" cy="720" rx="180" ry="30" fill="#b8ddff" opacity="0.32" filter="url(#b4)"/>
      <ellipse cx="520" cy="720" rx="140" ry="24" fill="#b8ddff" opacity="0.25" filter="url(#b4)"/>
      <ellipse cx="650" cy="750" rx="130" ry="22" fill="url(#blood)"/>
      <ellipse cx="1050" cy="760" rx="160" ry="26" fill="url(#pool)"/>
      <ellipse cx="1050" cy="760" rx="100" ry="14" fill="url(#poolShine)"/>
      <polygon points="400,730 430,725 440,740 405,745" fill="#2b3a52" stroke="#486282" stroke-width="1.8"/>
      <polygon points="1200,735 1235,730 1245,750 1210,755" fill="#2b3a52" stroke="#486282" stroke-width="1.8"/>
      <path d="M480,710 L510,735 L530,755 M880,715 L860,740 L870,765" stroke="#0a0e1a" stroke-width="3" fill="none"/>
    </g>`,
    fg: `<g filter="url(#b9)">
      <path d="M-100,0 L120,0 L90,900 L-100,900 Z" fill="#05080d"/>
      <path d="M1700,0 L1480,0 L1510,900 L1700,900 Z" fill="#05080d"/>
      <rect x="70" y="0" width="50" height="200" fill="#090e17"/>
      <rect x="1480" y="0" width="50" height="200" fill="#090e17"/>
      <rect x="65" y="740" width="55" height="160" fill="#090e17"/>
      <rect x="1480" y="740" width="55" height="160" fill="#090e17"/>
      <path d="M-100,0 L420,0 Q210,150 -100,170 Z" fill="#05080d"/>
      <path d="M1700,0 L1180,0 Q1390,150 1700,170 Z" fill="#05080d"/>
      <path d="M800,0 L800,120 M710,120 L890,120 M690,130 L730,120 M870,120 L910,130" stroke="#090e17" stroke-width="7" fill="none"/>
    </g>`,
    light: { ambient: '#06080e', key: '#a0c8e6', keyL: { x: 170, y: 400 }, keyR: { x: 1430, y: 400 }, keyOp: 0.35, fog: '#607890', fogOp: 0.22 },
    weather: { type: 'dust', count: 50, color: '#cfd8e6', wind: 6 },
    music: { root: 45, scale: 'aeolian', tempo: 70 }
  }
};
